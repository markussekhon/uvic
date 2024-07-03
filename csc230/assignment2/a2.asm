; a2-signalling.asm
; University of Victoria
; CSC 230: Spring 2023
; Instructor: Ahmad Abdullah
;
; Student name: Markus Sekhon
; Student ID: V00826257
; Date of completed work: 02/16/23
;
; *******************************
; Code provided for Assignment #2 
;
; Author: Mike Zastre (2022-Oct-15)
;
 
; This skeleton of an assembly-language program is provided to help you
; begin with the programming tasks for A#2. As with A#1, there are "DO
; NOT TOUCH" sections. You are *not* to modify the lines within these
; sections. The only exceptions are for specific changes changes
; announced on Brightspace or in written permission from the course
; instructor. *** Unapproved changes could result in incorrect code
; execution during assignment evaluation, along with an assignment grade
; of zero. ****

.include "m2560def.inc"
.cseg
.org 0

; ***************************************************
; **** BEGINNING OF FIRST "STUDENT CODE" SECTION ****
; ***************************************************

	; initializion code will need to appear in this
    ; section

ldi r16, low(RAMEND)
ldi r17, high(RAMEND)
out SPL, r16
out SPH, r17


; ***************************************************
; **** END OF FIRST "STUDENT CODE" SECTION **********
; ***************************************************

; ---------------------------------------------------
; ---- TESTING SECTIONS OF THE CODE -----------------
; ---- TO BE USED AS FUNCTIONS ARE COMPLETED. -------
; ---------------------------------------------------
; ---- YOU CAN SELECT WHICH TEST IS INVOKED ---------
; ---- BY MODIFY THE rjmp INSTRUCTION BELOW. --------
; -----------------------------------------------------

	rjmp test_part_a

	; Test code


test_part_a:
	ldi r16, 0b00100001
	rcall set_leds
	rcall delay_long

	clr r16
	rcall set_leds
	rcall delay_long

	ldi r16, 0b00111000
	rcall set_leds
	rcall delay_short

	clr r16
	rcall set_leds
	rcall delay_long

	ldi r16, 0b00100001
	rcall set_leds
	rcall delay_long

	clr r16
	rcall set_leds

	rjmp end


test_part_b:
	ldi r17, 0b00101010
	rcall slow_leds
	ldi r17, 0b00010101
	rcall slow_leds
	ldi r17, 0b00101010
	rcall slow_leds
	ldi r17, 0b00010101
	rcall slow_leds

	rcall delay_long
	rcall delay_long

	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds
	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds
	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds
	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds

	rjmp end

test_part_c:
	ldi r16, 0b11111000
	push r16
	rcall leds_with_speed
	pop r16

	ldi r16, 0b11011100
	push r16
	rcall leds_with_speed
	pop r16

	ldi r20, 0b00100000
test_part_c_loop:
	push r20
	rcall leds_with_speed
	pop r20
	lsr r20
	brne test_part_c_loop

	rjmp end


test_part_d:
	ldi r21, 'E'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long

	ldi r21, 'A'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long


	ldi r21, 'M'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long

	ldi r21, 'H'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long

	rjmp end


test_part_e:
	ldi r25, HIGH(WORD02 << 1)
	ldi r24, LOW(WORD02 << 1)
	rcall display_message
	rjmp end

end:
    rjmp end






; ****************************************************
; **** BEGINNING OF SECOND "STUDENT CODE" SECTION ****
; ****************************************************

set_leds:

		push r17
		push r18
		push r19
		push r20

		ldi r17, 0xFF ;set ddr for L and B
		sts DDRL, r17
		out DDRB, r17

		mov r17, r16

		clr r18
		clr r19

		ldi r20, 0x04 ;loop count 4

	setPortL:
		lsr r17
		rol r18
		lsl r18
		dec r20
		brne setPortL

		ldi r20, 0x02 ;set loop count to 2

	setPortB:
		lsr r17
		rol r19
		lsl r19
		dec r20
		brne setPortB

	sts PORTL, r18 ;set leds correctly
	out PORTB, r19 ;set leds correctly

	pop r20
	pop r19
	pop r18
	pop r17

	ret


slow_leds:

	mov r16, r17
	rcall set_leds ;set leds
	rcall delay_long ;delay correctly
	ldi r16, 0x00
	rcall set_leds ;turn off led
	ret


fast_leds:
	mov r16, r17
	rcall set_leds ;set leds
	rcall delay_short ;declay correctly
	ldi r16, 0x00
	rcall set_leds ;turn off led
	ret


leds_with_speed:

		.set StackOffset=8 ;to offset for values loaded into stack

		push r17
		push r18
		push r28
		push r29


		in r28, SPL ;stackpointerlow
		in r29, SPH ;stackpointerhigh

		ldd r17, Y+StackOffset ;offset applied

		mov r18, r17 ;r17 holds value in stack
		andi r18, 0xC0 ;mask
		breq leadingZeros ;fast leds

		rcall slow_leds

		pop r29
		pop r28
		pop r18
		pop r17

		ret

	leadingZeros:

		rcall fast_leds

		pop r29
		pop r28
		pop r18
		pop r17

		ret


; Note -- this function will only ever be tested
; with upper-case letters, but it is a good idea
; to anticipate some errors when programming (i.e. by
; accidentally putting in lower-case letters). Therefore
; the loop does explicitly check if the hyphen/dash occurs,
; in which case it terminates with a code not found
; for any legal letter.

