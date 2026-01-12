; ---------------------------------------------------------------------------
; Constants
; ---------------------------------------------------------------------------

Size_of_SegaPCM:			equ $6978
Size_of_DAC_driver_guess:	equ $1760

; Clocks
Master_Clock:				equ 53693175
M68000_Clock:				equ Master_Clock/7
Z80_Clock:					equ Master_Clock/15
FM_Sample_Rate:				equ M68000_Clock/(6*6*4)
PSG_Sample_Rate:			equ Z80_Clock/16

; VDP addressses
vdp_data_port:				equ $C00000
vdp_control_port:			equ $C00004
vdp_counter:				equ $C00008

psg_input:					equ $C00011

; Z80 addresses
z80_ram:					equ $A00000	; start of Z80 RAM
z80_ram_end:				equ $A02000	; end of non-reserved Z80 RAM

z80_version:				equ $A10001
z80_port_1_data:			equ $A10002
z80_port_1_control:			equ $A10008
z80_port_2_control:			equ $A1000A
z80_expansion_control:		equ $A1000C
z80_bus_request:			equ $A11100
z80_reset:					equ $A11200
ym2612_a0:					equ $A04000
ym2612_d0:					equ $A04001
ym2612_a1:					equ $A04002
ym2612_d1:					equ $A04003

sram_port:					equ $A130F1

security_addr:				equ $A14000

; SRAM data (SaveProgressMod)
sram_init					equ 0
sram_zone					equ 2
sram_act					equ 4
sram_lives					equ 6
sram_score					equ 8
sram_scorelife				equ $10
sram_lastspecial			equ $18
sram_emeralds				equ $1A
sram_continues				equ $1E

; VRAM data
vram_fg:					equ $C000	; foreground namespace
vram_bg:					equ $E000	; background namespace
vram_sprites:				equ $F800	; sprite table
vram_hscroll:				equ $FC00	; horizontal scroll table
tile_size:					equ 8*8/2
plane_size_64x32:			equ 64*32*2

; Game modes
id_Sega:		equ ptr_GM_Sega-GameModeArray		; $00
id_Title:		equ ptr_GM_Title-GameModeArray		; $04
id_Demo:		equ ptr_GM_Demo-GameModeArray		; $08
id_Level:		equ ptr_GM_Level-GameModeArray		; $0C
id_Special:		equ ptr_GM_Special-GameModeArray	; $10
id_Continue:	equ ptr_GM_Cont-GameModeArray		; $14
id_Ending:		equ ptr_GM_Ending-GameModeArray		; $18
id_Credits:		equ ptr_GM_Credits-GameModeArray	; $1C
	
	if NewLevelSelect
id_MenuScreen:	equ ptr_GM_MenuScreen-GameModeArray	; $20
	endif

	if SaveProgressMod
id_SRAMError:	equ ptr_GM_SRAMError-GameModeArray	; ($20/$24)
	endif

; Levels
id_GHZ:		equ 0
id_LZ:		equ 1
id_MZ:		equ 2
id_SLZ:		equ 3
id_SYZ:		equ 4
id_SBZ:		equ 5
id_EndZ:	equ 6
id_SS:		equ 7

; Colours
cBlack:		equ $000			; colour black
cWhite:		equ $EEE			; colour white
cBlue:		equ $E00			; colour blue
cGreen:		equ $0E0			; colour green
cRed:		equ $00E			; colour red
cYellow:	equ cGreen+cRed		; colour yellow
cAqua:		equ cGreen+cBlue	; colour aqua
cMagenta:	equ cBlue+cRed		; colour magenta

