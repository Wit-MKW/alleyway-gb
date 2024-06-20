include "common.inc"
setcharmap DMG

def audioButtonsDown equ $FF80
def audioButtonsPressed equ $FF81

SECTION FRAGMENT "Audio", ROM0, align[10]
_UpdateAudio:: ; $6800
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

AudioTestStart:: ; $681A
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
	ld a, $01
	ld [audioStarting1], a
	ret
.b_button::
	ld a, $02
	ld [audioStarting1], a
	ret
.start_button::
	ld a, $03
	ld [audioStarting1], a
	ret
.select_button::
	ld a, $04
	ld [audioStarting1], a
	ret
.right_button::
	ld a, $05
	ld [audioStarting1], a
	ret
.left_button::
	ld a, $06
	ld [audioStarting1], a
	ret
.up_button::
	ld a, $07
	ld [audioStarting1], a
	ret
.down_button::
	ld a, $08
	ld [audioStarting1], a
	ret
.nothing::
	ret

AudioTestStartPlay:: ; $6878
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
	ld a, $01
	ld [audioStarting1], a
	ld [audioStarting23], a
	ret
.b_button::
	ld a, $02
	ld [audioStarting1], a
	ld [audioStarting23], a
	ret
.start_button::
	ld a, $03
	ld [audioStarting1], a
	ld [audioStarting23], a
	ret
.select_button::
	ld a, $04
	ld [audioStarting1], a
	ld [audioStarting23], a
	ret
.right_button::
	ld a, $05
	ld [audioStarting1], a
	ld [audioStarting23], a
	ret
.left_button::
	ld a, $06
	ld [audioStarting1], a
	ld [audioStarting23], a
	ret
.up_button::
	ld a, $07
	ld [audioStarting1], a
	ld [audioStarting23], a
	ret
.down_button::
	ld a, $08
	ld [audioStarting1], a
	ld [audioStarting23], a
	ret
.nothing::
	ret

AudioTestNoise:: ; $68EE
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

AudioTestPlay:: ; $694C
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
	ld a, $01
	ld [audioStarting23], a
	ret
.b_button::
	ld a, $02
	ld [audioStarting23], a
	ret
.start_button::
	ld a, $03
	ld [audioStarting23], a
	ret
.select_button::
	ld a, $04
	ld [audioStarting23], a
	ret
.right_button::
	ld a, $05
	ld [audioStarting23], a
	ret
.left_button::
	ld a, $06
	ld [audioStarting23], a
	ret
.up_button::
	ld a, $07
	ld [audioStarting23], a
	ret
.down_button::
	ld a, $08
	ld [audioStarting23], a
	ret
.nothing::
	ret

AudioGetInput:: ; $69AA
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
audioPlaying11:: db ; $DFD7
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
