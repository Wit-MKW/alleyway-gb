include "common.inc"
setcharmap DMG

SECTION FRAGMENT "Main code", ROM0
TitleScreenStripArray:: ; $41CD
	strip $9800, 0, $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
	strip $9820, 0, $AC,$AC,$A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9,$A9,$AC,$AC,$A9
	strip $9840, 0, " "," "," ",$AB," ",$A8,$AB,$A8,$A8," ",$AB,$A8,$A8," ",$A8,$AB
	strip $9861, 0,     $0E,$01
	strip $9871, 0,                                                                     "T","M"
	strip $9881, 0,     $02,$03,$08," ",$08," ",$00,$15,$08,$08,$08,$08,$08,$0E,$01,$08,$08
	strip $98A1, 0,     $02,$03,$09," ",$09," ",$02,$16,$09,$09,$09,$09,$09,$02,$03,$09,$09
	strip $98C1, 0,     $02,$06,$09," ",$09," ",$02,$17,$04,$07,$09,$09,$09,$02,$06,$04,$07
	strip $98E1, 0,     $02,$03,$0A,$0B,$0A,$0B,$02,$0B," ",$09,$02,$A7,$06,$02,$03," ",$09
	strip $9901, 0,     $13,$14,$0C,$0D,$0C,$0D,$10,$0D,$08,$09,$0F,$12,$11,$13,$14,$08,$09
	strip $9929, 0,                                     $04,$05
	strip $9930, 0,                                                                 $04,$05
	strip $9963, 0, "TOP SCORE"
	strip $99C3, 0, "PUSH START KEY"
	strip $9A04, 0,  "©1989 ",$18,$19,$1A,$1B,$1C,$1D ; "©1989 Nintendo"
	db $00

NicePlay:: ; $42B3
	strip $9843, 0, "NICE PLAY!"
	strip $9884, 0,         $44,$45," "," "," ",$44,$45
	strip $98A3, 0,     $44,$46,$20,$21,$22,$23,$24,$44,$45
	strip $98C2, 0, $44,$45,$25,$26,$27,$28,$29,$2A,$2B,$44,$45
	strip $98E2, 0, $44,$45,$2C,$2D,$2E,$2F,$30,$31,$32,$44,$45
	strip $9902, 0, $44,$45,$33,$A5,$34,$35,$A5,$36,$37,$44,$45
	strip $9922, 0, $44,$45,$38,$39,$3A,$3B,$3C,$3D,$3E,$44,$45
	strip $9943, 0,     $44,$45,$3F,$40,$41,$42,$43,$44,$45
	strip $9963, 0,     $47,$48,$49,$4A,$4B,$4C,$4D,$4E,$4F
	strip $9983, 0,     $50,$51,$52,$53,$54,$55,$56,$57,$58
	db $00

	ds $A4, $00
	db $01, $00, $00, $00, $FF

MarioStart:: ; $43DC
	call MakeRacquetSprite
	call PlayMusic.two
	ldh a, [racquetX]
	add a, 80
	ld [marioX], a
	ldh a, [racquetY]
	sub 16
	ld [marioY], a
	ld a, $03
	ld [marioFrameAlt], a
.run_loop::
	call MarioRunStep
	call DispCurrentMarioFrame
	ld a, [marioX]
	dec a
	ld [marioX], a
	cp 60 + OAM_X_OFS
	jr nz, .run_loop
	ld a, $03
	ld [marioFrame], a
	call DispCurrentMarioFrame
	call PlaySound.nine
	call OpenRacquetDoor
	ld a, $04
	ld [marioFrame], a
	xor a
	ld [marioJumpCounter], a
	ld [marioSpeedX], a
.jump_loop::
	call DispCurrentMarioFrame
	call MarioJump
	ld a, [marioJumpCounter]
	cp 24
	jr c, .jump_loop
.fall_loop::
	call DispCurrentMarioFrame
	ld a, [marioY]
	inc a
	inc a
	inc a
	inc a
	ld [marioY], a
	cp 120 + OAM_Y_OFS
	jr c, .fall_loop
	call ClearLastSixObjs
	ld a, 16
	call DelayFrames
	call CloseRacquetDoor
	call MakeRacquetSprite
	ret

