.setcpu "65C02"
.debuginfo

.zeropage
                .org ZP_START0
READ_PTR:       .res 1
WRITE_PTR:      .res 1

.segment "INPUT_BUFFER"
INPUT_BUFFER:   .res $100

.segment "BIOS"

ACIA_DATA       = $5000
ACIA_STATUS     = $5001
ACIA_CMD        = $5002
ACIA_CTRL       = $5003
PORTA           = $6001
DDRA            = $6003
CB2             = $600C
CB2_LOW         = %11100000
CB2_HIGH        = %11011111

LOAD:
                rts
SAVE:
                rts

; Input a character from the serial interface.
; On return, carry flag indicates whether a key was pressed
; If a key was pressed, the key value will be in the A register
;
; Modifies: flags, A

MONRDKEY:       ; For BASIC
CHRIN:          ; For everything else.
                phx
                jsr BUFFER_SIZE
                beq @no_keypressed
                jsr READ_BUFFER
                jsr CHROUT                  ; echo
                pha
                jsr BUFFER_SIZE
                cmp #$B0
                bcs @mostly_full
                lda CB2
                ; set 600C to 110 (low inverted to high) to indicate ready to receive
                ora #$C0 ;11000000 - set 1s
                and #$DF ;11011111 - unset 0s
                sta CB2
@mostly_full:
                pla
                plx
                sec
                rts
@no_keypressed:
                plx
                clc
                rts

; Simple serial input routine for microchess
;
; Modifies: flags, A
syskin:
               lda ACIA_STATUS
               and #$08
               beq syskin
               lda ACIA_DATA
               sec
               rts

; Output a character (from the A register) to the serial interface.
;
; Modifies: flags
syschout:      ; For Microchess
MONCOUT:       ; For BASIC
CHROUT:        ; For everything else.
                pha
                sta ACIA_DATA
                lda #$FF
@txdelay:       dec
                bne @txdelay
                pla
                rts

; Initialize the circular input buffer
; Modifies: flags, A
INIT_BUFFER:
                lda READ_PTR
                sta WRITE_PTR
                lda CB2
                ; set 600C to 110 (low inverted to high) to indicate ready to receive
                ora #$C0 ;11000000 - set 11X
                and #$DF ;11011111 - set XX0
                sta CB2
                rts

; Write a character (from the A register) to the circular input buffer
; Modifies: flags, X
WRITE_BUFFER:
                ldx WRITE_PTR
                sta INPUT_BUFFER,x
                inc WRITE_PTR
                rts

; Read a character from the circular input buffer and put it in the A register
; Modifies: flags, A, X
READ_BUFFER:
                ldx READ_PTR
                lda INPUT_BUFFER,x
                inc READ_PTR
                rts

; Return (in A) the number of unread bytes in the circular input buffer
; Modifies: flags, A
BUFFER_SIZE:
                lda WRITE_PTR
                sec
                sbc READ_PTR
                rts


; Interrupt request handler
IRQ_HANDLER:
                pha
                phx
                lda ACIA_STATUS
                ; For now, assume the only source of interrupts is incoming data
                lda ACIA_DATA
                jsr WRITE_BUFFER
                jsr BUFFER_SIZE
                cmp #$F0
                bcc @not_full
                lda CB2
                ; set 111 high (CB2 inverted to low) to indicate not ready
                ora #$E0 ;11100000 - set 111
                sta CB2

@not_full:
                plx
                pla
                rti

.include "wozmon.s"

.segment "RESETVEC"
                .word   $0F00           ; NMI vector
                .word   RESET           ; RESET vector
                .word   IRQ_HANDLER     ; IRQ vector

