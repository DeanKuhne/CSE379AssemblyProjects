.text

	.global uart_init
	.global gpio_init
	.global output_character
	.global read_character
	.global read_string
	.global output_string
	.global read_from_push_btns
	.global illuminate_LEDs
	.global illuminate_RGB_LED
	.global read_from_keypad
	.global character_newline
	.global subtract
	.global divide
	.global compute

gpio_init:
	STMFD sp!,{lr,r0,r2}	; Store register lr on stack

	MOV r0, #0xE608
	MOVT r0, #0x400F
	LDR r2, [r0]
	ORR r2, r2, #0x2B
	STR r2, [r0]

	MOV r0, #0x4404
	MOVT r0, #0x4000
	LDR r2, [r0]
	AND r2, r2, #0x00
	STR r2, [r0]

	MOV r0, #0x4408
	MOVT r0, #0x4000
	LDR r2, [r0]
	AND r2, r2, #0x00
	STR r2, [r0]

	MOV r0, #0x440C
	MOVT r0, #0x4000
	LDR r2, [r0]
	ORR r2, r2, #0x2B
	STR r2, [r0]

	MOV r0, #0x4410
	MOVT r0, #0x4000
	LDR r2, [r0]
	ORR r2, r2, #0x2B
	STR r2, [r0]

;------------------PORTD--------------
	MOV r12, #0x73FC
	MOVT r12, #0x4000	; Sets r12 to PORTD's data register
	MOV r11, #0x7400
	MOVT r11, #0x4000	; Sets r11 to PORTD's direction

	LDR r10, [r11]
	ORR r9, r10, #0xF	; Sets pins 0-3 on PORTD to output
	STR r9, [r11]

	MOV r8, #0x751C
	MOVT r8, #0x4000	; Sets r8 to digital register
	LDRB r7, [r8]
	ORR r7, r7, #0xF;uhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
	STRB r7, [r8]

	LDRB r5, [r12]
	MOV r6, #0xF
	ORR r6, r6, r5
	STRB r6, [r12]		; Sets pins 0-3 to output 1

	SUB r6, r6, r6
	SUB r7, r7, r7
	SUB r8, r8, r8
	SUB r9, r9, r9
	SUB r10, r10, r10
	SUB r11, r11, r11

; ENABLE GPIO Interrupts by enabling NVIC (Nested Vector Interrupt Controller) by writing a 1 to bit 1 of EN0
	MOV r0, #0xE100
	MOVT r0, #0xE000
	LDR r2, [r0]
	ORR r2, r2, #0x8
	STR r2, [r0]
;---------------END PORTD------------


;------------------PORTA------------------
	MOV r11, #0x43FC
	MOVT r11, #0x4000	; Sets r11 to PORTA's data register
	MOV r6, #0x4400
	MOVT r6, #0x4000	; Sets r6 to PORTA's direction

	LDR r10, [r6]
	AND r9, r10, #0x00	; Sets pins 0-7(2-5) on PORTA to input
	STR r9, [r6]

	MOV r8, #0x451C
	MOVT r8, #0x4000	; Sets r8 to digital register
	LDRB r7, [r8]
	ORR r7, r7, #0x3C
	STRB r7, [r8]

; ENABLE GPIO Interrupts by enabling NVIC (Nested Vector Interrupt Controller) by writing a 1 to bit 1 of EN0 hhhh
	MOV r0, #0xE100
	MOVT r0, #0xE000
	LDR r2, [r0]
	ORR r2, r2, #0x1
	STR r2, [r0]

;--------------END PORTA-------------------

	LDMFD sp!, {lr,r0,r2}
	BX lr
;-------------------------END OF GPIO INIT-------------------------------------------
uart_init:
	STMFD sp!,{lr,r0,r1,r2}	; Store register lr on stack

; Giving clock to uart0
	MOV r0, #0xE618
	MOVT r0, #0x400F
	LDR r2, [r0]
	ORR r2, r2, #1
	STR r2, [r0]

; Enable clock to port A
	MOV r0, #0xE608
	MOVT r0, #0x400F
	LDR r2, [r0]
	ORR r2, r2, #1
	STR r2, [r0]

; Disable uart0 control
	MOV r0, #0xC030
	MOVT r0, #0x4000
	LDR r2, [r0]
	ORR r2, r2, #0
	STR r2, [r0]

