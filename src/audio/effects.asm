include "common.inc"
setcharmap DMG

SECTION FRAGMENT "Audio", ROM0
UpdateAud1:: ; $69FB
	ld a, [audioPlaying1]
	cp EFFECT_ONE_UP
	jp z, .continue_one_up
	ld a, [audioStarting1]
	cp EFFECT_BOUNCE_RACQUET
	jp z, .start_bounce_racquet
	cp EFFECT_BRICK1
	jp z, .start_brick1
	cp EFFECT_BUMPER
	jp z, .start_bumper
	cp EFFECT_ONE_UP
	jp z, .start_one_up
	cp EFFECT_BRICK2
	jp z, .start_brick2
	cp EFFECT_BRICK3
	jp z, .start_brick3
	cp EFFECT_DEPLOY_BALL
	jp z, .start_deploy_ball
	cp EFFECT_SPECIAL_BONUS
	jp z, .start_special_bonus
	cp EFFECT_MARIO_START
	jp z, .start_mario_start
	cp EFFECT_MARIO_END
	jp z, .start_mario_end
	cp EFFECT_RACQUET_SHRINK
	jp z, .start_racquet_shrink
	cp EFFECT_BOUNCE_WALL
	jp z, .start_bounce_wall
	ld a, [audioPlaying1]
	cp EFFECT_BRICK1
	jp z, .continue_brick1
	cp EFFECT_BUMPER
	jp z, .continue_bumper
	cp EFFECT_BOUNCE_RACQUET
	jp z, .continue_bounce_racquet
	cp EFFECT_BRICK2
	jp z, .continue_brick2
	cp EFFECT_BRICK3
	jp z, .continue_brick3
	cp EFFECT_DEPLOY_BALL
	jp z, .continue_deploy_ball
	cp EFFECT_SPECIAL_BONUS
	jp z, .continue_special_bonus
	cp EFFECT_MARIO_START
	jp z, .continue_mario_start
	cp EFFECT_MARIO_END
	jp z, .continue_mario_end
	cp EFFECT_RACQUET_SHRINK
	jp z, .continue_racquet_shrink
	cp EFFECT_BOUNCE_WALL
	jp z, .continue_bounce_wall
	ret
.start_one_up::
	ld a, EFFECT_ONE_UP
	ld [audioPlaying1], a
	ld a, $07
	ld [audioSampleCounter1], a
	ld hl, SampleOneUp_07
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.start_brick1::
	ld a, [audioPlayingRacquetShrink]
	cp $01
	jp z, .no_start_brick1
	ld a, EFFECT_BRICK1
	ld [audioPlaying1], a
	ld a, $05
	ld [audioSampleCounter1], a
	ld hl, SampleBrick1_04
	ld c, LOW(rNR10)
	call LoadFiveRegs
.no_start_brick1::
	ret
.start_bumper::
	ld a, [audioPlayingRacquetShrink]
	cp $01
	jp z, .no_start_bumper
	ld a, EFFECT_BUMPER
	ld [audioPlaying1], a
	ld a, $05
	ld [audioSampleCounter1], a
	ld hl, SampleBumper_05
	ld c, LOW(rNR10)
	call LoadFiveRegs
.no_start_bumper::
	ret
.start_bounce_racquet::
	ld a, [audioPlayingRacquetShrink]
	cp $01
	jp z, .no_start_bounce_racquet
	ld a, EFFECT_BOUNCE_RACQUET
	ld [audioPlaying1], a
	ld a, $04
	ld [audioSampleCounter1], a
	ld hl, SampleBounceRacquet_04
	ld c, LOW(rNR10)
	call LoadFiveRegs
.no_start_bounce_racquet::
	ret
.start_brick2::
	ld a, [audioPlayingRacquetShrink]
	cp $01
	jp z, .no_start_brick2
	ld a, EFFECT_BRICK2
	ld [audioPlaying1], a
	ld a, $05
	ld [audioSampleCounter1], a
	ld hl, SampleBrick2_04
	ld c, LOW(rNR10)
	call LoadFiveRegs
.no_start_brick2::
	ret
.start_brick3::
	ld a, [audioPlayingRacquetShrink]
	cp $01
	jp z, .no_start_brick3
	ld a, EFFECT_BRICK3
	ld [audioPlaying1], a
	ld a, $05
	ld [audioSampleCounter1], a
	ld hl, SampleBrick3_04
	ld c, LOW(rNR10)
	call LoadFiveRegs
