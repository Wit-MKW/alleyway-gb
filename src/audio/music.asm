include "common.inc"
setcharmap DMG

macro fq
	if _NARG == 0
		db
	else
		rept _NARG
			db (\1) | AUDHIGH_RESTART|AUDHIGH_LENGTH_OFF
			shift
		endr
	endc
endm

def NOTE_16TH equ 0
def NOTE_8TH equ 1
def NOTE_4TH equ 2
def NOTE_HALF equ 3
def NOTE_WHOLE equ 4
def WITH_DOT equs "+ 4"

; there are no triplets at 75 BPM.
def NOTE_8TH_TRIPLET2 equ 8
def NOTE_8TH_TRIPLET1 equ 9

; at 113 BPM, this is a sixteenth-note triplet.
; at 90 and 150 BPM, this is a 90-BPM quarter-note triplet.
def NOTE_OTHER_TRIPLET2 equ 10
def NOTE_OTHER_TRIPLET1 equ 11

; BPM typically means quarter-notes per minute, but here i'm using half-notes
; per minute, because what kind of tempo is 300 BPM?
def TEMPO_113BPM equs "+ $80" ; actually 112.5 BPM.
def TEMPO_90BPM equs "+ $8C"
def TEMPO_150BPM equs "+ $98"
def TEMPO_75BPM equs "+ $A4"

def NOTE_C equs "-22 + 12 *"
def NOTE_D equs "-20 + 12 *"
def NOTE_E equs "-18 + 12 *"
def NOTE_F equs "-17 + 12 *"
def NOTE_G equs "-15 + 12 *"
def NOTE_A equs "-13 + 12 *"
def NOTE_B equs "-11 + 12 *"

def FLAT equs "- 1"
def SHARP equs "+ 1"

def REST equ $01
def MUSIC_NEXT equ $7F

SECTION FRAGMENT "Audio", ROM0
UpdateAud23:: ; $70AE
	ld a, [audioStarting23]
	cp $01
	jp z, .one
	cp $02
	jp z, .two
	cp $03
	jp z, .three
	cp $04
	jp z, .four
	cp $05
	jp z, .five
	cp $06
	jp z, .six
	cp $07
	jp z, .seven
	cp $08
	jp z, .eight
	cp $09
	jp z, .nine
	cp $0A
	jp z, .ten
	cp $0B
	jp z, .eleven
	cp $0C
	jp z, .twelve
	ld a, [audioNext23]
	cp $00
	jp nz, ReadNotes23
	ld a, [audioNext3]
	cp $00
	jp nz, ReadNotes23.note_not_finished2
	ret
.one::
	ld a, $01
	ld [audioNext23], a
	ld [audioNext3], a
	ld [audioCounter2], a
	ld [audioCounter3], a
	ld [audioUnused5], a
	ld [audio2StereoFlag], a
	ld [audio2StereoUnused], a
	ld [audio2StereoTerm], a
	ld a, 96
	ld [audio2StereoCounter], a
	ld [audio2StereoModulo], a
	ld hl, Aud2_01
	ld a, h
	ld [audioPointer2], a
	ld a, l
	ld [audioPointer2+1], a
	ld hl, Aud3_01
	ld a, h
	ld [audioPointer3], a
	ld a, l
	ld [audioPointer3+1], a
	call ReadNotes23
	ret
.two::
	ld a, AUDTERM_4_LEFT|AUDTERM_3_LEFT|AUDTERM_2_LEFT|AUDTERM_1_LEFT|AUDTERM_4_RIGHT|AUDTERM_3_RIGHT|AUDTERM_2_RIGHT|AUDTERM_1_RIGHT
	ldh [rAUDTERM], a
	xor a
	ld [audio2StereoFlag], a
	ld a, $02
	ld [audioNext23], a
	ld [audioNext3], a
	ld a, $01
	ld [audioCounter2], a
	ld [audioCounter3], a
	ld [audioUnused5], a
	ld hl, Aud2_02
	ld a, h
	ld [audioPointer2], a
	ld a, l
	ld [audioPointer2+1], a
	ld hl, Aud3_02
	ld a, h
	ld [audioPointer3], a
	ld a, l
	ld [audioPointer3+1], a
	call ReadNotes23
	ret
.three::
	ld a, $03
	ld [audioNext23], a
	ld [audioNext3], a
	ld a, $01
	ld [audioCounter2], a
	ld [audioCounter3], a
	ld [audioUnused5], a
	ld [audio2StereoFlag], a
	ld [audio2StereoUnused], a
	ld [audio2StereoTerm], a
	ld a, 96
	ld [audio2StereoCounter], a
	ld [audio2StereoModulo], a
	ld hl, Aud2_03
	ld a, h
	ld [audioPointer2], a
	ld a, l
	ld [audioPointer2+1], a
	ld hl, Aud3_03
	ld a, h
	ld [audioPointer3], a
	ld a, l
	ld [audioPointer3+1], a
	call ReadNotes23
	ret
.four::
	xor a
	ld [audio2StereoFlag], a
	ld a, $04
	ld [audioNext23], a
	ld [audioNext3], a
	ld a, $01
	ld [audioCounter2], a
	ld [audioCounter3], a
	ld [audioUnused5], a
	ld hl, Aud2_04
	ld a, h
	ld [audioPointer2], a
	ld a, l
	ld [audioPointer2+1], a
	ld hl, Aud3_04
	ld a, h
	ld [audioPointer3], a
	ld a, l
	ld [audioPointer3+1], a
	call ReadNotes23
	ret