Func444D:: ; $444D
	call Func10FB
	call MakeRacquetSprite
	call PlaySound.ten
	call OpenRacquetDoor
	ld a, $88
	ld [marioY], a
	ldh a, [racquetX]
	add a, 4
	ld [marioX], a
	ld b, $00
	ld c, $05
	cp 76
	jr nc, .right
	ld b, $01
	ld c, $06
.right::
	ld a, b
	ld [marioSpeedX], a
	ld a, c
	ld [marioFrame], a
	xor a
	ld [marioJumpCounter], a
.loop1::
	call DispCurrentMarioFrame
	call MarioJump
	ld a, [marioJumpCounter]
	cp $18
	jr c, .loop1
.loop2::
	call DispCurrentMarioFrame
	ld a, [marioY]
	inc a
	inc a
	inc a
	inc a
	ld [marioY], a
	cp $A0
	jr c, .loop2
	call ClearLastSixObjs
	ld a, 64
	call DelayFrames
	ret

MarioRunStep:: ; $44A4
	ld a, [marioFrameAlt]
	dec a
	ld [marioFrameAlt], a
	ret nz
	ld a, [marioFrame]
	inc a
	cp $03
	jr c, .skip_zero
	xor a
.skip_zero::
	ld [marioFrame], a
	ld a, $05
	ld [marioFrameAlt], a
	ret

DispCurrentMarioFrame:: ; $44BE
	ld a, [marioX]
	ld b, a
	ld a, [marioY]
	ld c, a
	ld a, [marioFrame]
	call DispMarioFrame
	jp WaitVblank

MarioJump:: ; $44CF
	ld a, [marioJumpCounter]
	ld c, a
	inc a
	ld [marioJumpCounter], a
	ld b, $00
	ld hl, MarioSpeedY
	add hl, bc
	ld a, [hl]
	ld b, a
	ld a, [marioY]
	add a, b
	ld [marioY], a
	ld a, [marioSpeedX]
	sla a
	dec a
	ld b, a
	ld a, [marioX]
	add a, b
	ld [marioX], a
	ret

MarioSpeedY:: ; $44F5
	db -3, -3, -3, -2, -2, -2, -1, -1, -1, -0, -1, -0
	db  0,  1,  0,  1,  1,  1,  2,  2,  2,  3,  3,  3

OpenRacquetDoor:: ; $450D
	call MakeRacquetSprite
	xor a
.loop::
	push af
	call SetRacquetTiles
	ld a, $08
	call DelayFrames
	pop af
	inc a
	cp $03
	jr c, .loop
	ret

CloseRacquetDoor:: ; $4521
	ld a, $02
.loop::
	push af
	call SetRacquetTiles
	ld a, 12
	call DelayFrames
	pop af
	dec a
	cp -1
	jr nz, .loop
	ret

SetRacquetTiles:: ; $4533
	ld b, $00
	ld c, a
	ld hl, RacquetFrames
	add hl, bc
	ld b, [hl]
	ld e, $03
	call MultiplyBxE
	ld hl, RacquetTiles
	add hl, bc
	ld a, [hl+]
	ld [oamBuf + $02], a
	ld a, [hl+]
	ld [oamBuf + $06], a
	ld a, [hl]
	ld [oamBuf + $0A], a
	ret

RacquetFrames:: ; $4551
	db $00, $01, $02

RacquetTiles:: ; $4554
	db $00, $04, $00
	db $00, $03, $00
	db $02, $03, $02

DispSmoke:: ; $455D
	call PlayNoise
	ldh a, [ballPosX]
	sub $08
	ld [marioX], a
	ld a, 144
	ld [marioY], a
	xor a
	ld [marioFrameAlt], a
