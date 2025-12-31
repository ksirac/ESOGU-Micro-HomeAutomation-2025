; ==============================================================================
; UNIVERSITY : ESKISEHIR OSMANGAZI UNIVERSITY
; DEPARTMENT : ELECTRICAL AND ELECTRONICS ENGINEERING
; PROJECT    : SMART HOME AUTOMATION SYSTEM
; BOARD      : BOARD 1 - AIR CONDITIONING CONTROLLER
; FILE       : uart.asm
; DESCRIPTION: UART Communication with Remote Temperature Control
; COMMANDS   : 0x03-0x06 (Read) | 0x20 (Write)
; ==============================================================================

#include "config.inc"

; --- EXTERNAL VARIABLES ---
EXTRN uart_data, temp_int, temp_frac, fan_speed, desired_temp
EXTRN _MEASURE_AND_SEND_SPEED

PSECT code
GLOBAL _init_UART
GLOBAL _UART_Check_Command
GLOBAL _UART_Transmit

; ==============================================================================
; UART INITIALIZATION (9600 baud @ 20MHz)
; ==============================================================================
_init_UART:
    BSF STATUS, 5
    MOVLW 25
    MOVWF SPBRG
    MOVLW 0x24
    MOVWF TXSTA
    BCF STATUS, 5
    MOVLW 0x90
    MOVWF RCSTA
    RETURN

; ==============================================================================
; UART TRANSMIT (Sends byte in W register)
; ==============================================================================
_UART_Transmit:
    BSF STATUS, 5
WAIT_TX:
    BTFSS TXSTA, 1
    GOTO WAIT_TX
    BCF STATUS, 5
    MOVWF TXREG
    RETURN

; ==============================================================================
; UART COMMAND PROCESSOR
; ==============================================================================
_UART_Check_Command:
    MOVF RCREG, W
    MOVWF uart_data
    
    ; --- READ COMMANDS ---
    
    MOVF uart_data, W
    SUBLW 0x04
    BTFSC STATUS, 2
    GOTO SEND_TEMP_INT
    
    MOVF uart_data, W
    SUBLW 0x03
    BTFSC STATUS, 2
    GOTO SEND_TEMP_FRAC
    
    MOVF uart_data, W
    SUBLW 0x05
    BTFSC STATUS, 2
    GOTO MEASURE_JUMP

    MOVF uart_data, W
    SUBLW 0x06
    BTFSC STATUS, 2
    GOTO SEND_DESIRED_TEMP

    ; --- WRITE COMMANDS ---
    
    MOVF uart_data, W
    SUBLW 0x20
    BTFSC STATUS, 2
    GOTO SET_DESIRED_TEMP

    RETURN

MEASURE_JUMP:
    GOTO _MEASURE_AND_SEND_SPEED

SEND_TEMP_INT:
    MOVF temp_int, W
    CALL _UART_Transmit
    RETURN

SEND_TEMP_FRAC:
    MOVF temp_frac, W
    CALL _UART_Transmit
    RETURN

SEND_DESIRED_TEMP:
    MOVF desired_temp, W
    CALL _UART_Transmit
    RETURN

; ==============================================================================
; SET DESIRED TEMPERATURE (0x20 + temp_value)
; Valid range: 10-50°C
; Response: 0xAA (success) or 0xFF (invalid)
; ==============================================================================
SET_DESIRED_TEMP:
    ; Wait for temperature value byte
WAIT_NEXT_BYTE:
    BTFSS PIR1, 5
    GOTO WAIT_NEXT_BYTE
    
    MOVF RCREG, W
    MOVWF uart_data
    
    ; Validate minimum (10°C)
    MOVLW 10
    SUBWF uart_data, W
    BTFSS STATUS, 0
    GOTO SET_INVALID
    
    ; Validate maximum (50°C)
    MOVLW 51
    SUBWF uart_data, W
    BTFSC STATUS, 0
    GOTO SET_INVALID
    
    ; Store valid value
    MOVF uart_data, W
    MOVWF desired_temp
    
    ; Send acknowledgment
    MOVLW 0xAA
    CALL _UART_Transmit
    RETURN

SET_INVALID:
    ; Send error code
    MOVLW 0xFF
    CALL _UART_Transmit
    RETURN