; Set UART0_IBRD_R for 57,600 baud
	MOV r0, #0xC024
	MOVT r0, #0x4000
	LDR r2, [r0]
	ORR r2, r2, #17
	STR r2, [r0]

; Set UART0_FBRD_R for 57,600 baud
	MOV r0, #0xC028
	MOVT r0, #0x4000
	LDR r2, [r0]
	ORR r2, r2, #23
	STR r2, [r0]

; Use system clock
	MOV r0, #0xCFC8
	MOVT r0, #0x4000
	LDR r2, [r0]
	ORR r2, r2, #0
	STR r2, [r0]

; Use 8-bit word length, 1 stop bit, no parity
	MOV r0, #0xC02C
	MOVT r0, #0x4000
	LDR r2, [r0]
	ORR r2, r2, #0x60
	STR r2, [r0]

; Enable uart0 control
	MOV r0, #0xC030
	MOVT r0, #0x4000
	MOV r1, #0x301
	LDR r2, [r0]
	ORR r2, r2, r1
	STR r2, [r0]

; Make PA0 and PA1 as Digital Ports
	MOV r0, #0x451C
	MOVT r0, #0x4000
	LDR r2, [r0]
	ORR r2, r2, #0x03
	STR r2, [r0]

; Change PA0,PA1 to Use an Alternate Function
	MOV r0, #0x4420
	MOVT r0, #0x4000
	LDR r2, [r0]
	ORR r2, r2, #0x03
	STR r2, [r0]

; Configure PA0 and PA1 for UART
	MOV r0, #0x452C
	MOVT r0, #0x4000
	LDR r2, [r0]
	ORR r2, r2, #0x11
	STR r2, [r0]

	MOV r0, #0xC038
	MOVT r0, #0x4000
	LDR r2, [r0]
	ORR r2, r2, #0x10
	STR r2, [r0]

; ENABLE UART Interrupts by enabling NVIC (Nested Vector Interrupt Controller) by writing a 1 to bit 5 of EN0
	MOV r0, #0xE100
	MOVT r0, #0xE000
	LDR r2, [r0]
	ORR r2, r2, #0x20
	STR r2, [r0]

	LDMFD sp!, {lr,r0,r1,r2}
	BX lr
;---------------END OF UART INIT-----------------------------------------------------------

read_character:
	STMFD SP!,{lr,r1,r2,r3,r4,r5}	; Store register lr on stack


	MOV r5, #0xC000
	MOVT r5, #0x4000	; Sets r5 to be the UART data register
	MOV r1, #0xC018
	MOVT r1, #0x4000	; Sets r1 to be the UART Status Register
	; Start
	; Test RxFE in Status Register (bit 4)
	; If 0, go back to test
	; If 1, Read Byte from recieve Register
	; Stop

read_character_loopback:
	MOV r2, #0x10	; Bit we want to isolate on r3
	LDRB r3, [r1]	; Getting the status register
	AND r4, r2, r3	; Isolating the 5th bit
	CMP r4, #0
	BNE read_character_loopback	; If 0, branch to top, otherwise, continue
	LDRB r0, [r5]	; Stores the character into r0

	LDMFD sp!, {lr,r1,r2,r3,r4,r5}
	MOV pc,lr
;-------------------------END OF READ CHARACTER----------------------------------------------

output_character:
	; Start
	; Test TxFF in Status Register
	; If 0, go back to test
	; If 1, Store Byte in Transmit Register
	; Stop

	STMFD SP!,{lr,r1,r2,r3,r4,r5}


	MOV r5, #0xC000
	MOVT r5, #0x4000	; Sets r5 to be the UART data register
	MOV r1, #0xC018
	MOVT r1, #0x4000	; Sets r1 to be the UART Status Register

output_character_loopback:
	MOV r2, #0x20	; Need to look at the 5th bit
	LDRB r3, [r1]	; Loads the status register into r3
	AND r4, r2, r3	; ANDS to check the 5th bit
	CMP r4, #0		; If the 5th bit is a 1, go back to output_character_loopback
	BNE output_character_loopback	; If the 5th bit is a 0, continue further into the program

	STRB r0, [r5]	; Stores the character in the UART data register

	LDMFD sp!, {lr,r1,r2,r3,r4,r5}
	MOV pc,lr
