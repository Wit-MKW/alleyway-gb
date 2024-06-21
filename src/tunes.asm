include "common.inc"
setcharmap DMG

SECTION FRAGMENT "Main code", ROM0
TurnOnAudio:: ; $6375
; initialise audio hardware
; out(A) = AUDTERM_4_LEFT|AUDTERM_3_LEFT|AUDTERM_2_LEFT|AUDTERM_1_LEFT|AUDTERM_4_RIGHT|AUDTERM_3_RIGHT|AUDTERM_2_RIGHT|AUDTERM_1_RIGHT
	ld a, AUDENA_ON
	ldh [rAUDENA], a
	ld a, $77
	ldh [rAUDVOL], a
	ld a, AUDTERM_4_LEFT|AUDTERM_3_LEFT|AUDTERM_2_LEFT|AUDTERM_1_LEFT|AUDTERM_4_RIGHT|AUDTERM_3_RIGHT|AUDTERM_2_RIGHT|AUDTERM_1_RIGHT
	ldh [rAUDTERM], a
	ret

StartAudio:: ; $6382
; allow new audio to play
; out(A) = 1
	xor a
	ld [audioCancelFlag], a
	ret

CancelAudio:: ; $6387
; keep currently-playing audio playing, but cancel any scheduled to play
; out(A) = 1
	ld a, $01
	ld [audioCancelFlag], a
	ret

LoadBrickSound:: ; $638D
; play the sound of hitting the brick with ID [tileToDraw]
; out(A) = sound ID
; out(BC) = ([tileToDraw]-1)*BrickTypes_SIZEOF
; out(E) = 0
; out(HL) = pointer to brick's sound
	ldh a, [tileToDraw]
	dec a
	ld b, a
	ld e, BrickTypes_SIZEOF
	call MultiplyBxE
	ld hl, BrickTypes
	add hl, bc
	ld b, HIGH(BrickTypes_SOUND)
	ld c, LOW(BrickTypes_SOUND)
	add hl, bc
	ld a, [hl]
	cp $00
	jr z, PlaySound.bumper
	cp $01
	jr z, PlaySound.brick1
	cp $02
	jr z, PlaySound.brick2
	jr PlaySound.brick3

PlaySound:: ; $63AE
; (local labels are functions)
; play the selected sound effect
; out(A) = effect ID
.one_up::
	ld a, EFFECT_ONE_UP
	jr .done
.brick1::
	ld a, EFFECT_BRICK1
	jr .done
.bumper::
	ld a, EFFECT_BUMPER
	jr .done
.bounce_racquet::
	ld a, EFFECT_BOUNCE_RACQUET
	jr .done
.brick2::
	ld a, EFFECT_BRICK2
	jr .done
.brick3::
	ld a, EFFECT_BRICK3
	jr .done
.deploy_ball::
	ld a, EFFECT_DEPLOY_BALL
	jr .done
.special_bonus::
	ld a, EFFECT_SPECIAL_BONUS
	jr .done
.mario_start::
	ld a, EFFECT_MARIO_START
	jr .done
.mario_end::
	ld a, EFFECT_MARIO_END
	jr .done
.racquet_shrink::
	ld a, EFFECT_RACQUET_SHRINK
	jr .done
.bounce_wall::
	ld a, EFFECT_BOUNCE_WALL
.done::
	ld [audioStarting1], a
	ret

PlayNoise:: ; $63E0
; play the noise of the ball falling out of play
; out(A) = 1
	ld a, $01
	jr .but_why
.but_why::
	ld [audioNoiseFlag], a
	ret

PlayMusic:: ; $63E8
; (local labels are functions)
; play the selected music
; out(A) = music ID
.title::
	ld a, MUSIC_TITLE
	jr .done
.mario_start::
	ld a, MUSIC_MARIO_START
	jr .done
.game_over::
	ld a, MUSIC_GAME_OVER
	jr .done
.pause::
	ld a, MUSIC_PAUSE
	jr .done
.stage_end::
	ld a, MUSIC_STAGE_END
	jr .done
.special::
	ld a, MUSIC_SPECIAL
	jr .done
.special_fast::
	ld a, MUSIC_SPECIAL_FAST
	jr .done
.special_intro::
	ld a, MUSIC_SPECIAL_INTRO
	jr .done
.special_end::
	ld a, MUSIC_SPECIAL_END
	jr .done
.special_bonus::
	ld a, MUSIC_SPECIAL_BONUS
	jr .done
.stage_fall::
	ld a, MUSIC_STAGE_FALL
	jr .done
.nice_play::
	ld a, MUSIC_NICE_PLAY
.done::
	ld [audioStarting23], a
	ret
