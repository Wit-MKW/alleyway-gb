include "common.inc"
setcharmap DMG

SECTION FRAGMENT "Main code", ROM0
UpdateBall:: ; $0CA6
	call UpdateBallPos
	call DoBallPhysics
	call MakeBallSprite
	ret

DoBallPhysics:: ; $0CB0
	nop
	ldh a, [ballSpeedY]
	and $80
	jr nz, .not_touching_racquet
	ldh a, [ballPosY]
	sub 125 + OAM_Y_OFS
	jr c, .not_touching_racquet
	cp $08
	jr nc, .not_touching_racquet
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
	jr nc, .not_touching_racquet
	srl a
	ld b, a
	ld a, c
	cp $07
	ld a, b
	push af
	call c, BounceOffRacquet
	pop af
	call nc, BounceX
.not_touching_racquet::
	ldh a, [ballPosY]
	cp 8 + OAM_Y_OFS
	jp c, .hit_ceiling
	cp SCRN_Y + OAM_Y_OFS
	jp c, .not_fell_through
	ld a, gameMode_LOST_BALL
	ldh [gameMode], a
	ret
.hit_ceiling::
	call PlaySound.bounce_wall
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
	call PlaySound.racquet_shrink
.keep_racquet::
	call BounceY
.not_fell_through::
	ldh a, [ballPosX]
	cp 8 + OAM_X_OFS
	jp c, .bounce
	cp 116 + OAM_X_OFS
	jp c, .no_bounce
.bounce::
	call BounceX
	call PlaySound.bounce_wall
.no_bounce::
	ldh a, [ballPosY]
	sub 120 + OAM_Y_OFS
	ret nc
	xor a
	ldh [bounceFlag], a
	call TestForBounce
	ldh a, [bounceFlag]
	cp $00
	ret z
	; fallthrough otherwise

TestForBounce:: ; $0D37
	ldh a, [ballSpeedX]
	and $80
	push af
	call z, TestRight
	pop af
	call nz, TestLeft
	ldh a, [ballSpeedY]
	and $80
	push af
	call z, TestDown
	pop af
	call nz, TestUp
	ret

TestDown:: ; $0D50
	ldh a, [ballPosY]
	add a, $03
	ldh [ballPosYTest], a
	ldh a, [ballPosXLast]
	ldh [ballPosXTest], a
	call TestBallPos
	cp $00
	jp nz, BounceY
	ldh a, [ballPosY]
	ldh [ballPosYTest], a
	ldh a, [ballPosXLast]
	ldh [ballPosXTest], a
	call TestBallPos
	cp $00
	ret z
	jp PassThroughY

TestUp:: ; $0D73
	ldh a, [ballPosY]
	ldh [ballPosYTest], a
	ldh a, [ballPosXLast]
	ldh [ballPosXTest], a
	call TestBallPos
	cp $00
	jp nz, BounceY
	ldh a, [ballPosY]
	add a, $03
	ldh [ballPosYTest], a
	ldh a, [ballPosXLast]
	ldh [ballPosXTest], a
	call TestBallPos
	cp $00
	ret z
	jp PassThroughY

TestRight:: ; $0D96
	ldh a, [ballPosYLast]
	ldh [ballPosYTest], a
	ldh a, [ballPosX]
	add a, $03
	ldh [ballPosXTest], a
	call TestBallPos
	cp $00
	jp nz, BounceX
	ldh a, [ballPosYLast]
	ldh [ballPosYTest], a
	ldh a, [ballPosX]
	ldh [ballPosXTest], a
	call TestBallPos
	cp $00
	ret z
	jp PassThroughX

TestLeft:: ; $0DB9
	ldh a, [ballPosYLast]
	ldh [ballPosYTest], a
	ldh a, [ballPosX]
	ldh [ballPosXTest], a
	call TestBallPos
	cp $00
	jp nz, BounceX
	ldh a, [ballPosYLast]
	ldh [ballPosYTest], a
	ldh a, [ballPosX]
	add a, $03
	ldh [ballPosXTest], a
	call TestBallPos
	cp $00
	ret z
	jp PassThroughX

