include "common.inc"
setcharmap DMG

SECTION FRAGMENT "Main code", ROM0
MoveRacquetSprite:: ; $109D
	call MoveRacquet
	call MakeRacquetSprite
	ret

MoveRacquet:: ; $10A4
	ldh a, [paddleAngle]
	cp $F1
	jr c, .paddle
	ld b, $05
	ldh a, [buttonsDown]
	rrca
	jr nc, .ab_down
	ld b, $01
	rrca
	jr nc, .ab_down
	ld b, $03
.ab_down::
	ldh a, [buttonsDown]
	xor $FF
	and PADF_LEFT|PADF_RIGHT
	ret z
	and PADF_LEFT
	jr z, .right
	ldh a, [racquetX]
	sub b
	cp 15
	jr nc, .left
	ld a, 15
	jr .left
.right::
	ldh a, [racquetWidth]
	ld c, a
	ld a, 127
	sub c
	ld c, a
	ldh a, [racquetX]
	add a, b
	cp c
	jr c, .left
	ld a, c
.left::
	ldh [racquetX], a
	ret
.paddle::
	ldh a, [racquetWidth]
	ld b, a
	ld a, 127
	sub b
	ld b, a
	ldh a, [paddleAngle]
	sub $30
	jr c, .min
.check::
	cp 15
	jr nc, .max
.min::
	ld a, 15
	jr .done
.max::
	cp b
	jr c, .done
	ld a, b
.done::
	ldh [racquetX], a
	ret

RacquetEnd:: ; $10FB
	xor a
	ldh [smallRacquetFlag], a
	ld a, 24
	ldh [racquetWidth], a
	ldh a, [racquetX]
	sub $04
	ldh [racquetX], a
	ldh a, [racquetWidth]
	ld b, a
	ld a, 128
	sub b
	ld b, a
	ldh a, [racquetX]
	jr MoveRacquet.check

BounceOffRacquet:: ; $1113
	push af
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
	pop af
	push af
	ld d, $00
	ld e, a
	ld hl, NormalRacquetAngles
	ldh a, [smallRacquetFlag]
	cp $00
	jr z, .normalY
	ld hl, SmallRacquetAngles
.normalY::
	add hl, de
	ld a, [hl]
	sla a
	sla a
	ld h, $00
	ld l, a
	add hl, bc
	ld a, [hl+]
	ld b, a
	ld a, [hl+]
	ld c, a
	call NegativeBC
	ld a, b
	ldh [ballSpeedY], a
	ld a, c
	ldh [ballSpeedY+1], a
	ld a, [hl+]
	ld b, a
	ld a, [hl+]
	ld c, a
	ld d, $08
	ldh a, [smallRacquetFlag]
	cp $00
	jr z, .normalX
	ld d, $06
.normalX::
	pop af
	cp d
	jr nc, .pos
	call NegativeBC
.pos::
	ld a, b
	ldh [ballSpeedX], a
	ld a, c
	ldh [ballSpeedX+1], a
	call CheckStageFall
	jp PlaySound.bounce_racquet

CheckStageFall:: ; $116D
	ldh a, [stageFallTimer]
	dec a
	ldh [stageFallTimer], a
	jr nz, .write_timer
	call StageFallStep
.init_timer::
	ldh a, [stageFallCounter]
	cp $0A
	jr c, .read_modulo
	ld a, $01
	jr .write_timer
.read_modulo::
	ld c, a
	ld b, $00
	inc a
	ldh [stageFallCounter], a
	ld hl, StageFallModulo
	add hl, bc
	ld a, [hl]
.write_timer::
	ldh [stageFallTimer], a
	ret

MakeRacquetSprite:: ; $118F
	ld hl, oamBuf
	ldh a, [smallRacquetFlag]
	cp $00
	jr nz, .small
	ldh a, [racquetY]
	ld [hl+], a
	ldh a, [racquetX]
	add a, $01
	ld [hl+], a
	ld a, $00
	ld [hl+], a
	ld a, OAMF_PAL0|OAMF_BANK0
	ld [hl+], a
	ldh a, [racquetY]
	ld [hl+], a
	ldh a, [racquetX]
	add a, $09
	ld [hl+], a
	ld a, $01
	ld [hl+], a
	ld a, OAMF_PAL0|OAMF_BANK0
	ld [hl+], a
	ldh a, [racquetY]
	ld [hl+], a
	ldh a, [racquetX]
	add a, 17
	ld [hl+], a
	ld a, $00
	ld [hl+], a
	ld a, OAMF_XFLIP|OAMF_PAL0|OAMF_BANK0
	ld [hl+], a
	ret
.small::
	ldh a, [racquetY]
	ld [hl+], a
	ldh a, [racquetX]
	add a, $01
	ld [hl+], a
	ld a, $00
	ld [hl+], a
	ld a, OAMF_PAL0|OAMF_BANK0
	ld [hl+], a
	ldh a, [racquetY]
	ld [hl+], a
	ldh a, [racquetX]
	add a, $09
	ld [hl+], a
	ld a, $00
	ld [hl+], a
	ld a, OAMF_XFLIP|OAMF_PAL0|OAMF_BANK0
	ld [hl+], a
	ldh a, [racquetY]
	ld [hl+], a
	ldh a, [racquetX]
	add a, $05
	ld [hl+], a
	ld a, $01
	ld [hl+], a
	ld a, OAMF_PAL0|OAMF_BANK0
	ld [hl+], a
	ret
