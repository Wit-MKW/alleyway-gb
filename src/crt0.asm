include "common.inc"

SECTION "RST0", ROM0[$0000]
RST0::
	jp Entry

SECTION "RST1", ROM0[$0008]
RST1::
	rst RST7

SECTION "RST2", ROM0[$0010]
RST2::
	rst RST7

SECTION "RST3", ROM0[$0018]
RST3::
	rst RST7

SECTION "RST4", ROM0[$0020]
RST4::
	rst RST7

SECTION "RST5", ROM0[$0028]
RST5::
	rst RST7

SECTION "RST6", ROM0[$0030]
RST6::
	rst RST7

SECTION "RST7", ROM0[$0038]
RST7::
	rst RST7

SECTION "IntVblank", ROM0[$0040]
IntVblank::
	jp _IntVblank

SECTION "IntStat", ROM0[$0048]
IntStat::
	jp _IntStat

SECTION "IntTimer", ROM0[$0050]
IntTimer::
	jp _IntTimer

SECTION "IntSerial", ROM0[$0058]
IntSerial::
	jp _IntSerial

SECTION "IntJoypad", ROM0[$0060]
IntJoypad::
	reti

SECTION FRAGMENT "Main code", ROM0[$0100]
HeaderEntry::
	nop
	jp Entry
HeaderLogo::
	NINTENDO_LOGO
HeaderTitle::
	db "ALLEY WAY", $00, $00
HeaderMenufacturer::
	ds 4, $00
HeaderCGBCompat::
	db CART_COMPATIBLE_DMG
HeaderNewLicensee::
	db $00, $00
HeaderSGBFlag::
	db CART_INDICATOR_GB
HeaderCartType::
	db CART_ROM
HeaderROMSize::
	db CART_ROM_32KB
HeaderRAMSize::
	db CART_SRAM_NONE
HeaderRegionCode::
	db CART_DEST_JAPANESE
HeaderOldLicensee::
	db $01 ; Nintendo
HeaderROMVersion::
	db $00
HeaderChecksum::
	db $5E
HeaderGlobalChecksum::
	be $D19E

setcharmap DMG

Entry:: ; $0150
; wait for vblank
	ldh a, [rLY]
	cp 145
	jr c, Entry

; turn off LCD
	ld a, LCDCF_OFF|LCDCF_WIN9800|LCDCF_WINOFF|LCDCF_BLK21|LCDCF_BG9800|LCDCF_OBJ8|LCDCF_OBJOFF|LCDCF_BGOFF
	ldh [rLCDC], a

	ld sp, $CFFF
	call SaveIE

; zero-fill VRAM
; BUG: $8000-$80FF (inclusive) is not written to by this routine.
	ld hl, $9FFF
	ld c, $1F ; FIX: "ld c, $20"
	xor a
	ld b, $00
.vram_clear_loop::
	ld [hl-], a
	dec b
	jr nz, .vram_clear_loop
	dec c
	jr nz, .vram_clear_loop

; zero-fill WRAM
; BUG: $C000-$C0FF (inclusive) is not written to by this routine.
	ld hl, $DFFF
	ld c, $3F ; FIX: "ld c, $40"
	xor a
	ld b, $00
.wram_clear_loop::
	ld [hl-], a
	dec b
	jr nz, .wram_clear_loop
	dec c
	jr nz, .wram_clear_loop

; zero-fill HRAM
	ld hl, $FFFE
	ld b, $7F
.hram_clear_loop::
	ld [hl-], a
	dec b
	jr nz, .hram_clear_loop

; zero-fill OAM
; BUG: $FE00 is not written to by this routine.
	ld hl, $FEFF
	ld b, $FF ; FIX: "ld b, $00"
.oam_clear_loop::
	ld [hl-], a
	dec b
	jr nz, .oam_clear_loop

; prepare VRAM
	call PrepareTileSet
	call FillNameTable0
	call FillNameTable1

; copy DoOamDma to HRAM to be called during _IntVblank
	ld c, LOW(_DoOamDma)
	ld b, DoOamDma.end - DoOamDma
	ld hl, DoOamDma
.hram_setup_loop::
	ld a, [hl+]
	ldh [c], a
	inc c
	dec b
	jr nz, .hram_setup_loop

; enable vblank interrupt
	ld a, IEF_VBLANK
	ldh [rIF], a
	ldh [ieBackup], a
; enable LYC interrupt (once STAT interrupt is enabled)
	ld a, STATF_LYC|STATF_HBL
	ldh [rSTAT], a
; reset scroll position
	xor a
	ldh [rSCY], a
	ldh [rSCX], a
; turn off LCD
	ld a, LCDCF_OFF|LCDCF_WIN9800|LCDCF_WINOFF|LCDCF_BLK21|LCDCF_BG9800|LCDCF_OBJ8|LCDCF_OBJOFF|LCDCF_BGOFF
	ldh [rLCDC], a
; set palettes so intensity matches palette index
	ld a, %11100100
	ldh [rBGP], a
	ldh [rOBP0], a
	ldh [rOBP1], a
; acknowledge buttons held on frame 0
	ld a, $FF
	ldh [buttonsDown], a
; set LYC to top of screen (just after vblank)
	ld a, $00
	ldh [rLYC], a
; stop timer, set to 4 kHz
	ld a, TACF_STOP|TACF_4KHZ
	ldh [rTAC], a
; timer interrupt every 256 ticks
	ld a, $00
	ldh [rTMA], a
	ld a, $20
	ldh [unused], a
; disable all interrupts
	xor a
	ldh [rIF], a
	xor a
	ldh [scxTmp], a
	ldh [scyTmp], a
	ldh [gameMode], a
	ldh [specialStage], a
	ldh [scrollFlag], a
; turn on LCD
	ld a, LCDCF_ON|LCDCF_WIN9800|LCDCF_WINOFF|LCDCF_BLK21|LCDCF_BG9800|LCDCF_OBJ8|LCDCF_OBJON|LCDCF_BGON
	ldh [lcdcTmp], a
	ldh [rLCDC], a
	call RestoreIE
	jp DmgMain
