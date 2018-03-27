;
; GameProject.asm
;
; Created: 3/15/2018 10:07:10 AM
; Author : Marius Papa
;


.INCLUDE "M2560DEF.INC"
.org 00

       
	       ldi r16,0x00          ;r16=00000000
           out ddrb,r16          ;make port b input port

      
           ldi r16,0xff
           out ddrd,r16          ;make port d output port


	       ldi r17,high(ramend)
           out sph,r17
           ldi r17,low(ramend)
           out spl,r17             ;initialize stack pointer

	                                                      
	  
	      ldi r30,0xff             ;r30=255/used to turn of last led at the end of stage1
stage1:                        ;stage1 lights up one after one leds 7,0 and 2

                      
	      ldi r16,128           ;r16=128
	      com r16               ;invert r16/stk600 board takes 0's as 1 and 1's as 0
	      call delay            ; wait 1 second before jump to next command 
          out portd,r16         ;send r16 to port d
          call delay            
          ldi r17,1             
	      com r17
          out portd,r17
          call delay
          ldi r18,16
	      com r18
          out portd,r18
          call delay
		  ldi r25,4
		  com r25
		  out portd,r25
		  call delay
	      out portd,r30        ;turn of the led turned on by previos step
	      jmp waitForInput1


waitForInput1:
           
	      in r31,pinb        ;put in r31 whatever is in port b
loopinput1:
          in r19,pinb          ;put in r19 what comes from port b.if no switch is pressed r19=r31 and stays
		  cp r19,r31           ;in the loop.  If a switch is pressed r19 stores the value and the program
	      brne compare1        ;jumps to compare1
	      jmp loopinput1
		  		  		 		
compare1:
       
	      cp r19,r16            ;check if r16=r19. it compares the first value that was outputed in stage1 with the first input
	      brne fail             ;if not equal jump to fails

	      out portd,r16         ;if equal jump to waitForInput2 and waits for the second input
	      call delay
          jmp waitForInput2

waitForInput2:
           
	      in r31,pinb 
loopinput2:
          in r19,pinb 
		  cp r19,r31
	      brne compare2
	      jmp loopinput2
		  		  		 		
compare2:
       
	     cp r19,r17           
	     brne fail             

	     out portd,r17
	     call delay
         jmp waitForInput3


waitForInput3:
         in r31,pinb 
loopinput3:
          in r19,pinb 
		  cp r19,r31
	      brne compare3
	      jmp loopinput3
		  		  		 		
compare3:
       
	     cp r19,r18           ;check if r19=r18
	     brne fail             ;if not equal jump to fail

	     out portd,r18
	     call delay
	     jmp waitForInput4

waitForInput4:
             in r31,pinb
loopinput4:
          in r19,pinb
		  cp r19,r31
		  brne compare4
		  jmp loopinput4
compare4:
        
		 cp r19,r25
		 brne fail                      ;not working//////////////////////////
		 out portd,r25
		 call delay
		 jmp win
 

win:     
         ldi r28,4
        ldi r29,0x00
    repeat:	out portd,r29    
	    call delay
		com r29
		dec r28
		brne repeat
		
		
	   		
	      in r31,pinb 
restartGame:
          
          in r19,pinb 
		  cp r19,r31
	      brne fail
	      jmp restartGame

fail:

     call delay
     cbi portd,0            ;should set pin 0 to 0(low). aparently the board inverts the 
     call delay             ;input so cbi turns on the led
     cbi portd,1
     call delay
     cbi portd,2
     call delay
     cbi portd,3
     call delay
     cbi portd,4
     call delay
     cbi portd,5
     call delay
     cbi portd,6
     call delay
     cbi portd,7
     call delay
	 out portd,r30
	 call delay
	 jmp stage1

delay:
          ldi r20,32
	L1:	  ldi r21,200
	L2:	  ldi r22,255
	L3:
	     nop
		 nop
		 dec r22
		 brne L3

		 dec r21
		 brne L2
		 dec r20
		 brne L1
		 ret
