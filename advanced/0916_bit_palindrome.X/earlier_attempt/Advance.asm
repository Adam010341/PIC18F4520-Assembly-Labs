List p=18f4520 ;???PIC18F4520
    ;???PIC18F
    #include<p18f4520.inc>
        CONFIG OSC = INTIO67
        CONFIG WDT = OFF
        org 0x00 ; ???0x00???????

	initial:
	movlw b'11010010'
	movwf 0x00
	;load the sequence to 0x00
	
	movlw 0x07
	CLRF 0x01
	CLRF 0x10
	
	loop:
	cpfseq 0x01
	;skip if 0x01==7 (working register)
	GOTO mainLoop
	GOTO terminate
    
	mainLoop:
	btfss 0x00, 0
	GOTO isZero
	INCF 0x10, f
	;increment 0x10
	RLNCF 0x10
	;left shift 0x10
	RRNCF 0x00
	;right shift 0x00
	INCF 0x01, f
	;increment 0x01
	GOTO mainLoop
	
	isZero:
	RLNCF 0x10
	;left shift 0x10
	RRNCF 0x00
	;right shift 0x00
	INCF 0x01, f
	;increment 0x01
	GOTO mainLoop
	
	terminate:
	movf 0x10, W
	;move 0x10 to working register
	cpfseq 0x00
	GOTO notEqual
	GOTO Equal
	
	Equal:
	movlw 0xFF
	movwf 0x11
	GOTO terminate2
    
	notEqual:
	movlw 0x00
	movwf 0x11
	GOTO terminate2
    
	terminate2:
	GOTO terminate2
    end