; Joypad input
btnStart:	equ %10000000 ; Start button	($80)
btnA:		equ %01000000 ; A				($40)
btnC:		equ %00100000 ; C				($20)
btnB:		equ %00010000 ; B				($10)
btnR:		equ %00001000 ; Right			($08)
btnL:		equ %00000100 ; Left			($04)
btnDn:		equ %00000010 ; Down			($02)
btnUp:		equ %00000001 ; Up				($01)
btnDir:		equ %00001111 ; Any direction	($0F)
btnBC:		equ %00110000 ; B or C			($30)
btnABC:		equ %01110000 ; A, B or C		($70)
bitStart:	equ 7
bitA:		equ 6
bitC:		equ 5
bitB:		equ 4
bitR:		equ 3
bitL:		equ 2
bitDn:		equ 1
bitUp:		equ 0

; Object variables
	include "_incObj/00 OST Constants.asm"

; ---------------------------------------------------------------------------
; obRender constants
;
renXFlip:		equ 0	; horizontal flip flag
renYFlip:		equ 1	; vertical flip flag
renRelative:	equ 2	; if set, screen coordinates are relative to the level. If clear, screen coordinates are absolute.
renBGAlign:		equ 3	; object's sprite is aligned to the background
renUseHeight:	equ 4	; objects use obHeight to decide if object is on-screen, otherwise height is assumed to be $20 (used for large objects)
renRawMap:		equ 5	; sprites use raw mappings - i.e. object consists of a single sprite instead of multipart sprite mappings (e.g. broken block fragments)
renMultiDraw:	equ 6	; object renders subsprites (multiple sprites for one object)
renVisible:		equ 7	; object is visible on-screen
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
; obStatus bitfield constants
;
; Sonic's status bits (status)
staFacing:		equ 0 ; status Facing is cleared when facing right, and set when facing left.
staAir:			equ 1 ; status Air notes whether or not Sonic is in the air.
staSpin:		equ 2 ; status Spin notes whether or not Sonic is spinning.
staOnObj:		equ 3 ; status OnObj notes whether or not Sonic is standing on an object.
staRollJump:	equ 4 ; status RollJump notes whether or not Sonic is jumping from a roll. If so, he cannot control his trajectory.
staPush:		equ 5 ; status Push notes whether or not Sonic is pushing an object.
staWater:		equ 6 ; status Water is set when Sonic is in the water.
staSSJump:		equ 7 ; status SSJump is set when Sonic jumps in a Special Stage.
; Sonic's status masks
maskFacing:		equ 1<<staFacing		; $01
maskAir:		equ 1<<staAir			; $02
maskSpin:		equ 1<<staSpin			; $04
maskOnObj:		equ 1<<staOnObj			; $08
maskRollJump:	equ 1<<staRollJump		; $10
maskPush:		equ 1<<staPush			; $20
maskWater:		equ 1<<staWater			; $40
;
; Other objects' status bits
staFlipX:		equ 0 ; status FlipX is cleared when facing left, and set when facing right.
staFlipY:		equ 1 ; status FlipY is set if the sprite is flipped vertically. Cleared otherwise.
staSonicOnObj:	equ 3 ; status SonicOnObj notes whether or not Sonic is standing on the object. Bit 4 would test for Player 2
staSonicPush:	equ 5 ; status Push notes whether or not Sonic is pushing the object. Bit 6 would test for Player 2
; Other objects' status masks
maskFlipX:		equ 1<<staFlipX			; $01
maskFlipY:		equ 1<<staFlipY			; $02
	; 4
maskSonicOnObj:	equ 1<<staSonicOnObj	; $08
	; $10
maskSonicPush:	equ 1<<staSonicPush		; $20
	; $40
; ---------------------------------------------------------------------------
; status_secondary bitfield constants

; status_secondary bit numbers
sta2ndShield:		equ	0
sta2ndInvinc:		equ	1
sta2ndShoes:		equ	2
sta2ndGoggles:		equ 3	; Debug item

sta2ndFShield:		equ 4
sta2ndBShield:		equ 5
sta2ndLShield:		equ 6
sta2ndSuper:		equ 7	; SuperMod

; obShieldProp bits
shPropFlame:		equ sta2ndFShield
shPropBubble:		equ sta2ndBShield
shPropLightning:	equ sta2ndLShield
shPropReflect:		equ 7