;---------------END OF OUTPUT CHARACTER--------------------------------------------------------
character_newline:
	STMFD SP!,{lr,r1,r2,r3,r4,r5,r6}

	MOV r5, #0xC000
	MOVT r5, #0x4000	; Sets r5 to be the UART data register
	MOV r1, #0xC018
	MOVT r1, #0x4000	; Sets r1 to be the UART Status Register
output_character_new:
	MOV r2, #0x20	; Need to look at the 5th bit
	LDRB r3, [r1]	; Loads the status register into r3
	AND r4, r2, r3	; ANDS to check the 5th bit
	CMP r4, #0		; If the 5th bit is a 1, go back to output_character_loopback
	BNE output_character_new	; If the 5th bit is a 0, continue further into the program
	MOV r6, #0xA
	STRB r6, [r5]
output_character_newline:
	MOV r2, #0x20	; Need to look at the 5th bit
	LDRB r3, [r1]	; Loads the status register into r3
	AND r4, r2, r3	; ANDS to check the 5th bit
	CMP r4, #0		; If the 5th bit is a 1, go back to output_character_loopback
	BNE output_character_newline	; If the 5th bit is a 0, continue further into the program
	MOV r6, #0xD
	STRB r6, [r5]

	LDMFD sp!, {lr,r1,r2,r3,r4,r5,r6}
	MOV pc,lr

;---------------END OF CHARACTER NEWLINE----------------------------------------------------
read_string:
	STMFD SP!,{lr,r1,r2,r3,r5,r6,r7}


	MOV r5, #0xC000
	MOVT r5, #0x4000	; Sets r5 to be the UART data register
	MOV r1, #0xC018
	MOVT r1, #0x4000	; Sets r1 to be the UART Status Register
	; Start
	; Test RxFE in Status Register (bit 4)
	; If 0, go back to test
	; If 1, Read Byte from recieve Register
	; Stop

read_string_loopback:
	MOV r2, #0x10	; Bit we want to isolate on r3
	LDRB r3, [r1]	; Getting the status register
	AND r7, r2, r3	; Isolating the 5th bit
	CMP r7, #0
	BNE read_string_loopback	; If 0, branch to top, otherwise, continue
	LDRB r6, [r5]	; Stores the character into r6

	MOV r3, #0xD	; Sets r3 equal to the ascii value of a carriage return
	STRB r6, [r4]	; Store the character into memory
	CMP r3, r6		; Check to see if carriage return

	LDMFD sp!, {lr,r1,r2,r3,r5,r6,r7}
	MOV pc,lr
;---------------------------END OF READ STRING-------------------------------------------------


output_string:
	STMFD SP!,{lr,r0,r1,r2,r3,r5,r6}
	; base address is in r4

	MOV r1, #0xC000
	MOVT r1, #0x4000	; Sets r5 to be the UART data register
	MOV r2, #0xC018
	MOVT r2, #0x4000	; Sets r1 to be the UART Status Register

output_string_loopback:
	MOV r5, #0x20	; Bit we want to isolate on r3
	LDRB r3, [r2]	; Getting the status register
	AND r6, r5, r3	; Isolating the 5th bit
	CMP r6, #0
	BNE output_string_loopback	; If 1, branch to top, otherwise, continue

	LDRB r0, [r4]		; loads the character into r0
	ADD r4, r4, #0x1	; Increment counter of the string
	CMP r0, #0x00		; Check to see if this location is null
	BEQ output_end		; If this character is null, branch to end
	STRB r0, [r1]		; Stores the character to data register
	B output_string_loopback	; always go back to the loop
output_end:
	MOV r5, #0x20	; Bit we want to isolate on r3
	LDRB r3, [r2]	; Getting the status register
	AND r6, r5, r3	; Isolating the 5th bit
	CMP r6, #0
	BNE output_end
	MOV r0, #0xA
	STRB r0, [r1]
out_end:
	MOV r5, #0x20	; Bit we want to isolate on r3
	LDRB r3, [r2]	; Getting the status register
	AND r6, r5, r3	; Isolating the 5th bit
	CMP r6, #0
	BNE out_end
	MOV r0, #0xD
	STRB r0, [r1]
	LDMFD sp!, {lr,r0,r1,r2,r3,r5,r6}
	MOV pc,lr
