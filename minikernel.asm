; ******************************************************
; BASIC .ASM template file for AVR
; ******************************************************

.include "C:\VMLAB\include\m8def.inc"

; Define here the variables
;
.def  temp  =r16
;.EQU is used to define constant value
;or fixed addresses
;instead of these addresses we can use the name tags
.EQU   task1stackhb = 0x0070          ;address where the current stack pointer will be saved
.EQU   task1stacklb = 0x0071          ;address where the current stack pointer will be saved
.EQU   task2stackhb = 0x0072         ;instead of these addresses we can use the name tags
.EQU   task2stacklb = 0x0073         ;address where the current stack pointer will be saved
.EQU   task3stackhb = 0x0074        ;address where the current stack pointer will be saved
.EQU   task3stacklb = 0x0075       ;address where the current stack pointer will be saved

.MACRO REGISTERINIT   ;THIS INITIALISE R1-R31 & SREG
      LDI R17,32
      RLOOP:
      LDI R16,0
      PUSH R16
      DEC R17
      BRNE RLOOP
      IN R16, SREG
      PUSH R16
.ENDMACRO

.MACRO SAVE_CURRENT_SP   ;SAVES THE CURRENT STACK POINTER
       LDI R16, LOW(@0)  ;PLUS ADDRESS OF FIRST TASK
       PUSH R16
       LDI R16, HIGH(@0)
       PUSH R16
       IN R16, SPH       ;TO THE LOCATION DEFINED
		 STS @1,R16
		 IN R16, SPL
		 STS @2,R16
.ENDMACRO


;_--------------------stack macro-------------------------	______________________________________________________	
;used in code to change the stack
.MACRO TASK1STACK
      LDS R16, task1stackhb
	   OUT SPH, R16                    ;stack for the storage of data received
	   LDS R16,task1stacklb     ;by uart
	   OUT SPL, R16
.ENDMACRO 	
	
.MACRO TASK2STACK
      LDS R16, task2stackhb
	   OUT SPH, R16                    ;stack for the storage of data received
	   LDS R16, task2stacklb     ;by uart
	   OUT SPL, R16		
.ENDMACRO

.MACRO TASK3STACK
      LDS R16, task3stackhb
	   OUT SPH, R16                    ;stack for the storage of data received
	   LDS R16, task3stacklb     ;by uart
	   OUT SPL, R16
.ENDMACRO		

.MACRO   PUSHPA
	  			 PUSH R0
	  			 PUSH R1
	  			 push R2
	  			 PUSH R3
	  			 PUSH R4
	  	       PUSH R5
	  	       PUSH R6
	  			 PUSH R7
	  			 PUSH R8
	  			 PUSH R9
	  			 PUSH R10
	  			 PUSH R11
	  			 PUSH R12
	  			 PUSH R13
	  			 PUSH R14
	  			 PUSH R15
	  			 PUSH R16
	  			 PUSH R17
	  			 PUSH R18
	  			 PUSH R19
	  			 PUSH R20
	  			 PUSH R21
	  			 PUSH R22
	  			 PUSH R23
	  			 PUSH R24
	  	       PUSH R25
	  	       PUSH R26
	  			 PUSH R27
	  			 PUSH R28
	  			 PUSH R29
	  			 PUSH R30
	  			 PUSH R31
	  			 IN R16, SREG
	  			 PUSH R16
.ENDMACRO

.MACRO POPPA
              POP R16
              OUT R16, SREG
              POP R31
              POP R30
              POP R29
              POP R28
              POP R27
              POP R26
              POP R25
              POP R24
              POP R23
              POP R22
              POP R21
              POP R20
              POP R19
              POP R18
              POP R17
              POP R16
              POP R15
              POP R14
              POP R13
              POP R12
              POP R11
              POP R10
              POP R9
              POP R8
              POP R7
              POP R6
              POP R5
              POP R4
              POP R3
              POP R2
              POP R1
              POP R0
.ENDMACRO

reset:
   rjmp start
   reti      ; Addr $01
   reti      ; Addr $02
   reti      ; Addr $03
   reti      ; Addr $04
   reti      ; Addr $05
   reti      ; Addr $06        Use 'rjmp myVector'
   reti      ; Addr $07        to define a interrupt vector
   RJMP SCHEDULAR    ; Addr $08
   reti      ; Addr $09
   reti      ; Addr $0A
   reti      ; Addr $0B        This is just an example
   reti      ; Addr $0C        Not all MCUs have the same
   reti      ; Addr $0D        number of interrupt vectors
   reti      ; Addr $0E
   reti      ; Addr $0F
   reti      ; Addr $10
   reti      ; Addr $11
   reti      ; Addr $12

