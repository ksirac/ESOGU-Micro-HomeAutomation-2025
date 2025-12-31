; ==============================================================================
; UNIVERSITY : ESKISEHIR OSMANGAZI UNIVERSITY
; DEPARTMENT : ELECTRICAL AND ELECTRONICS ENGINEERING
; PROJECT    : SMART CURTAIN CONTROL SYSTEM
; BOARD      : BOARD 2
; FILE       : Sensors.asm
; DESCRIPTION: Sensor Reading and Percentage Calculation
; ==============================================================================

Read_Sensors:
    ; Temperature and Pressure are fixed values (BMP180 not implemented)
    BANKSEL Temp_H
    clrf    Temp_H
    
    BANKSEL Pres_H
    clrf    Pres_H
    
    ; LDR value is read in Main.asm from ADRESH
    return

; ==============================================================================
; CURTAIN PERCENTAGE CALCULATION
; Converts motor position (0-200) to percentage (0-100%)
; ==============================================================================
Calc_Percent:
    BANKSEL Position
    movf    Position, w
    BANKSEL Calc_Var
    movwf   Calc_Var
    bcf     STATUS, 0
    rrf     Calc_Var, w
    BANKSEL Percent_Val
    movwf   Percent_Val
    return
