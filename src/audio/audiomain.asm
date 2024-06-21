include "common.inc"
setcharmap DMG

def audioButtonsDown equ $FF80
def audioButtonsPressed equ $FF81

SECTION FRAGMENT "Audio", ROM0, align[10]
_UpdateAudio:: ; $6800
; update audio for this frame
	call CheckCancel
	call UpdateAud1
	call UpdateChannels
	call UpdateAud23
	call UpdateAudTerm2
	xor a
	ld [audioStarting1], a
	ld [audioNoiseFlag], a
	ld [audioStarting23], a
	ret

AudioTestEffect:: ; $681A
; play a sound effect based on what button is pressed
; * A: EFFECT_ONE_UP
; * B: EFFECT_BRICK1
; * START: EFFECT_BUMPER
; * SELECT: EFFECT_BOUNCE_RACQUET
; * RIGHT: EFFECT_BRICK2
; * LEFT: EFFECT_BRICK3
; * UP: EFFECT_DEPLOY_BALL
; * DOWN: EFFECT_SPECIAL_BONUS
; * missing: EFFECT_MARIO_START, EFFECT_MARIO_END, EFFECT_RACQUET_SHRINK, EFFECT_BOUNCE_WALL
	ldh a, [audioButtonsPressed]
	bit PADB_A, a
	jp nz, .a_button
	bit PADB_B, a
	jp nz, .b_button
	bit PADB_START, a
	jp nz, .start_button
	bit PADB_SELECT, a
	jp nz, .select_button
	bit PADB_RIGHT, a
	jp nz, .right_button
	bit PADB_LEFT, a
	jp nz, .left_button
	bit PADB_UP, a
	jp nz, .up_button
	bit PADB_DOWN, a
	jp nz, .down_button
	jp .nothing
.a_button::
	ld a, EFFECT_ONE_UP
	ld [audioStarting1], a
	ret
.b_button::
	ld a, EFFECT_BRICK1
	ld [audioStarting1], a
	ret
.start_button::
	ld a, EFFECT_BUMPER
	ld [audioStarting1], a
	ret
.select_button::
	ld a, EFFECT_BOUNCE_RACQUET
	ld [audioStarting1], a
	ret
.right_button::
	ld a, EFFECT_BRICK2
	ld [audioStarting1], a
	ret
.left_button::
	ld a, EFFECT_BRICK3
	ld [audioStarting1], a
	ret
.up_button::
	ld a, EFFECT_DEPLOY_BALL
	ld [audioStarting1], a
	ret
.down_button::
	ld a, EFFECT_SPECIAL_BONUS
	ld [audioStarting1], a
	ret
.nothing::
	ret

AudioTestEffectMusic:: ; $6878
; play a sound effect & music based on what button is pressed
; * see AudioTestEffect & AudioTestMusic for details.
	ldh a, [audioButtonsPressed]
	bit PADB_A, a
	jp nz, .a_button
	bit PADB_B, a
	jp nz, .b_button
	bit PADB_START, a
	jp nz, .start_button
	bit PADB_SELECT, a
	jp nz, .select_button
	bit PADB_RIGHT, a
	jp nz, .right_button
	bit PADB_LEFT, a
	jp nz, .left_button
	bit PADB_UP, a
	jp nz, .up_button
	bit PADB_DOWN, a
	jp nz, .down_button
	jp .nothing
.a_button::
	ld a, MUSIC_TITLE ; EFFECT_ONE_UP
	ld [audioStarting1], a
	ld [audioStarting23], a
	ret
.b_button::
	ld a, MUSIC_MARIO_START ; EFFECT_BRICK1
	ld [audioStarting1], a
	ld [audioStarting23], a
	ret
.start_button::
	ld a, MUSIC_GAME_OVER ; EFFECT_BUMPER
	ld [audioStarting1], a
	ld [audioStarting23], a
	ret
