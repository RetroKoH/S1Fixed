; ---------------------------------------------------------------------------
; Constants
; ---------------------------------------------------------------------------

Size_of_SegaPCM:			equ $6978
Size_of_DAC_driver_guess:	equ $1760

; VDP addressses
vdp_data_port:			equ $C00000
vdp_control_port:		equ $C00004
vdp_counter:			equ $C00008

psg_input:				equ $C00011

; Z80 addresses
z80_ram:				equ $A00000	; start of Z80 RAM
; Removed z80 DAC addresses
z80_ram_end:			equ $A02000	; end of non-reserved Z80 RAM
z80_version:			equ $A10001
z80_port_1_data:		equ $A10002
z80_port_1_control:		equ $A10008
z80_port_2_control:		equ $A1000A
z80_expansion_control:	equ $A1000C
z80_bus_request:		equ $A11100
z80_reset:				equ $A11200
ym2612_a0:				equ $A04000
ym2612_d0:				equ $A04001
ym2612_a1:				equ $A04002
ym2612_d1:				equ $A04003

sram_port:				equ $A130F1

security_addr:			equ $A14000

; VRAM data
vram_fg:				equ $C000	; foreground namespace
vram_bg:				equ $E000	; background namespace
vram_sprites:			equ $F800	; sprite table
vram_hscroll:			equ $FC00	; horizontal scroll table
tile_size:				equ 8*8/2
plane_size_64x32:		equ 64*32*2

; Game modes
id_Sega:		equ ptr_GM_Sega-GameModeArray	; $00
id_Title:		equ ptr_GM_Title-GameModeArray	; $04
id_Demo:		equ ptr_GM_Demo-GameModeArray	; $08
id_Level:		equ ptr_GM_Level-GameModeArray	; $0C
id_Special:		equ ptr_GM_Special-GameModeArray; $10
id_Continue:	equ ptr_GM_Cont-GameModeArray	; $14
id_Ending:		equ ptr_GM_Ending-GameModeArray	; $18
id_Credits:		equ ptr_GM_Credits-GameModeArray; $1C

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
; ---------------------------------------------------------------------------
; Object Status Table offsets (Rearranged for S3K Priority and Object Managers -- RetroKoH)
; Nomenclature adopted from s1disasm, Sorting adopted from s2disasm
; ---------------------------------------------------------------------------
; Universally followed object conventions
obID:			equ 0			; object ID number
obRender:		equ 1			; bitfield for x/y flip, display mode
obGfx:			equ 2			; palette line & VRAM setting (2 bytes)
obMap:			equ 4			; mappings address (4 bytes)
obX:			equ 8			; x-axis position (2-4 bytes)
obXSub:			equ obX+2		; x-axis position fraction, for extra precision (2 bytes)
obScreenY:		equ obXSub		; y-axis position for screen-fixed items (2 bytes)
obY:			equ $C			; y-axis position (2-4 bytes)
obYSub:			equ obY+2		; y-axis position fraction, for extra precision (2 bytes)
obPriority:		equ $18			; sprite stack priority (2 bytes)
obFrame:		equ $1A			; current frame displayed
obActWid:		equ $23			; action width
; ---------------------------------------------------------------------------
; conventions followed by most objects including Sonic:
obVelX:			equ $10			; x-axis velocity (2 bytes)
obVelY:			equ $12			; y-axis velocity (2 bytes)
obHeight:		equ $16			; height/2
obWidth:		equ $17			; width/2
obAniFrame:		equ $1B			; current frame in animation script
obAnim:			equ $1C			; current animation
obPrevAni:		equ $1D			; previous animation
obTimeFrame:	equ $1E			; time to next frame
obDelayAni:		equ $1F			; time to delay animation
obStatus:		equ $22			; orientation or mode
obRoutine:		equ $24			; routine number
ob2ndRout:		equ $25			; secondary routine number
obAngle:		equ $26			; angle
; ---------------------------------------------------------------------------
; conventions followed by many objects but NOT Sonic
obRespawnNo:	equ $14			; respawn list address (2 bytes)
obColType:		equ $20			; collision response type
obColProp:		equ $21			; collision extra property
obSolid:		equ $25			; solid status flag for objects
obShieldProp:	equ $27			; How object responds to shields {Reflect-Lightning-Bubble-Flame 0-0-0-0}
obSubtype:		equ $28			; object subtype
obBossX:		equ $30
obBossY:		equ $38
obParent:		equ $3E
; ---------------------------------------------------------------------------
; conventions specific to playable characters
obInertia:		equ $20			; potential speed (2 bytes) -- Exclusive to players
							; $23 unused
							; $24 obRoutine
					; Sonic uses $25 if double jump stuff is enabled
							; $26 obAngle
							; $27-$29 unused

							; $2B-$2E unused
					; Sonic uses $2F if double jump stuff is enabled
