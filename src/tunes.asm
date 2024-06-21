include "common.inc"
setcharmap DMG

SECTION FRAGMENT "Main code", ROM0
TurnOnAudio:: ; $6375
	ld a, AUDENA_ON
	ldh [rAUDENA], a
	ld a, $77
	ldh [rAUDVOL], a
	ld a, AUDTERM_4_LEFT|AUDTERM_3_LEFT|AUDTERM_2_LEFT|AUDTERM_1_LEFT|AUDTERM_4_RIGHT|AUDTERM_3_RIGHT|AUDTERM_2_RIGHT|AUDTERM_1_RIGHT
	ldh [rAUDTERM], a
	ret

StartAudio:: ; $6382
	xor a
	ld [audioCancelFlag], a
	ret

CancelAudio:: ; $6387
	ld a, $01
	ld [audioCancelFlag], a
	ret

LoadBrickSound:: ; $638D
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
	jr z, PlaySound.three
	cp $01
	jr z, PlaySound.two
	cp $02
	jr z, PlaySound.five
	jr PlaySound.six

PlaySound:: ; $63AE
.one::
	ld a, $01
	jr .done
.two::
	ld a, $02
	jr .done
.three::
	ld a, $03
	jr .done
.four::
	ld a, $04
	jr .done
.five::
	ld a, $05
	jr .done
.six::
	ld a, $06
	jr .done
.seven::
	ld a, $07
	jr .done
.eight::
	ld a, $08
	jr .done
.nine::
	ld a, $09
	jr .done
.ten::
	ld a, $0A
	jr .done
.eleven::
	ld a, $0B
	jr .done
.twelve::
	ld a, $0C
.done::
	ld [audioStarting1], a
	ret

PlayNoise:: ; $63E0
	ld a, $01
	jr .but_why
.but_why::
	ld [audioNoiseFlag], a
	ret

PlayMusic:: ; $63E8
.one::
	ld a, $01
	jr .done
.two::
	ld a, $02
	jr .done
.three::
	ld a, $03
	jr .done
.four::
	ld a, $04
	jr .done
.five::
	ld a, $05
	jr .done
.six::
	ld a, $06
	jr .done
.seven::
	ld a, $07
	jr .done
.eight::
	ld a, $08
	jr .done
.nine::
	ld a, $09
	jr .done
.ten::
	ld a, $0A
	jr .done
.eleven::
	ld a, $0B
	jr .done
.twelve::
	ld a, $0C
.done::
	ld [audioStarting23], a
	ret