.no_start_brick3::
	ret
.start_deploy_ball::
	ld a, EFFECT_DEPLOY_BALL
	ld [audioPlaying1], a
	ld a, $04
	ld [audioSampleCounter1], a
	ld hl, SampleDeployBall_04
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.start_special_bonus::
	ld a, EFFECT_SPECIAL_BONUS
	ld [audioPlaying1], a
	ld a, $05
	ld [audioSampleCounter1], a
	ld hl, SampleSpecialBonus_05
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.start_mario_start::
	ld a, EFFECT_MARIO_START
	ld [audioPlaying1], a
	ld a, $63 ; G#5
	ld [audioSpecialLow1], a
	ld a, $0A ; C5
	ld [audioSpecialLow2], a
	ld a, $07 | AUDHIGH_RESTART|AUDHIGH_LENGTH_OFF
	ld [audioSpecialHigh1], a
	ld a, $FF
	ld [audioCounter1], a
	ret
.start_mario_end::
	ld a, EFFECT_MARIO_END
	ld [audioPlaying1], a
	ld a, $0B ; C4
	ld [audioSpecialLow1], a
	ld a, $AC ; G6
	ld [audioSpecialLow2], a
	ld a, $06 | AUDHIGH_RESTART|AUDHIGH_LENGTH_OFF
	ld [audioSpecialHigh1], a
	ld a, $07 | AUDHIGH_RESTART|AUDHIGH_LENGTH_OFF
	ld [audioSpecialHigh2], a
	ld a, $FF
	ld [audioCounter1], a
	ret
.start_racquet_shrink::
	ld a, EFFECT_RACQUET_SHRINK
	ld [audioPlaying1], a
	ld a, $A5 ; F#6
	ld [audioSpecialLow2], a
	ld a, $07 | AUDHIGH_RESTART|AUDHIGH_LENGTH_OFF
	ld [audioSpecialHigh2], a
	ld a, $01
	ld [audioPlayingRacquetShrink], a
	ret
.start_bounce_wall::
	ld a, [audioPlayingRacquetShrink]
	cp $01
	jp z, .no_start_bounce_wall
	ld a, EFFECT_BOUNCE_WALL
	ld [audioPlaying1], a
	ld a, $FF ; C4
	ld [audioSpecialLow1], a
	ld a, $0A ; F3
	ld [audioSpecialLow2], a
	ld a, $05 | AUDHIGH_RESTART|AUDHIGH_LENGTH_OFF
	ld [audioSpecialHigh1], a
	ld a, $FF
	ld [audioCounter1], a
.no_start_bounce_wall::
	ret
.continue_one_up::
	ld a, [audioCounter1]
	inc a
	ld [audioCounter1], a
	cp $07
	jp nz, UpdateAud1Ret
	xor a
	ld [audioCounter1], a
	ld a, [audioSampleCounter1]
	dec a
	ld [audioSampleCounter1], a
	cp $06
	jp z, .continue_one_up_06
	cp $05
	jp z, .continue_one_up_05
	cp $04
	jp z, .continue_one_up_04
	cp $03
	jp z, .continue_one_up_03
	cp $02
	jp z, .continue_one_up_02
	cp $01
	xor a
	ld [audioPlaying1], a
	jp FinishedAud1
.continue_one_up_06::
	ld hl, SampleOneUp_06
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue_one_up_05::
	ld hl, SampleOneUp_05
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue_one_up_04::
	ld hl, SampleOneUp_04
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue_one_up_03::
	ld hl, SampleOneUp_03
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue_one_up_02::
	ld hl, SampleOneUp_02
	ld c, LOW(rNR10)
	call LoadFiveRegs
	xor a
	ld [audioPlayingRacquetShrink], a
	ret
.continue_brick1::
	ld a, [audioCounter1]
	inc a
	ld [audioCounter1], a
	cp $05
	jp nz, UpdateAud1Ret
	xor a
	ld [audioCounter1], a
	ld a, [audioSampleCounter1]
	dec a
	ld [audioSampleCounter1], a
	cp $04
	jp z, .continue_brick1_04
	cp $03
	jp z, .continue_brick1_03
	cp $02
	jp z, .continue_brick1_02
	cp $01
	jp FinishedAud1
