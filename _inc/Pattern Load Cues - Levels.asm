; ---------------------------------------------------------------------------
; Level pattern load cues
; ---------------------------------------------------------------------------
LevelLoadCues:		offsetTable
ptr_PLC_GHZ:			offsetTableEntry.w PLC_GHZ
ptr_PLC_GHZ2:			offsetTableEntry.w PLC_GHZ2
ptr_PLC_LZ:				offsetTableEntry.w PLC_LZ
ptr_PLC_LZ2:			offsetTableEntry.w PLC_LZ2
ptr_PLC_MZ:				offsetTableEntry.w PLC_MZ
ptr_PLC_MZ2:			offsetTableEntry.w PLC_MZ2
ptr_PLC_SLZ:			offsetTableEntry.w PLC_SLZ
ptr_PLC_SLZ2:			offsetTableEntry.w PLC_SLZ2
ptr_PLC_SYZ:			offsetTableEntry.w PLC_SYZ
ptr_PLC_SYZ2:			offsetTableEntry.w PLC_SYZ2
ptr_PLC_SBZ:			offsetTableEntry.w PLC_SBZ
ptr_PLC_SBZ2:			offsetTableEntry.w PLC_SBZ2
			zonewarning LevelLoadCues,4

	if NewSBZ3LevelArt
ptr_PLC_SBZ3:			offsetTableEntry.w PLC_SBZ3
ptr_PLC_SBZ3_2:			offsetTableEntry.w PLC_SBZ3_2
	endif

; ---------------------------------------------------------------------------
; Pattern load cues - Green Hill
; ---------------------------------------------------------------------------
PLC_GHZ:	dc.w ((PLC_GHZ2-PLC_GHZ-2)/6)-1
		plcm	Nem_Stalk,			ArtTile_GHZ_Flower_Stalk		; flower stalk
		plcm	Nem_PplRock,		ArtTile_GHZ_Purple_Rock			; purple rock
		plcm	Nem_Crabmeat,		ArtTile_Crabmeat				; crabmeat enemy
		plcm	Nem_Buzz,			ArtTile_Buzz_Bomber				; buzz bomber enemy
		plcm	Nem_Chopper,		ArtTile_Chopper					; chopper enemy
		plcm	Nem_Newtron,		ArtTile_Newtron					; newtron enemy
		plcm	Nem_Motobug,		ArtTile_Moto_Bug				; motobug enemy
		plcm	Nem_Spikes,			ArtTile_Spikes					; spikes
		plcm	Nem_HSpring,		ArtTile_Spring_Horizontal		; horizontal spring
		plcm	Nem_VSpring,		ArtTile_Spring_Vertical			; vertical spring

PLC_GHZ2:	dc.w ((PLC_GHZ2end-PLC_GHZ2-2)/6)-1
		plcm	Nem_Swing,			ArtTile_GHZ_MZ_Swing			; swinging platform
		plcm	Nem_Bridge,			ArtTile_GHZ_Bridge				; bridge
		plcm	Nem_SpikePole,		ArtTile_GHZ_Spike_Pole			; spiked pole
		plcm	Nem_Ball,			ArtTile_GHZ_Giant_Ball			; giant ball
		plcm	Nem_GhzWall1,		ArtTile_GHZ_Smashable_Wall		; breakable wall
		plcm	Nem_GhzWall2,		ArtTile_GHZ_Edge_Wall			; normal wall
PLC_GHZ2end:
; ---------------------------------------------------------------------------
; Pattern load cues - Labyrinth
; ---------------------------------------------------------------------------
PLC_LZ:		dc.w ((PLC_LZ2-PLC_LZ-2)/6)-1
		plcm	Nem_LzBlock1,		ArtTile_LZ_Block_1				; block
		plcm	Nem_LzBlock2,		ArtTile_LZ_Block_2				; blocks
		plcm	Nem_Waterfall,		ArtTile_LZ_Waterfall			; waterfalls
		plcm	Nem_Splash,			ArtTile_Splash					; water splash -- Temporary location
		plcm	Nem_Water,			ArtTile_LZ_Water_Surface		; water surface
		plcm	Nem_LzSpikeBall,	ArtTile_LZ_Spikeball_Chain		; spiked ball
		plcm	Nem_FlapDoor,		ArtTile_LZ_Flapping_Door		; flapping door
		plcm	Nem_Bubbles,		ArtTile_LZ_Bubbles				; bubbles, numbers and bubbler
		plcm	Nem_LzBlock3,		ArtTile_LZ_Moving_Block			; 32x16 block
		plcm	Nem_LzDoor1,		ArtTile_LZ_Door					; vertical door
		plcm	Nem_LzSwitch,		ArtTile_Button					; switch
		plcm	Nem_Burrobot,		ArtTile_Burrobot				; burrobot enemy

