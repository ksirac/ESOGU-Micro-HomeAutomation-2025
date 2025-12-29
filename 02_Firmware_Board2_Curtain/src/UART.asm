; ==============================================================================
; UNIVERSITY : ESKISEHIR OSMANGAZI UNIVERSITY
; DEPARTMENT : ELECTRICAL AND ELECTRONICS ENGINEERING
; LESSON     : INTRODUCTION TO MICROCOMPUTERS
; PROJECT    : SMART CURTAIN CONTROL SYSTEM
; BOARD      : BOARD 2
; AUTHOR     : CENGIZHAN GISI
; FILE       : UART.asm
; DESCRIPTION: This file handles Serial Communication. It listens for commands
;              (Table 2.2.6) and sends back system status (Temp, Press, Curtain).
; ==============================================================================

UART_Handler:
    BANKSEL PIR1
    btfss   PIR1, 5         ; Check RCIF flag (Data received?)
    return                  ; No data, return

    ; Data Received
    BANKSEL RCREG
    movf    RCREG, w        ; Read received data
    BANKSEL Rx_Data
    movwf   Rx_Data

    ; --- DECODE HEX COMMANDS ---
    ; 0x01: Get Curtain Low Byte
    movf    Rx_Data, w           
    xorlw   0x01               ;If a match is found, the bits in the STATUS register are checked, and the appropriate response subroutine is selected.
    btfsc   STATUS, 2          
    goto    Ans_Zero

    ; 0x02: Get Curtain High Byte (Percentage)
    movf    Rx_Data, w
    xorlw   0x02
    btfsc   STATUS, 2
    goto    Ans_Curtain

    ; 0x03: Get Temp Low Byte
    movf    Rx_Data, w
    xorlw   0x03
    btfsc   STATUS, 2
    goto    Ans_Zero

    ; 0x04: Get Temp High Byte
    movf    Rx_Data, w
    xorlw   0x04
    btfsc   STATUS, 2
    goto    Ans_Temp

    ; 0x05: Get Pressure Low Byte
    movf    Rx_Data, w
    xorlw   0x05
    btfsc   STATUS, 2
    goto    Ans_Pres_L

    ; 0x06: Get Pressure High Byte
    movf    Rx_Data, w
    xorlw   0x06
    btfsc   STATUS, 2
    goto    Ans_Pres_H

    ; 0x07: Get Light Low Byte (LDR)
    movf    Rx_Data, w
    xorlw   0x07
    btfsc   STATUS, 2
    goto    Ans_Light

    ; 0x08: Get Light High Byte
    movf    Rx_Data, w
    xorlw   0x08
    btfsc   STATUS, 2
    goto    Ans_Zero

    return

; --- UART RESPONSE SUBROUTINES ---
Ans_Zero:
    movlw   0x00
    call    UART_Send_Raw
    return

Ans_Curtain:
;Curtain percentage is calculated.
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
;It sends the low byte of pressure. Here, a constant value of 0x02 is sent.
    movlw   0x02
    call    UART_Send_Raw
    return

Ans_Pres_H:
;It sends the high byte of pressure. Here, a fixed value of 0x04 is sent.
    movlw   0x04
    call    UART_Send_Raw
    return

Ans_Light:
;It sends the data received from the light sensor (LDR). The LDR data is stored in the LDR_Val variable.
    BANKSEL LDR_Val
    movf    LDR_Val, w
    call    UART_Send_Raw
    return

UART_Send_Raw:
    BANKSEL TXREG
    movwf   TXREG           ; Send W register to UART
    BANKSEL PIR1
WaitTX:
    btfss   PIR1, 4         ; Wait for transmission to complete
    goto    WaitTX
    BANKSEL PORTD           ; Restore Bank
    return