.five::
	ld a, AUDTERM_4_LEFT|AUDTERM_3_LEFT|AUDTERM_2_LEFT|AUDTERM_1_LEFT|AUDTERM_4_RIGHT|AUDTERM_3_RIGHT|AUDTERM_2_RIGHT|AUDTERM_1_RIGHT
	ldh [rAUDTERM], a
	xor a
	ld [audio2StereoFlag], a
	ld a, $05
	ld [audioNext23], a
	ld [audioNext3], a
	ld a, $01
	ld [audioCounter2], a
	ld [audioCounter3], a
	ld [audioUnused5], a
	ld hl, Aud2_05
	ld a, h
	ld [audioPointer2], a
	ld a, l
	ld [audioPointer2+1], a
	ld hl, Aud3_05
	ld a, h
	ld [audioPointer3], a
	ld a, l
	ld [audioPointer3+1], a
	call ReadNotes23
	ret
.six::
	ld a, $06
	ld [audioNext23], a
	ld [audioNext3], a
	ld a, $01
	ld [audioCounter2], a
	ld [audioCounter3], a
	ld [audioUnused5], a
	ld [audio2StereoFlag], a
	ld [audio2StereoUnused], a
	ld [audio2StereoTerm], a
	ld a, 40
	ld [audio2StereoCounter], a
	ld [audio2StereoModulo], a
	ld hl, Aud2_06
	ld a, h
	ld [audioPointer2], a
	ld a, l
	ld [audioPointer2+1], a
	ld hl, Aud3_06
	ld a, h
	ld [audioPointer3], a
	ld a, l
	ld [audioPointer3+1], a
	call ReadNotes23
	ret
.seven::
	ld a, $07
	ld [audioNext23], a
	ld [audioNext3], a
	ld a, $01
	ld [audioCounter2], a
	ld [audioCounter3], a
	ld [audioUnused5], a
	ld [audio2StereoFlag], a
	ld [audio2StereoUnused], a
	ld [audio2StereoTerm], a
	ld a, 32
	ld [audio2StereoCounter], a
	ld [audio2StereoModulo], a
	ld hl, Aud2_07
	ld a, h
	ld [audioPointer2], a
	ld a, l
	ld [audioPointer2+1], a
	ld hl, Aud3_07
	ld a, h
	ld [audioPointer3], a
	ld a, l
	ld [audioPointer3+1], a
	call ReadNotes23
	ret
.eight::
	xor a
	ld [audio2StereoFlag], a
	ld a, $06
	ld [audioNext23], a
	ld [audioNext3], a
	ld a, $01
	ld [audioCounter2], a
	ld [audioCounter3], a
	ld [audioUnused5], a
	ld hl, Aud2_08
	ld a, h
	ld [audioPointer2], a
	ld a, l
	ld [audioPointer2+1], a
	ld hl, Aud3_08
	ld a, h
	ld [audioPointer3], a
	ld a, l
	ld [audioPointer3+1], a
	call ReadNotes23
	ret
.nine::
	xor a
	ld [audio2StereoFlag], a
	ld a, AUDTERM_4_LEFT|AUDTERM_3_LEFT|AUDTERM_2_LEFT|AUDTERM_1_LEFT|AUDTERM_4_RIGHT|AUDTERM_3_RIGHT|AUDTERM_2_RIGHT|AUDTERM_1_RIGHT
	ldh [rAUDTERM], a
	ld a, $06
	ld [audioNext23], a
	ld [audioNext3], a
	ld a, $01
	ld [audioCounter2], a
	ld [audioCounter3], a
	ld [audioUnused5], a
	ld hl, Aud2_09
	ld a, h
	ld [audioPointer2], a
	ld a, l
	ld [audioPointer2+1], a
	ld hl, Aud3_09
	ld a, h
	ld [audioPointer3], a
	ld a, l
	ld [audioPointer3+1], a
	call ReadNotes23
	ret
.ten::
	xor a
	ld [audio2StereoFlag], a
	ld a, AUDTERM_4_LEFT|AUDTERM_3_LEFT|AUDTERM_2_LEFT|AUDTERM_1_LEFT|AUDTERM_4_RIGHT|AUDTERM_3_RIGHT|AUDTERM_2_RIGHT|AUDTERM_1_RIGHT
	ldh [rAUDTERM], a
	ld a, $06
	ld [audioNext23], a
	ld [audioNext3], a
	ld a, $01
	ld [audioCounter2], a
	ld [audioCounter3], a
	ld [audioUnused5], a
	ld hl, Aud2_10
	ld a, h
	ld [audioPointer2], a
	ld a, l
	ld [audioPointer2+1], a
	ld hl, Aud3_10
	ld a, h
	ld [audioPointer3], a
	ld a, l
	ld [audioPointer3+1], a
	call ReadNotes23
	ret
.eleven::
	xor a
	ld [audio2StereoFlag], a
	ld a, $06
	ld [audioNext23], a
	ld [audioNext3], a
	ld a, $01
	ld [audioCounter2], a
	ld [audioCounter3], a
	ld [audioUnused5], a
	ld hl, Aud2_11
	ld a, h
	ld [audioPointer2], a
	ld a, l
	ld [audioPointer2+1], a
	ld hl, Aud3_11
	ld a, h
	ld [audioPointer3], a
	ld a, l
	ld [audioPointer3+1], a
	call ReadNotes23
	ret
.twelve::
	xor a
	ld [audio2StereoFlag], a
	ld a, $06
	ld [audioNext23], a
	ld [audioNext3], a
	ld a, $01
	ld [audioCounter2], a
	ld [audioCounter3], a
	ld [audioUnused5], a
	ld hl, Aud2_12
	ld a, h
	ld [audioPointer2], a
	ld a, l
	ld [audioPointer2+1], a
	ld hl, Aud3_12
	ld a, h
	ld [audioPointer3], a
	ld a, l
	ld [audioPointer3+1], a
	call ReadNotes23
	ret

