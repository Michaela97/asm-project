.equ array_start = 0x2ff            ; location of array in memory
.equ array_length = 9               ; length of array

start:
	ldi r16, 0xff
    out ddra, r16                   ; setting port A to be output

	ldi ZL, low(array_start)        ; loading low part of array location into Z pointer
	ldi ZH, high(array_start)       ; loading high part of array location into Z pointer

	clr r0
	ldi r17, 4						;number of rows for blocks.

init_blocks:                    
	ldi r16, 0b00000000				;columns in row which are lighting (0 = light on / 1 = light off)
	st Z+, r16                       ; storing column pattern in the position pointed to by the value in the Z pointer
	dec r17                         ; using a counter to keep track of the "number of block rows"
	brne init_blocks

init_ball:
	ldi r16, 0b11101111				;ball column pattern
	st Z+, r16
	ldi r16, 0b00000010				;ball row pattern
	st Z+, r16

init_paddle:
	ldi r16, 0b11000111				;paddle column pattern 
	st Z+, r16

init_vector:
	ldi r16, 0b00000010				;ball vector - x axis (100 = move left, 010 = stay at the same x position, 001=move right)
	st Z+, r16
	ldi r16, 0b00000010				;ball vector - y axis (10 = move up, 01 = move down)
	st Z, r16 

	
    ldi r16, 4                      ; the index of the value we would like to get is stored in r16
    call get_value_with_index       ; result will be saved in r16
    out porta, r16


end:
	rjmp end

get_value_with_index:
    ldi ZL, low(array_start)
    ldi ZH, high(array_start)
    add ZL, r16                     ; we should check for a carry out here!
    brcc no_carry
    inc ZH
no_carry:
    ld  r16, Z
    ret

	