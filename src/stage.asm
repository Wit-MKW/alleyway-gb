include "common.inc"
setcharmap DMG

def SPECIAL equ (1 << SPECIAL_BIT)
def SCROLLER equ (1 << SCROLLER_BIT)

def SCROLL_LEFT equ (0 << 7)
def SCROLL_RIGHT equ (1 << 7)

SECTION FRAGMENT "Main code", ROM0

; BUG: the ball cannot bounce off the right edge of the racquet at a 15° angle.
NormalRacquetAngles:: ; $1B41
	;  15°, 30°, 30°, 30°, 45°, 45°, 45°, 45°
	db $03, $06, $06, $06, $09, $09, $09, $09
	; ... and the same in reverse.
	db $09, $09, $09, $09, $06, $06, $06, $03

SmallRacquetAngles:: ; $1B51
	;  15°, 30°, 30°, 45°, 45°, 45°
	db $03, $06, $06, $09, $09, $09
	; ... and the same in reverse.
	db $09, $09, $09, $06, $06, $03

BonusScores:: ; $1B5D
for i, 1000, 10000, 1000
	be i
endr
	be 65535

SpecialRules:: ; $1B71
; special 03: 95 time, 500 points
	db 95
	be 500
; special 06: 90 time, 700 points
	db 90
	be 700
; special 09: 85 time, 1000 points
	db 85
	be 1000
; special 12, 15, 18, 21, 24: 80 time, 1500 points
	db 80
	be 1500

StageFallModulo:: ; $1B7D
	db $08, $08, $05, $05, $03, $03, $02, $02, $02, $02; and $01 forever after.

BrickTypes:: ; $1B87
; (top only), (bottom only), (both), (points << 4 | hits), (speed), (sound)
; "hits" values over 1 are broken: it ends up being the number of frames the ball
; needs to touch the brick to destroy it, passing straight through it until then.

; light (GBC light blue, SGB dim blue)
	db $AB, $AE, $A8, $11, $00, $01
; medium (GBC light yellow, SGB light magenta)
	db $AC, $AF, $A9, $21, $05, $02
; dark (GBC dark green, SGB light yellow)
	db $AD, $B0, $AA, $31, $07, $03
; bumpers
	db $00, $00, $B3, $10, $00, $00
rept 11
; unused
	db $00, $00, $00, $11, $00, $00
endr

StagePointers:: ; $1BE1
; (special << 7 | scroll << 6 | scroll type), (layout pointer)
setcharmap Bricks

; stage 01
	db 0
	dw Stage01
; stage 02
	db SCROLLER | 0
	dw Stage01
; stage 03
	db 0
	dw Stage03
; special 03
	db SPECIAL | 0
	dw Special03

; stage 04
	db 2
	dw Stage04
; stage 05
	db SCROLLER | 1
	dw Stage04
; stage 06
	db 0
	dw Stage06
; special 06
	db SPECIAL | 0
	dw Special06

; stage 07
	db 0
	dw Stage07
; stage 08
	db SCROLLER | 2
	dw Stage07
; stage 09
	db 0
	dw Stage09
; special 09
	db SPECIAL | 0
	dw Special09

; stage 10
	db 0
	dw Stage10
; stage 11
	db SCROLLER | 3
	dw Stage10
; stage 12
	db 0
	dw Stage12
; special 12
	db SPECIAL | 0
	dw Special12

; stage 13
	db 0
	dw Stage13
; stage 14
	db SCROLLER | 4
	dw Stage13
; stage 15
	db 0
	dw Stage15
; special 15
	db SPECIAL | 0
	dw Special15

; stage 16
	db 0
	dw Stage16
; stage 17
	db SCROLLER | 5
	dw Stage16
; stage 18
	db 0
	dw Stage18
; special 18
	db SPECIAL | 0
	dw Special18

; stage 19
	db 0
	dw Stage19
; stage 20
	db SCROLLER | 6
	dw Stage19
; stage 21
	db 0
	dw Stage21
