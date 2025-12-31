; ==============================================================================
; UNIVERSITY : ESKISEHIR OSMANGAZI UNIVERSITY
; DEPARTMENT : ELECTRICAL AND ELECTRONICS ENGINEERING
; PROJECT    : SMART CURTAIN CONTROL SYSTEM
; BOARD      : BOARD 2
; FILE       : Utils.asm
; DESCRIPTION: Utility Delay Routines for ADC, LCD, and Motor Timing
; ==============================================================================

Wait_Short:
    ; Short delay (~120us @ 20MHz)
    movlw   200
    movwf   Dly1
KL: decfsz  Dly1, f
    goto    KL
    return

Wait_Long:
    ; Long delay (~25ms @ 20MHz)
    movlw   100
    movwf   Dly1
U1: movlw   255
    movwf   Dly2
U2: decfsz  Dly2, f
    goto    U2
    decfsz  Dly1, f
    goto    U1
    return

Wait_Meas:
    ; Measurement delay
    movlw   50
    movwf   Dly1
    movlw   50
    movwf   Dly2
ML: decfsz  Dly2, f
    goto    ML
    decfsz  Dly1, f
    goto    Wait_Meas
    return

Wait_Motor:
    ; Motor step delay
    movlw   40
    movwf   Dly1
M1: movlw   50
    movwf   Dly2
M2: decfsz  Dly2, f
    goto    M2
    decfsz  Dly1, f
    goto    M1
    return
