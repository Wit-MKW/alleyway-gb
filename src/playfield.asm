include "common.inc"
setcharmap DMG

SECTION FRAGMENT "Main code", ROM0
SetupStage:: ; $092A
	ld b, a
	ld e, $03
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
	ld c, $0E
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
	ld e, $06
	call MultiplyBxE
	ld hl, BrickTypes
	add hl, bc
	ld b, $00
	ld c, $03
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
	sub 20
	jr nc, .stage_fall
	xor a
.stage_fall::
	ldh [stageFallMax], a
	ret

ClearStage:: ; $0983
	ld hl, stage
	ld de, hitsLeft
	ld bc, $0348
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
	ldh a, [stageHeight]
	dec a
	dec a
	ldh [rowToDraw], a
	ld a, 10
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
	ld a, $3A
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
	ld hl, stage
	ld de, $0000
	ld bc, $0348
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
	call WaitToDraw
	ldh a, [rowToDraw]
	srl a
	ld b, a
	ld e, $20
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
	ld e, $1C
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
	ld b, $00
	ld c, $0E
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
	ld e, $06
	call MultiplyBxE
	ld hl, BrickTypes
	add hl, bc
	pop af
	ld b, $00
	ld c, a
	add hl, bc
	ld a, [hl]
	ldh [tileToDraw], a
.nothing::
	ldh a, [vramOffset]
	ld b, a
	ldh a, [vramOffset+1]
	ld c, a
	ld hl, $9821
	add hl, bc
	ld b, h
	ld c, l
	push bc
	ld b, $00
	ld c, $0E
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
	call WaitToDraw
	ldh a, [rowToDraw]
	srl a
	ld b, a
	ld e, $20
	call MultiplyBxE
	ld hl, $9821
	add hl, bc
	ld b, h
	ld c, l
	ld hl, mainStripArray
	ld a, b
	ld [hl+], a
	ld a, c
	ld [hl+], a
	ld a, $1C
	ld [hl], a
	ldh a, [rowToDraw]
	srl a
	ld b, a
	ld e, $1C
	call MultiplyBxE
	ld hl, stage
	add hl, bc
	ld de, mainStripArray + $03
	ld a, $0E
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
	ld c, $0E
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
	ld e, $06
	call MultiplyBxE
	ld hl, BrickTypes
	add hl, bc
	pop af
	ld b, $00
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
	ld hl, 14
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
	cp $14
	jr c, .loop
	ret

IncMod112:: ; $0B53
; increment [hl], wrapping from 111+ to 0
; clobbers A
	ld a, [hl]
	inc a
	cp $70
	jr c, .skip_zero
	ld a, $00
.skip_zero::
	ld [hl], a
	ret

DecMod112:: ; $0B5D
; decrement [hl], wrapping from 0 to 111
; clobbers A
	ld a, [hl]
	dec a
	cp $FF
	jr nz, .skip_6f
	ld a, $6F
.skip_6f::
	ld [hl], a
	ret

IntStat_main:: ; $0B67
	ldh a, [stageRowDrawing]
	ld c, a
	inc a
; off-by-one error: row 20 is scrolled using row 0's counter.
; fortunately, there's never anything on row 20 (hence why the devs tried to skip it).
	cp 21
	jr nc, .twenty_one
	ldh [stageRowDrawing], a
	sla a
	sla a
	ld b, $07
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
.twenty_one::
	xor a
	ldh [stageRowDrawing], a
	ld b, $07
	add a, b
	ldh [rLYC], a
	ld a, [borderScy]
	ldh [rSCY], a
	xor a
	ldh [rSCX], a
	ret

Func0B9D:: ; $0B9D
	ld a, $00
	ldh [scxTmp], a
	ld hl, scrollOffsets
	ld b, $14
.loop::
	ld [hl+], a
	dec b
	jr nz, .loop
	xor a
	ldh [scyTmp], a
	; fallthrough

Func0BAD:: ; $0BAD
	ldh a, [stageFallMax]
	sla a
	sla a
	add a, $00
	ld [stageScy], a
	ld b, 112
	ldh a, [stageFallMax]
	cp 21
	jr c, .skip
	ld b, 176
.skip::
	ld a, b
	ld [borderScy], a
	ret

Func0BC7:: ; $0BC7
	ldh a, [stageFallMax]
	cp $00
	ret z
	dec a
	ldh [stageFallMax], a
	call PlayMusic.eleven
	call Func0BAD
	call Func0BF2
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
	add a, $16
	ldh [rowToDraw], a
	jp DrawStageRow

Func0BF2:: ; $0BF2
	ldh a, [stageFallMax]
	add a, $14
	ld b, a
	ld e, $0E
	call MultiplyBxE
	ld hl, stage
	add hl, bc
	ld a, $0E
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
	ld a, $08
	ldh [gameMode], a
.continue::
	pop hl
	inc hl
	pop af
	dec a
	jr nz, .loop
	ret
