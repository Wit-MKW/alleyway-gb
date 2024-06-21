include "common.inc"
setcharmap DMG

SECTION FRAGMENT "Main code", ROM0
DmgMain:: ; $0511
	nop
	call TurnOnAudio
	call PrepareSerial
	xor a
	ldh [gameMode], a ; gameMode_RESET_HISCORE
	ldh [specialStage], a
	ldh [scrollFlag], a
.loop::
	call MainLoop
	call RandomNumber
	call WaitVblank
	jp .loop

MainLoop:: ; $052B
; perform the action dictated by gameMode
; if game is reset: out(A) = gameMode_TITLE_MUSIC
; otherwise: see MainFuncList functions

; reset on START+SELECT
	ldh a, [buttonsDown]
	and PADF_START
	jr nz, .no_reset
	ldh a, [buttonsPressed]
	and PADF_SELECT
	jr nz, .no_reset
	ld a, gameMode_TITLE_MUSIC
	ldh [gameMode], a
	ret
.no_reset::
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
	dw ResetHiScore, TitleScreenWithMusic, TitleScreen, DemoMode
	dw StartGame, AwaitBall, GamePlaying, LostBall
	dw NextStage, DispNicePlay, FinishSpecialStage, GameOver
	dw PauseGame, WaitVblank.end, WaitVblank.end, WaitVblank.end

ResetHiScore:: ; $056C
; set high score to 0200
; out(A) = gameMode_TITLE_MUSIC
	ld a, 200
	ldh [hiScore], a
	xor a
	ldh [hiScore+1], a
	ld a, gameMode_TITLE_MUSIC
	ldh [gameMode], a
	ret

TitleScreenWithMusic:: ; $0578
; set title music to play before returning to title screen
; out(A) = gameMode_TITLE_SCREEN
	ld a, $04
	ld [titleScreenMusicCounter], a
	ld a, gameMode_TITLE_SCREEN
	ldh [gameMode], a
	ret

TitleScreen:: ; $0582
; display title screen
; out(A) = gameMode_DEMO if demo starts, gameMode_START_GAME otherwise
	call TurnOffLCD
	call SaveIE
; disable STAT interrupt
	ldh a, [ieBackup]
	and ~IEF_STAT
	ldh [ieBackup], a
; clear graphics
	call FillNameTable0
	call ClearOAM
; display game logo
	ld de, TitleScreenStripArray
	call DrawStripArray.start
; display high score
	call DispHiScore
; set standard palette
	ld a, %11100100
	ldh [rBGP], a
; disable window
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
; play title music every 5th time demo mode times out
	push af
	push af
	call z, StartAudio
	pop af
	call z, PlayMusic.title
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
; reset game variables before starting
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
	call DispGameScreen
	ld a, gameMode_START_GAME
	ldh [gameMode], a
	ret
.start_demo::
	ld a, gameMode_DEMO
	ldh [gameMode], a
	ret

DemoMode:: ; $0613
; show a demo of the game
; out(A) = gameMode_TITLE_MUSIC if demo is quit manually, gameMode_TITLE_SCREEN if it times out
	call CancelAudio
	call DispGameScreen
.pick_stage::
; choose a stage at random
	call RandomNumber
	and $1F
	ld [stageId], a
	ld b, a
	ld e, StagePointers_SIZEOF
	call MultiplyBxE
	ld hl, StagePointers
	add hl, bc
	ld a, [hl]
; try again if it's a special stage
	bit SPECIAL_BIT, a
	jr nz, .pick_stage
	ld a, $FF
	ld [stageNum], a
	inc a
	ldh [score], a
	ldh [score+1], a
	ld [numLives], a
	call StartGame
	ld a, $0A
	ld [demoCountdown], a
	call RacquetEnd
	call AwaitBall.continue
	ldh a, [ballPosX]
	sub 11
	ldh [racquetX], a
	call MakeRacquetSprite
	ld a, 16
	call DelayFrames
