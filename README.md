Super Mario Engine
A side-scrolling platform game written in x86 assembly (16-bit Real Mode).
It is built with NASM and runs in DOSBox. There is no graphics library and no game engine.
Every pixel, every key press, the clock and every rule is written instruction by instruction.
Course: EL2003 - Computer Organization and Assembly Language (Semester Project)
---
1. Team
Group: <<COAL PROJECT>>  (Section: <<BSE-3A>>)
Instructor: <<Muhammad Talha Dar>>
Repository: https://github.com/Ayeshasarfraz123-ctrl/COAL_Project_Group
Name	Roll number	Modules built
Hafiza Ayesha Sarfraz	25F-6566	Modules 1, 2, 3, 4, 5
Anoosha Choudhary	25F-5044	Modules 6, 7, 8, 9, 10
Jaweria Mushtaq	25F-3066	Modules 11 to 15

3. Project overview
The player controls a plumber-style hero. He runs, jumps and stomps across one level.
He collects coins and mushrooms, and touches the flag pole at the end before the lives or the time run out.
Rules in one minute
A new game starts with 3 lives, Small Mario (health 1), 0 points, 0 coins and 300 seconds on the clock.
Points: coin +200, "?" block coin +200, stomping an enemy 100 to 8000 (stomp chain: each stomp in the same jump gives more), kicking a shell +400, a shell killing an enemy +500 each, mushroom +1000, brick broken by Super Mario +50, flag pole 100 to 5000 (by height), and time left x 50 at the end.
Touching an enemy without stomping it turns Super Mario into Small Mario (about 2 seconds invulnerable, Mario blinks). Small Mario dies.
A pit or the clock reaching 0 kills Mario at any health.
100 coins give +1 life (maximum 99 lives).
Touching the flag pole wins the level. The time left becomes bonus points (`MUL` by 50).
The game is over when the last life is lost.
The score is a 32-bit number (two 16-bit words, `ADD` + `ADC`) and stops at 999999.
What the program contains
One level, 60 tiles (960 pixels, 3 screens) wide, 12 tiles high: ground, 2 pits (2 and 3 tiles wide), 2 pipes (2 and 3 tiles high), 3 coin "?" blocks, 2 mushroom "?" blocks, brick groups, 10 free coins, 4 Goombas, 2 Koopa Troopas, four stairs, a flag pole and a castle.
Movement with gravity, momentum, friction, run and variable jump height.
A scrolling camera that only moves right and stops at the end of the level.
Goomba, Koopa Troopa and shell behaviour (walk, turn at walls, fall, stomp, kick, slide).
Small Mario and Super Mario (16 x 32) with a health system.
A HUD with score, coins, world, time, lives and health hearts.
Screens: Title, Playing, Paused, Dying, Life lost, Win sequence, Level complete, Game over.
Flicker-free drawing through an off-screen frame buffer.
Our own keyboard (INT 09h) and timer (INT 08h) interrupt handlers.
---
3. Requirements (technical)
Item	Requirement
Processor	16-bit x86, Real Mode (the code uses only 8086 instructions)
Assembler	NASM
Emulator	DOSBox 0.74-3 or later
Display	VGA Mode 13h, 320 x 200, 256 colours, video segment 0A000h
Executable	MARIO.COM (.COM format, one segment, entry at offset 100h)
Frame rate	Steady 30 frames per second, driven by the timer interrupt
Fixed point	8.8 format (high byte = whole pixels, low byte = fraction)
---
4. Build and run (DOSBox commands)
Put `mario.asm` in the folder that DOSBox mounts as drive C (for example `C:\\\\Assembly`).
Start DOSBox and type:
```
nasm mario.asm -f bin -o MARIO.COM -l mario.lst
```
There must be no errors and no warnings.
Run the game:
```
MARIO.COM
```
To debug, type `afd MARIO.COM`.
If the game is slow, press Ctrl+F12 in DOSBox to raise the CPU speed (Ctrl+F11 lowers it).
---
5. Controls
Key	Action
Left arrow	Move left
Right arrow	Move right
Left Shift or Right Shift	Run (higher speed limit)
Space	Jump (hold Space = higher jump, only from solid ground)
P	Pause / resume
Up / Down arrow	Move the highlight in the title menu
Enter	Choose in the title menu / continue on end screens
Esc	Playing: back to the title. Title: exit to DOS
Several keys can be held at the same time (for example Right + Shift + Space).
Debug keys (for the live demo only)
Key	Effect
T	Sets the clock to 5 seconds (to test the time-out death)
C	Sets the coins counter to 99 (the next coin gives +1 life)
F	Moves Mario to the ground near the stairs and the flag pole
---
6. Memory choice
The program is a single-segment .COM file: code, data and stack share one 64 KB segment (`ORG 100h`).
The frame buffer (64,000 bytes) is in the free segment right after our program. DOS gives a .COM program all free memory, so nothing has to be requested. The buffer segment is `DS + 0x1000`; it is calculated at start-up and stored in the variable `bufseg`.
All drawing procedures draw into the segment stored in the variable `drawseg`. During the game `drawseg` = `bufseg`.
Each frame is built in the buffer. The buffer is cleared with one block fill (`REP STOSW`) and copied to video memory (segment 0A000h) with one block move (`REP MOVSW`).
Two copies of the level map are kept: `originalmap` (never changed) and `workmap` (changed when blocks are hit and coins are taken). A restart copies the original back with `REP MOVSB`, so blocks and coins are fresh in the new life.
The enemies also have an original table (`enemies\\\_orig`) and a working table (`enemies`). Each enemy is one 16-byte record, 6 records, read with indexed addressing.
The keyboard state is a 128-byte table (`keystate`): one byte per scan code, 1 = held.
---
7. Game states (and debug keys)
The game is driven by the variable `state` and a jump table (`statetable`) with one handler per state. The procedure `runstate` calls the handler of the current state once per frame.
No.	State	Entered when	Left when
0	TITLE	Program start, after Game over, after Level complete, Esc while playing	Enter on START -> PLAYING. Enter on EXIT or Esc -> EXIT
1	PLAYING	New game, resume, after the Life-lost screen	P -> PAUSED. Mario dies -> DYING. Flag touched -> WIN. Esc -> TITLE
2	PAUSED	P pressed while playing	P -> PLAYING. Esc -> TITLE
3	DYING	Enemy, pit or clock kills Mario	Animation finished -> LIFE LOST or GAME OVER
4	LIFE LOST	Death animation finished and lives are left	After about 2 seconds -> level reset -> PLAYING
5	WIN	Flag pole touched	Slide and walk finished -> LEVEL COMPLETE
6	LEVEL COMPLETE	After the win sequence	Enter -> TITLE
7	GAME OVER	The last life is lost	Enter -> TITLE
8	EXIT	Exit chosen from the title	Vectors restored, return to DOS
The only debug keys are T, C and F (section 5). They exist so that the time-out death, the extra life and the flag pole can be shown quickly in the demo.
Order of work in every PLAYING frame (Section 5.13 of the manual)
Wait for the next timer tick
Read the key-state table
Update Mario (speed, gravity, jump, tile collision one axis at a time)
Update the mushroom, the coin pop-up and the enemies and shells
Resolve Mario against enemies, items and blocks (coins are collected)
Count the clock (once per second) and the invulnerability timer
Check death (damage, pit, time) and the flag pole
Update the camera
Clear the frame buffer and draw the background, tiles, items, enemies, Mario and the HUD
Copy the frame buffer to video memory
---
8. Modules, procedures and why they exist
Every procedure has a comment block with its name, purpose, inputs, outputs and the registers it changes.
Procedures take their inputs through the stack (`push` before `call`, read with `\\\[bp+n]`, `ret n` to clean up) and keep every register they do not return.
Module	Procedure	What it does and why it was added
1. Skeleton	`start`	Entry point. Saves the old video mode, finds the free segment for the frame buffer, installs the interrupts, resets the game. Needed so the game starts cleanly.
	`mainloop`, `waitframe`	Runs one frame: waits for the 30 Hz tick, then `runstate`. Keeps the speed the same on every computer.
	`runstate`	Reads `state`, jumps through `statetable`. One place for all states instead of many `cmp`/`je`.
	exit code (`quitgame`)	Restores keyboard, timer, timer speed and text mode, then returns to DOS. Without it DOSBox hangs.