; status_secondary masks
mask2ndShield:		equ	1<<sta2ndShield		; $01
mask2ndInvinc:		equ	1<<sta2ndInvinc		; $02
mask2ndShoes:		equ	1<<sta2ndShoes		; $04

mask2ndFShield:		equ	1<<sta2ndFShield	; $10
mask2ndBShield:		equ	1<<sta2ndBShield	; $20
mask2ndLShield:		equ	1<<sta2ndLShield	; $40

mask2ndChkElement:	equ $70					; Elemental Shield bits checked
mask2ndChkShield:	equ $71					; Every shield bit checked
mask2ndRmvShield:	equ	~mask2ndChkShield	; ~$71
; ---------------------------------------------------------------------------
; obGfx constants
gfxFlipX:			equ 3					; if set, sprites will be flipped horizontally.
gfxFlipY:			equ 4					; if set, sprites will be flipped vertically.
gfxPalLower:		equ 5					; upper bit; sets base palette line to 1
gfxPalUpper:		equ 6					; upper bit; sets base palette line to 2 or 3
gfxPriority:		equ 7					; used on the upper byte

maskDrawing:		equ $7FFF
maskHighPriority:	equ $8000
; ---------------------------------------------------------------------------
; priority address constants -- RetroKoH/Devon S3K+ Priority Manager
priority0:	equ	v_spritequeue
priority1:	equ	v_spritequeue+$80
priority2:	equ	v_spritequeue+$100
priority3:	equ	v_spritequeue+$180
priority4:	equ	v_spritequeue+$200
priority5:	equ	v_spritequeue+$280
priority6:	equ	v_spritequeue+$300
priority7:	equ	v_spritequeue+$380

; Animation flags
afEnd:			equ $FF	; return to beginning of animation
afBack:			equ $FE	; go back (specified number) bytes
afChange:		equ $FD	; run specified animation
afRoutine:		equ $FC	; increment routine counter
afReset:		equ $FB	; reset animation and 2nd object routine counter
af2ndRoutine:	equ $FA	; increment 2nd routine counter

		include "_maps/Sonic Sprite Constants.asm"

; Boss locations
; The main values are based on where the camera boundaries mainly lie
; The end values are where the camera scrolls towards after defeat
boss_ghz_x:		equ $2960		; Green Hill Zone
boss_ghz_y:		equ $300
boss_ghz_end:	equ boss_ghz_x+$160

boss_lz_x:		equ $1DE0		; Labyrinth Zone
boss_lz_y:		equ $C0
boss_lz_end:	equ boss_lz_x+$250

boss_mz_x:		equ $1800		; Marble Zone
boss_mz_y:		equ $210
boss_mz_end:	equ boss_mz_x+$160

boss_slz_x:		equ $2000		; Star Light Zone
boss_slz_y:		equ $210
boss_slz_end:	equ boss_slz_x+$160

boss_syz_x:		equ $2C00		; Spring Yard Zone
boss_syz_y:		equ $4CC
boss_syz_end:	equ boss_syz_x+$140

boss_sbz2_x:	equ $2050		; Scrap Brain Zone Act 2 Cutscene
boss_sbz2_y:	equ $510

boss_fz_x:		equ $2450		; Final Zone
boss_fz_y:		equ $510
boss_fz_end:	equ boss_fz_x+$2B0

; Tile VRAM Locations

; Shared
ArtTile_GHZ_MZ_Swing:			equ $39C				; ✓ -- GHZ and MZ
ArtTile_Fireball:				equ $3AA				; ✓ -- MZ and SLZ
ArtTile_Crabmeat:				equ $3C2				; ✓ -- GHZ and SYZ
ArtTile_Buzz_Bomber:			equ $406				; ✓ -- GHZ, MZ, SYZ
ArtTile_Orbinaut:				equ $40A				; ✓ -- LZ and SLZ
ArtTile_Button:					equ $43D				; ✓ -- MZ, SYZ, LZ
ArtTile_Caterkiller:			equ $445				; ✓ -- MZ, SYZ and SBZ
ArtTile_Yadrin:					equ $455				; ✓ -- MZ and SYZ
ArtTile_Bomb:					equ $455				; ✓ -- SLZ and SBZ

