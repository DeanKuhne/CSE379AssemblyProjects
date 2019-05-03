		.data
board:	.string 0xC, "|---------------------------------------------|", 0xA, 0xD, "|*********************************************|", 0xA, 0xD, "|*****     *****     *****     *****     *****|", 0xA, 0xD, "|~~~~~~~~~~~~~~~~~~~~Aaaaaa~~~~~~~~~~Aaaaaa~~~|", 0xA, 0xD, "|~~~TT~~~~~~~~~~TT~~~~TT~~~~~~~~TT~~~TT~~~~~~~|", 0xA, 0xD, "|~~~~~~~~TT~~~~~~~~~~~TT~~~~~~~~TT~~~~~~~~~TT~|", 0xA, 0xD, "|~~~~LLLLLL~~~~~~~~~~~~~LLLLLL~~~~~~~~~~~~~~~~|", 0xA, 0xD, "|.............................................|", 0xA, 0xD, "|                                             |", 0xA, 0xD, "|                                             |", 0xA, 0xD, "|                                             |", 0xA, 0xD, "|                                             |", 0xA, 0xD, "|                                             |", 0xA, 0xD, "|                                             |", 0xA, 0xD, "|&............................................|", 0xA, 0xD, "|---------------------------------------------|", 0
legend:	.string "| |: Vertical Wall      | +10 for moving forward one space   |", 0xA, 0xD, "| -: Horizontal Wall    | -10 for moving back one space      |", 0xA, 0xD, "| a: Alligator's Back   | +50 for getting a frog home safely |", 0xA, 0xD, "| A: Alligator's Mouth  | +100 for eating a fly              |", 0xA, 0xD, "| L: Log                | +250 for completing the level      |", 0xA, 0xD, "| O: Lily Pad           | +10 for each second of unused time |", 0xA, 0xD, "| &: Frog               |	 when getting a frog home    |", 0xA, 0xD, "| T: Turtle             |", 0xA, 0xD, "| C: Car                |", 0xA, 0xD, "| #: Truck              |", 0xA, 0xD, "| +: Fly                |", 0xA, 0xD, "| H: Occupied Home      |", 0xA, 0xD, "| ~: Water              |", 0

;----------------BAUD RATE IS 921,600----------------------------
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
	.global rand
	.global randspawn
	.global timerdecrease
	.global timer_disable
	.global timer_init2
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
	ADD v4, v4, #10		; increase point counter by 10 on every move up
	SUB r11, r11, #49	; updating r11 with the frog's position
	B homecheck
checks:
	CMP v5, #0x73	; s
	BNE checka
	SUB v4, v4, #10		; decrease point counter by 10 on every move down
	ADD r11, r11, #49	; updating r11 with the frog's position
	B homecheck
checka:
	CMP v5, #0x61	; a
	BNE checkd
	SUB r11, r11, #1	; updating r11 with the frog's position
	B homecheck
checkd:
	CMP v5, #0x64	; d
	BNE endtimer
	ADD r11, r11, #1	; updating r11 with the frog's position

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
	CMP v2, #0x48	; compare to H
	BEQ deadfrog

	MOV a3, #0x0090
	MOVT a3, #0x2000

	CMP r11, a3
	BGT gotvalue	; if r11 is greater than the home row, skip next part

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
;---------hprint: print HHHHH to home position frog made it to---------------
	MOV a3, #0x0087
	MOVT a3, #0x2000
	MOV a1, #0x48
	STRB a1, [a3], #1
	STRB a1, [a3], #1
	STRB a1, [a3], #1
	STRB a1, [a3], #1
	STRB a1, [a3]
;-----------end h print------------
	B daddyimhome
nothome1:
	SUB a3, a3, #0xA
	CMP r11, a3
	BLT nothome2
;---------hprint: print HHHHH to home position frog made it to---------------
	MOV a3, #0x007D
	MOVT a3, #0x2000
	MOV a1, #0x48
	STRB a1, [a3], #1
	STRB a1, [a3], #1
	STRB a1, [a3], #1
	STRB a1, [a3], #1
	STRB a1, [a3]
;-----------end h print------------
	B daddyimhome
nothome2:
	SUB a3, a3, #0xA
	CMP r11, a3
	BLT nothome3
;---------hprint: print HHHHH to home position frog made it to---------------
	MOV a3, #0x0073
	MOVT a3, #0x2000
	MOV a1, #0x48
	STRB a1, [a3], #1
	STRB a1, [a3], #1
	STRB a1, [a3], #1
	STRB a1, [a3], #1
	STRB a1, [a3]
