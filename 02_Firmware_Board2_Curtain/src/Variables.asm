; ==============================================================================
; UNIVERSITY : ESKISEHIR OSMANGAZI UNIVERSITY
; DEPARTMENT : ELECTRICAL AND ELECTRONICS ENGINEERING
; LESSON     : INTRODUCTION TO MICROCOMPUTERS
; PROJECT    : SMART CURTAIN CONTROL SYSTEM
; BOARD      : BOARD 2
; AUTHOR     : ONUR KAPANCI
; FILE       : Variables.asm
; DESCRIPTION: This file contains the memory allocation and variable definitions
;              used throughout the project (Bank 0).
; ==============================================================================

PSECT udata_bank0,class=BANK0,space=1
Target:         DS 1    ; Desired curtain position (0-200) from Potentiometer
Position:       DS 1    ; Current curtain position (0-200) tracked by motor steps
Step_Count:     DS 1    ; Step counter for motor phase sequence
LDR_Val:        DS 1    ; Light intensity value read from LDR
Temp:           DS 1    ; Temporary variable for general calculations
Dly1:           DS 1    ; Delay loop variable 1
Dly2:           DS 1    ; Delay loop variable 2
Dly3:           DS 1    ; Delay loop variable 3
Nibble_Hold:    DS 1    ; Variable to hold 4-bit data for LCD
Digit_Hun:      DS 1    ; Hundreds digit for display
Digit_Ten:      DS 1    ; Tens digit for display
Digit_One:      DS 1    ; Ones digit for display
Percent_Val:    DS 1    ; Curtain position converted to percentage (0-100%)
; -- Sensor Variables --
Temp_H:         DS 1    ; Raw Temperature High Byte (from BMP180)
Pres_H:         DS 1    ; Raw Pressure High Byte (from BMP180)
Loop_Counter:   DS 1    ; Counter to slow down sensor updates
Rx_Data:        DS 1    ; Data received via UART


