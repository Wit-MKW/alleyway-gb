include "common.inc"
setcharmap DMG

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
; out(HL) = -1
	ld a, $01
	ldh [rSB], a
	ld hl, rIE
	set IEB_SERIAL, [hl]
	ret
