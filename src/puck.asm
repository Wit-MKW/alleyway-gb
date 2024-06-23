include "common.inc"
setcharmap DMG

SECTION FRAGMENT "Main code", ROM0
UpdateBall:: ; $0CA6
; perform one frame of ball physics, then update its sprite
; out(A) = OAMF_PAL0|OAMF_BANK0
; out(HL) = oamBuf + 4*sizeof_OAM_ATTRS
; clobbers BC and DE
	call UpdateBallPos
	call DoBallCollisions
	call MakeBallSprite
	ret

DoBallCollisions:: ; $0CB0
; after the ball has moved a frame, modify that motion based on what it collides with
; clobbers all registers
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
	; fallthrough otherwise, although nothing will happen

TestForBounce:: ; $0D37
; respond to the ball colliding with anything
; clobbers all registers
; BUG: while the ball's top-left pixel has full collision, the rest of its
;   top row of pixels has only horizontal collision, the rest of its left
;   column of pixels has only vertical collision, and the rest (over half)
;   of its pixels have no collision at all.
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
; as the ball travels up, respond to its left side colliding with anything
; clobbers all registers
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
; as the ball travels up, respond to its left side colliding with anything
; clobbers all registers
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
; as the ball travels right, respond to its top colliding with anything
; clobbers all registers
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
; as the ball travels left, respond to its top colliding with anything
; clobbers all registers
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
; check if the current test position is inside a brick (or outside the playfield)
; out(A) = 1 if so, 0 otherwise
; clobbers BC, DE, and HL
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
	ldh a, [stageFallRows]
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
; bounce the ball off a row it would have entered & switch its Y-direction
; out(A) = updated [ballPosY]
; out(BC) = updated Y-velocity
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
; remove the ball from a column it would have entered & switch its X-direction
; out(A) = updated [ballPosX]
; out(BC) = updated X-velocity
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
; dummied out
	ret
; pass the ball through its current row
; out(A) = updated [ballPosY]
; out(B) = prior [ballPosY] & 3
; * if the ball is fully within one row, nothing happens except out(A) = 0.
;   however, the function is never called in such cases.
; BUG: the ball may go a fair distance beyond the row boundary.
	ldh a, [ballSpeedY]
	and $80
	push af
	call nz, BounceDownUp
	pop af
	call z, BounceUpDown
	ret

PassThroughX:: ; $0EDB
; pass the ball through its current column
; out(A) = updated [ballPosX]
; if ball is travelling right, see BounceRightLeft for out(B)
	ldh a, [ballSpeedX]
	and $80
	push af
	call nz, BounceRightLeft
	pop af
	call z, BounceLeftRight
	ret

BounceDownUp:: ; $0EE8
; assume that the ball travelled down to its current position, and set its
;   position as if its travel had changed to up at the last row boundary
; out(A) = updated [ballPosY]
; out(B) = prior [ballPosY] & 3
; * if the ball is fully within one row, nothing happens except out(A) = 0.
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
; assume that the ball travelled up to its current position, and set its
;   position as if its travel had changed to down at the last row boundary
; out(A) = updated [ballPosY]
; out(B) = prior [ballPosY] & 3
; * if the ball is fully within one row, nothing happens except out(A) = 0.
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
; send the ball just to the left of the column that its rightmost pixel is in
; out(A) = updated [ballPosX]
; out(B) = -4 if the ball is fully within one column, +4 otherwise
; * if the ball is fully in the right half of a column, it will not move &
;   out(B) will be +4, but the function is never called in such cases.
	ld b, +4
	ldh a, [ballPosX]
	and $04
	jr nz, .pos
	ld b, -4
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
; send the ball just to the right of the column that its leftmost pixel is in
; out(A) = updated [ballPosX]
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
; if the brick type in [tileToDraw] requests a faster-than-current speed, set it
; if action performed:
;   out(A) = out(C)
;   out(BC) = resulting horizontal velocity
;   out(E) = 0
;   out(HL) = pointer to next sine table entry
; otherwise:
;   out(A) = [bounceSpeed]
;   out(B) = brick speed if not zero, otherwise HIGH(BrickTypes_SPEED)
;   out(C) = LOW(BrickTypes_SPEED)
;   out(E) = 0
;   out(HL) = pointer to brick speed
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
; every 10th call, change the ball's angle randomly
; if action performed:
;   out(A) = 0
;   out(BC) = resulting horizontal velocity
;   out(HL) = pointer to next sine table entry
; otherwise: out(A) = updated [changeAngleCounter]
; * see SetBounceSpeed for angle details
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
; every 8th call, run IncBounceSpeed & SetBounceSpeed (see those for details)
; if action performed:
;   out(A) = 0
;   out(BC) = resulting horizontal velocity
;   out(HL) = pointer to next sine table entry
; otherwise: out(A) = updated [speedUpCounter]
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
; add .125px/frame to bounce speed, wrapping from 4+ px/frame to 1.25px/frame
; out(A) = updated [bounceSpeed]
	ldh a, [bounceSpeed]
	inc a
	cp 26
	jr c, .ok
	ld a, 3
.ok::
	ldh [bounceSpeed], a
	jp DispBounceSpeed

UpdateBallPos:: ; $0F7C
; perform one frame of ball motion
; out(A) = out(H)
; out(BC) = ball's horizontal velocity
; out(HL) = ball's updated X-coordinate
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
; out(A) = out(C) - 1
; out(BC) = -in(BC)
	ld a, b
	xor $FF
	ld b, a
	ld a, c
	xor $FF
	ld c, a
	inc bc
	ret

SetBounceSpeed:: ; $0FBD
; set the ball's speed from [bounceSpeed], and its angle at random
; out(A) = out(C)
; out(BC) = resulting horizontal velocity
; out(HL) = pointer to next sine table entry
; * random angle: 3/8 chance of 30°, 3/8 chance of 40°, 1/4 chance of 50°
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
; deploy a ball coming toward the racquet
; out(A) = out(C)
; out(BC) = +181 if ball comes from left, -181 if from right
; out(HL) = pointer to 50°, 1px/frame sine table entry
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
; make the sprite for the ball
; out(A) = OAMF_PAL0|OAMF_BANK0
; out(HL) = oamBuf + 4*sizeof_OAM_ATTRS
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