.loop::
	push bc
	ld a, [marioX]
	ld b, a
	ld a, [marioY]
	ld c, a
	ld a, [marioFrameAlt]
	ld d, $00
	ld e, a
	ld hl, SmokeFrames
	add hl, de
	ld a, [hl]
	call DispMarioFrame
	call WaitVblank
	pop bc
	ld a, [marioFrameAlt]
	inc a
	ld [marioFrameAlt], a
	cp SmokeFrames.end - SmokeFrames
	jr c, .loop
	jp ClearLastSixObjs

SmokeFrames:: ; $4599
	ds 8, $07
	ds 12, $08
	ds 16, $09
.end:: ; $45BD

MarioWink:: ; $45BD
	xor a
	ld [marioFrameAlt], a
.loop::
	push bc
	ld b, $38
	ld c, $48
	ld a, [marioFrameAlt]
	ld d, $00
	ld e, a
	ld hl, WinkFrames
	add hl, de
	ld a, [hl]
	call DispMarioFrame
	call WaitVblank
	pop bc
	ld a, [marioFrameAlt]
	inc a
	ld [marioFrameAlt], a
	cp WinkFrames.end - WinkFrames
	jr c, .loop
	jp ClearLastSixObjs

WinkFrames:: ; $45E6
	ds 8, $0A
	ds 6, $0B
	ds 6, $0C
	ds 8, $0B
	db $0A
.end:: ; $4603

DispGameScreen:: ; $4603
	call TurnOffLCD
	call SaveIE
	call FillNameTable0
	call FillNameTable1
	call ClearOAM
	call StopAudio
	ld a, 127
	ldh [rWX], a
	ld a, $00
	ldh [rWY], a
	ldh a, [lcdcTmp]
	or LCDCF_WIN9C00|LCDCF_WINON
	ldh [lcdcTmp], a
	xor a
	ldh a, [stageRowDrawing]
	ld a, $08
	ldh [rLYC], a
	ld a, STATF_LYC|STATF_LYCF|STATF_HBL
	ldh [rSTAT], a
	ldh a, [ieBackup]
	or IEF_STAT
	or IEF_SERIAL
	ldh [ieBackup], a
	ld a, %11100100
	call SetPalette
	ld de, GameScreen
	call DrawStripArray.start
	ldh a, [gameMode]
	cp $03
	jr z, .not_finished
	ld a, [stageNum]
	cp $00
	jr z, .not_finished
	ld a, [stageId]
	cp $00
	jr nz, .not_finished
	ld de, NicePlay
	call DrawStripArray.start
	ld a, %00000000
	call SetPalette
.not_finished::
	call MakeLeftBorder
	call RestoreIE
	jp TurnOnLCD

MakeStageNumSprite:: ; $4669
	ld a, 112
	ld [oamBuf + $80], a
	ld [oamBuf + $84], a
	ld [oamBuf + $88], a
	ld [oamBuf + $8C], a
	ld [oamBuf + $90], a
	ld [oamBuf + $94], a
	ld [oamBuf + $98], a
	ld [oamBuf + $9C], a
	ld a, 48
	ld [oamBuf + $81], a
	ld a, 56
	ld [oamBuf + $85], a
	ld a, 64
	ld [oamBuf + $89], a
	ld a, 72
	ld [oamBuf + $8D], a
	ld a, 80
	ld [oamBuf + $91], a
	ld a, 88
	ld [oamBuf + $95], a
	ld a, 96
	ld [oamBuf + $99], a
	ld a, 104
	ld [oamBuf + $9D], a
	ld a, $00
	ld [oamBuf + $83], a
	ld [oamBuf + $87], a
	ld [oamBuf + $8B], a
	ld [oamBuf + $8F], a
	ld [oamBuf + $93], a
	ld [oamBuf + $97], a
	ld [oamBuf + $9B], a
	ld [oamBuf + $9F], a
	ld a, "S"
	ld [oamBuf + $82], a
	ld a, "T"
	ld [oamBuf + $86], a
	ld a, "A"
	ld [oamBuf + $8A], a
	ld a, "G"
	ld [oamBuf + $8E], a
	ld a, "E"
	ld [oamBuf + $92], a
	ld a, $3E ; blank space.
	ld [oamBuf + $96], a
	ld a, [stageNum]
	call ToDecimalA
	push af
	ld a, b
	add a, "0"
	ld [oamBuf + $9A], a
	pop af
	add a, "0"
	ld [oamBuf + $9E], a
	ret

