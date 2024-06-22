include "common.inc"
setcharmap DMG

SECTION FRAGMENT "Main code", ROM0
MultiplyBxE:: ; $0454
; out(BC) = in(B) * in(E)
; out(E) = 0
	push af
	push hl
	ld hl, $0000
	ld c, $00
	srl b
	rr c
	ld a, 8
.loop::
	sla e
	jr nc, .skip_add
	add hl, bc
.skip_add::
	srl b
	rr c
	dec a
	jr nz, .loop
	ld c, l
	ld b, h
	pop hl
	pop af
	ret

AbsAMinusB:: ; $0472
; out(A) = abs(out(B))
; out(B) = in(A) - in(B)
	sub b
	ld b, a
	and $80
	ld a, b
	ret z
	xor $FF
	inc a
	ret

ToDecimalA:: ; $047C
; out(A) = in(A) mod 10
; out(B) = floor(in(A) / 10) mod 10
; out(C) = floor(in(A) / 100)
	ld b, $FF
	ld c, $FF
.loop100::
	inc c
	sub 100
	jr nc, .loop100
	add a, 100
.loop10::
	inc b
	sub 10
	jr nc, .loop10
	add a, 10
	ret

ToDecimalAB:: ; $048F
; out(A) = out(B)
; out(B) = floor(in(AB) / 10) mod 10
; * [decOutput] = in(AB) mod 10
; * [decOutput+1] = out(A)
; * [decOutput+2] = floor(in(AB) / 100) mod 10
; * [decOutput+3] = floor(in(AB) / 1000) mod 10
; * [decOutput+4] = floor(in(AB) / 10000)
	ldh [decOutput+1], a
	ld a, b
	ldh [decOutput], a

	ld b, $FF
.loop10000::
	inc b
	ldh a, [decOutput]
	sub LOW(10000)
	ldh [decOutput], a
	ldh a, [decOutput+1]
	sbc a, HIGH(10000)
	ldh [decOutput+1], a
	jr nc, .loop10000

	ldh a, [decOutput]
	add a, LOW(10000)
	ldh [decOutput], a
	ldh a, [decOutput+1]
	adc a, HIGH(10000)
	ldh [decOutput+1], a
	ld a, b
	ldh [decOutput+4], a

	ld b, $FF
.loop1000::
	inc b
	ldh a, [decOutput]
	sub LOW(1000)
	ldh [decOutput], a
	ldh a, [decOutput+1]
	sbc a, HIGH(1000)
	ldh [decOutput+1], a
	jr nc, .loop1000

	ldh a, [decOutput]
	add a, LOW(1000)
	ldh [decOutput], a
	ldh a, [decOutput+1]
	adc a, HIGH(1000)
	ldh [decOutput+1], a
	ld a, b
	ldh [decOutput+3], a

	ld b, $FF
.loop100::
	inc b
	ldh a, [decOutput]
	sub LOW(100)
	ldh [decOutput], a
	ldh a, [decOutput+1]
	sbc a, HIGH(100)
	ldh [decOutput+1], a
	jr nc, .loop100

	ldh a, [decOutput]
	add a, 100
	ldh [decOutput], a
	ld a, b
	ldh [decOutput+2], a

	ld b, $FF
.loop10::
	inc b
	ldh a, [decOutput]
	sub 10
	ldh [decOutput], a
	jr nc, .loop10

	ldh a, [decOutput]
	add a, 10
	ldh [decOutput], a
	ldh [decOutput], a ; typo?
	ld a, b
	ldh [decOutput+1], a
	ret

RandomNumber:: ; $0505
; out(A) = [random] += (64 + 1)
; BUG: RNG is pathetic, especially since the upper two bits are always ignored.
	ld b, 5
	ldh a, [random]
.loop::
	add a, 13
	dec b
	jr nz, .loop
	ldh [random], a
	ret
