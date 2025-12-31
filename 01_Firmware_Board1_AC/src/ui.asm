; ==============================================================================
; UNIVERSITY : ESKISEHIR OSMANGAZI UNIVERSITY
; DEPARTMENT : ELECTRICAL AND ELECTRONICS ENGINEERING
; PROJECT    : SMART HOME AUTOMATION SYSTEM
; BOARD      : BOARD 1 - AIR CONDITIONING CONTROLLER
; FILE       : ui.asm
; DESCRIPTION: User Interface - Keypad and 7-Segment Display
; ==============================================================================

#include "config.inc"

; --- EXTERNAL VARIABLES ---
EXTRN key_val, key_prev, entry_mode, entry_val, entry_count
EXTRN digit_tens, digit_ones, temp_int, display_num
EXTRN desired_temp, mul_temp, temp_var
EXTRN persist_cnt, bounce_cnt, delay_var, loop_cnt1, loop_cnt2

PSECT code
GLOBAL _PROCESS_KEY_MATRIX
GLOBAL _DISPLAY_CYCLE
GLOBAL _GET_SEGMENT
GLOBAL _DELAY_1Sec
GLOBAL _DELAY_50us
GLOBAL _DELAY_MUX
GLOBAL _ANTI_BOUNCE_DELAY

; ==============================================================================
; 4x4 KEYPAD MATRIX SCANNING
; ==============================================================================
_PROCESS_KEY_MATRIX:
    ; ROW 0
    BCF PORTB, 0
    BSF PORTB, 1
    BSF PORTB, 2
    BSF PORTB, 3
    CALL _DISPLAY_CYCLE
    BTFSS PORTB, 4
    GOTO KEY_1
    BTFSS PORTB, 5
    GOTO KEY_2
    BTFSS PORTB, 6
    GOTO KEY_3
    BTFSS PORTB, 7
    GOTO KEY_A
    
    ; ROW 1
    BSF PORTB, 0
    BCF PORTB, 1
    BSF PORTB, 2
    BSF PORTB, 3
    CALL _DISPLAY_CYCLE
    BTFSS PORTB, 4
    GOTO KEY_4
    BTFSS PORTB, 5
    GOTO KEY_5
    BTFSS PORTB, 6
    GOTO KEY_6
    BTFSS PORTB, 7
    GOTO KEY_B
    
    ; ROW 2
    BSF PORTB, 0
    BSF PORTB, 1
    BCF PORTB, 2
    BSF PORTB, 3
    CALL _DISPLAY_CYCLE
    BTFSS PORTB, 4
    GOTO KEY_7
    BTFSS PORTB, 5
    GOTO KEY_8
    BTFSS PORTB, 6
    GOTO KEY_9
    BTFSS PORTB, 7
    GOTO KEY_C
    
    ; ROW 3
    BSF PORTB, 0
    BSF PORTB, 1
    BSF PORTB, 2
    BCF PORTB, 3
    CALL _DISPLAY_CYCLE
    BTFSS PORTB, 4
    GOTO KEY_STAR
    BTFSS PORTB, 5
    GOTO KEY_0
    BTFSS PORTB, 6
    GOTO KEY_HASH
    BTFSS PORTB, 7
    GOTO KEY_D
    
    RETURN

; Key Value Mapping
KEY_0: MOVLW 0
       GOTO PROCESS_KEY
KEY_1: MOVLW 1
       GOTO PROCESS_KEY
KEY_2: MOVLW 2
       GOTO PROCESS_KEY
KEY_3: MOVLW 3
       GOTO PROCESS_KEY
KEY_4: MOVLW 4
       GOTO PROCESS_KEY
KEY_5: MOVLW 5
       GOTO PROCESS_KEY
KEY_6: MOVLW 6
       GOTO PROCESS_KEY
KEY_7: MOVLW 7
       GOTO PROCESS_KEY
KEY_8: MOVLW 8
       GOTO PROCESS_KEY
KEY_9: MOVLW 9
       GOTO PROCESS_KEY
KEY_A: MOVLW 0x0A
       GOTO PROCESS_KEY
KEY_B: MOVLW 0x0B
       GOTO PROCESS_KEY
KEY_C: MOVLW 0x0C
       GOTO PROCESS_KEY
KEY_D: MOVLW 0x0D
       GOTO PROCESS_KEY
KEY_STAR: MOVLW 0x0E
       GOTO PROCESS_KEY
KEY_HASH: MOVLW 0x0F
       GOTO PROCESS_KEY

; ==============================================================================
; KEY PROCESSING LOGIC
; ==============================================================================
PROCESS_KEY:
    MOVWF key_val
    SUBWF key_prev, W
    BTFSC STATUS, 2
    GOTO PERSIST_DISPLAY
    MOVF key_val, W
    MOVWF key_prev
    MOVF entry_mode, W
    BTFSS STATUS, 2
    GOTO ENTRY_KEY_HANDLER
    MOVF key_val, W
    XORLW 0x0A
    BTFSS STATUS, 2
    GOTO PERSIST_DISPLAY
    MOVLW 1
    MOVWF entry_mode
    CLRF entry_val
    CLRF entry_count
    GOTO PERSIST_DISPLAY

