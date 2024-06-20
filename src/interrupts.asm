include "common.inc"
setcharmap DMG

SECTION FRAGMENT "Main code", ROM0
DisableVblank:: ; $0446
; disable vblank interrupt
; out(A) = [rIE] &= ~IEF_VBLANK
	ldh a, [rIE]
	and ~IEF_VBLANK
.store::
	ldh [rIE], a
	ret

EnableVblank:: ; $044D
; enable vblank interrupt
; out(A) = [rIE] |= IEF_VBLANK
	ldh a, [rIE]
	or IEF_VBLANK
	jr DisableVblank.store

_IntTimer:: ; $0453
	reti
