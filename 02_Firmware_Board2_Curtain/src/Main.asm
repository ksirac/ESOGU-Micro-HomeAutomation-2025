; ==============================================================================
; UNIVERSITY : ESKISEHIR OSMANGAZI UNIVERSITY
; DEPARTMENT : ELECTRICAL AND ELECTRONICS ENGINEERING
; LESSON     : INTRODUCTION TO MICROCOMPUTERS
; PROJECT    : SMART CURTAIN CONTROL SYSTEM (MAIN FILE)
; BOARD      : BOARD 2
; AUTHOR     : CENGIZHAN GISI
; DESCRIPTION: This is the main entry point. It configures the PIC, initializes
;              peripherals, and runs the main loop which calls other modules.
; ==============================================================================

PROCESSOR 16F877A
#include <xc.inc>

; --- CONFIGURATION BITS ---
config FOSC = HS
config WDTE = OFF
config PWRTE = ON
config BOREN = OFF
config LVP = OFF
config CPD = OFF
config WRT = OFF
config CP = OFF

; --- INCLUDE VARIABLES ---
#include "Variables.asm"

; --- RESET VECTOR ---
PSECT resetVect,class=CODE,delta=2,abs
ORG 0x0000
    clrf    PCLATH
    goto    Start

; --- MAIN PROGRAM CODE ---
PSECT code,class=CODE,delta=2

Start:
    ; 1. Port Configuration
    BANKSEL TRISA
    movlw   0xFF
    movwf   TRISA
    BANKSEL TRISB
    clrf    TRISB
    BANKSEL TRISD
    clrf    TRISD
    BANKSEL TRISC
    movlw   0x98
    movwf   TRISC

    ; 2. ADC Configuration
    BANKSEL ADCON1
    movlw   0x04
    movwf   ADCON1
    
    ; 3. UART Configuration
    BANKSEL SPBRG
    movlw   25
    movwf   SPBRG
    BANKSEL TXSTA
    movlw   0x24
    movwf   TXSTA
    BANKSEL RCSTA
    movlw   0x90
    movwf   RCSTA

    ; 4. I2C Configuration
    BANKSEL SSPCON
    movlw   0x28
    movwf   SSPCON
    BANKSEL SSPADD
    movlw   9
    movwf   SSPADD
    BANKSEL SSPSTAT
    movlw   0x80
    movwf   SSPSTAT

    ; 5. Initialize Variables
    BANKSEL PORTB
    clrf    PORTB
    clrf    Position
    clrf    Target
    clrf    Step_Count
    clrf    Loop_Counter
    ; Default Values
    movlw   25
    movwf   Temp_H
    movlw   100
    movwf   Pres_H
    movlw   200
    movwf   LDR_Val

    ; 6. Initialize LCD
    call    LCD_Init

Main_Loop:
    ; --- UART LISTENER ---
    call    UART_Handler

    ; --- 1. READ POTENTIOMETER ---
    BANKSEL ADCON0
    movlw   0x89
    movwf   ADCON0
    call    Wait_Short
    bsf     ADCON0, 2
Wait_P:
    btfsc   ADCON0, 2
    goto    Wait_P
    BANKSEL ADRESH
    movf    ADRESH, w
    movwf   Target
    
    ; Limit 200
    movlw   200
    subwf   Target, w
    btfss   STATUS, 0
    goto    Target_OK
    movlw   200
    movwf   Target
Target_OK:

    ; --- 2. LDR CONTROL ---
    BANKSEL ADCON0
    movlw   0x81
    movwf   ADCON0
    call    Wait_Short
    bsf     ADCON0, 2
Wait_L:
    btfsc   ADCON0, 2
    goto    Wait_L
    BANKSEL ADRESH
    movf    ADRESH, w
    movwf   LDR_Val
    
    ; Night Mode Check - The LDR was operating in reverse. The `btfss` command was being used here. It was replaced with the `btfsc` command, the `clrf` function in the `target` variable was disabled, and 200 was written to it and transferred to the `target` variable. The `LDR_Skip` subfunction was added. Thus, when the LDR does not receive sufficient light, the shutter position is set to 100%.
     movlw   100
    subwf   LDR_Val, w
    btfsc   STATUS, 0
    goto LDR_Skip
    
    movlw 200
    movwf Target

LDR_Skip:
    ; --- 3. MOTOR CONTROL ---
    call    Motor_Handler

    ; --- 4. SENSOR UPDATE ---
    call    UART_Handler    ; Check again
    
    incf    Loop_Counter, f
    btfss   STATUS, 2
    goto    Main_Loop
    
    call    Read_Sensors
    call    Calc_Percent
    call    LCD_Print_Full
    goto    Main_Loop

; --- INCLUDE MODULES ---
; The assembler will insert the code from these files here.
#include "Utils.asm"
#include "Motor.asm"
#include "LCD.asm"
#include "UART.asm"
#include "Sensors.asm"

END


