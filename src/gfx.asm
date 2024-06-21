include "common.inc"
setcharmap DMG

SECTION FRAGMENT "Main code", ROM0
DrawMainStripArray:: ; $02A1
; draw the strip array at mainStripArray if needed
; out(A) = 0
; out(B) = 0
; may clobber DE and HL
	ldh a, [drawNeeded]
	cp $00
	jr z, .end
	ld de, mainStripArray
	call DrawStripArray.start
	xor a
	ld [mainStripUnused], a
	ld [mainStripArray], a
	ldh [drawNeeded], a
.end::
	ret

DrawStripArray:: ; $02B7
; see .start for function description
	inc de
	ld h, a
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	inc de
	call DrawStrip
.start:: ; $02C1
; draw the strip array at in(DE)
; out(A) = 0
; out(B) = 0
; out(DE) = (end of strip array)
; clobbers HL
; * strip array format:
; * - 2 bytes: big-endian output address
; * - 1 byte: size specification
; *   - bit 7: set for column, clear for row
; *   - bit 6: set to fill with single tile, clear to copy unique tiles
; *   - bit 5-0: number of tiles
; * - (*) bytes: tile-data
; * repeat until high (first) byte of address is zero
	ld a, [de]
	cp $00
	jr nz, DrawStripArray
	ret

DrawStrip:: ; $02C7
; draw the strip tile-data at in(DE) with size specified by in(A) to in(HL)
; out(B) = 0
; out(DE) = (end of tile-data)
; out(HL) = (end of output)
; clobbers A
; * see DrawStripArray.start for size specification
	push af
	and $3F
	ld b, a
	pop af
	rlca
	rlca
	and $03
	jr z, .copy_row
	dec a
	jr z, .fill_row
	dec a
	jr z, .copy_col
	jr .fill_col
.copy_row::
	ld a, [de]
	ld [hl+], a
	inc de
	dec b
	jr nz, .copy_row
	ret
.fill_row::
	ld a, [de]
	inc de
.loop::
	ld [hl+], a
	dec b
	jr nz, .loop
	ret
.copy_col::
	ld a, [de]
	ld [hl], a
	inc de
	ld a, b
	ld bc, SCRN_VX_B
	add hl, bc
	ld b, a
	dec b
	jr nz, .copy_col
	ret
.fill_col::
	ld a, [de]
	ld [hl], a
	ld a, b
	ld bc, SCRN_VX_B
	add hl, bc
	ld b, a
	dec b
	jr nz, .fill_col
	inc de
	ret

DrawGfxArray:: ; $0302
; draw the gfx array at an immediate address after the call
; out(HL) = (end of gfx array)
; clobbers DE
; * gfx array format:
; * - 2 bytes: big-endian output address
; * - 1 byte: width specification
; *   - bit 7: set to copy unique tiles, clear to fill with single tile
; *   - bit 4-0: width in tiles
; * - 1 byte: height in tiles
; * - (*) bytes: tile-data
; * repeat until high (first) byte of address is $FF
	pop de
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
	push de
	push af
	push bc
.loop::
	ld a, [hl+]
	cp $FF
	jr z, .end
	ld d, a
	ld a, [hl+]
	ld e, a
	push de
	ld a, [hl+]
	push af
	and $1F
	ld c, a
	ld a, [hl+]
	ldh [gfxArrayWidth], a
	pop af
	and $80
	jr z, .fill
.copy::
	ldh a, [gfxArrayWidth]
	ld b, a
.copy_loop::
	ld a, [hl+]
	ld [de], a
	inc de
	dec b
	jr nz, .copy_loop
	pop de
	push hl
	ld hl, SCRN_VX_B
	add hl, de
	push hl
	pop de
	pop hl
	push de
	dec c
	jr nz, .copy
	pop de
	jr .loop
.fill::
	ldh a, [gfxArrayWidth]
	ld b, a
.fill_loop::
	ld a, [hl]
	ld [de], a
	inc de
	dec b
	jr nz, .fill_loop
	pop de
	push hl
	ld hl, SCRN_VX_B
	add hl, de
	push hl
	pop de
	pop hl
	push de
	dec c
	jr nz, .fill
	pop de
	inc hl
	jr .loop
.end::
	pop bc
	pop af
	ret

FillNameTable0:: ; $0358
; fill first nametable with " "
; out(A) = 0
; out(BC) = 0
; out(HL) = _SCRN0 + SCRN_VX_B*SCRN_VY_B
	ld hl, _SCRN0
	jr FillNameTable1.start

FillNameTable1:: ; $035D
; fill second nametable with " "
; out(A) = 0
; out(BC) = 0
; out(HL) = _SCRN1 + SCRN_VX_B*SCRN_VY_B
	ld hl, _SCRN1
.start::
	ld bc, SCRN_VX_B * SCRN_VY_B
.loop::
	ld a, " "
	ld [hl+], a
	dec bc
	ld a, b
	or c
	jr nz, .loop
	ret

ClearOAM:: ; $036C
; fill the OAM buffer with zero-bytes, hiding all objects
; out(A) = 0
; out(B) = 0
; out(HL) = oamBuf+$A0
	ld b, $A0
	ld a, $00
	ld hl, oamBuf
.loop::
	ld [hl+], a
	dec b
	jr nz, .loop
	ret

ClearLastSixObjs:: ; $0378
; fill the last six objects in the OAM buffer with zero-bytes, hiding them
; out(A) = 0
; out(B) = 0
; out(HL) = oamBuf+$A0
	ld b, $18
	ld a, $00
	ld hl, oamBuf + 34*sizeof_OAM_ATTRS
	jr ClearOAM.loop

PrepareTileSet:: ; $0381
; copy tile data to VRAM
; out(A) = 0
; out(BC) = 0
; out(DE) = _VRAM+$800
; out(HL) = tiles0_2bpp+$800
	ld hl, tiles2_2bpp
	ld de, _VRAM+$1000
	ld bc, $0800
.loop1::
	ld a, [hl+]
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, .loop1

	ld hl, tiles1_2bpp
	ld de, _VRAM+$0800
	ld bc, $0800
.loop2::
	ld a, [hl+]
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, .loop2

	ld hl, tiles0_2bpp
	ld de, _VRAM
	ld bc, $0800
.loop3::
	ld a, [hl+]
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, .loop3
	ret

DoOamDma:: ; $03B5
LOAD "DoOamDma", HRAM
_DoOamDma:: ; $FF80
; start OAM DMA from oamBuf and wait until it completes
; out(A) = 0
; * this cannot be run from ROM; it is copied to HRAM as the game starts
	di
	ld a, HIGH(oamBuf)
	ldh [rDMA], a
	ld a, $28
.stall
	dec a
	jr nz, .stall
	ei
	ret
ENDL
.end:: ; $03C1
