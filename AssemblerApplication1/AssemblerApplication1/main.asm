.INCLUDE "M2560DEF.INC"
.org 00

	.equ    LEVELS			= 10;
	.equ	array_bank		= 0x200 ; bellow is IO portion
	.equ	array_sequence	= 0x210 ; 

;initialize stack pointer
		ldi		r17, high(ramend)
		out		sph, r17
		ldi		r17, low(ramend)
		out		spl, r17            

		ldi		r16, 0x00          ;r16=00000000
		out		ddrb, r16          ;make port b input port      
		ldi		r16, 0xff
		out		ddrd, r16          ;make port d output port
		ldi		r16, 0xff
		out		portd, r16

		call	array_setup				;filling up array banck with values (1,2,4,8,16,32,64,128)
		ldi		yl, low(array_bank)     ; 0x00
		ldi		yh, high(array_bank)    ; 0x02
main:
		call	clearDisplay
		call	startGamePattern
		ldi		r20, LEVELS;
gameMainLoop:
		ldi		r19, 128           ;r16=128
		com		r19
		ldi		r17,1
		com		r17
		ldi		r21,16  
		com		r21           
		ldi		r25,4
		com		r25

		mov		r16, r19
		call	light_value
		mov		r16, r17
		call	light_value
		mov		r16, r21
		call	light_value
		mov		r16, r25
		call	light_value

		call clearDisplay

		mov		r18, r19
		call	compareInput
		mov		r18, r17
		call	compareInput
		mov		r18, r21
		call	compareInput
		mov		r18, r25
		call	compareInput
		call	win
		dec		r20
		brne	gameMainLoop

		rjmp	main

;used to fill up the array of values in a 'random' way
array_setup:
		push	r16
		ldi		xl, low(array_bank)      ; 0x00
		ldi		xh, high(array_bank)     ; 0x02
		clr		r16
		ldi		r16, 16
		st		x+, r16
		ldi		r16, 1
		st		x+, r16
		ldi		r16, 32
		st		x+, r16
		ldi		r16, 64
		st		x+, r16
		ldi		r16, 8
		st		x+, r16
		ldi		r16, 2
		st		x+, r16
		ldi		r16, 4
		st		x+, r16
		ldi		r16, 128
		st		x+, r16
		pop		r16
		ret
;fail notification
fail:
		push	r16
		push	r19
		ldi		r16, 0
		ldi		r19, 8
fail_for_loop:
		push	r16
		call	light_on
		call	delay
		pop		r16
		inc		r16
		cp		r16, r19 
		brlo	fail_for_loop
		pop		r19
		pop		r16
		rjmp	main		

;compare the input and the from a specific register
compareInput:
		in		r31,pinb 
loopinput:
		in		r19, pinb 
		cp		r19, r31
		brne	compare
		jmp		loopinput  		 		
compare:
		cp		r19, r18           ;check if r19=r18
		brne	fail				;if not equal jump to fail
		out		portd,r18
		call	delay
		ret
; falshes all the lights 3 times to notify the user 
; that he won the game
win:
		push	r17   
		ldi		r17, 3
win_for_loop:
		call	light_all_on		;turn on all the lights for a second
		call	light_all_off		;turn off all the light for a second
		dec		r17					; decrement r17 , r17  = r17 - 1
		brne	win_for_loop		; if it is bigger than 0(zero) start again
		pop		r17
		ret
;a sequance of flashes to notify the user that game starts
startGamePattern:
		push	r16
		push	r31
		in		r31,pinb 
		ldi		r16, 0b01010101
startloopinput:
		com		r16
		call	light_value
		in		r19, pinb 
		cp		r19, r31
		brne	breakfunction
		jmp		startloopinput
breakfunction:
		pop		r31
		pop		r16
		call	clearDisplay
		call	delay
		ret
	
;turn off all the lights
light_all_off:
		push	r16
		ldi		r16, 0x00		;0b00000000
		com		r16				;0b11111111
		out		portd, r16		;sending to the port
		call	delay			; make a delay of 1 second
		pop		r16
		ret

;a subroutine used to clear up the display
clearDisplay:
		push	r16
		ldi		r16, 0xff
		call	light_value
		pop		r16
		ret
;turn on all the lights
light_all_on:
		push	r16
		ldi		r16, 0xff		; 0b11111111
		com		r16				; 0b00000000
		out		portd, r16		; sending to the port
		call	delay			; make a delay of 1 second
		pop		r16
		ret
;turn on a single light without changing the state
; of other lights
;param: light number (between 0 and 7)
;parameter should be stored in r16 before calling

light_on:
		push	r17
		push	r18

	;convert number to bitmask
		ldi		r17, 1					;starting point for bitmask
light_on_shift_mask:
		tst		r16						;if input param is 0
		breq	light_on_shift_done		; we are already done
		lsl		r17						; if not, shift the mask left once
		dec		r16						; decrement counter
		rjmp	light_on_shift_mask		; jump back to test
light_on_shift_done:
		in		r18, portd				; getting current light state
		com		r18						; inverting
		or		r18, r17				; or-ing the bitmask, effectively turning on the desired light
		com		r18						
		out		portd, r18				; sending to the port

		pop		r18
		pop		r17
		ret
light_value:
		out		portd,r16         ;send r16 to port d
		call	delay            ; wait 1 second before jump to next command 
		ret
;one second delay
;example is from the book
delay:
		push	r20
		push	r21
		push	r22
		ldi		r20, 32
L1:
		ldi		r21,200
L2:
		ldi		r22,255
L3:
		nop
		nop
		dec		r22
		brne	L3
		dec		r21
		brne	L2
		dec		r20
		brne	L1
		pop		r22
		pop		r21
		pop		r20
		ret 

;-------------------------------------------------------------