; Green Hill Zone
ArtTile_GHZ_Flower_4:			equ $340				; ✓ animtiles4
ArtTile_GHZ_Flower_Stalk:		equ $358				; ✓ 4
ArtTile_GHZ_Sunflower:			equ $35C				; ✓ Uncompressed: 16
ArtTile_GHZ_Purple_Flower:		equ $36C				; ✓ Uncompressed: 12
ArtTile_GHZ_Waterfall:			equ $378				; ✓ Uncompressed: 8
ArtTile_GHZ_Flower_3:			equ $380				; ✓ animtiles5
ArtTile_GHZ_Big_Flower_2:		equ $390				; ✓ animtiles6
; ===== IN-GAME LEVEL OBJECTS ====================
ArtTile_GHZ_Purple_Rock:		equ $33E				; ✓
ArtTile_GHZ_Spike_Pole:			equ $380				; ✓
ArtTile_GHZ_Bridge:				equ $392				; ✓
ArtTile_GHZ_Smashable_Wall:		equ $3AA				; ✓
ArtTile_GHZ_Edge_Wall:			equ $3B6				; ✓
ArtTile_Chopper:				equ $43D				; ✓
ArtTile_GHZ_Giant_Ball:			equ $462				; ✓
ArtTile_Newtron:				equ $488				; ✓
ArtTile_Moto_Bug:				equ $4DD				; ✓

; Marble Zone
ArtTile_MZ_Animated_Magma:		equ $297				; ✓ Uncompressed: 16
ArtTile_MZ_Animated_Lava:		equ $2A7				; ✓ Uncompressed: 8
ArtTile_MZ_Torch:				equ $2AF				; ✓ Uncompressed: 6
ArtTile_MZ_Lava:				equ $2B5				; ✓
ArtTile_MZ_Spike_Stomper:		equ $351				; ✓
ArtTile_Basaran:				equ $3D6				; ✓
ArtTile_MZ_Glass_Pillar:		equ $492				; ✓
ArtTile_MZ_Block:				equ $4AC				; ✓
ArtTile_MZ_UFO:					equ $4F2				; Uncompressed: 8

; Spring Yard Zone
ArtTile_SYZ_Big_Spikeball:		equ $372				; ✓ (Actually also used in SBZ)
ArtTile_SYZ_Bumper:				equ $38A				; ✓
ArtTile_Splats:					equ $3A0				; ✓
ArtTile_SYZ_Spikeball_Chain:	equ $492				; ✓
ArtTile_Roller:					equ $496				; ✓

; Labyrinth Zone
ArtTile_LZ_Block_1:				equ $1C6				; ✓
ArtTile_LZ_Block_2:				equ $1D6				; ✓
ArtTile_LZ_Waterfall:			equ $23E				; ✓
ArtTile_LZ_Gargoyle:			equ $2AB				; ✓
ArtTile_LZ_Water_Surface:		equ $2BC				; ✓
ArtTile_LZ_Spikeball_Chain:		equ $2CC				; ✓
ArtTile_LZ_Flapping_Door:		equ $2E4				; ✓
ArtTile_LZ_Bubbles:				equ $304				; ✓
ArtTile_LZ_Moving_Block:		equ $378				; ✓
ArtTile_LZ_Door:				equ $380				; ✓
ArtTile_LZ_Harpoon:				equ $388				; ✓
ArtTile_LZ_Push_Block:			equ $392				; ✓ -- Appears to be correct
ArtTile_LZ_Blocks:				equ $39A				; ✓
ArtTile_LZ_Conveyor_Wheel:		equ $3AA				; ✓ (Now only $10 tiles here)
ArtTile_LZ_Conveyor_Ptfm:		equ $3BA				; ✓ (Only 8 tiles here)
ArtTile_LZ_Rising_Platform:		equ $3F2				; ✓
ArtTile_LZ_Cork:				equ $429				; ✓
ArtTile_LZ_Sonic_Drowning:		equ $440				; For now, leave this alone.
ArtTile_LZ_Pole:				equ $445				; ✓
ArtTile_Jaws:					equ $44D				; ✓
ArtTile_Burrobot:				equ $46D				; ✓
ArtTile_Splash:					equ $4C5				; ✓ - Temporary Location

