;;;  YOUR CODE SHOULD GO INTO THIS FILE.
;;;	PLEASE ADD YOUR OWN COMMENTED HEADER


;;; Basis of timing:
;;; First of all the timer prescaler is set to 1024, ie one timer tick
;;; is 1024 CPU clock ticks. Then we only look at the high byte of the
;;; 16 bit timer1, which is the basis for all timing. One tick at the
;;; high byte is 1024*256 CPU clock ticks. With a CPU clock of 16MHz,
;;; ie 16,000,000 CPU clock ticks per second, this means one tick in
;;; the high byte of timer1 corresponds to 256*1024 / 16.000.000 Hz =
;;; 16ms. So 16ms is the basis of all our timings, about 61 ticks per second:

	CPU_FREQ = 16000000
	TICKS_PER_SEC = CPU_FREQ / (256 * 1024)

	DECISION_LIMIT = TICKS_PER_SEC / 5 ; 200ms - distinguishing between a dot and a dash
	TIMEOUT = 2 * TICKS_PER_SEC / 5	   ; 400ms - marks the end of a letter

;;; Timer1 capture interrupt is used to record the length of button
;;; presses and button releases. 
;;; 
;;; r19: used a flag that indicates whether the timer has overrun its
;;; max value while a button has been held pressed.
	

	
;;; just including the standard symbol definitions of all ports:
#define __SFR_OFFSET 0
#include <avr/io.h>

;;; include all symbol definitions for the seven segement display:
#include "7segment_alphabet.S"
#include "get_letter.S"

;;; Button is connected to PIN 8, PORTB, Bit 0, because that doubles as the ICP1 for timer1.
	.global BUTTON
	BUTTON = 0
	
;;; user code starts from here, as init.S ends with jmp main:

	.global main 		; declaring main global, so it can be used in other files	
main:
	nop
	
	ldi r24, ALL_SEGS
	out DDRD, r24 		; make pins of PORTD output (except pin 0)


	clr r16
	sts TCCR1A, r16 	; setting timer output mode: no output
				; pin used, normal counting up. 

	ldi r16, TIMEOUT	; time in 16ms ticks to detect a TIMEOUT,
				; about 400ms.
				; long and short button presses. 
	sts OCR1AH, r16		; move into high byte of compare match
				; register A
	
	clr r16			; low byte of compare match is just 0.
	sts OCR1AL, r16         ; 16bit registers always have to
				; be written high byte first

	;; enable input capture interrupt (to time button presses) and
	;; compare match interrupt (the time-out to mark the end of a letter)
	ldi r16, _BV(ICIE1) | _BV(OCIE1A)
	sts TIMSK1, r16

	;; enable noise canceller, set prescaler to 1024, and start
	;; timer in CTC mode
 
	ldi r16,  _BV(ICNC1) | _BV(CS12) | _BV(CS10) | _BV(WGM12)
	sts TCCR1B, r16

	clr r19			; reset overflow flag to defined state

	clr r29
	clr r30
	push r29
	push r30
	
	sei			; enable interrupts globally.

do_nothing: rjmp do_nothing 	; do nothing => just wait for the
				; interrupts to occur -- forever.

;;; This interrupt service routine is called whenever timer1 has
;;; counted up to match the value stored in OCA1, ie when more then
;;; GAP_LIMIT time has elapses since the last button press or release.
	
	.global timer1_compa_isr  ; export symbol to overwrite weak
				; definition in init.S
	
timer1_compa_isr:			

	push r16	
	in r16, SREG		; save the status register.
	push r16

	;; check whether we are waiting for a button press or release:
	lds r16, TCCR1B
	sbrs r16, ICES1 	; skip if waiting for postive edge (ie for button release)
	rjmp awaiting_press

awaiting_release:
	;;  make sure also an overly long press is always recognised
	;;  as a long press, irrespective of a timer overrun:

	ser r19 		; using r19 as a flag to indicate a
				; timer overflow has occured.
	rjmp restore_status_register

