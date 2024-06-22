include "common.inc"
setcharmap DMG

macro sine_table_entry
if (\1) == 3 && (\2) == 15
	be $00BE
elif (\1) == 1 && (\2) == 18
	be $0049
else
	be ROUND(SIN(DIV((\1) * 1.0, 72.0)) * ((\2) + 8) * 32) / 1.0
endc

if (\1) == 15 && (\2) == 15
	be $00BE
elif (\1) == 17 && (\2) == 18
	be $0049
else
	be ROUND(COS(DIV((\1) * 1.0, 72.0)) * ((\2) + 8) * 32) / 1.0
endc
endm

SECTION FRAGMENT "Main code", ROM0
SineTables:: ; $11EE
for i, 25
	dw SineTable_{d:i}
endr

for i, 25
SineTable_{d:i}:: ; $1220 + $4C*i
for j, 19
	sine_table_entry j, i
endr
endr