;---------------------------------END OF OUTPUT STRING------------------------------------------
read_from_push_btns:
	STMFD SP!,{lr,r7,r8,r9,r10,r11,r12}	; Store register lr on stack

	MOV r12, #0x73FC
	MOVT r12, #0x4000	; Sets r12 to PORTD's data register
	MOV r11, #0x7400
	MOVT r11, #0x4000	; Sets r11 to PORTD's direction

	LDR r10, [r11]
	AND r9, r10, #0x0	; Sets pins 0-7 on PORTD to input
	STR r9, [r11]

	MOV r8, #0x751C
	MOVT r8, #0x4000	; Sets r8 to digital register
	LDRB r7, [r8]
	ORR r7, r7, #0xF
	STRB r7, [r8]

	MOV r0, #0
	MOV r0, #0
	MOV r0, #0
	LDR r0, [r12]		; Loads into r0 what button is being pushed



	LDMFD sp!, {lr,r7,r8,r9,r10,r11,r12}
	MOV pc, lr

illuminate_LEDs:
	STMFD SP!,{lr,r7,r8,r9,r10,r11,r12}	; Store register lr on stack
	; pattern passed into r0

	MOV r12, #0x53FC
	MOVT r12, #0x4000	; Sets r12 to PORTB's data register
	MOV r11, #0x5400
	MOVT r11, #0x4000	; Sets r11 to PORTB's direction

	LDR r10, [r11]
	ORR r9, r10, #0xFF	; Sets pins 0-7 on PORTB to output
	STR r9, [r11]

	MOV r8, #0x551C
	MOVT r8, #0x4000	; Sets r8 to digital register
	LDRB r7, [r8]
	ORR r7, r7, #0xF
	STRB r7, [r8]

	STRB r0, [r12]		; Stores the patterns into r12, lighting the LEDS

	LDMFD sp!, {lr,r7,r8,r9,r10,r11,r12}
	MOV pc, lr


illuminate_RGB_LED:
	STMFD SP!,{lr,r7,r8,r9,r10,r11,r12}	; Store register lr on stack
	; should implement red, blue, green, purple, yellow, white
	;					0	 1		2		3		4		5
	; red = #0x2
	; blue = #0x4
	; green = #0x8
	; purple = #0x6
	; yellow = #0xA
	; white = #0xF

	MOV r12, #0x53FC
	MOVT r12, #0x4002	; Sets r12 to PORTF's data register
	MOV r11, #0x5400
	MOVT r11, #0x4002	; Sets r11 to PORTF's direction

	LDR r10, [r11]
	ORR r9, r10, #0xE	; Sets pins 1-3 on PORTF to input
	STR r9, [r11]

	MOV r8, #0x551C
	MOVT r8, #0x4002	; Sets r8 to digital register
	LDRB r7, [r8]
	ORR r7, r7, #0xF
	STRB r7, [r8]

	STRB r0, [r12]

	LDMFD sp!, {lr,r7,r8,r9,r10,r11,r12}
	MOV pc, lr


read_from_keypad:
	STMFD SP!,{lr,r6,r7,r8,r9,r10,r11,r12}

testing123:
	MOV r0, #0x00
	LDRB r0, [r11]		; stores the key that was pressed into r0
	AND r0, r0, #0x3C
	CMP r0, #0
	BEQ testing123


	MOV r6, #0xE
	STRB r6, [r12]		; turns off row 1
	MOV r6, #0x0
	MOV r6, #0x0
	MOV r6, #0x0
	LDRB r1, [r11]		; r1 holds output value of pressed button? (not really though)
	AND r1, r1, #0x3C
	CMP r0,r1			;
	BEQ isitinrow2
;here if it's in row 1
	CMP r0,#0x4
	BEQ print1
	CMP r0,#0x8
	BEQ print2
	CMP r0,#0x10
	BEQ print3
	CMP r0,#0x20
	BEQ printA

isitinrow2:
	MOV r6, #0xC
	STRB r6, [r12]		; turns off row 2
	MOV r6, #0x0
	MOV r6, #0x0
	MOV r6, #0x0
	LDRB r1, [r11]		; r1 holds output value of pressed button? (not really though)
	AND r1, r1, #0x3C
	CMP r0,r1
	BEQ isitinrow3
;here if it's in row 2
	CMP r0,#0x4
	BEQ print4
	CMP r0,#0x8
	BEQ print5
	CMP r0,#0x10
	BEQ print6
	CMP r0,#0x20
	BEQ printB

