include "common.inc"
setcharmap DMG

SECTION FRAGMENT "Main code", ROM0
SpecialTimeTick:: ; $198C
; tick the special timer if appropriate, play faster music if it hits 20, then display it
; if timer updated:
;   out(A) = OAMF_PAL0|OAMF_BANK0
;   out(B) = floor([specialTime] / 10) mod 10
;   out(C) = [specialTime] mod 10
;   out(HL) = oamBuf + 34*sizeof_OAM_ATTRS
; otherwise: out(A) = [frameCount] mod 32
	ldh a, [frameCount]
	and $1F
	ret nz
	ld a, [specialTime]
	dec a
	ld [specialTime], a
	push af
	call z, TimeUpMode
	pop af
	cp 20
	call z, PlayMusic.special_fast
	; fallthrough

DispSpecialTime:: ; $19A2
; display the special timer
; out(A) = OAMF_PAL0|OAMF_BANK0
; out(B) = floor([specialTime] / 10) mod 10
; out(C) = [specialTime] mod 10
; out(HL) = oamBuf + 34*sizeof_OAM_ATTRS
	ld hl, oamBuf + 32*sizeof_OAM_ATTRS
	ld a, [specialTime]
	call ToDecimalA
	ld c, a
	ld a, 112 + OAM_Y_OFS
	ld [hl+], a
	ld a, 136 + OAM_X_OFS
	ld [hl+], a
	ld a, b
	add a, "0"
	ld [hl+], a
	ld a, OAMF_PAL0|OAMF_BANK0
	ld [hl+], a
	ld a, 112 + OAM_Y_OFS
	ld [hl+], a
	ld a, 144 + OAM_X_OFS
	ld [hl+], a
	ld a, c
	add a, "0"
	ld [hl+], a
	ld a, OAMF_PAL0|OAMF_BANK0
	ld [hl+], a
	ret

TimeUpMode:: ; $19C7
; time's up!
; out(A) = gameMode_LOST_BALL
	ld a, gameMode_LOST_BALL
	ldh [gameMode], a
	ret

SpecialStart:: ; $19CC
; begin a special stage
; out(A) = 0
; out(B) = floor([specialTime] / 10) mod 10
; out(C) = [specialTime] mod 10
; out(E) = 0
; out(HL) = oamBuf + 34*sizeof_OAM_ATTRS
	call GetSpecialRules
	ld a, [hl]
	ld [specialTime], a
	call DispTimeLabel
	call DispSpecialTime
	call PlayMusic.special_intro
	ld a, 32
	call DelayFrames
	ret

GetSpecialRules:: ; $19E2
; get the rules for the current special stage
; out(A) = min([specialNum] - 1, 3)
; out(BC) = out(A) * SpecialRules_SIZEOF
; out(E) = 0
; out(HL) = pointer to rules
	ld a, [specialNum]
	dec a
	cp 3
	jr c, .ok
	ld a, 3
.ok::
	ld b, a
	ld e, SpecialRules_SIZEOF
	call MultiplyBxE
	ld hl, SpecialRules
	add hl, bc
	ret

FinishSpecialStage:: ; $19F7
; finish a special stage
; out(A) = 0
; if all bricks were destroyed:
;   out(BC) = 0
;   out(D) = HIGH(mainStripArray)
;   out(E) = 0
;   out(HL) = final score
; otherwise: out(B) = [bricksLeft]
	call StopAudio
	ldh a, [bricksLeft]
	ld b, a
	ldh a, [bricksLeft+1]
	or b
	jr z, .no_bricks
	call PlayMusic.special_end
	ld a, 128
	jp DelayFrames
.no_bricks::
	call PlayMusic.special_bonus
rept 319 / 255
	ld a, 255
	call DelayFrames
endr
	ld a, 319 % 255
	call DelayFrames
	jp .but_why
.but_why::
	call DispSpecialBonusText
	call GetSpecialRules
	inc hl
	ld b, [hl]
	inc hl
	ld c, [hl]
	push bc
	call DispSpecialBonus
	ld a, 128
	call DelayFrames
	pop bc
.loop::
	ld a, b
	cp $00
	jr nz, .ten_or_more
	ld a, c
	cp $00
	ret z
	cp 10
	jr c, .less_than_ten
.ten_or_more::
rept 10
	dec bc