ReadNotes23:: ; $738C
	ld a, [audioCounter2]
	dec a
	ld [audioCounter2], a
	cp $00
	jp nz, .note_not_finished2
	ld a, [audioPointer2]
	ld h, a
	ld a, [audioPointer2+1]
	ld l, a
.next_byte2::
	ld a, [hl+]
	bit 7, a
	jp nz, SetNoteLength2
	cp $00
	jp z, StopAud1
	cp $7F
	jp z, AudioNext
	cp $01
	jp nz, .play_note2
	call RestAud2
	jr .rest2
.play_note2::
	ld [audioNote2], a
	ld a, 63|AUDLEN_DUTY_50
	ldh [rAUD2LEN], a
	ld a, $F2|AUDENV_DOWN
	ldh [rAUD2ENV], a
	ld a, [audioNote2]
	push hl
	ld hl, FreqLow
	ld d, $00
	ld e, a
	add hl, de
	ld a, [hl]
	ldh [rAUD2LOW], a
	ld hl, FreqHigh
	add hl, de
	ld a, [hl]
	ldh [rAUD2HIGH], a
	pop hl
.rest2::
	xor a
	ld a, h
	ld [audioPointer2], a
	ld a, l
	ld [audioPointer2+1], a
	ld a, [audioCounter2]
	and a
	jr nz, .note_not_finished2
	ld a, [audioModulo2]
	ld [audioCounter2], a
.note_not_finished2::
	ld a, [audioCounter3]
	dec a
	ld [audioCounter3], a
	cp $00
	jp nz, .note_not_finished3
	ld a, [audioPointer3]
	ld h, a
	ld a, [audioPointer3+1]
	ld l, a
.next_byte3::
	ld a, [hl+]
	bit 7, a
	jp nz, SetNoteLength3
	cp $00
	jp z, StopAud3
	cp $7F
	jp z, AudioNext
	cp $01
	jp nz, .play_note3
	call RestAud3
	jr .rest3
.play_note3::
	ld [audioNote3], a
	push hl
	ld a, AUD3ENA_OFF
	ldh [rAUD3ENA], a
	ld a, AUD3ENA_ON
	ldh [rAUD3ENA], a
	ld a, 63|AUDLEN_DUTY_75
	ldh [rAUD3LEN], a
	call LoadWaveRam
	ld a, AUD3LEVEL_100
	ldh [rAUD3LEVEL], a
	ld a, [audioNote3]
	ld hl, FreqLow
	ld d, $00
	ld e, a
	add hl, de
	ld a, [hl]
	ldh [rAUD3LOW], a
	ld hl, FreqHigh
	add hl, de
	ld a, [hl]
	ldh [rAUD3HIGH], a
	pop hl
.rest3::
	ld a, h
	ld [audioPointer3], a
	ld a, l
	ld [audioPointer3+1], a
	ld a, [audioCounter3]
	and a
	jr nz, .note_not_finished3
	ld a, [audioModulo3]
	ld [audioCounter3], a
.note_not_finished3::
	ret

LoadWaveRam:: ; $745F
	ld hl, WaveRam
	ld c, LOW(_AUD3WAVERAM)
.loop::
	ld a, [hl+]
	ld [c], a
	inc c
	ld a, [audioWaveRamCounter]
	inc a
	ld [audioWaveRamCounter], a
	cp $10
	jp nz, .loop
	xor a
	ld [audioWaveRamCounter], a
	ret

SetNoteLength2:: ; $7478
	push hl
	and $7F
	ld hl, NoteLengths
	ld d, $00
	ld e, a
	add hl, de
	ld a, [hl]
	ld [audioCounter2], a
	ld [audioModulo2], a
	pop hl
	jp ReadNotes23.next_byte2

SetNoteLength3:: ; $748D
	push hl
	and $7F
	ld hl, NoteLengths
	ld d, $00
	ld e, a
	add hl, de
	ld a, [hl]
	ld [audioCounter3], a
	ld [audioModulo3], a
	pop hl
	jp ReadNotes23.next_byte3

AudioNext:: ; $74A2
	ld a, [audioNext23]
	ld [audioStarting23], a
	jp UpdateAud23

UpdateAudTerm2:: ; $74AB
	ld a, [audio2StereoFlag]
	cp $01
	jp nz, .mono
	ld a, [audio2StereoTerm]
	cp $01
	jp nz, .right
	ld a, [audio2StereoCounter]
	dec a
	ld [audio2StereoCounter], a
	cp $00
	jp z, .left_counterup
	ld a, AUDTERM_3_LEFT|AUDTERM_2_LEFT|AUDTERM_1_LEFT|AUDTERM_3_RIGHT|AUDTERM_1_RIGHT
	ldh [rAUDTERM], a
	ret
.left_counterup::
	xor a
	ld [audio2StereoTerm], a
	ld a, [audio2StereoModulo]
	ld [audio2StereoCounter], a
	ret
.right::
	ld a, [audio2StereoCounter]
	dec a
	ld [audio2StereoCounter], a
	cp $00
	jp z, .right_counterup
	ld a, AUDTERM_3_LEFT|AUDTERM_1_LEFT|AUDTERM_3_RIGHT|AUDTERM_2_RIGHT|AUDTERM_1_RIGHT
	ldh [rAUDTERM], a
	ret
.right_counterup::
	ld a, $01
	ld [audio2StereoTerm], a
	ld a, [audio2StereoModulo]
	ld [audio2StereoCounter], a
	ret
.mono::
	xor a
	ld [audio2StereoFlag], a
	ret

StopAud1:: ; $74F9
	xor a
	ld [audioNext23], a
	ld [audio2StereoFlag], a
	ldh [rAUD1ENV], a
	ret

StopAud3:: ; $7503
	xor a
	ld [audioNext3], a
	ld [audio2StereoFlag], a
	ldh [rAUD3LEVEL], a
	ret

