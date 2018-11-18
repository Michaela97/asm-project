;.def temp = r16


init:
    ldi		r16, 0x00
	out		ddrg, r16	    ; set port C to input
	ldi		r16, 0xff
	;out     portc, r16      ; enable internal pull-up resistors on port C
    out		ddra, r16	    ; set port A to output
    ldi     r17, 1          ; init counter

	
main:
	
	call button ;read button to r19, 0xff if HIGH
	call led ;read from r19 and do the led
	

    rjmp main

led:
	ldi r16, 0xff
	cpse r19, r16 
	call ledoff
	ldi r16, 0x00
	cpse r19, r16
	call ledon
	ret 

ledon: ; fun for turning the led on on port A (22-27 on the arduino)
	ldi r16, 0xff
	out porta, r16
	ret

ledoff: ; fun for turning the led off on port A (22-27 on the arduino)
	ldi r16, 0x00
	out porta, r16
	ret

button:
	in r19, PINC ; read from button on PINC (37) to r19
	ret

