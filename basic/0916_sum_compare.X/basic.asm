List p=18f4520 ;???PIC18F4520
    ;???PIC18F
    #include<p18f4520.inc>
        CONFIG OSC = INTIO67
        CONFIG WDT = OFF
        org 0x00 ; 
	
	initial:
	MOVLW 0x07 ;x1 val
	MOVWF 0x00
	;move 0x12 to 0x00
	
	MOVLW 0x09 ;x2 val
	MOVWF 0x01
	;move 0x08 to 0x01
	
	movf 0x00, w
	addwf 0x01, w
	movwf 0x10
	;A1=x1+x2
	
	MOVLW 0x16 ;y1 val
	MOVWF 0x02
	;move 0x0A to 0x02
	
	MOVLW 0x09  ;y2 val
	MOVWF 0x03
	;move 0x05 to 0x03
	
	movf 0x02, w
	addwf 0x03, w
	movwf 0x11
	;A2=y1+y2
	
	
	movf 0x10, w
	;move 0x10 to WREG
	
	cpfseq 0x11
	GOTO LessOrMore
	movlw 0x22
	movwf 0x20
	GOTO terminate
	
	LessOrMore:
	cpfsgt 0x11
	GOTO isMore
	movlw 0x33
	movwf 0x20
	GOTO terminate
	
	isMore:
    	movlw 0x11
	movwf 0x20
    
	terminate:
	GOTO terminate
end
	