2. Video	`putpixel`	Writes one pixel at `y\\\*320+x` (offset made by shifts: `y\\\*256 + y\\\*64`). Base of all drawing. Used as the Module 2 test tool.
	`fillrect`	Fills a rectangle with one colour and clips it to the screen. Used for tiles, HUD boxes, the castle and the "?" mark.
3. Map and tiles	`resetmap`	Copies `originalmap` to `workmap` with `REP MOVSB`. Makes a new life start with fresh blocks.
	`gettile`	Returns the tile code at a pixel position (x/16, y/16). Used by all collision code.
	`drawtile`	Draws one tile: coloured square with a black border. Question blocks also get a "?" made from 6 rectangles (`qmark\\\_rects`). Added so the player can see which blocks can be hit.
	`drawmap`, `drawmapscroll`	Draw the visible part of the map for the camera position, even when it is scrolled by a few pixels.
4. Sprites	`drawsprite`	Draws a 16x16 sprite (colour 0 is transparent), with mirror and clipping. Used for Mario, enemies, items.
	`drawsuper`	Draws Super Mario (16x32) as a top half and a bottom half using `drawsprite`.
5. Frame buffer	`clearbuf`, `copybuf`	`REP STOSW` clears the off-screen buffer, `REP MOVSW` copies it to the screen. This removes flicker.
6. Camera	`updatecamera`	Moves the camera right when Mario passes screen x = 160. Never moves left, stops at 640.
7. Keyboard	`kbisr`	Our INT 09h handler. Reads port 60h, fills `keystate` (make = 1, break = 0), sets `keyhit` for a fresh press, ignores the extra E0 prefix and the fake Shift codes (2Ah/36h after E0) that the arrow keys send, then sends EOI. Needed so many keys can be held at once.
	`installkb`, `restorekb`	Save the old vector and set ours / put the old one back on exit.
	`gethit`	Returns 1 once for a new key press (used for P, Enter, Esc, menu keys).