; Star Light Zone
ArtTile_SLZ_Pylon:				equ $36A				; ✓
ArtTile_SLZ_Seesaw:				equ $37A				; ✓
ArtTile_SLZ_Spikeball:			equ $3D6				; ✓ 
ArtTile_SLZ_Swing:				equ $3E8				; ✓
ArtTile_SLZ_Fan:				equ $429				; ✓
ArtTile_SLZ_Shrapnel:			equ $47C				; ✓ -- For boss
ArtTile_SLZ_Fireball_Launcher:	equ $47E				; ✓
ArtTile_SLZ_Smashable_Wall:		equ $486				; ✓
ArtTile_SLZ_Collapsing_Floor:	equ $48E				; ✓

; Scrap Brain Zone
ArtTile_SBZ_Smoke_Puff_1:		equ $2A9				; ✓
ArtTile_SBZ_Smoke_Puff_2:		equ $2B5				; ✓
ArtTile_SBZ_Moving_Block_Short:	equ $2C1				; ✓
ArtTile_SBZ_Door:				equ $2E9				; ✓
ArtTile_SBZ_Girder:				equ $2F1				; ✓
ArtTile_Ball_Hog:				equ $303				; ✓
ArtTile_SBZ_Saw:				equ $332				; ✓ SBZCutter
ArtTile_SBZ_Vanishing_Block:	equ $356				; ✓
ArtTile_SBZ_Trap_Door:			equ $396				; ✓
ArtTile_SBZ_Horizontal_Door:	equ $3C7				; ✓
ArtTile_SBZ_Collapsing_Floor:	equ $3D6				; ✓ Used Twice
ArtTile_SBZ_Moving_Block_Long:	equ $3DE				; ✓
ArtTile_SBZ_Electric_Orb:		equ $3ED				; ✓
ArtTile_SBZ_Spinning_Platform:	equ $401				; ✓
ArtTile_SBZ_Flamethrower:		equ $47E				; ✓
ArtTile_SBZ_Disc:				equ $49A				; ✓ SBZWheel1
ArtTile_SBZ_Junction:			equ $49E				; ✓ SBZWheel2

; Final Zone
ArtTile_FZ_Boss:				equ $300
ArtTile_FZ_Eggman_Fleeing:		equ $3A0
ArtTile_FZ_Eggman_No_Vehicle:	equ $470

; General Level Art
ArtTile_Level:					equ $000
ArtTile_Missile_Disolve:		equ $41C ; Unused
ArtTile_Spring_Horizontal:		equ $4FA				; ✓
ArtTile_Spring_Vertical:		equ $50A				; ✓
ArtTile_Lamppost:				equ $518				; ✓
ArtTile_Points:					equ $522				; ✓
ArtTile_Dust:					equ $52B				; ✓
ArtTile_Shield:					equ $53B				; ✓ A760
ArtTile_LShield_Sparks:			equ ArtTile_Shield+$15	;
ArtTile_Game_Over:				equ ArtTile_Sonic		; ✓
ArtTile_Spikes:					equ $560				; ✓
ArtTile_Title_Card:				equ $568				; ✓ - Make letters uncompressed?
ArtTile_Animal_1:				equ $568				; ✓
ArtTile_Animal_2:				equ $57A				; ✓
ArtTile_Explosion:				equ $58C				; ✓

