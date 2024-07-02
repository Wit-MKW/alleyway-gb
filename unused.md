# Unused content
This game has comically little by way of unused content, and even less of it is
of any interest. Nevertheless, here is a list of all unused content:
## `extinput.asm`
Arguably the most interesting piece of unused content in Alleyway is its support
for an external peripheral that ultimately never released. See the comments at
the top of `extinput.asm` for details.
## `gfx.asm`
The function labelled `DrawGfxArray` goes unused. It would take an address
`dw`'d after the call (returning after that address, à la `BCALL` on the TI-8x
calculators), and use it to draw arbitrary rectangles in VRAM.
## `input.asm`
Arguably the *least* interesting piece of unused content is the function
labelled `ThirtyOneNOPs`, consisting of... thirty-one `NOP`s & a `RET`.
## `interrupts.asm`
The functions labelled `DisableVblank` & `EnableVblank` go unused. They would,
respectively, disable & enable the vblank interrupt. Instead, its status is only
ever modified in `crt0.asm`, which enables it (manually) quite quickly & never
disables it.
## `math.asm`
The function labelled `AbsAMinusB` goes unused. It would set the A & B
registers' values both to the signed absolute value of their initial difference.
## `mloop.asm`
There are three extra game modes whose loops would return without doing
anything, causing the game to hang until the player pressed START+SELECT.
## `puck.asm`
- Brick types can be configured to require multiple hits to destroy. However, until such a brick is destroyed, the ball will not bounce off of it, and every frame that the ball intersects with it will be counted as a hit.
- The function labelled `PassThroughY`, though used, starts with an unconditional `RET`. If this instruction were removed or replaced with a `NOP`, the otherwise-unused code below would cause the ball to jump past its current row, and quite jarringly.
- The function labelled `CheckSpeedUp`, which contains the only use of the function labelled `IncBounceSpeed`, is itself unused. The former, on every eighth call, invokes the latter to increase the ball's speed by .125 px/frame... but if it was already moving at 4 px/frame, it inexplicably slows down to 1.25 px/frame.
- The data labelled `VerticalAngles` (possibly an intended continuation of `HorizontalAngles`) goes unused. It contains three 50° angles, three 60° angles, and two 70° angles.
## `sinetables.asm`
This file contains sine tables multiplied by every .125 interval in the range
1.0-4.0 (8.8 fixed-point), inclusive, with angles of every 5° interval in the
range 0°-90°, inclusive. However, only the 1.25, 1.5, and 1.75 tables are used,
and only at 15°, 30°, 40°, 45°, and 50° angles; with the exception of the 45°
entry in the 1.0 table.
## `stage.asm`
- The 15° angles at the end of `NormalRacquetAngles` & `SmallRacquetAngles` go unused because the arrays themselves are too long.
- There are eleven unused brick types which break immediately, retain the ball's speed, score one point, make the sound of a bumper, and use a glitched tile from the top-left of the E in the title screen logo.
- The stage with ID 4 (stage 04), while having its `SCROLLER` bit clear, has the same scroll configuration set as the stage with ID 9 (stage 08). Setting the `SCROLLER` bit reveals that this configuration makes little sense.
- There is an extra stage with ID 32 which is a duplicate of that with ID 0 (stage 01). However, when the stage ID is incremented from 31, it loops back to 0.
- There is an unused stage layout consisting of forty empty rows, with forty rows being the height of the vertical-scrolling stages, the tallest used stages in the game.
- There are four scroll configurations referenced in `ScrollConfigs` that go unused:
	- `UnusedScroll1`: The top two rows of bricks move one pixel to the left every ninth frame, in time with the next two rows moving to the right. This pattern continues until the bottom two rows, which move one pixel to the right every single frame.
	- `UnusedScroll2`: The top four rows of bricks move one pixel to the left every frame. The fifth row moves one pixel to the right every frame, the sixth row moves one pixel to the left every frame, and this pattern continues to the bottom of the playfield.
	- `UnusedScroll3`, `UnusedScroll4`: The entire playfield moves one pixel to the left every frame.
- There are four more scroll configurations that are not referenced in `ScrollConfigs` at all:
	- `UnusedScroll5`: The top row of bricks moves one pixel to the left every frame, the next row moves one pixel to the right every frame, and this pattern continues to the bottom of the playfield.
	- `UnusedScroll6`: The top row of bricks moves one pixel to the left every frame, the next row moves one pixel to the left every two frames, and so on.
	- `UnusedScroll7`, `UnusedScroll8`: The entire playfield moves one pixel to the left every frame.
## `text.asm`
- Just after `NicePlay` is the only unused area that is neither \$FF bytes, sensible code, nor a sensible continuation of whatever precedes it.
- The function labelled `DispBounceSpeed`, though used, starts with an unconditional `RET`. If this instruction were removed or replaced with a `NOP`, the otherwise-unused code below would cause the `bounceSpeed` variable (where the ball's speed in px/frame can be calculated as `bounceSpeed*.125+1.0`) to be displayed in the lower-left corner of the screen.
## `tiles1.png`
- Though the entire Latin alphabet is available in the font (tile numbers \$8A-\$A3, inclusive), the letters `DFJQVWXZ` go unused.
- Tile numbers \$A4-\$A7, inclusive, are the solid colours from lightest to darkest. Of these, only \$A5 is used.
- Tile number \$B6, which resembles an equals-sign `=`, goes unused.
## `variables.asm`
- The variable `mainStripUnused` is only ever written to (with a zero) at the end of `DrawMainStripArray`, and is never read from.
- The variables `wUnused`, `buttonsUnused`, and `paddleUnused` are never written to nor read from.
- The variable `hUnused` is only ever written to (with \$20) in `crt0.asm` after disabling the timer, and is never read from.
## `audio/audiomain.asm`
- The functions labelled `AudioTestEffect`, `AudioTestEffectMusic`, `AudioTestNoise`, and `AudioTestMusic` go unused. They would use input acquired by `AudioGetInput` (which also goes unused & would overwrite parts of `_DoOamDma`) to perform various tests of the audio engine.
- There are several unused variables; some are written to match other variables but never read, others are never written to nor read, and `audioUnused4` is only ever written to by two unused functions & never read.
## `audio/effects.asm`
The function labelled `ClearAudioUnused4` goes unused.
## `audio/music.asm`
The function labelled `SetAudioUnused4` goes unused, and the function labelled `_ClearAudioUnused4` is only used by `ClearAudioUnused4`, which itself goes unused.
