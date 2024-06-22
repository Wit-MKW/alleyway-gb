include "common.inc"
setcharmap DMG

SECTION FRAGMENT "Main code", ROM0
SetupStage:: ; $092A
; load the stage with ID in(A) into WRAM
; out(A) = max(out(B) - STAGE_ROWS_ONSCREEN, 0)
; out(B) = stage height
; out(C) = 0
; out(DE) = (end of input stage data)
; out(HL) = (end of output stage data)
	ld b, a
	ld e, StagePointers_SIZEOF
	call MultiplyBxE
	ld hl, StagePointers
	add hl, bc
	inc hl
	ld e, [hl]
	inc hl
	ld d, [hl]
	push de
	call ClearStage
	call DrawStage
	pop de
	ld hl, stage
	ld b, $00
.bigloop::
	ld c, STAGE_COLUMNS
.loop::
	push bc
	push de
	push hl
	ld a, [de]
	ld [hl], a
	cp $00
	jr z, .empty
	push hl
	dec a
	ld b, a
	ld e, BrickTypes_SIZEOF
	call MultiplyBxE
	ld hl, BrickTypes
	add hl, bc
	ld b, HIGH(BrickTypes_POINTS)
	ld c, LOW(BrickTypes_POINTS)
	add hl, bc
	ld a, [hl]
	and $0F
	pop hl
	ld bc, hitsLeft - stage
	add hl, bc
	ld [hl], a
.empty::
	pop hl
	pop de
	pop bc
	inc hl
	inc de
	dec c
	jr nz, .loop
	inc b
	ld a, [de]
	cp $FF
	jr nz, .bigloop
	ld a, b
	ldh [stageHeight], a
	sub STAGE_ROWS_ONSCREEN
	jr nc, .stage_fall
	xor a
.stage_fall::
	ldh [stageFallMax], a
	ret

ClearStage:: ; $0983
; erase stage data from HRAM
; out(A) = 0
; out(BC) = 0
; out(DE) = hitsLeft + STAGE_ROWS_MAX*STAGE_COLUMNS
; out(HL) = stage + STAGE_ROWS_MAX*STAGE_COLUMNS
	ld hl, stage
	ld de, hitsLeft
	ld bc, STAGE_ROWS_MAX*STAGE_COLUMNS
.loop::
	ld a, $00
	ld [hl+], a
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, .loop
	ret

RedrawStage:: ; $0997
; draw the region of the stage that is currently on-screen
; clobbers A
	ldh a, [stageHeight]
	dec a
	dec a
	ldh [rowToDraw], a
	ld a, STAGE_ROWS_ONSCREEN/2
.loop::
	push af
	call DrawStageRow
	call WaitVblank
	ldh a, [rowToDraw]
	dec a
	dec a
	ldh [rowToDraw], a
	pop af
	dec a
	jr nz, .loop
	ldh a, [stageFallMax]
	cp $00
	ret z
	dec a
	ldh [rowToDraw], a
	jp DrawStageRow

DrawStage:: ; $09BB
; draw the entire stage
; out(A) = 0
	ld a, STAGE_ROWS_MAX-2
	ldh [rowToDraw], a
.loop::
	call DrawStageRow
	call WaitVblank
	ldh a, [rowToDraw]
	cp $00
	ret z
	dec a
	dec a
	ldh [rowToDraw], a
	jr .loop

CountBricks:: ; $09D0
; count up the stage's breakable bricks
; out(A) = out(E)
; out(BC) = 0
; out(DE) = be[bricksLeft] = final count
; out(HL) = stage + STAGE_ROWS_MAX*STAGE_COLUMNS
	ld hl, stage
	ld de, $0000
	ld bc, STAGE_ROWS_MAX*STAGE_COLUMNS
.loop::
	push bc
	push hl
	ld a, [hl]
	cp $00
	jr z, .nothing
	ld bc, hitsLeft - stage
	add hl, bc
	ld a, [hl]
	cp $00
	jr z, .nothing
	inc de
.nothing::
	pop hl
	inc hl
	pop bc
	dec bc
	ld a, b
	or c
	jr nz, .loop
	ld a, d
	ldh [bricksLeft], a
	ld a, e
	ldh [bricksLeft+1], a
	ret

DrawTile:: ; $09F9
; draw a single tile (a vertical pair of bricks)
; out(A) = 1
; out(E) = 0
; out(HL) = mainStripArray + 9
; clobbers BC
	call WaitToDraw
	ldh a, [rowToDraw]
	srl a
	ld b, a
	ld e, SCRN_VX_B
	call MultiplyBxE
	ldh a, [colToDraw]
	ld l, a
	ld h, $00
	add hl, bc
	ld a, h
	ldh [vramOffset], a
	ld a, l
	ldh [vramOffset+1], a
	ldh a, [rowToDraw]
	srl a
	ld b, a
	ld e, STAGE_COLUMNS*2
	call MultiplyBxE
	ldh a, [colToDraw]
	ld l, a
	ld h, $00
	add hl, bc
	ld a, $FF
	ldh [tileToDraw], a
	xor a
	push af
	ld bc, stage
	add hl, bc
	ld a, [hl]
	cp $00
	jr z, .no_top
	ldh [tileToDraw], a
	pop af
	or $01
	push af