; Test w/ Optimal and Normal Title cards
ArtTile_Ring:					equ $5F4				; ✓
ArtTile_LostRing:				equ $5F8				; ✓
ArtTile_RingSparkles:			equ $5FC				; ✓

ArtTile_Monitor:				equ $680				; ✓ - Optimized by removing life icon (Use HUD life icon)
ArtTile_HUD:					equ $6CA				; ✓ - Optimized by removing 1 R
ArtTile_Sonic:					equ $780				; ✓ - Player 1
ArtTile_Goggles:				equ $7BC				; Testing
ArtTile_Lives_Counter:			equ $7D4				; ✓

; Eggman
ArtTile_Eggman:					equ $3F0				; ✓
ArtTile_Eggman_Weapons:			equ $45C				; ✓
ArtTile_Eggman_Spikeball:		equ $504				; Test this
ArtTile_Eggman_Exhaust:			equ $51A				; ?
ArtTile_Eggman_Button:			equ $4A4				; SBZ2 Cutscene. Leave alone for now. < Align this w/ ArtTile_Button?
ArtTile_Eggman_Trap_Floor:		equ $518				; SBZ2 Cutscene. Leave alone for now.

; End of Level
ArtTile_Giant_Ring:				equ $430				; ✓
ArtTile_Giant_Ring_Flash:		equ $462				; ✓
ArtTile_Prison_Capsule:			equ $49D				; ✓
ArtTile_Hidden_Points:			equ $4B6				; ✓
ArtTile_Warp:					equ $541				; Currently unused. Can overwrite Shield art if used.
ArtTile_Mini_Sonic:				equ ArtTile_Monitor		; ✓
ArtTile_Signpost:				equ $680				; ✓
ArtTile_Bonuses:				equ $6B0				; ✓ - Moved to overwrite some monitor art.
ArtTile_Perfect:				equ $7B0				; Zone/Special Stage Results

; Sega Screen
ArtTile_Sega_Tiles:				equ $000

; Title Screen - This is fine as is.
ArtTile_Title_Japanese_Text:	equ $000
ArtTile_Title_Foreground:		equ $200
ArtTile_Title_Trademark:		equ $30E
ArtTile_Title_Sonic:			equ $310
ArtTile_Level_Select_Font:		equ $680

; Continue Screen
ArtTile_Continue_Sonic:			equ $500
ArtTile_Continue_Number:		equ $6FC				; Check this

; Ending
ArtTile_Ending_Flowers:			equ $3A0				; ✓
ArtTile_Ending_Emeralds:		equ $3C5				; ✓
ArtTile_Ending_Sonic:			equ $3E1				; ✓
ArtTile_Ending_Eggman:			equ $524				; Unused
ArtTile_Ending_Rabbit:			equ $524				; ✓
ArtTile_Ending_Chicken:			equ $536				; ✓
ArtTile_Ending_Penguin:			equ $544				; ✓
ArtTile_Ending_Seal:			equ $556				; ✓
ArtTile_Ending_Pig:				equ $564				; ✓
ArtTile_Ending_Flicky:			equ $576				; ✓
ArtTile_Ending_Squirrel:		equ $584				; ✓
ArtTile_Ending_STH:				equ $596				; ✓

; Try Again Screen
ArtTile_Try_Again_Emeralds:		equ $3C5
ArtTile_Try_Again_Eggman:		equ $3E1

