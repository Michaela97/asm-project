
main:
	LDI R16, 0b11111111           ; writing bit pattern 1000 0000 to register 16
	OUT DDRA, R16           ; setup data direction for port A
	out ddrc, r16

	call row_one
	call delay_5ms

	call row_two
	call delay_5ms

	call row_three
	call delay_5ms

	call row_four
	call delay_5ms
	
	call ball
	call delay_5ms

	call paddle
	call delay_5ms



	rjmp main



; 20 ms delay subroutine
delay_5ms:
    ldi r20, 1
delay_loop_1:
	ldi r21, 105
delay_loop_2:
	ldi r22, 154
delay_loop_3:
	dec r22
	brne delay_loop_3
	dec r21
	brne delay_loop_2
	dec r20
	brne delay_loop_1
    ret

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
	ldi r16, 0b00100000
	out porta, r16
	
	ldi r16, 0b11011111
	out portc, r16
	ret

paddle:
	ldi r16, 0b10000000
	out porta, r16
	
	ldi r16, 0b11100011
	out portc, r16
	ret