;-----------end h print------------
	B daddyimhome
nothome3:
	SUB a3, a3, #0xA
	;---------hprint: print HHHHH to home position frog made it to---------------
	MOV a3, #0x0069
	MOVT a3, #0x2000
	MOV a1, #0x48
	STRB a1, [a3], #1
	STRB a1, [a3], #1
	STRB a1, [a3], #1
	STRB a1, [a3], #1
	STRB a1, [a3]
;-----------end h print------------
daddyimhome:
	ADD v4, v4, #50

	MOV a1, #0x0087
	MOVT a1, #0x2000	; home1

	MOV a2, #0

	LDRB a3, [a1, #1]
	CMP a3, #0x48
	BNE checkhome2
	ADD a2, a2, #1	; if we have been to this home, add 1 to a2

checkhome2:
	MOV a1, #0x007D
	MOVT a1, #0x2000	; home2

	LDRB a3, [a1, #1]
	CMP a3, #0x48
	BNE checkhome3
	ADD a2, a2, #1	; if we have been to this home, add 1 to a2


checkhome3:
	MOV a1, #0x0073
	MOVT a1, #0x2000	; home3

	LDRB a3, [a1, #1]
	CMP a3, #0x48
	BNE checkhome4
	ADD a2, a2, #1	; if we have been to this home, add 1 to a2

checkhome4:
	MOV a1, #0x0069
	MOVT a1, #0x2000	; home4

	LDRB a3, [a1, #1]
	CMP a3, #0x48
	BNE levelupmaybe
	ADD a2, a2, #1	; if we have been to this home, add 1 to a2

levelupmaybe:
	CMP a2, #2
	BLT newfrog


	MOV a3, #0x0087		; clearhome1
	MOVT a3, #0x2000
	MOV a1, #0x20
	STRB a1, [a3], #1
	STRB a1, [a3], #1
	STRB a1, [a3], #1
	STRB a1, [a3], #1
	STRB a1, [a3]

	MOV a3, #0x007D		; clearhome2
	MOVT a3, #0x2000
	MOV a1, #0x20
	STRB a1, [a3], #1
	STRB a1, [a3], #1
	STRB a1, [a3], #1
	STRB a1, [a3], #1
	STRB a1, [a3]

	MOV a3, #0x0073		; clearhome3
	MOVT a3, #0x2000
	MOV a1, #0x20
	STRB a1, [a3], #1
	STRB a1, [a3], #1
	STRB a1, [a3], #1
	STRB a1, [a3], #1
	STRB a1, [a3]

	MOV a3, #0x0069		; clearhome4
	MOVT a3, #0x2000
	MOV a1, #0x20
	STRB a1, [a3], #1
	STRB a1, [a3], #1
	STRB a1, [a3], #1
	STRB a1, [a3], #1
	STRB a1, [a3]

	ADD v4, v4, v3	; add remaining time to the score
	BL timerdecrease	; decrease time and interrupt period
	ADD v4, v4, #250	; add 250 to score


newfrog:
	MOV v2, #0x2E	; set history to a .

	MOV r11, #0x02B0
	MOVT r11, #0x2000	; starting location for frog (before randomization)

	;need to find a random spot along the bottom to place the asterisk
	;for now, it will just go to the bottom corner
	MOV a3, #0x26
	STRB a3, [r11]

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
	CMP a3, #0xF	; 4 lives remaining before this death
	BNE not4
	MOV a3, #0x7
	STR a3, [r12]	; decrease lives remaining by 1
	B respawn
not4:
	CMP a3, #0x7	; 3 lives remaining before this death
	BNE not3
	MOV a3, #0x3
	STR a3, [r12]	; decrease lives remaining by 1
	B respawn
not3:
	CMP a3, #0x3	; 2 lives remaining before this death
	BNE not2
	MOV a3, #0x1
	STR a3, [r12]	; decrease lives remaining by 1
	B respawn
not2:
	MOV a3, #0x0
	STR a3, [r12]	; decrease lives remaining by 1
respawn:
	STRB v2, [r11]

	MOV v2, #0x2E	; sets history to a .

	MOV r11, #0x02B0
	MOVT r11, #0x2000

	STMFD sp!, {r1-r12, lr}
	BL randspawn ; GRAB DAT RANDOM NUMBER WHITE BOI
	LDMFD sp!, {r1-r12, lr}

    ADD r11,r11,r0

	;need to find a random spot along the bottom to place the asterisk
	;for now, it will just go to the bottom corner


;-------------------------end dead frog------------------------------


;--------------------movement for logs, etc, only do this half the time-----------------------
endtimer:
	MOV a3, #0x26
	STRB a3, [r11]


	CMP v7, #2
	BNE timerfinale
	SUB v7, v7, #2

;#0x2000724D
	STMFD sp!, {r0, r1, r2, r3, r4, r7, r8, r9, r10, r12}

	MOV r2, #0x20

preroadloop2:
	MOV r10, #0x027A	; start of shifting population of road loop 2
	MOVT r10, #0x2000

roadloop2:
	LDRB r3, [r10], #-1
	CMP r3, #0x7C
	BEQ spawnfor2
	CMP r3, #0x20
	BEQ roadloop2
	CMP r3, #0x26
	BEQ roadloop2
	LDRB r4, [r10, #2]
	CMP r4, #0x26
	BNE roadloop21
	BL squashedfrog
roadloop21:
	CMP r4, #0x7C
	STRB r2, [r10, #1] ; here we are setting the head # to a space
	BEQ roadloop2
	STRB r3, [r10, #2] ;set the space to the left of head to the new # character
	B roadloop2
;----------------------------- THE FOLLOWING LOGIC IS THE SAME FOR ROAD 2,4,and 6!----------------------------
spawnfor2:

	MOV r4, #0x024e
	MOVT r4, #0x2000 ; here starts the object spawning for road 2 this is the case for all rows where objects can spawn

	STMFD sp!, {r1-r12, lr}
	BL rand ; GRAB DAT RANDOM NUMBER WHITE BOI
	LDMFD sp!, {r1-r12, lr}

	CMP r0, #0x25 ; is it time to spawn a random thing?
	BGT preroadloop4 ; proceed on if it's not time
; here if we wanna spawn a neww oneee
;want to check if first 4 spots to right of r4 are spaces
	LDRB r3, [r4]
	CMP r3, #0x20
	BNE preroadloop4 ; if first slot is occupied, skip the spawning and go to preroadloop4
	LDRB r3, [r4, #1]
	CMP r3, #0x20
	BNE preroadloop4 ; if second slot is occupied, skip the spawning and go to preroadloop4
	LDRB r3, [r4, #2]
	CMP r3, #0x20
	BNE preroadloop4 ; if third slot is occupied, skip the spawning and go to preroadloop4
	LDRB r3, [r4, #3]
	CMP r3, #0x20
	BNE preroadloop4 ; if fourth slot is occupied, skip the spawning and go to preroadloop4
; here if we have space to spawn a truck
	MOV r3, #0x23
	STRB r3, [r4] ;set the space to the left of head to the new # character
	STRB r3, [r4, #1] ;set the space to the left of head to the new # character
	STRB r3, [r4, #2] ;set the space to the left of head to the new # character
	STRB r3, [r4, #3] ;set the space to the left of head to the new # character

;----------------------------------------------------------------------------------------------------
preroadloop4:
	MOV r0, #0x0218	; start of shifting population of road loop 2
	MOVT r0, #0x2000

roadloop4:
	LDRB r3, [r0], #-1
	CMP r3, #0x7C
	BEQ spawnfor4
	CMP r3, #0x20
	BEQ roadloop4
	CMP r3, #0x26
	BEQ roadloop4
	LDRB r4, [r0, #2]
	CMP r4, #0x26
	BNE roadloop41
	BL squashedfrog
roadloop41:
	CMP r4, #0x7C
	STRB r2, [r0, #1] ; here we are setting the head # to a space
	BEQ roadloop4
	STRB r3, [r0, #2] ;set the space to the left of head to the new # character
	B roadloop4

spawnfor4:

	MOV r4, #0x01ec
	MOVT r4, #0x2000

	STMFD sp!, {r1-r12, lr}
	BL rand ; GRAB DAT RANDOM NUMBER WHITE BOI
	LDMFD sp!, {r1-r12, lr}

	CMP r0, #0x25 ; is it time to spawn a random thing?
	BGT preroadloop6 ; proceed on if it's not time
; here if we wanna spawn a neww oneee
;want to check if first 4 spots to right of r4 are spaces
	LDRB r3, [r4]
	CMP r3, #0x20
	BNE preroadloop6 ; if first slot is occupied, skip the spawning and go to preroadloop6
	LDRB r3, [r4, #1]
	CMP r3, #0x20
	BNE preroadloop6 ; if second slot is occupied, skip the spawning and go to preroadloop6
	LDRB r3, [r4, #2]
	CMP r3, #0x20
	BNE preroadloop6 ; if third slot is occupied, skip the spawning and go to preroadloop6
	LDRB r3, [r4, #3]
	CMP r3, #0x20
	BNE preroadloop6 ; if fourth slot is occupied, skip the spawning and go to preroadloop6
; here if we have space to spawn a truck
	MOV r3, #0x23
	STRB r3, [r4] ;set the space to the left of head to the new # character
	STRB r3, [r4, #1] ;set the space to the left of head to the new # character
	STRB r3, [r4, #2] ;set the space to the left of head to the new # character
	STRB r3, [r4, #3] ;set the space to the left of head to the new # character

preroadloop6:

	MOV r12, #0x01B6	; carloop6
	MOVT r12, #0x2000

roadloop6:
	LDRB r3, [r12], #-1
	CMP r3, #0x7C
	BEQ spawnfor6
	CMP r3, #0x20
	BEQ roadloop6
	CMP r3, #0x26
	BEQ roadloop6
	LDRB r4, [r12, #2]
	CMP r4, #0x26
	BNE roadloop61
	BL squashedfrog
roadloop61:
	CMP r4, #0x7C
	STRB r2, [r12, #1] ; here we are setting the head # to a space
	BEQ roadloop6
	STRB r3, [r12, #2] ;set the space to the left of head to the new # character
	B roadloop6

spawnfor6:

	MOV r4, #0x018a
	MOVT r4, #0x2000

	STMFD sp!, {r1-r12, lr}
	BL rand ; GRAB DAT RANDOM NUMBER WHITE BOI
	LDMFD sp!, {r1-r12, lr}

	CMP r0, #0x25 ; is it time to spawn a random thing?
	BGT preroadloop1 ; proceed on if it's not time
; here if we wanna spawn a neww oneee
	CMP r0, #0x17
	BGT spawncaron6 ; if between 14-26 spawn a car
; here if spawning a truck on 2 with r0 range of 0-13 inclusive

;want to check if first 4 spots to right of r4 are spaces
	LDRB r3, [r4]
	CMP r3, #0x20
	BNE preroadloop1 ; if first slot is occupied, skip the spawning and go to preroadloop1
	LDRB r3, [r4, #1]
	CMP r3, #0x20
	BNE preroadloop1 ; if second slot is occupied, skip the spawning and go to preroadloop1
	LDRB r3, [r4, #2]
	CMP r3, #0x20
	BNE preroadloop1 ; if third slot is occupied, skip the spawning and go to preroadloop1
	LDRB r3, [r4, #3]
	CMP r3, #0x20
	BNE preroadloop1 ; if fourth slot is occupied, skip the spawning and go to preroadloop1
; here if we have space to spawn a truck
	MOV r3, #0x23
	STRB r3, [r4] ;set the space to the left of head to the new # character
	STRB r3, [r4, #1] ;set the space to the left of head to the new # character
	STRB r3, [r4, #2] ;set the space to the left of head to the new # character
	STRB r3, [r4, #3] ;set the space to the left of head to the new # character
	B preroadloop1

spawncaron6:
	LDRB r3, [r4]
	CMP r3, #0x20
	BNE preroadloop1 ; if first slot is occupied, skip the spawning and go to carloop2
	MOV r3, #0x43
	STRB r3, [r4] ;set the space to the left of head to the new C character
	B preroadloop1

preroadloop1:

	MOV r9, #0x027F		; truckloop1
	MOVT r9, #0x2000

roadloop1:
	LDRB r3, [r9], #1
	CMP r3, #0x7C
	BEQ spawnfor1
	CMP r3, #0x20
	BEQ roadloop1
	CMP r3, #0x26
	BEQ roadloop1
	LDRB r4, [r9, #-2]
	CMP r4, #0x26
	BNE roadloop11
	BL squashedfrog
roadloop11:
	CMP r4, #0x7C
	STRB r2, [r9, #-1] ; here we are setting the head # to a space
	BEQ roadloop1
	STRB r3, [r9, #-2] ;set the space to the left of head to the new # character
	B roadloop1
;--------------------------------------------------THE FOLLOWING LOGIC IS IDENTICAL TO ROAD 1,3,and 5----------------------
spawnfor1:

	MOV r4, #0x02ab
	MOVT r4, #0x2000

	STMFD sp!, {r1-r12, lr}
	BL rand ; GRAB DAT RANDOM NUMBER WHITE BOI
	LDMFD sp!, {r1-r12, lr}

	CMP r0, #0x25 ; is it time to spawn a random thing?
	BGT preroadloop3 ; proceed on if it's not time
; here if we wanna spawn a neww oneee
	LDRB r3, [r4]
	CMP r3, #0x20
	BNE preroadloop3 ; if first slot is occupied, skip the spawning and go to preroadloop3
	MOV r3, #0x43
	STRB r3, [r4] ;set the space to the left of head to the new C character for spawning a CAR!
	B preroadloop3
;----------------------------------------------------------------------------------------------------------------------------
preroadloop3:

	MOV r8, #0x01BB		; truckloop3
	MOVT r8, #0x2000

roadloop3:
	LDRB r3, [r8], #1
	CMP r3, #0x7C
	BEQ spawnfor3
	CMP r3, #0x20
	BEQ roadloop3
	CMP r3, #0x26
	BEQ roadloop3
	LDRB r4, [r8, #-2]
	CMP r4, #0x26
	BNE roadloop31
	BL squashedfrog
roadloop31:
	CMP r4, #0x7C
	STRB r2, [r8, #-1] ; here we are setting the head # to a space
	BEQ roadloop3
	STRB r3, [r8, #-2] ;set the space to the left of head to the new # character
	B roadloop3

spawnfor3:

	MOV r4, #0x0249
	MOVT r4, #0x2000

	STMFD sp!, {r1-r12, lr}
	BL rand ; GRAB DAT RANDOM NUMBER WHITE BOI
	LDMFD sp!, {r1-r12, lr}

	CMP r0, #0x25 ; is it time to spawn a random thing?
	BGT preroadloop5 ; proceed on if it's not time
; here if we wanna spawn a neww oneee
	LDRB r3, [r4]
	CMP r3, #0x20
	BNE preroadloop5 ; if first slot is occupied, skip the spawning and go to preroadloop5
	MOV r3, #0x43
	STRB r3, [r4] ;set the space to the left of head to the new C character
	B preroadloop5

preroadloop5:

	MOV r7, #0x021D		; truckloop5
	MOVT r7, #0x2000

roadloop5:
	LDRB r3, [r7], #1
	CMP r3, #0x7C
	BEQ spawnfor5
	CMP r3, #0x20
	BEQ roadloop5
	CMP r3, #0x26
	BEQ roadloop5
	LDRB r4, [r7, #-2]
	CMP r4, #0x26
	BNE roadloop51
	BL squashedfrog
roadloop51:
	CMP r4, #0x7C
	STRB r2, [r7, #-1] ; here we are setting the head # to a space
	BEQ roadloop5
	STRB r3, [r7, #-2] ;set the space to the left of head to the new # character
	B roadloop5

spawnfor5:

	MOV r4, #0x01e7
	MOVT r4, #0x2000

	STMFD sp!, {r1-r12, lr}
	BL rand ; GRAB DAT RANDOM NUMBER WHITE BOI
	LDMFD sp!, {r1-r12, lr}

	CMP r0, #0x25 ; is it time to spawn a random thing?
	BGT transition ; proceed on if it's not time
; here if we wanna spawn a neww oneee
	LDRB r3, [r4]
	CMP r3, #0x20
	BNE transition ; if first slot is occupied, skip the spawning and go to transition
	MOV r3, #0x43
	STRB r3, [r4] ;set the space to the left of head to the new C character
	B transition

transition:
	MOV r2, #0x7E

prewater1:

	MOV r9, #0x0095		; start of shifting population of water loop 1, this is the case for all rows where objects can spawn
	MOVT r9, #0x2000

water1:
	LDRB r3, [r9], #1
	CMP r3, #0x7C
	BEQ spawnforwater1
	CMP r3, #0x26
	BNE water11
	BL movefrogl
water11:
	CMP r3, #0x20
	BEQ water1
	LDRB r4, [r9, #-2]
	CMP r4, #0x7C
	STRB r2, [r9, #-1] ; here we are setting the head to a space
	BEQ water1
	STRB r3, [r9, #-2] ;set the space to the left of head to the new character
	B water1

;--------------------------------THE FOLLOWING LOGIC IS IDENTICAL FOR WATER ROWS 1 and 3!---------------------
spawnforwater1:

	MOV r4, #0x00c1
	MOVT r4, #0x2000

	STMFD sp!, {r1-r12, lr}
	BL rand ; GRAB DAT RANDOM NUMBER WHITE BOI
	LDMFD sp!, {r1-r12, lr}

	CMP r0, #0x26 ; is it time to spawn a random thing?
	BGT prewater2 ; proceed on if it's not time

	LDRB r3, [r4]
	CMP r3, #0x7E
	BNE prewater2 ; if first slot is occupied, skip the spawning and go to prewater2
	LDRB r3, [r4, #-1]
	CMP r3, #0x7E
	BNE prewater2 ; if second slot is occupied, skip the spawning and go to prewater2
	LDRB r3, [r4, #-2]
	CMP r3, #0x7E
	BNE prewater2 ; if third slot is occupied, skip the spawning and go to prewater2
	LDRB r3, [r4, #-3]
	CMP r3, #0x7E
	BNE prewater2 ; if fourth slot is occupied, skip the spawning and go to prewater2
	LDRB r3, [r4, #-4]
	CMP r3, #0x7E
	BNE prewater2 ; if fifth slot is occupied, skip the spawning and go to prewater2
	LDRB r3, [r4, #-5]
	CMP r3, #0x7E
	BNE prewater2 ; if sixth slot is occupied, skip the spawning and go to prewater2
	MOV r3, #0x61
	STRB r3, [r4] ;set the space to the left of head to the new a character
	STRB r3, [r4, #-1] ;set the space to the left of head to the new a character
	STRB r3, [r4, #-2] ;set the space to the left of head to the new a character
	STRB r3, [r4, #-3] ;set the space to the left of head to the new a character
	STRB r3, [r4, #-4] ;set the space to the left of head to the new a character for alligator body
	MOV r3, #0x41
	STRB r3, [r4, #-5] ;set the space to the left of head to the new A character for alligator head
	B prewater2
;--------------------------------------------------------------------------------------------------------
prewater2:

	MOV r10, #0x00F2	; start of shifting population of water loop 2, this is the case for all rows where objects can spawn
	MOVT r10, #0x2000

water2:
	LDRB r3, [r10], #-1
	CMP r3, #0x7C
	BEQ spawnforwater2
	CMP r3, #0x26
	BNE water21
	BL movefrogr
water21:
	CMP r3, #0x20
	BEQ water2
	LDRB r4, [r10, #2]
	CMP r4, #0x7C
	STRB r2, [r10, #1] ; here we are setting the head to a space
	BEQ water2
	STRB r3, [r10, #2] ;set the space to the left of head to the new character
	B water2

spawnforwater2:

	MOV r4, #0x00c6
	MOVT r4, #0x2000

	STMFD sp!, {r1-r12, lr}
	BL rand ; GRAB DAT RANDOM NUMBER WHITE BOI
	LDMFD sp!, {r1-r12, lr}

	CMP r0, #0x26 ; is it time to spawn a random thing?
	BGT prewater3 ; proceed on if it's not time

	CMP r0, #0x18
	BGT notturtle2; if between 00-18 spawn a turtle, if not, spawn a lilypad!

    LDRB r3, [r4]
	CMP r3, #0x7E
	BNE prewater3 ; if first slot is occupied, skip the spawning and go to prewater3
	LDRB r3, [r4, #1]
	CMP r3, #0x7E
	BNE prewater3 ; if second slot is occupied, skip the spawning and go to prewater3
	MOV r3, #0x54
	STRB r3, [r4] ;set the space to the left of head to the new T character
	STRB r3, [r4, #1] ;set the space to the left of head to the new T character for TURTLE!
	B prewater3

notturtle2:

    LDRB r3, [r4]
	CMP r3, #0x7E
	BNE prewater3 ; if first slot is occupied, skip the spawning and go to prewater2
	MOV r3, #0x4F
	STRB r3, [r4] ;set the space to the left of head to the new O character for LILYPAD!

prewater3:

	MOV r0, #0x00F7	; water3
	MOVT r0, #0x2000

water3:
	LDRB r3, [r0], #1
	CMP r3, #0x7C
	BEQ spawnforwater3
	CMP r3, #0x26
	BNE water31
	BL movefrogl
water31:
	CMP r3, #0x20
	BEQ water3
	LDRB r4, [r0, #-2]
	CMP r4, #0x7C
	STRB r2, [r0, #-1] ; here we are setting the head to a space
	BEQ water3
	STRB r3, [r0, #-2] ;set the space to the left of head to the new character
	B water3

spawnforwater3:

	MOV r4, #0x0123
	MOVT r4, #0x2000

	STMFD sp!, {r1-r12, lr}
	BL rand ; GRAB DAT RANDOM NUMBER WHITE BOI
	LDMFD sp!, {r1-r12, lr}

	CMP r0, #0x26 ; is it time to spawn a random thing?
	BGT prewater4 ; proceed on if it's not time

    LDRB r3, [r4]
	CMP r3, #0x7E
	BNE prewater4 ; if first slot is occupied, skip the spawning and go to prewater4
	LDRB r3, [r4, #-1]
	CMP r3, #0x7E
	BNE prewater4 ; if second slot is occupied, skip the spawning and go to prewater4
	MOV r3, #0x54
	STRB r3, [r4] ;set the space to the left of head to the new T character
	STRB r3, [r4, #-1] ;set the space to the left of head to the new T character for TURTLE!

prewater4:

	MOV r12, #0x0154	; water4
	MOVT r12, #0x2000

water4:
	LDRB r3, [r12], #-1
	CMP r3, #0x7C
	BEQ spawnforwater4
	CMP r3, #0x26
	BNE water41
	BL movefrogr
water41:
	CMP r3, #0x20
	BEQ water4
	LDRB r4, [r12, #2]
	CMP r4, #0x7C
	STRB r2, [r12, #1] ; here we are setting the head to a space
	BEQ water4
	STRB r3, [r12, #2] ;set the space to the left of head to the new character
	B water4

spawnforwater4:

	MOV r4, #0x0128
	MOVT r4, #0x2000

	STMFD sp!, {r1-r12, lr}
	BL rand ; GRAB DAT RANDOM NUMBER WHITE BOI
	LDMFD sp!, {r1-r12, lr}

	CMP r0, #0x26 ; is it time to spawn a random thing?
	BGT endloops ; proceed on if it's not time

	LDRB r3, [r4]
	CMP r3, #0x7E
	BNE endloops ; if first slot is occupied, skip the spawning and go to endloops
	LDRB r3, [r4, #1]
	CMP r3, #0x7E
	BNE endloops ; if second slot is occupied, skip the spawning and go to endloops
	LDRB r3, [r4, #2]
	CMP r3, #0x7E
	BNE endloops ; if third slot is occupied, skip the spawning and go to endloops
	LDRB r3, [r4, #3]
	CMP r3, #0x7E
	BNE endloops ; if fourth slot is occupied, skip the spawning and go to endloops
	LDRB r3, [r4, #4]
	CMP r3, #0x7E
	BNE endloops ; if fifth slot is occupied, skip the spawning and go to endloops
	LDRB r3, [r4, #5]
	CMP r3, #0x7E
	BNE endloops ; if sixth slot is occupied, skip the spawning and go to endloops
; here if we have space to spawn a truck
	MOV r3, #0x4C
	STRB r3, [r4] ;set the space to the left of head to the new L character
	STRB r3, [r4, #1] ;set the space to the left of head to the new L character
	STRB r3, [r4, #2] ;set the space to the left of head to the new L character
	STRB r3, [r4, #3] ;set the space to the left of head to the new L character
	STRB r3, [r4, #4] ;set the space to the left of head to the new L character
	STRB r3, [r4, #5] ;set the space to the left of head to the new L character for LOG!

endloops:
	LDMFD sp!, {r0, r1, r2, r3, r4, r7, r8, r9, r10, r12}



;--------------------end movement for logs, etc------------------------------------------------
timerfinale:

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

	LDMFD sp!, {lr}
	BX lr

Timer1Handler: ; This is the handler for the game countdown
	STMFD sp!,{lr,r0,r2}

	SUB v3, v3, #1

	MOV r0, #0x1024		; go to TIMER0 Interrupt Clear GPTMICR at 0x40030000 offset 0x24, and clear bit 0 by writting a 1 to it
	MOVT r0, #0x4003
	LDR r2, [r0]
	ORR r2, r2, #0x1
	STR r2, [r0]

	LDMFD sp!, {lr,r0,r2}
	BX lr

Uart0Handler:
	STMFD sp!,{lr}
	; store whatever is at the new location, then print that value on next move
	BL read_character
	MOV v5, r0

enduart:
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
	BL timer_disable

	MOV r9, #0
	STRB r9, [r10]

	B leaveport
resume:
	MOV r0, #0x8
	BL illuminate_RGB_LED
	MOV r9, #0
	STRB r9, [r10]	; sets RGB LED to green
	BL uart_init
	BL timer_init2
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

	MOV r10, #0x70F0
	MOVT r10, #0x2000
	STR r1, [r10]

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
	CMP v3, #0
	BEQ gameover
	MOV r12, #0x53FC
	MOVT r12, #0x4000	; Sets r12 to PORTB's data register
	LDR a3, [r12]
	CMP a3, #0x00
	BEQ gameover

	B busy			; right most home is 0x2000008B, left most is 0x20000069

squashedfrog:
	STMFD sp!, {r0-r4, r6-r10, r12, lr}

	;need to decrease life counter, as well as place a new frog somewhere in the starting row
	MOV r12, #0x53FC
	MOVT r12, #0x4000	; Sets r12 to PORTB's data register
	LDR a3, [r12]
	CMP a3, #0xF
	BNE not4s
	MOV a3, #0x7
	STR a3, [r12]
	B respawns
not4s:
	CMP a3, #0x7
	BNE not3s
	MOV a3, #0x3
	STR a3, [r12]
	B respawns
not3s:
	CMP a3, #0x3
	BNE not2s
	MOV a3, #0x1
	STR a3, [r12]
	B respawns
not2s:
	MOV a3, #0x0
	STR a3, [r12]

respawns:
	MOV v2, #0x2E


	MOV r11, #0x02B0
	MOVT r11, #0x2000

	STMFD sp!, {r1-r12, lr}
	BL randspawn ; GRAB DAT RANDOM NUMBER WHITE BOI
	LDMFD sp!, {r1-r12, lr}

    ADD r11,r11,r0
	MOV a3, #0x26
	STRB a3, [r11]

	LDMFD sp!, {r0-r4, r6-r10, r12, lr}
	BX lr

movefrogl:
	STMFD sp!, {r1, lr}

	ADD r11, r11, #-1

	LDRB r1, [r11]
	CMP r1, #0x7C
	BNE allgoodl
	BL squashedfrog

allgoodl:

	LDMFD sp!, {r1, lr}
	BX lr

movefrogr:
	STMFD sp!, {r1, lr}

	ADD r11, r11, #1

	LDRB r1, [r11]
	CMP r1, #0x7C
	BNE allgoodr
	BL squashedfrog

allgoodr:
	LDMFD sp!, {r1, lr}
	BX lr


restart:
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

	MOV r0, #0x2E
	MOV r1, #45
newspawnloop:
	SUB r1, r1, #1
	STRB r0, [r11], #1
	CMP r1, #0
	BNE newspawnloop


	MOV a3, #0x0087		; clearhome1
	MOVT a3, #0x2000
	MOV a1, #0x20
	STRB a1, [a3], #1
	STRB a1, [a3], #1
	STRB a1, [a3], #1
	STRB a1, [a3], #1
	STRB a1, [a3]

	MOV a3, #0x007D		; clearhome2
	MOVT a3, #0x2000
	MOV a1, #0x20
	STRB a1, [a3], #1
	STRB a1, [a3], #1
	STRB a1, [a3], #1
	STRB a1, [a3], #1
	STRB a1, [a3]

	MOV a3, #0x0073		; clearhome3
	MOVT a3, #0x2000
	MOV a1, #0x20
	STRB a1, [a3], #1
	STRB a1, [a3], #1
	STRB a1, [a3], #1
	STRB a1, [a3], #1
	STRB a1, [a3]

	MOV a3, #0x0069		; clearhome4
	MOVT a3, #0x2000
	MOV a1, #0x20
	STRB a1, [a3], #1
	STRB a1, [a3], #1
	STRB a1, [a3], #1
	STRB a1, [a3], #1
	STRB a1, [a3]

	MOV r1, #0x00
	MOV r0, #0x00
	MOV r11, #0x02B0
	MOVT r11, #0x2000

waittostart2:
	BL read_character
	CMP r0, #0x20
	BNE waittostart2

	MOV r0, #0x8
	BL timer_init2
	BL illuminate_RGB_LED
	MOV v2, #0x2E
	B busy

gameover:
	BL timer_disable

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
	BL read_character
	CMP r0, #0
	BEQ exitgame	; no user input yet
	CMP r0, #0x71
	BNE restart	; user wishes to play again

	LDMFD sp!, {lr}
	BX lr

	.end
