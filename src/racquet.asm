include "common.inc"
setcharmap DMG

SECTION FRAGMENT "Main code", ROM0
MoveRacquetSprite:: ; $109D
; perform one frame of racquet movement, then update its sprite
; out(A) = OAMF_PAL0|OAMF_BANK0 (|OAMF_XFLIP unless small racquet)
; out(HL) = oamBuf + 3*sizeof_OAM_ATTRS
; if paddle used: out(B) = 119 + OAM_X_OFS - [racquetWidth]
; otherwise:
;   out(B) = 1 if B held, otherwise 5 if A held, otherwise 3
;   out(C) = 119 + OAM_X_OFS - [racquetWidth] if moved right, otherwise in(C)
	call MoveRacquet
	call MakeRacquetSprite
	ret

MoveRacquet:: ; $10A4
; perform one frame of racquet movement based on user input
; out(A) = final [racquetX]
; if paddle used: out(B) = 119 + OAM_X_OFS - [racquetWidth]
; otherwise:
;   out(B) = 1 if B held, otherwise 5 if A held, otherwise 3
;   out(C) = 119 + OAM_X_OFS - [racquetWidth] if moved right, otherwise in(C)
	ldh a, [paddleAngle]
	cp $F1
	jr c, .paddle
	ld b, 5
	ldh a, [buttonsDown]
	rrca
	jr nc, .ab_down
	ld b, 1
	rrca
	jr nc, .ab_down
	ld b, 3
.ab_down::
	ldh a, [buttonsDown]
	xor $FF
	and PADF_LEFT|PADF_RIGHT
	ret z
	and PADF_LEFT
	jr z, .right
	ldh a, [racquetX]
	sub b
	cp 7 + OAM_X_OFS
	jr nc, .left
	ld a, 7 + OAM_X_OFS
	jr .left
.right::
	ldh a, [racquetWidth]
	ld c, a
	ld a, 119 + OAM_X_OFS
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
	ld a, 119 + OAM_X_OFS
	sub b
	ld b, a
	ldh a, [paddleAngle]
	sub $30
	jr c, .min
.check::
	cp 7 + OAM_X_OFS
	jr nc, .max
.min::
	ld a, 7 + OAM_X_OFS
	jr .done
.max::
	cp b
	jr c, .done
	ld a, b
.done::
	ldh [racquetX], a
	ret

RacquetEnd:: ; $10FB
; reset the racquet's size & attempt to move its left edge 4 pixels to the left
; out(A) = final [racquetX]
; out(B) = 96 + OAM_X_OFS
	xor a
	ldh [smallRacquetFlag], a
	ld a, 24
	ldh [racquetWidth], a
	ldh a, [racquetX]
; BUG: the racquet should not have been moved unless it was already small.
	sub 4
	ldh [racquetX], a
	ldh a, [racquetWidth]
	ld b, a
	ld a, 120 + OAM_X_OFS
	sub b
	ld b, a
	ldh a, [racquetX]
	jr MoveRacquet.check

BounceOffRacquet:: ; $1113
; bounce the ball off the racquet
; out(A) = EFFECT_BOUNCE_RACQUET
; barring CheckStageFall:
;   out(BC) = updated horizontal velocity
;   out(D) = 6 if small racquet, 8 otherwise
;   out(E) = in(A)
;   out(HL) = pointer to next sine table entry
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
	ld d, 8
	ldh a, [smallRacquetFlag]
	cp $00
	jr z, .normalX
	ld d, 6
.normalX::
	pop af
; BUG: this checks what side the left edge of the ball is on, not the whole ball.
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
; check if the stage should fall a row after hitting the racquet
; out(A) = updated [stageFallTimer]
; if action performed:
;   if this is one of the first 10 times:
;     out(B) = 0
;     out(C) = prior [stageFallCounter]
;     out(HL) = pointer to new timer modulo
;   otherwise, if a new row of tiles was revealed:
;     out(BC) = mainStripArray + 3 + STAGE_COLUMNS*2
;     out(HL) = bottom-left brick of row in (stage)
;   if a new row of tiles was revealed at all:
;     out(DE) = mainStripArray + 3 + STAGE_COLUMNS
	ldh a, [stageFallTimer]
	dec a
	ldh [stageFallTimer], a
	jr nz, .write_timer
	call StageFallStep
.init_timer::
	ldh a, [stageFallCounter]
	cp 10
	jr c, .read_modulo
	ld a, 1
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
; make sprites for the racquet
; out(A) = OAMF_PAL0|OAMF_BANK0 (|OAMF_XFLIP unless small racquet)
; out(HL) = oamBuf + 3*sizeof_OAM_ATTRS
	ld hl, oamBuf
	ldh a, [smallRacquetFlag]
	cp $00
	jr nz, .small
	ldh a, [racquetY]
	ld [hl+], a
	ldh a, [racquetX]
	add a, 1
	ld [hl+], a
	ld a, $00
	ld [hl+], a
	ld a, OAMF_PAL0|OAMF_BANK0
	ld [hl+], a
	ldh a, [racquetY]
	ld [hl+], a
	ldh a, [racquetX]
	add a, 9
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
	add a, 1
	ld [hl+], a
	ld a, $00
	ld [hl+], a
	ld a, OAMF_PAL0|OAMF_BANK0
	ld [hl+], a
	ldh a, [racquetY]
	ld [hl+], a
	ldh a, [racquetX]
	add a, 9
	ld [hl+], a
	ld a, $00
	ld [hl+], a
	ld a, OAMF_XFLIP|OAMF_PAL0|OAMF_BANK0
	ld [hl+], a
	ldh a, [racquetY]
	ld [hl+], a
	ldh a, [racquetX]
	add a, 5
	ld [hl+], a
	ld a, $01
	ld [hl+], a
	ld a, OAMF_PAL0|OAMF_BANK0
	ld [hl+], a
	ret
