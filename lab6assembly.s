	.data
board:	.string 0xC, " ---------------------------------------- ", 0xA, 0xD, "|                                        |", 0xA, 0xD, "|                                        |", 0xA, 0xD, "|                                        |", 0xA, 0xD, "|                                        |", 0xA, 0xD, "|                                        |", 0xA, 0xD, "|                                        |", 0xA, 0xD, "|                                        |", 0xA, 0xD, "|                   *                    |", 0xA, 0xD, "|                                        |", 0xA, 0xD, "|                                        |", 0xA, 0xD, "|                                        |", 0xA, 0xD, "|                                        |", 0xA, 0xD, "|                                        |", 0xA, 0xD, "|                                        |", 0xA, 0xD, "|                                        |", 0xA, 0xD, "|                                        |", 0xA, 0xD, " ---------------------------------------- ", 0

	.text
	.global lab6
	.global Timer0Handler
	.global Uart0Handler
	.global uart_init
	.global timer_init
	.global read_character
	.global output_character
	.global output_string
	.global character_newline
	.global inttoascii
ptr: .word board

prompt: .string "Your score: ", 0
startprompt: .string "Press W,A,S,or D to start game", 0

Timer0Handler:
	STMFD sp!, {lr}

;------------setting r11 to the location of the next astrics spot-------------
	CMP r10, #0x77	; w
	BNE checks
	SUB r11, r11, #44
	B gotvalue
checks:
	CMP r10, #0x73	; s
	BNE checka
	ADD r11, r11, #44
	B gotvalue
checka:
	CMP r10, #0x61	; a
	BNE checkd
	SUB r11, r11, #1
	B gotvalue
checkd:
;	CMP r10, #0x64	; d
	ADD r11, r11, #1


;-------------end of setting r11 to new location--------------------

;------------check if new location is space--------------------
gotvalue:
	LDRB r0, [r11]	; load ascii value at new location into r0
	CMP r0, #0x20	; check if r0 is a space
	BEQ safe		; if yes, skip setting the flag
	MOV r2, #0xBAD	; r2 will hold flag for gameover
	MOV r3, #0x7FF0
	MOVT r3, #0x2000
	STR r2, [r3]	; set flag in memory
	B timeout
;---------------end of check of location is a space---------------

;--------------store ascii-------------------------
	; if we are here, then we are not at a space, and are safe to print
safe:
	MOV r1, #0x2A	; Ascii value of *
	STRB r1, [r11]	; store asterisk at current location
	LDR r4, ptr
	BL output_string	; print updated board
	ADD r9, r9, #1	; r9 holds out counter for the score
timeout:
;-----------clear psr----------
	MOV r8, #0xFFFF
	MOVT r8, #0x0FFF
	LDR r7, [r12]
	AND r7, r7, r8
	MSR APSR_nzcvq, r7
;---------end clear psr---------
	MOV r0, #0x0024		; go to TIMER0 Interrupt Clear GPTMICR at 0x40030000 offset 0x24, and clear bit 0 by writting a 1 to it
	MOVT r0, #0x4003
	LDR r2, [r0]
	ORR r2, r2, #0x1
	STR r2, [r0]


	LDMFD sp!, {lr}
	BX lr

Uart0Handler:
	STMFD sp!, {lr,r11}

	BL read_character
	CMP r0, #0x77	; check if input was a w
	BNE iss
	MOV r10, r0
	B leaveuart
iss:
	CMP r0, #0x73	; check if input was an s
	BNE isa
	MOV r10, r0
	B leaveuart
isa:
	CMP r0, #0x61	; check if input is an a
	BNE isd
	MOV r10, r0
	B leaveuart
isd:
	CMP r0, #0x64	; check if input is a d
	BNE leaveuart
	MOV r10, r0


leaveuart:
;-----------clear psr----------
	MOV r8, #0xFFFF
	MOVT r8, #0x0FFF
	LDR r11, [r12]
	AND r11, r11, r8
	MSR APSR_nzcvq, r11
;---------end clear psr---------
	MOV r0, #0xC044		; go to UART Interrupt Clear UARTICR at 0x4000C000 offset 0x44, and clear bit 4 (RXIC) by writing a 1 to it.
	MOVT r0, #0x4000
	LDR r2, [r0]
	ORR r2, r2, #0x10
	STR r2, [r0]

	LDMFD sp!, {lr,r11}
	BX lr


lab6:
	STMFD sp!, {lr}

	BL uart_init


	MOV r11, #0x0175
	MOVT r11, #0x2000	; location of the starting astrics
	MOV r9, #1			; counter for score

	LDR r4, ptr
	BL output_string	; print the board to putty

	ADR r4, startprompt
	BL output_string

	MOV r10, #0			; initialize r10 to 0
startloop:
	CMP r10, #0
	BEQ startloop

	MOV r2, #0x0000	; r2 will hold flag for gameover
	MOV r3, #0x7FF0
	MOVT r3, #0x2000
	STR r2, [r3]

	BL timer_init

busy:
	MOV r2, #0xBAD
	MOV r3, #0x7FF0
	MOVT r3, #0x2000
	LDR r1, [r3]
	CMP r1, r2
	BEQ gameover
	B busy

gameover:
	ADR r4, prompt
	BL output_string
	BL inttoascii
	BL character_newline

	LDMFD sp!, {lr}
	BX lr
	.end