_StopAudio:: ; $750D
	xor a
	ld [audioUnused], a
	ld [audioNext23], a
	ld [audioNext3], a
	ldh [rAUD1ENV], a
	ldh [rAUD2ENV], a
	ldh [rAUD3LEVEL], a
	ret

RestAud2:: ; $751E
	xor a
	ldh [rAUD2ENV], a
	ret

RestAud3:: ; $7522
	xor a
	ldh [rAUD3ENA], a
	ret

SetAudioUnused4:: ; $7526
	ld a, $01
	ld [audioUnused4], a
	ret

_ClearAudioUnused4:: ; $752C
	xor a
	ld [audioUnused4], a
	ret

;     +----+----+----+----+----+----+----+----+----+----+----+----+
;     |    | C# |    | D# |    |    | F# |    | G# |    | A# |    |
;     |    | Db |    | Eb |    |    | Gb |    | Ab |    | Bb |    |
;     |    +--+-+    +-+--+    |    +--+-+    +-+--+    +-+--+    |
;     |       |        |       |       |        |         |       |
;     |  C2   |   D2   |   E2  |  F2   |   G2   |    A2   |   B2  |
;     +-------+--------+-------+-------+--------+---------+-------+
FreqHigh:: ; $7531
	db AUDHIGH_LENGTH_OFF, AUDHIGH_RESTART|AUDHIGH_LENGTH_ON
	fq $00, $00, $01, $01, $01, $02, $02, $02, $03, $03, $03, $03 ; 2
	fq $04, $04, $04, $04, $04, $05, $05, $05, $05, $05, $05, $05 ; 3
	fq $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06 ; 4
	fq $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07 ; 5
	fq $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07 ; 6
	fq $07, $07, $07, $07, $07                                    ; 7
FreqLow:: ; $7574
	db $00, $00
	db $2C, $9D, $07, $6B, $C9, $23, $77, $C7, $12, $58, $9B, $DA ; 2
	db $16, $4F, $83, $B5, $E5, $11, $3B, $63, $88, $AC, $CE, $ED ; 3
	db $0B, $27, $42, $5B, $72, $89, $9E, $B2, $C4, $D6, $E7, $F7 ; 4
	db $06, $14, $21, $2D, $39, $44, $4F, $59, $62, $6B, $73, $7B ; 5
	db $83, $8A, $90, $97, $9D, $A2, $A7, $AC, $B1, $B6, $BA, $BE ; 6
	db $C1, $C5, $C8, $CB, $CE                                    ; 7

NoteLengths:: ; $75B7
; 112.5 BPM
	db 4,  8, 16, 32, 64
	db    12, 24, 48
	db 5,  6, 11, 10
; 90 BPM
	db 5, 10, 20, 40, 80
	db    15, 30, 60
	db 7,  6,  2,  1
; 150 BPM
	db 3,  6, 12, 24, 48
	db     9, 18, 36
	db 4,  4, 11, 10
; 75 BPM
	db 6, 12, 24, 48, 96
	db    18, 36, 72

Aud2_01:: ; $75E3
	db NOTE_8TH TEMPO_150BPM, NOTE_E 4, REST
	db NOTE_HALF TEMPO_150BPM, NOTE_E 4
; measure 1
	db NOTE_8TH TEMPO_150BPM, NOTE_E 4, NOTE_F 4, REST, NOTE_F 4 SHARP, REST
	db NOTE_4TH WITH_DOT TEMPO_150BPM, NOTE_G 4
; measure 2
	db NOTE_4TH TEMPO_150BPM, REST, NOTE_C 5 SHARP
	db NOTE_8TH TEMPO_150BPM, NOTE_B 4, NOTE_A 4, REST, NOTE_C 5 SHARP
; measure 3
	db NOTE_8TH TEMPO_150BPM, REST, NOTE_C 5 SHARP, REST, NOTE_C 5 SHARP
	db NOTE_4TH TEMPO_150BPM, NOTE_B 4, NOTE_A 4
; measure 4
	db NOTE_4TH TEMPO_150BPM, REST, NOTE_D 5
	db NOTE_8TH TEMPO_150BPM, NOTE_B 4, NOTE_A 4, REST, NOTE_D 5
; measure 5
	db NOTE_8TH TEMPO_150BPM, REST, NOTE_D 5, REST, NOTE_D 5
	db NOTE_4TH TEMPO_150BPM, NOTE_B 4, NOTE_A 4
; measure 6
	db NOTE_4TH TEMPO_150BPM, REST, NOTE_C 5 SHARP
	db NOTE_8TH TEMPO_150BPM, NOTE_B 4, NOTE_A 4, REST, NOTE_C 5 SHARP
; measure 7
	db NOTE_8TH TEMPO_150BPM, REST
	db NOTE_4TH WITH_DOT TEMPO_150BPM, NOTE_C 5 SHARP
	db NOTE_8TH TEMPO_150BPM, NOTE_B 4, NOTE_A 4, NOTE_B 4, NOTE_C 5 SHARP
; measure 8
	db NOTE_4TH TEMPO_150BPM, REST, NOTE_D 5
	db NOTE_8TH TEMPO_150BPM, NOTE_B 4, NOTE_A 4, NOTE_B 4, NOTE_C 5 SHARP
; measure 9
	db NOTE_8TH TEMPO_150BPM, REST, NOTE_D 5
	db NOTE_4TH TEMPO_150BPM, REST
	db NOTE_8TH TEMPO_150BPM, NOTE_F 5, NOTE_F 5 SHARP
	db NOTE_4TH TEMPO_150BPM, NOTE_D 5
; measure 10
	db NOTE_4TH TEMPO_150BPM, REST, NOTE_C 5 SHARP
	db NOTE_8TH TEMPO_150BPM, NOTE_B 4, NOTE_A 4, NOTE_B 4, NOTE_C 5 SHARP