; special 21
	db SPECIAL | 0
	dw Special21

; stage 22
	db 0
	dw Stage22
; stage 23
	db SCROLLER | 7
	dw Stage22
; stage 24
	db 0
	dw Stage24
; special 24
	db SPECIAL | 0
	dw Special24

; unused duplicate of stage 01
	db 0
	dw Stage01

Stage01:: ; $1C44
	db "XXXXXXXXXXXXXX"
	db "XXXXXXXXXXXXXX"
	db "              "
	db "              "
	db "              "
	db "              "
	db " ############ "
	db " ############ "
	db " ++++++++++++ "
	db " ++++++++++++ "
	db " ------------ "
	db " ------------ "
	db " ------------ "
	db "              ", $FF
Stage04:: ; $1D09
	db "              "
	db "              "
	db "##############"
	db "##############"
	db "              "
	db "              "
	db "++++++++++++++"
	db "++++++++++++++"
	db "              "
	db "              "
	db "--------------"
	db "--------------"
	db "--------------"
	db "              ", $FF
Stage07:: ; $1DCE
	db "              "
	db "              "
	db "# # # # # # # "
	db "# # # # # # # "
	db " # # # # # # #"
	db " # # # # # # #"
	db "+ + + + + + + "
	db "+ + + + + + + "
	db " + + + + + + +"
	db " + + + + + + +"
	db "+ + + + + + + "
	db "+ + + + + + + "
	db " - - - - - - -"
	db " - - - - - - -"
	db "- - - - - - - "
	db "- - - - - - - "
	db " - - - - - - -"
	db " - - - - - - -"
	db "- - - - - - - "
	db "- - - - - - - ", $FF
Stage10:: ; $1EE7
	db "              "
	db "              "
	db "              "
	db "              "
	db "####X####X####"
	db "####X####X####"
	db "    X    X    "
	db "    X    X    "
	db "++++X++++X++++"
	db "++++X++++X++++"
	db "    X    X    "
	db "    X    X    "
	db "----X----X----"
	db "----X----X----"
	db "----X----X----"
	db "    X    X    ", $FF
Stage13:: ; $1FC8
	db "              "
	db "              "
	db "#     ##     #"
	db "##   ####   ##"
	db " ## ##  ## ## "
	db "  ###    ###  "
	db "   #      #   "
	db "+     ++     +"
	db "++   ++++   ++"
	db " ++ ++  ++ ++ "
	db "  +++    +++  "
	db "   +      +   "
	db "-     --     -"
	db "--   ----   --"
	db "--- ------ ---"
	db " -----  ----- "
	db "  ---    ---  "
	db "   -      -   ", $FF
Stage16:: ; $20C5
	db "              "
	db "              "
	db "    +++++++   "
	db "    +++++++   "
	db " +++++++++++  "
	db " +++++++++++  "
	db "   --#--####  "
	db "   --#--####  "
	db " -------#--## "
	db " -------#--## "
	db " ----#-##--## "
	db " ----#-##--## "
	db "  #####---### "
	db "  #####---### "
	db "   ------###  "
	db "   ------###  "
	db "              "
	db "              "
	db "XX          XX"
	db "XX          XX", $FF
Stage19:: ; $21DE
	db "              "
	db "              "
	db "##############"
	db "##############"
	db "++++++++++++++"
	db "++++++++++++++"
	db "--------------"
	db "--------------"
	db "--------------"
	db "--------------"
	db "XX  XX  XX  XX"
	db "XX  XX  XX  XX"
	db "##############"
	db "##############"
	db "++++++++++++++"
	db "++++++++++++++"
	db "--------------"
	db "--------------"
	db "--------------"
	db "--------------", $FF
Stage22:: ; $22F7
	db "              "
	db "              "
	db "              "
	db "              "
	db "##############"
	db "##############"
	db "+++XXX++XXX+++"
	db "+++XXX++XXX+++"
	db "++XX++++++XX++"
	db "++XX++++++XX++"
	db "  X        X  "
	db "  X        X  "
	db "--X--------X--"
	db "--X--------X--"
	db "--XX------XX--"
	db "--XX------XX--"
	db "   XXX  XXX   "
	db "   XXX  XXX   ", $FF