PLC_LZ2:	dc.w ((PLC_LZ2end-PLC_LZ2-2)/6)-1
		plcm	Nem_LzPole,			ArtTile_LZ_Pole					; pole that breaks
		plcm	Nem_LzDoor2,		ArtTile_LZ_Blocks				; large horizontal door
		plcm	Nem_LzConvPtfm,		ArtTile_LZ_Conveyor_Ptfm		; conveyor platform
		plcm	Nem_Gargoyle,		ArtTile_LZ_Gargoyle				; gargoyle head
		plcm	Nem_LzPlatfm,		ArtTile_LZ_Rising_Platform		; rising platform
		plcm	Nem_Orbinaut,		ArtTile_Orbinaut				; orbinaut enemy
		plcm	Nem_Jaws,			ArtTile_Jaws					; jaws enemy
		plcm	Nem_Harpoon,		ArtTile_LZ_Harpoon				; harpoon
		plcm	Nem_Cork,			ArtTile_LZ_Cork					; cork block
		plcm	Nem_Spikes,			ArtTile_Spikes					; spikes
		plcm	Nem_HSpring,		ArtTile_Spring_Horizontal		; horizontal spring
		plcm	Nem_VSpring,		ArtTile_Spring_Vertical			; vertical spring
PLC_LZ2end:
; ---------------------------------------------------------------------------
; Pattern load cues - Marble
; ---------------------------------------------------------------------------
PLC_MZ:		dc.w ((PLC_MZ2-PLC_MZ-2)/6)-1
		plcm	Nem_MzMetal,		ArtTile_MZ_Spike_Stomper		; metal blocks
		plcm	Nem_Fireball,		ArtTile_Fireball				; fireballs
		plcm	Nem_Swing,			ArtTile_GHZ_MZ_Swing			; swinging platform
		plcm	Nem_MzGlass,		ArtTile_MZ_Glass_Pillar			; green glassy block
		plcm	Nem_Lava,			ArtTile_MZ_Lava					; lava
		plcm	Nem_Buzz,			ArtTile_Buzz_Bomber				; buzz bomber enemy
		plcm	Nem_Yadrin,			ArtTile_Yadrin					; yadrin enemy
		plcm	Nem_Basaran,		ArtTile_Basaran					; basaran enemy
		plcm	Nem_Cater,			ArtTile_Caterkiller				; caterkiller enemy

PLC_MZ2:	dc.w ((PLC_MZ2end-PLC_MZ2-2)/6)-1
		plcm	Nem_MzSwitch,		ArtTile_Button					; switch
		plcm	Nem_Spikes,			ArtTile_Spikes					; spikes
		plcm	Nem_HSpring,		ArtTile_Spring_Horizontal		; horizontal spring
		plcm	Nem_VSpring,		ArtTile_Spring_Vertical			; vertical spring
		plcm	Nem_MzBlock,		ArtTile_MZ_Block				; green stone block
PLC_MZ2end:
; ---------------------------------------------------------------------------
; Pattern load cues - Star Light
; ---------------------------------------------------------------------------
PLC_SLZ:	dc.w ((PLC_SLZ2-PLC_SLZ-2)/6)-1
		plcm	Nem_Bomb,			ArtTile_Bomb					; bomb enemy
		plcm	Nem_Orbinaut_SLZ,	ArtTile_Orbinaut				; orbinaut enemy
		plcm	Nem_Fireball,		ArtTile_Fireball				; fireballs
		plcm	Nem_SlzBlock,		ArtTile_SLZ_Collapsing_Floor	; block
		plcm	Nem_SlzWall,		ArtTile_SLZ_Smashable_Wall		; breakable wall
		plcm	Nem_Spikes,			ArtTile_Spikes					; spikes
		plcm	Nem_HSpring,		ArtTile_Spring_Horizontal		; horizontal spring
		plcm	Nem_VSpring,		ArtTile_Spring_Vertical			; vertical spring

PLC_SLZ2:	dc.w ((PLC_SLZ2end-PLC_SLZ2-2)/6)-1
		plcm	Nem_Seesaw,			ArtTile_SLZ_Seesaw				; seesaw
		plcm	Nem_Fan,			ArtTile_SLZ_Fan					; fan
		plcm	Nem_Pylon,			ArtTile_SLZ_Pylon				; foreground pylon
		plcm	Nem_SlzSwing,		ArtTile_SLZ_Swing				; swinging platform
		plcm	Nem_SlzCannon,		ArtTile_SLZ_Fireball_Launcher	; fireball launcher
		plcm	Nem_SlzSpike,		ArtTile_SLZ_Spikeball			; spikeball
