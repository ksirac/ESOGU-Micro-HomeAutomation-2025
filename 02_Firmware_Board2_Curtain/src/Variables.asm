; ==============================================================================
; UNIVERSITY : ESKISEHIR OSMANGAZI UNIVERSITY
; DEPARTMENT : ELECTRICAL AND ELECTRONICS ENGINEERING
; PROJECT    : SMART CURTAIN CONTROL SYSTEM
; BOARD      : BOARD 2
; FILE       : Variables.asm
; DESCRIPTION: RAM Variable Definitions
; ==============================================================================

PSECT udata_bank0,space=1,class=BANK0

; --- SYSTEM VARIABLES ---
Loop_Counter:   DS 1        ; Main loop iteration counter
Dly1:           DS 1        ; Delay counter (primary)
Dly2:           DS 1        ; Delay counter (secondary)
Dly3:           DS 1        ; Delay counter (tertiary)
Temp:           DS 1        ; Temporary register

; --- SENSOR VARIABLES ---
Temp_H:         DS 1        ; Temperature reading
Pres_H:         DS 1        ; Atmospheric pressure
LDR_Val:        DS 1        ; Light sensor ADC value
Target:         DS 1        ; Target motor position (0-200)
Position:       DS 1        ; Current motor position (0-200)
Step_Count:     DS 1        ; Stepper motor phase counter

; --- CURTAIN CONTROL VARIABLES ---
Percent_Val:    DS 1        ; Curtain opening percentage
Auto_Flag:      DS 1        ; Control mode: 0=Pot, 1=LDR, 2=GUI

; --- LCD VARIABLES ---
Calc_Var:       DS 1        ; Arithmetic temporary
Digit_Var:      DS 1        ; BCD digit counter
Temp_Var:       DS 1        ; LCD data temporary
Temp_L:         DS 1        ; LCD nibble temporary
Rx_Data:        DS 1        ; UART receive buffer