obInvuln:		equ $30			; Invulnerable (blinking after getting hit) timer
obInvinc:		equ $31			; Invincibility timer
obShoes:		equ $32			; Speed Shoes timer
							; $33-34 unused
obCtrlLock:		equ $35			; formerly f_playerctrl (0, 1, or $81)
obFrontAngle:	equ $36			; angle on ground in front of sprite
obRearAngle:	equ $37			; angle on ground behind sprite
obOnWheel:		equ $38			; on convex wheel flag
obStatus2nd:	equ $39			; secondary status counter
obRestartTimer:	equ $3A			; level restart timer (1 byte)
							; $3B obSpinDashCounter+1
obJumping:		equ $3C			; jumping flag
obLRLock:		equ $3D			; flag for preventing left and right input
obPlatformAddr:	equ $3E			; ost slot of the object Sonic's on top of (Convert to 2 bytes and swap with obLRLock)
							; $3F obPlatformAddr

;	if (SpinDashEnabled|PeeloutEnabled)=1
obSpinDashFlag:		equ $2A				; spin dash/peelout flag - if toggled off, this is unused.
obSpinDashCounter:	equ obRestartTimer	; Counter used for the Spin Dash and/or Peelout (2 bytes) - if toggled off, this is unused.
;	endif
;	if ShieldsMode>0|DropDashEnabled=1
obDoubleJumpFlag:	equ	$2F				; Flag noting double jump status. 0 - not triggered. 1 - triggered. 2 - post-instashield (Begin Drop Dash revving). 3 - Drop Dash Cancelled.
obDoubleJumpProp:	equ $25				; Counter for Sonic's Drop Dash (if enabled). Can also be utilized for remaining frames of flight / 2 for Tails, gliding-related for Knuckles.
;	endif
; ---------------------------------------------------------------------------
; obStatus bitfield variables
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
; status_secondary bitfield variables
;
; status_secondary variable bit numbers
sta2ndShield:		equ	0
sta2ndInvinc:		equ	1
sta2ndShoes:		equ	2

sta2ndFShield:		equ 4
sta2ndBShield:		equ 5
sta2ndLShield:		equ 6
sta2ndSuper:		equ 7	; SuperMod

; obShieldProp bits
shPropFlame:		equ sta2ndFShield
shPropBubble:		equ sta2ndBShield
shPropLightning:	equ sta2ndLShield
shPropReflect:		equ 7

; status_secondary variable masks
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
; priority address variables -- RetroKoH/Devon S3K+ Priority Manager
priority0:	equ	v_spritequeue
priority1:	equ	v_spritequeue+$80
priority2:	equ	v_spritequeue+$100
priority3:	equ	v_spritequeue+$180
priority4:	equ	v_spritequeue+$200
priority5:	equ	v_spritequeue+$280
priority6:	equ	v_spritequeue+$300
priority7:	equ	v_spritequeue+$380

; Miscellaneous object scratch-RAM
objoff_25:	equ $25
objoff_26:	equ $26
objoff_27:	equ $27	; unused
objoff_28:	equ $28	; unused
objoff_29:	equ $29
objoff_2A:	equ $2A
objoff_2B:	equ $2B
objoff_2C:	equ $2C
objoff_2E:	equ $2E
objoff_2F:	equ $2F
objoff_30:	equ $30
objoff_31:	equ $31	; unused
objoff_32:	equ $32
objoff_33:	equ $33
objoff_34:	equ $34
objoff_35:	equ $35
objoff_36:	equ $36
objoff_37:	equ $37
objoff_38:	equ $38
objoff_39:	equ $39
objoff_3A:	equ $3A
objoff_3B:	equ $3B
objoff_3C:	equ $3C
objoff_3D:	equ $3D
objoff_3E:	equ $3E
objoff_3F:	equ $3F

