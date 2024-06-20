include "common.inc"
setcharmap DMG

SECTION FRAGMENT "Main code", ROM0
Func0CA6:: ; $0CA6
	call UpdateBallPos
	call Func0CB0
	call Func108D
	ret

Func0CB0:: ; $0CB0
	nop
	ldh a, [ballSpeedY]
	and $80
	jr nz, .on_screen
	ldh a, [ballPosY]
	sub 141
	jr c, .on_screen
	cp $08
	jr nc, .on_screen
	ld c, a
	ldh a, [racquetWidth]
	add a, $05
	ld d, a
	ldh a, [racquetX]
	sub $03
	ld b, a
	ldh a, [ballPosX]
	sub b
	cp d
	jr nc, .on_screen
	srl a
	ld b, a
	ld a, c
	cp $07
	ld a, b
	push af
	call c, Func1113
	pop af
	call nc, Func0EAD
.on_screen::
	ldh a, [ballPosY]
	cp 24
	jp c, .hit_ceiling
	cp 160
	jp c, .not_fell_through
	ld a, $07
	ldh [gameMode], a
	ret
.hit_ceiling::
	call PlaySound.twelve
	ldh a, [specialStage]
	cp $00
	jr nz, .keep_racquet
	ldh a, [smallRacquetFlag]
	cp $00
	jr nz, .keep_racquet
	ld a, $01
	ldh [smallRacquetFlag], a
	ld a, 16
	ldh [racquetWidth], a
	ldh a, [racquetX]
	add a, $04
	ldh [racquetX], a
	call PlaySound.eleven
.keep_racquet::
	call Func0E8D
.not_fell_through::
	ldh a, [ballPosX]
	cp $10
	jp c, .bounce
	cp $7C
	jp c, .no_bounce
.bounce::
	call Func0EAD
	call PlaySound.twelve
.no_bounce::
	ldh a, [ballPosY]
	sub $88
	ret nc
	xor a
	ldh [bounceFlag], a
	call Func0D37
	ldh a, [bounceFlag]
	cp $00
	ret z
	; fallthrough otherwise

Func0D37:: ; $0D37
	ldh a, [ballSpeedX]
	and $80
	push af
	call z, Func0D96
	pop af
	call nz, Func0DB9
	ldh a, [ballSpeedY]
	and $80
	push af
	call z, Func0D50
	pop af
	call nz, Func0D73
	ret

Func0D50:: ; 0D50
	ldh a, [ballPosY]
	add a, $03
	ldh [ballPosYTest], a
	ldh a, [ballPosXLast]
	ldh [ballPosXTest], a
	call Func0DDC
	cp $00
	jp nz, Func0E8D
	ldh a, [ballPosY]
	ldh [ballPosYTest], a
	ldh a, [ballPosXLast]
	ldh [ballPosXTest], a
	call Func0DDC
	cp $00
	ret z
	jp Func0ECD

Func0D73:: ; $0D73
	ldh a, [ballPosY]
	ldh [ballPosYTest], a
	ldh a, [ballPosXLast]
	ldh [ballPosXTest], a
	call Func0DDC
	cp $00
	jp nz, Func0E8D
	ldh a, [ballPosY]
	add a, $03
	ldh [ballPosYTest], a
	ldh a, [ballPosXLast]
	ldh [ballPosXTest], a
	call Func0DDC
	cp $00
	ret z
	jp Func0ECD

Func0D96:: ; $0D96
	ldh a, [ballPosYLast]
	ldh [ballPosYTest], a
	ldh a, [ballPosX]
	add a, $03
	ldh [ballPosXTest], a
	call Func0DDC
	cp $00
	jp nz, Func0EAD
	ldh a, [ballPosYLast]
	ldh [ballPosYTest], a
	ldh a, [ballPosX]
	ldh [ballPosXTest], a
	call Func0DDC
	cp $00
	ret z
	jp Func0EDB

