; ==============================================================================
; UNIVERSITY : ESKISEHIR OSMANGAZI UNIVERSITY
; DEPARTMENT : ELECTRICAL AND ELECTRONICS ENGINEERING
; LESSON     : INTRODUCTION TO MICROCOMPUTERS
; PROJECT    : SMART CURTAIN CONTROL SYSTEM
; BOARD      : BOARD 2
; AUTHOR     : CENGIZHAN GISI
; FILE       : LCD.asm
; DESCRIPTION: This file contains LCD initialization and printing routines.
;              It formats the display according to Project Requirement [R2.2.5-1].
; ==============================================================================

LCD_Print_Full:
    ; Line 1: +25.0C  1026hPa
    movlw   0x80
    call    Command
    movlw   '+'
    call    Data
    movlw   '0'
    call    Data
    movlw   '0'
    call    Data
    movlw   '.'
    call    Data
    movlw   '0'
    call    Data
    movlw   0xDF            ; Degree Symbol
    call    Data
    movlw   'C'
    call    Data
    movlw   ' '
    call    Data
    movlw   ' '
    call    Data
    movlw   '0'
    call    Data
    movlw   '0'
    call    Data
    movlw   '0'
    call    Data
    movlw   '0'
    call    Data
    movlw   'h'
    call    Data
    movlw   'P'
    call    Data
    movlw   'a'
    call    Data
    
    ; Line 2: 00xxxLux  xx.0%
    movlw   0xC0
    call    Command
    movlw   '0'
    call    Data
    movlw   '0'
    call    Data
    BANKSEL LDR_Val
    movf    LDR_Val, w
    call    Print_3_Digits
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
    BANKSEL Percent_Val
    movf    Percent_Val, w
    sublw   100
    btfsc   STATUS, 2
    goto    Write_100_LCD
    movlw   ' '
    call    Data
    BANKSEL Percent_Val
    movf    Percent_Val, w
    call    Print_2_Digits
    goto    LCD_End
Write_100_LCD:
    movlw   '1'
    call    Data
    movlw   '0'
    call    Data
    movlw   '0'
    call    Data
LCD_End:
    movlw   '.'
    call    Data
    movlw   '0'
    call    Data
    movlw   '%'
    call    Data
    return

; --- LCD INITIALIZATION & DRIVERS ---
LCD_Init:
    call    Wait_Long
    movlw   0x03
    call    Nibble
    call    Wait_Long
    movlw   0x03
    call    Nibble
    call    Wait_Long
    movlw   0x03
    call    Nibble
    call    Wait_Long
    movlw   0x02
    call    Nibble
    call    Wait_Long
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
Command:
    bcf     PORTD, 2
    goto    Sender
Data:
    bsf     PORTD, 2
Sender:
    movwf   Temp
    swapf   Temp, w
    call    Nibble
    movf    Temp, w
    call    Nibble
    call    Wait_Short
    return
Nibble:
    andlw   0x0F
    movwf   Nibble_Hold
    swapf   Nibble_Hold, w
    movwf   Nibble_Hold
    movf    PORTD, w
    andlw   0x0F
    iorwf   Nibble_Hold, w
    movwf   PORTD
    bsf     PORTD, 3
    nop
    bcf     PORTD, 3
    return

; --- NUMBER PRINTING HELPERS ---
Print_3_Digits:
    movwf   Digit_One
    clrf    Digit_Hun
    clrf    Digit_Ten
L3_100: movlw 100
    subwf   Digit_One, w
    btfss   STATUS, 0
    goto    L3_10
    movwf   Digit_One
    incf    Digit_Hun, f
    goto    L3_100
L3_10: movlw 10
    subwf   Digit_One, w
    btfss   STATUS, 0
    goto    L3_1
    movwf   Digit_One
    incf    Digit_Ten, f
    goto    L3_10
L3_1: movf  Digit_Hun, w
    addlw   0x30
    call    Data
    movf    Digit_Ten, w
    addlw   0x30
    call    Data
    movf    Digit_One, w
    addlw   0x30
    call    Data
    return

Print_2_Digits:
    movwf   Digit_One
    clrf    Digit_Ten
L2_10: movlw 10
    subwf   Digit_One, w
    btfss   STATUS, 0
    goto    L2_1
    movwf   Digit_One
    incf    Digit_Ten, f
    goto    L2_10
L2_1: movf  Digit_Ten, w
    addlw   0x30
    call    Data
    movf    Digit_One, w
    addlw   0x30
    call    Data
    return


