include "common.inc"
setcharmap DMG

SECTION FRAGMENT "Main code", ROM0
_IntVblank:: ; $01EF
	push af
	push bc
	push de
	push hl
	call GetInput
	ld a, $02
	ldh [paddleCounter], a
; get paddle angle
	ld a, SCF_START|SCF_SOURCE
	ldh [rSC], a
; OAM DMA
	call _DoOamDma
	call DrawMainStripArray
; reconfigure LCD
	ldh a, [lcdcTmp]
	ldh [rLCDC], a
	ldh a, [scxTmp]
	ldh [rSCX], a
	ldh a, [scyTmp]
	ldh [rSCY], a
	call UpdateAudio
	ldh a, [frameCount]
	inc a
	ldh [frameCount], a
	ld a, $01
	ldh [vblankTrigger], a
	pop hl
	pop de
	pop bc
	pop af
	reti

WaitVblank:: ; $0221
; wait for a single vblank interrupt to complete
; out(A) = 1
	ld a, $00
	ldh [vblankTrigger], a
.loop::
	halt
	ldh a, [vblankTrigger]
	cp $00
	jr z, .loop
.end::
	ret

RestoreIE:: ; $022D
; copy [ieBackup] to [rIE]
; out(A) = [ieBackup]
	ldh a, [ieBackup]
	ldh [rIE], a
	ei
	ret

SaveIE:: ; $0233
; copy [rIE] to [ieBackup] and disable interrupts
; out(A) = 0
	ldh a, [rIE]
	ldh [ieBackup], a
	ld a, $00
	ldh [rIE], a
	di
	ret

WaitToDraw:: ; $023D
; wait until vblank iff drawing is needed
; out(A) = [drawNeeded] ? 1 : 0
	ldh a, [drawNeeded]
	cp $00
	ret z
	jr WaitVblank

TurnOnLCD:: ; $0244
; turn on LCD
; out(A) = [lcdcTmp] |= LCDCF_ON
	ldh a, [lcdcTmp]
	and ~LCDCF_ON ; ???
	or LCDCF_ON
	ldh [lcdcTmp], a
	ldh [rLCDC], a
	ret

TurnOffLCD:: ; $024F
; set LCD to turn off, then wait until it does
; out(A) = 0
	ldh a, [lcdcTmp]
	and ~LCDCF_ON
	ldh [lcdcTmp], a
; can't turn off LCD outside vblank
	jr WaitVblank

DelayFrames:: ; $0257
; delay for in(A) number of frames
; out(A) = 0
	push af
	call WaitVblank
	pop af
	dec a
	jr nz, DelayFrames
	ret

_IntStat:: ; $0260
	push af
	push bc
	push de
	push hl
	call IntStat_main
	ldh a, [rIF]
	and ~IEF_STAT
	ldh [rIF], a
	pop hl
	pop de
	pop bc
	pop af
	reti