TestBallPos:: ; $0DDC
	ld a, [stageScy]
	sub $00
	ld b, a
	ldh a, [ballPosYTest]
	sub 8 + OAM_Y_OFS
	add a, b
	jr c, .no_bounce
	srl a
	srl a
	ldh [rowToDraw], a
	cp STAGE_ROWS_MAX
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
	sub 8 + OAM_X_OFS
	add a, b
	cp STAGE_COLUMNS*8
	jr c, .left
	sub STAGE_COLUMNS*8
.left::
	srl a
	srl a
	srl a
	ldh [colToDraw], a
	ldh a, [rowToDraw]
	ld b, a
	ld e, STAGE_COLUMNS
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
	call SetBrickSpeed
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
	ld a, gameMode_NEXT_STAGE
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
	call CheckChangeAngle
	call LoadBrickSound
	jr .set_bounce_flag

BounceY:: ; $0E8D
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

BounceX:: ; $0EAD
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

PassThroughY:: ; $0ECD
	ret
; dummied out
	ldh a, [ballSpeedY]
	and $80
	push af
	call nz, BounceDownUp
	pop af
	call z, BounceUpDown
	ret

PassThroughX:: ; $0EDB
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
	cp 8 + OAM_X_OFS
	jr nc, .ok
	ld a, 8 + OAM_X_OFS
.ok::
	ldh [ballPosX], a
	ret

BounceLeftRight:: ; $0F20
	ldh a, [ballPosX]
	and $F8
	add a, $08
	cp 116 + OAM_X_OFS
	jr c, .ok
	ld a, 116 + OAM_X_OFS
.ok::
	ldh [ballPosX], a
	ret

SetBrickSpeed:: ; $0F2F
	ldh a, [tileToDraw]
	dec a
	ld b, a
	ld e, BrickTypes_SIZEOF
	call MultiplyBxE
	ld hl, BrickTypes
	add hl, bc
	ld b, HIGH(BrickTypes_SPEED)
	ld c, LOW(BrickTypes_SPEED)
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
	jr SetBounceSpeed

CheckChangeAngle:: ; $0F4F
	ldh a, [changeAngleCounter]
	inc a
	cp 10
	jr c, .not_finished
	call SetBounceSpeed
	xor a
.not_finished::
	ldh [changeAngleCounter], a
	ret

CheckSpeedUp:: ; $0F5D
	ldh a, [speedUpCounter]
	inc a
	cp $08
	jr c, .not_finished
	call IncBounceSpeed
	call SetBounceSpeed
	xor a
.not_finished::
	ldh [speedUpCounter], a
	ret

IncBounceSpeed:: ; $0F6E
	ldh a, [bounceSpeed]
	inc a
	cp 26
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

SetBounceSpeed:: ; $0FBD
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

DeployBall:: ; $101B
	xor a
	ldh [ballPosY+1], a
	ldh [ballPosX+1], a
	ld a, $03
	ldh [bounceSpeed], a
	ldh a, [specialStage]
	cp $00
	jr nz, .special
	ldh a, [bricksLeft]
	cp HIGH(40)
	jr nz, .forty_bricks
	ldh a, [bricksLeft+1]
	cp LOW(40)
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
	cp 64 + OAM_X_OFS
	jr c, .left
	ld a, -24
	ld b, a
.left::
	ldh a, [racquetX]
	add a, b
	add a, c
	ldh [ballPosX], a
	ldh [ballPosXLast], a
	ld a, 124 + OAM_Y_OFS
	sub 24
	ldh [ballPosY], a
	ldh [ballPosYLast], a
	ld a, b
	push af
	ld b, HIGH(0)
	ld c, LOW(0)
	ld hl, SineTables
	add hl, bc
	ld a, [hl+]
	ld c, a
	ld a, [hl]
	ld b, a
	ld a, $09 ; 45°
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

MakeBallSprite:: ; $108D
	ld hl, oamBuf + 3*sizeof_OAM_ATTRS
	ldh a, [ballPosY]
	ld [hl+], a
	ldh a, [ballPosX]
	ld [hl+], a
	ld a, $05
	ld [hl+], a
	ld a, OAMF_PAL0|OAMF_BANK0
	ld [hl+], a
	ret
