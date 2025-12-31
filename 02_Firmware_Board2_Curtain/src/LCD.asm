; ==============================================================================
; UNIVERSITY : ESKISEHIR OSMANGAZI UNIVERSITY
; DEPARTMENT : ELECTRICAL AND ELECTRONICS ENGINEERING
; PROJECT    : SMART CURTAIN CONTROL SYSTEM
; BOARD      : BOARD 2
; FILE       : LCD.asm
; DESCRIPTION: LCD Display Driver (16x2, 4-bit mode)
; ==============================================================================

LCD_Init:
    BANKSEL TRISD
    clrf    TRISD
    BANKSEL PORTD
    clrf    PORTD
    
    call    Wait_Long
    
    ; Force Reset Sequence
    movlw   0x03
    call    Nibble_Direct
    call    Wait_Long
    movlw   0x03
    call    Nibble_Direct
    call    Wait_Long
    movlw   0x03
    call    Nibble_Direct
    call    Wait_Short
    movlw   0x02
    call    Nibble_Direct
    call    Wait_Short
    
    ; LCD Configuration
    movlw   0x28
    call    Command
    movlw   0x0C
    call    Command
    movlw   0x06
    call    Command
    movlw   0x01
    call    Command
    call    Wait_Long
    return

LCD_Clear:
    movlw   0x01
    call    Command
    call    Wait_Long
    return

LCD_Print_Full:
    ; Line 1: Fixed Temperature and Pressure
    movlw   0x80
    call    Command
    
    ; Temperature: "+25.0Â°C"
    movlw   '+'
    call    Data
    movlw   '2'
    call    Data
    movlw   '5'
    call    Data
    movlw   '.'
    call    Data
    movlw   '0'
    call    Data
    movlw   0xDF
    call    Data
    movlw   'C'
    call    Data
    
    movlw   ' '
    call    Data
    
    ; Pressure: "1026hPa"
    movlw   '1'
    call    Data
    movlw   '0'
    call    Data
    movlw   '2'
    call    Data
    movlw   '6'
    call    Data
    movlw   'h'
    call    Data
    movlw   'P'
    call    Data
    movlw   'a'
    call    Data

    ; Line 2: Live LDR and Curtain Values
    movlw   0xC0
    call    Command
    
    ; LDR Value
    BANKSEL LDR_Val
    movf    LDR_Val, w
    call    Print_Decimal
    
    movlw   'L'
    call    Data
    movlw   'u'
    call    Data
    movlw   'x'
    call    Data
    movlw   ' '
    call    Data
    movlw   ' '
    call    Data

    ; Curtain Percentage
    BANKSEL Percent_Val
    movf    Percent_Val, w
    call    Print_Decimal
    
    movlw   '%'
    call    Data
    return

; --- HELPER FUNCTIONS ---
Print_Decimal:
    BANKSEL Calc_Var
    movwf   Calc_Var
    
    ; Hundreds
    clrf    Digit_Var
Calc_100:
    movlw   100
    subwf   Calc_Var, w
    btfss   STATUS, 0
    goto    Print_100
    movwf   Calc_Var
    incf    Digit_Var, f
    goto    Calc_100
Print_100:
    movf    Digit_Var, w
    addlw   '0'
    call    Data
    
    ; Tens
    clrf    Digit_Var
Calc_10:
    movlw   10
    subwf   Calc_Var, w
    btfss   STATUS, 0
    goto    Print_10
    movwf   Calc_Var
    incf    Digit_Var, f
    goto    Calc_10
Print_10:
    movf    Digit_Var, w
    addlw   '0'
    call    Data
    
    ; Units
    movf    Calc_Var, w
    addlw   '0'
    call    Data
    return

; --- LCD DRIVERS ---
Command:
    BANKSEL Temp_Var
    movwf   Temp_Var
    BANKSEL PORTD
    bcf     PORTD, 2
    goto    Send
Data:
    BANKSEL Temp_Var
    movwf   Temp_Var
    BANKSEL PORTD
    bsf     PORTD, 2
Send:
    BANKSEL Temp_Var
    movf    Temp_Var, w
    andlw   0xF0
    call    Nibble_Out
    BANKSEL Temp_Var
    swapf   Temp_Var, w
    andlw   0xF0
    call    Nibble_Out
    return

Nibble_Out:
    movwf   Temp_L
    BANKSEL PORTD
    movf    PORTD, w
    andlw   0x0F
    iorwf   Temp_L, w
    movwf   PORTD
    bsf     PORTD, 3
    call    Wait_Short
    bcf     PORTD, 3
    return

Nibble_Direct:
    movwf   Temp_L
    swapf   Temp_L, w
    andlw   0xF0
    call    Nibble_Out
    return