.select_button::
	ld a, MUSIC_PAUSE ; EFFECT_BOUNCE_RACQUET
	ld [audioStarting1], a
	ld [audioStarting23], a
	ret
.right_button::
	ld a, MUSIC_STAGE_END ; EFFECT_BRICK2
	ld [audioStarting1], a
	ld [audioStarting23], a
	ret
.left_button::
	ld a, MUSIC_SPECIAL ; EFFECT_BRICK3
	ld [audioStarting1], a
	ld [audioStarting23], a
	ret
.up_button::
	ld a, MUSIC_SPECIAL_FAST ; EFFECT_DEPLOY_BALL
	ld [audioStarting1], a
	ld [audioStarting23], a
	ret
.down_button::
	ld a, MUSIC_SPECIAL_INTRO ; EFFECT_SPECIAL_BONUS
	ld [audioStarting1], a
	ld [audioStarting23], a
	ret
.nothing::
	ret

AudioTestNoise:: ; $68EE
; play the noise of the ball falling out of play if the A button is pressed
	ldh a, [audioButtonsPressed]
	bit PADB_A, a
	jp nz, .a_button
	bit PADB_B, a
	jp nz, .b_button
	bit PADB_START, a
	jp nz, .start_button
	bit PADB_SELECT, a
	jp nz, .select_button
	bit PADB_RIGHT, a
	jp nz, .right_button
	bit PADB_LEFT, a
	jp nz, .left_button
	bit PADB_UP, a
	jp nz, .up_button
	bit PADB_DOWN, a
	jp nz, .down_button
	jp AudioTestStart.nothing
.a_button::
	ld a, $01
	ld [audioNoiseFlag], a
	ret
.b_button::
	ld a, $02
	ld [audioNoiseFlag], a
	ret
.start_button::
	ld a, $03
	ld [audioNoiseFlag], a
	ret
.select_button::
	ld a, $04
	ld [audioNoiseFlag], a
	ret
.right_button::
	ld a, $05
	ld [audioNoiseFlag], a
	ret
.left_button::
	ld a, $06
	ld [audioNoiseFlag], a
	ret
.up_button::
	ld a, $07
	ld [audioNoiseFlag], a
	ret
.down_button::
	ld a, $08
	ld [audioNoiseFlag], a
	ret
.nothing::
	ret

AudioTestMusic:: ; $694C
; play music based on what button is pressed
; * A: MUSIC_TITLE
; * B: MUSIC_MARIO_START
; * START: MUSIC_GAME_OVER
; * SELECT: MUSIC_PAUSE
; * RIGHT: MUSIC_STAGE_END
; * LEFT: MUSIC_SPECIAL
; * UP: MUSIC_SPECIAL_FAST
; * DOWN: MUSIC_SPECIAL_INTRO
; * missing: MUSIC_SPECIAL_END, MUSIC_SPECIAL_BONUS, MUSIC_STAGE_FALL, MUSIC_NICE_PLAY
	ldh a, [audioButtonsPressed]
	bit PADB_A, a
	jp nz, .a_button
	bit PADB_B, a
	jp nz, .b_button
	bit PADB_START, a
	jp nz, .start_button
	bit PADB_SELECT, a
	jp nz, .select_button
	bit PADB_RIGHT, a
	jp nz, .right_button
	bit PADB_LEFT, a
	jp nz, .left_button
	bit PADB_UP, a
	jp nz, .up_button
	bit PADB_DOWN, a
	jp nz, .down_button
	jp .nothing
.a_button::
	ld a, MUSIC_TITLE
	ld [audioStarting23], a
	ret
.b_button::
	ld a, MUSIC_MARIO_START
	ld [audioStarting23], a
	ret
.start_button::
	ld a, MUSIC_GAME_OVER
	ld [audioStarting23], a
	ret
.select_button::
	ld a, MUSIC_PAUSE
	ld [audioStarting23], a
	ret
.right_button::
	ld a, MUSIC_STAGE_END
	ld [audioStarting23], a
	ret