Func0DB9:: ; $0DB9
	ldh a, [ballPosYLast]
	ldh [ballPosYTest], a
	ldh a, [ballPosX]
	ldh [ballPosXTest], a
	call Func0DDC
	cp $00
	jp nz, Func0EAD
	ldh a, [ballPosYLast]
	ldh [ballPosYTest], a
	ldh a, [ballPosX]
	add a, $03
	ldh [ballPosXTest], a
	call Func0DDC
	cp $00
	ret z
	jp Func0EDB

Func0DDC:: ; $0DDC
	ld a, [stageScy]
	sub $00
	ld b, a
	ldh a, [ballPosYTest]
	sub 24
	add a, b
	jr c, .no_bounce
	srl a
	srl a
	ldh [rowToDraw], a
	cp 60
	jr c, .check
.no_bounce::
	ld a, $00
	ret
.check::
	ld b, a
	ldh a, [stageFallMax]
	ld c, a
	ld a, b
	sub c
	ld c, a
	ld b, $00
	ld hl, scrollOffsets
	add hl, bc
	ld a, [hl]
	sub $00
	ld b, a
	ldh a, [ballPosXTest]
	sub 16
	add a, b
	cp 112
	jr c, .left
	sub 112
.left::
	srl a
	srl a
	srl a
	ldh [colToDraw], a
	ldh a, [rowToDraw]
	ld b, a
	ld e, $0E
	call MultiplyBxE
	ldh a, [colToDraw]
	ld l, a
	ld h, $00
	add hl, bc
	ld bc, stage
	add hl, bc
	ld a, [hl]
	cp $00
	ret z
	ldh [tileToDraw], a
	push hl
	call Func0F2F
	pop hl
	ld d, h
	ld e, l
	ld bc, hitsLeft - stage
	add hl, bc
	ld a, [hl]
	cp $00
	jr z, .bumper
	ld b, a
	ldh a, [specialStage]
	cp $00
	jr nz, .special
	dec b
	ld [hl], b
	ret nz
.special::
	xor a
	ld [de], a
	ldh a, [tileToDraw]
	call UpdateScore
	call UpdateHiScore
	call GiveBonus
	call DispScore
	call LoadBrickSound
	call DrawTile
	ldh a, [bricksLeft]
	ld b, a
	ldh a, [bricksLeft+1]
	ld c, a
	dec bc
	ld a, b
	ldh [bricksLeft], a
	ld a, c
	ldh [bricksLeft+1], a
	or b
	jr nz, .keep_playing
	ld a, $08
	ldh [gameMode], a
.keep_playing::
	ldh a, [specialStage]
	cp $00
	jp nz, .no_bounce
.set_bounce_flag::
	ldh a, [bounceFlag]
	inc a
	ldh [bounceFlag], a
	ld a, $01
	ret
.bumper::
	call Func0F4F
	call LoadBrickSound
	jr .set_bounce_flag

Func0E8D:: ; $0E8D
	ldh a, [ballSpeedY]
	and $80
	push af
	call z, BounceDownUp
	pop af
	call nz, BounceUpDown
	ldh a, [ballSpeedY]
	ld b, a
	ldh a, [ballSpeedY+1]
	ld c, a
	call NegativeBC
	ld a, b
	ldh [ballSpeedY], a
	ld a, c
	ldh [ballSpeedY+1], a
	ldh a, [ballPosY]
	ldh [ballPosYLast], a
	ret

Func0EAD:: ; $0EAD
	ldh a, [ballSpeedX]
	and $80
	push af
	call z, BounceRightLeft
	pop af
	call nz, BounceLeftRight
	ldh a, [ballSpeedX]
	ld b, a
	ldh a, [ballSpeedX+1]
	ld c, a
	call NegativeBC
	ld a, b
	ldh [ballSpeedX], a
	ld a, c
	ldh [ballSpeedX+1], a
	ldh a, [ballPosX]
	ldh [ballPosXLast], a
	ret