isitinrow3:
	MOV r6, #0x8
	STRB r6, [r12]		; turns off row 3
	MOV r6, #0x0
	MOV r6, #0x0
	MOV r6, #0x0
	LDRB r1, [r11]		; r1 holds output value of pressed button? (not really though)
	AND r1, r1, #0x3C
	CMP r0,r1
	BEQ inrow4
;here if it's in row 3
	CMP r0,#0x4
	BEQ print7
	CMP r0,#0x8
	BEQ print8
	CMP r0,#0x10
	BEQ print9
	CMP r0,#0x20
	BEQ printC

inrow4:
;here if it's in row 4
	CMP r0,#0x4
	BEQ printstar
	CMP r0,#0x8
	BEQ print0
	CMP r0,#0x10
	BEQ printpound
	CMP r0,#0x20
	BEQ printD

print1:
	MOV r0, #0x31
	B printend
print2:
	MOV r0, #0x32
	B printend
print3:
	MOV r0, #0x33
	B printend
print4:
	MOV r0, #0x34
	B printend
print5:
	MOV r0, #0x35
	B printend
print6:
	MOV r0, #0x36
	B printend
print7:
	MOV r0, #0x37
	B printend
print8:
	MOV r0, #0x38
	B printend
print9:
	MOV r0, #0x39
	B printend
print0:
	MOV r0, #0x30
	B printend
printA:
	MOV r0, #0x41
	B printend
printB:
	MOV r0, #0x42
	B printend
printC:
	MOV r0, #0x43
	B printend
printD:
	MOV r0, #0x44
	B printend
printstar:
	MOV r0, #0x2A
	B printend
printpound:
	MOV r0, #0x23
	B printend

printend:

	LDMFD sp!, {lr,r6,r7,r8,r9,r10,r11,r12}
	MOV pc, lr



compute:

	STMFD SP!,{lr,r1-r12}

	;String is stored at 0x20000000, which is stored in r10
	; + = 0x2B
	; - = 0x2D
	; / = 0x2F
	MOV r10, #0
	MOVT r10, #0x2000
	MOV r12, #10

parse1:
	LDRB r3, [r10], #1	; Load the string into r3, then increment r10
	SUB r3, r3, #0x30	; Subtract 0x30 to convert from ascii to int
	ADD r7, r3, r7		; Add the integer into r7 (running total for the first integer entered in)
	LDRB r3, [r10]		; Loads the next character of the string entered into r3
	BL checksign		; Branch and link to checksign
	MUL r7, r7, r12		; Multiplies the running total by 10 (shifting each digit once to the left, working with base 10)
	B parse1			; Always branch from here back to the top of parse1
parse2:
	LDRB r3, [r10], #1	; Load the string into r3, then increment r10
	SUB r3, r3, #0x30	; Subtract 0x30 to convert from ascii to int
	ADD r8, r3, r8		; Add the integer into r8 (running total for the second integer entered in)
	LDRB r3, [r10]		; Loads the next character of the string entered into r3
	CMP r3, #0x00		; If that next character was a null, branch to final
	BEQ final			; If that naxt character wasn't a null, continue
	MUL r8, r8, r12		; Multiplies the running total by 10 (shifting each digit once to the left, working with base 10)
	B parse2			; Always branch from here back to the top of parse2


checksign:
	CMP r3, #0x2B	; Compares r3 (next character) to the ascii value of +
	BNE checkneg	; If not equal, go to checkneg
	MOV r11,#1 		; If it was equal, set r11 to be equal to 1
	ADD r10, r10, #1	; Add one to r10 (so we will look at the first character after the +)
	B parse2		; Branch to parse2 to start converting the second argument to an integer
checkneg:
	CMP r3, #0x2D	; Compares r3 (next character) to the ascii value of -
	BNE checkdiv	; If not equal, go to checkdiv
	MOV r11,#2 		; If it was equal, set r11 to be equal to 2
	ADD r10, r10, #1	; Add one to r10 (so we will look at the first character after the -)
	B parse2		; Branch to parse2 to start converting the second argument to an integer
checkdiv:
	CMP r3, #0x2F	; Compares r3 (next character) to the ascii value of /
	BNE notsign		; If not equal, go to notsign
	MOV r11,#3 		; If it was equal, set r11 to be equal to 3
	ADD r10, r10, #1	; Add one to r10 (so we will look at the first character after the /)
	B parse2		; Branch to parse2 to start converting the second argument to an integer