MakeBonusSprite:: ; $46F7
	ld a, 112
	ld [oamBuf + $80], a
	ld [oamBuf + $84], a
	ld [oamBuf + $88], a
	ld [oamBuf + $8C], a
	ld [oamBuf + $90], a
	ld a, 56
	ld [oamBuf + $81], a
	ld a, 64
	ld [oamBuf + $85], a
	ld a, 72
	ld [oamBuf + $89], a
	ld a, 80
	ld [oamBuf + $8D], a
	ld a, 88
	ld [oamBuf + $91], a
	ld a, $00
; BUG: these first four addresses are $10 more than they should be,
;   causing the 1st to be a duplicate of the 5th.
	ld [oamBuf + $93], a
	ld [oamBuf + $97], a
	ld [oamBuf + $9B], a
	ld [oamBuf + $9F], a
	ld [oamBuf + $93], a
	ld a, "B"
	ld [oamBuf + $82], a
	ld a, "O"
	ld [oamBuf + $86], a
	ld a, "N"
	ld [oamBuf + $8A], a
	ld a, "U"
	ld [oamBuf + $8E], a
	ld a, "S"
	ld [oamBuf + $92], a
	ret

MakePauseSprite:: ; $474C
	ld a, 112
	ld [oamBuf + $80], a
	ld [oamBuf + $84], a
	ld [oamBuf + $88], a
	ld [oamBuf + $8C], a
	ld [oamBuf + $90], a
	ld a, 56
	ld [oamBuf + $81], a
	ld a, 64
	ld [oamBuf + $85], a
	ld a, 72
	ld [oamBuf + $89], a
	ld a, 80
	ld [oamBuf + $8D], a
	ld a, 88
	ld [oamBuf + $91], a
	ld a, $00
; BUG: see MakeBonusSprite.
	ld [oamBuf + $93], a
	ld [oamBuf + $97], a
	ld [oamBuf + $9B], a
	ld [oamBuf + $9F], a
	ld [oamBuf + $93], a
	ld a, "P"
	ld [oamBuf + $82], a
	ld a, "A"
	ld [oamBuf + $86], a
	ld a, "U"
	ld [oamBuf + $8A], a
	ld a, "S"
	ld [oamBuf + $8E], a
	ld a, "E"
	ld [oamBuf + $92], a
	ret

DispWindowStageNum:: ; $47A1
	call WaitToDraw
	ld hl, mainStripArray
	ld a, $9D
	ld [hl+], a
	ld a, $62
	ld [hl+], a
	ld a, $02
	ld [hl+], a
	ld a, [stageNum]
	call ToDecimalA
	push af
	ld a, b
	add a, "0"
	ld [hl+], a
	pop af
	add a, "0"
	ld [hl+], a
	xor a
	ld [hl+], a
	inc a
	ldh [drawNeeded], a
	jp WaitVblank

DispNumLives:: ; $47C7
	call WaitToDraw
	ld hl, mainStripArray
	ld a, $9E
	ld [hl+], a
	ld a, $04
	ld [hl+], a
	ld a, $01
	ld [hl+], a
	ld a, [numLives]
	add a, "0"
	ld [hl+], a
	xor a
	ld [hl+], a
	inc a
	ldh [drawNeeded], a
	jp WaitVblank

DispTimeLabel:: ; $47E4
	call WaitToDraw
	ld hl, mainStripArray
	ld a, $9D
	ld [hl+], a
	ld a, $A1
	ld [hl+], a
	ld a, $04
	ld [hl+], a
	ld a, "T"
	ld [hl+], a
	ld a, "I"
	ld [hl+], a
	ld a, "M"
	ld [hl+], a
	ld a, "E"
	ld [hl+], a
.end::
	xor a
	ld [hl+], a
	inc a
	ldh [drawNeeded], a
	jp WaitVblank

