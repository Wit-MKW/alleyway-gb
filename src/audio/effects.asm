include "common.inc"
setcharmap DMG

SECTION FRAGMENT "Audio", ROM0
UpdateAud1:: ; $69FB
	ld a, [audioPlaying1]
	cp $01
	jp z, .continue01
	ld a, [audioStarting1]
	cp $04
	jp z, .start04
	cp $02
	jp z, .start02
	cp $03
	jp z, .start03
	cp $01
	jp z, .start01
	cp $05
	jp z, .start05
	cp $06
	jp z, .start06
	cp $07
	jp z, .start07
	cp $08
	jp z, .start08
	cp $09
	jp z, .start09
	cp $0A
	jp z, .start10
	cp $0B
	jp z, .start11
	cp $0C
	jp z, .start12
	ld a, [audioPlaying1]
	cp $02
	jp z, .continue02
	cp $03
	jp z, .continue03
	cp $04
	jp z, .continue04
	cp $05
	jp z, .continue05
	cp $06
	jp z, .continue06
	cp $07
	jp z, .continue07
	cp $08
	jp z, .continue08
	cp $09
	jp z, .continue09
	cp $0A
	jp z, .continue10
	cp $0B
	jp z, .continue11
	cp $0C
	jp z, .continue12
	ret
.start01::
	ld a, $01
	ld [audioPlaying1], a
	ld a, $07
	ld [audioSampleCounter1], a
	ld hl, Sample01_07
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.start02::
	ld a, [audioPlaying11]
	cp $01
	jp z, .no_start02
	ld a, $02
	ld [audioPlaying1], a
	ld a, $05
	ld [audioSampleCounter1], a
	ld hl, Sample02_04
	ld c, LOW(rNR10)
	call LoadFiveRegs
.no_start02::
	ret
.start03::
	ld a, [audioPlaying11]
	cp $01
	jp z, .no_start03
	ld a, $03
	ld [audioPlaying1], a
	ld a, $05
	ld [audioSampleCounter1], a
	ld hl, Sample03_05
	ld c, LOW(rNR10)
	call LoadFiveRegs
.no_start03::
	ret
.start04::
	ld a, [audioPlaying11]
	cp $01
	jp z, .no_start04
	ld a, $04
	ld [audioPlaying1], a
	ld a, $04
	ld [audioSampleCounter1], a
	ld hl, Sample04_04
	ld c, LOW(rNR10)
	call LoadFiveRegs
.no_start04::
	ret
.start05::
	ld a, [audioPlaying11]
	cp $01
	jp z, .no_start05
	ld a, $05
	ld [audioPlaying1], a
	ld a, $05
	ld [audioSampleCounter1], a
	ld hl, Sample05_04
	ld c, LOW(rNR10)
	call LoadFiveRegs
.no_start05::
	ret
.start06::
	ld a, [audioPlaying11]
	cp $01
	jp z, .no_start06
	ld a, $06
	ld [audioPlaying1], a
	ld a, $05
	ld [audioSampleCounter1], a
	ld hl, Sample06_04
	ld c, LOW(rNR10)
	call LoadFiveRegs
.no_start06::
	ret
.start07::
	ld a, $07
	ld [audioPlaying1], a
	ld a, $04
	ld [audioSampleCounter1], a
	ld hl, Sample07_04
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.start08::
	ld a, $08
	ld [audioPlaying1], a
	ld a, $05
	ld [audioSampleCounter1], a
	ld hl, Sample08_05
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.start09::
	ld a, $09
	ld [audioPlaying1], a
	ld a, $63
	ld [audioSpecialLow1], a
	ld a, $0A
	ld [audioSpecialLow2], a
	ld a, $07 | AUDHIGH_RESTART|AUDHIGH_LENGTH_OFF
	ld [audioSpecialHigh1], a
	ld a, $FF
	ld [audioCounter1], a
	ret