ENTRY_KEY_HANDLER:
    MOVF key_val, W
    XORLW 0x0F
    BTFSC STATUS, 2
    GOTO VALIDATE_INPUT
    MOVF key_val, W
    XORLW 0x0E
    BTFSC STATUS, 2
    GOTO CANCEL_INPUT
    MOVF key_val, W
    SUBLW 9
    BTFSS STATUS, 0
    GOTO PERSIST_DISPLAY
    MOVLW 2
    SUBWF entry_count, W
    BTFSC STATUS, 0
    GOTO PERSIST_DISPLAY
    MOVF entry_val, W
    MOVWF mul_temp
    BCF STATUS, 0
    RLF mul_temp, F
    BCF STATUS, 0
    RLF mul_temp, F
    BCF STATUS, 0
    RLF mul_temp, F
    BCF STATUS, 0
    RLF entry_val, F
    MOVF mul_temp, W
    ADDWF entry_val, F
    MOVF key_val, W
    ADDWF entry_val, F
    INCF entry_count, F
    CALL _ANTI_BOUNCE_DELAY
    GOTO PERSIST_DISPLAY

VALIDATE_INPUT:
    MOVLW 10
    SUBWF entry_val, W
    BTFSS STATUS, 0
    GOTO INVALID_VAL
    MOVLW 51
    SUBWF entry_val, W
    BTFSC STATUS, 0
    GOTO INVALID_VAL
    MOVF entry_val, W
    MOVWF desired_temp
INVALID_VAL:
    CLRF entry_mode
    CLRF entry_val
    CLRF entry_count
    GOTO PERSIST_DISPLAY

CANCEL_INPUT:
    CLRF entry_mode
    CLRF entry_val
    CLRF entry_count
    GOTO PERSIST_DISPLAY

; ==============================================================================
; DISPLAY PERSISTENCE LOOP
; ==============================================================================
PERSIST_DISPLAY:
    MOVLW 30
    MOVWF persist_cnt
PERSIST_LOOP:
    MOVF entry_mode, W
    BTFSS STATUS, 2
    GOTO PERSIST_ENTRY
    MOVF temp_int, W
    MOVWF display_num
    MOVLW 100
    SUBWF display_num, W
    BTFSS STATUS, 0
    GOTO PERSIST_BCD
    MOVLW 99
    MOVWF display_num
    GOTO PERSIST_BCD
PERSIST_ENTRY:
    MOVF entry_val, W
    MOVWF display_num
PERSIST_BCD:
    MOVF display_num, W
    MOVWF digit_ones
    CLRF digit_tens
PERSIST_DIV:
    MOVLW 10
    SUBWF digit_ones, W
    BTFSS STATUS, 0
    GOTO PERSIST_DISP
    MOVWF digit_ones
    INCF digit_tens, F
    GOTO PERSIST_DIV
PERSIST_DISP:
    CALL _DISPLAY_CYCLE
    CALL _DISPLAY_CYCLE
    DECFSZ persist_cnt, F
    GOTO PERSIST_LOOP
    RETURN

; ==============================================================================
; 7-SEGMENT DISPLAY MULTIPLEXING
; ==============================================================================
_DISPLAY_CYCLE:
    MOVF digit_tens, W
    CALL _GET_SEGMENT
    MOVWF PORTD
    BSF PORTC, 2
    CALL _DELAY_MUX
    BCF PORTC, 2
    CLRF PORTD
    MOVF digit_ones, W
    CALL _GET_SEGMENT
    MOVWF PORTD
    BSF PORTC, 3
    CALL _DELAY_MUX
    BCF PORTC, 3
    CLRF PORTD
    RETURN

; ==============================================================================
; 7-SEGMENT LOOKUP TABLE
; ==============================================================================
_GET_SEGMENT:
    MOVWF temp_var
    MOVF temp_var, W
    BTFSC STATUS, 2
    RETLW 0x3F
    MOVLW 1
    SUBWF temp_var, W
    BTFSC STATUS, 2
    RETLW 0x06
    MOVLW 2
    SUBWF temp_var, W
    BTFSC STATUS, 2
    RETLW 0x5B
    MOVLW 3
    SUBWF temp_var, W
    BTFSC STATUS, 2
    RETLW 0x4F
    MOVLW 4
    SUBWF temp_var, W
    BTFSC STATUS, 2
    RETLW 0x66
    MOVLW 5
    SUBWF temp_var, W
    BTFSC STATUS, 2
    RETLW 0x6D
    MOVLW 6
    SUBWF temp_var, W
    BTFSC STATUS, 2
    RETLW 0x7D
    MOVLW 7
    SUBWF temp_var, W
    BTFSC STATUS, 2
    RETLW 0x07
    MOVLW 8
    SUBWF temp_var, W
    BTFSC STATUS, 2
    RETLW 0x7F
    MOVLW 9
    SUBWF temp_var, W
    BTFSC STATUS, 2
    RETLW 0x6F
    RETLW 0x00

; ==============================================================================
; DELAY ROUTINES
; ==============================================================================
_ANTI_BOUNCE_DELAY:
    MOVLW 50
    MOVWF bounce_cnt
BOUNCE_LOOP:
    CALL _DISPLAY_CYCLE
    DECFSZ bounce_cnt, F
    GOTO BOUNCE_LOOP
    RETURN

_DELAY_MUX:
    MOVLW 200
    MOVWF delay_var
D_LOOP:
    DECFSZ delay_var, F
    GOTO D_LOOP
    RETURN

_DELAY_50us:
    MOVLW 15
    MOVWF delay_var
DELAY_50us_L:
    DECFSZ delay_var, F
    GOTO DELAY_50us_L
    RETURN

_DELAY_1Sec:
    MOVLW 10
    MOVWF loop_cnt2
DELAY_1S_L2:
    MOVLW 250
    MOVWF loop_cnt1
DELAY_1S_L1:
    CALL _DELAY_50us
    CALL _DELAY_50us
    DECFSZ loop_cnt1, F
    GOTO DELAY_1S_L1
    DECFSZ loop_cnt2, F
    GOTO DELAY_1S_L2
    RETURN