Func0ECD:: ; $0ECD
	ret
; dummied out
	ldh a, [ballSpeedY]
	and $80
	push af
	call nz, BounceDownUp
	pop af
	call z, BounceUpDown
	ret

Func0EDB:: ; $0EDB
	ldh a, [ballSpeedX]
	and $80
	push af
	call nz, BounceRightLeft
	pop af
	call z, BounceLeftRight
	ret

BounceDownUp:: ; $0EE8
	ldh a, [ballPosY]
	and $03
	ret z
	ld b, a
	ldh a, [ballPosY]
	and $FC
	sub b
	inc a
	ldh [ballPosY], a
	ret

BounceUpDown:: ; $0EF7
	ldh a, [ballPosY]
	and $03
	ret z
	ld b, a
	ldh a, [ballPosY]
	and $FC
	add a, $08
	sub b
	dec a
	ldh [ballPosY], a
	ret

BounceRightLeft:: ; $0F08
	ld b, $04
	ldh a, [ballPosX]
	and $04
	jr nz, .pos
	ld b, -$04
.pos::
	ldh a, [ballPosX]
	and $F8
	add a, b
	cp 16
	jr nc, .ok
	ld a, 16
.ok::
	ldh [ballPosX], a
	ret

BounceLeftRight:: ; $0F20
	ldh a, [ballPosX]
	and $F8
	add a, $08
	cp 124
	jr c, .ok
	ld a, 124
.ok::
	ldh [ballPosX], a
	ret

Func0F2F:: ; $0F2F
	ldh a, [tileToDraw]
	dec a
	ld b, a
	ld e, $06
	call MultiplyBxE
	ld hl, BrickTypes
	add hl, bc
	ld b, $00
	ld c, $04
	add hl, bc
	ld a, [hl]
	cp $00
	ret z
	ld b, a
	ldh a, [bounceSpeed]
	cp b
	ret nc
	ld a, b
	ldh [bounceSpeed], a
	jr Func0FBD

Func0F4F:: ; $0F4F
	ldh a, [changeAngleCounter]
	inc a
	cp $0A
	jr c, .not_finished
	call Func0FBD
	xor a
.not_finished::
	ldh [changeAngleCounter], a
	ret

Func0F5D:: ; $0F5D
	ldh a, [speedUpCounter]
	inc a
	cp $08
	jr c, .not_finished
	call Func0F6E
	call Func0FBD
	xor a
.not_finished::
	ldh [speedUpCounter], a
	ret

Func0F6E:: ; $0F6E
	ldh a, [bounceSpeed]
	inc a
	cp $1A
	jr c, .ok
	ld a, $03
.ok::
	ldh [bounceSpeed], a
	jp DispBounceSpeed

UpdateBallPos:: ; $0F7C
	ldh a, [ballPosY]
	ldh [ballPosYLast], a
	ld h, a
	ldh a, [ballPosY+1]
	ld l, a
	ldh a, [ballSpeedY]
	ld b, a
	ldh a, [ballSpeedY+1]
	ld c, a
	add hl, bc
	ld a, c
	ldh [ballSpeedY+1], a
	ld a, b
	ldh [ballSpeedY], a
	ld a, l
	ldh [ballPosY+1], a
	ld a, h
	ldh [ballPosY], a

	ldh a, [ballPosX]
	ldh [ballPosXLast], a
	ld h, a
	ldh a, [ballPosX+1]
	ld l, a
	ldh a, [ballSpeedX]
	ld b, a
	ldh a, [ballSpeedX+1]
	ld c, a
	add hl, bc
	ld a, c
	ldh [ballSpeedX+1], a
	ld a, b
	ldh [ballSpeedX], a
	ld a, l
	ldh [ballPosX+1], a
	ld a, h
	ldh [ballPosX], a
	ret

NegativeBC:: ; $0FB3
	ld a, b
	xor $FF
	ld b, a
	ld a, c
	xor $FF
	ld c, a
	inc bc
	ret