.start10::
	ld a, $0A
	ld [audioPlaying1], a
	ld a, $0B
	ld [audioSpecialLow1], a
	ld a, $AC
	ld [audioSpecialLow2], a
	ld a, $06 | AUDHIGH_RESTART|AUDHIGH_LENGTH_OFF
	ld [audioSpecialHigh1], a
	ld a, $07 | AUDHIGH_RESTART|AUDHIGH_LENGTH_OFF
	ld [audioSpecialHigh2], a
	ld a, $FF
	ld [audioCounter1], a
	ret
.start11::
	ld a, $0B
	ld [audioPlaying1], a
	ld a, $A5
	ld [audioSpecialLow2], a
	ld a, $07 | AUDHIGH_RESTART|AUDHIGH_LENGTH_OFF
	ld [audioSpecialHigh2], a
	ld a, $01
	ld [audioPlaying11], a
	ret
.start12::
	ld a, [audioPlaying11]
	cp $01
	jp z, .no_start12
	ld a, $0C
	ld [audioPlaying1], a
	ld a, $FF
	ld [audioSpecialLow1], a
	ld a, $0A
	ld [audioSpecialLow2], a
	ld a, $05 | AUDHIGH_RESTART|AUDHIGH_LENGTH_OFF
	ld [audioSpecialHigh1], a
	ld a, $FF
	ld [audioCounter1], a
.no_start12::
	ret
.continue01::
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
	jp z, .continue01_06
	cp $05
	jp z, .continue01_05
	cp $04
	jp z, .continue01_04
	cp $03
	jp z, .continue01_03
	cp $02
	jp z, .continue01_02
	cp $01
	xor a
	ld [audioPlaying1], a
	jp FinishedAud1
.continue01_06::
	ld hl, Sample01_06
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue01_05::
	ld hl, Sample01_05
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue01_04::
	ld hl, Sample01_04
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue01_03::
	ld hl, Sample01_03
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue01_02::
	ld hl, Sample01_02
	ld c, LOW(rNR10)
	call LoadFiveRegs
	xor a
	ld [audioPlaying11], a
	ret
.continue02::
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
	jp z, .continue02_04
	cp $03
	jp z, .continue02_03
	cp $02
	jp z, .continue02_02
	cp $01
	jp FinishedAud1
.continue02_04::
	ld hl, Sample02_04
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue02_03::
	ld hl, Sample02_03
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue02_02::
	ld hl, Sample02_02
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue03::
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
	jp z, .continue03_04
	cp $03
	jp z, .continue03_03
	cp $02
	jp z, .continue03_02
	cp $01
	jp FinishedAud1
.continue03_04::
	ld hl, Sample03_04
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue03_03::
	ld hl, Sample03_03
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue03_02::
	ld hl, Sample03_02
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue04::
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
	jp z, .continue04_04
	cp $03
	jp z, .continue04_03
	cp $02
	jp z, .continue04_02
	cp $01
	jp FinishedAud1
.continue04_04::
	ld hl, Sample04_04
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue04_03::
	ld hl, Sample04_03
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue04_02::
	ld hl, Sample04_02
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue05::
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
	jp z, .continue05_04
	cp $03
	jp z, .continue05_03
	cp $02
	jp z, .continue05_02
	cp $01
	jp FinishedAud1
.continue05_04::
	ld hl, Sample05_04
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue05_03::
	ld hl, Sample05_03
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue05_02::
	ld hl, Sample05_02
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue06::
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
	jp z, .continue06_04
	cp $03
	jp z, .continue06_03
	cp $02
	jp z, .continue06_02
	cp $01
	jp FinishedAud1
.continue06_04::
	ld hl, Sample06_04
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue06_03::
	ld hl, Sample06_03
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue06_02::
	ld hl, Sample06_02
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue07::
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
	jp z, .continue07_03
	cp $02
	jp z, .continue07_02
	cp $01
	jp FinishedAud1