.left_button::
	ld a, MUSIC_SPECIAL
	ld [audioStarting23], a
	ret
.up_button::
	ld a, MUSIC_SPECIAL_FAST
	ld [audioStarting23], a
	ret
.down_button::
	ld a, MUSIC_SPECIAL_INTRO
	ld [audioStarting23], a
	ret
.nothing::
	ret

AudioGetInput:: ; $69AA
; write current input data to HRAM
; * [audioButtonsDown] bit clear: button depressed
; * [audioButtonsPressed] bit clear: button pressed anew
; * bit 7: DOWN
; * bit 6: UP
; * bit 5: LEFT
; * bit 4: RIGHT
; * bit 3: START
; * bit 2: SELECT
; * bit 1: B
; * bit 0: A
	push af
	push bc
	ld a, P1F_GET_BTN
	ldh [rP1], a
rept 6
	ldh a, [rP1]
endr
	cpl
	and P1F_3|P1F_2|P1F_1|P1F_0
	ld b, a
	ld a, P1F_GET_DPAD
	ldh [rP1], a
rept 6
	ldh a, [rP1]
endr
	cpl
	and P1F_3|P1F_2|P1F_1|P1F_0
	swap a
	or b
	ld c, a
	ldh a, [audioButtonsDown]
	xor c
	and c
	ldh [audioButtonsPressed], a
	ld a, c
	ldh [audioButtonsDown], a
	ld a, P1F_GET_NONE
	ldh [rP1], a
	pop bc
	pop af
	ret

CheckCancel:: ; $69E7
; cancel audio to be played if appropriate
; out(A) = [audioCancelFlag] if not 1, else 0
	ld a, [audioCancelFlag]
	cp $01
	jp z, .cancel
	ret
.cancel::
	xor a
	ld [audioStarting1], a
	ld [audioNoiseFlag], a
	ld [audioStarting23], a
	ret

SECTION "Audio redirects", ROM0[$7FF0]
UpdateAudio:: ; $7FF0
	jp _UpdateAudio
StopAudio:: ; $7FF3
	call _StopAudio
	ret

SECTION "Audio WRAM", WRAM0[$DFD0]
audioSpecialCounter1:: db ; $DFD0
audioSpecialCounter2:: db ; $DFD1
audio2StereoFlag:: db ; $DFD2
audio2StereoCounter:: db ; $DFD3
audio2StereoModulo:: db ; $DFD4
audio2StereoTerm:: db ; $DFD5
audio2StereoUnused:: db ; $DFD6
audioPlayingRacquetShrink:: db ; $DFD7
audioCancelFlag:: db ; $DFD8
ds align[3] ; $DFD9-$DFDF

audioStarting1:: db ; $DFE0
audioNoiseFlag:: db ; $DFE1
audioPlaying1:: db ; $DFE2

audioUnused:: db ; $DFE3
audioNext23:: db ; $DFE4
audioNext3:: db ; $DFE5

audioCounter1:: db ; $DFE6
audioUnused1:: db ; $DFE7

audioStarting23:: db ; $DFE8
audioSampleCounter1:: db ; $DFE9

audioUnused2:: db ; $DFEA
audioCounter2:: db ; $DFEB
audioModulo2:: db ; $DFEC

audioCounter3:: db ; $DFED
audioModulo3:: db ; $DFEE
audioUnused3:: db ; $DFEF

audioPointer2:: be ; $DFF0
audioPointer3:: be ; $DFF2

audioUnused4:: db ; $DFF4
audioNote2:: db ; $DFF5
audioNote3:: db ; $DFF6

audioWaveRamCounter:: db ; $DFF7
audioUnused5:: db ; $DFF8

audioAllStereoCounter:: db ; $DFF9
audioAllStereoTermRotation:: db ; $DFFA

audioSpecialLow1:: db ; $DFFB
audioSpecialHigh1:: db ; $DFFC
audioSpecialLow2:: db ; $DFFD
audioSpecialHigh2:: db ; $DFFE