; measure 11
	db NOTE_8TH TEMPO_150BPM, REST
	db NOTE_4TH WITH_DOT TEMPO_150BPM, NOTE_C 5 SHARP
	db NOTE_8TH TEMPO_150BPM, NOTE_F 5
	db NOTE_4TH TEMPO_150BPM, NOTE_F 5 SHARP
	db NOTE_8TH TEMPO_150BPM, NOTE_D 5
; measure 12
	db NOTE_8TH TEMPO_150BPM, NOTE_D 5, REST, NOTE_B 4, NOTE_A 4, REST, NOTE_F 4 SHARP, NOTE_A 4, REST
; measure 13
	db NOTE_8TH TEMPO_150BPM, NOTE_D 5, REST
	db $00

Aud3_01:: ; $7652
	db NOTE_8TH TEMPO_150BPM, NOTE_E 4, REST
	db NOTE_HALF TEMPO_150BPM, NOTE_E 4
; measure 1
	db NOTE_8TH TEMPO_150BPM, NOTE_E 4, NOTE_F 4, REST, NOTE_F 4 SHARP, REST
	db NOTE_4TH WITH_DOT TEMPO_150BPM, NOTE_G 4
; measure 2
	db NOTE_8TH TEMPO_150BPM, NOTE_A 4, REST, NOTE_G 5, REST, NOTE_A 4, REST, NOTE_A 5, NOTE_G 5
; measure 3
	db NOTE_A 4, NOTE_G 5, NOTE_A 5, NOTE_G 5, NOTE_A 4, REST, NOTE_A 5, REST
; measure 4
	db NOTE_D 4, REST, NOTE_F 5 SHARP, REST, NOTE_D 4, REST, NOTE_F 5 SHARP, REST
; measure 5
	db NOTE_D 4, NOTE_F 5 SHARP, NOTE_D 5, NOTE_F 5 SHARP, NOTE_D 4, REST, NOTE_D 5, REST
; measure 6
	db NOTE_8TH TEMPO_150BPM, NOTE_A 4, REST, NOTE_G 5, REST, NOTE_A 4, REST, NOTE_A 5, NOTE_G 5
; measure 7
	db NOTE_A 4, NOTE_G 5, NOTE_A 5, REST, NOTE_A 4, REST, NOTE_A 5, NOTE_G 5
; measure 8
	db NOTE_D 4, REST, NOTE_F 5 SHARP, REST, NOTE_D 4, REST, NOTE_D 5, REST
; measure 9
	db NOTE_D 4, NOTE_F 5 SHARP, NOTE_D 5, REST, NOTE_D 4, REST, NOTE_D 5, REST
; measure 10
	db NOTE_8TH TEMPO_150BPM, NOTE_A 4, REST, NOTE_G 5, REST, NOTE_A 4, REST, NOTE_A 5, NOTE_G 5
; measure 11
	db NOTE_A 4, NOTE_G 5, NOTE_A 5, REST, NOTE_A 4, NOTE_G 5, NOTE_A 5, REST
; measure 12
	db NOTE_F 5 SHARP, REST, NOTE_D 5, REST, NOTE_D 4, REST, NOTE_D 5, REST
; measure 13
	db NOTE_F 5 SHARP, REST, NOTE_F 4 SHARP, REST, NOTE_D 4, REST
	db NOTE_4TH TEMPO_113BPM, REST
	db $00

Aud2_02:: ; $76C3
; measure 1
	db NOTE_8TH TEMPO_113BPM, NOTE_E 5, NOTE_C 5, NOTE_G 4
	db NOTE_4TH TEMPO_113BPM, NOTE_F 5, NOTE_D 5
	db NOTE_8TH TEMPO_113BPM, NOTE_G 4
; measure 2
	db NOTE_8TH TEMPO_113BPM, NOTE_E 5, NOTE_C 5
	db NOTE_4TH TEMPO_113BPM, NOTE_G 4
	db NOTE_8TH TEMPO_113BPM, NOTE_D 5, REST, NOTE_D 5, REST
; measure 3
	db NOTE_HALF WITH_DOT TEMPO_113BPM, NOTE_E 5
	db $00

Aud3_02:: ; $76D9
; measure 1
	db NOTE_8TH TEMPO_113BPM, NOTE_C 4, NOTE_G 4
	db NOTE_4TH TEMPO_113BPM, NOTE_C 5
	db NOTE_8TH TEMPO_113BPM, NOTE_F 4, NOTE_A 4
	db NOTE_4TH TEMPO_113BPM, NOTE_C 5
; measure 2
	db NOTE_8TH TEMPO_113BPM, NOTE_G 4, NOTE_E 5, NOTE_C 5, NOTE_E 5, NOTE_B 4, REST, NOTE_B 4, REST
; measure 3
	db NOTE_HALF TEMPO_113BPM, NOTE_C 5, REST
; no measure 4
	db $00

Aud2_03:: ; $76F0
; measure 1
	db NOTE_4TH TEMPO_150BPM, REST, NOTE_C 5 SHARP
	db NOTE_8TH TEMPO_150BPM, NOTE_B 4, NOTE_A 4, NOTE_B 4, NOTE_C 5 SHARP
; measure 2
	db NOTE_8TH TEMPO_150BPM, REST
	db NOTE_4TH WITH_DOT TEMPO_150BPM, NOTE_C 5 SHARP
	db NOTE_8TH TEMPO_150BPM, NOTE_F 5
	db NOTE_4TH TEMPO_150BPM, NOTE_F 5 SHARP
	db NOTE_8TH TEMPO_150BPM, NOTE_D 5