Stage03:: ; $23F4
rept 18
	db "              "
endr
	db "XXXXXXXXXXXXXX"
	db "XXXXXXXXXXXXXX"
	db "XXXXXXXXXXXXXX"
	db "XXXXXXXXXXXXXX"
	db "              "
	db "              "
	db "              "
	db "              "
	db " ############ "
	db " ############ "
	db " ++++++++++++ "
	db " ++++++++++++ "
	db " ------------ "
	db " ------------ "
	db " ------------ "
	db "              "
	db "              "
	db "              "
	db "              "
	db "              "
	db "              "
	db "              ", $FF
Stage06:: ; $2625
rept 8
	db "              "
endr
	db "##############"
	db "##############"
	db "              "
	db "              "
	db "++++++++++++++"
	db "++++++++++++++"
	db "              "
	db "              "
	db "--------------"
	db "--------------"
	db "--------------"
	db "              "
	db "              "
	db "              "
	db "##############"
	db "##############"
	db "              "
	db "              "
	db "++++++++++++++"
	db "++++++++++++++"
	db "              "
	db "              "
	db "--------------"
	db "--------------"
	db "--------------"
	db "              "
	db "              "
	db "              "
	db "              "
	db "              "
	db "              "
	db "              ", $FF
Stage09:: ; $2856
	db "              "
	db "              "
	db "# # # # # # # "
	db "# # # # # # # "
	db " # # # # # # #"
	db " # # # # # # #"
	db "+ + + + + + + "
	db "+ + + + + + + "
	db " + + + + + + +"
	db " + + + + + + +"
	db "+ + + + + + + "
	db "+ + + + + + + "
	db " - - - - - - -"
	db " - - - - - - -"
	db "- - - - - - - "
	db "- - - - - - - "
	db " - - - - - - -"
	db " - - - - - - -"
	db "- - - - - - - "
	db "- - - - - - - "
	db "              "
	db "              "
	db " # # # # # # #"
	db " # # # # # # #"
	db "# # # # # # # "
	db "# # # # # # # "
	db " + + + + + + +"
	db " + + + + + + +"
	db "+ + + + + + + "
	db "+ + + + + + + "
	db " + + + + + + +"
	db " + + + + + + +"
	db "- - - - - - - "
	db "- - - - - - - "
	db " - - - - - - -"
	db " - - - - - - -"
	db "- - - - - - - "
	db "- - - - - - - "
	db " - - - - - - -"
	db " - - - - - - -", $FF
Stage12:: ; $2A87
rept 6
	db "              "
endr
	db "####X####X####"
	db "####X####X####"
	db "    X    X    "
	db "    X    X    "
	db "++++X++++X++++"
	db "++++X++++X++++"
	db "    X    X    "
	db "    X    X    "
	db "----X----X----"
	db "----X----X----"
	db "----X----X----"
	db "    X    X    "
	db "              "
	db "              "
	db "              "
	db "              "
	db "              "
	db "              "
	db "####X####X####"
	db "####X####X####"
	db "    X    X    "
	db "    X    X    "
	db "++++X++++X++++"
	db "++++X++++X++++"
	db "    X    X    "
	db "    X    X    "
	db "----X----X----"
	db "----X----X----"
	db "----X----X----"
	db "    X    X    "
	db "              "
	db "              "
	db "              "
	db "              ", $FF