notsign:
	MOV pc, lr		; We did not hit a sign character, so we want to go back to the link

final:
	CMP r11, #1		; If r11 is equal to 1, go to plus
	BEQ plus
	CMP r11, #2		; If r11 is equal to 2, go to subtract
	BEQ subtract
	CMP r11, #3		; If r11 is equal to 3, go to divide
	BEQ divide

plus:
	ADD r9, r7, r8	; Add the running total for each argument, store the answer into r9
	B fullsend		; Branch to fullsend
subtract:
	SUB r9, r7, r8	; Subtracts r8 from r7, and stores the answer into r9
	CMP r9, #0		; Check to see if the answer is negative
	BGE fullsend	; If positive, go to fullsend
	RSB r9, r9, #0	; Set r9 to a positive number
	MOV r5, #1		; Set r5 to one, so we can later check to see if the answer is negative
	B fullsend		; Branch to fullsend
divide:

	MOV r3, r7		; Moves the dividend into r3
	MOV r4, r8		; Moves the divisor into r4
	MOV r6, #0x0000
	MOVT r6, #0x0000
	MOV r7, #0x0000
	MOVT r7, #0x0000
	MOV r8, #0x0000
	MOVT r8, #0x0000
	MOV r9, #0x0000
	MOVT r9, #0x0000
	MOV r0, #0x0000
	MOVT r0, #0x0000
	MOV r1, #0x0000
	MOVT r1, #0x0000
	MOV r2, #0x0000
	MOVT r2, #0x0000
	MOV r10, #0x0000
	MOVT r10, #0x0000
	MOV r11, #0x0000
	MOVT r11, #0x0000
	MOV r12, #0x0000
	MOVT r12, #0x0000	; Clears registers for use in divide

check:				; Check is where I will check if the divisor or dividen are negative
	CMP r4, #0		; Check to see if r4 (divisor) is negative
	BLT divisor		; If the divisor is negative, branch
	B checkagain	; If here, the divisor is positive, so branch to checkagain
divisor:
	MOV r6, #1		; If r6 is one, that means the divisor is negative
	RSB r4, r4, #0	; Sets the divisor to a positive number

checkagain:
	CMP r3, #0		; Check to see if r3 (dividend) is negative
	BLT dividend	; If the dividend is negative, branch
	B initialize	; If here, the divident is positive, so branch to initialize
dividend:
	MOV r7, #1		; If r7 is 1, that means the dividend is negative
	RSB r3, r3, #0	; Sets the dividend to a positive number

initialize:
	MOV r2, #15		; Sets the counter to 15
	MOV r0, r3		; Sets the remainder to the dividend
	MOV r1, #0x0000	; Sets the quotient to 0
	MOVT r1, #0x0000
	LSL r4, #15		; Logical Left Shfit the divisor by 15
	ADD r2, r2, #1	; Increase the counter by 1 to help the loop work better

loop:
	SUB r2, r2, #1	; Decrement the counter
	SUB r0, r0, r4	; Remainder = Remainder - Divisior
	CMP r0, #0		; Check to see if the remainder is negative
	BLT neg			; If the remainder is negative, Branch to neg
	LSL r1, #1		; Logical Left Shift the quotient once
	ADD r1, r1, #1	; Increase the quotient by 1

mid:				; This is where the previous branch comes back to
	LSR r4, #1		; Right shift the divisor by 1
	CMP r2, #0		; Checks to see if the counter is greater than 0
	BGT loop		; If the counter is greater than 0, go back to the top of the loop
	B done			; Branch to the end

neg:				; This is where to go if the remainder is less than 0
	add r0, r0, r4	; Remainder = Remainder + Divisor
	LSL r1, #1		; Logical Left Shift the quotient once
	B mid			; branch back up into the loop

done:
	CMP r6, r7		; Check to see if r6=r7
	BEQ sendtwo		; if r6=r7, branch to sendtwo
	RSB r1, r1, #0	; converts the quotient to a negative number

sendtwo:
	; Here we will convert the quotient and remainder to strings, then print them
	MOV r9, r0		; Sets r9 equal to the remainder
	MOV r12, r1		; Sets r12 equal to the quotient
	MOV r1, #0x0000
	MOVT r1, #0x0000
	MOV r2, #0x0000
	MOVT r2, #0x0000
	MOV r3, #0x0000
	MOVT r3, #0x0000	; Clears these registers for use