; measure 3
	db NOTE_8TH TEMPO_150BPM, NOTE_D 5, REST, NOTE_B 4, NOTE_A 4, REST, NOTE_F 4 SHARP, NOTE_A 4, REST
; measure 4
	db NOTE_8TH TEMPO_150BPM, NOTE_D 5, REST, REST, REST, NOTE_D 4
	db $00

Aud3_03:: ; $7712
; measure 1
	db NOTE_8TH TEMPO_150BPM, NOTE_A 4, REST, NOTE_G 5, REST, NOTE_A 4, REST, NOTE_A 5, NOTE_G 5
; measure 2
	db NOTE_A 4, NOTE_G 5, NOTE_A 5, REST, NOTE_A 4, NOTE_G 5, NOTE_A 5, REST
; measure 3
	db NOTE_F 5 SHARP, REST, NOTE_D 5, REST, NOTE_D 4, REST, NOTE_D 5, REST
; measure 4
	db NOTE_D 5, REST, REST, REST
	; here in 150 BPM, this is a sixteenth-note triplet, missing its third note.
	db NOTE_OTHER_TRIPLET2 TEMPO_90BPM, REST, NOTE_D 3
	db $00

Aud2_04:: ; $7733
	db NOTE_8TH TEMPO_113BPM, NOTE_E 5, NOTE_G 5, NOTE_C 6, $00
Aud3_04:: ; $7738
	db NOTE_4TH WITH_DOT TEMPO_113BPM, REST, $00 ; nice work, team.

Aud2_05:: ; $773B
; measure 1
	db NOTE_8TH TEMPO_113BPM, NOTE_E 4, NOTE_C 4, NOTE_G 3, NOTE_F 4, NOTE_D 4, NOTE_G 3, NOTE_G 4, NOTE_E 4
; measure 2
	db NOTE_8TH TEMPO_113BPM, NOTE_C 5, NOTE_B 4, NOTE_A 4, NOTE_B 4, REST, NOTE_G 4, NOTE_A 4, NOTE_B 4
; measure 3
	db NOTE_HALF WITH_DOT TEMPO_113BPM, NOTE_E 5
	db $00

Aud3_05:: ; $7750
; measure 1
	db NOTE_4TH TEMPO_113BPM, NOTE_C 4
	db NOTE_8TH TEMPO_113BPM, NOTE_C 5
	db NOTE_4TH WITH_DOT TEMPO_113BPM, NOTE_C 4
	db NOTE_4TH TEMPO_113BPM, NOTE_C 5
; measure 2
	db NOTE_4TH TEMPO_113BPM, NOTE_G 4
	db NOTE_8TH TEMPO_113BPM, NOTE_G 5
	db NOTE_4TH WITH_DOT TEMPO_113BPM, NOTE_G 4
	db NOTE_4TH TEMPO_113BPM, NOTE_G 5
; measure 3
	db NOTE_HALF TEMPO_113BPM, NOTE_C 5
	db NOTE_4TH TEMPO_113BPM, REST
	db $00

Aud2_06:: ; $7765
	db NOTE_16TH TEMPO_90BPM
; measures 1-2
rept 2
	db NOTE_E 5, NOTE_C 5, NOTE_G 4, REST, NOTE_F 5, NOTE_D 5, NOTE_G 4, REST
	db NOTE_E 5, NOTE_C 5, NOTE_G 4, REST, NOTE_D 5, NOTE_B 4, NOTE_G 4, REST
endr
; measure 3
	db NOTE_8TH TEMPO_90BPM, NOTE_F 4, NOTE_A 4, NOTE_C 5
	db NOTE_4TH TEMPO_90BPM, NOTE_F 4
	db NOTE_4TH TEMPO_90BPM, NOTE_A 4
	db NOTE_8TH TEMPO_90BPM, NOTE_C 5
; measure 4
	db NOTE_8TH TEMPO_90BPM, NOTE_G 4, NOTE_B 4, NOTE_D 5
	db NOTE_4TH TEMPO_90BPM, NOTE_G 4
	db NOTE_4TH TEMPO_90BPM, NOTE_C 5
	db NOTE_8TH TEMPO_90BPM, NOTE_D 5
; repeat
	db MUSIC_NEXT

Aud3_06:: ; $779B
	db NOTE_16TH TEMPO_90BPM
; measures 1-2
rept 2
	db NOTE_C 4, REST, NOTE_C 4, REST, NOTE_F 4, REST, NOTE_F 4, REST
	db NOTE_C 4, REST, NOTE_C 4, REST, NOTE_G 4, REST, NOTE_G 4, REST
endr
; measure 3
	db NOTE_8TH TEMPO_90BPM, NOTE_F 4, NOTE_F 5, NOTE_F 5, NOTE_F 4
	db NOTE_16TH TEMPO_90BPM, NOTE_F 4, REST, NOTE_F 5, REST
	db NOTE_8TH TEMPO_90BPM, NOTE_F 5, NOTE_F 4
; measure 3
	db NOTE_8TH TEMPO_90BPM, NOTE_G 4, NOTE_G 5, NOTE_G 5, NOTE_G 4
	db NOTE_16TH TEMPO_90BPM, NOTE_G 4, REST, NOTE_G 5, REST
	db NOTE_8TH TEMPO_90BPM, NOTE_G 5, NOTE_G 4
; repeat
	db MUSIC_NEXT

Aud2_07:: ; $77D7
	db NOTE_16TH TEMPO_113BPM
; measures 1-2
rept 2
	db NOTE_E 5, NOTE_C 5, NOTE_G 4, REST, NOTE_F 5, NOTE_D 5, NOTE_G 4, REST
	db NOTE_E 5, NOTE_C 5, NOTE_G 4, REST, NOTE_D 5, NOTE_B 4, NOTE_G 4, REST
