
.def ballCol = r17
.def ballRow = r18
.def paddleCol = r19
.def vectorX = r23
.def vectorY = r24
.def blockRow1 = r26
.def blockRow2 = r27
.def blockRow3 = r28
.def blockRow4 = r29
.def blockCounter = r10


;free: r16, r30, r31

LDI R16, 0b11111111           ; writing bit pattern 1000 0000 to register 16
OUT DDRA, R16           ; setup data direction for port A
out ddrc, r16
ldi ballCol, 0b11101111 ; ball column
ldi ballRow, 0b01000000 ; ball row
ldi vectorX, 0b00000001 ; 100 left / 010 middle / 001 right
ldi vectorY, 0b00000010 ; 10 up / 01 down

ldi blockRow1, 0b00000000
ldi blockRow2, 0b00000000
ldi blockRow3, 0b00000000
ldi blockRow4, 0b00000000

ldi r16, 32
mov blockCounter, r16

ldi paddleCol, 0b11000111 ; paddle column

ldi		r20, 0xff		; left button
out		ddrg, r20	    ; set port G to input

ldi		r20, 0xff		; right button
out		ddrb, r20	    ; set port B to input

call main ; for debug

game_start:
	call start_position
	in r20, PING
	cpi r20, 0
	breq game_start
	in r20, PINB
	cpi r20, 0
	breq game_start

main:
	ldi r25, 12 ; number of display loop iteration before game logic
	
display:
		
	call row_one
	;call delay_10ms

	call row_two
	;call delay_10ms

	call row_three
	;call delay_10ms

	call row_four
	;call delay_10ms
	
	call ball
	;call delay_10ms

	call paddle
	;call delay_10ms
	;60ms

	dec r25
	cpi r25, 0
	breq game
	rjmp display


game:
	call button					; read buttons input
	
	call check_ball_top
	call check_ball_left_wall
	call check_ball_right_wall

	call check_ball_hit_paddle

	call check_ball_hit_block

	call movementX				; move ball in X axis
	call movementY				; move ball in Y axis

	call check_win
	call check_game_over
	rjmp main

check_win:
	ldi r16, 0
	cp blockCounter, r16
	breq win
	ret
win:
	call happy_face

button:
	in r20, PINB ; read from button on PING (41) to r20
	cpi r20, 0
	brne move_paddle_right
	in r20, PING
	cpi r20, 0
	brne move_paddle_left
	ret
	
	rjmp main

movementX:
	cpi vectorX, 0b00000010
	breq return
	cpi vectorX, 0b00000100
	breq move_ball_left
	cpi vectorX, 0b00000001
	breq move_ball_right
	ret

movementY:
	cpi vectorY, 0b00000010
	breq move_ball_up
	cpi vectorY, 0b00000001
	breq move_ball_down
	ret

move_paddle_right:
;circular shift left
	cpi paddleCol, 0b00011111
	breq return
	bst paddleCol, 7
    rol paddleCol
    bld paddleCol, 0
	ret	

move_paddle_left:
;circular shift right
	cpi paddleCol, 0b11111000
	breq return
	bst paddleCol,0
    ror paddleCol
    bld paddleCol,7
	ret

return: ;return to last call, use with branch
	ret

move_ball_up:
;circural shift right
	bst ballRow, 0
    ror ballRow
    bld ballRow, 7
	ret

move_ball_down:
;circular shift left
	bst ballRow, 7
    rol ballRow
    bld ballRow, 0
	ret

move_ball_right:
;circular shift left
	bst ballCol, 7
    rol ballCol
    bld ballCol, 0
	ret

move_ball_left:
;circular shift right
	bst ballCol,0
    ror ballCol
    bld ballCol,7
	ret

check_ball_top:
	cpi ballRow, 0b00000001
	breq change_Y_to_down
	ret

change_Y_to_down:
	ldi vectorY, 0b00000001
	ret

change_Y_to_up:
	ldi vectorY, 0b00000010
	ret

check_ball_left_wall:
	cpi ballCol, 0b11111110
	breq change_X_to_right
	ret

change_X_to_right:
	ldi vectorX, 0b00000001
	ret

check_ball_right_wall:
	cpi ballCol, 0b01111111
	breq change_X_to_left
	ret