Stage15:: ; $2CB8
	db "              "
	db "              "
	db "              "
	db "              "
	db "#     ##     #"
	db "##   ####   ##"
	db " ## ##  ## ## "
	db "  ###    ###  "
	db "   #      #   "
	db "+     ++     +"
	db "++   ++++   ++"
	db " ++ ++  ++ ++ "
	db "  +++    +++  "
	db "   +      +   "
	db "-     --     -"
	db "--   ----   --"
	db "--- ------ ---"
	db " -----  ----- "
	db "  ---    ---  "
	db "   -      -   "
	db "              "
	db "              "
	db "#     ##     #"
	db "##   ####   ##"
	db " ## ##  ## ## "
	db "  ###    ###  "
	db "   #      #   "
	db "+     ++     +"
	db "++   ++++   ++"
	db " ++ ++  ++ ++ "
	db "  +++    +++  "
	db "   +      +   "
	db "-     --     -"
	db "--   ----   --"
	db "--- ------ ---"
	db " -----  ----- "
	db "  ---    ---  "
	db "   -      -   "
	db "              "
	db "              ", $FF
Stage18:: ; $2EE9
	db "              "
	db "              "
	db "   +++++++    "
	db "   +++++++    "
	db "  +++++++++++ "
	db "  +++++++++++ "
	db "  ####--#--   "
	db "  ####--#--   "
	db " ##--#------- "
	db " ##--#------- "
	db " ##--##-#---- "
	db " ##--##-#---- "
	db " ###---#####  "
	db " ###---#####  "
	db "  ###------   "
	db "  ###------   "
	db "              "
	db "              "
	db "     XXXX     "
	db "     XXXX     "
	db "              "
	db "              "
	db "    +++++++   "
	db "    +++++++   "
	db " +++++++++++  "
	db " +++++++++++  "
	db "   --#--####  "
	db "   --#--####  "
	db " -------#--## "
	db " -------#--## "
	db " ----#-##--## "
	db " ----#-##--## "
	db "  #####---### "
	db "  #####---### "
	db "   ------###  "
	db "   ------###  "
	db "              "
	db "              "
	db "XX          XX"
	db "XX          XX", $FF
Stage21:: ; $311A
	db "              "
	db "              "
	db "              "
	db "              "
	db "XX  XX  XX  XX"
	db "XX  XX  XX  XX"
	db "              "
	db "              "
	db "##############"
	db "##############"
	db "++++++++++++++"
	db "++++++++++++++"
	db "--------------"
	db "--------------"
	db "--------------"
	db "--------------"
	db "              "
	db "              "
	db "  XX  XX  XX  "
	db "  XX  XX  XX  "
	db "              "
	db "              "
	db "##############"
	db "##############"
	db "++++++++++++++"
	db "++++++++++++++"
	db "--------------"
	db "--------------"
	db "--------------"
	db "--------------"
	db "              "
	db "              "
	db "XX  XX  XX  XX"
	db "XX  XX  XX  XX"
	db "              "
	db "              "
	db "              "
	db "              "
	db "              "
	db "              ", $FF
Stage24:: ; $334B
	db "              "
	db "              "
	db "              "
	db "              "
	db "##XXX####XXX##"
	db "##XXX####XXX##"
	db "    XX  XX    "
	db "    XX  XX    "
	db "+++++X++X+++++"
	db "+++++X++X+++++"
	db "+++++X++X+++++"
	db "+++++X++X+++++"
	db "     X  X     "
	db "     X  X     "
	db "----XX--XX----"
	db "----XX--XX----"
	db "--XXX----XXX--"
	db "--XXX----XXX--"
	db "              "
	db "              "
	db "              "
	db "              "
	db "              "
	db "              "
	db "##############"
	db "##############"
	db "+++XXX++XXX+++"
	db "+++XXX++XXX+++"
	db "++XX++++++XX++"
	db "++XX++++++XX++"
	db "  X        X  "
	db "  X        X  "
	db "--X--------X--"
	db "--X--------X--"
	db "--XX------XX--"
	db "--XX------XX--"
	db "   XXX  XXX   "
	db "   XXX  XXX   "
	db "              "
	db "              ", $FF

