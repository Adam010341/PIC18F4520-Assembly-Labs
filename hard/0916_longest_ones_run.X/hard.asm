List p=18f4520 ;???PIC18F4520
    ;???PIC18F
    #include<p18f4520.inc>
        CONFIG OSC = INTIO67
        CONFIG WDT = OFF
        org 0x00 ; ???0x00???????

	movlw b'11111111'
	movwf 0x00
	movwf 0x05
	;initialize
	
	;0x00=input
	;0x10=max
	;0x02=ones counter
	;0x03=loop counter
	;0x04=8
	movlw 0x08
	movwf 0x04
	
	loop:
	movlw  0x08
	cpfseq 0x03
	    GOTO mainloop
	GOTO evaluate
	
	mainloop:
	INCF 0x03
	BTFSS 0x05,0
	GOTO evaluate
	incf 0x02
	RRNCF 0x05
	GOTO loop
	
	evaluate:
	movf 0x02, w
	cpfsgt 0x10
	movwf 0x10
	CLRF 0x02
	movlw 0x08
	cpfseq 0x03
	    GOTO continue_loop
	GOTO terminate
	
	continue_loop:
	RRNCF 0x05
	GOTO loop
	
	terminate:
	GOTO terminate
    end