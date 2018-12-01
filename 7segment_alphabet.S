;;;  7segmentAlphabet.s 26/11/18 Group Project of group 01
;;;  This file contains all the English alphabet letters and how to display them on the 7-segment display.

#include <avr/io.h> 				

	;; the segments are connected to these pins of PORTD:
	
	SEG_A = 7		; top
	SEG_B = 1 		; upper right
	SEG_C = 2		; lower right
	SEG_D = 3		; buttom
	SEG_E = 4		; lower left
	SEG_F = 5		; upper right
	SEG_G = 6		; middle

	;; a bit mask that contains all bits used:
	ALL_SEGS = _BV(SEG_A) | _BV(SEG_B) | _BV(SEG_C) | _BV(SEG_D) | _BV(SEG_E) | _BV(SEG_F) | _BV(SEG_G)
	

	;; The English alphabet letters:
	;; Note that the seven segment follows INVERSE LOGIC. That
	;; means a 0 in the corresponding bit switches the segment on
	;; and a 1 switches the segment off. That is why the bit patterns
	;; below are inverted (~):


	CHAR_A = ~(_BV(SEG_A) | _BV(SEG_B) | _BV(SEG_C) | _BV(SEG_E) | _BV(SEG_F) | _BV(SEG_G))
	CHAR_B = ~(_BV(SEG_C) | _BV(SEG_D) | _BV(SEG_E) | _BV(SEG_F) | _BV(SEG_G))
	CHAR_C = ~(_BV(SEG_A) | _BV(SEG_D) | _BV(SEG_E) | _BV(SEG_F))
	CHAR_D = ~(_BV(SEG_B) | _BV(SEG_C) | _BV(SEG_D) | _BV(SEG_E) | _BV(SEG_G))
	CHAR_E = ~(_BV(SEG_A) | _BV(SEG_D) | _BV(SEG_E) | _BV(SEG_F) | _BV(SEG_G))
	CHAR_F = ~(_BV(SEG_A) | _BV(SEG_E) | _BV(SEG_F) | _BV(SEG_G))
	CHAR_G = ~(_BV(SEG_A) | _BV(SEG_C) | _BV(SEG_D) | _BV(SEG_E) | _BV(SEG_F))
	CHAR_H = ~(_BV(SEG_B) | _BV(SEG_C) | _BV(SEG_E) | _BV(SEG_F) | _BV(SEG_G))
	CHAR_I = ~(_BV(SEG_B) | _BV(SEG_C))
	CHAR_J = ~(_BV(SEG_B) | _BV(SEG_C) | _BV(SEG_D) | _BV(SEG_E))
	CHAR_K = ~(_BV(SEG_B) | _BV(SEG_C) | _BV(SEG_E) | _BV(SEG_F) | _BV(SEG_G))
	CHAR_L = ~(_BV(SEG_D) | _BV(SEG_E) | _BV(SEG_F))
	CHAR_M = ~(_BV(SEG_A) | _BV(SEG_C) | _BV(SEG_E))
	CHAR_N = ~(_BV(SEG_A) | _BV(SEG_B) | _BV(SEG_C) | _BV(SEG_E) | _BV(SEG_F))
	CHAR_O = ~(_BV(SEG_A) | _BV(SEG_B) | _BV(SEG_C) | _BV(SEG_D) | _BV(SEG_E) | _BV(SEG_F))
	CHAR_P = ~(_BV(SEG_A) | _BV(SEG_B) | _BV(SEG_E) | _BV(SEG_F) | _BV(SEG_G))
	CHAR_Q = ~(_BV(SEG_A) | _BV(SEG_B) | _BV(SEG_C) | _BV(SEG_F) | _BV(SEG_G))
	CHAR_R = ~(_BV(SEG_A) | _BV(SEG_B) | _BV(SEG_E) | _BV(SEG_F))
	CHAR_S = ~(_BV(SEG_A) | _BV(SEG_C) | _BV(SEG_D) | _BV(SEG_F) | _BV(SEG_G))
	CHAR_T = ~(_BV(SEG_D) | _BV(SEG_E) | _BV(SEG_F) | _BV(SEG_G))
	CHAR_U = ~(_BV(SEG_B) | _BV(SEG_C) | _BV(SEG_D) | _BV(SEG_E) | _BV(SEG_F))
	CHAR_V = ~(_BV(SEG_B) | _BV(SEG_F) | _BV(SEG_G))
	CHAR_W = ~(_BV(SEG_B) | _BV(SEG_C) | _BV(SEG_D) | _BV(SEG_E) | _BV(SEG_F) | _BV(SEG_G))
	CHAR_X = ~(_BV(SEG_C) | _BV(SEG_F) | _BV(SEG_G))
	CHAR_Y = ~(_BV(SEG_B) | _BV(SEG_C) | _BV(SEG_D) | _BV(SEG_F) | _BV(SEG_G))
	CHAR_Z = ~(_BV(SEG_A) | _BV(SEG_B) | _BV(SEG_D) | _BV(SEG_E) | _BV(SEG_G))
	CHAR_ERROR_INPUT = ~(_BV(SEG_A) | _BV(SEG_D) | _BV(SEG_G)) ;This will be displayed if there is no corresponding letter.
