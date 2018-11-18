
.def ballCol = r17
.def ballRow = r18
.def paddleCol = r19
.def vectorX = r23
.def vectorY = r24

LDI R16, 0b11111111           ; writing bit pattern 1000 0000 to register 16
OUT DDRA, R16           ; setup data direction for port A
out ddrc, r16
ldi ballCol, 0b11101111 ; ball column
ldi ballRow, 0b01000000 ; ball row
ldi vectorX, 0b00000010 ; 100 left / 010 middle / 001 right
ldi vectorY, 0b00000010 ; 10 up / 01 down

ldi paddleCol, 0b11000111 ; paddle column

ldi		r20, 0xff		; right button
out		ddrg, r20	    ; set port G to input

ldi		r20, 0xff		; left button
out		ddrb, r20	    ; set port K to input

main:
	ldi r25, 12 ; number of display loop iteration before game logic
	
display:
		
	;call row_one
	call delay_10ms

	;call row_two
	call delay_10ms

	;call row_three
	call delay_10ms

	;call row_four
	call delay_10ms
	
	call ball
	call delay_10ms

	call paddle
	call delay_10ms
	;60ms

	dec r25
	cpi r25, 0
	breq game
	rjmp display


game:

	call button
	call movement
	rjmp main

button:
	in r20, PINB ; read from button on PING (41) to r20
	cpi r20, 0
	brne move_paddle_right
	in r20, PING
	cpi r20, 0
	brne move_paddle_left
	ret
	
	rjmp main

movement:
	ldi 


row_one:
	ldi r16, 0b00000001
	out porta, r16
	
	ldi r16, 0b00000000
	out portc, r16
	ret

row_two:
	ldi r16, 0b00000010
	out porta, r16
	
	ldi r16, 0b00000000
	out portc, r16
	ret

row_three:
	ldi r16, 0b00000100
	out porta, r16
	
	ldi r16, 0b00000000
	out portc, r16
	ret

row_four:
	ldi r16, 0b00001000
	out porta, r16
	
	ldi r16, 0b00000000
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

;circural shift left
rolc:  bst r0,7
       rol r0
       bld r0,0

;circural shift right
rorc:  bst r0,0
       ror r0
       bld r0,7


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