.continue_brick1_04::
	ld hl, SampleBrick1_04
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue_brick1_03::
	ld hl, SampleBrick1_03
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue_brick1_02::
	ld hl, SampleBrick1_02
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue_bumper::
	ld a, [audioCounter1]
	inc a
	ld [audioCounter1], a
	cp $03
	jp nz, UpdateAud1Ret
	xor a
	ld [audioCounter1], a
	ld a, [audioSampleCounter1]
	dec a
	ld [audioSampleCounter1], a
	cp $04
	jp z, .continue_bumper_04
	cp $03
	jp z, .continue_bumper_03
	cp $02
	jp z, .continue_bumper_02
	cp $01
	jp FinishedAud1
.continue_bumper_04::
	ld hl, SampleBumper_04
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue_bumper_03::
	ld hl, SampleBumper_03
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue_bumper_02::
	ld hl, SampleBumper_02
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue_bounce_racquet::
	ld a, [audioCounter1]
	inc a
	ld [audioCounter1], a
	cp $05
	jp nz, UpdateAud1Ret
	xor a
	ld [audioCounter1], a
	ld a, [audioSampleCounter1]
	dec a
	ld [audioSampleCounter1], a
	cp $04
	jp z, .continue_bounce_racquet_04
	cp $03
	jp z, .continue_bounce_racquet_03
	cp $02
	jp z, .continue_bounce_racquet_02
	cp $01
	jp FinishedAud1
.continue_bounce_racquet_04::
	ld hl, SampleBounceRacquet_04
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue_bounce_racquet_03::
	ld hl, SampleBounceRacquet_03
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue_bounce_racquet_02::
	ld hl, SampleBounceRacquet_02
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue_brick2::
	ld a, [audioCounter1]
	inc a
	ld [audioCounter1], a
	cp $05
	jp nz, UpdateAud1Ret
	xor a
	ld [audioCounter1], a
	ld a, [audioSampleCounter1]
	dec a
	ld [audioSampleCounter1], a
	cp $04
	jp z, .continue_brick2_04
	cp $03
	jp z, .continue_brick2_03
	cp $02
	jp z, .continue_brick2_02
	cp $01
	jp FinishedAud1
.continue_brick2_04::
	ld hl, SampleBrick2_04
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue_brick2_03::
	ld hl, SampleBrick2_03
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue_brick2_02::
	ld hl, SampleBrick2_02
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue_brick3::
	ld a, [audioCounter1]
	inc a
	ld [audioCounter1], a
	cp $05
	jp nz, UpdateAud1Ret
	xor a
	ld [audioCounter1], a
	ld a, [audioSampleCounter1]
	dec a
	ld [audioSampleCounter1], a
	cp $04
	jp z, .continue_brick3_04
	cp $03
	jp z, .continue_brick3_03
	cp $02
	jp z, .continue_brick3_02
	cp $01
	jp FinishedAud1
.continue_brick3_04::
	ld hl, SampleBrick3_04
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue_brick3_03::
	ld hl, SampleBrick3_03
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue_brick3_02::
	ld hl, SampleBrick3_02
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue_deploy_ball::
	ld a, [audioCounter1]
	inc a
	ld [audioCounter1], a
	cp $05
	jp nz, UpdateAud1Ret
	xor a
	ld [audioCounter1], a
	ld a, [audioSampleCounter1]
	dec a
	ld [audioSampleCounter1], a
	cp $03
	jp z, .continue_deploy_ball_03
	cp $02
	jp z, .continue_deploy_ball_02
	cp $01
	jp FinishedAud1
.continue_deploy_ball_03::
	ld hl, SampleDeployBall_03
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue_deploy_ball_02::
	ld hl, SampleDeployBall_02
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue_special_bonus::
	ld a, [audioCounter1]
	inc a
	ld [audioCounter1], a
	cp $02
	jp nz, UpdateAud1Ret
	xor a
	ld [audioCounter1], a
	ld a, [audioSampleCounter1]
	dec a
	ld [audioSampleCounter1], a
	cp $04
	jp z, .continue_special_bonus_04
	cp $03
	jp z, .continue_special_bonus_03
	cp $02
	jp z, .continue_special_bonus_02
	cp $01
	jp FinishedAud1
