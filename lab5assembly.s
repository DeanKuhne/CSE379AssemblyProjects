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

prompt: .string "Enter an Expression (two 0-999 operands accepted, only +,-,/ accepted for operators. For division answers, it's shown as Quotient R Remainder). For keypad usage, D=Enter, C=division,B=subtraction,A=addition: ", 0


PortAHandler:
	STMFD sp!, {lr}

	BL read_from_keypad
	BL output_character
	STRB r0, [r12], #2	; Store to Memory

	LDMFD sp!, {lr}
	BX lr

Uart0Handler:
	STMFD sp!, {lr}

	BL read_character
	BL output_character
	STRB r0, [r12], #2	; Store to Memory

	LDMFD sp!, {lr}
	BX lr


lab5:
	STMFD SP!,{lr}	; Store register lr on stack

	BL uart_init
	BL gpio_init

	MOV r12, #0
	MOVT r12, #0x2000	; Location for where the string gets stored in memory

	MOV r0, #0xC044		; go to UART Interrupt Clear UARTICR at 0x4000C000 offset 0x44, and clear bit 4 (RXIC) by writing a 1 to it.
	MOVT r0, #0x4000
	LDR r2, [r0]
	ORR r2, r2, #0x10
	STR r2, [r0]

	MOV r0, #0x441C		; go to GPIO Interrupt Clear GPIOICR at 0x40004000 offset 0x41C, and clear bit 0 by writting a 1 to it
	MOVT r0, #0x4000
	LDR r2, [r0]
	ORR r2, r2, #0x1
	STR r2, [r0]

	ADR r4, prompt
	BL output_string
busy:
	MOV r1, #0
	B busy

	LDMFD sp!, {lr}
	.end