PLC_SLZ2end:
; ---------------------------------------------------------------------------
; Pattern load cues - Spring Yard
; ---------------------------------------------------------------------------
PLC_SYZ:	dc.w ((PLC_SYZ2-PLC_SYZ-2)/6)-1
		plcm	Nem_Crabmeat,		ArtTile_Crabmeat				; crabmeat enemy
		plcm	Nem_Buzz,			ArtTile_Buzz_Bomber				; buzz bomber enemy
		plcm	Nem_Yadrin,			ArtTile_Yadrin					; yadrin enemy
		plcm	Nem_SyzSpike1,		ArtTile_SYZ_Big_Spikeball		; large spikeball	-- Moved to Queue 1; RetroKoH VRAM Reshuffle
		plcm	Nem_SyzSpike2,		ArtTile_SYZ_Spikeball_Chain		; small spikeball	-- Moved to Queue 1; RetroKoH VRAM Reshuffle
		plcm	Nem_Roller,			ArtTile_Roller					; roller enemy
		plcm	Nem_Splats,			ArtTile_Splats					; splats enemy

PLC_SYZ2:	dc.w ((PLC_SYZ2end-PLC_SYZ2-2)/6)-1
		plcm	Nem_Bumper,			ArtTile_SYZ_Bumper				; bumper
		plcm	Nem_Cater,			ArtTile_Caterkiller				; caterkiller enemy
		plcm	Nem_LzSwitch,		ArtTile_Button					; switch
		plcm	Nem_Spikes,			ArtTile_Spikes					; spikes
		plcm	Nem_HSpring,		ArtTile_Spring_Horizontal		; horizontal spring
		plcm	Nem_VSpring,		ArtTile_Spring_Vertical			; vertical spring
PLC_SYZ2end:
; ---------------------------------------------------------------------------
; Pattern load cues - Scrap Brain
; ---------------------------------------------------------------------------
PLC_SBZ:	dc.w ((PLC_SBZ2-PLC_SBZ-2)/6)-1
		plcm	Nem_Stomper,		ArtTile_SBZ_Moving_Block_Short	; moving platform and stomper
		plcm	Nem_SbzDoor1,		ArtTile_SBZ_Door				; door
		plcm	Nem_Girder,			ArtTile_SBZ_Girder				; girder
		plcm	Nem_BallHog,		ArtTile_Ball_Hog				; ball hog enemy
		plcm	Nem_SbzWheel1,		ArtTile_SBZ_Disc				; spot on large wheel
		plcm	Nem_SbzWheel2,		ArtTile_SBZ_Junction			; wheel that grabs Sonic
		plcm	Nem_SyzSpike1,		ArtTile_SYZ_Big_Spikeball		; large spikeball
		plcm	Nem_Cutter,			ArtTile_SBZ_Saw					; pizza cutter
		plcm	Nem_FlamePipe,		ArtTile_SBZ_Flamethrower		; flaming pipe
		plcm	Nem_SbzFloor,		ArtTile_SBZ_Collapsing_Floor	; collapsing floor
		plcm	Nem_SbzBlock,		ArtTile_SBZ_Vanishing_Block		; vanishing block

PLC_SBZ2:	dc.w ((PLC_SBZ2end-PLC_SBZ2-2)/6)-1
		plcm	Nem_Cater,			ArtTile_Caterkiller				; caterkiller enemy
		plcm	Nem_Bomb,			ArtTile_Bomb					; bomb enemy
		plcm	Nem_SlideFloor,		ArtTile_SBZ_Moving_Block_Long	; floor that slides away
		plcm	Nem_SbzDoor2,		ArtTile_SBZ_Horizontal_Door		; horizontal door
		plcm	Nem_Electric,		ArtTile_SBZ_Electric_Orb		; electric orb
		plcm	Nem_TrapDoor,		ArtTile_SBZ_Trap_Door			; trapdoor
		plcm	Nem_SbzFloor,		ArtTile_SBZ_Collapsing_Floor+4	; collapsing floor
		plcm	Nem_SpinPform,		ArtTile_SBZ_Spinning_Platform	; small spinning platform
		plcm	Nem_LzSwitch,		ArtTile_Button					; switch
		plcm	Nem_Spikes,			ArtTile_Spikes					; spikes
		plcm	Nem_HSpring,		ArtTile_Spring_Horizontal		; horizontal spring
		plcm	Nem_VSpring,		ArtTile_Spring_Vertical			; vertical spring
