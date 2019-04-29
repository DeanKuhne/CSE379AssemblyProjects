	.data
board:	.string 0xC, "|---------------------------------------------|", 0xA, 0xD, "|*********************************************|", 0xA, 0xD, "|*****     *****     *****     *****     *****|", 0xA, 0xD, "|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|", 0xA, 0xD, "|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|", 0xA, 0xD, "|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|", 0xA, 0xD, "|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|", 0xA, 0xD, "|.............................................|", 0xA, 0xD, "|                                             |", 0xA, 0xD, "|                                             |", 0xA, 0xD, "|                                             |", 0xA, 0xD, "|                                             |", 0xA, 0xD, "|                                             |", 0xA, 0xD, "|                                             |", 0xA, 0xD, "|&............................................|", 0xA, 0xD, "|---------------------------------------------|", 0

	.text
	.global lab7
	.global Timer0Handler
	.global Uart0Handler
	.global PortAHandler
	.global uart_init
	.global gpio_init
	.global timer_init
	.global read_character
	.global output_character
	.global output_string
	.global character_newline
	.global inttoascii
	.global illuminate_LEDs
	.global illuminate_RGB_LED
	.global uart_disable
ptr: .word board

endprompt: .string "Game Over", 0
scoreprompt: .string "Your score: ", 0
replayprompt: .string "Press q to quit, or press anything else to play again.", 0
startprompt: .string "Press space to start the game, then W, A, S, or D to move.  To pause/resume, press any button on the keypad.", 0

Timer0Handler:
	STMFD sp!,{lr}

;------------setting r11 to the location of the next astrics spot-------------
	STRB v2, [r11]

	CMP v5, #0x77	; w
	BNE checks
	SUB r11, r11, #49
	B homecheck
checks:
	CMP v5, #0x73	; s
	BNE checka
	ADD r11, r11, #49
	B homecheck
checka:
	CMP v5, #0x61	; a
	BNE checkd
	SUB r11, r11, #1
	B homecheck
checkd:
	CMP v5, #0x64
	BNE endtimer
	ADD r11, r11, #1

;-------------end of setting r11 to new location--------------------

;----------------start of home check------------------------------
homecheck:
	LDRB v2, [r11]	; load current value of new location into v2


	CMP v2, #0x7E	; compare to ~
	BEQ deadfrog

	MOV a3, #0x0090
	MOVT a3, #0x2000
	CMP r11, a3
	BGT gotvalue

	CMP v2, #0x2A
	BNE home1
	ADD r11, r11, #49
	MOV v2, #0x4C
	MOV v1, #0x26
	STRB v1, [r11]	; store & to new location
	B boardout

home1:
	SUB a3, a3, #0xA
	CMP r11, a3
	BLT nothome1
	AND a2, v6, #1
	CMP a2, #0
	BNE notforrent
	ADD v6, v6, #1
	B daddyimhome
nothome1:
	SUB a3, a3, #0xA
	CMP r11, a3
	BLT nothome2
	AND a2, v6, #2
	CMP a2, #0
	BNE notforrent
	ADD v6, v6, #2
	B daddyimhome
nothome2:
	SUB a3, a3, #0xA
	CMP r11, a3
	BLT nothome3
	AND a2, v6, #4
	CMP a2, #0
	BNE notforrent
	ADD v6, v6, #4
	B daddyimhome
nothome3:
	AND a2, v6, #8
	CMP a2, #0
	BNE notforrent
	ADD v6, v6, #8
daddyimhome:
	MOV a1, #0x48
	STRB a1, [r11]
	B newfrog

notforrent:
	ADD r11, r11, #49
	MOV a3, #0x26
	STRB a3, [r11]
	MOV v2, #0x20
	B boardout

newfrog:
	MOV v2, #0x2E

	MOV r11, #0x02B0
	MOVT r11, #0x2000

	;need to find a random spot along the bottom to place the asterisk
	;for now, it will just go to the bottom corner
	MOV a3, #0x26
	STRB a3, [r11]

;	LDR r4, ptr
;	BL output_string	; print the board to putty



	B boardout

;-----------------end of home check-------------------------------


gotvalue:
	LDRB v2, [r11]	; load current value of new location into v2
	CMP v2, #0x7C
	BEQ deadfrog
	CMP v2, #0x2D
	BNE notminus
	SUB r11, r11, #49
	MOV v2, #0x2E
notminus:
	MOV v1, #0x26
	STRB v1, [r11]	; store & to new location
boardout:
	LDR r4, ptr
	BL output_string	; print the board to putty
	B endtimer
;---------------------------------dead frog---------------------------
deadfrog:
	;need to decrease life counter, as well as place a new frog somewhere in the starting row
	MOV r12, #0x53FC
	MOVT r12, #0x4000	; Sets r12 to PORTB's data register
	LDR a3, [r12]
	CMP a3, #0xF
	BNE not4
	MOV a3, #0x7
	STR a3, [r12]
	B respawn
not4:
	CMP a3, #0x7
	BNE not3
	MOV a3, #0x3
	STR a3, [r12]
	B respawn
