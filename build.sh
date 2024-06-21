#!/bin/sh

# change to this script's directory
cd $(dirname $0)

# convert graphics files
echo '==> tiles0.png <=='
rgbgfx -v -v -v -v -v -v -o tiles0.2bpp tiles0.png
echo '==> tiles1.png <=='
rgbgfx -v -v -v -v -v -v -o tiles1.2bpp tiles1.png
echo '==> tiles2.png <=='
rgbgfx -v -v -v -v -v -v -o tiles2.2bpp tiles2.png
echo

# create object files
cd src
for file in {,audio/}*.asm; do
	echo "==> $file <=="
	rgbasm -v -I.. -I../hardware.inc -o ${file/asm/gbo} -Weverything $file
done
echo

# link into ROM
echo '==> rgblink <=='
rgblink -dtvw -m 'Alleyway (World).map' -n 'Alleyway (World).sym' -o 'Alleyway (World).gb' -p 0xFF {,audio/}*.gbo

# fix checksums
echo '==> rgbfix <=='
rgbfix -f hg 'Alleyway (World).gb'

# check ROM
true
if [[ $(head -c336 'Alleyway (World).gb' | tail -c80 | cksum -o3) != '3416921627 80' ]]; then
	echo 'Header CRC32 is incorrect!'
	false
fi
if [[ $(cksum -o3 'Alleyway (World).gb') != '1556092294 32768 Alleyway (World).gb' ]]; then
	echo 'ROM CRC32 and/or size is incorrect!'
	false
fi
if ! (echo '0cf2b8d0428f389f5361f67a0cd1ace05a1c75cc  Alleyway (World).gb' | shasum -c); then
	echo 'ROM SHA1 is incorrect!'
	false
fi
if [[ "$?" != '0' ]]; then
	echo 'If you intentionally modified the source code, then this is okay.'
fi
