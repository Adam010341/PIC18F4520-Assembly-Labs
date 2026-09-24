    List p=18f4520 ;???PIC18F4520
    ;???PIC18F
    #include<p18f4520.inc>
        CONFIG OSC = INTIO67
        CONFIG WDT = OFF
        org 0x00 ; ???0x00???????
	
	movlw 0x04;WREG=3
	movwf 0x01;0x01=loop counter=3
	
	movlw 0x64 ;0x0A to WREG
	movlb 1 ;move 2 to bank select register
	movwf 0x40, 1;move 0x0A from WREG to 0x140
	
	movlw 0x50 ;0x0A to WREG
	movlb 1 ;move 2 to bank select register
	movwf 0x41, 1;move 0x0A from WREG to 0x140
	
	movlw 0x29 ;0x0A to WREG
	movlb 1 ;move 2 to bank select register
	movwf 0x42, 1;move 0x0A from WREG to 0x140
	
	LFSR 0, 0x140;indf0=adddr-3
	LFSR 1, 0x142;indf1=addr-1

	Loop:
	;FSR0=addr-3
	;FSR1=addr-1
	dcfsnz 0x01;skip if loop counter != 0
	GOTO terminate
	btfsc INDF1, 0; test first bit of addr-1
	GOTO odd
	movf INDF0,w; WREG=addr-3
	addwf PREINC0, w;WREG=WREG + add - 2
	addwf PREINC0, w; WREG = WREG + addr -1
	movwf PREINC0; addr=WREG
	DECF FSR0L, f;
	DECF FSR0L, f;
	incf FSR1L, f;
	GOTO Loop
	
	odd:
	;FSR0=addr-3
	;FSR1=addr-1
	movf INDF1,w; WREG=addr - 1
	subwf PREINC0, w; WREG = (addr -2)- WREG
	movwf PREINC1; addr=WREG
	GOTO Loop
    
	terminate:
	GOTO terminate
end