.no_top::
	ld b, HIGH(STAGE_COLUMNS)
	ld c, LOW(STAGE_COLUMNS)
	add hl, bc
	ld a, [hl]
	cp $00
	jr z, .no_bottom
	ldh [tileToDraw], a
	pop af
	or $02
	push af
.no_bottom::
	pop af
	cp $00
	jp z, .nothing
	dec a
	push af
	ldh a, [tileToDraw]
	dec a
	ld b, a
	ld e, BrickTypes_SIZEOF
	call MultiplyBxE
	ld hl, BrickTypes
	add hl, bc
	pop af
	ld b, HIGH(BrickTypes_TILES)
	ld c, a
	add hl, bc
	ld a, [hl]
	ldh [tileToDraw], a
.nothing::
	ldh a, [vramOffset]
	ld b, a
	ldh a, [vramOffset+1]
	ld c, a
	ld hl, _SCRN0+SCRN_VX_B+1
	add hl, bc
	ld b, h
	ld c, l
	push bc
	ld b, $00
	ld c, STAGE_COLUMNS
	add hl, bc
	ld b, h
	ld c, l
	ld hl, mainStripArray
	ld a, b
	ld [hl+], a
	ld a, c
	ld [hl+], a
	ld a, $01
	ld [hl+], a
	ldh a, [tileToDraw]
	ld [hl+], a
	pop bc
	ld a, b
	ld [hl+], a
	ld a, c
	ld [hl+], a
	ld a, $01
	ld [hl+], a
	ldh a, [tileToDraw]
	ld [hl+], a
	xor a
	ld [hl+], a
	inc a
	ldh [drawNeeded], a
	ret

DrawStageRow:: ; $0A96
; draw a row of tiles (two adjacent rows of bricks)
; out(A) = 1
; out(BC) = mainStripArray + 3 + STAGE_COLUMNS*2
; out(DE) = mainStripArray + 3 + STAGE_COLUMNS
; out(HL) = bottom-left brick of row in (stage)
	call WaitToDraw
	ldh a, [rowToDraw]
	srl a
	ld b, a
	ld e, SCRN_VX_B
	call MultiplyBxE
	ld hl, _SCRN0+SCRN_VX_B+1
	add hl, bc
	ld b, h
	ld c, l
	ld hl, mainStripArray
	ld a, b
	ld [hl+], a
	ld a, c
	ld [hl+], a
	ld a, STAGE_COLUMNS*2
	ld [hl], a
	ldh a, [rowToDraw]
	srl a
	ld b, a
	ld e, STAGE_COLUMNS*2
	call MultiplyBxE
	ld hl, stage
	add hl, bc
	ld de, mainStripArray + $03
	ld a, STAGE_COLUMNS
.loop::
	push af
	push hl
	push de
	ld a, $FF
	ldh [tileToDraw], a
	xor a
	push af
	ld a, [hl]
	cp $00
	jr z, .no_top
	ldh [tileToDraw], a
	pop af
	or $01
	push af
.no_top::
	ld b, $00
	ld c, STAGE_COLUMNS
	add hl, bc
	ld a, [hl]
	cp $00
	jr z, .no_bottom
	ldh [tileToDraw], a
	pop af
	or $02
	push af
.no_bottom::
	pop af
	cp $00
	jp z, .nothing
	dec a
	push af
	ldh a, [tileToDraw]
	dec a
	ld b, a
	ld e, BrickTypes_SIZEOF
	call MultiplyBxE
	ld hl, BrickTypes
	add hl, bc
	pop af
	ld b, HIGH(BrickTypes_TILES)
	ld c, a
	add hl, bc
	ld a, [hl]
	ldh [tileToDraw], a
.nothing::
	pop de
	ldh a, [tileToDraw]
	ld [de], a
	ld b, d
	ld c, e
	ld hl, STAGE_COLUMNS
	add hl, bc
	ld [hl+], a
	ld b, h
	ld c, l
	inc de
	pop hl
	inc hl
	pop af
	dec a
	jr nz, .loop
	xor a
	ld [bc], a
	inc a
	ldh [drawNeeded], a
	ret

UpdateScroll:: ; $0B21
; update scroll counters, and offsets if appropriate
; if the stage is a scroller:
;   out(A) = STAGE_ROWS_ONSCREEN
;   out(BC) = scrollCounters + STAGE_ROWS_ONSCREEN
;   out(DE) = scrollModulo + STAGE_ROWS_ONSCREEN
;   out(HL) = scrollOffsets + STAGE_ROWS_ONSCREEN
; otherwise: out(A) = 0
	ldh a, [scrollFlag]
	cp $00
	ret z
	ld hl, scrollOffsets
	ld de, scrollModulo
	ld bc, scrollCounters
	ld a, $00
