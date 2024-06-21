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

; Sound driver constants
TrackPlaybackControl:	equ 0		; All tracks
TrackVoiceControl:	equ 1		; All tracks
TrackTempoDivider:	equ 2		; All tracks
TrackDataPointer:	equ 4		; All tracks (4 bytes)
TrackTranspose:		equ 8		; FM/PSG only (sometimes written to as a word, to include TrackVolume)
TrackVolume:		equ 9		; FM/PSG only
TrackAMSFMSPan:		equ $A		; FM/DAC only
TrackVoiceIndex:	equ $B		; FM/PSG only
TrackVolEnvIndex:	equ $C		; PSG only
TrackStackPointer:	equ $D		; All tracks
TrackDurationTimeout:	equ $E		; All tracks
TrackSavedDuration:	equ $F		; All tracks
TrackSavedDAC:		equ $10		; DAC only
TrackFreq:		equ $10		; FM/PSG only (2 bytes)
TrackNoteTimeout:	equ $12		; FM/PSG only
TrackNoteTimeoutMaster:equ $13		; FM/PSG only
TrackModulationPtr:	equ $14		; FM/PSG only (4 bytes)
TrackModulationWait:	equ $18		; FM/PSG only
TrackModulationSpeed:	equ $19		; FM/PSG only
TrackModulationDelta:	equ $1A		; FM/PSG only
TrackModulationSteps:	equ $1B		; FM/PSG only
TrackModulationVal:	equ $1C		; FM/PSG only (2 bytes)
TrackDetune:		equ $1E		; FM/PSG only
TrackPSGNoise:		equ $1F		; PSG only
TrackFeedbackAlgo:	equ $1F		; FM only
TrackVoicePtr:		equ $20		; FM SFX only (4 bytes)
TrackLoopCounters:	equ $24		; All tracks (multiple bytes)
TrackGoSubStack:	equ TrackSz	; All tracks (multiple bytes. This constant won't get to be used because of an optimisation that just uses TrackSz)

TrackSz:	equ $30

; VRAM data
vram_fg:	equ $C000	; foreground namespace
vram_bg:	equ $E000	; background namespace
vram_sprites:	equ $F800	; sprite table
vram_hscroll:	equ $FC00	; horizontal scroll table

; Game modes
id_Sega:	equ ptr_GM_Sega-GameModeArray	; $00
id_Title:	equ ptr_GM_Title-GameModeArray	; $04
id_Demo:	equ ptr_GM_Demo-GameModeArray	; $08
id_Level:	equ ptr_GM_Level-GameModeArray	; $0C
id_Special:	equ ptr_GM_Special-GameModeArray; $10
id_Continue:	equ ptr_GM_Cont-GameModeArray	; $14
id_Ending:	equ ptr_GM_Ending-GameModeArray	; $18
id_Credits:	equ ptr_GM_Credits-GameModeArray; $1C

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
cBlack:		equ $000		; colour black
cWhite:		equ $EEE		; colour white
cBlue:		equ $E00		; colour blue
cGreen:		equ $0E0		; colour green
cRed:		equ $00E		; colour red
cYellow:	equ cGreen+cRed		; colour yellow
cAqua:		equ cGreen+cBlue	; colour aqua
cMagenta:	equ cBlue+cRed		; colour magenta

; Joypad input
btnStart:	equ %10000000 ; Start button	($80)
btnA:		equ %01000000 ; A		($40)
btnC:		equ %00100000 ; C		($20)
btnB:		equ %00010000 ; B		($10)
btnR:		equ %00001000 ; Right		($08)
btnL:		equ %00000100 ; Left		($04)
btnDn:		equ %00000010 ; Down		($02)
btnUp:		equ %00000001 ; Up		($01)
btnDir:		equ %00001111 ; Any direction	($0F)
btnABC:		equ %01110000 ; A, B or C	($70)
bitStart:	equ 7
bitA:		equ 6
bitC:		equ 5
bitB:		equ 4
bitR:		equ 3
bitL:		equ 2
bitDn:		equ 1
bitUp:		equ 0

; Object variables (Rearranged for S2 Priority Manager -- RetroKoH)
obID:			equ 0			; object ID number
obRender:		equ 1			; bitfield for x/y flip, display mode
obGfx:			equ 2			; palette line & VRAM setting (2 bytes)
obMap:			equ 4			; mappings address (4 bytes)
obX:			equ 8			; x-axis position (2-4 bytes)
obScreenY:		equ $A			; y-axis position for screen-fixed items (2 bytes)
obY:			equ $C			; y-axis position (2-4 bytes)
obVelX:			equ $10			; x-axis velocity (2 bytes)
obVelY:			equ $12			; y-axis velocity (2 bytes)
obRespawnNo:	equ $14			; respawn list index number (now 2 bytes; Swapped w/ obActWid)
obHeight:		equ $16			; height/2
obWidth:		equ $17			; width/2
obPriority:		equ $18			; sprite stack priority (2 bytes)
obFrame:		equ $1A			; current frame displayed
obAniFrame:		equ $1B			; current frame in animation script
obAnim:			equ $1C			; current animation
obPrevAni:		equ $1D			; previous animation
obTimeFrame:	equ $1E			; time to next frame
obDelayAni:		equ $1F			; time to delay animation
obInertia:		equ $20			; potential speed (2 bytes) -- Exclusive to players
obColType:		equ $20			; collision response type
obColProp:		equ $21			; collision extra property
obStatus:		equ $22			; orientation or mode
obActWid:		equ $23			; action width (formerly obInertia); swapped with obRespawnNo 
obRoutine:		equ $24			; routine number
ob2ndRout:		equ $25			; secondary routine number
obAngle:		equ $26			; angle
obSubtype:		equ $28			; object subtype
obSolid:		equ ob2ndRout	; solid status flag

; Mercury SST Constants
obInvuln:		equ $30			; Invulnerable (blinking after getting hit) timer
obInvinc:		equ $31			; Invincibility timer
obShoes:		equ $32			; Speed Shoes timer
							; $33-35 unused
obFrontAngle:	equ $36
obRearAngle:	equ $37
obOnWheel:		equ $38			; on convex wheel flag
obStatus2:		equ $39			; status for abilities such as Spin Dash
obRestartTimer:	equ $3A			; level restart timer
obJumping:		equ $3C			; jumping flag
obPlatformID:	equ $3D			; ost slot of the object Sonic's on top of
obLRLock:		equ $3E			; flag for preventing left and right input (2 bytes)

; Miscellaneous object scratch-RAM
objoff_25:	equ $25
objoff_26:	equ $26
objoff_29:	equ $29
objoff_2A:	equ $2A
objoff_2B:	equ $2B
objoff_2C:	equ $2C
objoff_2E:	equ $2E
objoff_2F:	equ $2F
objoff_30:	equ $30
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

object_size_bits:	equ 6
object_size:	equ 1<<object_size_bits

; Devon Subsprite SSTs -- Subsprite properties set DO override some standard object SSTs.
; What is overridden really depends on the amount of sub sprites you have set to display.
mainspr_mapframe:		equ $B	; last byte of obX (2nd byte of obScreenY)
mainspr_width:			equ $E
mainspr_childsprites:	equ $F	; amount of child sprites
mainspr_height:			equ $14
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
afEnd:		equ $FF	; return to beginning of animation
afBack:		equ $FE	; go back (specified number) bytes
afChange:	equ $FD	; run specified animation
afRoutine:	equ $FC	; increment routine counter
afReset:	equ $FB	; reset animation and 2nd object routine counter
af2ndRoutine:	equ $FA	; increment 2nd routine counter

; Background music
bgm__First:	equ $81
bgm_GHZ:	equ ((ptr_mus81-MusicIndex)/4)+bgm__First
bgm_LZ:		equ ((ptr_mus82-MusicIndex)/4)+bgm__First
bgm_MZ:		equ ((ptr_mus83-MusicIndex)/4)+bgm__First
bgm_SLZ:	equ ((ptr_mus84-MusicIndex)/4)+bgm__First
bgm_SYZ:	equ ((ptr_mus85-MusicIndex)/4)+bgm__First
bgm_SBZ:	equ ((ptr_mus86-MusicIndex)/4)+bgm__First
bgm_Invincible:	equ ((ptr_mus87-MusicIndex)/4)+bgm__First
bgm_ExtraLife:	equ ((ptr_mus88-MusicIndex)/4)+bgm__First
bgm_SS:		equ ((ptr_mus89-MusicIndex)/4)+bgm__First
bgm_Title:	equ ((ptr_mus8A-MusicIndex)/4)+bgm__First
bgm_Ending:	equ ((ptr_mus8B-MusicIndex)/4)+bgm__First
bgm_Boss:	equ ((ptr_mus8C-MusicIndex)/4)+bgm__First
bgm_FZ:		equ ((ptr_mus8D-MusicIndex)/4)+bgm__First
bgm_GotThrough:	equ ((ptr_mus8E-MusicIndex)/4)+bgm__First
bgm_GameOver:	equ ((ptr_mus8F-MusicIndex)/4)+bgm__First
bgm_Continue:	equ ((ptr_mus90-MusicIndex)/4)+bgm__First
bgm_Credits:	equ ((ptr_mus91-MusicIndex)/4)+bgm__First
bgm_Drowning:	equ ((ptr_mus92-MusicIndex)/4)+bgm__First
bgm_Emerald:	equ ((ptr_mus93-MusicIndex)/4)+bgm__First
bgm__Last:	equ ((ptr_musend-MusicIndex-4)/4)+bgm__First

; Sound effects
sfx__First:	equ $A0
sfx_Jump:	equ ((ptr_sndA0-SoundIndex)/4)+sfx__First
sfx_Lamppost:	equ ((ptr_sndA1-SoundIndex)/4)+sfx__First
sfx_A2:		equ ((ptr_sndA2-SoundIndex)/4)+sfx__First
sfx_Death:	equ ((ptr_sndA3-SoundIndex)/4)+sfx__First
sfx_Skid:	equ ((ptr_sndA4-SoundIndex)/4)+sfx__First
sfx_A5:		equ ((ptr_sndA5-SoundIndex)/4)+sfx__First
sfx_HitSpikes:	equ ((ptr_sndA6-SoundIndex)/4)+sfx__First
sfx_Push:	equ ((ptr_sndA7-SoundIndex)/4)+sfx__First
sfx_SSGoal:	equ ((ptr_sndA8-SoundIndex)/4)+sfx__First
sfx_SSItem:	equ ((ptr_sndA9-SoundIndex)/4)+sfx__First
sfx_Splash:	equ ((ptr_sndAA-SoundIndex)/4)+sfx__First
sfx_AB:		equ ((ptr_sndAB-SoundIndex)/4)+sfx__First
sfx_HitBoss:	equ ((ptr_sndAC-SoundIndex)/4)+sfx__First
sfx_Bubble:	equ ((ptr_sndAD-SoundIndex)/4)+sfx__First
sfx_Fireball:	equ ((ptr_sndAE-SoundIndex)/4)+sfx__First
sfx_Shield:	equ ((ptr_sndAF-SoundIndex)/4)+sfx__First
sfx_Saw:	equ ((ptr_sndB0-SoundIndex)/4)+sfx__First
sfx_Electric:	equ ((ptr_sndB1-SoundIndex)/4)+sfx__First
sfx_Drown:	equ ((ptr_sndB2-SoundIndex)/4)+sfx__First
sfx_Flamethrower:equ ((ptr_sndB3-SoundIndex)/4)+sfx__First
sfx_Bumper:	equ ((ptr_sndB4-SoundIndex)/4)+sfx__First
sfx_Ring:	equ ((ptr_sndB5-SoundIndex)/4)+sfx__First
sfx_SpikesMove:	equ ((ptr_sndB6-SoundIndex)/4)+sfx__First
sfx_Rumbling:	equ ((ptr_sndB7-SoundIndex)/4)+sfx__First
sfx_B8:		equ ((ptr_sndB8-SoundIndex)/4)+sfx__First
sfx_Collapse:	equ ((ptr_sndB9-SoundIndex)/4)+sfx__First
sfx_SSGlass:	equ ((ptr_sndBA-SoundIndex)/4)+sfx__First
sfx_Door:	equ ((ptr_sndBB-SoundIndex)/4)+sfx__First
sfx_Teleport:	equ ((ptr_sndBC-SoundIndex)/4)+sfx__First
sfx_ChainStomp:	equ ((ptr_sndBD-SoundIndex)/4)+sfx__First
sfx_Roll:	equ ((ptr_sndBE-SoundIndex)/4)+sfx__First
sfx_Continue:	equ ((ptr_sndBF-SoundIndex)/4)+sfx__First
sfx_Basaran:	equ ((ptr_sndC0-SoundIndex)/4)+sfx__First
sfx_BreakItem:	equ ((ptr_sndC1-SoundIndex)/4)+sfx__First
sfx_Warning:	equ ((ptr_sndC2-SoundIndex)/4)+sfx__First
sfx_GiantRing:	equ ((ptr_sndC3-SoundIndex)/4)+sfx__First
sfx_Bomb:	equ ((ptr_sndC4-SoundIndex)/4)+sfx__First
sfx_Cash:	equ ((ptr_sndC5-SoundIndex)/4)+sfx__First
sfx_RingLoss:	equ ((ptr_sndC6-SoundIndex)/4)+sfx__First
sfx_ChainRise:	equ ((ptr_sndC7-SoundIndex)/4)+sfx__First
sfx_Burning:	equ ((ptr_sndC8-SoundIndex)/4)+sfx__First
sfx_Bonus:	equ ((ptr_sndC9-SoundIndex)/4)+sfx__First
sfx_EnterSS:	equ ((ptr_sndCA-SoundIndex)/4)+sfx__First
sfx_WallSmash:	equ ((ptr_sndCB-SoundIndex)/4)+sfx__First
sfx_Spring:	equ ((ptr_sndCC-SoundIndex)/4)+sfx__First
sfx_Switch:	equ ((ptr_sndCD-SoundIndex)/4)+sfx__First
sfx_RingLeft:	equ ((ptr_sndCE-SoundIndex)/4)+sfx__First
sfx_Signpost:	equ ((ptr_sndCF-SoundIndex)/4)+sfx__First
sfx__Last:	equ ((ptr_sndend-SoundIndex-4)/4)+sfx__First

; Special sound effects
spec__First:	equ $D0
sfx_Waterfall:	equ ((ptr_sndD0-SpecSoundIndex)/4)+spec__First
spec__Last:	equ ((ptr_specend-SpecSoundIndex-4)/4)+spec__First

flg__First:	equ $E0
bgm_Fade:	equ ((ptr_flgE0-Sound_ExIndex)/4)+flg__First
sfx_Sega:	equ ((ptr_flgE1-Sound_ExIndex)/4)+flg__First
bgm_Speedup:	equ ((ptr_flgE2-Sound_ExIndex)/4)+flg__First
bgm_Slowdown:	equ ((ptr_flgE3-Sound_ExIndex)/4)+flg__First
bgm_Stop:	equ ((ptr_flgE4-Sound_ExIndex)/4)+flg__First
flg__Last:	equ ((ptr_flgend-Sound_ExIndex-4)/4)+flg__First

; Sonic frame IDs
fr_Null:	equ 0
fr_Stand:	equ 1
fr_Wait1:	equ 2
fr_Wait2:	equ 3
fr_Wait3:	equ 4
fr_LookUp:	equ 5
fr_Walk11:	equ 6
fr_Walk12:	equ 7
fr_Walk13:	equ 8
fr_Walk14:	equ 9
fr_Walk15:	equ $A
fr_Walk16:	equ $B
fr_Walk21:	equ $C
fr_Walk22:	equ $D
fr_Walk23:	equ $E
fr_Walk24:	equ $F
fr_Walk25:	equ $10
fr_Walk26:	equ $11
fr_Walk31:	equ $12
fr_Walk32:	equ $13
fr_Walk33:	equ $14
fr_Walk34:	equ $15
fr_Walk35:	equ $16
fr_Walk36:	equ $17
fr_Walk41:	equ $18
fr_Walk42:	equ $19
fr_Walk43:	equ $1A
fr_Walk44:	equ $1B
fr_Walk45:	equ $1C
fr_Walk46:	equ $1D
fr_Run11:	equ $1E
fr_Run12:	equ $1F
fr_Run13:	equ $20
fr_Run14:	equ $21
fr_Run21:	equ $22
fr_Run22:	equ $23
fr_Run23:	equ $24
fr_Run24:	equ $25
fr_Run31:	equ $26
fr_Run32:	equ $27
fr_Run33:	equ $28
fr_Run34:	equ $29
fr_Run41:	equ $2A
fr_Run42:	equ $2B
fr_Run43:	equ $2C
fr_Run44:	equ $2D
fr_Roll1:	equ $2E
fr_Roll2:	equ $2F
fr_Roll3:	equ $30
fr_Roll4:	equ $31
fr_Roll5:	equ $32
fr_Warp1:	equ $33
fr_Warp2:	equ $34
fr_Warp3:	equ $35
fr_Warp4:	equ $36
fr_Stop1:	equ $37
fr_Stop2:	equ $38
fr_Duck:	equ $39
fr_Balance1:	equ $3A
fr_Balance2:	equ $3B
fr_Float1:	equ $3C
fr_Float2:	equ $3D
fr_Float3:	equ $3E
fr_Float4:	equ $3F
fr_Spring:	equ $40
fr_Hang1:	equ $41
fr_Hang2:	equ $42
fr_Leap1:	equ $43
fr_Leap2:	equ $44
fr_Push1:	equ $45
fr_Push2:	equ $46
fr_Push3:	equ $47
fr_Push4:	equ $48
fr_Surf:	equ $49
fr_BubStand:	equ $4A
fr_Burnt:	equ $4B
fr_Drown:	equ $4C
fr_Death:	equ $4D
fr_Shrink1:	equ $4E
fr_Shrink2:	equ $4F
fr_Shrink3:	equ $50
fr_Shrink4:	equ $51
fr_Shrink5:	equ $52
fr_Float5:	equ $53
fr_Float6:	equ $54
fr_Injury:	equ $55
fr_GetAir:	equ $56
fr_WaterSlide:	equ $57

; Boss locations
; The main values are based on where the camera boundaries mainly lie
; The end values are where the camera scrolls towards after defeat
boss_ghz_x:	equ $2960		; Green Hill Zone
boss_ghz_y:	equ $300
boss_ghz_end:	equ boss_ghz_x+$160

boss_lz_x:	equ $1DE0		; Labyrinth Zone
boss_lz_y:	equ $C0
boss_lz_end:	equ boss_lz_x+$250

boss_mz_x:	equ $1800		; Marble Zone
boss_mz_y:	equ $210
boss_mz_end:	equ boss_mz_x+$160

boss_slz_x:	equ $2000		; Star Light Zone
boss_slz_y:	equ $210
boss_slz_end:	equ boss_slz_x+$160

boss_syz_x:	equ $2C00		; Spring Yard Zone
boss_syz_y:	equ $4CC
boss_syz_end:	equ boss_syz_x+$140

boss_sbz2_x:	equ $2050		; Scrap Brain Zone Act 2 Cutscene
boss_sbz2_y:	equ $510

boss_fz_x:	equ $2450		; Final Zone
boss_fz_y:	equ $510
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
ArtTile_Bomb:					equ $455				; ✓

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
ArtTile_LZ_Blocks:				equ $39A				; ✓
ArtTile_LZ_Conveyor_Belt:		equ $3AA				; ✓
ArtTile_LZ_Push_Block:			equ $3DE				; ✓ -- Appears to be correct
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
;ArtTile_Dust:					equ $52B
ArtTile_Shield:					equ $53B				; ✓ A760
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

; Title Screen - This is fine as is.
ArtTile_Title_Foreground:		equ $200
ArtTile_Title_Sonic:			equ $300
ArtTile_Title_Trademark:		equ $510
ArtTile_Level_Select_Font:		equ $680

; Continue Screen
ArtTile_Continue_Sonic:			equ $500

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
ArtTile_SS_Bumper:				equ $23B
ArtTile_SS_Goal:				equ $251
ArtTile_SS_Up_Down:				equ $263
ArtTile_SS_R_Block:				equ $2F0
ArtTile_SS_Extra_Life:			equ $370
ArtTile_SS_Emerald_Sparkle:		equ $3F0
ArtTile_SS_Red_White_Block:		equ $470
ArtTile_SS_Ghost_Block:			equ $4F0
ArtTile_SS_W_Block:				equ $570
ArtTile_SS_Glass:				equ $5F0
ArtTile_SS_Emerald:				equ $770
ArtTile_SS_Zone_1:				equ $790				; ✓
ArtTile_SS_Ring:				equ $799				; ✓

; Special Stage Results
ArtTile_SS_Results_Emeralds:	equ $541

; Font
ArtTile_Sonic_Team_Font:		equ $0A6
ArtTile_Credits_Font:			equ $58C				; ✓
