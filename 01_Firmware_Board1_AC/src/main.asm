; ==============================================================================
; UNIVERSITY : ESKISEHIR OSMANGAZI UNIVERSITY
; DEPARTMENT : ELECTRICAL AND ELECTRONICS ENGINEERING
; PROJECT    : SMART HOME AUTOMATION SYSTEM
; BOARD      : BOARD 1 - AIR CONDITIONING CONTROLLER
; FILE       : main.asm
; DESCRIPTION: Main Program Entry Point with HVAC Control Logic
; ==============================================================================

#include "config.inc"

; --- VARIABLES (GLOBAL) ---
PSECT udata_bank0
GLOBAL entry_mode, entry_val, entry_count, desired_temp
GLOBAL key_prev, key_val, display_num, digit_tens, digit_ones
GLOBAL temp_int, temp_frac, fan_speed
GLOBAL uart_data, adc_counter, bounce_cnt, persist_cnt
GLOBAL delay_var, loop_cnt1, loop_cnt2, temp_var, mul_temp
GLOBAL adc_stable, control_state

; Control States
STATE_IDLE    EQU 0
STATE_HEATING EQU 1
STATE_COOLING EQU 2

entry_mode:   DS 1
entry_val:    DS 1
entry_count:  DS 1
desired_temp: DS 1
key_prev:     DS 1
key_val:      DS 1
display_num:  DS 1
digit_tens:   DS 1
digit_ones:   DS 1
temp_int:     DS 1
temp_frac:    DS 1
fan_speed:    DS 1
uart_data:    DS 1
adc_counter:  DS 1
bounce_cnt:   DS 1
persist_cnt:  DS 1
delay_var:    DS 1
loop_cnt1:    DS 1
loop_cnt2:    DS 1
temp_var:     DS 1
mul_temp:     DS 1
adc_stable:   DS 1
control_state: DS 1

; --- EXTERNAL DEPENDENCIES ---
EXTRN _init_UART, _UART_Check_Command
EXTRN _read_Temperature
EXTRN _PROCESS_KEY_MATRIX

GLOBAL init_System

; ==============================================================================
; RESET VECTOR
; ==============================================================================
PSECT resetVec, class=CODE, delta=2
resetVec:
    clrf    PCLATH
    goto    Start

; ==============================================================================
; MAIN PROGRAM CODE
; ==============================================================================
PSECT code, class=CODE, delta=2
GLOBAL _main

_main:
    GOTO Start

Start:
    CALL init_System
    CALL _init_UART
    
    ; Initialize Default Values
    MOVLW 25
    MOVWF desired_temp
    MOVWF temp_int
    CLRF entry_mode
    CLRF entry_val
    CLRF entry_count
    MOVLW KEY_NONE
    MOVWF key_prev
    CLRF adc_counter
    CLRF adc_stable
    CLRF control_state

LOOP:
    ; Display Mode Selection
    MOVF entry_mode, W
    BTFSS STATUS, 2
    GOTO USE_ENTRY_VAL
    MOVF temp_int, W
    MOVWF display_num
    MOVLW 100
    SUBWF display_num, W
    BTFSS STATUS, 0
    GOTO SET_DISPLAY
    MOVLW 99
    MOVWF display_num
    GOTO SET_DISPLAY
USE_ENTRY_VAL:
    MOVF entry_val, W
    MOVWF display_num
SET_DISPLAY:

    ; BCD Conversion
    MOVF display_num, W
    MOVWF digit_ones
    CLRF digit_tens
DIV_LOOP:
    MOVLW 10
    SUBWF digit_ones, W
    BTFSS STATUS, 0
    GOTO SCAN_START
    MOVWF digit_ones
    INCF digit_tens, F
    GOTO DIV_LOOP

SCAN_START:
    CALL _PROCESS_KEY_MATRIX
    MOVLW KEY_NONE
    MOVWF key_prev
    
    ; Periodic ADC Reading
    INCF adc_counter, F
    MOVLW 10
    SUBWF adc_counter, W
    BTFSS STATUS, 2
    GOTO CHECK_UART
    CLRF adc_counter
    CALL _read_Temperature
    CALL Auto_Control_Logic

CHECK_UART:
    BTFSC PIR1, 5
    CALL _UART_Check_Command
    GOTO LOOP

; ==============================================================================
; HVAC CONTROL LOGIC (Asymmetric Hysteresis)
; Start: ±2°C threshold, Stop: at target
; ==============================================================================
Auto_Control_Logic:
    ; Check if heating needed (temp <= desired - 2)
    MOVLW 2
    SUBWF desired_temp, W
    MOVWF temp_var
    MOVF temp_int, W
    SUBWF temp_var, W
    BTFSC STATUS, 0
    GOTO START_HEATING
    
    ; Check if cooling needed (temp >= desired + 2)
    MOVF desired_temp, W
    ADDLW 2
    SUBWF temp_int, W
    BTFSC STATUS, 0
    GOTO START_COOLING
    
    ; Check heating stop condition
    MOVLW STATE_HEATING
    SUBWF control_state, W
    BTFSS STATUS, 2
    GOTO CHECK_COOLING_STOP
    MOVF desired_temp, W
    SUBWF temp_int, W
    BTFSC STATUS, 0
    GOTO STOP_HEATING
    GOTO KEEP_STATE
    
CHECK_COOLING_STOP:
    MOVLW STATE_COOLING
    SUBWF control_state, W
    BTFSS STATUS, 2
    GOTO KEEP_STATE
    MOVF temp_int, W
    SUBWF desired_temp, W
    BTFSC STATUS, 0
    GOTO STOP_COOLING
    GOTO KEEP_STATE
    
START_HEATING:
    MOVLW STATE_HEATING
    MOVWF control_state
    BCF COOLER
    BSF HEATER
    RETURN
    
START_COOLING:
    MOVLW STATE_COOLING
    MOVWF control_state
    BCF HEATER
    BSF COOLER
    RETURN
    
STOP_HEATING:
    MOVLW STATE_IDLE
    MOVWF control_state
    BCF HEATER
    RETURN
    
STOP_COOLING:
    MOVLW STATE_IDLE
    MOVWF control_state
    BCF COOLER
    RETURN
    
KEEP_STATE:
    RETURN

; ==============================================================================
; SYSTEM INITIALIZATION
; ==============================================================================
init_System:
    BSF STATUS, 5
    MOVLW 0xF0
    MOVWF TRISB
    BCF OPTION_REG, 7
    MOVLW 0xFF
    MOVWF TRISA
    CLRF TRISE
    MOVLW 0xC0
    MOVWF TRISC
    CLRF TRISD
    MOVLW 0x8E
    MOVWF ADCON1
    BCF STATUS, 5
    MOVLW 0x41
    MOVWF ADCON0
    CLRF PORTB
    CLRF PORTC
    CLRF PORTD
    CLRF PORTE
    RETURN