endr
; measure 3
	db NOTE_8TH TEMPO_113BPM, NOTE_F 4, NOTE_A 4, NOTE_C 5
	db NOTE_4TH TEMPO_113BPM, NOTE_F 4
	db NOTE_4TH TEMPO_113BPM, NOTE_A 4
	db NOTE_8TH TEMPO_113BPM, NOTE_C 5
; measure 4
	db NOTE_8TH TEMPO_113BPM, NOTE_G 4, NOTE_B 4, NOTE_D 5
	db NOTE_4TH TEMPO_113BPM, NOTE_G 4
	db NOTE_4TH TEMPO_113BPM, NOTE_C 5
	db NOTE_8TH TEMPO_113BPM, NOTE_D 5
; repeat
	db MUSIC_NEXT

Aud3_07:: ; $780D
	db NOTE_16TH TEMPO_113BPM
; measures 1-2
rept 2
	db NOTE_C 4, REST, NOTE_C 4, REST, NOTE_F 4, REST, NOTE_F 4, REST
	db NOTE_C 4, REST, NOTE_C 4, REST, NOTE_G 4, REST, NOTE_G 4, REST
endr
; measure 3
	db NOTE_8TH TEMPO_113BPM, NOTE_F 4, NOTE_F 5, NOTE_F 5, NOTE_F 4
	db NOTE_16TH TEMPO_113BPM, NOTE_F 4, REST, NOTE_F 5, REST
	db NOTE_8TH TEMPO_113BPM, NOTE_F 5, NOTE_F 4
; measure 3
	db NOTE_8TH TEMPO_113BPM, NOTE_G 4, NOTE_G 5, NOTE_G 5, NOTE_G 4
	db NOTE_16TH TEMPO_113BPM, NOTE_G 4, REST, NOTE_G 5, REST
	db NOTE_8TH TEMPO_113BPM, NOTE_G 5, NOTE_G 4
; repeat
	db MUSIC_NEXT

Aud2_08:: ; $7849
	db NOTE_8TH WITH_DOT TEMPO_90BPM, NOTE_E 5
	db NOTE_16TH TEMPO_90BPM, NOTE_E 5
	db NOTE_8TH WITH_DOT TEMPO_90BPM, NOTE_D 5
	db NOTE_16TH TEMPO_90BPM, NOTE_D 5
	db NOTE_8TH WITH_DOT TEMPO_90BPM, NOTE_G 4
	db NOTE_16TH TEMPO_90BPM, NOTE_G 4
	db NOTE_8TH WITH_DOT TEMPO_90BPM, NOTE_F 5
	db NOTE_16TH TEMPO_90BPM, NOTE_F 5
	db NOTE_HALF WITH_DOT TEMPO_90BPM, NOTE_G 5
	db $00

Aud3_08:: ; $785C
rept 2
	db NOTE_8TH_TRIPLET2 TEMPO_90BPM, NOTE_G 4, NOTE_C 5
	db NOTE_8TH_TRIPLET1 TEMPO_90BPM, NOTE_E 5
	db NOTE_8TH_TRIPLET2 TEMPO_90BPM, NOTE_G 4, NOTE_D 5
	db NOTE_8TH_TRIPLET1 TEMPO_90BPM, NOTE_F 5
endr
	db NOTE_4TH WITH_DOT TEMPO_90BPM, NOTE_E 5
	db NOTE_4TH WITH_DOT TEMPO_90BPM, REST
	db $00

Aud2_09:: ; $7875
; measure 1
	db NOTE_HALF TEMPO_113BPM, NOTE_C 5
	db NOTE_8TH TEMPO_113BPM, REST, NOTE_G 4, NOTE_A 4, NOTE_B 4
; measure 2
	db NOTE_4TH TEMPO_113BPM, NOTE_C 5
	db NOTE_8TH TEMPO_113BPM, NOTE_E 5, NOTE_D 5, REST
	db NOTE_4TH WITH_DOT TEMPO_113BPM, NOTE_B 4
; measure 3
	db NOTE_HALF WITH_DOT TEMPO_113BPM, NOTE_C 5
	db $00

Aud3_09:: ; $7887
; measure 1
	db NOTE_4TH TEMPO_113BPM, NOTE_C 4
	db NOTE_8TH TEMPO_113BPM, NOTE_C 5, NOTE_C 4, REST, NOTE_C 4
	db NOTE_4TH TEMPO_113BPM, NOTE_C 5
; measure 2
	db NOTE_4TH TEMPO_113BPM, NOTE_G 4
	db NOTE_8TH TEMPO_113BPM, NOTE_A 4, NOTE_B 4, REST, NOTE_C 4, REST, NOTE_C 4
; measure 3
	db NOTE_HALF WITH_DOT TEMPO_113BPM, NOTE_C 4
	db $00

Aud2_10:: ; $789C
; measure 1
	db NOTE_HALF TEMPO_113BPM, NOTE_C 5
	db NOTE_8TH TEMPO_113BPM, REST, NOTE_G 4, NOTE_A 4, NOTE_B 4
; measure 2
	db NOTE_4TH TEMPO_113BPM, NOTE_C 5
	db NOTE_8TH TEMPO_113BPM, NOTE_E 5, NOTE_D 5, REST
	db NOTE_4TH WITH_DOT TEMPO_113BPM, NOTE_B 4
rept 2
; measures 3, 5
	db NOTE_8TH TEMPO_113BPM, NOTE_F 4
	db NOTE_4TH TEMPO_113BPM, NOTE_A 4
	db NOTE_8TH TEMPO_113BPM, NOTE_C 5, REST, NOTE_F 5, REST, NOTE_F 5
; measures 4, 6
	db NOTE_8TH TEMPO_113BPM, NOTE_G 4
	db NOTE_4TH TEMPO_113BPM, NOTE_B 4
	db NOTE_8TH TEMPO_113BPM, NOTE_D 5, REST, NOTE_G 5, REST, NOTE_G 5
