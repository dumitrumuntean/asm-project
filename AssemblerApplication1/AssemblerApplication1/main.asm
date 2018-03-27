;
; GameProject.asm
;
; Created: 3/15/2018 10:07:10 AM
; Author : Marius Papa
;

.INCLUDE "M2560DEF.INC"
.org 00

;initialize stack pointer
		ldi		r17, high(ramend)
		out		sph, r17
		ldi		r17, low(ramend)
		out		spl, r17            
		call	port_setup

;main:
main:
stage1:									;stage1 lights up one after one leds 7,0 and 2               
		ldi		r16, 128           ;r16=128
		com		r16               ;invert r16/stk600 board takes 0's as 1 and 1's as 0
		call	delay            ; wait 1 second before jump to next command 
		out		portd,r16         ;send r16 to port d
		call	delay            
		ldi		r17,1             
		com		r17
		out		portd,r17
		call	delay
		ldi		r18,16
		com		r18
		out		portd,r18
		call	delay
		ldi		r25,4
		com		r25
		out		portd,r25
		call	delay
		out		portd,r30        ;turn of the led turned on by previos step


;setting led and switches to port d and b 
port_setup:
		push	r16
		ldi		r16, 0x00          ;r16=00000000
		out		ddrb, r16          ;make port b input port      
		ldi		r16, 0xff
		out		ddrd, r16          ;make port d output port
		ldi		r16, 0xff
		out		portd, r16
		pop		r16
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

;turn off all the lights
light_all_off:
		push	r16
		ldi		r16, 0x00		;0b00000000
		com		r16				;0b11111111
		out		portd, r16		;sending to the port
		call	delay			; make a delay of 1 second
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