object_size_bits:		equ 6
object_size:			equ 1<<object_size_bits

; Devon Subsprite SSTs -- Subsprite properties set DO override some standard object SSTs.
; What is overridden really depends on the amount of sub sprites you have set to display.
mainspr_mapframe:		equ $B	; last byte of obX (2nd byte of obScreenY)
mainspr_width:			equ $E
mainspr_childsprites:	equ $F	; amount of child sprites
mainspr_height:			equ $14
subspr_data:			equ $10
sub2_x_pos:				equ $10	; x_vel
sub2_y_pos:				equ $12	; y_vel
sub2_mapframe:			equ $15
sub3_x_pos:				equ $16	; y_radius
sub3_y_pos:				equ $18 ; priority
sub3_mapframe:			equ $1B ; anim_frame
sub4_x_pos:				equ $1C ; anim
sub4_y_pos:				equ $1E ; anim_frame_duration
sub4_mapframe:			equ $21 ; collision_property
sub5_x_pos:				equ $22 ; status
sub5_y_pos:				equ $24 ; routine
sub5_mapframe:			equ $27
sub6_x_pos:				equ $28 ; subtype
sub6_y_pos:				equ $2A
sub6_mapframe:			equ $2D
sub7_x_pos:				equ $2E
sub7_y_pos:				equ $30
sub7_mapframe:			equ $33
sub8_x_pos:				equ $34
sub8_y_pos:				equ $36
sub8_mapframe:			equ $39
sub9_x_pos:				equ $3A
sub9_y_pos:				equ $3C
sub9_mapframe:			equ $3F
next_subspr:			equ $6

; Animation flags
afEnd:			equ $FF	; return to beginning of animation
afBack:			equ $FE	; go back (specified number) bytes
afChange:		equ $FD	; run specified animation
afRoutine:		equ $FC	; increment routine counter
afReset:		equ $FB	; reset animation and 2nd object routine counter
af2ndRoutine:	equ $FA	; increment 2nd routine counter

; Background music
bgm__First:		equ $81
bgm_GHZ:		equ ((ptr_mus81-MusicIndex)/4)+bgm__First
bgm_LZ:			equ ((ptr_mus82-MusicIndex)/4)+bgm__First
bgm_MZ:			equ ((ptr_mus83-MusicIndex)/4)+bgm__First
bgm_SLZ:		equ ((ptr_mus84-MusicIndex)/4)+bgm__First
bgm_SYZ:		equ ((ptr_mus85-MusicIndex)/4)+bgm__First
bgm_SBZ:		equ ((ptr_mus86-MusicIndex)/4)+bgm__First
bgm_Invincible:	equ ((ptr_mus87-MusicIndex)/4)+bgm__First
bgm_ExtraLife:	equ ((ptr_mus88-MusicIndex)/4)+bgm__First
bgm_SS:			equ ((ptr_mus89-MusicIndex)/4)+bgm__First
bgm_Title:		equ ((ptr_mus8A-MusicIndex)/4)+bgm__First
bgm_Ending:		equ ((ptr_mus8B-MusicIndex)/4)+bgm__First
bgm_Boss:		equ ((ptr_mus8C-MusicIndex)/4)+bgm__First
bgm_FZ:			equ ((ptr_mus8D-MusicIndex)/4)+bgm__First
bgm_GotThrough:	equ ((ptr_mus8E-MusicIndex)/4)+bgm__First
bgm_GameOver:	equ ((ptr_mus8F-MusicIndex)/4)+bgm__First
bgm_Continue:	equ ((ptr_mus90-MusicIndex)/4)+bgm__First
bgm_Credits:	equ ((ptr_mus91-MusicIndex)/4)+bgm__First
bgm_Drowning:	equ ((ptr_mus92-MusicIndex)/4)+bgm__First
bgm_Emerald:	equ ((ptr_mus93-MusicIndex)/4)+bgm__First
bgm__Last:		equ ((ptr_musend-MusicIndex-4)/4)+bgm__First

; $94-9F Unused