EraseTimeLabel:: ; $4807
	call WaitToDraw
	ld hl, mainStripArray
	ld a, $9D
	ld [hl+], a
	ld a, $A1
	ld [hl+], a
	ld a, $04
	ld [hl+], a
	ld a, " "
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	jr DispTimeLabel.end

DispScore:: ; $481E
	ld hl, oamBuf + $14
	ldh a, [score]
	ld b, a
	ldh a, [score+1]
	call ToDecimalAB
	ld a, 64
	ld [hl+], a
	ld a, 136
	ld [hl+], a
	ld b, " "
	ldh a, [decOutput+4]
	cp $00
	jr z, .good_icon
	ld b, $BF ; flower.
	cp $01
	jr z, .good_icon
	ld b, $BC ; mushroom.
	cp $02
	jr z, .good_icon
	ld b, $C9 ; star.
.good_icon::
	ld a, b
	ld [hl+], a
	ld a, $00
	ld [hl+], a
	ld a, 56
	ld [hl+], a
	ld a, 136
	ld [hl+], a
	ldh a, [decOutput+3]
	add a, "0"
	ld [hl+], a
	ld a, $00
	ld [hl+], a
	ld a, 56
	ld [hl+], a
	ld a, 144
	ld [hl+], a
	ldh a, [decOutput+2]
	add a, "0"
	ld [hl+], a
	ld a, $00
	ld [hl+], a
	ld a, 56
	ld [hl+], a
	ld a, 152
	ld [hl+], a
	ldh a, [decOutput+1]
	add a, "0"
	ld [hl+], a
	ld a, $00
	ld [hl+], a
	ld a, 56
	ld [hl+], a
	ld a, 160
	ld [hl+], a
	ldh a, [decOutput]
	add a, "0"
	ld [hl+], a
	ld a, $00
	ld [hl+], a
	ldh a, [hiScore]
	ld b, a
	ldh a, [hiScore+1]
	call ToDecimalAB
	ld a, 40
	ld [hl+], a
	ld a, 136
	ld [hl+], a
	ld b, " "
	ldh a, [decOutput+4]
	cp $00
	jr z, .good_icon_hi
	ld b, $BF ; flower.
	cp $01
	jr z, .good_icon_hi
	ld b, $BC ; mushroom.
	cp $02
	jr z, .good_icon_hi
	ld b, $C9 ; star.
.good_icon_hi::
	ld a, b
	ld [hl+], a
	ld a, $00
	ld [hl+], a
	ld a, 32
	ld [hl+], a
	ld a, 136
	ld [hl+], a
	ldh a, [decOutput+3]
	add a, "0"
	ld [hl+], a
	ld a, $00
	ld [hl+], a
	ld a, 32
	ld [hl+], a
	ld a, 144
	ld [hl+], a
	ldh a, [decOutput+2]
	add a, "0"
	ld [hl+], a
	ld a, $00
	ld [hl+], a
	ld a, 32
	ld [hl+], a
	ld a, 152
	ld [hl+], a
	ldh a, [decOutput+1]
	add a, "0"
	ld [hl+], a
	ld a, $00
	ld [hl+], a
	ld a, 32
	ld [hl+], a
	ld a, 160
	ld [hl+], a
	ldh a, [decOutput]
	add a, "0"
	ld [hl+], a
	ld a, $00
	ld [hl+], a
	ret

DispHiScore:: ; $48E4
	ldh a, [hiScore]
	ld b, a
	ldh a, [hiScore+1]
	call ToDecimalAB
	ld hl, oamBuf + $28
	ld a, 112
	ld [hl+], a
	ld a, 112
	ld [hl+], a
	ld b, " "
	ldh a, [decOutput+4]
	cp $00
	jr z, .good_icon
	ld b, $BF
	cp $01
	jr z, .good_icon
	ld b, $BC
	cp $02
	jr z, .good_icon
	ld b, $C9