hund1:
	CMP r12, #100	; Compares r12 (quotient) to 100
	BLT ten1		; If less than, branch to ten1
	ADD r1, r1, #1	; Adds 1 to r1 (running total for hundreds place)
	SUB r12, r12, #100	; Subtract 100 from r12
	B hund1		; Go back to the top of hund1

ten1:
	CMP r12, #10	; Compares r12 to 10
	BLT one1		; If less than, branch to one1
	ADD r2, r2, #1	; Adds 1 to r2 (running total for tens place)
	SUB r12, r12, #10	; Subtract 10 from r12
	B ten1			; Go back to the top of ten1

one1:
	CMP r12, #1		; Compares r12 to 1
	BLT printtwo		; If less than, branch to print2
	ADD r3, r3, #1	; Adds 1 to r3 (running total for ones place)
	SUB r12, r12, #1	; Subtract 1 from r12
	B one1			; Go back to the top of one1

printtwo:
	MOV r12, #0xC000
	MOVT r12, #0x4000	; Sets r12 equal to the UART data register

	MOV r11, #0x3D		; Sets r11 equal to 0x3D (= sign)
	STRB r11, [r12]		; Printing an = character for return display
	MOV r11, #0x52		; Moves 0x52 into r11 (ascii value of R)
	ADD r1, r1, #0x30	; Adds 0x30 to the hundreds place (conerting it to ascii)
	ADD r2, r2, #0x30	; Adds 0x30 to the tens place (conerting it to ascii)
	ADD r3, r3, #0x30	; Adds 0x30 to the ones place (conerting it to ascii)

	CMP r1, #0x30		; Compares the hundreds place to the ascii value of 0
	BEQ skip1			; If equal, go to skip1
	B skiponce			; If not, go to skiponce

printloop:
	MOV r6, #0x20		; Sets r6 to have a 1 in the 5th bit
	MOV r7, #0xC018		; Sets r7 equal to the UART status register
	MOVT r7, #0x4000
	LDRH r4, [r7]		; Loads the status register into r4
	AND r5, r6, r4		; ANDS the status register with r6
	CMP r5, #0			; If the 5th bit was a 0, continue further
	BNE printloop		; If the 5th bit was a 1, go back to the top of printloop
	MOV pc, lr			; Goes back to where we were

skiponce:
	BL printloop		; Go to printloop to check if we can print
	STRB r1, [r12]		; Print the hundreds place
	BL printloop		; Go to printloop to check if we can print
	STRB r2, [r12]		; Print the tens place
	BL printloop		; Go to printloop to check if we can print
	STRB r3, [r12]		; Print the ones place
	BL printloop		; Go to printloop to check if we can print
	STRB r11, [r12]		; Print an R (stands for Remainder)
	B fullsend			; Branch to fullsend
skip1:
	CMP r2, #0x30		; Compares the hundreds place to the ascii value of 0
	BEQ skip2			; If equal, branch to skip2
	BL printloop		; Go to printloop to check if we can print
	STRB r2, [r12]		; Print the tens digit
	BL printloop		; Go to printloop to check if we can print
	STRB r3, [r12]		; Print the ones digit
	BL printloop		; Go to printloop to check if we can print
	STRB r11, [r12]		; Print an R (stands for Remainder)
	B fullsend			; Branch to fullsend
skip2:
	BL printloop		; Go to printloop to check if we can print
	STRB r3, [r12]		; Print the ones digit
	BL printloop		; Go to printloop to check if we can print
	STRB r11, [r12]		; Print an R (stands for Remainder)
	B fullsend			; Branch to fullsend

fullsend:
	; Here we will convert the answer from add or sub to a string, then print it
	MOV r1, #0x0000
	MOVT r1, #0x0000
	MOV r2, #0x0000
	MOVT r2, #0x0000
	MOV r3, #0x0000
	MOVT r3, #0x0000
	MOV r4, #0x0000
	MOVT r4, #0x0000	; Clears these registers for future use

thousand:
	CMP r9, #1000		; Compares r9 to 1000
	BLT hundred			; If less than, branch to hundred
	ADD r4, r4, #1		; Add 1 to r4 (running total for thousands place)
	SUB r9, r9, #1000	; Subtract 1000 from r9
	B thousand			; Branch to thousand