; Sound effects
sfx__First:		equ $A0
sfx_Jump:		equ ((ptr_sndA0-SoundIndex)/4)+sfx__First
sfx_Lamppost:	equ ((ptr_sndA1-SoundIndex)/4)+sfx__First
sfx_A2:			equ ((ptr_sndA2-SoundIndex)/4)+sfx__First
sfx_Death:		equ ((ptr_sndA3-SoundIndex)/4)+sfx__First
sfx_Skid:		equ ((ptr_sndA4-SoundIndex)/4)+sfx__First
sfx_A5:			equ ((ptr_sndA5-SoundIndex)/4)+sfx__First
sfx_HitSpikes:	equ ((ptr_sndA6-SoundIndex)/4)+sfx__First
sfx_Push:		equ ((ptr_sndA7-SoundIndex)/4)+sfx__First
sfx_SSGoal:		equ ((ptr_sndA8-SoundIndex)/4)+sfx__First
sfx_SSItem:		equ ((ptr_sndA9-SoundIndex)/4)+sfx__First
sfx_Splash:		equ ((ptr_sndAA-SoundIndex)/4)+sfx__First
sfx_AB:			equ ((ptr_sndAB-SoundIndex)/4)+sfx__First
sfx_HitBoss:	equ ((ptr_sndAC-SoundIndex)/4)+sfx__First
sfx_Bubble:		equ ((ptr_sndAD-SoundIndex)/4)+sfx__First
sfx_Fireball:	equ ((ptr_sndAE-SoundIndex)/4)+sfx__First
sfx_Shield:		equ ((ptr_sndAF-SoundIndex)/4)+sfx__First
sfx_Saw:		equ ((ptr_sndB0-SoundIndex)/4)+sfx__First
sfx_Electric:	equ ((ptr_sndB1-SoundIndex)/4)+sfx__First
sfx_Drown:		equ ((ptr_sndB2-SoundIndex)/4)+sfx__First
sfx_Flamethrower:equ ((ptr_sndB3-SoundIndex)/4)+sfx__First
sfx_Bumper:		equ ((ptr_sndB4-SoundIndex)/4)+sfx__First
sfx_Ring:		equ ((ptr_sndB5-SoundIndex)/4)+sfx__First
sfx_SpikesMove:	equ ((ptr_sndB6-SoundIndex)/4)+sfx__First
sfx_Rumbling:	equ ((ptr_sndB7-SoundIndex)/4)+sfx__First
sfx_B8:			equ ((ptr_sndB8-SoundIndex)/4)+sfx__First
sfx_Collapse:	equ ((ptr_sndB9-SoundIndex)/4)+sfx__First
sfx_SSGlass:	equ ((ptr_sndBA-SoundIndex)/4)+sfx__First
sfx_Door:		equ ((ptr_sndBB-SoundIndex)/4)+sfx__First
sfx_Teleport:	equ ((ptr_sndBC-SoundIndex)/4)+sfx__First
sfx_ChainStomp:	equ ((ptr_sndBD-SoundIndex)/4)+sfx__First
sfx_Roll:		equ ((ptr_sndBE-SoundIndex)/4)+sfx__First
sfx_Continue:	equ ((ptr_sndBF-SoundIndex)/4)+sfx__First
sfx_Basaran:	equ ((ptr_sndC0-SoundIndex)/4)+sfx__First
sfx_BreakItem:	equ ((ptr_sndC1-SoundIndex)/4)+sfx__First
sfx_Warning:	equ ((ptr_sndC2-SoundIndex)/4)+sfx__First
sfx_GiantRing:	equ ((ptr_sndC3-SoundIndex)/4)+sfx__First
sfx_Bomb:		equ ((ptr_sndC4-SoundIndex)/4)+sfx__First
sfx_Cash:		equ ((ptr_sndC5-SoundIndex)/4)+sfx__First
sfx_RingLoss:	equ ((ptr_sndC6-SoundIndex)/4)+sfx__First
sfx_ChainRise:	equ ((ptr_sndC7-SoundIndex)/4)+sfx__First
sfx_Burning:	equ ((ptr_sndC8-SoundIndex)/4)+sfx__First
sfx_Bonus:		equ ((ptr_sndC9-SoundIndex)/4)+sfx__First
sfx_EnterSS:	equ ((ptr_sndCA-SoundIndex)/4)+sfx__First
sfx_WallSmash:	equ ((ptr_sndCB-SoundIndex)/4)+sfx__First
sfx_Spring:		equ ((ptr_sndCC-SoundIndex)/4)+sfx__First
sfx_Switch:		equ ((ptr_sndCD-SoundIndex)/4)+sfx__First
sfx_RingLeft:	equ ((ptr_sndCE-SoundIndex)/4)+sfx__First
sfx_Signpost:	equ ((ptr_sndCF-SoundIndex)/4)+sfx__First
sfx__Last:		equ ((ptr_sndend-SoundIndex-4)/4)+sfx__First