.continue_special_bonus_04::
	ld hl, SampleSpecialBonus_04
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue_special_bonus_03::
	ld hl, SampleSpecialBonus_03
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue_special_bonus_02::
	ld hl, SampleSpecialBonus_02
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue_mario_start::
	ld a, $05
	ld [audioSpecialCounter1], a
	ld a, $04
	ld [audioSpecialCounter2], a
	ld a, $00|AUD1SWEEP_UP
	ldh [rAUD1SWEEP], a
	ld a, 63|AUDLEN_DUTY_50
	ldh [rAUD1LEN], a
	ld a, $40|AUDENV_DOWN
	ldh [rAUD1ENV], a
	ld a, [audioCounter1]
	cp $00
	jp z, .continue_mario_start_mode2
.continue_mario_start_mode1::
	ld a, [audioSpecialLow1]
	inc a
	cp $63 ; G#5
	jp z, .continue_mario_start_finish1
	ld [audioSpecialLow1], a
	ld a, [audioSpecialCounter1]
	dec a
	ld [audioSpecialCounter1], a
	cp $00
	jp nz, .continue_mario_start_mode1
	ld a, [audioSpecialLow1]
	ldh [rAUD1LOW], a
	ld a, [audioSpecialHigh1]
	ldh [rAUD1HIGH], a
	ret
.continue_mario_start_finish1::
	ld a, $00
	ld [audioCounter1], a
	ret
.continue_mario_start_mode2::
	ld a, [audioSpecialLow2]
	dec a
	cp $10 ; C#5
	jp z, .continue_mario_start_finish2
	ld [audioSpecialLow2], a
	ld a, [audioSpecialCounter2]
	dec a
	ld [audioSpecialCounter2], a
	cp $00
	jp nz, .continue_mario_start_mode2
	ld a, [audioSpecialLow2]
	ldh [rAUD1LOW], a
	ld a, [audioSpecialHigh1]
	ldh [rAUD1HIGH], a
	ret
.continue_mario_start_finish2::
	xor a
	ld [audioPlaying1], a
	ldh [rAUD1ENV], a
	jp FinishedAud1
.continue_mario_end::
	ld a, $09
	ld [audioSpecialCounter1], a
	ld a, $04
	ld [audioSpecialCounter2], a
	ld a, $00|AUD1SWEEP_UP
	ldh [rAUD1SWEEP], a
	ld a, 63|AUDLEN_DUTY_50
	ldh [rAUD1LEN], a
	ld a, $90|AUDENV_DOWN
	ldh [rAUD1ENV], a
	ld a, [audioCounter1]
	cp $00
	jp z, .continue_mario_end_mode2
.continue_mario_end_mode1::
	ld a, [audioSpecialLow1]
	inc a
	cp $89 ; F4
	jp z, .continue_mario_end_finish1
	ld [audioSpecialLow1], a
	ld a, [audioSpecialCounter1]
	dec a
	ld [audioSpecialCounter1], a
	cp $00
	jp nz, .continue_mario_end_mode1
	ld a, [audioSpecialLow1]
	ldh [rAUD1LOW], a
	ld a, [audioSpecialHigh1]
	ldh [rAUD1HIGH], a
	ret
.continue_mario_end_finish1::
	ld a, $00
	ld [audioCounter1], a
	ret
.continue_mario_end_mode2::
	ld a, [audioSpecialLow2]
	dec a
	cp $1E ; D5
	jp z, .continue_mario_end_finish2
	ld [audioSpecialLow2], a
	ld a, [audioSpecialCounter2]
	dec a
	ld [audioSpecialCounter2], a
	cp $00
	jp nz, .continue_mario_end_mode2
	ld a, [audioSpecialLow2]
	ldh [rAUD1LOW], a
	ld a, [audioSpecialHigh2]
	ldh [rAUD1HIGH], a
	ret
.continue_mario_end_finish2::
	xor a
	ld [audioPlaying1], a
	ldh [rAUD1ENV], a
	ret