.game_loop::
	call UpdateScroll
	call UpdateBall
	call MakeRacquetSprite
	ldh a, [racquetWidth]
	ld b, a
	ld a, $80
	sub b
	ld b, a
	ldh a, [ballPosX]
	sub 11
	ldh [racquetX], a
	call MoveRacquet.check
	call RandomNumber
	call WaitVblank
; quit when START (or paddle button) is pressed
	ldh a, [buttonsPressed]
	and PADF_START
	jr z, .quit_demo
	ldh a, [paddleButonsPressed]
	and $80
	jr z, .quit_demo
	ldh a, [frameCount]
	cp $00
	jr nz, .game_loop
	ld a, [demoCountdown]
	dec a
	ld [demoCountdown], a
	jr nz, .game_loop
; freeze for half a second before returning
	ld a, 32
	call DelayFrames
	ld a, gameMode_TITLE_SCREEN
	ldh [gameMode], a
	ret
.quit_demo::
	ld a, gameMode_TITLE_MUSIC
	ldh [gameMode], a
	ret

StartGame:: ; $06A2
; start a new stage
; out(A) = gameMode_AWAIT_BALL

; erase any text that a special stage might have written
	call EraseTimeLabel
	call EraseSpecialBonusText
; reset per-stage variables
	xor a
	ldh [specialStage], a
	ldh [scrollFlag], a
	ldh [smallRacquetFlag], a
	ld a, 24
	ldh [racquetWidth], a
; get the current stage's properties
	ld a, [stageId]
	ld b, a
	ld e, StagePointers_SIZEOF
	call MultiplyBxE
	ld hl, StagePointers
	add hl, bc
	ld a, [hl]
	bit SPECIAL_BIT, a
	push af
	push af
	call nz, IncSpecialNum
	pop af
	call z, IncStageNum
	pop af
	bit SCROLLER_BIT, a
	call nz, SetupScroll
; place racquet on-screen
	ld a, 32 + OAM_X_OFS
	ldh [racquetX], a
	ld a, 128 + OAM_Y_OFS
	ldh [racquetY], a
; setup stage layout
	ld a, [stageId]
	call SetupStage
	call CountBricks
	call ResetScroll
	xor a
; BUG: operands switched.
	ldh a, [stageRowDrawing]
; fill out window information
	call MakeLeftBorder
	call DispScore
	call DispNumLives
	call DispBounceSpeed
; show Mario jumping into the racquet on stage 01
	ld a, [stageNum]
	cp $01
	call z, MarioStart
	ldh a, [specialStage]
	cp $00
	push af
	call z, MakeStageNumSprite
	pop af
	call nz, MakeBonusSprite
; finish filling out window information
	call DispScore
	call DispBounceSpeed
	call DispNumLives
	call DispWindowStageNum
	ld a, 16
	call DelayFrames
; finalise screen setup
	call RedrawStage
	call ClearOAM
	call DispScore
	call DispBounceSpeed
	call MakeLeftBorder
	ldh a, [specialStage]
	cp $00
	call nz, SpecialStart
	xor a
	ldh [stageFallCounter], a
	ld a, gameMode_AWAIT_BALL
	ldh [gameMode], a
	ret

IncSpecialNum:: ; $0738
; increment the special stage count
; out(A) = ++[specialNum]
	ld a, $01
	ldh [specialStage], a
	ld a, [specialNum]
	inc a
	ld [specialNum], a
	ret

IncStageNum:: ; $0744
; increment the non-special stage count
; out(A) = ++[stageNum]
	ld a, [stageNum]
	inc a
	ld [stageNum], a
	ret

SetupScroll:: ; $074C
; setup scroll counters based on StagePointers_RULES byte in(A)
; out(A) = 1
; out(BC) = scrollModulo + STAGE_ROWS_ONSCREEN
; out(DE) = scrollCounters + STAGE_ROWS_ONSCREEN
; clobbers HL
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
	ld a, STAGE_ROWS_ONSCREEN
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
; wait for the player to press A & deploy a ball
; out(A) = gameMode_GAME_PLAYING
	call UpdateScroll
	call MoveRacquetSprite
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
	call CheckStageFall.init_timer
	call DeployBall
	call DispBounceSpeed
	call DispNumLives
	call PlaySound.deploy_ball
	ldh a, [specialStage]
	cp $00
	call nz, PlayMusic.special
	ld a, gameMode_GAME_PLAYING
	ldh [gameMode], a
	ret