; Special sound effects
spec__First:	equ $D0
sfx_Waterfall:	equ ((ptr_sndD0-SpecSoundIndex)/4)+spec__First

; Additional SFX will not be toggled in/out. They will instead stay in ROM.
sfx_SpinDash:	equ ((ptr_sndD1-SpecSoundIndex)/4)+spec__First
sfx_Charge:		equ ((ptr_sndD2-SoundIndex)/4)+sfx__First
sfx_Release:	equ ((ptr_sndD3-SoundIndex)/4)+sfx__First
sfx_Stop:		equ ((ptr_sndD4-SoundIndex)/4)+sfx__First
sfx_InstaAtk:	equ ((ptr_sndD5-SoundIndex)/4)+sfx__First
sfx_FShield:	equ ((ptr_sndD6-SoundIndex)/4)+sfx__First
sfx_FShieldAtk:	equ ((ptr_sndD7-SoundIndex)/4)+sfx__First
sfx_BShield:	equ ((ptr_sndD8-SoundIndex)/4)+sfx__First
sfx_BShieldAtk:	equ ((ptr_sndD9-SoundIndex)/4)+sfx__First
sfx_LShield:	equ ((ptr_sndDA-SoundIndex)/4)+sfx__First
sfx_LShieldAtk:	equ ((ptr_sndDB-SoundIndex)/4)+sfx__First
spec__Last:		equ ((ptr_specend-SpecSoundIndex-4)/4)+spec__First

flg__First:		equ $E0
bgm_Fade:		equ ((ptr_flgE0-Sound_ExIndex)/4)+flg__First
sfx_Sega:		equ ((ptr_flgE1-Sound_ExIndex)/4)+flg__First
bgm_Speedup:	equ ((ptr_flgE2-Sound_ExIndex)/4)+flg__First
bgm_Slowdown:	equ ((ptr_flgE3-Sound_ExIndex)/4)+flg__First
bgm_Stop:		equ ((ptr_flgE4-Sound_ExIndex)/4)+flg__First
flg__Last:		equ ((ptr_flgend-Sound_ExIndex-4)/4)+flg__First

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
ArtTile_Button:					equ $43B				; ✓ -- MZ, SYZ, LZ
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

; Spring Yard Zone
ArtTile_SYZ_Big_Spikeball:		equ $372				; ✓ (Actually also used in SBZ)
ArtTile_SYZ_Bumper:				equ $38A				; ✓
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
ArtTile_LZ_Conveyor_Belt:		equ $3AA				; ✓
ArtTile_LZ_Rising_Platform:		equ $3F2				; ✓
ArtTile_LZ_Cork:				equ $429				; ✓
ArtTile_LZ_Sonic_Drowning:		equ $440				; For now, leave this alone.
ArtTile_LZ_Pole:				equ $443				; ✓
ArtTile_Jaws:					equ $44B				; ✓
ArtTile_Burrobot:				equ $46B				; ✓
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
ArtTile_SBZ_Smoke_Puff_1:		equ $2A9				; ✓ 448
ArtTile_SBZ_Smoke_Puff_2:		equ $2B5				; ✓ 454
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
ArtTile_Game_Over:				equ $550				; ?
ArtTile_Spikes:					equ $560				; ✓
ArtTile_Title_Card:				equ $568				; ✓ - Make letters uncompressed?
ArtTile_Animal_1:				equ $568				; ✓
ArtTile_Animal_2:				equ $57A				; ✓
ArtTile_Explosion:				equ $58C				; ✓
ArtTile_Ring:					equ $5EC				; ✓
ArtTile_Monitor:				equ $680				; ✓ - Optimized by removing life icon (Use HUD life icon)
ArtTile_HUD:					equ $6CA				; ✓ - Optimized by removing 1 R
ArtTile_Sonic:					equ $780				; ✓ - Player 1
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
ArtTile_Giant_Ring_Flash:		equ $462				; Remove this later and have flash be part of Giant Ring anim.
ArtTile_Prison_Capsule:			equ $49D				; ✓
ArtTile_Hidden_Points:			equ $4B6				; ✓
ArtTile_Warp:					equ $541				; Currently unused. Can overwrite Shield art if used.
ArtTile_Mini_Sonic:				equ ArtTile_Monitor		; ✓
ArtTile_Signpost:				equ $680				; ✓
ArtTile_Bonuses:				equ $6B0				; ✓ - Moved to overwrite some monitor art.

