; ==============================================================================
; UNIVERSITY : ESKISEHIR OSMANGAZI UNIVERSITY
; DEPARTMENT : ELECTRICAL AND ELECTRONICS ENGINEERING
; LESSON     : INTRODUCTION TO MICROCOMPUTERS
; PROJECT    : SMART CURTAIN CONTROL SYSTEM
; BOARD      : BOARD 2
; AUTHOR     : CENGIZHAN GISI
; FILE       : Sensors.asm
; DESCRIPTION: This file handles I2C communication with BMP180 sensor and
;              performs percentage calculations for the curtain position.
; ==============================================================================

; --- SENSOR MODULE (I2C) ---
Read_Sensors:
    ; Read Temp
    call    I2C_Start
    movlw   0xEE
    call    I2C_Write
    movlw   0xF4
    call    I2C_Write
    movlw   0x2E
    call    I2C_Write
    call    I2C_Stop
    call    Wait_Short
    
    call    I2C_Start
    movlw   0xEE
    call    I2C_Write
    movlw   0xF6
    call    I2C_Write
    call    I2C_RepStart
    movlw   0xEF
    call    I2C_Write
    call    I2C_Read
    movwf   Temp_H
    call    I2C_Nack
    call    I2C_Stop
    
    ; Read Pressure
    call    I2C_Start
    movlw   0xEE
    call    I2C_Write
    movlw   0xF4
    call    I2C_Write
    movlw   0x34
    call    I2C_Write
    call    I2C_Stop
    call    Wait_Short
    
    call    I2C_Start
    movlw   0xEE
    call    I2C_Write
    movlw   0xF6
    call    I2C_Write
    call    I2C_RepStart
    movlw   0xEF
    call    I2C_Write
    call    I2C_Read
    movwf   Pres_H
    call    I2C_Nack
    call    I2C_Stop
    return

; --- PERCENTAGE CALCULATOR ---
Calc_Percent:
    BANKSEL Position
    bcf     STATUS, 0
    rrf     Position, w
    BANKSEL Percent_Val
    movwf   Percent_Val
    movlw   100
    subwf   Percent_Val, w
    btfsc   STATUS, 0
    goto    Clamp
    return
Clamp:
    movlw   100
    movwf   Percent_Val
    return

; --- I2C DRIVERS ---
I2C_Start:
    BANKSEL SSPCON2
    bsf     SSPCON2,0
    goto    GW
I2C_RepStart:
    BANKSEL SSPCON2
    bsf     SSPCON2,1
    goto    GW
I2C_Stop:
    BANKSEL SSPCON2
    bsf     SSPCON2,2
    goto    GW
I2C_Write:
    BANKSEL SSPBUF
    movwf   SSPBUF
    goto    GW
I2C_Read:
    BANKSEL SSPCON2
    bsf     SSPCON2,3
    call    GW
    BANKSEL SSPBUF
    movf    SSPBUF,w
    return
I2C_Nack:
    BANKSEL SSPCON2
    bsf     SSPCON2,5
    bsf     SSPCON2,4
    goto    GW
GW:
    BANKSEL PIR1
    movlw   255
    movwf   Dly2
WL: btfsc   PIR1,3
    goto    WD
    decfsz  Dly2,f
    goto    WL
    bcf     PIR1,3
    return
WD: bcf     PIR1,3
    return