; Special Stage
ArtTile_SS_Background_Clouds:	equ $000
ArtTile_SS_Background_Fish:		equ $051
ArtTile_SS_Wall:				equ $142
ArtTile_SS_HUD:					equ $1F9
ArtTile_SS_Plane_1:				equ $200				; Check this
ArtTile_SS_Lives:				equ $22F
ArtTile_SS_Bumper:				equ $23B
ArtTile_SS_Goal:				equ $251
ArtTile_SS_Up_Down:				equ $263
ArtTile_SS_R_Block:				equ $2F0
ArtTile_SS_Plane_2:				equ $300				; Check this
ArtTile_SS_Extra_Life:			equ $370
ArtTile_SS_Emerald_Sparkle:		equ $3F0
ArtTile_SS_Plane_3:				equ $400				; Check this
ArtTile_SS_Red_White_Block:		equ $470
ArtTile_SS_Ghost_Block:			equ $4F0
ArtTile_SS_Plane_4:				equ $500				; Check this
ArtTile_SS_W_Block:				equ $570
ArtTile_SS_Glass:				equ $5F0
ArtTile_SS_Plane_5:				equ $600				; Check this
ArtTile_SS_Plane_6:				equ $700				; Check this
ArtTile_SS_Emerald:				equ $770
ArtTile_SS_Zone_1:				equ $790				; ✓
ArtTile_SS_Ring:				equ $799				; ✓
ArtTile_SS_RingSparkles:		equ $79D				; ✓
ArtTile_SS_Cursor:				equ $790				; ✓
ArtTile_SS_Delete:				equ $7B0				; Check this

; Special Stage Results
ArtTile_SS_Results_Emeralds:	equ $541

; Font
ArtTile_Sonic_Team_Font:		equ $0A6
ArtTile_Credits_Font:			equ $58C				; ✓

; Special Stage Block IDs (Used in _incObj/09 Sonic in Special Stage.asm -- Obj09_ChkItems:)
	phase $01

; Standard Wall Blocks
SSBlock_BlueWall:				ds.b 9	; $01-09
SSBlock_YellowWall:				ds.b 9	; $0A-12
SSBlock_PinkWall:				ds.b 9	; $13-1B
SSBlock_GreenWall:				ds.b 9	; $1C-24

; Solid Non-Wall Blocks
SSBlock_Bumper:					ds.b 1	; $25
SSBlock_W:						ds.b 1	; $26 (Unused)
SSBlock_GOAL:					ds.b 1	; $27
SSBlock_1Up:					ds.b 1	; $28
SSBlock_UP:						ds.b 1	; $29
SSBlock_DOWN:					ds.b 1	; $2A
SSBlock_R:						ds.b 1	; $2B
SSBlock_GhostSolid:				ds.b 1	; $2C
SSBlock_Glass1:					ds.b 1	; $2D
SSBlock_Glass2:					ds.b 1	; $2E
SSBlock_Glass3:					ds.b 1	; $2F
SSBlock_Glass4:					ds.b 1	; $30
SSBlock_R2:						ds.b 1	; $31 (not used in initial layouts; Only used in real-time for animation)
SSBlock_BumperHit1:				ds.b 1	; $32 (not used in initial layouts; Only used in real-time for animation)
SSBlock_BumperHit2:				ds.b 1	; $33 (not used in initial layouts; Only used in real-time for animation)
SSBlock_ZoneBlocks:				ds.b 6	; $34-39 (Unused)

; Non-Solid Blocks (Tokens)
SSBlock_Ring:					ds.b 1	; $3A
SSBlock_Emld1:					ds.b 1	; $3B
SSBlock_Emld2:					ds.b 1	; $3C
SSBlock_Emld3:					ds.b 1	; $3D
SSBlock_Emld4:					ds.b 1	; $3E
SSBlock_Emld5:					ds.b 1	; $3F
SSBlock_Emld6:					ds.b 1	; $40

	if SuperMod
SSBlock_Emld7:					ds.b 1	; $41
SSBlock_EmldLast:				equ SSBlock_Emld7
	else
SSBlock_EmldLast:				equ SSBlock_Emld6	
	endif

