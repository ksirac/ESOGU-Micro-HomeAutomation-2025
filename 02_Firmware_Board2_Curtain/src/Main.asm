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
config FOSC = HS         ; A high-speed oscillator is used.
config WDTE = OFF        ; Watchdog Timer is disabled.
config PWRTE = ON        ; The power-up timer is activated.
config BOREN = OFF       ; Brown-out reset (low voltage) is disabled.
config LVP = OFF         ; Low Voltage Programming is disabled.
config CPD = OFF         ; Data EEPROM code protection is disabled.
config WRT = OFF         ; Write protection is disabled.
config CP = OFF          ; Program memory protection is disabled.

; --- INCLUDE VARIABLES ---
#include "Variables.asm"               ;Defines Variables in here.

; --- RESET VECTOR ---
PSECT resetVect,class=CODE,delta=2,abs ; indicating absolute address and It specifies that each code will be sequenced with a 2-byte (2-byte) distance between each line.
ORG 0x0000
    clrf    PCLATH
    goto    Start

; --- MAIN PROGRAM CODE ---
PSECT code,class=CODE,delta=2

Start:
    ; 1. Port Configuration
    BANKSEL TRISA
    movlw   0xFF  ; PORTA all bits are inputs
    movwf   TRISA
    BANKSEL TRISB ; PORTB all bits are outputs
    clrf    TRISB
    BANKSEL TRISD
    clrf    TRISD ; PORTD all bits are outputs
    BANKSEL TRISC
    movlw   0x98  ; Some pins of PORTC are configured as inputs, and some are configured as outputs.
    movwf   TRISC

    ; 2. ADC Configuration - Analog inputs are configured to be read digitally.
    BANKSEL ADCON1
    movlw   0x04 ; 
    movwf   ADCON1
    
    ; 3. UART Configuration
    BANKSEL SPBRG
    movlw   25
    movwf   SPBRG ; It sets the baud rate to 9600.
    BANKSEL TXSTA
    movlw   0x24
    movwf   TXSTA ; Transmit
    BANKSEL RCSTA
    movlw   0x90  
    movwf   RCSTA ; Receivet

    ; 4. I2C Configuration
    BANKSEL SSPCON
    movlw   0x28    ; I2C mode active
    movwf   SSPCON
    BANKSEL SSPADD
    movlw   9
    movwf   SSPADD  ; Set I2C time speed
    BANKSEL SSPSTAT
    movlw   0x80
    movwf   SSPSTAT

    ; 5. Initialize Variables
    BANKSEL PORTB                     ; PORTB and orher variables are cleared.
    clrf    PORTB
    clrf    Position
    clrf    Target
    clrf    Step_Count
    clrf    Loop_Counter
    ; Default Values - Initial values are assigned.
    movlw   25
    movwf   Temp_H
    movlw   100
    movwf   Pres_H
    movlw   200
    movwf   LDR_Val

    ; 6. Initialize LCD - It calls the function necessary for the LCD screen to function correctly.
    call    LCD_Init

Main_Loop:
    ; --- UART LISTENER ---
    call    UART_Handler          ;It checks and processes the incoming data.

    ; --- 1. READ POTENTIOMETER ---
    ;Using an ADC, the values ​​from the potentiometer are read and saved to the Target variable. 
    
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

    ; --- 2. LDR CONTROL ---
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
    ;Sensor data is processed and displayed on the LCD screen.
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
#include "Utils.asm"                                             ;These functions include loops used to provide various waiting times:
#include "Motor.asm"                                             ;Here, operations such as direct control of the motor and speed adjustments can be performed. For example, the direction of the motor, rotational speed, starting and stopping states, etc.
#include "LCD.asm"                                               ;This module includes functions that enable LCD screen control.
#include "UART.asm"                                              ;This file contains the functions necessary to control UART (Universal Asynchronous Receiver-Transmitter) communication.
#include "Sensors.asm"                                           ;This module contains the functions necessary for sensor reading operations.

END