.continue_racquet_shrink::
	ld a, $08
	ld [audioSpecialCounter2], a
	ld a, $00|AUD1SWEEP_UP
	ldh [rAUD1SWEEP], a
	ld a, 63|AUDLEN_DUTY_50
	ldh [rAUD1LEN], a
	ld a, $90|AUDENV_DOWN
	ldh [rAUD1ENV], a
.continue_racquet_shrink_loop::
	ld a, [audioSpecialLow2]
	dec a
	cp $06 ; C5
	jp z, .continue_racquet_shrink_finish
	ld [audioSpecialLow2], a
	ld a, [audioSpecialCounter2]
	dec a
	ld [audioSpecialCounter2], a
	cp $00
	jp nz, .continue_racquet_shrink_loop
	ld a, [audioSpecialLow2]
	ldh [rAUD1LOW], a
	ld a, [audioSpecialHigh2]
	ldh [rAUD1HIGH], a
	ret
.continue_racquet_shrink_finish::
	xor a
	ld [audioPlaying1], a
	ldh [rAUD1ENV], a
	ld [audioPlayingRacquetShrink], a
	jp FinishedAud1
	ret
.continue_bounce_wall::
	ld a, $28
	ld [audioSpecialCounter1], a
	ld a, $28
	ld [audioSpecialCounter2], a
	ld a, $00|AUD1SWEEP_UP
	ldh [rAUD1SWEEP], a
	ld a, 63|AUDLEN_DUTY_50
	ldh [rAUD1LEN], a
	ld a, $40|AUDENV_DOWN
	ldh [rAUD1ENV], a
	ld a, [audioCounter1]
	cp $00
	jp z, .continue_bounce_wall_mode2
.continue_bounce_wall_mode1::
	ld a, [audioSpecialLow1]
	dec a
	cp $10 ; F3
	jp z, .continue_bounce_wall_finish1
	ld [audioSpecialLow1], a
	ld a, [audioSpecialCounter1]
	dec a
	ld [audioSpecialCounter1], a
	cp $00
	jp nz, .continue_bounce_wall_mode1
	ld a, [audioSpecialLow1]
	ldh [rAUD1LOW], a
	ld a, [audioSpecialHigh1]
	ldh [rAUD1HIGH], a
	ret
.continue_bounce_wall_finish1::
	ld a, $00
	ld [audioCounter1], a
	ret
.continue_bounce_wall_mode2::
	ld a, [audioSpecialLow2]
	inc a
	cp $63 ; G3
	jp z, .continue_bounce_wall_finish2
	ld [audioSpecialLow2], a
	ld a, [audioSpecialCounter2]
	dec a
	ld [audioSpecialCounter2], a
	cp $00
	jp nz, .continue_bounce_wall_mode2
	ld a, [audioSpecialLow2]
	ldh [rAUD1LOW], a
	ld a, [audioSpecialHigh1]
	ldh [rAUD1HIGH], a
	ret
.continue_bounce_wall_finish2::
	xor a
	ld [audioPlaying1], a
	ldh [rAUD1ENV], a
	jp FinishedAud1

ClearAudioUnused4:: ; $6F8B
	call _ClearAudioUnused4
	ret

FinishedAud1:: ; $6F8F
	xor a
	ld [audioPlaying1], a
	ldh [rAUD1ENV], a
	ld [audioCounter1], a
	ld [audioSampleCounter1], a
	ret

UpdateAud1Ret:: ; $6F9C
	ret

LoadFiveRegs:: ; $6F9D
rept 4
	ld a, [hl+]
	ldh [c], a
	inc c
endr
	ld a, [hl]
	ldh [c], a
	ret

; AUD1 (SWEEP, LEN, ENV,  LOW,HIGH)

SampleBounceRacquet_04:: ; $6FAC
	db $00|AUD1SWEEP_UP, 1|AUDLEN_DUTY_50, $72|AUDENV_DOWN
	dw $74B|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; F#5
SampleBounceRacquet_03:: ; $6FB1
	db $00|AUD1SWEEP_UP, 1|AUDLEN_DUTY_50, $15|AUDENV_DOWN
	dw $74B|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; F#5
SampleBounceRacquet_02:: ; $6FB6
	db $00|AUD1SWEEP_UP, 1|AUDLEN_DUTY_50, $17|AUDENV_DOWN
	dw $74B|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; F#5

