List p=18f4520 ;???PIC18F4520
    ;???PIC18F
    #include<p18f4520.inc>
        CONFIG OSC = INTIO67
        CONFIG WDT = OFF
        org 0x00 ; ???0x00???????
	
	movlw 0x06;
	movwf 0x01;0x01=counter A=6
	movlw 0x05;
	movwf 0x02;0x02=counter B=5
	movlw 0x11;
	movwf 0x03;0x03=counter ans
	
	LFSR 0, 0x200; start of sequence A
	movlw 0x0F
	movwf POSTINC0
	movlw 0x21
	movwf POSTINC0
	movlw 0x35
	movwf POSTINC0
	movlw 0x50
	movwf POSTINC0
	movlw 0x88
	movwf POSTINC0
	movlw 0xB4
	movwf INDF0; FSR0L=end of sequence A
	
	LFSR 1, 0x210; start of sequence B
	movlw 0x10
	movwf POSTINC1
	movlw 0x28
	movwf POSTINC1
	movlw 0x44
	movwf POSTINC1
	movlw 0x95
	movwf POSTINC1
	movlw 0xFD
	movwf POSTINC1
	
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LFSR 0, 0x200;start of sequence A
	LFSR 1, 0x210;start of sequence B
	LFSR 2, 0x230; start of temp (reverse later)
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	merge:
	movf INDF0, W;move sequence A head ptr to WREG
	cpfsgt INDF1; Skip if WREG<sequence B
	GOTO appendB; 
	movff POSTINC0, POSTINC2;append A to temp
	
	dcfsnz 0x01 ;check if counter A == 0, if yes, go to fillWithB
	GOTO fillWithB
	GOTO merge
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	appendB:
	movff POSTINC1, POSTINC2;;append B to temp
	dcfsnz 0x02 ;check if counter B == 0, if yes, go to fillWithA
	GOTO fillWithA
	GOTO merge;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	fillWithA:
	movff POSTINC0, POSTINC2;append A to temp
	dcfsnz 0x01 ;check if counter A == 0, if yes, go to reverse
	GOTO reverse
	GOTO fillWithA
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	fillWithB:
	movff POSTINC1, POSTINC2;append B to temp
	dcfsnz 0x02 ;check if counter A == 0, if yes, go to reverse
	GOTO reverse
	GOTO fillWithB
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	reverse:
	decf FSR2L;FSR2 = temp tail 
	LFSR 1, 0x220;FSR = ans head
	reverseLoop:
	movff INDF2, POSTINC1;
	decf FSR2L;
	dcfsnz 0x03 ;check if counter ans == 0, if yes, go to terminate
	GOTO terminate;
	GOTO reverseLoop
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	terminate:
	GOTO terminate
    end