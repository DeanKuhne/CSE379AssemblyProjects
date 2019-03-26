.text
	.global lab5
	.global PortAHandler
	.global Uart0Handler
	.global uart_init
	.global gpio_init
	.global output_character
	.global read_character
	.global read_string
	.global output_string
	.global read_from_keypad
	.global character_newline
	.global compute
	.global solve



; things to fix:
; debounce the buttons on the keypad



prompt: .string "Enter an Expression (two 0-999 operands accepted, only +,-,/ accepted for operators. For division answers, it's shown as Quotient R Remainder). For keypad usage: A=Addition, B=Subtraction, C=Division, and D=Enter.  Press q to quit.", 0
		.align 4
exitprompt:	.string "Goodbye",0
			.align 4

PortAHandler:
	STMFD sp!, {lr,r0-r12}

	MOV r11, #0x43FC
	MOVT r11, #0x4000	; Sets r11 to PORTA's data register

	BL read_from_keypad
	CMP r0, #0x00
	BEQ donewithport
wait:
	BL checkG
	BL output_character
	LDR r11, [r12]	; loads the string location into r11
	STRB r0, [r11]	; Store to Memory
	ADD r11, r11, #1	; increments r11
	STR r11, [r12]	; stores the new string location back into memory

donewithport:
	MOV r0, #0x441C		; go to GPIO Interrupt Clear GPIOICR at 0x40004000 offset 0x41C, and clear bit 0 by writting a 1 to it
	MOVT r0, #0x4000
	LDR r2, [r0]
	ORR r2, r2, #0xFF
	STR r2, [r0]

	MOV r10, #0xFFFF
	MOVT r10, #0x0FFF
	LDR r11, [r12]
	AND r11, r11, r10
	MSR APSR_nzcvq, r11

	LDMFD sp!, {lr,r0-r12}
	BX lr

Uart0Handler:
	STMFD sp!, {lr,r0-r12}

	BL read_character
	CMP r0, #0xD
	BEQ solve
	CMP r0, #0x71
	BEQ skipq
	BL output_character
notq:
	LDR r11, [r12]	; loads the string location into r11
	STRB r0, [r11]	; Store to Memory
	ADD r11, r11, #1	; increments r11
	STR r11, [r12]	; stores the new string location back into memory
	B clear
skipq:
	MOV r9, #0xBAD
	MOV r10, #0x7FF0
	MOVT r10, #0x2000
	STR r9, [r10]
clear:

	MOV r10, #0xFFFF
	MOVT r10, #0x0FFF
	LDR r11, [r12]
	AND r11, r11, r10
	MSR APSR_nzcvq, r11

	LDMFD sp!, {lr,r0-r12}
	BX lr


lab5:
	STMFD SP!,{lr,r0-r12}	; Store register lr on stack



	BL uart_init
	BL gpio_init


	MOV r0, #0xC044		; go to UART Interrupt Clear UARTICR at 0x4000C000 offset 0x44, and clear bit 4 (RXIC) by writing a 1 to it.
	MOVT r0, #0x4000
	LDR r2, [r0]
	ORR r2, r2, #0x10
	STR r2, [r0]

	MOV r0, #0x441C		; go to GPIO Interrupt Clear GPIOICR at 0x40004000 offset 0x41C, and clear bit 0 by writting a 1 to it
	MOVT r0, #0x4000
	LDR r2, [r0]
	ORR r2, r2, #0xFF
	STR r2, [r0]

	MOV r7, #0xFEC

setup:


	MOV r12, #0x7000
	MOVT r12, #0x2000	; location where the location where the string will get stored is stored
	MOV r11, #0x0000
	MOVT r11, #0x2000	; Location where the string will get stored
	STR r11, [r12]		; stores 0x20000000 in memory

	MOV r10, #0x0000
	STR r10, [r11]

	MOV r10, #0x7FF0
	MOVT r10, #0x2000	; location for flags
	MOV r9, #0x0000
	STR r9, [r10]
	MOV r9, #0xBAD


mainprompt:
	ADR r4, prompt
	BL output_string


busy:
	LDR r8, [r10]	; checking to see if q was hit
	CMP r8, r9
	BEQ end

	LDR r8, [r10]	; checking to see if we computed
	CMP r8, r7
	BEQ setup

	MOV r5, #0

	B busy


checkG:
	STMFD sp!, {lr}
	CMP r0, #0x41
	BNE notplus
	MOV r0, #0x2B
	B notsign
notplus:
	CMP r0, #0x42
	BNE notsub
	MOV r0, #0x2D
	B notsign
notsub:
	CMP r0, #0x43
	BNE notdiv
	MOV r0, #0x2F
	B notsign
notdiv:
	CMP r0, #0x44
	BNE notsign
	B solve
notsign:
	LDMFD sp!, {lr}
	BX lr

solve:

	MOV r0, #0
	LDR r11, [r12]	; loads the string location into r11
	STRB r0, [r11]	; Store to Memory
	BL compute

	MOV r9, #0xFEC
	MOV r10, #0x7FF0
	MOVT r10, #0x2000
	STR r9, [r10]

	MOV r0, #0
	MOV r1, #0
	MOV r2, #0
	MOV r3, #0
	MOV r4, #0
	MOV r5, #0
	MOV r6, #0
	MOV r8, #0
	MOV r9, #0
	MOV r11, #0
	MOV r12, #0

	LDMFD sp!, {lr}
	BX lr

end:
	ADR r4, exitprompt
	BL output_string
	LDMFD sp!, {lr,r0-r12}
	BX lr
	.end