.continue07_03::
	ld hl, Sample07_03
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue07_02::
	ld hl, Sample07_02
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue08::
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
	jp z, .continue08_04
	cp $03
	jp z, .continue08_03
	cp $02
	jp z, .continue08_02
	cp $01
	jp FinishedAud1
.continue08_04::
	ld hl, Sample08_04
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue08_03::
	ld hl, Sample08_03
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue08_02::
	ld hl, Sample08_02
	ld c, LOW(rNR10)
	call LoadFiveRegs
	ret
.continue09::
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
	jp z, .continue09_zero
.continue09_loop::
	ld a, [audioSpecialLow1]
	inc a
	cp $63
	jp z, .continue09_freq99
	ld [audioSpecialLow1], a
	ld a, [audioSpecialCounter1]
	dec a
	ld [audioSpecialCounter1], a
	cp $00
	jp nz, .continue09_loop
	ld a, [audioSpecialLow1]
	ldh [rAUD1LOW], a
	ld a, [audioSpecialHigh1]
	ldh [rAUD1HIGH], a
	ret
.continue09_freq99::
	ld a, $00
	ld [audioCounter1], a
	ret
.continue09_zero::
	ld a, [audioSpecialLow2]
	dec a
	cp $10
	jp z, .continue09_freq16
	ld [audioSpecialLow2], a
	ld a, [audioSpecialCounter2]
	dec a
	ld [audioSpecialCounter2], a
	cp $00
	jp nz, .continue09_zero
	ld a, [audioSpecialLow2]
	ldh [rAUD1LOW], a
	ld a, [audioSpecialHigh1]
	ldh [rAUD1HIGH], a
	ret
.continue09_freq16::
	xor a
	ld [audioPlaying1], a
	ldh [rAUD1ENV], a
	jp FinishedAud1
.continue10::
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
	jp z, .continue10_zero
.continue10_loop::
	ld a, [audioSpecialLow1]
	inc a
	cp $89
	jp z, .continue10_freq137
	ld [audioSpecialLow1], a
	ld a, [audioSpecialCounter1]
	dec a
	ld [audioSpecialCounter1], a
	cp $00
	jp nz, .continue10_loop
	ld a, [audioSpecialLow1]
	ldh [rAUD1LOW], a
	ld a, [audioSpecialHigh1]
	ldh [rAUD1HIGH], a
	ret
.continue10_freq137::
	ld a, $00
	ld [audioCounter1], a
	ret
.continue10_zero::
	ld a, [audioSpecialLow2]
	dec a
	cp $1E
	jp z, .continue10_freq30
	ld [audioSpecialLow2], a
	ld a, [audioSpecialCounter2]
	dec a
	ld [audioSpecialCounter2], a
	cp $00
	jp nz, .continue10_zero
	ld a, [audioSpecialLow2]
	ldh [rAUD1LOW], a
	ld a, [audioSpecialHigh2]
	ldh [rAUD1HIGH], a
	ret
.continue10_freq30::
	xor a
	ld [audioPlaying1], a
	ldh [rAUD1ENV], a
	ret
.continue11::
	ld a, $08
	ld [audioSpecialCounter2], a
	ld a, $00|AUD1SWEEP_UP
	ldh [rAUD1SWEEP], a
	ld a, 63|AUDLEN_DUTY_50
	ldh [rAUD1LEN], a
	ld a, $90|AUDENV_DOWN
	ldh [rAUD1ENV], a
.continue11_loop::
	ld a, [audioSpecialLow2]
	dec a
	cp $06
	jp z, .continue11_freq06
	ld [audioSpecialLow2], a
	ld a, [audioSpecialCounter2]
	dec a
	ld [audioSpecialCounter2], a
	cp $00
	jp nz, .continue11_loop
	ld a, [audioSpecialLow2]
	ldh [rAUD1LOW], a
	ld a, [audioSpecialHigh2]
	ldh [rAUD1HIGH], a
	ret
