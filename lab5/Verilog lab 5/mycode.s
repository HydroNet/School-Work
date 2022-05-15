    GLOBAL flashing
    AREA    mycode,CODE,READONLY
flashing

PINSEL0    EQU    0xE002C000    ;pin function for port 0
IO0DIR     EQU    0xE0028008    ;writing 1 configures pin to output, writing 0 corresponds pin to input
IO0PIN     EQU    0xE0028000
IO0SET     EQU    0XE0028004
IO0CLR     EQU    0XE002800C
PIN14      EQU    0x4000
TASK1      EQU    0xF00    ;keeps bits 8-11 ON
TASK2      EQU    0xFF00 ;turns ON LED pins 8-16
;task2
        MOV r0,#0
        LDR r1,=PINSEL0
        STR r0,[r1]

        MOV r0, #TASK2
        LDR r2,=IO0DIR
        LDR r1,[r2]
        ORR r1,r1,r0
        ;BIC r1,#PIN14
        STR r1,[r2]
       
        LDR r3,=IO0SET
        LDR r4,=IO0CLR
        LDR r5,=IO0PIN
        STR r0, [r3]; turning off all LEDs
        
CHECK    
        ;Set pin14 as an input
        LDR r1,[r2]
        BIC r1,#PIN14
        STR r1,[r2]
        LDR r1,=IO0PIN
        LDR r6,[r1];reads value of input (pin14)
        ;set 14 back to output
        LDR r1,[r2]
        ORR r1,#PIN14
        STR r1,[r2]

        TST r6,#PIN14
        BNE CHECK
        LDR r8, =30000
LOOP    SUBS r8,r8,#1
        BNE LOOP
        ;turn on all LEDs
        STR r0, [r4]

stop    B    stop    ;endless loop
    END
        
        
        
        
        
        
        
        
        
        
        
        
        ;task1
        MOV r0,#0
        LDR r1,=PINSEL0
        STR r0,[r1]

        MOV r0,#TASK1    ;turns on all LED's that are 1's  in this case pins 8-11
        LDR r2,=IO0DIR
        LDR r1,[r2]
        ORR r1,r1,#TASK1
        BIC r1,#PIN14
        STR r1,[r2]        
        
        LDR r3,=IO0SET
        LDR r4,=IO0CLR
        LDR r5,=IO0PIN
;CHECK
        LDR r6,[r5]
        TST r6,#0x4000
        BEQ TURNON
        BNE TURNOFF
        B CHECK
        
;TURNOFF    
        STR r0,[r3] ;sets bits 8-11
        B    CHECK
;TURNON 
		STR r0,[r4]    ;clears bit 8-11
        B    CHECK