; ==============================================================================
; UNIVERSITY : ESKISEHIR OSMANGAZI UNIVERSITY
; DEPARTMENT : ELECTRICAL AND ELECTRONICS ENGINEERING
; LESSON     : INTRODUCTION TO MICROCOMPUTERS
; PROJECT    : SMART CURTAIN CONTROL SYSTEM
; BOARD      : BOARD 2
; AUTHOR     : CENGIZHAN GISI
; FILE       : Utils.asm
; DESCRIPTION: This file contains general utility and delay routines used
;              for timing (ADC, LCD, Motor stepping).
; ==============================================================================

Wait_Short:
    movlw   10
    movwf   Dly1
KL: decfsz  Dly1, f
    goto    KL
    return

Wait_Long:
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
    movlw   40
    movwf   Dly1
M1: movlw   50
    movwf   Dly2
M2: decfsz  Dly2, f
    goto    M2
    decfsz  Dly1, f
    goto    M1
    return