SSBlock_Ghost:					ds.b 1
SSBlock_RingSparkle1:			ds.b 1		; not used in initial layouts (Only used in real-time for animation)
SSBlock_RingSparkle2:			ds.b 1		; not used in initial layouts (Only used in real-time for animation)
SSBlock_RingSparkle3:			ds.b 1		; not used in initial layouts (Only used in real-time for animation)
SSBlock_RingSparkle4:			ds.b 1		; not used in initial layouts (Only used in real-time for animation)
SSBlock_ItemSparkle1:			ds.b 1		; not used in initial layouts (Only used in real-time for animation)
SSBlock_ItemSparkle2:			ds.b 1		; not used in initial layouts (Only used in real-time for animation)
SSBlock_ItemSparkle3:			ds.b 1		; not used in initial layouts (Only used in real-time for animation)
SSBlock_ItemSparkle4:			ds.b 1		; not used in initial layouts (Only used in real-time for animation)
SSBlock_GhostSwitch:			ds.b 1		; used in initial layouts, not placeable in Debug Mode
SSBlock_GlassAni1:				ds.b 1		; not used in initial layouts (Only used in real-time for animation)
SSBlock_GlassAni2:				ds.b 1		; not used in initial layouts (Only used in real-time for animation)
SSBlock_GlassAni3:				ds.b 1		; not used in initial layouts (Only used in real-time for animation)
SSBlock_GlassAni4:				ds.b 1		; not used in initial layouts (Only used in real-time for animation)
	dephase

; obColType constants (See _incObj/sub ReactToItem.asm)
; collision flags
colEnemy:						equ $00
colPowerup:						equ $40
colHarmful:						equ $80
colSpecial:						equ $C0

; collision sizes (WIDTHxHEIGHT)
colSz_20x20:					equ $01		; Wrecking Balls
colSz_12x20:					equ $02		; Splats badnik
colSz_20x12:					equ $03		; unused?
colSz_4x16:						equ $04		; GHZ Spiked Log, SYZ Boss Spike
colSz_12x18:					equ $05		; Ballhog and Burrobot badniks
colSz_16x16:					equ $06		; SBZ2 Spikeball, Crabmeat, Monitors, Prison Button, SYZ Big Spiked Ball
colSz_6x6:						equ $07		; Badnik Missiles, Ball Hog's Cannonballs, Rings
colSz_24x12:					equ $08		; Buzz Bomber badnik
colSz_12x16:					equ $09		; Chopper badnik
colSz_16x12:					equ $0A		; Jaws badnik
colSz_8x8:						equ $0B		; Lava/Fire Balls, Basaran badnik, Chained Spike Ball, Seesaw spikeball, Orbinaut head, Caterkiller parts, SLZ Boss Spikeball
colSz_20x16:					equ $0C		; Motobug, Newtron, and Yadrin badniks
colSz_20x8:						equ $0D		; Newtron badnik
colSz_16x14:					equ $0E		; Roller badnik
colSz_24x24:					equ $0F		; Bosses
colSz_40x16:					equ $10		; Chained Stompers
colSz_16x24:					equ $11		; Sideways Stompers
colSz_8x16:						equ $12		; Giant Ring
colSz_32x112:					equ $13		; Lava Fall/Geyser
colSz_64x32:					equ $14		; Lava Wall, Lava Tag
colSz_128x32:					equ $15		; Lava Tag
colSz_32x32:					equ $16		; Lava Tag
colSz_8x8_2:					equ $17		; Bumper
colSz_4x4:						equ $18		; SYZ Small Spike Chain, Bomb shrapnel, Orbinaut orbs, Gargoyle Fireball, SLZ Spikeball shrapnel
colSz_32x8:						equ $19		; SLZ Spiked Platform
colSz_12x12:					equ $1A		; Bomb badnik, and FZ Plasma Balls
colSz_8x4:						equ $1B		; Harpoon
colSz_24x4:						equ $1C		; Harpoon
colSz_40x4:						equ $1D		; Harpoon
colSz_4x8:						equ $1E		; Harpoon
colSz_4x24:						equ $1F		; Harpoon
colSz_4x40:						equ $20		; Harpoon
colSz_4x32:						equ $21		; LZ Breakable Pole
colSz_24x24_2:					equ $22		; SBZ Saws and Cutters
colSz_12x24:					equ $23		; SBZ Flamethrower
colSz_72x8:						equ $24		; SBZ Electrocuter