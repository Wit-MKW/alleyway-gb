#!/bin/sh

# change to this script's directory
cd $(dirname $0)

# convert graphics files
rgbgfx -o tiles0.2bpp tiles0.png
rgbgfx -o tiles1.2bpp tiles1.png
rgbgfx -o tiles2.2bpp tiles2.png

# create object files
cd src
for file in {,audio/}*.asm; do
	rgbasm -I.. -I../hardware.inc -o ${file/asm/gbo} $file
done

# link into ROM
rgblink -dtw -m 'Alleyway (World).map' -n 'Alleyway (World).sym' -o 'Alleyway (World).gb' -p 0xFF {,audio/}*.gbo

# fix checksums
rgbfix -O -f hg 'Alleyway (World).gb'

# check ROM
true
if [[ $(head -c336 'Alleyway (World).gb' | tail -c80 | cksum -o3) != '3416921627 80' ]]; then
	echo 'Header CRC32 is incorrect!'
	false
fi
if [[ $(cksum -o3 'Alleyway (World).gb') != '1556092294 32768 Alleyway (World).gb' ]]; then
	echo 'ROM CRC32 is incorrect!'
	false
fi
if ! (echo '0cf2b8d0428f389f5361f67a0cd1ace05a1c75cc  Alleyway (World).gb' | shasum -c); then
	echo 'ROM SHA1 is incorrect!'
	false
fi
if [[ "$?" != '0' ]]; then
	echo 'If you intentionally modified the source code, then this is okay.'
fi
