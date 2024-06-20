include "common.inc"
setcharmap DMG

SECTION FRAGMENT "Main code", ROM0
DmgMain:: ; $0511
	nop
	call TurnOnAudio
	call PrepareSerial
	xor a
	ldh [gameMode], a
	ldh [specialStage], a
	ldh [scrollFlag], a
.loop::
	call MainLoop
	call RandomNumber
	call WaitVblank
	jp .loop

MainLoop:: ; $052B
	ldh a, [buttonsDown]
	and PADF_START
	jr nz, .do
	ldh a, [buttonsPressed]
	and PADF_SELECT
	jr nz, .do
	ld a, $01
	ldh [gameMode], a
	ret
.do::
	ldh a, [gameMode]
	sla a
	ld c, a
	ld b, $00
	ld hl, MainFuncList
	add hl, bc
	ld a, [hl+]
	ld b, a
	ld h, [hl]
	ld l, b
	jp hl

MainFuncList:: ; $054C
	dw ResetHiScore, TitleScreenNoMusic, TitleScreen, DemoMode
	dw StartGame, AwaitBall, Func07A4, LostBall
	dw NextStage, Func0839, GiveSpecialBonus, GameOver
	dw Func0907, WaitVblank.end, WaitVblank.end, WaitVblank.end

ResetHiScore:: ; $056C
	ld a, 200
	ldh [hiScore], a
	xor a
	ldh [hiScore+1], a
	ld a, $01
	ldh [gameMode], a
	ret

TitleScreenNoMusic:: ; $0578
	ld a, $04
	ld [titleScreenMusicCounter], a
	ld a, $02
	ldh [gameMode], a
	ret

TitleScreen:: ; $0582
	call TurnOffLCD
	call SaveIE
	ldh a, [ieBackup]
	and ~IEF_STAT
	ldh [ieBackup], a
	call FillMap0
	call ClearOAM
	ld de, TitleScreenStripArray
	call DrawStripArray.start
	call DispHiScore
	ld a, %11100100
	ldh [rBGP], a
	ldh a, [lcdcTmp]
	and ~LCDCF_WINON
	ldh [lcdcTmp], a
	call RestoreIE
	call TurnOnLCD
	ld a, [titleScreenMusicCounter]
	inc a
	cp $05
	jr nz, .skip_zero
	xor a
.skip_zero::
	ld [titleScreenMusicCounter], a
	cp $00
	push af
	push af
	call z, StartAudio
	pop af
	call z, PlayMusic.one
	pop af
	call nz, CancelAudio
	ld a, $03
	ld [demoCountdown], a
.loop::
	call WaitVblank
	ldh a, [frameCount]
	cp $00
	jr nz, .skip_dec
	ld a, [demoCountdown]
	dec a
	ld [demoCountdown], a
	jr z, .start_demo
.skip_dec::
	ldh a, [buttonsPressed]
	and PADF_START
	jr z, .start_game
	ldh a, [paddleButonsPressed]
	and $80
	jr nz, .loop
.start_game::
	xor a
	ld [stageId], a
	ld [stageNum], a
	ld [specialNum], a
	ldh [bonusesGiven], a
	ldh [score], a
	ldh [score+1], a
	ld a, $04
	ld [numLives], a
	call CountBonus
	call StartAudio
	call DispNicePlay
	ld a, $04
	ldh [gameMode], a
	ret
.start_demo::
	ld a, $03
	ldh [gameMode], a
	ret

DemoMode:: ; $0613
	call CancelAudio
	call DispNicePlay
.loop1::
	call RandomNumber
	and $1F
	ld [stageId], a
	ld b, a
	ld e, $03
	call MultiplyBxE
	ld hl, StagePointers
	add hl, bc
	ld a, [hl]
	bit 7, a
	jr nz, .loop1
	ld a, $FF
	ld [stageNum], a
	inc a
	ldh [score], a
	ldh [score+1], a
	ld [numLives], a
	call StartGame
	ld a, $0A
	ld [demoCountdown], a
	call Func10FB
	call AwaitBall.continue
	ldh a, [ballPosX]
	sub $0B
	ldh [racquetX], a
	call MakeRacquetSprite
	ld a, 16
	call DelayFrames
