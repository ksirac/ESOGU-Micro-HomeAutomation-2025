; ==============================================================================
; UNIVERSITY : ESKISEHIR OSMANGAZI UNIVERSITY
; DEPARTMENT : ELECTRICAL AND ELECTRONICS ENGINEERING
; LESSON     : INTRODUCTION TO MICROCOMPUTERS
; PROJECT    : SMART CURTAIN CONTROL SYSTEM (MAIN FILE)
; BOARD      : BOARD 2
; FILE       : Main.asm
; AUTHOR     : CENGIZHAN GISI
; DESCRIPTION: This is the main entry point. It configures the PIC, initializes
;              peripherals, and runs the main loop which calls other modules.
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
It specifies that each code will be sequenced with a 2-byte (2-byte) distance between each line.
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

    ; 2. ADC Configuration - Analog inputs are configured to be read digitally.
    BANKSEL ADCON1
    movlw   0x04
    movwf   ADCON1
    
    ; 3. UART Configuration (9600 baud @ 20MHz)
    BANKSEL SPBRG
    movlw   25
    movwf   SPBRG
    BANKSEL TXSTA
    movlw   0x24
    movwf   TXSTA
    BANKSEL RCSTA
    movlw   0x90  
    movwf   RCSTA

    ; 4. I2C Configuration (BMP180 Interface)
    BANKSEL SSPCON
    movlw   0x28
    movwf   SSPCON
    BANKSEL SSPADD
    movlw   49
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
    clrf    Auto_Flag
    
    ; Default Sensor Values
    movlw   25
    movwf   Temp_H
    movlw   100
    movwf   Pres_H
    movlw   200
    movwf   LDR_Val

    ; 6. Initialize LCD - It calls the function necessary for the LCD screen to function correctly.
    call    LCD_Init

Main_Loop:
    ; Process UART Commands
    call    UART_Handler ;It checks and processes the incoming data.

    ; Potentiometer Control (Mode 0 Only)
    ;Using an ADC, the values ââfrom the potentiometer are read and saved to the Target variable.
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
    
    ; Limit 200 - If the potentiometer value exceeds 200, it is limited to 200. Therefore, the potentiometer will output the same value from approximately 3.90V up to 5 volts.
    movlw   200
    subwf   Target, w
    btfss   STATUS, 0
    goto    Target_OK
    movlw   200
    movwf   Target
Target_OK:

Skip_Pot:
    ; LDR Sensor Reading
    ;If there is insufficient light, the Target value is set to 200 (night mode).
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
    

    ; Night Mode Check - The LDR was operating in reverse.
    ; The `btfss` command was being used here.
    ; It was replaced with the `btfsc` command, the `clrf` function in the `target` variable was disabled, and 200 was written to it and transferred to the `target` variable.
    ; The `LDR_Skip` subfunction was added.
    ; Thus, when the LDR does not receive sufficient light, the shutter position is set to 100%.
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
    ;Sensor data is processed and displayed on the LCD screen.
    call    UART_Handler
    
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
;functions include loops used to provide various waiting times:
#include "Motor.asm"
;Here, operations such as direct control of the motor and speed adjustments can be performed. For example, the direction of the motor, rotational speed, starting and stopping states, etc.
#include "LCD.asm"
 ;This module includes functions that enable LCD screen control.
#include "UART.asm"
 ;This file contains the functions necessary to control UART (Universal Asynchronous Receiver-Transmitter) communication.
#include "Sensors.asm"
 ;This module contains the functions necessary for sensor reading operations.

END
