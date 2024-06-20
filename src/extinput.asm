include "common.inc"
setcharmap DMG

; This file implements support for an unreleased peripheral.
; It would have connected through the Game Boy's serial (EXT.) port,
; and it is reasonable to imagine it as a paddle-type controller.

; Both the Game Boy & the paddle would have used the Game Boy's
; internal clock to communicate, and made exchanges in a two-byte
; cycle every frame:
; 1. Game Boy sends last-received button status, paddle sends angle
; - In the first exchange, where the Game Boy has not received any
;   button status, it sends the byte $01.
;   - This is the value (SCF_SOURCE) written to rSC to indicate that
;     the Game Boy should emit its internal clock pulse on the serial
;     port & not accept any other, so perhaps writing it to rSB (to send
;     it as the first byte) was a mistake.
; - Valid angle values are $00 (far left) - $F0 (far right), inclusive.
;   - An angle value of $FF can be assumed to indicate that the paddle
;     is not connected at all.
;     - Values in the range $F1-$FE, inclusive, may have been other
;       error codes.
;   - Assuming that the wheel would have had a range of 330°, each unit
;     corresponds to a change of roughly 1.37°.
;   - Alleyway specifically uses this value as follows:
;     - A value in the range $00-$3F, inclusive, sends the in-game
;       racquet to the far left of the playfield.
;     - Each angle unit in the range $3F-$9F (or $3F-$97), inclusive,
;       corresponds to a single pixel.
;     - A value in the range $97-$F0, inclusive, sends the in-game
;       racquet to the far right of the playfield if it has not been
;       reduced by the ball hitting the top of the playfield.
;     - A value in the range $9F-$F0, inclusive, sends the in-game
;       racquet to the far right of the playfield in any case.
; 2. Game Boy sends newly-received angle, paddle sends button status
; - A bit cleared here indicates that the corresponding button is
;   currently depressed, while a bit set indicates the opposite.
; - Alleyway only acknowledges bit 7 of this byte: it acts as the
;   Game Boy's START button in most cases, but is also used like
;   its A button to deploy a ball when starting a stage or after
;   losing a life.
;   - It is possible that some or all of the other bits were used
;     as a signature, to distinguish the paddle from other
;     external devices, to prevent $FF from being sent when no
;     buttons are depressed, and/or to indicate errors.
;     - The standard state of these signature bits (if they existed)
;       might well have matched the $01 byte that the Game Boy
;       initially sends in lieu of a button status.

SECTION FRAGMENT "Main code", ROM0
_IntSerial:: ; $0272
	push af
	push bc
	ldh a, [paddleCounter]
	dec a
	ldh [paddleCounter], a
	jr nz, .got_angle
	ldh a, [paddleButtons]
	ld b, a
	ldh a, [rSB]
	ldh [paddleButtons], a
; ~((new buttons) ^ (old buttons)) | (new buttons)
; only newly-cleared bits (newly-pressed buttons) are clear
	ld c, a
	xor b
	xor $FF
	or c
	ldh [paddleButonsPressed], a
	pop bc
	pop af
	reti
.got_angle::
	ldh a, [rSB]
	ldh [paddleAngle], a
	ld a, SCF_START|SCF_SOURCE
	ldh [rSC], a
	pop bc
	pop af
	reti

PrepareSerial:: ; $0297
; prepare $01 byte to be sent to paddle
; out(A) = 1
; out(HL) = rIE
	ld a, $01 ; SCF_SOURCE
	ldh [rSB], a
	ld hl, rIE
	set IEB_SERIAL, [hl]
	ret