.loop::
	push af
	ld a, [bc]
	dec a
	jr nz, .skip
	ld a, [de]
	cp $00
	jr z, .skip
	and $80
	push af
	call z, IncMod112
	pop af
	call nz, DecMod112
	ld a, [de]
	and $7F
.skip::
	ld [bc], a
	inc hl
	inc de
	inc bc
	pop af
	inc a
	cp STAGE_ROWS_ONSCREEN
	jr c, .loop
	ret

IncMod112:: ; $0B53
; increment [hl], wrapping from 111+ to 0
; clobbers A
	ld a, [hl]
	inc a
	cp STAGE_COLUMNS*8
	jr c, .ok
	ld a, $00
.ok::
	ld [hl], a
	ret

DecMod112:: ; $0B5D
; decrement [hl], wrapping from 0 to 111
; clobbers A
	ld a, [hl]
	dec a
	cp -1
	jr nz, .ok
	ld a, STAGE_COLUMNS*8-1
.ok::
	ld [hl], a
	ret

IntStat_main:: ; $0B67
	ldh a, [stageRowDrawing]
	ld c, a
	inc a
; off-by-one error: row 20 is scrolled using row 0's counter as an offset.
; fortunately, there's never anything on row 20 (hence why the devs tried to skip it).
	cp STAGE_ROWS_ONSCREEN+1
	jr nc, .last_row
	ldh [stageRowDrawing], a
	sla a
	sla a
	ld b, 7
	add a, b
	ldh [rLYC], a
	ld b, $00
	ld hl, scrollOffsets
	add hl, bc
	ld a, [hl]
	ldh [rSCX], a
	xor a
	cp c
	ret nz
	ld a, [stageScy]
	ldh [rSCY], a
	ret
.last_row::
	xor a
	ldh [stageRowDrawing], a
	ld b, 7
	add a, b
	ldh [rLYC], a
	ld a, [borderScy]
	ldh [rSCY], a
	xor a
	ldh [rSCX], a
	ret

ResetScroll:: ; $0B9D
; set all scroll offsets to 0
; out(A) = out(B)
; out(B) = 22 tiles' height if at least a screen's worth of bricks
;   are above the screen, 14 tiles' height otherwise
	ld a, $00
	ldh [scxTmp], a
	ld hl, scrollOffsets
	ld b, STAGE_ROWS_ONSCREEN
.loop::
	ld [hl+], a
	dec b
	jr nz, .loop
	xor a
	ldh [scyTmp], a
	; fallthrough

SetStageScy:: ; $0BAD
; set SCY appropriately for stage rendering
; out(A) = out(B)
; out(B) = 22 tiles' height if at least a screen's worth of bricks
;   are above the screen, 14 tiles' height otherwise
	ldh a, [stageFallMax]
	sla a
	sla a
	add a, $00
	ld [stageScy], a
	ld b, 14*8
	ldh a, [stageFallMax]
	cp STAGE_ROWS_ONSCREEN+1
	jr c, .ok
	ld b, 22*8
.ok::
	ld a, b
	ld [borderScy], a
	ret

StageFallStep:: ; $0BC7
; send the stage downward one row of bricks
; if a new row of tiles was revealed:
;   out(A) = 1
;   out(BC) = mainStripArray + 3 + STAGE_COLUMNS*2
;   out(DE) = mainStripArray + 3 + STAGE_COLUMNS
;   out(HL) = bottom-left brick of row in (stage)
; otherwise: out(A) = 0
	ldh a, [stageFallMax]
	cp $00
	ret z
	dec a
	ldh [stageFallMax], a
	call PlayMusic.stage_fall
	call SetStageScy
	call CountLostBricks
	ldh a, [stageFallMax]
	cp $00
	ret z
	dec a
	ret z
	ld b, a
	and $01
	ret z
	ld a, b
	ldh [rowToDraw], a
	call DrawStageRow
	ldh a, [rowToDraw]
	add a, STAGE_ROWS_ONSCREEN+2
	ldh [rowToDraw], a
	jp DrawStageRow

CountLostBricks:: ; $0BF2
; treat the breakable bricks just below the screen as destroyed without scoring them
; out(A) = 0
; out(BC) = new bricksLeft
; out(DE) = last non-empty tile regarded, in (stage)
; out(HL) = first tile in the row just below that regarded, in (stage)
	ldh a, [stageFallMax]
	add a, STAGE_ROWS_ONSCREEN
	ld b, a
	ld e, STAGE_COLUMNS
	call MultiplyBxE
	ld hl, stage
	add hl, bc
	ld a, STAGE_COLUMNS
.loop::
	push af
	push hl
	ld a, [hl]
	cp $00
	jr z, .continue
	ld d, h
	ld e, l
	ld bc, hitsLeft - stage
	add hl, bc
	ld a, [hl]
	cp $00
	ld a, $00
	ld [de], a
	jr z, .continue
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
	jr nz, .continue
	ld a, gameMode_NEXT_STAGE
	ldh [gameMode], a
.continue::
	pop hl
	inc hl
	pop af
	dec a
	jr nz, .loop
	ret
