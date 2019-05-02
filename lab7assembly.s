	.data
board:	.string 0xC, "|---------------------------------------------|", 0xA, 0xD, "|*********************************************|", 0xA, 0xD, "|*****     *****     *****     *****     *****|", 0xA, 0xD, "|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|", 0xA, 0xD, "|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|", 0xA, 0xD, "|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|", 0xA, 0xD, "|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~|", 0xA, 0xD, "|.............................................|", 0xA, 0xD, "|        C                  C                 |", 0xA, 0xD, "|                                             |", 0xA, 0xD, "| C C                                         |", 0xA, 0xD, "|                                             |", 0xA, 0xD, "|               C                    C        |", 0xA, 0xD, "|     ####                ####                |", 0xA, 0xD, "|&............................................|", 0xA, 0xD, "|---------------------------------------------|", 0
legend:	.string "| |: Vertical Wall      | +10 for moving forward one space   |", 0xA, 0xD, "| -: Horizontal Wall    | -10 for moving back one space      |", 0xA, 0xD, "| a: Alligator's Back   | +50 for getting a frog home safely |", 0xA, 0xD, "| A: Alligator's Mouth  | +100 for eating a fly              |", 0xA, 0xD, "| L: Log                | +250 for completing the level      |", 0xA, 0xD, "| O: Lily Pad           | +10 for each second of unused time |", 0xA, 0xD, "| &: Frog               |	 when getting a frog home    |", 0xA, 0xD, "| T: Turtle             |", 0xA, 0xD, "| C: Car                |", 0xA, 0xD, "| #: Truck              |", 0xA, 0xD, "| +: Fly                |", 0xA, 0xD, "| H: Occupied Home      |", 0xA, 0xD, "| ~: Water              |", 0


	.text
	.global lab7
	.global Timer0Handler
	.global Timer1Handler
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
	.global character_newline
ptr: .word board
ptrl: .word legend

endprompt: .string "Game Over", 0
scoreprompt: .string "Your score: ", 0
replayprompt: .string "Press q to quit, or press anything else to play again.", 0
startprompt: .string "Press space to start the game, then W, A, S, or D to move.  To pause/resume, press any button on the keypad.", 0
explainprompt: .string "Traverse through the board, without hitting any cars, trucks, or water, and get your frog home.", 0

Timer0Handler: ; This is the timer for the board/frog from movement
	STMFD sp!,{lr}
;------------setting r11 to the location of the next astrics spot-------------
	STRB v2, [r11]
	ADD v7, v7, #1

	CMP v5, #0x77	; w
	BNE checks
	ADD v4, v4, #10
	SUB r11, r11, #49
	B homecheck
checks:
	CMP v5, #0x73	; s
	BNE checka
	SUB v4, v4, #10
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
	CMP v2, #0x41	; compare to A
	BEQ deadfrog
	CMP v2, #0x23	; compare to #
	BEQ deadfrog
	CMP v2, #0x43	; compare to C
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
	ADD v4, v4, #50
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
	B gameover	; need to set a flag to read from in busy loop
respawn:
	STRB v2, [r11]

	MOV v2, #0x2E

	MOV r11, #0x02B0
	MOVT r11, #0x2000

	;need to find a random spot along the bottom to place the asterisk
	;for now, it will just go to the bottom corner


;-------------------------end dead frog------------------------------


;--------------------movement for logs, etc, only do this half the time-----------------------
endtimer:
	CMP v7, #2
	BNE timerfinale
	SUB v7, v7, #2

;#0x2000724D
	STMFD sp!, {r1, r2, r3, r4, r9, r10, r11, r12}

	MOV r2, #0x20

	MOV r10, #0x024E
	MOVT r10, #0x2000

	MOV r11, #0x01EC
	MOVT r11, #0x2000

	MOV r12, #0x018A
	MOVT r12, #0x2000

	MOV r9, #0x027F
	MOVT r9, #0x2000