; Sega Screen
ArtTile_Sega_Tiles:				equ $000

; Title Screen - This is fine as is.
ArtTile_Title_Japanese_Text:	equ $000
ArtTile_Title_Foreground:		equ $200
ArtTile_Title_Sonic:			equ $300
ArtTile_Title_Trademark:		equ $510
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

; Special Stage Results
ArtTile_SS_Results_Emeralds:	equ $541

; Font
ArtTile_Sonic_Team_Font:		equ $0A6
ArtTile_Credits_Font:			equ $58C				; ✓

; Special Stage Block IDs (Used in _incObj/09 Sonic in Special Stage.asm -- Obj09_ChkItems:)
; I could consolidate the ZONE blocks into one block ID and dynamically load art in.
; Possibly use the W block to warp Sonic.

; Everything prior is standard wall
SSBlock_Bumper:					equ $25
; $26 is unused W block
SSBlock_GOAL:					equ $27
SSBlock_1Up:					equ $28
SSBlock_UP:						equ $29
SSBlock_DOWN:					equ $2A
SSBlock_R:						equ $2B
SSBlock_GhostSolid:				equ $2C
SSBlock_Glass1:					equ $2D
SSBlock_Glass2:					equ $2E
SSBlock_Glass3:					equ $2F
SSBlock_Glass4:					equ $30
SSBlock_R2:						equ $31
SSBlock_BumperHit1:				equ $32
SSBlock_BumperHit2:				equ $33
; $34-39 are unused ZONE Blocks
SSBlock_Ring:					equ $3A
SSBlock_Emld1:					equ $3B
SSBlock_Emld2:					equ $3C
SSBlock_Emld3:					equ $3D
SSBlock_Emld4:					equ $3E
SSBlock_Emld5:					equ $3F
SSBlock_Emld6:					equ $40

	if SuperMod=1

SSBlock_Emld7:					equ $41
SSBlock_EmldLast:				equ SSBlock_Emld7
SSBlock_Ghost:					equ $42
SSBlock_RingSparkle1:			equ $43
SSBlock_RingSparkle2:			equ $44
SSBlock_RingSparkle3:			equ $45
SSBlock_RingSparkle4:			equ $46
SSBlock_ItemSparkle1:			equ $47
SSBlock_ItemSparkle2:			equ $48
SSBlock_ItemSparkle3:			equ $49
SSBlock_ItemSparkle4:			equ $4A
SSBlock_GhostSwitch:			equ $4B
SSBlock_GlassAni1:				equ $4C
SSBlock_GlassAni2:				equ $4D
SSBlock_GlassAni3:				equ $4E
SSBlock_GlassAni4:				equ $4F

	else

SSBlock_EmldLast:				equ SSBlock_Emld6
SSBlock_Ghost:					equ $41
SSBlock_RingSparkle1:			equ $42
SSBlock_RingSparkle2:			equ $43
SSBlock_RingSparkle3:			equ $44
SSBlock_RingSparkle4:			equ $45
SSBlock_ItemSparkle1:			equ $46
SSBlock_ItemSparkle2:			equ $47
SSBlock_ItemSparkle3:			equ $48
SSBlock_ItemSparkle4:			equ $49
SSBlock_GhostSwitch:			equ $4A
SSBlock_GlassAni1:				equ $4B
SSBlock_GlassAni2:				equ $4C
SSBlock_GlassAni3:				equ $4D
SSBlock_GlassAni4:				equ $4E

	endif