.continue11_freq06::
	xor a
	ld [audioPlaying1], a
	ldh [rAUD1ENV], a
	ld [audioPlaying11], a
	jp FinishedAud1
	ret
.continue12::
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
	jp z, .continue12_zero
.continue12_loop::
	ld a, [audioSpecialLow1]
	dec a
	cp $10
	jp z, .continue12_freq16
	ld [audioSpecialLow1], a
	ld a, [audioSpecialCounter1]
	dec a
	ld [audioSpecialCounter1], a
	cp $00
	jp nz, .continue12_loop
	ld a, [audioSpecialLow1]
	ldh [rAUD1LOW], a
	ld a, [audioSpecialHigh1]
	ldh [rAUD1HIGH], a
	ret
.continue12_freq16::
	ld a, $00
	ld [audioCounter1], a
	ret
.continue12_zero::
	ld a, [audioSpecialLow2]
	inc a
	cp $63
	jp z, .continue12_freq99
	ld [audioSpecialLow2], a
	ld a, [audioSpecialCounter2]
	dec a
	ld [audioSpecialCounter2], a
	cp $00
	jp nz, .continue12_zero
	ld a, [audioSpecialLow2]
	ldh [rAUD1LOW], a
	ld a, [audioSpecialHigh1]
	ldh [rAUD1HIGH], a
	ret
.continue12_freq99::
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

Sample04_04:: ; $6FAC
	db $00|AUD1SWEEP_UP, 1|AUDLEN_DUTY_50, $72|AUDENV_DOWN
	dw $74B|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; F#5
Sample04_03:: ; $6FB1
	db $00|AUD1SWEEP_UP, 1|AUDLEN_DUTY_50, $15|AUDENV_DOWN
	dw $74B|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; F#5
Sample04_02:: ; $6FB6
	db $00|AUD1SWEEP_UP, 1|AUDLEN_DUTY_50, $17|AUDENV_DOWN
	dw $74B|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; F#5

Sample02_04:: ; $6FBB
	db $00|AUD1SWEEP_UP, 1|AUDLEN_DUTY_50, $72|AUDENV_DOWN
	dw $77B|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; B5
Sample02_03:: ; $6FC0
	db $00|AUD1SWEEP_UP, 1|AUDLEN_DUTY_50, $15|AUDENV_DOWN
	dw $77B|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; B5
Sample02_02:: ; $6FC5
	db $00|AUD1SWEEP_UP, 1|AUDLEN_DUTY_50, $17|AUDENV_DOWN
	dw $77B|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; B5

Sample03_05:: ; $6FCA
	db $00|AUD1SWEEP_UP, 1|AUDLEN_DUTY_50, $C2|AUDENV_DOWN
	dw $7AC|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; G6
Sample03_04:: ; $6FCF
	db $00|AUD1SWEEP_UP, 1|AUDLEN_DUTY_50, $C2|AUDENV_DOWN
	dw $7BE|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; B6
Sample03_03:: ; $6FD4
	db $00|AUD1SWEEP_UP, 1|AUDLEN_DUTY_50, $95|AUDENV_DOWN
	dw $7BE|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; B6
Sample03_02:: ; $6FD9
	db $00|AUD1SWEEP_UP, 1|AUDLEN_DUTY_50, $40|AUDENV_UP
	dw $7BE|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; B6

Sample01_07:: ; $6FDE
	db $00|AUD1SWEEP_UP, 49|AUDLEN_DUTY_25, $F2|AUDENV_DOWN
	dw $759|(AUDHIGH_RESTART|AUDHIGH_LENGTH_OFF)<<8 ; G5
Sample01_06:: ; $6FE3
	db $00|AUD1SWEEP_UP, 63|AUDLEN_DUTY_25, $F2|AUDENV_DOWN
	dw $783|(AUDHIGH_RESTART|AUDHIGH_LENGTH_OFF)<<8 ; C6
