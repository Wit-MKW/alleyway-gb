include "hardware.inc"

if !DEF(COMMON_INC)
def COMMON_INC equ 1

macro be
	if _NARG == 0
		dw
	else
		rept _NARG
			db HIGH(\1), LOW(\1)
			shift
		endr
	endc
endm

def STRIP_COLUMN equ (1 << 7)
def STRIP_FILL equ (1 << 6)

macro strip
	be \1
	if ((\2) & STRIP_FILL) == 0
		db (\2) | (.end\@ - (@ + 1))
	else
		db (\2)
	endc
	shift 2
	db \#
.end\@::
endm

def SPECIAL_BIT equ 7
def SCROLLER_BIT equ 6

def STAGE_ROWS_ONSCREEN equ 20
def STAGE_ROWS_HIGHEST equ 40
def STAGE_ROWS_MAX equ 60

def STAGE_COLUMNS equ 14

rsreset
def gameMode_RESET_HISCORE rb
def gameMode_TITLE_MUSIC rb
def gameMode_TITLE_SCREEN rb
def gameMode_DEMO rb
def gameMode_START_GAME rb
def gameMode_AWAIT_BALL rb
def gameMode_GAME_PLAYING rb
def gameMode_LOST_BALL rb
def gameMode_NEXT_STAGE rb
def gameMode_NICE_PLAY rb
def gameMode_SPECIAL_BONUS rb
def gameMode_GAME_OVER rb
def gameMode_PAUSE rb

rsreset
def BrickTypes_TILES rb 3
def BrickTypes_POINTS rb
def BrickTypes_SPEED rb
def BrickTypes_SOUND rb
def BrickTypes_SIZEOF rb 0

rsreset
def StagePointers_RULES rb
def StagePointers_DATA rw
def StagePointers_SIZEOF rb 0

rsreset
def SpecialRules_POINTS rw
def SpecialRules_TIME rb
def SpecialRules_SIZEOF rb 0

PUSHC
NEWCHARMAP Bricks
charmap " ", $00
charmap "-", $01
charmap "+", $02
charmap "#", $03
charmap "X", $04

NEWCHARMAP DMG

charmap "0", $80
charmap "1", $81
charmap "2", $82
charmap "3", $83
charmap "4", $84
charmap "5", $85
charmap "6", $86
charmap "7", $87
charmap "8", $88
charmap "9", $89

charmap "A", $8A
charmap "B", $8B
charmap "C", $8C
charmap "D", $8D
charmap "E", $8E
charmap "F", $8F
charmap "G", $90
charmap "H", $91
charmap "I", $92
charmap "J", $93
charmap "K", $94
charmap "L", $95
charmap "M", $96
charmap "N", $97
charmap "O", $98
charmap "P", $99
charmap "Q", $9A
charmap "R", $9B
charmap "S", $9C
charmap "T", $9D
charmap "U", $9E
charmap "V", $9F
charmap "W", $A0
charmap "X", $A1
charmap "Y", $A2
charmap "Z", $A3

charmap "x", $B2
charmap "=", $B6
charmap ".", $B7

charmap "l", $C8
charmap " ", $FF

; only in "$8800"/"$9000" mode
charmap "©", $1E
charmap "!", $1F

POPC

endc ; COMMON_INC
