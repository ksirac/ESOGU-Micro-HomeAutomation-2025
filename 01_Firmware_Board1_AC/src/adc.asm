; ==============================================================================
; UNIVERSITY : ESKISEHIR OSMANGAZI UNIVERSITY
; DEPARTMENT : ELECTRICAL AND ELECTRONICS ENGINEERING
; PROJECT    : SMART HOME AUTOMATION SYSTEM
; BOARD      : BOARD 1 - AIR CONDITIONING CONTROLLER
; FILE       : adc.asm
; DESCRIPTION: ADC Temperature Reading and Fan Speed Measurement
; ==============================================================================

#include "config.inc"

; --- EXTERNAL VARIABLES ---
EXTRN temp_int, temp_frac, fan_speed
EXTRN delay_var, loop_cnt1, loop_cnt2
EXTRN _UART_Transmit
EXTRN _DELAY_50us, _DELAY_1Sec

PSECT code
GLOBAL _read_Temperature
GLOBAL _MEASURE_AND_SEND_SPEED

; ==============================================================================
; READ TEMPERATURE FROM LM35 SENSOR
; Converts ADC value to temperature with 0.5°C resolution
; ==============================================================================
_read_Temperature:
    CALL _DELAY_50us
    BSF ADCON0, 2
WAIT_ADC:
    BTFSC ADCON0, 2
    GOTO WAIT_ADC
    BSF STATUS, 5
    MOVF ADRESL, W
    BCF STATUS, 5
    MOVWF temp_int
    CLRF temp_frac
    BTFSC temp_int, 0
    MOVLW 5
    BTFSC temp_int, 0
    MOVWF temp_frac
    BCF STATUS, 0
    RRF temp_int, F
    RETURN

; ==============================================================================
; MEASURE FAN SPEED (RPS) USING TIMER0
; Counts pulses over 1 second window
; ==============================================================================
_MEASURE_AND_SEND_SPEED:
    CLRF TMR0
    CALL _DELAY_1Sec
    MOVF TMR0, W
    MOVWF fan_speed
    CALL _UART_Transmit
    RETURN
