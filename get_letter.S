;;; This file decodes the letter described as morse code in registers 29(length) and 30(dashes and dots)
;;; Part of the group project of group 01

;;; just including the standard symbol definitions of all ports:
#define __SFR_OFFSET 0
#include <avr/io.h>

;;; import all lettes definitions for the seven segment display.
#include "7segment_alphabet.S"

decode_and_display_letter:
;;; this five compares follow inverse logic because breq
;;; could only be used for jumps > -64 and < 64
;;; doing it this way we use jmp which can make jumps
;;; greater than -1024 and less than 1024 and in this way
;;; we are able to reach the definitions of count_X (0<=X<=4)

	cpi r29, 0		;if button has been pressed 0 times
	brne next_compare0
	jmp restore_status_register
	
next_compare0:	
	cpi r29, 1		;if button has been pressed 1 times
	brne next_compare1
	jmp count_1
	
next_compare1:
	cpi r29, 2		;if button has been pressed 2 times
	brne next_compare2
	jmp count_2
	
next_compare2:
	cpi r29, 3		;if button has been pressed 3 times
	brne next_compare3
	jmp count_3
	
next_compare3:
	cpi r29, 4 		;if button has been pressed 4 times
	brne go_to_default
	jmp count_4
	
go_to_default:
	jmp error_input
	;; button has been pressed more than 4 times which is a mistakes
	;; as letters contain at moset 4 dots and dashes


;;; checks letters with only one dot and dash (E and F)
count_1:
	cpi r30, 0
	breq load_letter_E
	cpi r30, 1
	breq load_letter_T
	
load_letter_E:
	ldi r31, CHAR_E
	jmp done
load_letter_T:
	ldi r31, CHAR_T
	jmp done

;;; checks letters with 2 dots and dashs (I, A, N, M)
count_2:
	cpi r30, 0b00
	breq load_letter_I

	cpi r30, 0b01
	breq load_letter_A

	cpi r30, 0b10
	breq load_letter_N

	cpi r30, 0b11
	breq load_letter_M

load_letter_I:
	ldi r31, CHAR_I
	jmp done
load_letter_A:
	ldi r31, CHAR_A
	jmp done
load_letter_N:
	ldi r31, CHAR_N
	jmp done
load_letter_M:
	ldi r31, CHAR_M
	jmp done

;;; checks letters with 3 dots and dashs (S, U, R, W, D, K, G, O)	
count_3:
	cpi r30, 0b000
	breq load_letter_S
	
	cpi r30, 0b001
	breq load_letter_U

	cpi r30, 0b010
	breq load_letter_R
	
	cpi r30, 0b011
	breq load_letter_W

	cpi r30, 0b100
	breq load_letter_D
	
	cpi r30, 0b101
	breq load_letter_K

	cpi r30, 0b110
	breq load_letter_G
	
	cpi r30, 0b111
	breq load_letter_O

load_letter_S:
	ldi r31, CHAR_S
	jmp done
load_letter_U:
	ldi r31, CHAR_U
	jmp done
load_letter_R:
	ldi r31, CHAR_R
	jmp done
load_letter_W:
	ldi r31, CHAR_W
	jmp done
load_letter_D:
	ldi r31, CHAR_D
	jmp done
load_letter_K:
	ldi r31, CHAR_K
	jmp done
load_letter_G:
	ldi r31, CHAR_G
	jmp done
load_letter_O:
	ldi r31, CHAR_O
	jmp done

;;; checks letters with 2 dots and dashs (H, V, F, L, P, J, B, X, C, Y, Z, Q)
count_4:
	cpi r30, 0b0000
	breq load_letter_H
	
	cpi r30, 0b0001
	breq load_letter_V

	cpi r30, 0b0010
	breq load_letter_F
	
	cpi r30, 0b0100
	breq load_letter_L

	cpi r30, 0b0110
	breq load_letter_P
	
	cpi r30, 0b0111
	breq load_letter_J

	cpi r30, 0b1000
	breq load_letter_B
	
	cpi r30, 0b1001
	breq load_letter_X

	cpi r30, 0b1010
	breq load_letter_C
	
	cpi r30, 0b1011
	breq load_letter_Y

	cpi r30, 0b1100
	breq load_letter_Z
	
	cpi r30, 0b1101
	breq load_letter_Q
	
	;; there are combinations of 4 dots and digits not representing an letter in morse
	;; if reached here => there is no such letter => error_input
	jmp error_input

load_letter_H:
	ldi r31, CHAR_H
	jmp done
load_letter_V:
	ldi r31, CHAR_V
	jmp done
load_letter_F:	
	ldi r31, CHAR_F
	jmp done
load_letter_L:
	ldi r31, CHAR_L
	jmp done
load_letter_P:
	ldi r31, CHAR_P
	jmp done
load_letter_J:
	ldi r31, CHAR_J
	jmp done
load_letter_B:
	ldi r31, CHAR_B
	jmp done
load_letter_X:
	ldi r31, CHAR_X
	jmp done
load_letter_C:
	ldi r31, CHAR_C
	jmp done
load_letter_Y:
	ldi r31, CHAR_Y
	jmp done
load_letter_Z:
	ldi r31, CHAR_Z
	jmp done
load_letter_Q:
	ldi r31, CHAR_Q
	jmp done

error_input:
	ldi r31, CHAR_ERROR_INPUT


;;; when done dysplay the letter stored in register r31 on PORTD
;;; and go back to finished_decoding in file group_01.S
done:
	;;; clear counter of morse symbols and the stored morse symbols
	clr r29
	clr r30
	out PORTD, r31
	jmp finished_decoding
