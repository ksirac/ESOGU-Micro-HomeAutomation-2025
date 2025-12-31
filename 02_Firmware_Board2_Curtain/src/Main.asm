; ==============================================================================
; UNIVERSITY : ESKISEHIR OSMANGAZI UNIVERSITY
; DEPARTMENT : ELECTRICAL AND ELECTRONICS ENGINEERING
; PROJECT    : SMART CURTAIN CONTROL SYSTEM
; BOARD      : BOARD 2
; FILE       : Main.asm
; DESCRIPTION: Main Program Entry Point with Multi-Mode Curtain Control
; MODES      : 0=Potentiometer | 1=LDR Automatic | 2=GUI Remote
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

; --- INCLUDE DEFINITIONS & VARIABLES ---
#include "Definitions.inc"
#include "Variables.asm"

; --- RESET VECTOR ---
PSECT resetVec,class=CODE,delta=2
    clrf    PCLATH
    goto    Start

; --- MAIN PROGRAM CODE ---
PSECT code,class=CODE,delta=2

Start:
    ; Port Configuration
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

    ; ADC Configuration
    BANKSEL ADCON1
    movlw   0x04
    movwf   ADCON1
    
    ; UART Configuration (9600 baud @ 20MHz)
    BANKSEL SPBRG
    movlw   25
    movwf   SPBRG
    BANKSEL TXSTA
    movlw   0x24
    movwf   TXSTA
    BANKSEL RCSTA
    movlw   0x90  
    movwf   RCSTA

    ; I2C Configuration (BMP180 Interface)
    BANKSEL SSPCON
    movlw   0x28
    movwf   SSPCON
    BANKSEL SSPADD
    movlw   49
    movwf   SSPADD
    BANKSEL SSPSTAT
    movlw   0x80
    movwf   SSPSTAT

    ; Initialize Variables
    BANKSEL PORTB
    clrf    PORTB
    clrf    Position
    clrf    Target
    clrf    Step_Count
    clrf    Loop_Counter
    clrf    Auto_Flag
    
    ; Default Sensor Values
    movlw   25
    movwf   Temp_H
    movlw   100
    movwf   Pres_H
    movlw   200
    movwf   LDR_Val

    ; Initialize LCD
    call    LCD_Init

Main_Loop:
    ; Process UART Commands
    call    UART_Handler

    ; Potentiometer Control (Mode 0 Only)
    BANKSEL Auto_Flag
    movf    Auto_Flag, w
    btfss   STATUS, 2
    goto    Skip_Pot
    
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
    
    ; Clamp to Maximum (200)
    movlw   200
    subwf   Target, w
    btfss   STATUS, 0
    goto    Target_OK
    movlw   200
    movwf   Target
Target_OK:

Skip_Pot:
    ; LDR Sensor Reading
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
    
    ; Automatic Mode (Mode 1 Only)
    BANKSEL Auto_Flag
    movf    Auto_Flag, w
    xorlw   1
    btfss   STATUS, 2
    goto    LDR_Skip
    
    ; LDR Threshold Comparison
    movlw   100
    BANKSEL LDR_Val
    subwf   LDR_Val, w
    btfsc   STATUS, 0
    goto    Auto_Open
    goto    Auto_Close

Auto_Open:
    BANKSEL Target
    clrf    Target
    goto    LDR_Skip

Auto_Close:
    BANKSEL Target
    movlw   200
    movwf   Target
    goto    LDR_Skip

LDR_Skip:
    ; Motor Control
    call    Motor_Handler

    ; Sensor Update
    call    UART_Handler
    
    incf    Loop_Counter, f
    btfss   STATUS, 2
    goto    Main_Loop
    
    call    Read_Sensors
    call    Calc_Percent
    call    LCD_Print_Full
    goto    Main_Loop

; --- INCLUDE MODULES ---
#include "Utils.asm"
#include "Motor.asm"
#include "LCD.asm"
#include "UART.asm"
#include "Sensors.asm"

END