hundred:
	CMP r9, #100		; Compares r9 to 100
	BLT tens			; If less than, branch to tens
	ADD r1, r1, #1		; Add 1 to r1 (running total for hundreds place)
	SUB r9, r9, #100	; Subract 100 from r9
	B hundred			; Branch to hundred

tens:
	CMP r9, #10			; Compares r9 to 10
	BLT ones			; If less than, branch to ones
	ADD r2, r2, #1		; Add 1 to r2 (running total for tens place)
	SUB r9, r9, #10		; Subtract 10 from r9
	B tens				; Branch to tens

ones:
	CMP r9, #1			; Compares r9 to 1
	BLT printone		; If less than, branch to print1
	ADD r3, r3, #1		; Add 1 to r3 (running total for ones place)
	SUB r9, r9, #1		; Subtract 1 from r9
	B ones				; Branch to ones

printone:
	MOV r12, #0xC000
	MOVT r12, #0x4000	; Sets r12 to the UART Data Register
	CMP r11, #0x52	; If this is equal, then we did the above print
	BEQ printt
	MOV r11, #0x3D	;printing an = character for return display
	STMFD SP!,{r4,r5,r6}
	BL printloop		; Go to printloop to check if we can print
	LDMFD sp!, {r4,r5,r6}
	STRB r11, [r12]		; Store the = sign to the Data register, printing it
	CMP r5, #0			; Checks to see if we got a negative answer
	BEQ printt		; If not equal, skip to printt
	MOV r6, #0x2D		; Sets r6 equal to the ascii value of -
	STMFD SP!,{r4,r5,r6}
	BL printloop		; Go to printloop to check if we can print
	LDMFD sp!, {r4,r5,r6}
	STRB r6, [r12]		; Prints the - sign

printt:
	MOV r12, #0xC000
	MOVT r12, #0x4000	; Sets r12 to the UART Data Register
	ADD r4, r4, #0x30	; Adds 0x30 to the thousands place (converting from int to ascii)
	ADD r1, r1, #0x30	; Adds 0x30 to the hundreds place (converting from int to ascii)
	ADD r2, r2, #0x30	; Adds 0x30 to the tens place (converting from int to ascii)
	ADD r3, r3, #0x30	; Adds 0x30 to the ones place (converting from int to ascii)
	CMP r4, #0x30		; Compare the thousands place to 0
	BEQ skip11			; If equal, skip to skip11
	STMFD SP!,{r4}
	BL printloop		; Go to printloop to check if we can print
	LDMFD sp!, {r4}
	STRB r4, [r12]		; Prints the thousands place
	BL printloop		; Go to printloop to check if we can print
	STRB r1, [r12]		; Prints the hundreds place
	BL printloop		; Go to printloop to check if we can print
	STRB r2, [r12]		; Prints the tens place
	BL printloop		; Go to printloop to check if we can print
	STRB r3, [r12]		; Prints the ones place
	B end				; Branch to end
skip11:
	CMP r1, #0x30		; Compares the hundreds place to 0
	BEQ skip21			; If equal, branch to skip21
	BL printloop		; Go to printloop to check if we can print
	STRB r1, [r12]		; Print the hundreds place
	BL printloop		; Go to printloop to check if we can print
	STRB r2, [r12]		; Print the tens place
	BL printloop		; Go to printloop to check if we can print
	STRB r3, [r12]		; Print the ones place
	B end				; Branch to end
skip21:
	CMP r2, #0x30		; Compares the tens place to 0
	BEQ skip31			; If equal, branch to skip31
	BL printloop		; Go to printloop to check if we can print
	STRB r2, [r12]		; Print the tens place
	BL printloop		; Go to printloop to check if we can print
	STRB r3, [r12]		; Print the ones place
	B end
skip31:
	BL printloop		; Go to printloop to check if we can print
	STRB r3, [r12]		; Print the ones place

end:
	MOV r3, #0xA		; Sends to the data register a new line
	BL printloop		; Go to printloop to check if we can print
	STRB r3, [r12]		; Print the ones place
	MOV r3, #0xD		; Sends to the data register a carriage return
	BL printloop		; Go to printloop to check if we can print
	STRB r3, [r12]		; Print the ones place

	LDMFD SP!,{lr,r1-r12}

	.end