.good_icon::
	ld a, b
	ld [hl+], a
	ld a, $00
	ld [hl+], a
	ld a, 104
	ld [hl+], a
	ld a, 112
	ld [hl+], a
	ldh a, [decOutput+3]
	add a, "0"
	ld [hl+], a
	ld a, $00
	ld [hl+], a
	ld a, 104
	ld [hl+], a
	ld a, 120
	ld [hl+], a
	ldh a, [decOutput+2]
	add a, "0"
	ld [hl+], a
	ld a, $00
	ld [hl+], a
	ld a, 104
	ld [hl+], a
	ld a, 128
	ld [hl+], a
	ldh a, [decOutput+1]
	add a, "0"
	ld [hl+], a
	ld a, $00
	ld [hl+], a
	ld a, 104
	ld [hl+], a
	ld a, 136
	ld [hl+], a
	ldh a, [decOutput]
	add a, "0"
	ld [hl+], a
	ld a, $00
	ld [hl+], a
	ret

DispSpecialBonus:: ; $4949
	ld hl, oamBuf + $88
	ld a, b
	ld b, c
	call ToDecimalAB
	ld a, 120
	ld [hl+], a
	ld a, 48
	ld [hl+], a
	ldh a, [decOutput+3]
	add a, "0"
	ld [hl+], a
	ld a, $00
	ld [hl+], a
	ld a, 120
	ld [hl+], a
	ld a, 56
	ld [hl+], a
	ldh a, [decOutput+2]
	add a, "0"
	ld [hl+], a
	ld a, $00
	ld [hl+], a
	ld a, 120
	ld [hl+], a
	ld a, 64
	ld [hl+], a
	ldh a, [decOutput+1]
	add a, "0"
	ld [hl+], a
	ld a, $00
	ld [hl+], a
	ld a, 120
	ld [hl+], a
	ld a, 72
	ld [hl+], a
	ldh a, [decOutput]
	add a, "0"
	ld [hl+], a
	ld a, $00
	ld [hl+], a
	ret

DispGameOver:: ; $498A
	ld a, 80
	ld [oamBuf + $00], a
	ld [oamBuf + $04], a
	ld [oamBuf + $08], a
	ld [oamBuf + $0C], a
	ld [oamBuf + $10], a
	ld [oamBuf + $14], a
	ld [oamBuf + $18], a
	ld [oamBuf + $1C], a
	ld a, 56
	ld [oamBuf + $01], a
	ld a, 64
	ld [oamBuf + $05], a
	ld a, 72
	ld [oamBuf + $09], a
	ld a, 80
	ld [oamBuf + $0D], a
	ld a, 96
	ld [oamBuf + $11], a
	ld a, 104
	ld [oamBuf + $15], a
	ld a, 112
	ld [oamBuf + $19], a
	ld a, 120
	ld [oamBuf + $1D], a
	ld a, $00
	ld [oamBuf + $03], a
	ld [oamBuf + $07], a
	ld [oamBuf + $0B], a
	ld [oamBuf + $0F], a
	ld [oamBuf + $13], a
	ld [oamBuf + $17], a
	ld [oamBuf + $1B], a
	ld [oamBuf + $1F], a
	ld a, "G"
	ld [oamBuf + $02], a
	ld a, "A"
	ld [oamBuf + $06], a
	ld a, "M"
	ld [oamBuf + $0A], a
	ld a, "E"
	ld [oamBuf + $0E], a
	ld a, "O"
	ld [oamBuf + $12], a
	ld a, "V"
	ld [oamBuf + $16], a
	ld a, "E"
	ld [oamBuf + $1A], a
	ld a, "R"
	ld [oamBuf + $1E], a
	ret

MakeLeftBorder:: ; $4A0F
	ld hl, oamBuf + $3C
	ld e, $18
	ld d, $11
.loop::
	ld a, e
	ld [hl+], a
	ld a, $08
	ld [hl+], a
	ld a, $B4
	ld [hl+], a
	ld a, $00
	ld [hl+], a
	ld a, e
	add a, $08
	ld e, a
	dec d
	jr nz, .loop
	ret

DispBounceSpeed:: ; $4A29
	ret
