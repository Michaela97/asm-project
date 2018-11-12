
.def ballCol = r17
.def ballRow = r18

LDI R16, 0b11111111           ; writing bit pattern 1000 0000 to register 16
OUT DDRA, R16           ; setup data direction for port A
out ddrc, r16
ldi ballCol, 0b11101111 ; ball column
ldi ballRow, 0b10000000 ; ball row

ldi r24, 4
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

	;call paddle
	call delay_10ms
	;60ms

	dec r25
	cpi r25, 0
	breq game
	rjmp display


game:
	cpi r24, 4
	brne no4
	call move_ball_up

no4:
	cpi r24, 3
	brne no3
	call move_ball_right

no3:
	cpi r24, 2
	brne no2
	call move_ball_down

no2:
	cpi r24, 1
	brne no1
	call move_ball_left
 
no1:
	dec r24
	cpi r24, 0 ;copmare skip if equal
	brne main
	ldi r24, 4
	
	rjmp main



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
	
	ldi r16, 0b11100011
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

