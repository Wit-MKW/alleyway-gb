include "common.inc"
setcharmap DMG

SECTION FRAGMENT "Main code", ROM0
UpdateScore:: ; $0C32
; update current score based on destroying brick type in(A)
; out(B) = (added points)
; out(C) = 3
; out(E) = 0
; clobbers A
	dec a
	ld b, a
	ld e, BrickTypes_SIZEOF
	call MultiplyBxE
	ld hl, BrickTypes
	add hl, bc
	ld b, HIGH(BrickTypes_POINTS)
	ld c, LOW(BrickTypes_POINTS)
	add hl, bc
	ld a, [hl]
	swap a
	and $0F
	ld b, a
	ldh a, [score]
	add a, b
	ldh [score], a
	ldh a, [score+1]
	adc a, $00
	ldh [score+1], a
	ret nc
	xor a
	dec a
	ldh [score+1], a
	ldh [score], a
	ret

UpdateHiScore:: ; $0C5B
; update high score based on current score
; out(BC) = hiScore (+1 if no update)
; out(HL) = score (+1 if no update)
; clobbers A
	ld bc, hiScore
	ld hl, score
	ldh a, [c]
	sub [hl]
	push af
	inc c
	inc hl
	pop af
	ldh a, [c]
	sbc a, [hl]
	ret nc
	ld a, [hl]
	ldh [c], a
	dec c
	dec hl
	ld a, [hl]
	ldh [c], a
	ret

GiveBonus:: ; $0C71
; give the player a bonus if appropriate
; out(B) = 0
; clobbers A, C, HL
	ld hl, score
	ldh a, [nextBonus]
	sub [hl]
	push af
	inc hl
	pop af
	ldh a, [nextBonus+1]
	sbc a, [hl]
	ret nc
	ld a, [numLives]
	cp $09
	jr nc, .skip_inc
	inc a
	ld [numLives], a
	call PlaySound.one
.skip_inc::
	call DispNumLives
	; fallthrough

CountBonus:: ; $0C8F
; increment the next bonus score
; out(B) = 0
; clobbers A, C, HL
	ldh a, [bonusesGiven]
	sla a
	ld c, a
	ld b, $00
	ld hl, BonusScores
	add hl, bc
	ld a, [hl+]
	ldh [nextBonus+1], a
	ld a, [hl]
	ldh [nextBonus], a
	ldh a, [bonusesGiven]
	inc a
	ldh [bonusesGiven], a
	ret