change_X_to_left:
	ldi vectorX, 0b00000100
	ret

check_ball_hit_paddle:
	ldi	 r31, 0b01000000 ; ball on second row
	cpse ballRow, r31
	ret

	call save_ball

	call movementX  ;simulate one ball movement
	call movementY

	ldi r31, 0xff
	mov r30, paddleCol ; load paddle pattern
	eor r30, r31	   ; flip all bits

	mov r16, ballCol   ; load ball pattern
	eor r16, r31	   ; flip all bits

	and r16, r30	   ; AND bitwise both numbers

	call load_ball

	cpi r16, 0		   ; if number is greater than 0, ball hit the paddle
	brne change_Y_to_up
	ret

save_ball:
	mov r14, ballCol
	mov r15, ballRow 
	ret

load_ball:
	mov ballCol, r14
	mov ballRow, r15
	ret

revertY:
	cpi vectorY, 0b00000001
	breq change_Y_to_up
	jmp change_Y_to_down

	

check_ball_hit_block:
;if(ballRow < 0b00010000
	cpi ballRow, 0b00000001
	breq check_row1
	cpi ballRow, 0b00000010
	breq check_row2
	cpi ballRow, 0b00000100
	breq check_row3
	cpi ballRow, 0b00001000
	breq check_row4
	ret

check_row1:
	ldi r31, 0xff
	mov r30, blockRow1 ; load paddle pattern
	eor r30, r31	   ; flip all bits

	mov r16, ballCol   ; load ball pattern
	eor r16, r31	   ; flip all bits

	and r16, r30	   ; AND bitwise both numbers
	cpi r16, 0		   ; if number is greater than 0, ball hit the paddle
	brne hitR1
	ret

hitR1:
	and blockRow1, ballCol
	dec blockCounter
	jmp revertY
	ret

check_row2:
	ldi r31, 0xff
	mov r30, blockRow2 ; load paddle pattern
	eor r30, r31	   ; flip all bits

	mov r16, ballCol   ; load ball pattern
	eor r16, r31	   ; flip all bits

	and r16, r30	   ; AND bitwise both numbers
	cpi r16, 0		   ; if number is greater than 0, ball hit the paddle
	brne hitR2
	ret

hitR2:
	and blockRow2, ballCol
	dec blockCounter
	jmp revertY
	ret

check_row3:
	ldi r31, 0xff
	mov r30, blockRow3 ; load paddle pattern
	eor r30, r31	   ; flip all bits

	mov r16, ballCol   ; load ball pattern
	eor r16, r31	   ; flip all bits

	and r16, r30	   ; AND bitwise both numbers
	cpi r16, 0		   ; if number is greater than 0, ball hit the paddle
	brne hitR3
	ret	

hitR3:
	and blockRow3, ballCol
	dec blockCounter
	jmp revertY
	ret

check_row4:
	ldi r31, 0xff
	mov r30, blockRow4 ; load paddle pattern
	eor r30, r31	   ; flip all bits

	mov r16, ballCol   ; load ball pattern
	eor r16, r31	   ; flip all bits

	and r16, r30	   ; AND bitwise both numbers
	cpi r16, 0		   ; if number is greater than 0, ball hit the paddle
	brne revertY
	ret

hitR4:
	and blockRow4, ballCol
	dec blockCounter
	jmp revertY
	ret

row_one:
	ldi r16, 0b00000001
	out porta, r16
	
	mov r16, blockRow1
	out portc, r16
	ret

row_two:
	ldi r16, 0b00000010
	out porta, r16
	
	mov r16, blockRow2
	out portc, r16
	ret

row_three:
	ldi r16, 0b00000100
	out porta, r16
	
	mov r16, blockRow3
	out portc, r16
	ret

row_four:
	ldi r16, 0b00001000
	out porta, r16
	
	mov r16, blockRow4
	out portc, r16
	ret

ball:
	out porta, ballRow
	
	out portc, ballCol
	ret

paddle:
	ldi r16, 0b10000000
	out porta, r16
	
	mov r16, paddleCol
	out portc, r16
	ret

delay_10ms:
	ldi r20, 2
delay_loop_1:
    ldi r21, 50 
delay_loop_2: 
	ldi r22, 100
delay_loop_3: ;
	dec r22
	nop
	brne delay_loop_3

	dec r21
	brne delay_loop_2

	dec r20
	brne delay_loop_1
    ret

check_game_over:
	cpi ballRow, 0b10000000
	breq sad_face
	ret

sad_face:
	;set up first row
	ldi r16, 0b00000001
	out porta, r16
	
	ldi r16, 0b11111111
	out portc, r16
	
	call delay_10ms

	;set up second row
	ldi r16, 0b00000010
	out porta, r16
	
	ldi r16, 0b10011001
	out portc, r16
	
	call delay_10ms

	;set up third row
	ldi r16, 0b00000100
	out porta, r16
	
	ldi r16, 0b10011001
	out portc, r16
	
	call delay_10ms

	;set up fourth row
	ldi r16, 0b00001000
	out porta, r16
	
	ldi r16, 0b11111111
	out portc, r16
	
	call delay_10ms

	;set up fifth row
	ldi r16, 0b00010000
	out porta, r16
	
	ldi r16, 0b11100111
	out portc, r16
	
	call delay_10ms

	;set up sixth row
	ldi r16, 0b00100000
	out porta, r16
	
	ldi r16, 0b11011011
	out portc, r16
	
	call delay_10ms

	;set up seventh row
	ldi r16, 0b01000000
	out porta, r16
	
	ldi r16, 0b10111101
	out portc, r16
	
	call delay_10ms

	;set up eighth row
	ldi r16, 0b10000000
	out porta, r16
	
	ldi r16, 0b11111111
	out portc, r16
	
	call delay_10ms

	rjmp sad_face

start_position:
	;set up first row
	ldi r16, 0b00000001
	out porta, r16
	
	ldi r16, 0b00000000
	out portc, r16
	
	call delay_10ms

	;set up second row
	ldi r16, 0b00000010
	out porta, r16
	
	ldi r16, 0b00000000
	out portc, r16
	
	call delay_10ms

	;set up third row
	ldi r16, 0b00000100
	out porta, r16
	
	ldi r16, 0b00000000
	out portc, r16
	
	call delay_10ms

	;set up fourth row
	ldi r16, 0b00001000
	out porta, r16
	
	ldi r16, 0b00000000
	out portc, r16
	
	call delay_10ms
	;set up fifth row
	ldi r16, 0b00010000
	out porta, r16
	
	ldi r16, 0b11111111
	out portc, r16
	
	call delay_10ms

	;set up sixth row
	ldi r16, 0b00100000
	out porta, r16
	
	ldi r16, 0b11111111
	out portc, r16
	
	call delay_10ms

	;set up seventh row
	ldi r16, 0b01000000
	out porta, r16
	
	ldi r16, 0b11101111
	out portc, r16
	
	call delay_10ms

	;set up eighth row
	ldi r16, 0b10000000
	out porta, r16
	
	ldi r16, 0b11000111
	out portc, r16
	
	call delay_10ms

	ret


happy_face:
	;set up first row
	ldi r16, 0b00000001
	out porta, r16
	
	ldi r16, 0b11111111
	out portc, r16
	
	call delay_10ms

	;set up second row
	ldi r16, 0b00000010
	out porta, r16
	
	ldi r16, 0b10011001
	out portc, r16
	
	call delay_10ms

	;set up third row
	ldi r16, 0b00000100
	out porta, r16
	
	ldi r16, 0b10011001
	out portc, r16
	
	call delay_10ms

	;set up fourth row
	ldi r16, 0b00001000
	out porta, r16
	
	ldi r16, 0b11111111
	out portc, r16
	
	call delay_10ms
	;set up fifth row
	ldi r16, 0b00010000
	out porta, r16
	
	ldi r16, 0b10111101
	out portc, r16
	
	call delay_10ms

	;set up sixth row
	ldi r16, 0b00100000
	out porta, r16
	
	ldi r16, 0b11011011
	out portc, r16
	
	call delay_10ms

	;set up seventh row
	ldi r16, 0b01000000
	out porta, r16
	
	ldi r16, 0b11100111
	out portc, r16
	
	call delay_10ms

	;set up eighth row
	ldi r16, 0b10000000
	out porta, r16
	
	ldi r16, 0b11111111
	out portc, r16
	
	call delay_10ms

	rjmp happy_face