Sample01_05:: ; $6FE8
	db $00|AUD1SWEEP_UP, 63|AUDLEN_DUTY_50, $F2|AUDENV_DOWN
	dw $79D|(AUDHIGH_RESTART|AUDHIGH_LENGTH_OFF)<<8 ; E6
Sample01_04:: ; $6FED
	db $00|AUD1SWEEP_UP, 63|AUDLEN_DUTY_50, $F2|AUDENV_DOWN
	dw $783|(AUDHIGH_RESTART|AUDHIGH_LENGTH_OFF)<<8 ; C6
Sample01_03:: ; $6FF2
	db $00|AUD1SWEEP_UP, 63|AUDLEN_DUTY_50, $F2|AUDENV_DOWN
	dw $790|(AUDHIGH_RESTART|AUDHIGH_LENGTH_OFF)<<8 ; D6
Sample01_02:: ; $6FF7
	db $00|AUD1SWEEP_UP, 63|AUDLEN_DUTY_50, $F2|AUDENV_DOWN
	dw $7AC|(AUDHIGH_RESTART|AUDHIGH_LENGTH_OFF)<<8 ; G6

Sample05_04:: ; $6FFC
	db $00|AUD1SWEEP_UP, 1|AUDLEN_DUTY_50, $72|AUDENV_DOWN
	dw $797|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; D#6
Sample05_03:: ; $7001
	db $00|AUD1SWEEP_UP, 1|AUDLEN_DUTY_50, $15|AUDENV_DOWN
	dw $797|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; D#6
Sample05_02:: ; $7006
	db $00|AUD1SWEEP_UP, 1|AUDLEN_DUTY_50, $17|AUDENV_DOWN
	dw $797|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; D#6

Sample06_04:: ; $700B
	db $00|AUD1SWEEP_UP, 1|AUDLEN_DUTY_50, $72|AUDENV_DOWN
	dw $7A7|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; F#6
Sample06_03:: ; $7010
	db $00|AUD1SWEEP_UP, 1|AUDLEN_DUTY_50, $15|AUDENV_DOWN
	dw $7A7|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; F#6
Sample06_02:: ; $7015
	db $00|AUD1SWEEP_UP, 1|AUDLEN_DUTY_50, $17|AUDENV_DOWN
	dw $7A7|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; F#6

Sample07_04:: ; $701A
	db $12|AUD1SWEEP_DOWN, 1|AUDLEN_DUTY_50, $F0|AUDENV_DOWN
	dw $79D|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; E6
Sample07_03:: ; $701F
	db $11|AUD1SWEEP_DOWN, 3|AUDLEN_DUTY_50, $72|AUDENV_DOWN
	dw $79E|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; E6
Sample07_02:: ; $7024
	db $12|AUD1SWEEP_UP, 3|AUDLEN_DUTY_25, $32|AUDENV_UP
	dw $79F|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; E6

Sample08_05:: ; $7029
	db $00|AUD1SWEEP_UP, 1|AUDLEN_DUTY_50, $72|AUDENV_DOWN
	dw $77F|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; B5
Sample08_04:: ; $702E
	db $00|AUD1SWEEP_UP, 1|AUDLEN_DUTY_50, $15|AUDENV_DOWN
	dw $77F|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; B5
Sample08_03:: ; $7033
	db $00|AUD1SWEEP_UP, 1|AUDLEN_DUTY_50, $72|AUDENV_DOWN
	dw $77F|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; B5
Sample08_02:: ; $7038
	db $00|AUD1SWEEP_UP, 1|AUDLEN_DUTY_50, $17|AUDENV_DOWN
	dw $77F|(AUDHIGH_RESTART|AUDHIGH_LENGTH_ON)<<8 ; B5

; unused duplicate of 07, pitched a minor 16th up
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
