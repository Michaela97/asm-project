;The ballCol, paddle and blocks registers are storing patterns of displayed collumn
;When to the column on the display is provided low, and to row is provided high then the led is lit
;For the column pattern 0b11111110 the first led on the left will be lit
;For the row pattern 0b00000001 the top row is lit

;define names for registers
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


;free registers: r16, r30, r31

ldi r16, 0b11111111     ; writing bit pattern 1000 0000 to register 16
out ddra, r16           ; setup data direction for port A - output
out ddrc, r16			; setup data direction for port C - output

;prepare game registers
ldi ballCol, 0b11101111 ; ball column - 0 means that column is displayed
ldi ballRow, 0b01000000 ; ball row - 1 means that ball is in that raw
ldi vectorX, 0b00000001 ; direction of vector (100 left / 001 right)
ldi vectorY, 0b00000010 ; direction of vector (10 up / 01 down)

;initialize block pattern
ldi blockRow1, 0b10101010
ldi blockRow2, 0b01010101
ldi blockRow3, 0b10101010
ldi blockRow4, 0b01010101

;initialize blocks to hit counter. When counter = 0 then the game is over and player has won
ldi r16, 16
mov blockCounter, r16

ldi paddleCol, 0b11000111 ; paddle column (0 - led on, 1 - led off) each bit corresponds to one column 

ldi		r20, 0xff		; left button
out		ddrg, r20	    ; set port G to input

ldi		r20, 0xff		; right button
out		ddrb, r20	    ; set port B to input


game_start:  ; loading start position, the game will start when both buttons are pressed 
	call start_position
	in r20, PING		;read left button
	cpi r20, 0			;if r20 != 0 then button is pressed
	breq game_start
	in r20, PINB		;read right button
	cpi r20, 0			;if r20 != 0 then button is pressed
	breq game_start		;go back in loop

main:
	ldi r25, 12 ; number of display loop iteration before game logic
	
display:
	;section responsible for displaying the game status on the screen
	;each row is displayed separately in 10ms periods. Then the procedure repeats
	call row_one
	call delay_10ms

	call row_two
	call delay_10ms

	call row_three
	call delay_10ms

	call row_four
	call delay_10ms
	
	call ball
	call delay_10ms

	call paddle
	call delay_10ms
	;displaying all elements on the screen takes approx. 60ms

	
	;when the screen is displayed 12 times, 
	;so 12*60ms = 720ms passed the game logic is checked
	dec r25
	cpi r25, 0
	breq game
	rjmp display


game:
	call button					; read buttons input
	
	call check_ball_left_wall	
	call check_ball_right_wall

	call check_ball_hit_paddle

	call check_ball_hit_block

	call check_ball_top

	;move the ball according to vector 
	call movementX				; move ball in X axis
	call movementY				; move ball in Y axis

	call check_win
	call check_game_over
	rjmp main

check_win:
	;if blockCounter = 0 then the player destoryed all the blocks and the player has won
	ldi r16, 0
	cp blockCounter, r16
	breq win
	ret
win:
	call happy_face

button:
	in r20, PINB ; read from button on PINB to r20
	cpi r20, 0   ; check if right button was pressed
	brne move_paddle_right
	in r20, PING ; read from button on PING to r20
	cpi r20, 0 ; check if left button was pressed
	brne move_paddle_left 
	ret

movementX:
	cpi vectorX, 0b00000100 ;if vector is equal this value then move ball left
	breq move_ball_left
	cpi vectorX, 0b00000001	;if vector is equal this value then move ball lright
	breq move_ball_right
	ret

movementY:
	cpi vectorY, 0b00000010	;if vector is equal this value then move ball up
	breq move_ball_up
	cpi vectorY, 0b00000001	;if vector is equal this value then move ball down
	breq move_ball_down
	ret

move_paddle_right:
;circular shift left
	cpi paddleCol, 0b00011111 ; if paddle is on the right, don't move it
	breq return
	bst paddleCol, 7	;store last left bit 
    rol paddleCol		;shit to left
    bld paddleCol, 0	;load stored bit to first bit
	ret	

move_paddle_left:
;circular shift right
	cpi paddleCol, 0b11111000
	breq return
	bst paddleCol, 0	;store last right bit
    ror paddleCol		;shit to right
    bld paddleCol, 7	;load stored bit to last bit
	ret

return: ;return to last call, use with branch
	ret

move_ball_up:
;circural shift right
;shifting right moves the ball up
	bst ballRow, 0
    ror ballRow
    bld ballRow, 7
	ret

move_ball_down:
;circular shift left
;shifting left moves the ball down
	bst ballRow, 7
    rol ballRow
    bld ballRow, 0
	ret

move_ball_right:
;circular shift left
;shifting left moves the ball to the right
	bst ballCol, 7
    rol ballCol
    bld ballCol, 0
	ret

move_ball_left:
;circular shift right
;shifting right moves the ball to the left
	bst ballCol,0
    ror ballCol
    bld ballCol,7
	ret

check_ball_top:
	cpi ballRow, 0b00000001 ;ball in top row
	breq change_Y_to_down
	ret