.loop2::
	call UpdateScroll
	call Func0CA6
	call MakeRacquetSprite
	ldh a, [racquetWidth]
	ld b, a
	ld a, $80
	sub b
	ld b, a
	ldh a, [ballPosX]
	sub $0B
	ldh [racquetX], a
	call MoveRacquet.check
	call RandomNumber
	call WaitVblank
	ldh a, [buttonsPressed]
	and PADF_START
	jr z, .quit_demo
	ldh a, [paddleButonsPressed]
	and $80
	jr z, .quit_demo
	ldh a, [frameCount]
	cp $00
	jr nz, .loop2
	ld a, [demoCountdown]
	dec a
	ld [demoCountdown], a
	jr nz, .loop2
	ld a, 32
	call DelayFrames
	ld a, $02
	ldh [gameMode], a
	ret
.quit_demo::
	ld a, $01
	ldh [gameMode], a
	ret

StartGame:: ; $06A2
	call EraseTimeLabel
	call EraseSpecialBonusText
	xor a
	ldh [specialStage], a
	ldh [scrollFlag], a
	ldh [smallRacquetFlag], a
	ld a, 24
	ldh [racquetWidth], a
	ld a, [stageId]
	ld b, a
	ld e, $03
	call MultiplyBxE
	ld hl, StagePointers
	add hl, bc
	ld a, [hl]
	bit 7, a
	push af
	push af
	call nz, IncSpecialNum
	pop af
	call z, IncStageNum
	pop af
	bit 6, a
	call nz, SetupScroll
	ld a, 40
	ldh [racquetX], a
	ld a, 144
	ldh [racquetY], a
	ld a, [stageId]
	call SetupStage
	call CountBricks
	call Func0B9D
	xor a ; ???
	ldh a, [stageRowDrawing]
	call MakeLeftBorder
	call DispScore
	call DispNumLives
	call DispBounceSpeed
	ld a, [stageNum]
	cp $01
	call z, Func43DC
	ldh a, [specialStage]
	cp $00
	push af
	call z, MakeStageNumSprite
	pop af
	call nz, MakeBonusSprite
	call DispScore
	call DispBounceSpeed
	call DispNumLives
	call DispWindowStageNum
	ld a, 16
	call DelayFrames
	call RedrawStage
	call ClearOAM
	call DispScore
	call DispBounceSpeed
	call MakeLeftBorder
	ldh a, [specialStage]
	cp $00
	call nz, Func19CC
	xor a
	ldh [stageFallCounter], a
	ld a, $05
	ldh [gameMode], a
	ret

IncSpecialNum:: ; $0738
	ld a, $01
	ldh [specialStage], a
	ld a, [specialNum]
	inc a
	ld [specialNum], a
	ret

IncStageNum:: ; $0744
	ld a, [stageNum]
	inc a
	ld [stageNum], a
	ret

SetupScroll:: ; $074C
	and $3F
	sla a
	ld c, a
	ld b, $00
	ld hl, ScrollConfigs
	add hl, bc
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld bc, scrollModulo
	ld de, scrollCounters
	ld a, $14
.loop::
	push af
	ld a, [hl+]
	ld [bc], a
	and $7F
	ld [de], a
	inc bc
	inc de
	pop af
	dec a
	jr nz, .loop
	ld a, $01
	ldh [scrollFlag], a
	ret

AwaitBall:: ; $0773
	call UpdateScroll
	call Func109D
	ldh a, [buttonsPressed]
	and PADF_A
	jr z, .continue
	ldh a, [paddleButonsPressed]
	and $80
	ret nz
.continue::
	xor a
	ldh [speedUpCounter], a
	ldh [changeAngleCounter], a
	call Func116D.sub_1177
	call Func101B
	call DispBounceSpeed
	call DispNumLives
	call PlaySound.seven
	ldh a, [specialStage]
	cp $00
	call nz, PlayMusic.six
	ld a, $06
	ldh [gameMode], a
	ret

Func07A4:: ; $07A4
	ldh a, [specialStage]
	cp $00
	call nz, SpecialTimeTick
	call UpdateScroll
	call Func0CA6
	call Func109D
	ldh a, [buttonsPressed]
	and PADF_START
	jr z, .start_pressed
	ldh a, [paddleButonsPressed]
	and $80
	ret nz
	ld a, $FF
	ldh [paddleButonsPressed], a
.start_pressed::
	ldh a, [specialStage]
	cp $00
	ret nz
	call MakePauseSprite
	call PlayMusic.four
	ld a, $0C
	ldh [gameMode], a
	ret