Special03:: ; $357C
	db "    ++++++    "
	db "  ++++++++    "
	db "    -#-###    "
	db "   --#-####   "
	db "  -----#-##   "
	db "  -----#-##   "
	db "  #####--##   "
	db "   ####--#    "
	db "   -----#     "
	db "     ---      "
	db "   +#++#++    "
	db "  ++#++#+++   "
	db " --#-##-#+--  "
	db " --#-##-#+--  "
	db " -########--  "
	db " -########--  "
	db "  #### ####   "
	db "  ###   ###   "
	db " ++++   ++++  "
	db " ++++   ++++  ", $FF
Special06:: ; $3695
	db " --           "
	db " --           "
	db " #-+   ###    "
	db "+#-+  #####   "
	db "+--++ #-###   "
	db "+--++##-####  "
	db "+++++#######  "
	db "+ +++#######  "
	db "+ ++ #######  "
	db "  ++ #######  "
	db " +++-#######  "
	db " + +-#######  "
	db "   ++-#####-  "
	db "    +-#####-+ "
	db "     +----- + "
	db "     +-----  +"
	db "    +++  +++  "
	db "   ++++  +++  "
	db "  -+++    ++- "
	db "  -++     ++- ", $FF
Special09:: ; $37AE
	db "      -+      "
	db "     --++     "
	db "    -----+    "
	db "   ------++   "
	db "  ---------+  "
	db " ----------++ "
	db " --++#++#++++ "
	db "   ++#++#++   "
	db "   -# ## #+   "
	db "   -# ## #+   "
	db "   --#--#-+   "
	db "  ---#--#-++  "
	db "  ----------  "
	db " -----------+ "
	db " -++-+++--+-+ "
	db " -+ -+++--+-+ "
	db " -+ -+  -+ -+ "
	db " -+ -+  -+ -+ "
	db "  -  -- -+ -+ "
	db "  --   -- --  ", $FF
Special12:: ; $38C7
	db "   +-   -+    "
	db "  #+     +#   "
	db " -##+  -+-#   "
	db " -##+   +-#   "
	db "  ##+-  +##-  "
	db "  ##+   +##-  "
	db " -#-#+ +##-   "
	db " -#-#+ +##-   "
	db "  ###+-+-##   "
	db "   ##+ +-#    "
	db "   #-#+###-   "
	db "    -#+## -   "
	db "     #-#      "
	db " ++   -   ++  "
	db " +++  -  ++++ "
	db " ++++ - +++++ "
	db " ++++ - +++++ "
	db "  ++++-+++++  "
	db "   +++-+++    "
	db "     +-+      ", $FF
Special15:: ; $39E0
	db "              "
	db "              "
	db "     ###### # "
	db "    ####### # "
	db "   #-##---#+- "
	db "  ##-##---#+- "
	db "  #--#-####-# "
	db " ##--#-####-# "
	db " #-#-######+# "
	db " #-#-######+# "
	db " ##-####++#+# "
	db " ##-####++#+# "
	db " ####--#-##+# "
	db " ####--#-##+# "
	db " ###-----##+# "
	db "  ##-----##+# "
	db "  ###--####+# "
	db "   ##--####+# "
	db "   ######## # "
	db "    ####### # ", $FF
Special18:: ; $3AF9
	db "      ++      "
	db "     ++++     "
	db "  ###++++###  "
	db "   ##++++##   "
	db "   --#++#--   "
	db "  +--#++#--+  "
	db "  +--#--#--+  "
	db " ++--#--#--++ "
	db " +++--++--+++ "
	db " +++--++--+++ "
	db " ++++####++++ "
	db " ++++####++++ "
	db " ++-#++++#-++ "
	db "  +-#++++#-+  "
	db "   ++----++   "
	db "     ----     "
	db "   ##----##   "
	db "   ##----##   "
	db "  ## ---- ##  "
	db "  ##  --  ##  ", $FF
Special21:: ; $3C12
	db "   +++        "
	db "    +++       "
	db "   ####   --  "
	db "  ######  --- "
	db " #-#--###---- "
	db " #-#--###---- "
	db " -#-#--##---- "
	db " -#-#--##---- "
	db " -#-#--#----- "
	db " -#-#--#----  "
	db " #-#--##---   "
	db " #-#--##---   "
	db "++++####-## - "
	db " +++####-###- "
	db "  ##+--#####- "
	db "   #+--#####- "
	db " +++-----##-- "
	db "  ++-----# -  "
	db "   ------- -  "
	db "    ----      ", $FF