PLC_SBZ2end:

	if NewSBZ3LevelArt
; ---------------------------------------------------------------------------
; Pattern load cues - Scrap Brain Act 3 (New)
; ---------------------------------------------------------------------------
PLC_SBZ3:	dc.w ((PLC_SBZ3_2-PLC_SBZ3-2)/6)-1
		plcm	Nem_LzBlock1,		ArtTile_LZ_Block_1				; block
		plcm	Nem_LzBlock2,		ArtTile_LZ_Block_2				; blocks
		plcm	Nem_Waterfall,		ArtTile_LZ_Waterfall			; waterfalls
		plcm	Nem_Splash,			ArtTile_Splash					; water splash -- Temporary location
		plcm	Nem_Water,			ArtTile_LZ_Water_Surface		; water surface
		plcm	Nem_LzSpikeBall,	ArtTile_LZ_Spikeball_Chain		; spiked ball
		plcm	Nem_FlapDoor_SBZ3,	ArtTile_LZ_Flapping_Door		; flapping door
		plcm	Nem_Bubbles,		ArtTile_LZ_Bubbles				; bubbles, numbers and bubbler
		plcm	Nem_LzBlock3,		ArtTile_LZ_Moving_Block			; 32x16 block
		plcm	Nem_LzDoor1,		ArtTile_LZ_Door					; vertical door
		plcm	Nem_LzSwitch,		ArtTile_Button					; switch
		plcm	Nem_Burrobot_SBZ3,	ArtTile_Burrobot				; burrobot enemy

PLC_SBZ3_2:	dc.w ((PLC_SBZ3_2end-PLC_SBZ3_2-2)/6)-1
		plcm	Nem_LzPole,			ArtTile_LZ_Pole					; pole that breaks
		plcm	Nem_LzDoor2,		ArtTile_LZ_Blocks				; large horizontal door
		plcm	Nem_LzConvPtfm,		ArtTile_LZ_Conveyor_Ptfm		; conveyor platform
		plcm	Nem_Gargoyle,		ArtTile_LZ_Gargoyle				; gargoyle head
		plcm	Nem_LzPlatfm,		ArtTile_LZ_Rising_Platform		; rising platform
		plcm	Nem_Orbinaut_SBZ3,	ArtTile_Orbinaut				; orbinaut enemy
		plcm	Nem_Jaws_SBZ3,		ArtTile_Jaws					; jaws enemy
		plcm	Nem_Harpoon,		ArtTile_LZ_Harpoon				; harpoon
		plcm	Nem_Cork,			ArtTile_LZ_Cork					; cork block
		plcm	Nem_Spikes,			ArtTile_Spikes					; spikes
		plcm	Nem_HSpring,		ArtTile_Spring_Horizontal		; horizontal spring
		plcm	Nem_VSpring,		ArtTile_Spring_Vertical			; vertical spring
PLC_SBZ3_2end:
	endif

; ---------------------------------------------------------------------------
; Pattern load cue IDs
; ---------------------------------------------------------------------------
plcid_GHZ:			equ (ptr_PLC_GHZ-LevelLoadCues)/2			; 0
plcid_GHZ2:			equ (ptr_PLC_GHZ2-LevelLoadCues)/2			; 1
plcid_LZ:			equ (ptr_PLC_LZ-LevelLoadCues)/2			; 2
plcid_LZ2:			equ (ptr_PLC_LZ2-LevelLoadCues)/2			; 3
plcid_MZ:			equ (ptr_PLC_MZ-LevelLoadCues)/2			; 4
plcid_MZ2:			equ (ptr_PLC_MZ2-LevelLoadCues)/2			; 5
plcid_SLZ:			equ (ptr_PLC_SLZ-LevelLoadCues)/2			; 6
plcid_SLZ2:			equ (ptr_PLC_SLZ2-LevelLoadCues)/2			; 7
plcid_SYZ:			equ (ptr_PLC_SYZ-LevelLoadCues)/2			; 8
plcid_SYZ2:			equ (ptr_PLC_SYZ2-LevelLoadCues)/2			; 9
plcid_SBZ:			equ (ptr_PLC_SBZ-LevelLoadCues)/2			; $A
plcid_SBZ2:			equ (ptr_PLC_SBZ2-LevelLoadCues)/2			; $B

	if NewSBZ3LevelArt
plcid_SBZ3:			equ (ptr_PLC_SBZ3-LevelLoadCues)/2			; $C
plcid_SBZ3_2:		equ (ptr_PLC_SBZ3_2-LevelLoadCues)/2		; $D
	endif