awaiting_press:	
	;; if we are waiting for a button press, then more time than
	;; TIME-OUT has elasped since the last release -- in this case
	;; the morse code of the letter has ended
	
	jmp decode_and_display_letter ; this is in file get_letter.S

	;; making it global so that it can be reached from get_letter.S
	.global finished_decoding
finished_decoding:
	ldi r16, _BV(0) 	; pull-up for button stays on.
	out PORTB, r16

	;; making it global so that it can be reached from get_letter.S
	;; if the count of button clicks is zero
	.global restore_status_register
restore_status_register:
	pop r16
	out SREG, r16 		; restore status register
	pop r16
	
	reti


;;; This interrupt service routine times the duration of button
;;; presses. It is also involved in timing button releases as it
;;; always resets timer1 when called.
;;; It is called whenever the signal at ICP1 (PORTB0) changes in a
;;; certain direction. If we are called for a negative edge (button
;;; has just been depressed), we go on waiting for a positive edge
;;; (button will be released) and vice-versa.
	
	.global timer1_cpt_isr

timer1_cpt_isr:

	push r8

	in r8, SREG 		; save the status register.
	push r8

	lds r8, ICR1L		; get the timer count when the capture event happened.
	lds r8, ICR1H           ; we discard the low part, only
				; interested in the high part, but
				; reading low byte is necessary to get
				; a correct high byte in ICR1H
	push r17				


	or r17, r8

	mov r17,r19		;  debounce. If there is no timer overflow and
	or r17,r8		;  ICR1H is still zero, then 
				;  less than 16ms have elapsed since
				;  last release or press
	breq debounce		;  and we do nothing



	clr r17
	sts TCNT1H, r17 	; reset timer, first writing the high byte to the latch
	sts TCNT1L, r17		; then the low byte

	;; check whether we were looking for a positive or a negative edge:
	lds r17, TCCR1B
	sbrs  r17, ICES1	; skip next instruction if positive edge dedection.
	
	rjmp pressed		; we have a negative edge ie button
				; has been pressed

	;; positive edge, button has been released
	rcall released

	andi r17, ~(_BV(ICES1)) ; we have had positive edge, so next
				; time looking for negative edge
	rjmp end_isr

	
pressed:
	ori r17, _BV(ICES1)	; next time detect positive edge, ie a
				; button release.
	ldi r31, ALL_SEGS
	out PORTD, r31		; turn off all segs if the button is pressed
	clr r31

end_isr:
	sts TCCR1B, r17 	; write r17 to TCCR1B to activate the
				; change in edge detection.
	
debounce:
	pop r17
	pop r8
	out SREG, r8		; restore status register
	pop r8

	reti

;;; This subroutine handles the detection of the end of a morse
;;; signal.
;;; It expects the durations of button presses in 16ms ticks in r8


released:
	inc r29
;;; IMPORTANT!!!  using r29 as a counter of button clicks(count of dashes and dots)
	
	ldi r16, _BV(BUTTON)
	out PORTB, r16
	push r16
	tst r19 		; Did we have a timer overflow
				; (ie more than TIMEOUT time since the
				; last released of the button?
	brne long_press		; if yes, then signal is a long
				; press in any case

	;; is the signal longer than DECISION_LIMIT?
	ldi r16, DECISION_LIMIT
	cp r8,r16
	brcs short_press	; if it is shorter jump to label short

;;; We are using r30 to store the dots(0) and dashes(1)
long_press:
	lsl r30			; shift r30 to the left
	inc r30			; add 1 for the new dash
	rjmp 1f

short_press:
	lsl r30			; shift r30 to the left
	;; the added 0 at the right side of the register represents the new dot
	
1:
	ldi r16, _BV(BUTTON)	; turn the button on
	out PORTB, r16
	pop r16
	clr r19			; clear overflow flag in case it was set
	reti