Special24:: ; $3D2B
	db "     -        "
	db "  #+--        "
	db " #-+-         "
	db " #-+-+  #     "
	db "+--+++ ###-   "
	db "+--+++####-   "
	db "####+-##-###  "
	db "   #+-##-###  "
	db "  +#+-#####-# "
	db " + #+-#####-# "
	db "  ###---#-###-"
	db " ## #---#-###-"
	db "    +++-###-# "
	db "  -++++-###-# "
	db "   ++++-------"
	db "  -++++-------"
	db "   ++ ####++#+"
	db "       ###++ +"
	db "         ++++ "
	db "        -++++ ", $FF

EmptyStage:: ; $3E44
rept STAGE_ROWS_HIGHEST
	db "              "
endr
	db $FF

setcharmap DMG

ScrollConfigs:: ; $4075
; these first eight are used by stages 02, 05, 08, ..., 23.
	dw Scroll02, Scroll05, Scroll08, Scroll11, Scroll14, Scroll17, Scroll20, Scroll23
; these four aren't used anywhere in the game.
	dw UnusedScroll1, UnusedScroll2, UnusedScroll3, UnusedScroll4
; and four more aren't referenced in this list.

Scroll02:: ; $408D
rept STAGE_ROWS_ONSCREEN
	db SCROLL_LEFT | 4
endr

Scroll05:: ; $40A1
	db $00
	db $00
	db SCROLL_LEFT | 4
	db SCROLL_LEFT | 4
	db $00
	db $00
	db SCROLL_RIGHT | 4
	db SCROLL_RIGHT | 4
	db $00
	db $00
	db SCROLL_LEFT | 4
	db SCROLL_LEFT | 4
	db SCROLL_LEFT | 4
	db SCROLL_LEFT | 4
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00

Scroll08:: ; $40B5
	db $00
	db $00
	db SCROLL_LEFT | 8
	db SCROLL_LEFT | 8
	db SCROLL_LEFT | 8
	db SCROLL_LEFT | 8
	db SCROLL_LEFT | 4
	db SCROLL_LEFT | 4
	db SCROLL_LEFT | 4
	db SCROLL_LEFT | 4
	db SCROLL_LEFT | 4
	db SCROLL_LEFT | 4
	db SCROLL_LEFT | 2
	db SCROLL_LEFT | 2
	db SCROLL_LEFT | 2
	db SCROLL_LEFT | 2
	db SCROLL_LEFT | 2
	db SCROLL_LEFT | 2
	db SCROLL_LEFT | 2
	db SCROLL_LEFT | 2

Scroll11:: ; $40C9
	db $00
	db $00
	db SCROLL_RIGHT | 4
	db SCROLL_RIGHT | 4
	db SCROLL_LEFT | 4
	db SCROLL_LEFT | 4
	db SCROLL_RIGHT | 4
	db SCROLL_RIGHT | 4
	db SCROLL_LEFT | 4
	db SCROLL_LEFT | 4
	db SCROLL_RIGHT | 4
	db SCROLL_RIGHT | 4
	db SCROLL_LEFT | 4
	db SCROLL_LEFT | 4
	db SCROLL_RIGHT | 4
	db SCROLL_RIGHT | 4
	db $00
	db $00
	db $00
	db $00

Scroll14:: ; $40DD
	db $00
	db $00
	db SCROLL_RIGHT | 15
	db SCROLL_RIGHT | 15
	db SCROLL_RIGHT | 15
	db SCROLL_RIGHT | 15
	db SCROLL_RIGHT | 15
	db SCROLL_LEFT | 4
	db SCROLL_LEFT | 4
	db SCROLL_LEFT | 4
	db SCROLL_LEFT | 4
	db SCROLL_LEFT | 4
	db SCROLL_LEFT | 15
	db SCROLL_LEFT | 15
	db SCROLL_LEFT | 15
	db SCROLL_LEFT | 15
	db SCROLL_LEFT | 15
	db SCROLL_LEFT | 15
	db $00
	db $00