start:    ;THIS CODE RUNS FOR ONLY ONE TIME
;*********************************************************************************
;putting up the value of current stack pointer at memory location (initilizing the stack for tasks)
LDI R16, 0x04  ;uart
STS task1stackhb,R16
LDI R16, 0X07
STS task1stacklb,R16

LDI R16, 0x03  ;waste
STS task2stackhb,R16
LDI R16, 0x07
STS task2stacklb,R16

LDI R16, 0x02  ;display
STS task3stackhb,R16
LDI R16, 0x07
STS task3stacklb,R16
;---------------------------------------
      TASK1STACK
      SAVE_CURRENT_SP UART,task1stackhb,task1stacklb
      REGISTERINIT UART  ;macro used for pushing r0-r21, sreg in particular task stack

      TASK2STACK
      SAVE_CURRENT_SP WASTE,task2stackhb,task2stacklb
      REGISTERINIT WASTE  ;macro used for pushing r0-r21, sreg in particular task stack

      TASK3STACK
      SAVE_CURRENT_SP DISPLAY,task3stackhb,task3stacklb
      REGISTERINIT DISPLAY  ;macro used for pushing r0-r21, sreg in particular task stack


;--------------initialization of timer for 10ms and uart---------------------
      ;initializing uart
	   LDI R16, 0x33           ;baud rate is set to 9600
		OUT UBRRL, R16          ;baudrate is given to UBRRL
		LDI R16,(1<<RXEN)
		OUT UCSRB, R16         ;setting up UCSRB 	
		LDI R16, (1<<UCSZ1)|(1<<UCSZ0)|(1<<URSEL)
	   OUT UCSRC, R16
      ;timer 1
		LDI R16, (1<<TOIE1)     ;timer1 overflow interrupt enable
	   OUT TIMSK, R16
      LDI R16, 0xD8
	   OUT TCNT1H, R16         ; putting 55536 in TCNT register
	   LDI R16, 0xF0
	   OUT TCNT1L, R16
	   LDI R16, (1<<CS11)|(0<<CS10)|(0<<CS12)         ;working on prescaler clk/8, normal mode
      OUT TCCR1B, R16
	   SEI		               ;global interrupt enable
	
	   LDI R18, 1	  		   	 ;for switching task
	   STS 0x0061, R18                         ;not to be used in code anywwhere	
	   LDI R18, 1
	   STS 0X0062, R18
;********************************************************************8*******8*	
      LOOP:    RJMP LOOP


			UART:
		  		 READ:
				 SBIS UCSRA, RXC    ;uart data receive function
				 RJMP READ
				 SBI UCSRA, RXC     ;polling rxc flag for received data
				 IN R31, UDR
             STS 0x0060, R31           ;pushing the received by uart
             RJMP READ
;*****************************************************

         WASTE:                      ;a function to waste machine cycle
		      	 nop
	      	    nop
	      	    nop
		      RJMP WASTE
;****************************************************

         DISPLAY:                    ;a function to display the received data on port b      		
	          LDI R17, 0XFF      ;performing the main task
	          OUT DDRB, R17      ;of display
	          LDS R31, 0x0060
	          OUT PORTB, R31
	      RJMP DISPLAY		     	   	
;***************************************************     		    	

;-----------------------------------------------------------------	

	SCHEDULAR:
				 LDI R16, 0xD8
	  			 OUT TCNT1H, R16         ; putting 55536 in TCNT register
	  			 LDI R16, 0xF0
	  			 OUT TCNT1L, R16
	  			
	  			
	  			 LDS R18, 0x0061
	  		    CPI R18,1               ;will acts as a if condition	  			
	  			 BREQ TASK_1               ;if values are equal then we will jump to uart
             CPI R18,2               ;will act as if condition
             BREQ TASK_2              ;branch to waste
             CPI R18,3               ;will act as if condition
             BREQ TASK_3            ;branch to display


     TASK_1: RJMP TASK1
     TASK_2: RJMP TASK2
     TASK_3: RJMP TASK3

             TASK1:
              ; SAVE_CURRENT_SP UART,task1stackhb,task1stacklb  ;saving the stack pointer

              LDS R19, 0X0062
              CPI R19, 1
              BREQ T1
              CPI R19, 0
              BREQ T2
              T1:
              TASK1STACK
              DEC R19
              STS 0X0062, R19
              RETI
              T2:
	           TASK2STACK	
	           LDI R18, 2
	           STS 0x0061, R18
	           RETI
	
	          TASK2:
	
	           TASK3STACK
	           LDI R18, 3
	           STS 0x0061, R18
	           RETI
	              	
	          TASK3:
	
	           TASK1STACK
	           LDI R18, 1
	           STS 0x0061, R18
	           RETI  	
;------------------------------------------------------------					
					

				
			