not3:
	CMP a3, #0x3
	BNE not2
	MOV a3, #0x1
	STR a3, [r12]
	B respawn
not2:
	CMP a3, #0x1
	BNE endtimer
	MOV a3, #0x0
	STR a3, [r12]
	B gameover
respawn:
	STRB v2, [r11]

	MOV v2, #0x2E

	MOV r11, #0x02B0
	MOVT r11, #0x2000

	;need to find a random spot along the bottom to place the asterisk
	;for now, it will just go to the bottom corner
	MOV a3, #0x26
	STRB a3, [r11]

	LDR r4, ptr
	BL output_string	; print the board to putty
;-------------------------end dead frog------------------------------
endtimer:
	MOV v5, #0x00
	MOV r0, #0x0024		; go to TIMER0 Interrupt Clear GPTMICR at 0x40030000 offset 0x24, and clear bit 0 by writting a 1 to it
	MOVT r0, #0x4003
	LDR r2, [r0]
	ORR r2, r2, #0x1
	STR r2, [r0]

	LDMFD sp!, {lr}
	BX lr

Uart0Handler:
	STMFD sp!,{lr}
	; store whatever is at the new location, then print that value on next move
	BL read_character
	MOV v5, r0

enduart:
;-----------clear psr----------
;	MOV r8, #0xFFFF
;	MOVT r8, #0x0FFF
;	LDR r11, [r12]
;	AND r11, r11, r8
;	MSR APSR_nzcvq, r11
;---------end clear psr---------
;	MOV r0, #0xC044		; go to UART Interrupt Clear UARTICR at 0x4000C000 offset 0x44, and clear bit 4 (RXIC) by writing a 1 to it.
;	MOVT r0, #0x4000
;	LDR r2, [r0]
;	ORR r2, r2, #0x10
;	STR r2, [r0]

	LDMFD sp!, {lr}
	BX lr

PortAHandler:
	STMFD sp!,{lr, r0-r12}
	MOV r10, #0x7FF0
	MOVT r10, #0x2000
	LDRB r9, [r10]
	CMP r9, #0xF
	BLT increasehistory

	; rgb is white when game hasnt been started
	; rgb is green when game has been started
	; rgb is red when game has been paused
	; rgb is blue when the game is over
	; data register is #0x3FC
	; Port F is #0x40025000
	MOV r12, #0x53FC
	MOVT r12, #0x4002
	LDRB r2, [r12]
	CMP r2, #0x2
	BEQ resume
	MOV r0, #0x2
	BL illuminate_RGB_LED
	;print a legend here
	BL uart_disable

	MOV r9, #0
	STRB r9, [r10]

	B leaveport
resume:
	MOV r0, #0x8
	BL illuminate_RGB_LED
	MOV r9, #0
	STRB r9, [r10]
	BL uart_init
	B leaveport

increasehistory:
	LSL r9, r9, #1
	ADD r9, r9, #1
	STRB r9, [r10]

leaveport:
;-----------clear psr----------
	MOV r8, #0xFFFF
	MOVT r8, #0x0FFF
	LDR r11, [r12]
	AND r11, r11, r8
	MSR APSR_nzcvq, r11
;---------end clear psr---------
	MOV r0, #0x441C		; go to GPIO Interrupt Clear GPIOICR at 0x40004000 offset 0x41C, and clear bit 4 (RXIC) by writing a 1 to it.
	MOVT r0, #0x4000
	LDR r2, [r0]
	ORR r2, r2, #0xFF	; 1
	STR r2, [r0]


	LDMFD sp!, {lr, r0-r12}
	BX lr

lab7:
	STMFD sp!,{lr}

	BL uart_init

	BL gpio_init

gamestart:
	LDR r4, ptr
	BL output_string	; print the board to putty

	ADR r4, startprompt
	BL output_string

	MOV r0, #0xF
	BL illuminate_LEDs

	MOV v6, #0x0

	MOV r0, #0xF
	BL illuminate_RGB_LED

	MOV r11, #0x02B0
	MOVT r11, #0x2000

	MOV r0, #0x00
waittostart:
	BL read_character
	CMP r0, #0x20
	BNE waittostart

	MOV r0, #0x8
	BL timer_init
	BL illuminate_RGB_LED
	MOV v2, #0x2E

busy:
	B busy			; right most home is 0x2000008B, left most is 0x20000069

gameover:
	MOV r0, #0x4
	BL illuminate_RGB_LED

	ADR r4, endprompt
	BL output_string	; prints Game Over

	ADR r4, scoreprompt
	BL output_string	; prints Your score:

	;need to print the score here

	ADR r4, replayprompt
	BL output_string	; prints prompt for playing again
	MOV r0, #0

exitgame:
	CMP r0, #0
	BEQ exitgame	; no user input yet
	CMP r0, #0x71
	BNE gamestart	; user wishes to play again

	LDMFD sp!, {lr}
	LDMFD sp!, {lr}
	BX lr

	.end