; dummied out
	ld hl, oamBuf + $10
	ld a, 152
	ld [hl+], a
	ld a, 16
	ld [hl+], a
	ldh a, [bounceSpeed]
	add a, "0"
	ld [hl+], a
	ld a, $00
	ld [hl+], a
	ret

GameScreen:: ; $4A3C
	strip $9C00, 0, $BE
	strip $9C20, STRIP_COLUMN|STRIP_FILL|24, $B4
	strip $9800, 0, $BD
	strip $9801, STRIP_FILL|20, $B5
	strip $9C21, 0, "TOP"
	strip $9C81, 0, $B8,$B9,$BA,$BB ; "SCORE"
	strip $9D41, 0, $C0,$C1,$C2,$C3 ; "STAGE"
	strip $9E02, 0, $B1,"x"
	db $00

DispMarioFrame:: ; $4A66
	sla a
	ld e, a
	ld d, $00
	ld hl, MarioFramePointers
	add hl, de
	ld d, [hl]
	inc hl
	ld e, [hl]
	ld hl, oamBuf + $88
	ld a, $04
.loop::
	push af
	ld a, [de]
	add a, c
	ld [hl+], a
	inc de
	ld a, [de]
	add a, b
	ld [hl+], a
	inc de
	ld a, [de]
	ld [hl+], a
	inc de
	ld a, [de]
	ld [hl+], a
	inc de
	pop af
	dec a
	jr nz, .loop
	ret

MarioFramePointers:: ; $4A8B
for i, 13
	be MarioFrame{d:i}
endr

; jump in & out of ball
MarioFrame0:: ; $4AA5
	db 0, 0, $06, $80
	db 0, 8, $07, $80
	db 8, 0, $08, $80
	db 8, 8, $09, $80
MarioFrame1:: ; $4AB5
	db 0, 0, $0A, $80
	db 0, 8, $0B, $80
	db 8, 0, $0C, $80
	db 8, 8, $0D, $80
MarioFrame2:: ; $4AC5
	db 0, 0, $0E, $80
	db 0, 8, $0F, $80
	db 8, 0, $10, $80
	db 8, 8, $11, $80
MarioFrame3:: ; $4AD5
	db 0, 0, $12, $80
	db 0, 8, $13, $80
	db 8, 0, $14, $80
	db 8, 8, $15, $80
MarioFrame4:: ; $4AE5
	db 0, 0, $16, $80
	db 0, 8, $17, $80
	db 8, 0, $18, $80
	db 8, 8, $19, $80
MarioFrame5:: ; $4AF5
	db 0, 0, $1A, $80
	db 0, 8, $17, $80
	db 8, 0, $18, $80
	db 8, 8, $19, $80
MarioFrame6:: ; $4B05
	db 0, 0, $17, $A0
	db 0, 8, $1A, $A0
	db 8, 0, $19, $A0
	db 8, 8, $18, $A0

; puff of smoke under ball
MarioFrame7:: ; $4B15
	db 0, 0, " ", $00
	db 0, 8, " ", $00
	db 8, 0, $1B, $00
	db 8, 8, $1B, $20
MarioFrame8:: ; $4B25
	db 0, 0, $1C, $00
	db 0, 8, $1C, $20
	db 8, 0, $1D, $00
	db 8, 8, $1D, $20
MarioFrame9:: ; $4B35
	db 0, 0, $1E, $00
	db 0, 8, $1E, $20
	db 8, 0, $1F, $00
	db 8, 8, $1F, $20

; "NICE PLAY!" wink
MarioFrame10:: ; $4B45
	db 0, 0, " ", $00
	db 0, 8, " ", $00
	db 8, 0, " ", $00
	db 8, 8, " ", $00
MarioFrame11:: ; $4B55
	db 0, 0, $21, $00
	db 0, 8, $22, $00
	db 8, 0, $23, $00
	db 8, 8, $24, $00
MarioFrame12:: ; $4B65
	db 0, 0, $21, $00
	db 0, 8, $22, $00
	db 8, 0, $25, $00
	db 8, 8, $26, $00