GamePlaying:: ; $07A4
; run one frame of gameplay
; out(A) = gameMode_PAUSE if game paused, $80 otherwise
	ldh a, [specialStage]
	cp $00
	call nz, SpecialTimeTick
	call UpdateScroll
	call UpdateBall
	call MoveRacquetSprite
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
	call PlayMusic.pause
	ld a, gameMode_PAUSE
	ldh [gameMode], a
	ret

LostBall:: ; $07D3
; animate the ball falling out of play
; out(A) = 0 if out of lives, gameMode_AWAIT_BALL otherwise
	call StopAudio
	call DispSmoke
	ld a, 64
	call DelayFrames
	ldh a, [specialStage]
	cp $00
	jr nz, NextStage
	ld a, gameMode_GAME_OVER
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
	ld a, gameMode_AWAIT_BALL
	ldh [gameMode], a
	ret

NextStage:: ; $0805
; finish this stage & proceed to the next
; out(A) = out(B)
; out(B) = gameMode_NICE_PLAY after special 24, gameMode_START_GAME otherwise
	ldh a, [specialStage]
	cp $00
	push af
	call z, PlayStageEndMusic
	pop af
	call nz, FinishSpecialStage
	call IncStageId
	ld b, gameMode_START_GAME
	ld a, [stageId]
	cp $00
	jr nz, .not_finished
	ld b, gameMode_NICE_PLAY
.not_finished::
	ld a, b
	ldh [gameMode], a
	ret

PlayStageEndMusic:: ; $0823
; play music after finishing a standard stage
; out(A) = 0
	call PlayMusic.stage_end
	ld a, 144
	jp DelayFrames

IncStageId:: ; $082B
; increment the stage ID, wrapping from 31+ to 0
; out(A) = new stageId
	ld a, [stageId]
	inc a
	cp $20
	jr c, .skip_zero
	ld a, $00
.skip_zero::
	ld [stageId], a
	ret

DispNicePlay:: ; $0839
; congratulate the player for passing all 24 standard stages
; out(A) = gameMode_START_GAME
	call FadeOut
	ldh a, [ieBackup]
	and ~IEF_STAT
	ldh [ieBackup], a
	call DispGameScreen
	ldh a, [ieBackup]
	and ~IEF_STAT
	ldh [ieBackup], a
	ldh [rIE], a
	call MakeLeftBorder
	call DispScore
	call DispNumLives
	call DispBounceSpeed
	call DispWindowStageNum
	call PlayMusic.nice_play
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
	call DispTryAgainText
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
	ld a, gameMode_START_GAME
	ldh [gameMode], a
	ret

FadeIn:: ; $08A7
; out(A) = %11100100
; out(B) = 0
; out(HL) = FadeInPalette + 4
	ld hl, FadeInPalette
	jr FadeOut.start

FadeOut:: ; $08AC
; out(A) = 0
; out(B) = 0
; out(HL) = FadeOutPalette + 4
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
; display a "GAME OVER" screen
; out(A) = gameMode_TITLE_MUSIC
	call MarioEnd
	ld a, 64
	call DelayFrames
	call TurnOffLCD
	call SaveIE
	call FillNameTable0
	call ClearOAM
	ldh a, [lcdcTmp]
	and ~LCDCF_WINON
	ldh [lcdcTmp], a
	ldh a, [ieBackup]
	and ~IEF_STAT
	ldh [ieBackup], a
	call PlayMusic.game_over
	call DispGameOver
	call RestoreIE
	call TurnOnLCD
	ld a, 192
	call DelayFrames
	ld a, gameMode_TITLE_MUSIC
	ldh [gameMode], a
	ret

PauseGame:: ; $0907
; don't do anything unless the player presses START
; out(A) = gameMode_GAME_PLAYING
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
	call PlayMusic.pause
	ld a, gameMode_GAME_PLAYING
	ldh [gameMode], a
	ret
