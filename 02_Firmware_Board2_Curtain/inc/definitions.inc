; ==============================================================================
; UNIVERSITY : ESKISEHIR OSMANGAZI UNIVERSITY
; PROJECT    : SMART CURTAIN CONTROL SYSTEM
; BOARD      : BOARD 2
; FILE       : definitions.inc
; DESCRIPTION: System constants and Pin Mappings for Board #2
; ==============================================================================

; --- SYSTEM SETTINGS ---
#define _XTAL_FREQ    20000000  ; 20 MHz Crystal

; --- LCD DISPLAY MAPPINGS (PORTD) ---
#define LCD_PORT      PORTD
#define LCD_TRIS      TRISD
#define LCD_RS_PIN    2         ; RD2 -> LCD RS
#define LCD_EN_PIN    3         ; RD3 -> LCD EN
; LCD Data pins: D4->RD4, D5->RD5, D6->RD6, D7->RD7

; --- STEP MOTOR MAPPINGS (PORTB) ---
#define MOTOR_PORT    PORTB
#define MOTOR_TRIS    TRISB
#define MOTOR_MASK    0x0F      ; Uses RB0-RB3

; --- SENSOR PINS ---
#define LDR_CHANNEL   0         ; RA0/AN0
#define POT_CHANNEL   1         ; RA1/AN1

; --- I2C (BMP180) PINS ---
#define SCL_PIN       3         ; RC3
#define SDA_PIN       4         ; RC4
#define BMP180_ADDR_W 0xEE
#define BMP180_ADDR_R 0xEF

; --- UART SETTINGS ---
#define BAUD_RATE     9600
#define RX_PIN        7         ; RC7
#define TX_PIN        6         ; RC6