8. Timer	`tmisr`	Our INT 08h handler. Counts frames and the second counter, then chains to the old handler.
	`installtimer`, `restoretimer`	Install and restore the vector.
	`setrate30`, `restorerate`	Program the timer chip to 30 Hz (divisor 39773) and restore the normal rate (divisor 0).
	`updateclock`	Subtracts one second from the level time every 30 ticks.
9. Physics	`updatehero`	Reads keys, applies acceleration, friction, run limit, jump (start and cut-off) and gravity in 8.8 fixed point, then calls collision.
	`addfixed`	Adds a fixed-point speed to a position (whole part + fraction).
10. Collision	`issolid`	Tells if a tile code is solid.
	`collidex`, `collidey`	Move Mario one axis at a time, check the corners against solid tiles, push him out, set `on\\\_ground`, stop on head hits. One axis at a time prevents sticking in corners.
	`mariooverlap`	Rectangle overlap test between Mario and an enemy or item.
11. Enemies	`resetenemies`	Copies `enemies\\\_orig` to `enemies` (new life = all enemies back).
	`updateenemies`	Loops over the 6 records and moves, turns, drops or kills them; resets the stomp chain when Mario lands.
	`enemymove`, `enemystep`, `enemyahead`, `enemyfall`	Walk, turn at walls and edges, fall with gravity.
	`enemyhit`	Decides stomp or damage from the side.
	`enemystomp`	Stomp: squash Goomba, turn Koopa into shell, give chain points, bounce Mario.
	`enemykick`, `shellkill`	Kick a still shell (+400) and let a sliding shell kill others (+500).
	`drawenemies`	Draws every live enemy; Goomba walk animation by mirroring.
12. Blocks, coins, items	`hitblock`	Block hit from below: brick breaks (Super only, +50), "?" gives a coin or a mushroom, then becomes an empty block. Called once per head hit at the centre of Mario.
	`checkcoin`, `collectcoins`	Collect map coins on overlap (+200, coins +1).
	`updatemushroom`	Mushroom moves, falls and is collected (+1000, becomes Super Mario).
	`updatepop`	Small coin that jumps out of a "?" block.
13. Score, HUD	`addscore`	32-bit add with `ADD`/`ADC`, clamps at 999999.
	`addcoin`	Coins +1; at 100 gives a life (max 99).
	`drawnum32`, `drawdigit`	Turn a 32-bit number into decimal digits by repeated `DIV` by 10 (digits kept on the stack) and draw them with the 8x8 font.
	`drawtext`, `drawtexts`	Draw a string with the bitmap font. `fontchars` lists the supported characters.
	`drawhudfull`	Draws the HUD: score, coins, world, time, lives and hearts.
14. States	`st\\\_title`, `st\\\_playing`, `st\\\_paused`, `st\\\_lifelost`, `st\\\_gameover`	One handler per screen, each with its own comment block.
	`drawboxes`, `setstate`	Draw the coloured boxes of the screens / change `state`.
15. Win, lose, restart	`hurtmario`, `killmario`	Damage rule (Super -> Small, Small -> death) and the death start.
	`st\\\_dying`	Death animation: Mario hops up and falls out of the screen.
	`checkflag`, `st\\\_winseq`, `winslide`, `winwalk`, `winfinish`	Flag pole points by height, slide down, walk to the castle, then the time bonus with `MUL`.
	`st\\\_levelcomplete`, `st\\\_exit`	Level complete screen / the exit state.
	`newgame`, `resetlevel`	New game values (3 lives, 0 score) / reset map, enemies, clock, position after a death.