change_Y_to_down:
	ldi vectorY, 0b00000001 
	ret

change_Y_to_up:
	ldi vectorY, 0b00000010
	ret

check_ball_left_wall:
	cpi ballCol, 0b11111110 ;ball near left wall
	breq change_X_to_right
	ret

change_X_to_right:
	ldi vectorX, 0b00000001
	ret

check_ball_right_wall:
	cpi ballCol, 0b01111111 ;ball near right wall
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
	mov r15, ballRow ;store ball position to r14 and r15
	ret

load_ball:
	mov ballCol, r14 
	mov ballRow, r15 ;load ball back to correct registers
	ret

revertY:
	cpi vectorY, 0b00000001
	breq change_Y_to_up
	jmp change_Y_to_down

	

check_ball_hit_block:
	cpi ballRow, 0b00000001 ;ball in top row
	breq check_row1
	cpi ballRow, 0b00000010	;ball in 2nd form the top row
	breq check_row2
	cpi ballRow, 0b00000100	;ball in 3rd row
	breq check_row3
	cpi ballRow, 0b00001000 ;ball in 4th row
	breq check_row4
	ret

check_row1:
	ldi r31, 0xff
	mov r30, blockRow1 ; load paddle pattern
	eor r30, r31	   ; flip all bits

	mov r16, ballCol   ; load ball pattern
	eor r16, r31	   ; flip all bits

	and r16, r30	   ; AND bitwise both numbers
	cpi r16, 0		   ; if number is greater than 0, ball hit the block
	brne hitR1
	ret

hitR1:
	mov r16, ballCol   ; load ball pattern
	eor r16, r31	   ; flip all bits
	or blockRow1, r16  ; turn off the block with ball
	dec blockCounter   ; subtract 1 from counter
	jmp revertY
	ret

check_row2:
	ldi r31, 0xff
	mov r30, blockRow2 ; load paddle pattern
	eor r30, r31	   ; flip all bits

	mov r16, ballCol   ; load ball pattern
	eor r16, r31	   ; flip all bits

	and r16, r30	   ; AND bitwise both numbers
	cpi r16, 0		   ; if number is greater than 0, ball hit the block
	brne hitR2
	ret

hitR2:
	mov r16, ballCol   ; load ball pattern
	eor r16, r31	   ; flip all bits
	or blockRow2, r16
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
	cpi r16, 0		   ; if number is greater than 0, ball hit the block
	brne hitR3
	ret	

hitR3:
	mov r16, ballCol   ; load ball pattern
	eor r16, r31	   ; flip all bits
	or blockRow3, r16
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
	cpi r16, 0		   ; if number is greater than 0, ball hit the block
	brne hitR4
	ret

hitR4:
	mov r16, ballCol   ; load ball pattern
	eor r16, r31	   ; flip all bits
	or blockRow4, r16
	dec blockCounter
	jmp revertY
	ret


;display subroutines
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

;delay loop
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

sad_face: ;turn on leds to show a sad face
	ldi r16, 0b00000001 ;set up first row
	out porta, r16
	
	ldi r16, 0b11111111
	out portc, r16
	
	call delay_10ms

	ldi r16, 0b00000010 ;set up second row
	out porta, r16
	
	ldi r16, 0b10011001
	out portc, r16
	
	call delay_10ms

	
	ldi r16, 0b00000100 ;set up third row
	out porta, r16
	
	ldi r16, 0b10011001
	out portc, r16
	
	call delay_10ms

	
	ldi r16, 0b00001000 ;set up fourth row
	out porta, r16
	
	ldi r16, 0b11111111
	out portc, r16
	
	call delay_10ms

	
	ldi r16, 0b00010000 ;set up fifth row
	out porta, r16
	
	ldi r16, 0b11100111
	out portc, r16
	
	call delay_10ms

	
	ldi r16, 0b00100000 ;set up sixth row
	out porta, r16
	
	ldi r16, 0b11011011
	out portc, r16
	
	call delay_10ms

	
	ldi r16, 0b01000000 ;set up seventh row
	out porta, r16
	
	ldi r16, 0b10111101
	out portc, r16
	
	call delay_10ms

	
	ldi r16, 0b10000000 ;set up eighth row
	out porta, r16
	
	ldi r16, 0b11111111
	out portc, r16
	
	call delay_10ms

	rjmp sad_face


start_position: ; turn on leds to show start position
	;set up first row
	ldi r16, 0b00000001
	out porta, r16
	
	ldi r16, 0b10101010
	out portc, r16
	
	call delay_10ms

	;set up second row
	ldi r16, 0b00000010
	out porta, r16
	
	ldi r16, 0b01010101
	out portc, r16
	
	call delay_10ms

	;set up third row
	ldi r16, 0b00000100
	out porta, r16
	
	ldi r16, 0b10101010
	out portc, r16
	
	call delay_10ms

	;set up fourth row
	ldi r16, 0b00001000
	out porta, r16
	
	ldi r16, 0b01010101
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


happy_face: ;turn on leds to show happy face
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