Scroll17:: ; $40F1
	db $00
	db $00
	db SCROLL_LEFT | 16
	db SCROLL_LEFT | 16
	db SCROLL_LEFT | 16
	db SCROLL_LEFT | 16
	db SCROLL_LEFT | 16
	db SCROLL_LEFT | 16
	db SCROLL_LEFT | 16
	db SCROLL_LEFT | 16
	db SCROLL_LEFT | 16
	db SCROLL_LEFT | 16
	db SCROLL_LEFT | 16
	db SCROLL_LEFT | 16
	db SCROLL_LEFT | 16
	db SCROLL_LEFT | 16
	db $00
	db $00
	db SCROLL_RIGHT | 4
	db SCROLL_RIGHT | 4

Scroll20:: ; $4105
	db $00
	db $00
	db SCROLL_RIGHT | 4
	db SCROLL_RIGHT | 4
	db SCROLL_RIGHT | 4
	db SCROLL_RIGHT | 4
	db SCROLL_RIGHT | 4
	db SCROLL_RIGHT | 4
	db SCROLL_RIGHT | 4
	db SCROLL_RIGHT | 4
	db SCROLL_LEFT | 4
	db SCROLL_LEFT | 4
	db SCROLL_RIGHT | 4
	db SCROLL_RIGHT | 4
	db SCROLL_RIGHT | 4
	db SCROLL_RIGHT | 4
	db SCROLL_RIGHT | 4
	db SCROLL_RIGHT | 4
	db SCROLL_RIGHT | 4
	db SCROLL_RIGHT | 4

Scroll23:: ; $4119
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
	db SCROLL_RIGHT | 4
	db SCROLL_RIGHT | 4
	db SCROLL_RIGHT | 4
	db SCROLL_RIGHT | 4
	db SCROLL_RIGHT | 4
	db SCROLL_RIGHT | 4
	db SCROLL_LEFT | 4
	db SCROLL_LEFT | 4
	db SCROLL_LEFT | 4
	db SCROLL_LEFT | 4
	db SCROLL_LEFT | 4
	db SCROLL_LEFT | 4
	db $00
	db $00

UnusedScroll1:: ; $412D
rept 4
	db SCROLL_LEFT | 9
	db SCROLL_LEFT | 9
	db SCROLL_RIGHT | 9
	db SCROLL_RIGHT | 9
endr
	db SCROLL_LEFT | 9
	db SCROLL_LEFT | 9
	db SCROLL_RIGHT | 1
	db SCROLL_RIGHT | 1

UnusedScroll2:: ; $4141
	db SCROLL_LEFT | 1
	db SCROLL_LEFT | 1
	db SCROLL_LEFT | 1
	db SCROLL_LEFT | 1
rept 8
	db SCROLL_RIGHT | 1
	db SCROLL_LEFT | 1
endr

UnusedScroll3:: ; $4155
rept STAGE_ROWS_ONSCREEN
	db SCROLL_LEFT | 1
endr

UnusedScroll4:: ; $4169
rept STAGE_ROWS_ONSCREEN
	db SCROLL_LEFT | 1
endr

UnusedScroll5:: ; $417D
rept STAGE_ROWS_ONSCREEN/2
	db SCROLL_LEFT | 1
	db SCROLL_RIGHT | 1
endr

UnusedScroll6:: ; $4191
for i, STAGE_ROWS_ONSCREEN
	db SCROLL_LEFT | (i + 1)
endr

UnusedScroll7:: ; $41A5
rept STAGE_ROWS_ONSCREEN
	db SCROLL_LEFT | 1
endr

UnusedScroll8:: ; $41B9
rept STAGE_ROWS_ONSCREEN
	db SCROLL_LEFT | 1
endr