LostBall:: ; $07D3
	call StopAudio
	call DispSmoke
	ld a, 64
	call DelayFrames
	ldh a, [specialStage]
	cp $00
	jr nz, NextStage
	ld a, $0B
	ldh [gameMode], a
	ld a, [numLives]
	cp $00
	ret z
	dec a
	ld [numLives], a
	call DispNumLives
	xor a
	ldh [smallRacquetFlag], a
	ld a, 24
	ldh [racquetWidth], a
	ld a, $02
	ldh [stageFallCounter], a
	ld a, $05
	ldh [gameMode], a
	ret

NextStage:: ; $0805
	ldh a, [specialStage]
	cp $00
	push af
	call z, Func0823
	pop af
	call nz, GiveSpecialBonus
	call Func082B
	ld b, $04
	ld a, [stageId]
	cp $00
	jr nz, .not_stage01
	ld b, $09
.not_stage01::
	ld a, b
	ldh [gameMode], a
	ret

Func0823:: ; $0823
	call PlayMusic.five
	ld a, 144
	jp DelayFrames

Func082B:: ; $082B
	ld a, [stageId]
	inc a
	cp $20
	jr c, .skip_zero
	ld a, $00
.skip_zero::
	ld [stageId], a
	ret

Func0839:: ; $0839
	call FadeOut
	ldh a, [ieBackup]
	and ~IEF_STAT
	ldh [ieBackup], a
	call DispNicePlay
	ldh a, [ieBackup]
	and ~IEF_STAT
	ldh [ieBackup], a
	ldh [rIE], a
	call MakeLeftBorder
	call DispScore
	call DispNumLives
	call DispBounceSpeed
	call DispWindowStageNum
	call PlayMusic.twelve
	call FadeIn
rept HIGH(672)
	ld a, $00
	call DelayFrames
endr
	ld a, LOW(672)
	call DelayFrames
	ld a, $01
	call DelayFrames
	call MarioWink
rept HIGH(257)
	ld a, $00
	call DelayFrames
endr
	ld a, LOW(257)
	call DelayFrames
	call DrawTryAgainText
	ld a, 192
	call DelayFrames
	call EraseTryAgainText
	call FadeOut
	ldh a, [ieBackup]
	or IEF_STAT
	ldh [ieBackup], a
	ldh [rIE], a
	call ClearStage
	call DrawStage
	call FadeIn
	ld a, $04
	ldh [gameMode], a
	ret

FadeIn:: ; $08A7
; out(A) = $E4
; out(B) = 0
; out(HL) = $08C6
	ld hl, FadeInPalette
	jr FadeOut.start

FadeOut:: ; $08AC
; out(A) = $E4
; out(B) = 0
; out(HL) = $08CA
	ld hl, FadeOutPalette
.start::
	ld b, $04
.loop::
	ld a, [hl+]
	call SetPalette
	push bc
	push hl
	ld a, 16
	call DelayFrames
	pop hl
	pop bc
	dec b
	jr nz, .loop
	ret

FadeInPalette:: ; $08C2
	db %00000000, %01000000, %10010000, %11100100
FadeOutPalette:: ; $08C6
	db %11100100, %10010000, %01000000, %00000000

SetPalette:: ; $08CA
; set all palettes to in(A)
	ldh [rBGP], a
	ldh [rOBP0], a
	ldh [rOBP1], a
	ret

GameOver:: ; $08D1
	call Func444D
	ld a, 64
	call DelayFrames
	call TurnOffLCD
	call SaveIE
	call FillMap0
	call ClearOAM
	ldh a, [lcdcTmp]
	and ~LCDCF_WINON
	ldh [lcdcTmp], a
	ldh a, [ieBackup]
	and ~IEF_STAT
	ldh [ieBackup], a
	call PlayMusic.three
	call DispGameOver
	call RestoreIE
	call TurnOnLCD
	ld a, 192
	call DelayFrames
	ld a, $01
	ldh [gameMode], a
	ret

Func0907:: ; $0907
	ldh a, [buttonsPressed]
	and PADF_START
	jr z, .start
	ldh a, [paddleButonsPressed]
	and $80
	ret nz
	ld a, $FF
	ldh [paddleButonsPressed], a
.start::
	call ClearOAM
	call DispScore
	call DispBounceSpeed
	call MakeLeftBorder
	call PlayMusic.four
	ld a, $06
	ldh [gameMode], a
	ret
