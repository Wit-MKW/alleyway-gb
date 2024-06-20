include "common.inc"

SECTION "WRAM", WRAM0
stage:: ds $400 ; $C000
hitsLeft:: ds $400 ; $C400
ds align[8] ; already aligned
oamBuf:: ds $100 ; $C800
mainStripUnused:: db ; $C900
mainStripArray:: ds $FF ; $C901
scrollOffsets:: ds 20 ; $CA00
scrollModulo:: ds 20 ; $CA14
scrollCounters:: ds 20 ; $CA28
stageScy:: db ; $CA3C
borderScy:: db ; $CA3D
marioX:: db ; $CA3E
marioY:: db ; $CA3F
marioFrame:: db ; $CA40
marioFrameAlt:: db ; $CA41
marioJumpCounter:: db ; $CA42
marioSpeedX:: db ; $CA43
numLives:: db ; $CA44
stageId:: db ; $CA45
stageNum:: db ; $CA46
specialNum:: db ; $CA47
specialTime:: db ; $CA48
demoCountdown:: ds 2 ; $CA49
titleScreenMusicCounter:: db ; $CA4B

SECTION "HRAM", HRAM[$FF8C]
buttonsDown:: db ; $FF8C
buttonsPressed:: db ; $FF8D
buttonsUp:: db ; $FF8E
buttonsUnused:: db ; $FF8F

paddleCounter:: db ; $FF90
paddleAngle:: db ; $FF91
paddleButtons:: db ; $FF92
paddleButonsPressed:: db ; $FF93
paddleUnused:: db ; $FF94

gfxArrayWidth:: db ; $FF95
decOutput:: ds 5 ; $FF96
unused:: db ; $FF9B

lcdcTmp:: db ; $FF9C
ieBackup:: db ; $FF9D
scxTmp:: db ; $FF9E
scyTmp:: db ; $FF9F
vblankTrigger:: db ; $FFA0

random:: db ; $FFA1
frameCount:: db ; $FFA2
drawNeeded:: db ; $FFA3
gameMode:: db ; $FFA4

bonusesGiven:: db ; $FFA5
nextBonus:: dw ; $FFA6

stageHeight:: db ; $FFA8
stageFallMax:: db ; $FFA9
specialStage:: db ; $FFAA
scrollFlag:: db ; $FFAB
stageRowDrawing:: db ; $FFAC

rowToDraw:: db ; $FFAD
colToDraw:: db ; $FFAE

ballPosYTest:: db ; $FFAF
ballPosXTest:: db ; $FFB0

tileToDraw:: db ; $FFB1
vramOffset:: be ; $FFB2, big-endian

ballPosY:: be ; $FFB4, big-endian
ballPosX:: be ; $FFB6, big-endian
ballSpeedY:: be ; $FFB8, big-endian
ballSpeedX:: be ; $FFBA, big-endian
ballPosYLast:: db ; $FFBC
ballPosXLast:: db ; $FFBD
bounceSpeed:: db ; $FFBE

racquetY:: db ; $FFBF
racquetX:: db ; $FFC0
smallRacquetFlag:: db ; $FFC1
racquetWidth:: db ; $FFC2

speedUpCounter:: db ; $FFC3
stageFallTimer:: db ; $FFC4
stageFallCounter:: db ; $FFC5
changeAngleCounter:: db ; $FFC6
bounceFlag:: db ; $FFC7
bricksLeft:: be ; $FFC8, big-endian
score:: dw ; $FFCA, little-endian
hiScore:: dw ; $FFCC, little-endian
