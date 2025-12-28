; ==============================================================================
; UNIVERSITY : ESKISEHIR OSMANGAZI UNIVERSITY
; DEPARTMENT : ELECTRICAL AND ELECTRONICS ENGINEERING
; LESSON     : INTRODUCTION TO MICROCOMPUTERS
; PROJECT    : SMART CURTAIN CONTROL SYSTEM
; BOARD      : BOARD 2
; AUTHOR     : CENGIZHAN GISI
; FILE       : Motor.asm
; DESCRIPTION: This file contains the logic for controlling the Stepper Motor.
;              It compares Target vs Position and drives the motor coils.
; ==============================================================================

; --- MOTOR CONTROL LOGIC ---
Motor_Handler:
    BANKSEL Position
    movf    Position, w
    subwf   Target, w       ; Calculate (Target - Position)
    
    btfsc   STATUS, 2       ; If Zero (Target == Position), Stop
    goto    Motor_Stop
    btfsc   STATUS, 0       ; If Carry (Target > Position), Open
    goto    Open
    goto    Close

Open:
    ; Safety Check: Don't exceed Max Position
    movlw   255
    subwf   Position, w
    btfsc   STATUS, 0
    return                  ; Exit if limit reached
    
    incf    Position, f     ; Increment Position
    movlw   5               ; Motor steps per unit
    movwf   Temp
Open_Loop:
    incf    Step_Count, f
    call    Drive_Motor     ; Step the motor
    decfsz  Temp, f
    goto    Open_Loop
    return

Close:
    ; Safety Check: Don't go below Zero
    movf    Position, f
    btfsc   STATUS, 2
    return                  ; Exit if limit reached
    
    decf    Position, f     ; Decrement Position
    movlw   5               ; Motor steps per unit
    movwf   Temp
Close_Loop:
    decf    Step_Count, f
    call    Drive_Motor     ; Step the motor
    decfsz  Temp, f
    goto    Close_Loop
    return

Motor_Stop:
    BANKSEL PORTB
    clrf    PORTB           ; De-energize motor coils
    return

; --- STEPPER MOTOR DRIVER ---
Drive_Motor:
    movf    Step_Count, w
    andlw   0x03            ; Keep step count between 0-3
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
BB: movwf   PORTB           ; Output phase to PORTB
    call    Wait_Motor
    return


