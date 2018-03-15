;
; GAME_PROJECT_CAL.asm
;
; Created: 15-Mar-18 09:09:03
; Author : Cristian
;
	.equ counter = 2
	ldi r16, counter	    ;loading counter value into register
	ldi r17, 1				;loading cont  step value
loop:
	sub r16, r17			;4 - 1
	breq end				;if  0 then end the loop
	nop						; do nothing
		
							

	ldi r16, 0xff           ; load the bit pattern 1111 1111 into r16
	out ddra, r16           ; write the bit pattern to port a's data direction register

	rjmp loop				;back to loop label
end: 
	nop