carloop2:
	LDRB r3, [r10], #1
	CMP r3, #0x7C
	BEQ carloop4
	CMP r3, #0x20
	BEQ carloop2
	LDRB r4, [r10]
	CMP r4, #0x7C
	STRB r2, [r10, #-1]
	BEQ carloop4	; get rid of character
	STRB r3, [r10]
	ADD r10, r10, #1
	B carloop2

carloop4:
	LDRB r3, [r11], #1
	CMP r3, #0x7C
	BEQ carloop6
	CMP r3, #0x20
	BEQ carloop4
	LDRB r4, [r11]
	CMP r4, #0x7C
	STRB r2, [r11, #-1]
	BEQ carloop6	; get rid of character
	STRB r3, [r11]
	ADD r11, r11, #1
	B carloop4

carloop6:
	LDRB r3, [r12], #1
	CMP r3, #0x7C
	BEQ truckloop1
	CMP r3, #0x20
	BEQ carloop6
	LDRB r4, [r12]
	CMP r4, #0x7C
	STRB r2, [r12, #-1]
	BEQ truckloop1	; get rid of character
	STRB r3, [r12]
	ADD r12, r12, #1
	B carloop6

truckloop1:
	LDRB r3, [r9], #1
	CMP r3, #0x7C
	BEQ endloops
	CMP r3, #0x20
	BEQ truckloop1
	LDRB r4, [r9, #-2]
	CMP r4, #0x7C
	STRB r2, [r9, #-1] ; here we are setting the head # to a space
	BEQ truckloop1
	MOV r1, #0x23 ; r1 holds a # character
	STRB r1, [r9, #-2] ;set the space to the left of head to the new # character
	B truckloop1

endloops:
	LDMFD sp!, {r1, r2, r3, r4, r9, r10, r11, r12}



;--------------------end movement for logs, etc------------------------------------------------
timerfinale:

	MOV a3, #0x26
	STRB a3, [r11]

	LDR r4, ptr
	BL output_string	; print the board to putty
	MOV r9, v3
	BL inttoascii
	BL character_newline

	MOV v5, #0x00
	MOV r0, #0x0024		; go to TIMER0 Interrupt Clear GPTMICR at 0x40030000 offset 0x24, and clear bit 0 by writting a 1 to it
	MOVT r0, #0x4003
	LDR r2, [r0]
	ORR r2, r2, #0x1
	STR r2, [r0]

;-----------clear psr----------
;	MOV r8, #0xFFFF
;	MOVT r8, #0x0FFF
;	LDR r11, [r12]
;	AND r11, r11, r8
;	MSR APSR_nzcvq, r11
;---------end clear psr---------

	LDMFD sp!, {lr}
	BX lr


Timer1Handler: ; This is the handler for the game countdown
	STMFD sp!,{lr,r0,r2,r4,r9}

	SUB v3, v3, #1

	MOV r0, #0x1024		; go to TIMER0 Interrupt Clear GPTMICR at 0x40030000 offset 0x24, and clear bit 0 by writting a 1 to it
	MOVT r0, #0x4003
	LDR r2, [r0]
	ORR r2, r2, #0x1
	STR r2, [r0]

	LDMFD sp!, {lr,r0,r2,r4,r9}
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
	CMP r9, #0x1
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

	LDR r4, ptrl
	BL output_string	; print the legend to putty
	BL uart_disable
;	BL timer_disable

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

	MOV r10, #0x7000
	MOVT r10, #0x2000

	MOV r1, #0x00


	MOV r0, #0x2323	; ascii for # four wide is a truck
	MOVT r0, #0x2323
	STR r0, [r10], #4
	STRB r1, [r10], #1

	MOV r0, #0x43	; ascii for C one wide is a car
	STRB r0, [r10], #1
	STRB r1, [r10], #1	; #0x20007005

	MOV r0, #0x41	; ascii for A one wide is an alligator mouth
	STRB r0, [r10], #1

	MOV r0, #0x6161	; ascii for a five wide is an alligator back
	MOVT r0, #0x6161
	STR r0, [r10], #4
	MOV r0, #0x61	; end of alligator back
	STRB r0, [r10], #1
	STRB r1, [r10], #1	; #0x20007007

	MOV r0, #0x4C4C	; ascii for L six wide is a log
	MOVT r0, #0x4C4C
	STR r0, [r10], #4
	MOV r0, #0x4C4C	; end of log
	STRH r0, [r10], #2
	STRB r1, [r10], #1	; #0x2000700e

	MOV r0, #0x5454	; ascii for T two wide is a turtle
	STRH r0, [r10], #2
	STRB r1, [r10], #1	; #0x20007015

	MOV r0, #0x4F	; ascii for O one wide is a lilypad
	STRB r0, [r10], #1
	STRB r1, [r10], #1	; #0x20007018


gamestart:
	LDR r4, ptr
	BL output_string	; print the board to putty
	MOV v4, #0
	MOV v3, #60
	MOV v7, #0

	MOV r9, v3
	BL inttoascii
	BL character_newline

	ADR r4, startprompt
	BL output_string

	ADR r4, explainprompt
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

	MOV r9, v4
	BL inttoascii
	BL character_newline	; prints score

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