Func0FBD:: ; $0FBD
	ld b, $00
	ldh a, [bounceSpeed]
	dec a
	sla a
	ld c, a
	ld hl, SineTables
	add hl, bc
	ld a, [hl+]
	ld c, a
	ld a, [hl]
	ld b, a
	push bc
	call RandomNumber
	and $07
	ld b, $00
	ld c, a
	ld hl, HorizontalAngles
	add hl, bc
	ld a, [hl]
	pop bc
	sla a
	sla a
	ld h, $00
	ld l, a
	add hl, bc
	ld a, [hl+]
	ld b, a
	ld a, [hl+]
	ld c, a
	ldh a, [ballSpeedY]
	and $80
	jr z, .pos_y
	call NegativeBC
.pos_y::
	ld a, b
	ldh [ballSpeedY], a
	ld a, c
	ldh [ballSpeedY+1], a
	ld a, [hl+]
	ld b, a
	ld a, [hl+]
	ld c, a
	ldh a, [ballSpeedX]
	and $80
	jr z, .pos_x
	call NegativeBC
.pos_x::
	ld a, b
	ldh [ballSpeedX], a
	ld a, c
	ldh [ballSpeedX+1], a
	ret

; Wikipedia claims that the ball only moves at 15°, 30°, and 45° angles.
; its source for this claim is the game's official website, which makes no mention
; of exact angles. it does have several 45° arrows, and one 15° arrow, but i have
; reason to believe there was little to no intention behind these angles.
HorizontalAngles:: ; $100B
	;  30°, 40°, 50°, 30°, 40°, 50°, 40°, 50°
	db $06, $08, $0A, $06, $08, $0A, $08, $0A
VerticalAngles:: ; $1013
	;  50°, 60°, 70°, 50°, 60°, 70°, 50°, 60°
	db $0A, $0C, $0E, $0A, $0C, $0E, $0A, $0C

Func101B:: ; $101B
	xor a
	ldh [ballPosY+1], a
	ldh [ballPosX+1], a
	ld a, $03
	ldh [bounceSpeed], a
	ldh a, [specialStage]
	cp $00
	jr nz, .special
	ldh a, [bricksLeft]
	cp $00
	jr nz, .forty_bricks
	ldh a, [bricksLeft+1]
	cp 40
	jr nc, .forty_bricks
.special::
	ld a, $07
	ldh [bounceSpeed], a
.forty_bricks::
	ld a, 24
	ld b, a
	ldh a, [racquetWidth]
	srl a
	ld c, a
	ldh a, [racquetX]
	add a, c
	cp 72
	jr c, .left
	ld a, -24
	ld b, a
.left::
	ldh a, [racquetX]
	add a, b
	add a, c
	ldh [ballPosX], a
	ldh [ballPosXLast], a
	ld a, 140
	sub 24
	ldh [ballPosY], a
	ldh [ballPosYLast], a
	ld a, b
	push af
	ld b, $00
	ld c, $00
	ld hl, SineTables
	add hl, bc
	ld a, [hl+]
	ld c, a
	ld a, [hl]
	ld b, a
	ld a, $09
	sla a
	sla a
	ld h, $00
	ld l, a
	add hl, bc
	ld a, [hl+]
	ldh [ballSpeedY], a
	ld a, [hl+]
	ldh [ballSpeedY+1], a
	ld a, [hl+]
	ld b, a
	ld a, [hl+]
	ld c, a
	pop af
	cp $80
	jr nc, .pos
	call NegativeBC
.pos::
	ld a, b
	ldh [ballSpeedX], a
	ld a, c
	ldh [ballSpeedX+1], a
	ret

Func108D:: ; $108D
	ld hl, oamBuf + $0C
	ldh a, [ballPosY]
	ld [hl+], a
	ldh a, [ballPosX]
	ld [hl+], a
	ld a, $05
	ld [hl+], a
	ld a, $00
	ld [hl+], a
	ret