SampleBrick1_04:: ; $6FBB
	db $00|AUD1SWEEP_UP, 1|AUDLEN_DUTY_50, $72|AUDENV_DOWN
	dw $77B|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; B5
SampleBrick1_03:: ; $6FC0
	db $00|AUD1SWEEP_UP, 1|AUDLEN_DUTY_50, $15|AUDENV_DOWN
	dw $77B|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; B5
SampleBrick1_02:: ; $6FC5
	db $00|AUD1SWEEP_UP, 1|AUDLEN_DUTY_50, $17|AUDENV_DOWN
	dw $77B|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; B5

SampleBumper_05:: ; $6FCA
	db $00|AUD1SWEEP_UP, 1|AUDLEN_DUTY_50, $C2|AUDENV_DOWN
	dw $7AC|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; G6
SampleBumper_04:: ; $6FCF
	db $00|AUD1SWEEP_UP, 1|AUDLEN_DUTY_50, $C2|AUDENV_DOWN
	dw $7BE|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; B6
SampleBumper_03:: ; $6FD4
	db $00|AUD1SWEEP_UP, 1|AUDLEN_DUTY_50, $95|AUDENV_DOWN
	dw $7BE|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; B6
SampleBumper_02:: ; $6FD9
	db $00|AUD1SWEEP_UP, 1|AUDLEN_DUTY_50, $40|AUDENV_UP
	dw $7BE|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; B6

SampleOneUp_07:: ; $6FDE
	db $00|AUD1SWEEP_UP, 49|AUDLEN_DUTY_25, $F2|AUDENV_DOWN
	dw $759|(AUDHIGH_RESTART|AUDHIGH_LENGTH_OFF)<<8 ; G5
SampleOneUp_06:: ; $6FE3
	db $00|AUD1SWEEP_UP, 63|AUDLEN_DUTY_25, $F2|AUDENV_DOWN
	dw $783|(AUDHIGH_RESTART|AUDHIGH_LENGTH_OFF)<<8 ; C6
SampleOneUp_05:: ; $6FE8
	db $00|AUD1SWEEP_UP, 63|AUDLEN_DUTY_50, $F2|AUDENV_DOWN
	dw $79D|(AUDHIGH_RESTART|AUDHIGH_LENGTH_OFF)<<8 ; E6
SampleOneUp_04:: ; $6FED
	db $00|AUD1SWEEP_UP, 63|AUDLEN_DUTY_50, $F2|AUDENV_DOWN
	dw $783|(AUDHIGH_RESTART|AUDHIGH_LENGTH_OFF)<<8 ; C6
SampleOneUp_03:: ; $6FF2
	db $00|AUD1SWEEP_UP, 63|AUDLEN_DUTY_50, $F2|AUDENV_DOWN
	dw $790|(AUDHIGH_RESTART|AUDHIGH_LENGTH_OFF)<<8 ; D6
SampleOneUp_02:: ; $6FF7
	db $00|AUD1SWEEP_UP, 63|AUDLEN_DUTY_50, $F2|AUDENV_DOWN
	dw $7AC|(AUDHIGH_RESTART|AUDHIGH_LENGTH_OFF)<<8 ; G6

SampleBrick2_04:: ; $6FFC
	db $00|AUD1SWEEP_UP, 1|AUDLEN_DUTY_50, $72|AUDENV_DOWN
	dw $797|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; D#6
SampleBrick2_03:: ; $7001
	db $00|AUD1SWEEP_UP, 1|AUDLEN_DUTY_50, $15|AUDENV_DOWN
	dw $797|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; D#6
SampleBrick2_02:: ; $7006
	db $00|AUD1SWEEP_UP, 1|AUDLEN_DUTY_50, $17|AUDENV_DOWN
	dw $797|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; D#6

SampleBrick3_04:: ; $700B
	db $00|AUD1SWEEP_UP, 1|AUDLEN_DUTY_50, $72|AUDENV_DOWN
	dw $7A7|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; F#6
SampleBrick3_03:: ; $7010
	db $00|AUD1SWEEP_UP, 1|AUDLEN_DUTY_50, $15|AUDENV_DOWN
	dw $7A7|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; F#6
SampleBrick3_02:: ; $7015
	db $00|AUD1SWEEP_UP, 1|AUDLEN_DUTY_50, $17|AUDENV_DOWN
	dw $7A7|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; F#6