endr
	push bc
	call DispSpecialBonus
	ldh a, [score+1]
	ld h, a
	ldh a, [score]
	ld l, a
	ld b, HIGH(10)
	ld c, LOW(10)
	add hl, bc
	ld a, h
	ldh [score+1], a
	ld a, l
	ldh [score], a
	call UpdateHiScore
	call GiveBonus
	call DispScore
	call PlaySound.special_bonus
	call WaitVblank
	pop bc
	jr .loop
.less_than_ten::
	dec bc
	push bc
	call DispSpecialBonus
	ldh a, [score+1]
	ld h, a
	ldh a, [score]
	ld l, a
	ld b, HIGH(1)
	ld c, LOW(1)
	add hl, bc
	ld a, h
	ldh [score+1], a
	ld a, l
	ldh [score], a
	call UpdateHiScore
	call GiveBonus
	call DispScore
	call PlaySound.special_bonus
	call WaitVblank
	pop bc
	ld a, b
	or c
	jr nz, .less_than_ten
	ret

DispSpecialBonusText:: ; $1A97
; display the text "SPECIAL BONUS"
; out(A) = 1
; out(B) = 0
; out(DE) = mainStripArray + (SpecialBonusText.end - SpecialBonusText)
; out(HL) = SpecialBonusText.end
	call WaitToDraw
	ld hl, SpecialBonusText
	ld de, mainStripArray
	ld b, SpecialBonusText.end - SpecialBonusText
.loop::
	ld a, [hl+]
	ld [de], a
	inc de
	dec b
	jr nz, .loop
	ld a, $01
	ldh [drawNeeded], a
	jp WaitVblank

SpecialBonusText:: ; $1AAF
	strip _SCRN0,26,2, 0, $C4,$C5,$C6,$C7,"Al BONUS" ; "SPECIAL BONUS"
	strip _SCRN0,27,9, 0,                    "PTS."
	db $00
.end:: ; $1AC6

EraseSpecialBonusText:: ; $1AC6
; erase what was displayed by DispSpecialBonusText
; out(A) = 1
; out(B) = 0
; out(DE) = mainStripArray + (BlankSpecialBonusText.end - BlankSpecialBonusText)
; out(HL) = BlankSpecialBonusText.end
	call WaitToDraw
	ld hl, BlankSpecialBonusText
	ld de, mainStripArray
	ld b, BlankSpecialBonusText.end - BlankSpecialBonusText
.loop::
	ld a, [hl+]
	ld [de], a
	inc de
	dec b
	jr nz, .loop
	ld a, $01
	ldh [drawNeeded], a
	jp WaitVblank

BlankSpecialBonusText:: ; $1ADE
	strip _SCRN0,26,2, 0, "            "
	strip _SCRN0,27,9, 0,        "    "
	db $00
.end:: ; $1AF5

DispTryAgainText:: ; $1AF5
; display the text "TRY AGAIN!" under the "NICE PLAY!" graphic
; out(A) = 1
; out(B) = 0
; out(DE) = mainStripArray + (TryAgainText.end - TryAgainText)
; out(HL) = TryAgainText.end
	call WaitToDraw
	ld hl, TryAgainText
	ld de, mainStripArray
	ld b, TryAgainText.end - TryAgainText
.loop::
	ld a, [hl+]
	ld [de], a
	inc de
	dec b
	jr nz, .loop
	ld a, $01
	ldh [drawNeeded], a
	jp WaitVblank

TryAgainText:: ; $1B0D
	strip _SCRN0,14,3, 0, "TRY AGAIN!"
	db $00
.end:: ; $1B1B

EraseTryAgainText:: ; $1B1B
; erase what was displayed by DispTryAgainText
; out(A) = 1
; out(B) = 0
; out(DE) = mainStripArray + (BlankTryAgainText.end - BlankTryAgainText)
; out(HL) = BlankTryAgainText.end
	call WaitToDraw
	ld hl, BlankTryAgainText
	ld de, mainStripArray
	ld b, BlankTryAgainText.end - BlankTryAgainText
.loop::
	ld a, [hl+]
	ld [de], a
	inc de
	dec b
	jr nz, .loop
	ld a, $01
	ldh [drawNeeded], a
	jp WaitVblank

BlankTryAgainText:: ; $1B33
	strip _SCRN0,14,3, 0, "          "
	db $00
.end:: ; $1B41
