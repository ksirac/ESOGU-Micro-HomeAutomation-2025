; ==============================================================================
; UNIVERSITY : ESKISEHIR OSMANGAZI UNIVERSITY
; DEPARTMENT : ELECTRICAL AND ELECTRONICS ENGINEERING
; PROJECT    : SMART HOME AUTOMATION SYSTEM
; BOARD      : BOARD 1 - AIR CONDITIONING CONTROLLER
; FILE       : config.inc
; DESCRIPTION: System Configuration and Pin Definitions
; ==============================================================================

#include <xc.inc>

; --- CONFIGURATION BITS ---
config FOSC = XT, WDTE = OFF, PWRTE = ON, BOREN = ON, LVP = OFF, DEBUG = OFF

; --- CONSTANTS ---
KEY_NONE  EQU 0xFF

; --- PIN DEFINITIONS ---
#define HEATER      PORTE, 0  
#define COOLER      PORTE, 1
