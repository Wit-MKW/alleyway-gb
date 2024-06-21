include "common.inc"
setcharmap DMG

SECTION FRAGMENT "Main code", ROM0
GetInput:: ; $03C1
; write current input data to HRAM
; out(B) = 0
; clobbers A and C (same value)
; * [buttonsDown] bit clear: button depressed
; * [buttonsPressed] bit clear: button pressed anew
; * [buttonsUp] bit clear: button not pressed
; * bit 7: DOWN
; * bit 6: UP
; * bit 5: LEFT
; * bit 4: RIGHT
; * bit 3: START
; * bit 2: SELECT
; * bit 1: B
; * bit 0: A
	ld a, P1F_GET_DPAD
	ldh [rP1], a
rept 10
	ldh a, [rP1]
endr
	and P1F_3|P1F_2|P1F_1|P1F_0
	swap a
	ld b, a
	ld a, P1F_GET_BTN
	ldh [rP1], a
rept 10
	ldh a, [rP1]
endr
	and P1F_3|P1F_2|P1F_1|P1F_0
	or b
	ldh [buttonsDown], a
	ld a, P1F_GET_NONE
	ldh [rP1], a
	ld b, $08
	ldh a, [buttonsUp]
	ld c, a
	ldh a, [buttonsDown]
.loop::
	rrc c
	jr c, .pressed_before
	rrca
	jr nc, .pressed_anew
.continue:: ; $040D
	dec b
	jr nz, .loop
	ldh [buttonsPressed], a
	ld a, c
	ldh [buttonsUp], a
	ret
.pressed_before::
	rrca
	jr c, .released
	set 7, a
	jr .continue
.released::
	res 7, c
	jr .continue
.pressed_anew::
	set 7, c
	jp .continue

ThirtyOneNOPs:: ; $0426
; thirty-one NOPs
	ds 31, $00
	ret
