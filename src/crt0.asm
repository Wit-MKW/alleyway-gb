include "common.inc"

SECTION "RST0", ROM0[$0000]
RST0::
; restart as if by turning the console off & on
	jp Entry

SECTION "RST1", ROM0[$0008]
RST1::
; HANG
	rst RST7

SECTION "RST2", ROM0[$0010]
RST2::
; HANG
	rst RST7

SECTION "RST3", ROM0[$0018]
RST3::
; HANG
	rst RST7

SECTION "RST4", ROM0[$0020]
RST4::
; HANG
	rst RST7

SECTION "RST5", ROM0[$0028]
RST5::
; HANG
	rst RST7

SECTION "RST6", ROM0[$0030]
RST6::
; HANG
	rst RST7

SECTION "RST7", ROM0[$0038]
RST7::
; HANG
	rst RST7

SECTION "IntVblank", ROM0[INT_HANDLER_VBLANK]
IntVblank::
	jp _IntVblank

SECTION "IntStat", ROM0[INT_HANDLER_STAT]
IntStat::
	jp _IntStat

SECTION "IntTimer", ROM0[INT_HANDLER_TIMER]
IntTimer::
	jp _IntTimer

SECTION "IntSerial", ROM0[INT_HANDLER_SERIAL]
IntSerial::
	jp _IntSerial

SECTION "IntJoypad", ROM0[INT_HANDLER_JOYPAD]
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
	cp SCRN_Y + 1
	jr c, Entry

; turn off LCD
	ld a, LCDCF_OFF|LCDCF_WIN9800|LCDCF_WINOFF|LCDCF_BLK21|LCDCF_BG9800|LCDCF_OBJ8|LCDCF_OBJOFF|LCDCF_BGOFF
	ldh [rLCDC], a

	ld sp, $CFFF
	call SaveIE

; zero-fill VRAM
; BUG: $8000-$80FF (inclusive) is not written to by this routine.
	ld hl, _VRAM+$1FFF
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
; BUG: this routine reaches $A100-$BFFF (inclusive).
	ld hl, _RAM+$1FFF
	ld c, $3F ; FIX: "ld c, $20"
	xor a
	ld b, $00
.wram_clear_loop::
	ld [hl-], a
	dec b
	jr nz, .wram_clear_loop
	dec c
	jr nz, .wram_clear_loop

; zero-fill HRAM
	ld hl, _HRAM+$7E
	ld b, $7F
.hram_clear_loop::
	ld [hl-], a
	dec b
	jr nz, .hram_clear_loop

; zero-fill OAM
; BUG: $FE00 is not written to by this routine.
	ld hl, _OAMRAM+$FF
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
; no buttons yet
	ld a, $FF
	ldh [buttonsDown], a
; set LYC to top of screen (just after vblank)
	ld a, $00
	ldh [rLYC], a
; disable timer
	ld a, TACF_STOP|TACF_4KHZ
	ldh [rTAC], a
	ld a, $00
	ldh [rTMA], a
	ld a, $20
	ldh [unused], a
; disable all interrupts
	xor a
	ldh [rIF], a
; set other variables
	xor a
	ldh [scxTmp], a
	ldh [scyTmp], a
	ldh [gameMode], a ; gameMode_RESET_HISCORE
	ldh [specialStage], a
	ldh [scrollFlag], a
; turn on LCD
	ld a, LCDCF_ON|LCDCF_WIN9800|LCDCF_WINOFF|LCDCF_BLK21|LCDCF_BG9800|LCDCF_OBJ8|LCDCF_OBJON|LCDCF_BGON
	ldh [lcdcTmp], a
	ldh [rLCDC], a
	call RestoreIE
	jp DmgMain