---
9. Data tables
Tile codes
Code	Tile	Solid
0	Sky	No
1	Ground	Yes
2	Brick	Yes (Super Mario breaks it from below, +50)
3	"?" block (coin)	Yes (hit from below: empty block, coin, +200)
4	"?" block (mushroom)	Yes (hit from below: empty block, mushroom appears)
5	Empty block	Yes
6 to 9	Pipe parts	Yes
10	Stair block	Yes
11	Coin	No (collected on overlap: +200, coins +1)
12	Flag pole	No (touch = level won, points by height)
Physics (8.8 fixed point, 30 frames per second)
Constant	px/frame	Hex
Walk acceleration	0.125	0020h
Friction	0.0625	0010h
Maximum walk speed	1.5	0180h
Maximum run speed	2.5	0280h
Gravity	0.25	0040h
Jump start speed (changed)	-6.0	FA00h (manual: FA80h = -5.5)
Jump cut-off speed	-2.0	FE00h
Maximum fall speed	4.0	0400h
Stomp bounce	-3.0	FD00h
Goomba speed	0.5	0080h
Koopa speed	0.75	00C0h
Shell slide speed	3.0	0300h
---
10. Deviations from the manual
Jump start speed is -6.0 (FA00h) instead of the suggested -5.5 (FA80h).
Why: in our level the bricks are 64 pixels above the ground and the pipes are up to 3 tiles (48 pixels) high. With -5.5 Mario rises about 58 pixels, which is too low to get safely onto the bricks and the 3-tile pipe. With -6.0 he rises about 69 pixels (about 4.3 tiles; the manual says about 3.8 tiles with -5.5). The manual allows tuning when the checks still pass; all jump, stomp and block checks pass with FA00h. The constant is `JUMP\\\_SPEED` at the top of the code; changing it back to `0xFA80` restores the manual value.
The timer runs at 30 ticks per second (the timer chip is reprogrammed). The old rate is restored on every exit path.
Tiles are plain coloured squares with a black border (plus a drawn "?" on question blocks). The sprites (Mario, Goomba, Koopa, shell, mushroom, coin) are our own pixel pictures.
The castle is drawn with rectangles and is not a map tile.
The 8x8 font contains only the characters the game needs (digits and the letters used in the screens, plus J, K, Q, Y, Z so that names can be typed on the title screen). Other letters are not in the font.
The Goomba walking animation is a mirror flip every few frames.
Super Mario is drawn as a top half and a bottom half and uses the same 16x16 sprite code.
Mario does not move if both Left and Right are held (they cancel each other).
Both the Left and the Right Shift keys work as run.
The keyboard handler ignores the fake Shift codes that some keyboards send with the arrow keys. Without this, the run key would be lost while an arrow is held.
Brick hit uses one check at the centre of Mario's head (hero x + 8), so one jump breaks or hits only one block.
Finishing the level does not give an extra life.
Scoring, health, death and win rules follow Section 5 of the manual; the only changed number is the jump speed above.
---
11. Bonus features
These are small extras beyond the manual. They are optional and none of them changes a rule:
Goomba walking animation (mirror flip while walking).
Mario blinks while he is invulnerable after being hurt.
Coin pop-up: a coin jumps out of a "?" block when it is hit.
"?" symbol drawn on question blocks so they are easy to see.
Win sequence: Mario slides down the pole and walks to the castle; the time bonus is shown on the Level complete screen.
Pause screen and a title menu with START and EXIT.
(No sound, no second level, no saved high score, no fire flower and no "hurry" blink.)
---
12. Known limitations
Only one level.
No sound.
The Mario sprites have no walking animation (only stand, run and jump pictures).
The tiles are simple coloured squares, not detailed artwork.
The font is limited to the characters used by the game.
The sprite procedure draws pixel by pixel, so it is slower than a block copy (still fast enough for 30 frames per second in DOSBox).
The title screen has no text box for typing; names are changed in the source (`str\\\_group`) and the program is assembled again.
---
13. Repository layout
```
src/mario.asm    all source code (one file)
MARIO.COM        the assembled game
README.md        this file
docs/            report (Word) and screenshots
```
---
14. References
NASM documentation: The Netwide Assembler manual (nasm.us)
Ralf Brown's Interrupt List (BIOS, DOS and hardware interrupt reference)
Intel 8086/8088 family user's manual (instruction set and addressing modes)
DOSBox documentation and debugger guide (dosbox.com)
The course textbook and lecture slides on assembly language, interrupts and the stack