encode_letter:

			.set StackOffset=12

			push r17
			push r18
			push r19
			push r20
			push r28
			push r29
			push r30
			push r31

			ldi r19, 0x06 ;loaded for a loop later
			clr r25 ;clearing r25

			in r28, SPL ;stackpointer low
			in r29, SPH ;stack pointer high

			ldd r17, Y+StackOffset ;load from data

			ldi r30, low(PATTERNS<<1) ;access table
			ldi r31, high(PATTERNS<<1) ;access table

		loopToFindLetter:
			lpm r18, Z ;loading value from table

			cp r18, r17 ;comparing value from table with data
			breq foundLetter

			cpi r18, '-' ;end of table
			breq foundLetter

			adiw Z, 0x08 ;offset to find letter 
			rjmp loopToFindLetter

		foundLetter:
			adiw Z, 0x01 
			lpm r20, Z ;loading value 

			lsl r25 ;register holding final binary value
			cpi r20, 'o' ;checking to see if 1/0 necessary
			breq binaryOne

			dec r19 ;dec counter
			breq fastOrSlow
			rjmp foundLetter

		binaryOne:
			ori r25, 0x01 ;add 1

			dec r19
			breq fastOrSlow ;check if fast or slow now
			rjmp foundLetter

		fastOrSlow:

			adiw Z,0x01
			lpm r20, Z
			cpi r20, 2 ;check if last value indicates slow or fast
			breq done
			ori r25, 0xC0
			rjmp done

		done:

			pop r31
			pop r30
			pop r29
			pop r28
			pop r20
			pop r19
			pop r18
			pop r17
			
			;end of this code will have value needed to be loaded in r25

	ret


display_message:

	push r23
	push r30
	push r31

	mov r30, r24
	mov r31, r25

	loopToFindString:
			lpm r23, Z; loading letter

			tst r23 ; check letter
			breq endDisplayMessage ;break out

			push ZH ;to make sure values are kept
			push ZL ;to make sure values are kept

			push r23
			rcall encode_letter ;get letter into r25
			pop r23

			push r25
			rcall leds_with_speed ;diplay the letter
			rcall delay_short
			rcall delay_short
			pop r25

			pop ZL ;keep values
			pop ZH ;keep values

			adiw Z, 0x01 ;increment

			rjmp loopToFindString

	endDisplayMessage:

			pop r31
			pop r30
			pop r23

	ret



; ****************************************************
; **** END OF SECOND "STUDENT CODE" SECTION **********
; ****************************************************




; =============================================
; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; =============================================

; about one second
delay_long:
	push r16

	ldi r16, 14
delay_long_loop:
	rcall delay
	dec r16
	brne delay_long_loop

	pop r16
	ret


; about 0.25 of a second
delay_short:
	push r16

	ldi r16, 4
delay_short_loop:
	rcall delay
	dec r16
	brne delay_short_loop

	pop r16
	ret

; When wanting about a 1/5th of a second delay, all other
; code must call this function
;
delay:
	rcall delay_busywait
	ret


; This function is ONLY called from "delay", and
; never directly from other code. Really this is
; nothing other than a specially-tuned triply-nested
; loop. It provides the delay it does by virtue of
; running on a mega2560 processor.
;
delay_busywait:
	push r16
	push r17
	push r18

	ldi r16, 0x08
delay_busywait_loop1:
	dec r16
	breq delay_busywait_exit

	ldi r17, 0xff
delay_busywait_loop2:
	dec r17
	breq delay_busywait_loop1

	ldi r18, 0xff
delay_busywait_loop3:
	dec r18
	breq delay_busywait_loop2
	rjmp delay_busywait_loop3

delay_busywait_exit:
	pop r18
	pop r17
	pop r16
	ret


; Some tables
.cseg
; .org 0x600

PATTERNS:
	; LED pattern shown from left to right: "." means off, "o" means
    ; on, 1 means long/slow, while 2 means short/fast.
	.db "A", "..oo..", 1
	.db "B", ".o..o.", 2
	.db "C", "o.o...", 1
	.db "D", ".....o", 1
	.db "E", "oooooo", 1
	.db "F", ".oooo.", 2
	.db "G", "oo..oo", 2
	.db "H", "..oo..", 2
	.db "I", ".o..o.", 1
	.db "J", ".....o", 2
	.db "K", "....oo", 2
	.db "L", "o.o.o.", 1
	.db "M", "oooooo", 2
	.db "N", "oo....", 1
	.db "O", ".oooo.", 1
	.db "P", "o.oo.o", 1
	.db "Q", "o.oo.o", 2
	.db "R", "oo..oo", 1
	.db "S", "....oo", 1
	.db "T", "..oo..", 1
	.db "U", "o.....", 1
	.db "V", "o.o.o.", 2
	.db "W", "o.o...", 2
	.db "W", "oo....", 2
	.db "Y", "..oo..", 2
	.db "Z", "o.....", 2
	.db "-", "o...oo", 1   ; Just in case!

WORD00: .db "HELLOWORLD", 0, 0
WORD01: .db "THE", 0
WORD02: .db "QUICK", 0
WORD03: .db "BROWN", 0
WORD04: .db "FOX", 0
WORD05: .db "JUMPED", 0, 0
WORD06: .db "OVER", 0, 0
WORD07: .db "THE", 0
WORD08: .db "LAZY", 0, 0
WORD09: .db "DOG", 0

; =======================================
; ==== END OF "DO NOT TOUCH" SECTION ====
; =======================================