SampleDeployBall_04:: ; $701A
	db $12|AUD1SWEEP_DOWN, 1|AUDLEN_DUTY_50, $F0|AUDENV_DOWN
	dw $79D|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; E6
SampleDeployBall_03:: ; $701F
	db $11|AUD1SWEEP_DOWN, 3|AUDLEN_DUTY_50, $72|AUDENV_DOWN
	dw $79E|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; E6
SampleDeployBall_02:: ; $7024
	db $12|AUD1SWEEP_UP, 3|AUDLEN_DUTY_25, $32|AUDENV_UP
	dw $79F|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; E6

SampleSpecialBonus_05:: ; $7029
	db $00|AUD1SWEEP_UP, 1|AUDLEN_DUTY_50, $72|AUDENV_DOWN
	dw $77F|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; B5
SampleSpecialBonus_04:: ; $702E
	db $00|AUD1SWEEP_UP, 1|AUDLEN_DUTY_50, $15|AUDENV_DOWN
	dw $77F|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; B5
SampleSpecialBonus_03:: ; $7033
	db $00|AUD1SWEEP_UP, 1|AUDLEN_DUTY_50, $72|AUDENV_DOWN
	dw $77F|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; B5
SampleSpecialBonus_02:: ; $7038
	db $00|AUD1SWEEP_UP, 1|AUDLEN_DUTY_50, $17|AUDENV_DOWN
	dw $77F|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; B5

; unused duplicate of EFFECT_DEPLOY_BALL, pitched a minor 16th up
; (also quite a bit out of tune.)
UnusedSample1:: ; $703D
	db $12|AUD1SWEEP_DOWN, 1|AUDLEN_DUTY_50, $F0|AUDENV_DOWN
	dw $7E9|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; F8
UnusedSample2:: ; $7042
	db $11|AUD1SWEEP_DOWN, 3|AUDLEN_DUTY_50, $72|AUDENV_DOWN
	dw $7E9|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; F8
UnusedSample3:: ; $7047
	db $12|AUD1SWEEP_UP, 3|AUDLEN_DUTY_25, $32|AUDENV_UP
	dw $7E9|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; F8

NoiseConfig:: ; $704C
	db 0|AUDLEN_DUTY_12_5, $F7|AUDENV_DOWN, $57|AUD4POLY_15STEP, AUDHIGH_RESTART|AUDHIGH_LENGTH_OFF

UpdateChannels:: ; $7050
	ld a, [audioNoiseFlag]
	cp $01
	jp z, .noise
	call UpdateAudTerm
	ret
.noise::
	ld hl, NoiseConfig
	ld c, LOW(rNR41)
	ld a, 73
	ld [audioAllStereoCounter], a
	ld a, %00001111
	ld [audioAllStereoTermRotation], a
	xor a
	ld [audio2StereoFlag], a
	call LoadFourRegs
	ret

LoadFourRegs:: ; $7073
rept 3
	ld a, [hl+]
	ld [c], a
	inc c
endr
	ld a, [hl+]
	ld [c], a
	ret

UpdateAudTerm:: ; $707F
	ld a, [audioAllStereoCounter]
	cp $00
	jp z, .zero
	dec a
	ld [audioAllStereoCounter], a
	cp $00
	jp z, .both
	ld a, [audioAllStereoTermRotation]
	rlc a
	ld [audioAllStereoTermRotation], a
	jp nc, .left
	ld a, AUDTERM_4_RIGHT|AUDTERM_3_RIGHT|AUDTERM_2_RIGHT|AUDTERM_1_RIGHT
	ldh [rAUDTERM], a
	ret
.left::
	ld a, AUDTERM_4_LEFT|AUDTERM_3_LEFT|AUDTERM_2_LEFT|AUDTERM_1_LEFT
	ldh [rAUDTERM], a
	ret
.both::
	ld a, AUDTERM_4_RIGHT|AUDTERM_3_RIGHT|AUDTERM_2_RIGHT|AUDTERM_1_RIGHT|AUDTERM_4_LEFT|AUDTERM_3_LEFT|AUDTERM_2_LEFT|AUDTERM_1_LEFT
	ldh [rAUDTERM], a
.zero::
	xor a
	ld [audioAllStereoCounter], a
	ret
