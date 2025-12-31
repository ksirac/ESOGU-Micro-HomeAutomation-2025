; ==============================================================================
; UNIVERSITY : ESKISEHIR OSMANGAZI UNIVERSITY
; DEPARTMENT : ELECTRICAL AND ELECTRONICS ENGINEERING
; PROJECT    : SMART CURTAIN CONTROL SYSTEM
; BOARD      : BOARD 2
; FILE       : UART.asm
; DESCRIPTION: Serial Communication Handler with Remote Control Protocol
; COMMANDS   : 0x01-0x08 (Read) | 0x10-0x13 (Control)
; ==============================================================================

UART_Handler:
    BANKSEL PIR1
    btfss   PIR1, 5
    return

    BANKSEL RCREG
    movf    RCREG, w
    BANKSEL Rx_Data
    movwf   Rx_Data

    ; --- READ COMMANDS ---
    
    movf    Rx_Data, w           
    xorlw   0x01
    btfsc   STATUS, 2          
    goto    Ans_Zero

    movf    Rx_Data, w
    xorlw   0x02
    btfsc   STATUS, 2
    goto    Ans_Curtain

    movf    Rx_Data, w
    xorlw   0x03
    btfsc   STATUS, 2
    goto    Ans_Zero

    movf    Rx_Data, w
    xorlw   0x04
    btfsc   STATUS, 2
    goto    Ans_Temp

    movf    Rx_Data, w
    xorlw   0x05
    btfsc   STATUS, 2
    goto    Ans_Pres_L

    movf    Rx_Data, w
    xorlw   0x06
    btfsc   STATUS, 2
    goto    Ans_Pres_H

    movf    Rx_Data, w
    xorlw   0x07
    btfsc   STATUS, 2
    goto    Ans_Light

    movf    Rx_Data, w
    xorlw   0x08
    btfsc   STATUS, 2
    goto    Ans_Zero

    ; --- CONTROL COMMANDS ---
    
    movf    Rx_Data, w
    xorlw   0x10
    btfsc   STATUS, 2
    goto    Cmd_Open

    movf    Rx_Data, w
    xorlw   0x11
    btfsc   STATUS, 2
    goto    Cmd_Close

    movf    Rx_Data, w
    xorlw   0x12
    btfsc   STATUS, 2
    goto    Cmd_Auto

    movf    Rx_Data, w
    xorlw   0x13
    btfsc   STATUS, 2
    goto    Cmd_SetPosition

    return

; --- READ RESPONSES ---
Ans_Zero:
    movlw   0x00
    call    UART_Send_Raw
    return

Ans_Curtain:
    call    Calc_Percent
    BANKSEL Percent_Val
    movf    Percent_Val, w
    call    UART_Send_Raw
    return

Ans_Temp:
    movlw   25
    call    UART_Send_Raw
    return

Ans_Pres_L:
    movlw   0x02
    call    UART_Send_Raw
    return

Ans_Pres_H:
    movlw   0x04
    call    UART_Send_Raw
    return

Ans_Light:
    BANKSEL LDR_Val
    movf    LDR_Val, w
    call    UART_Send_Raw
    return

; --- CONTROL HANDLERS ---
Cmd_Open:
    BANKSEL Auto_Flag
    clrf    Auto_Flag
    BANKSEL Target
    clrf    Target
    movlw   0xAA
    call    UART_Send_Raw
    return

Cmd_Close:
    BANKSEL Auto_Flag
    clrf    Auto_Flag
    BANKSEL Target
    movlw   200
    movwf   Target
    movlw   0xAA
    call    UART_Send_Raw
    return

Cmd_Auto:
    BANKSEL Auto_Flag
    movlw   1
    movwf   Auto_Flag
    movlw   0xAA
    call    UART_Send_Raw
    return

Cmd_SetPosition:
    BANKSEL Auto_Flag
    movlw   2
    movwf   Auto_Flag
    
Wait_Pos_Byte:
    BANKSEL PIR1
    btfss   PIR1, 5
    goto    Wait_Pos_Byte
    
    BANKSEL RCREG
    movf    RCREG, w
    
    BANKSEL Target
    movwf   Target
    
    movlw   201
    subwf   Target, w
    btfss   STATUS, 0
    goto    SetPos_OK
    movlw   200
    movwf   Target
    
SetPos_OK:
    movlw   0xAA
    call    UART_Send_Raw
    return

; --- UART TRANSMIT ---
UART_Send_Raw:
    BANKSEL TXREG
    movwf   TXREG
    BANKSEL PIR1
WaitTX:
    btfss   PIR1, 4
    goto    WaitTX
    BANKSEL PORTD
    return
