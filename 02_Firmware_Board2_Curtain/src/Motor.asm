; ==============================================================================
; UNIVERSITY : ESKISEHIR OSMANGAZI UNIVERSITY
; DEPARTMENT : ELECTRICAL AND ELECTRONICS ENGINEERING
; PROJECT    : SMART CURTAIN CONTROL SYSTEM
; BOARD      : BOARD 2
; FILE       : Motor.asm
; DESCRIPTION: Stepper Motor Control Logic (4-phase unipolar)
; ==============================================================================

Motor_Handler:
    BANKSEL Position
    movf    Position, w
    subwf   Target, w
    
    btfsc   STATUS, 2
    goto    Motor_Stop
    btfsc   STATUS, 0
    goto    Open
    goto    Close

Open:
    ; Upper Limit Check
    movlw   255
    subwf   Position, w
    btfsc   STATUS, 0
    return
    
    incf    Position, f
    movlw   5
    movwf   Temp
Open_Loop:
    incf    Step_Count, f
    call    Drive_Motor
    decfsz  Temp, f
    goto    Open_Loop
    return

Close:
    ; Lower Limit Check
    movf    Position, f
    btfsc   STATUS, 2
    return
    
    decf    Position, f
    movlw   5
    movwf   Temp
Close_Loop:
    decf    Step_Count, f
    call    Drive_Motor
    decfsz  Temp, f
    goto    Close_Loop
    return

Motor_Stop:
    BANKSEL PORTB
    clrf    PORTB
    return

; --- STEPPER MOTOR DRIVER ---
Drive_Motor:
    movf    Step_Count, w
    andlw   0x03
    movwf   Step_Count
    movf    Step_Count, w
    xorlw   0
    btfsc   STATUS, 2
    goto    B0
    movf    Step_Count, w
    xorlw   1
    btfsc   STATUS, 2
    goto    B1
    movf    Step_Count, w
    xorlw   2
    btfsc   STATUS, 2
    goto    B2
    goto    B3
B0: movlw   0x01
    goto    BB
B1: movlw   0x02
    goto    BB
B2: movlw   0x04
    goto    BB
B3: movlw   0x08
BB: movwf   PORTB
    call    Wait_Motor
    return
