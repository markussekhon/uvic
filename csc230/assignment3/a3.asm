;
; a3part-D.asm
;
; Part D of assignment #3
;
;
; Student name: Markus Sekhon
; Student ID: V00000000
; Date of completed work: 04/22/2023
;
; **********************************
; Code provided for Assignment #3
;
; Author: Mike Zastre (2022-Nov-05)
;
; This skeleton of an assembly-language program is provided to help you 
; begin with the programming tasks for A#3. As with A#2 and A#1, there are
; "DO NOT TOUCH" sections. You are *not* to modify the lines within these
; sections. The only exceptions are for specific changes announced on
; Brightspace or in written permission from the course instruction.
; *** Unapproved changes could result in incorrect code execution
; during assignment evaluation, along with an assignment grade of zero. ***
;


; =============================================
; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; =============================================
;
; In this "DO NOT TOUCH" section are:
; 
; (1) assembler direction setting up the interrupt-vector table
;
; (2) "includes" for the LCD display
;
; (3) some definitions of constants that may be used later in
;     the program
;
; (4) code for initial setup of the Analog-to-Digital Converter
;     (in the same manner in which it was set up for Lab #4)
;
; (5) Code for setting up three timers (timers 1, 3, and 4).
;
; After all this initial code, your own solutions's code may start
;

.cseg
.org 0
	jmp reset

; Actual .org details for this an other interrupt vectors can be
; obtained from main ATmega2560 data sheet
;
.org 0x22
	jmp timer1

; This included for completeness. Because timer3 is used to
; drive updates of the LCD display, and because LCD routines
; *cannot* be called from within an interrupt handler, we
; will need to use a polling loop for timer3.
;
; .org 0x40
;	jmp timer3

.org 0x54
	jmp timer4

.include "m2560def.inc"
.include "lcd.asm"

.cseg
#define CLOCK 16.0e6
#define DELAY1 0.01
#define DELAY3 0.1
#define DELAY4 0.5

#define BUTTON_RIGHT_MASK 0b00000001	
#define BUTTON_UP_MASK    0b00000010
#define BUTTON_DOWN_MASK  0b00000100
#define BUTTON_LEFT_MASK  0b00001000

#define BUTTON_RIGHT_ADC  0x032
#define BUTTON_UP_ADC     0x0b0   ; was 0x0c3
#define BUTTON_DOWN_ADC   0x160   ; was 0x17c
#define BUTTON_LEFT_ADC   0x22b
#define BUTTON_SELECT_ADC 0x316

.equ PRESCALE_DIV=1024   ; w.r.t. clock, CS[2:0] = 0b101

; TIMER1 is a 16-bit timer. If the Output Compare value is
; larger than what can be stored in 16 bits, then either
; the PRESCALE needs to be larger, or the DELAY has to be
; shorter, or both.
.equ TOP1=int(0.5+(CLOCK/PRESCALE_DIV*DELAY1))
.if TOP1>65535
.error "TOP1 is out of range"
.endif

; TIMER3 is a 16-bit timer. If the Output Compare value is
; larger than what can be stored in 16 bits, then either
; the PRESCALE needs to be larger, or the DELAY has to be
; shorter, or both.
.equ TOP3=int(0.5+(CLOCK/PRESCALE_DIV*DELAY3))
.if TOP3>65535
.error "TOP3 is out of range"
.endif

; TIMER4 is a 16-bit timer. If the Output Compare value is
; larger than what can be stored in 16 bits, then either
; the PRESCALE needs to be larger, or the DELAY has to be
; shorter, or both.
.equ TOP4=int(0.5+(CLOCK/PRESCALE_DIV*DELAY4))
.if TOP4>65535
.error "TOP4 is out of range"
.endif

reset:
; ***************************************************
; **** BEGINNING OF FIRST "STUDENT CODE" SECTION ****
; ***************************************************

; Anything that needs initialization before interrupts
; start must be placed here.

; ***************************************************
; ******* END OF FIRST "STUDENT CODE" SECTION *******
; ***************************************************

; ALL OF THIS CODE CAME FROM LAB 4

;Definitions for using the Analog to Digital Conversion

ldi r16, 0
sts CURRENT_CHAR_INDEX, r16 ;init of char index


;INIT FROM LAB 4
.equ ADCSRA_BTN=0x7A
.equ ADCSRB_BTN=0x7B
.equ ADMUX_BTN=0x7C
.equ ADCL_BTN=0x78
.equ ADCH_BTN=0x79

.def DATAH=r25  ;DATAH:DATAL  store 10 bits data from ADC
.def DATAL=r24
.def BOUNDARY_H=r1  ;hold high byte value of the threshold for button
.def BOUNDARY_L=r0  ;hold low byte value of the threshold for button, r1:r0

;loading loop bounds to init charset index and topline content
ldi r17, 16

ldi xl, low(CURRENT_CHARSET_INDEX)
ldi xh, high(CURRENT_CHARSET_INDEX)

ldi yl, low(TOP_LINE_CONTENT)
ldi yh, high(TOP_LINE_CONTENT)

byte_loop:
	;init loop for topline content and charset index
	ldi r16, 0
	st X, r16 ;init 0 into charset index

	adiw x, 1 ;changing index by 1 word

	ldi r16, ' '
	st Y, r16 ;init space into all topline content

	adiw y, 1 ;changing index by one word

	dec r17 ;dec loop limit
	breq byte_loop_exit

	rjmp byte_loop

byte_loop_exit:
	;init loop for topline content and charset index exit
	ldi zl, low(AVAILABLE_CHARSET*2)
	ldi zh, high(AVAILABLE_CHARSET*2)

	
	ldi r17, 0 ;register that will hold str_length
string_length_loop:
	;loop to find string length

	lpm r16, z+ ;looping to find hard limit 0
	cpi r16, 0
	breq exit_string_loop

	inc r17
	rjmp string_length_loop

exit_string_loop:
	sts STRING_LENGTH, r17 ;count string length and load into data memory

clr r17
clr r16

;LCD INIT FROM LAB 8
rcall lcd_init
; =============================================
; ====  START OF "DO NOT TOUCH" SECTION    ====
; =============================================

	; initialize the ADC converter (which is needed
	; to read buttons on shield). Note that we'll
	; use the interrupt handler for timer 1 to
	; read the buttons (i.e., every 10 ms)
	;
	ldi temp, (1 << ADEN) | (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0)
	sts ADCSRA, temp
	ldi temp, (1 << REFS0)
	sts ADMUX, r16

	; Timer 1 is for sampling the buttons at 10 ms intervals.
	; We will use an interrupt handler for this timer.
	ldi r17, high(TOP1)
	ldi r16, low(TOP1)
	sts OCR1AH, r17
	sts OCR1AL, r16
	clr r16
	sts TCCR1A, r16
	ldi r16, (1 << WGM12) | (1 << CS12) | (1 << CS10)
	sts TCCR1B, r16
	ldi r16, (1 << OCIE1A)
	sts TIMSK1, r16

	; Timer 3 is for updating the LCD display. We are
	; *not* able to call LCD routines from within an 
	; interrupt handler, so this timer must be used
	; in a polling loop.
	ldi r17, high(TOP3)
	ldi r16, low(TOP3)
	sts OCR3AH, r17
	sts OCR3AL, r16
	clr r16
	sts TCCR3A, r16
	ldi r16, (1 << WGM32) | (1 << CS32) | (1 << CS30)
	sts TCCR3B, r16
	; Notice that the code for enabling the Timer 3
	; interrupt is missing at this point.

	; Timer 4 is for updating the contents to be displayed
	; on the top line of the LCD.
	ldi r17, high(TOP4)
	ldi r16, low(TOP4)
	sts OCR4AH, r17
	sts OCR4AL, r16
	clr r16
	sts TCCR4A, r16
	ldi r16, (1 << WGM42) | (1 << CS42) | (1 << CS40)
	sts TCCR4B, r16
	ldi r16, (1 << OCIE4A)
	sts TIMSK4, r16

	sei

; =============================================
; ====    END OF "DO NOT TOUCH" SECTION    ====
; =============================================

; ****************************************************
; **** BEGINNING OF SECOND "STUDENT CODE" SECTION ****
; ****************************************************

;LOGIC FROM LAB 4
;threshold for a button press is based off of select
;every value lower than select also works for the other buttons
start:
	ldi r16, 0x16
	mov BOUNDARY_L, r16
	ldi r16, 0x03
	mov BOUNDARY_H, r16
	rjmp timer3 

;TIMER 1 LAB 4 COPIED ENTIRELY
timer1:

	push r16
	in r16, sreg
	push r16
	push r23

	lds	r16, ADCSRA_BTN	

	; bit 6 =1 ADSC (ADC Start Conversion bit), remain 1 if conversion not done
	; ADSC changed to 0 if conversion is done
	ori r16, 0x40 ; 0x40 = 0b01000000
	sts	ADCSRA_BTN, r16

;WAIT LAB 4 COPIRED ENTIRELY
wait:	lds r16, ADCSRA_BTN
		andi r16, 0x40
		brne wait

		; read the value, use XH:XL to store the 10-bit result
		lds DATAL, ADCL_BTN
		lds DATAH, ADCH_BTN

		clr r23

		; if DATAH:DATAL < BOUNDARY_H:BOUNDARY_L
		;     r23=1  "right" button is pressed
		; else
		;     r23=0

		sts BUTTON_IS_PRESSED, R23 ;LOADING R23 INTO DATA (CHANGE FROM LAB 4)

		cp DATAL, BOUNDARY_L ;comparing to see if any button is pressed
		cpc DATAH, BOUNDARY_H ;comparing to see if any button is pressed

		brcc timer1_exit ;CHANGED FROM LAB TO SKIP IF CARRY CLEAR INSTEAD OF CARRY SET
		ldi r23,1

		sts BUTTON_IS_PRESSED, R23 ;LOADING R23 INTO DATA (CHANGE FROM LAB 4)


timer1_exit:

	pop r23
	pop r16
	out sreg, r16
	pop r16

	reti ;return from interupt into timer 3

; Note: There is no "timer3" interrupt handler as you must use
; timer3 in a polling style (i.e. it is used to drive the refreshing
; of the LCD display, but LCD functions cannot be called/used from
; within an interrupt handler).

;COPIED FROM LAB 7
timer3:
	in temp, TIFR3
	sbrs temp, OCF3A
	rjmp timer3

	ldi temp, 1<<OCF3A ;clear bit 1 in TIFR3 by writing logical one to its bit position, P163 of the Datasheet
	out TIFR3, temp

	lds r23, BUTTON_IS_PRESSED ;Loading button press flag to R23

	cpi r23, 0 ;comparing with unpressed state
	breq print_dash ;if unpressed break to print_dash

	rjmp print_star ;if pressed print_star

;printing dash is designed off of blink_loop in lab 8
print_dash:
	ldi r16, 0x01 ; ROW
	ldi r17, 0x0F ; COLUMN

	;PUSHING ROW AND COLOUMN ON TSTACK TO INDICATE WHERE TO DISPLAY
	push r16
	push r17
	rcall lcd_gotoxy
	pop r17
	pop r16

	;LOADING DASH ONTO LCD In ROW/COLOUMN DESIRED
	ldi r16, '-'
	push r16
	rcall lcd_putchar
	pop r16

	rjmp timer3

;designed off of blink_loop in lab 8
print_left:
	
	;clearing all other slots and printing the topline
	rcall clear_right
	rcall clear_up
	rcall clear_down
	rcall print_char
	
	ldi r16, 0x01 ; ROW
	ldi r17, 0x00 ; COLUMN

	;PUSHING ROW AND COLOUM ON STACK TO INDICATE WHERE TO DISPLAY
	push r16
	push r17
	rcall lcd_gotoxy
	pop r17
	pop r16

	;1 into button is pressed
	ldi r16, 1
	sts BUTTON_IS_PRESSED, r16

	;L into last button pressed
	ldi r16, 'L'
	sts LAST_BUTTON_PRESSED, r16

	;putting left onto the screen
	push r16
	rcall lcd_putchar
	pop r16

	rjmp timer3

;printing star is designed off of blink_loop in lab 8
print_star:
	
	;clearing LCD to help with bouncing issues
	;rcall lcd_clr

	ldi r16, 0x01 ; ROW
	ldi r17, 0x0F ; COLUMN

	;PUSHING ROW AND COLOUM ON STACK TO INDICATE WHERE TO DISPLAY
	push r16
	push r17
	rcall lcd_gotoxy
	pop r17
	pop r16

	;LOADING STAR ONTO LCD In ROW/COLOUMN DESIRED
	ldi r16, '*'
	push r16
	rcall lcd_putchar
	pop r16

	;Checking for R
    ldi r16, 0x32
    ldi r17, 0x00
    cp DATAL, r16
    cpc DATAH, r17
    brcs print_right

    ;Check for U
    ldi r16, 0xb0
    ldi r17, 0x00
    cp DATAL, r16
    cpc DATAH, r17
    brcs print_up

	;Check for D
    ldi r16, 0x60
    ldi r17, 0x01
    cp DATAL, r16
    cpc DATAH, r17
    brcs print_down

	;Check for L
    ldi r16, 0x2b
    ldi r17, 0x02
    cp DATAL, r16
    cpc DATAH, r17
    brcs print_left

	ldi r16, 1
	sts BUTTON_IS_PRESSED, r16

	;select is pressed
	rjmp timer3

;designed off of blink_loop in lab 8
print_right:
	
	;clearing other values and printing all of top line
	rcall clear_up
	rcall clear_down
	rcall clear_left
	rcall print_char

	ldi r16, 0x01 ; ROW
	ldi r17, 0x03 ; COLUMN

	;PUSHING ROW AND COLOUM ON STACK TO INDICATE WHERE TO DISPLAY
	push r16
	push r17
	rcall lcd_gotoxy
	pop r17
	pop r16

	;button is pressed
	ldi r16, 1
	sts BUTTON_IS_PRESSED, r16

	;storing what button was pressed
	ldi r16, 'R'
	sts LAST_BUTTON_PRESSED, r16

	push r16
	rcall lcd_putchar
	pop r16

	rjmp timer3

;designed off of blink_loop in lab 8
print_up:
	
	;clearing all other button presses off of LCD and printing topline
	rcall clear_right
	rcall clear_down
	rcall clear_left
	rcall print_char

	ldi r16, 0x01 ; ROW
	ldi r17, 0x02 ; COLUMN

	;PUSHING ROW AND COLOUM ON STACK TO INDICATE WHERE TO DISPLAY
	push r16
	push r17
	rcall lcd_gotoxy
	pop r17
	pop r16

	;button is pressed
	ldi r16, 1
	sts BUTTON_IS_PRESSED, r16

	;last button pressed
	ldi r16, 'U'
	sts LAST_BUTTON_PRESSED, r16

	push r16
	rcall lcd_putchar
	pop r16

	rjmp timer3

;designed off of blink_loop in lab 8
print_down:
	
	;clearing all other characters and printing all of topline
	rcall clear_right
	rcall clear_up
	rcall clear_left
	rcall print_char
	
	ldi r16, 0x01 ; ROW
	ldi r17, 0x01 ; COLUMN

	;PUSHING ROW AND COLOUM ON STACK TO INDICATE WHERE TO DISPLAY
	push r16
	push r17
	rcall lcd_gotoxy
	pop r17
	pop r16

	;button is pressed
	ldi r16, 1
	sts BUTTON_IS_PRESSED, r16

	;last button pressed
	ldi r16, 'D'
	sts LAST_BUTTON_PRESSED, r16
	push r16
	rcall lcd_putchar
	pop r16

	;no need to push/pop off stack as we dont care about values
	;that are changing from these calls
	;rcall clear_right
	;rcall clear_up
	;rcall clear_left

	rjmp timer3

timer4:

	push r16
	in r16, sreg
	push r16

	push r17
	push r18
	push r19
	push r20
	push r21
	push r22
	push r23
	push r24
	push r25
	push r26
	push r27
	push r28
	push r29
	push r30
	push r31

	;check if button is pressed
	lds r23, BUTTON_IS_PRESSED
	cpi r23, 1
	breq button_press_confirmed

	rjmp timer4_exit

shift_right:
	;updating index to shift to the right
	lds r16, CURRENT_CHAR_INDEX
	cpi r16, 15
	breq jmp_to_timer4_exit

	;inc and loading shift
	inc r16
	sts CURRENT_CHAR_INDEX, r16

	rjmp timer4_exit

jmp_to_timer4_exit:

	;exit to end
	rjmp timer4_exit

shift_left:

	;updating index to shift to the left
	lds r16, CURRENT_CHAR_INDEX
	cpi r16, 0
	breq jmp_to_timer4_exit

	;inc and dec charindex
	dec r16
	sts CURRENT_CHAR_INDEX, r16

	rjmp timer4_exit

button_press_confirmed:
	
	;check last button pressed
	lds r23, LAST_BUTTON_PRESSED
	cpi r23, 'U'
	breq incr

	lds r23, LAST_BUTTON_PRESSED
	cpi r23, 'D'
	breq decr

	lds r23, LAST_BUTTON_PRESSED
	cpi r23, 'R'
	breq shift_right

	lds r23, LAST_BUTTON_PRESSED
	cpi r23, 'L'
	breq shift_left

	rjmp timer4_exit

incr:
	
	;loading charset and top line
	ldi xl, low(CURRENT_CHARSET_INDEX)
	ldi xh, high(CURRENT_CHARSET_INDEX)

	ldi yl, low(TOP_LINE_CONTENT)
	ldi yh, high(TOP_LINE_CONTENT)

	lds r16, CURRENT_CHAR_INDEX
	cpi r16, 0 ;skip loop if offset unneeded
	breq incr_loop_exit

incr_loop:

	adiw x, 1 ;looping to index
	adiw y, 1 ;looping to index

	dec r16
	breq incr_loop_exit ;offset finished

	rjmp incr_loop

incr_loop_exit:
	
	; ONE VARIATION NOT USING ANYMORE
	;lds r16, CURRENT_CHARSET_INDEX

	;clr r20
	;add xl, r16
	;adc xh, r20

	;lds r16, CURRENT_CHAR_INDEX
	;clr r20
	;add yl, r16
	;adc yh, r20
	; ONE VARIATION NOT USING ANYMORE


	ld r16, x ;charset index

	lds r18, STRING_LENGTH ;upperbound from init
	dec r18
	cp r16, r18 ;checking upperbounds
	breq timer4_exit

	ld r16, x ;charset index
	inc r16 ;inc charset index
	st x, r16 ;store new index value

	ldi zl, LOW(AVAILABLE_CHARSET*2)
	ldi zh, HIGH(AVAILABLE_CHARSET*2)

	clr r20 ;clearing our overflow
	add zl, r16 ;adding index
	adc zh, r20 ;adding index

	lpm r16, z ;load from program memory with charset placed in right index

	st y, r16 ;store into topline

	rjmp timer4_exit

decr:

	;load charset and top line
	ldi xl, low(CURRENT_CHARSET_INDEX)
	ldi xh, high(CURRENT_CHARSET_INDEX)

	ldi yl, low(TOP_LINE_CONTENT)
	ldi yh, high(TOP_LINE_CONTENT)

	lds r16, CURRENT_CHAR_INDEX
	cpi r16, 0
	breq decr_loop_exit ;skip offset

decr_loop:
	adiw x, 1;add offset to pointers
	adiw y, 1;add offset to pointers

	dec r16
	breq decr_loop_exit ;offset added

	rjmp decr_loop

decr_loop_exit:
	;lds r16, CURRENT_CHARSET_INDEX
	ld r16, x ;charset index IDK 

	cpi r16, 0  ;checking for lower bound
	breq timer4_exit ; took this part out for part D as it wasnt needed

	dec r16
	st x, r16 ;store new charset index

	ldi zl, LOW(AVAILABLE_CHARSET*2)
	ldi zh, HIGH(AVAILABLE_CHARSET*2)

	clr r20 ;clearing our overflow
	add zl, r16 ;find character
	adc zh, r20;find character

	lpm r16, z ;holds character

	st y, r16

	rjmp timer4_exit


decr_bc:
	;skipping for part D and is it isnt needed
	ldi r16, ' '
	sts TOP_LINE_CONTENT, r16

	rjmp timer4_exit
	


timer4_exit:

	pop r31
	pop r30
	pop r29
	pop r28
	pop r27
	pop r26
	pop r25
	pop r24
	pop r23
	pop r22
	pop r21
	pop r20
	pop r19
	pop r18
	pop r17
	pop r16
	out sreg, r16
	pop r16
	
	reti

print_char:
	;will print all 16 topline characters with this subroutine
	ldi r16, 0x00 ; ROW
	ldi r17, 0x00 ; COLUMN 

	;PUSHING ROW AND COLOUM ON STACK TO INDICATE WHERE TO DISPLAY
	push r16
	push r17
	rcall lcd_gotoxy
	pop r17
	pop r16
	
	;loading where to have topline content load in
	ldi yl, low(TOP_LINE_CONTENT)
	ldi yh, high(TOP_LINE_CONTENT)


pc_loop:
	inc r17
	cpi r17, 17 ;is our base case 
	breq pc_loop_exit ;exit loop

	ld r16, y+
	push r16
	rcall lcd_putchar ;displaying all of topline
	pop r16

	rjmp pc_loop

pc_loop_exit:
	ret

;designed off of blink_loop in lab 8
clear_right:
	ldi r16, 0x01 ; ROW
	ldi r17, 0x03 ; COLUMN

	;PUSHING ROW AND COLOUM ON STACK TO INDICATE WHERE TO DISPLAY
	push r16
	push r17
	rcall lcd_gotoxy
	pop r17
	pop r16

	ldi r16, ' '
	push r16
	rcall lcd_putchar
	pop r16

	ret

;designed off of blink_loop in lab 8
clear_up:
	ldi r16, 0x01 ; ROW
	ldi r17, 0x02 ; COLUMN

	;PUSHING ROW AND COLOUM ON STACK TO INDICATE WHERE TO DISPLAY
	push r16
	push r17
	rcall lcd_gotoxy
	pop r17
	pop r16

	ldi r16, ' '
	push r16
	rcall lcd_putchar
	pop r16

	ret

;designed off of blink_loop in lab 8
clear_down:
	ldi r16, 0x01 ; ROW
	ldi r17, 0x01 ; COLUMN

	;PUSHING ROW AND COLOUM ON STACK TO INDICATE WHERE TO DISPLAY
	push r16
	push r17
	rcall lcd_gotoxy
	pop r17
	pop r16

	ldi r16, ' '
	push r16
	rcall lcd_putchar
	pop r16

	ret

;designed off of blink_loop in lab 8
clear_left:
	ldi r16, 0x01 ; ROW
	ldi r17, 0x00 ; COLUMN

	;PUSHING ROW AND COLOUM ON STACK TO INDICATE WHERE TO DISPLAY
	push r16
	push r17
	rcall lcd_gotoxy
	pop r17
	pop r16

	ldi r16, ' '
	push r16
	rcall lcd_putchar
	pop r16

	ret


; ****************************************************
; ******* END OF SECOND "STUDENT CODE" SECTION *******
; ****************************************************


; =============================================
; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; =============================================

; r17:r16 -- word 1
; r19:r18 -- word 2
; word 1 < word 2? return -1 in r25
; word 1 > word 2? return 1 in r25
; word 1 == word 2? return 0 in r25
;
compare_words:
	; if high bytes are different, look at lower bytes
	cp r17, r19
	breq compare_words_lower_byte

	; since high bytes are different, use these to
	; determine result
	;
	; if C is set from previous cp, it means r17 < r19
	; 
	; preload r25 with 1 with the assume r17 > r19
	ldi r25, 1
	brcs compare_words_is_less_than
	rjmp compare_words_exit

compare_words_is_less_than:
	ldi r25, -1
	rjmp compare_words_exit

compare_words_lower_byte:
	clr r25
	cp r16, r18
	breq compare_words_exit

	ldi r25, 1
	brcs compare_words_is_less_than  ; re-use what we already wrote...

compare_words_exit:
	ret

.cseg
AVAILABLE_CHARSET: .db "0123456789abcdef_", 0


.dseg

BUTTON_IS_PRESSED: .byte 1			; updated by timer1 interrupt, used by LCD update loop
LAST_BUTTON_PRESSED: .byte 1        ; updated by timer1 interrupt, used by LCD update loop

TOP_LINE_CONTENT: .byte 16			; updated by timer4 interrupt, used by LCD update loop
CURRENT_CHARSET_INDEX: .byte 16		; updated by timer4 interrupt, used by LCD update loop
CURRENT_CHAR_INDEX: .byte 1			; ; updated by timer4 interrupt, used by LCD update loop


; =============================================
; ======= END OF "DO NOT TOUCH" SECTION =======
; =============================================


; ***************************************************
; **** BEGINNING OF THIRD "STUDENT CODE" SECTION ****
; ***************************************************

.dseg

STRING_LENGTH: .byte 1 ;storing string length in memory

; If you should need additional memory for storage of state,
; then place it within the section. However, the items here
; must not be simply a way to replace or ignore the memory
; locations provided up above.


; ***************************************************
; ******* END OF THIRD "STUDENT CODE" SECTION *******
; ***************************************************