endr
; measure 7
	db NOTE_HALF TEMPO_113BPM, NOTE_E 4
	db $00

Aud3_10:: ; $78D6
; measure 1
	db NOTE_4TH TEMPO_113BPM, NOTE_C 4
	db NOTE_8TH TEMPO_113BPM, NOTE_C 5, NOTE_C 4, REST, NOTE_C 4
	db NOTE_4TH TEMPO_113BPM, NOTE_C 5
; measure 2
	db NOTE_4TH TEMPO_113BPM, NOTE_G 4
	db NOTE_8TH TEMPO_113BPM, NOTE_A 4, NOTE_B 4, REST, NOTE_C 4, REST, NOTE_C 4
rept 2
; measures 3, 5
	db NOTE_4TH TEMPO_113BPM, NOTE_F 4
	db NOTE_8TH TEMPO_113BPM, NOTE_F 5, NOTE_F 4, REST, NOTE_A 4, REST, NOTE_C 5
; measures 4, 6
	db NOTE_4TH TEMPO_113BPM, NOTE_G 4
	db NOTE_8TH TEMPO_113BPM, NOTE_G 5, NOTE_G 4, REST, NOTE_D 5, REST, NOTE_G 5
endr
; measure 7
	db NOTE_HALF TEMPO_113BPM, NOTE_C 5
	db $00

Aud2_11:: ; $790F
	; changes pitch every frame.
	db NOTE_OTHER_TRIPLET1 TEMPO_90BPM, NOTE_F 3 SHARP, NOTE_D 3 SHARP, NOTE_C 3 SHARP, NOTE_A 3, NOTE_F 3, NOTE_D 3 SHARP, NOTE_C 3 SHARP, NOTE_A 3
	db $00
Aud3_11:: ; $7919
	; changes pitch every other frame.
	db NOTE_OTHER_TRIPLET2 TEMPO_90BPM, NOTE_D 3, NOTE_D 3, NOTE_C 3, NOTE_C 3
	db $00

Aud2_12:: ; $791F
rept 2
; measures 1-2, 5-6
  rept 2
	db NOTE_8TH TEMPO_75BPM, NOTE_E 5, NOTE_C 5, NOTE_G 4, NOTE_F 5, NOTE_D 5, NOTE_G 4, NOTE_G 5, NOTE_E 5
  endr
; measures 3, 7
	db NOTE_8TH TEMPO_75BPM, NOTE_F 4, NOTE_A 4, NOTE_C 5
	db NOTE_4TH TEMPO_75BPM, NOTE_F 5, NOTE_E 5
	db NOTE_8TH TEMPO_75BPM, NOTE_D 5
; measures 4, 8
	db NOTE_4TH WITH_DOT TEMPO_75BPM, NOTE_C 5
	db NOTE_4TH TEMPO_75BPM, NOTE_B 4, NOTE_C 5
	db NOTE_8TH TEMPO_75BPM, NOTE_D 5
endr
; measure 9
	db NOTE_8TH TEMPO_75BPM, NOTE_F 4, NOTE_A 4, NOTE_C 5
	db NOTE_HALF TEMPO_75BPM, NOTE_F 5
	db NOTE_8TH TEMPO_75BPM, REST
; measure 10
	db NOTE_8TH TEMPO_75BPM, NOTE_G 4, NOTE_B 4, NOTE_D 5
	db NOTE_HALF TEMPO_75BPM, NOTE_G 5
	db NOTE_8TH TEMPO_75BPM, REST
; measure 11
	db NOTE_8TH TEMPO_75BPM, NOTE_F 4, NOTE_A 4, NOTE_C 5
	db NOTE_HALF TEMPO_75BPM, NOTE_F 5
	db NOTE_8TH TEMPO_75BPM, REST
; measure 12
	db NOTE_8TH TEMPO_75BPM, NOTE_G 4, NOTE_B 4, NOTE_D 5, NOTE_G 5, REST
	db NOTE_4TH WITH_DOT TEMPO_75BPM, NOTE_G 5
; measure 13
	db NOTE_HALF TEMPO_75BPM, NOTE_E 5
	db NOTE_HALF TEMPO_75BPM, REST
	db $00

Aud3_12:: ; $7988
rept 2
; measures 1-2, 5-6
  rept 4
	db NOTE_16TH TEMPO_75BPM, NOTE_C 4, REST, NOTE_C 4, REST, NOTE_C 4, REST, NOTE_C 4, REST
  endr
; measures 3, 7
  rept 2
	db NOTE_16TH TEMPO_75BPM, NOTE_F 4, REST, NOTE_F 4, REST, NOTE_F 4, REST, NOTE_F 4, REST
  endr
; measures 4, 8
  rept 2
	db NOTE_16TH TEMPO_75BPM, NOTE_G 4, REST, NOTE_G 4, REST, NOTE_G 4, REST, NOTE_G 4, REST
  endr
endr
rept 2
; measures 9, 11
  rept 4
	db NOTE_16TH TEMPO_75BPM, NOTE_F 4, NOTE_A 4, NOTE_C 5, NOTE_F 5
  endr
; measures 10, 12
  rept 4
	db NOTE_16TH TEMPO_75BPM, NOTE_G 4, NOTE_B 4, NOTE_D 5, NOTE_G 5
  endr
endr
; measure 13
	db NOTE_4TH WITH_DOT TEMPO_75BPM, NOTE_C 5
	db NOTE_HALF TEMPO_75BPM, REST
	db NOTE_8TH TEMPO_75BPM, REST
	db $00

WaveRam:: ; $7A6F
	db $89, $AB, $BB, $BB, $BB, $BB, $98, $54, $21, $00, $00, $00, $00, $00, $00, $00
