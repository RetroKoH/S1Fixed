; ---------------------------------------------------------------------------
; Pattern load cues
; ---------------------------------------------------------------------------
ArtLoadCues:

ptr_PLC_Main:			dc.w PLC_Main-ArtLoadCues
ptr_PLC_Main2:			dc.w PLC_Main2-ArtLoadCues
ptr_PLC_Explode:		dc.w PLC_Explode-ArtLoadCues
ptr_PLC_GameOver:		dc.w PLC_GameOver-ArtLoadCues

PLC_Levels:
ptr_PLC_GHZ:			dc.w PLC_GHZ-ArtLoadCues
ptr_PLC_GHZ2:			dc.w PLC_GHZ2-ArtLoadCues
ptr_PLC_LZ:				dc.w PLC_LZ-ArtLoadCues
ptr_PLC_LZ2:			dc.w PLC_LZ2-ArtLoadCues
ptr_PLC_MZ:				dc.w PLC_MZ-ArtLoadCues
ptr_PLC_MZ2:			dc.w PLC_MZ2-ArtLoadCues
ptr_PLC_SLZ:			dc.w PLC_SLZ-ArtLoadCues
ptr_PLC_SLZ2:			dc.w PLC_SLZ2-ArtLoadCues
ptr_PLC_SYZ:			dc.w PLC_SYZ-ArtLoadCues
ptr_PLC_SYZ2:			dc.w PLC_SYZ2-ArtLoadCues
ptr_PLC_SBZ:			dc.w PLC_SBZ-ArtLoadCues
ptr_PLC_SBZ2:			dc.w PLC_SBZ2-ArtLoadCues
			zonewarning PLC_Levels,4

	if NewSBZ3LevelArt
ptr_PLC_SBZ3:			dc.w PLC_SBZ3-ArtLoadCues
ptr_PLC_SBZ3_2:			dc.w PLC_SBZ3_2-ArtLoadCues
	endif

ptr_PLC_Boss:			dc.w PLC_Boss-ArtLoadCues
ptr_PLC_Boss_GHZ:		dc.w PLC_Boss_GHZ-ArtLoadCues
ptr_PLC_Boss_MZ:		dc.w PLC_Boss_MZ-ArtLoadCues
ptr_PLC_Boss_SYZ:		dc.w PLC_Boss_SYZ-ArtLoadCues
ptr_PLC_Boss_SLZ:		dc.w PLC_Boss_SLZ-ArtLoadCues
ptr_PLC_Signpost:		dc.w PLC_Signpost-ArtLoadCues
ptr_PLC_SpecialStage:	dc.w PLC_SpecialStage-ArtLoadCues

PLC_Animals:
ptr_PLC_GHZAnimals:		dc.w PLC_GHZAnimals-ArtLoadCues
ptr_PLC_LZAnimals:		dc.w PLC_LZAnimals-ArtLoadCues
ptr_PLC_MZAnimals:		dc.w PLC_MZAnimals-ArtLoadCues
ptr_PLC_SLZAnimals:		dc.w PLC_SLZAnimals-ArtLoadCues
ptr_PLC_SYZAnimals:		dc.w PLC_SYZAnimals-ArtLoadCues
ptr_PLC_SBZAnimals:		dc.w PLC_SBZAnimals-ArtLoadCues
			zonewarning PLC_Animals,2

ptr_PLC_SSResult:		dc.w PLC_SSResult-ArtLoadCues
ptr_PLC_Ending:			dc.w PLC_Ending-ArtLoadCues
ptr_PLC_TryAgain:		dc.w PLC_TryAgain-ArtLoadCues
ptr_PLC_EggmanSBZ2:		dc.w PLC_EggmanSBZ2-ArtLoadCues
ptr_PLC_FZBoss:			dc.w PLC_FZBoss-ArtLoadCues

plcm:	macro gfx,vram
	dc.l gfx
	dc.w (vram)*$20
	endm

; ---------------------------------------------------------------------------
; Pattern load cues - standard block 1
; ---------------------------------------------------------------------------
PLC_Main:	dc.w ((PLC_Mainend-PLC_Main-2)/6)-1
		plcm	Nem_Hud,			ArtTile_HUD						; HUD
		plcm	Nem_Lives,			ArtTile_Lives_Counter			; lives counter
PLC_Mainend:
; ---------------------------------------------------------------------------
; Pattern load cues - standard block 2
; ---------------------------------------------------------------------------
PLC_Main2:	dc.w ((PLC_Main2end-PLC_Main2-2)/6)-1
		plcm	Nem_Lamp,			ArtTile_Lamppost				; lamppost
		plcm	Nem_Ring,			ArtTile_Ring					; rings	-- Moved here to load over the title card
		plcm	Nem_Monitors,		ArtTile_Monitor					; monitors
		plcm	Nem_Points,			ArtTile_Points					; points from enemy
PLC_Main2end:
; ---------------------------------------------------------------------------
; Pattern load cues - explosion
; ---------------------------------------------------------------------------
PLC_Explode:	dc.w ((PLC_Explodeend-PLC_Explode-2)/6)-1
		plcm	Nem_Explode,		ArtTile_Explosion				; explosion
PLC_Explodeend:
; ---------------------------------------------------------------------------
; Pattern load cues - game over
; ---------------------------------------------------------------------------
PLC_GameOver:	dc.w ((PLC_GameOverend-PLC_GameOver-2)/6)-1
		plcm	Nem_GameOver,		ArtTile_Game_Over				; game over
PLC_GameOverend:
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
		plcm	Nem_LzWheel,		ArtTile_LZ_Conveyor_Belt		; wheel
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
		plcm	Nem_LzWheel,		ArtTile_LZ_Conveyor_Belt		; wheel
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
; Pattern load cues - LZ act 3 boss -- RetroKoH VRAM Overhaul
; ---------------------------------------------------------------------------
PLC_Boss:	dc.w ((PLC_Bossend-PLC_Boss-2)/6)-1
		plcm	Nem_Eggman,			ArtTile_Eggman					; Eggman main patterns
		plcm	Nem_Prison,			ArtTile_Prison_Capsule			; prison capsule
		plcm	Nem_Exhaust,		ArtTile_Eggman_Exhaust			; exhaust flame
PLC_Bossend:
; ---------------------------------------------------------------------------
; Pattern load cues - GHZ act 3 boss -- RetroKoH VRAM Overhaul
; ---------------------------------------------------------------------------
PLC_Boss_GHZ:	dc.w ((PLC_Boss_GHZend-PLC_Boss_GHZ-2)/6)-1
		plcm	Nem_Eggman,			ArtTile_Eggman					; Eggman main patterns
		plcm	Nem_Weapons_GHZ,	ArtTile_Eggman_Weapons			; Eggman's chain base (6 tiles)
		plcm	Nem_Prison,			ArtTile_Prison_Capsule			; prison capsule
		plcm	Nem_Exhaust,		ArtTile_Eggman_Exhaust			; exhaust flame
PLC_Boss_GHZend:
; ---------------------------------------------------------------------------
; Pattern load cues - MZ act 3 boss -- RetroKoH VRAM Overhaul
; ---------------------------------------------------------------------------
PLC_Boss_MZ:	dc.w ((PLC_Boss_MZend-PLC_Boss_MZ-2)/6)-1
		plcm	Nem_Eggman,			ArtTile_Eggman					; Eggman main patterns
		plcm	Nem_Weapons_MZ,		ArtTile_Eggman_Weapons			; Eggman's lava cannon (4 tiles)
		plcm	Nem_Prison,			ArtTile_Prison_Capsule			; prison capsule
		plcm	Nem_Exhaust,		ArtTile_Eggman_Exhaust			; exhaust flame
PLC_Boss_MZend:
; ---------------------------------------------------------------------------
; Pattern load cues - SYZ act 3 boss -- RetroKoH VRAM Overhaul
; ---------------------------------------------------------------------------
PLC_Boss_SYZ:	dc.w ((PLC_Boss_SYZend-PLC_Boss_SYZ-2)/6)-1
		plcm	Nem_Eggman,			ArtTile_Eggman					; Eggman main patterns
		plcm	Nem_Weapons_SYZ,	ArtTile_Eggman_Weapons			; Eggman's spiker (5 tiles)
		plcm	Nem_Prison,			ArtTile_Prison_Capsule			; prison capsule
		plcm	Nem_Exhaust,		ArtTile_Eggman_Exhaust			; exhaust flame
PLC_Boss_SYZend:
; ---------------------------------------------------------------------------
; Pattern load cues - SLZ act 3 boss -- RetroKoH VRAM Overhaul
; ---------------------------------------------------------------------------
PLC_Boss_SLZ:	dc.w ((PLC_Boss_SLZend-PLC_Boss_SLZ-2)/6)-1
		plcm	Nem_Eggman,			ArtTile_Eggman					; Eggman main patterns
		plcm	Nem_Weapons_SLZ,	ArtTile_Eggman_Weapons			; Eggman's weapons (6 tiles)
		plcm	Nem_Prison,			ArtTile_Prison_Capsule			; prison capsule
		plcm	Nem_Exhaust,		ArtTile_Eggman_Exhaust			; exhaust flame
PLC_Boss_SLZend:
; ---------------------------------------------------------------------------
; Pattern load cues - act 1/2 signpost -- RetroKoH VRAM Overhaul
; ---------------------------------------------------------------------------
PLC_Signpost:	dc.w ((PLC_Signpostend-PLC_Signpost-2)/6)-1
		plcm	Nem_Bonus,			ArtTile_Hidden_Points			; hidden bonus points
PLC_Signpostend:
; ---------------------------------------------------------------------------
; Pattern load cues - special stage
; ---------------------------------------------------------------------------
PLC_SpecialStage:	dc.w ((PLC_SpeStageend-PLC_SpecialStage-2)/6)-1
		plcm	Nem_SSBgCloud,  ArtTile_SS_Background_Clouds ; bubble and cloud background
		plcm	Nem_SSBgFish,   ArtTile_SS_Background_Fish   ; bird and fish background

	if DynamicSpecialStageWalls=1	; Mercury Dynamic Special Stage Walls
		plcm	Nem_Hud,		ArtTile_SS_HUD					; HUD
		plcm	Nem_Lives,		ArtTile_SS_Lives				; lives
	else
		plcm	Nem_SSWalls,	ArtTile_SS_Wall					; walls
	endif	; Dynamic Special Stage Walls End

		plcm	Nem_Bumper,     ArtTile_SS_Bumper				; bumper
		plcm	Nem_SSGOAL,     ArtTile_SS_Goal					; GOAL block
		plcm	Nem_SSUpDown,   ArtTile_SS_Up_Down				; UP and DOWN blocks
		plcm	Nem_SSRBlock,   ArtTile_SS_R_Block				; R block
		plcm	Nem_SS1UpBlock, ArtTile_SS_Extra_Life			; 1UP block
		plcm	Nem_SSEmStars,  ArtTile_SS_Emerald_Sparkle		; emerald collection stars
		plcm	Nem_SSRedWhite, ArtTile_SS_Red_White_Block		; red and white block
		plcm	Nem_SSGhost,    ArtTile_SS_Ghost_Block			; ghost block
		plcm	Nem_SSWBlock,   ArtTile_SS_W_Block				; W block
		plcm	Nem_SSGlass,    ArtTile_SS_Glass				; glass block
		plcm	Nem_SSEmerald,  ArtTile_SS_Emerald				; emeralds
;		plcm	Nem_SSZone1,    ArtTile_SS_Zone_1				; ZONE X block
		plcm	Nem_Ring,		ArtTile_SS_Ring					; Rings	-- RetroKoH VRAM Overhaul
PLC_SpeStageend:
; ---------------------------------------------------------------------------
; Pattern load cues - GHZ animals
; ---------------------------------------------------------------------------
PLC_GHZAnimals:	dc.w ((PLC_GHZAnimalsend-PLC_GHZAnimals-2)/6)-1
		plcm	Nem_Rabbit, ArtTile_Animal_1 ; rabbit
		plcm	Nem_Flicky, ArtTile_Animal_2 ; flicky
PLC_GHZAnimalsend:
; ---------------------------------------------------------------------------
; Pattern load cues - LZ animals
; ---------------------------------------------------------------------------
PLC_LZAnimals:	dc.w ((PLC_LZAnimalsend-PLC_LZAnimals-2)/6)-1
		plcm	Nem_Penguin, ArtTile_Animal_1 ; penguin
		plcm	Nem_Seal,    ArtTile_Animal_2 ; seal
PLC_LZAnimalsend:
; ---------------------------------------------------------------------------
; Pattern load cues - MZ animals
; ---------------------------------------------------------------------------
PLC_MZAnimals:	dc.w ((PLC_MZAnimalsend-PLC_MZAnimals-2)/6)-1
		plcm	Nem_Squirrel, ArtTile_Animal_1 ; squirrel
		plcm	Nem_Seal,     ArtTile_Animal_2 ; seal
PLC_MZAnimalsend:
; ---------------------------------------------------------------------------
; Pattern load cues - SLZ animals
; ---------------------------------------------------------------------------
PLC_SLZAnimals:	dc.w ((PLC_SLZAnimalsend-PLC_SLZAnimals-2)/6)-1
		plcm	Nem_Pig,    ArtTile_Animal_1 ; pig
		plcm	Nem_Flicky, ArtTile_Animal_2 ; flicky
PLC_SLZAnimalsend:
; ---------------------------------------------------------------------------
; Pattern load cues - SYZ animals
; ---------------------------------------------------------------------------
PLC_SYZAnimals:	dc.w ((PLC_SYZAnimalsend-PLC_SYZAnimals-2)/6)-1
		plcm	Nem_Pig,     ArtTile_Animal_1 ; pig
		plcm	Nem_Chicken, ArtTile_Animal_2 ; chicken
PLC_SYZAnimalsend:
; ---------------------------------------------------------------------------
; Pattern load cues - SBZ animals
; ---------------------------------------------------------------------------
PLC_SBZAnimals:	dc.w ((PLC_SBZAnimalsend-PLC_SBZAnimals-2)/6)-1
		plcm	Nem_Rabbit,  ArtTile_Animal_1 ; rabbit
		plcm	Nem_Chicken, ArtTile_Animal_2 ; chicken
PLC_SBZAnimalsend:
; ---------------------------------------------------------------------------
; Pattern load cues - special stage results screen
; ---------------------------------------------------------------------------
PLC_SSResult:dc.w ((PLC_SpeStResultend-PLC_SSResult-2)/6)-1
		plcm	Nem_ResultEm,  ArtTile_SS_Results_Emeralds ; emeralds
		plcm	Nem_MiniSonic, ArtTile_Mini_Sonic          ; mini Sonic
PLC_SpeStResultend:
; ---------------------------------------------------------------------------
; Pattern load cues - ending sequence
; ---------------------------------------------------------------------------
PLC_Ending:	dc.w ((PLC_Endingend-PLC_Ending-2)/6)-1
		plcm	Nem_Stalk,     ArtTile_GHZ_Flower_Stalk ; flower stalk (4)
		plcm	Nem_EndFlower, ArtTile_Ending_Flowers   ; flowers (37)
		plcm	Nem_EndEm,     ArtTile_Ending_Emeralds  ; emeralds (28)
		plcm	Nem_EndSonic,  ArtTile_Ending_Sonic     ; Sonic (323)
		plcm	Nem_Rabbit,    ArtTile_Ending_Rabbit    ; rabbit (18)
		plcm	Nem_Chicken,   ArtTile_Ending_Chicken   ; chicken (14)
		plcm	Nem_Penguin,   ArtTile_Ending_Penguin   ; penguin (18)
		plcm	Nem_Seal,      ArtTile_Ending_Seal      ; seal (14)
		plcm	Nem_Pig,       ArtTile_Ending_Pig       ; pig (18)
		plcm	Nem_Flicky,    ArtTile_Ending_Flicky    ; flicky (14)
		plcm	Nem_Squirrel,  ArtTile_Ending_Squirrel  ; squirrel (18)
		plcm	Nem_EndStH,    ArtTile_Ending_STH       ; "SONIC THE HEDGEHOG" (48)
PLC_Endingend:
; ---------------------------------------------------------------------------
; Pattern load cues - "TRY AGAIN" and "END" screens
; ---------------------------------------------------------------------------
PLC_TryAgain:	dc.w ((PLC_TryAgainend-PLC_TryAgain-2)/6)-1
		plcm	Nem_EndEm,      ArtTile_Try_Again_Emeralds ; emeralds
		plcm	Nem_TryAgain,   ArtTile_Try_Again_Eggman   ; Eggman
		plcm	Nem_CreditText, ArtTile_Credits_Font       ; credits alphabet
PLC_TryAgainend:
; ---------------------------------------------------------------------------
; Pattern load cues - Eggman on SBZ 2
; ---------------------------------------------------------------------------
PLC_EggmanSBZ2:	dc.w ((PLC_EggmanSBZ2end-PLC_EggmanSBZ2-2)/6)-1
		plcm	Nem_SbzBlock,   ArtTile_Eggman_Trap_Floor	; block
		plcm	Nem_Sbz2Eggman, ArtTile_Eggman				; Eggman
		plcm	Nem_LzSwitch,   ArtTile_Eggman_Button		; switch
PLC_EggmanSBZ2end:
; ---------------------------------------------------------------------------
; Pattern load cues - final boss
; ---------------------------------------------------------------------------
PLC_FZBoss:	dc.w ((PLC_FZBossend-PLC_FZBoss-2)/6)-1
		plcm	Nem_FzEggman,   ArtTile_FZ_Eggman_Fleeing    ; Eggman after boss
		plcm	Nem_FzBoss,     ArtTile_FZ_Boss              ; FZ boss
		plcm	Nem_Eggman,     ArtTile_Eggman               ; Eggman main patterns
		plcm	Nem_Sbz2Eggman, ArtTile_FZ_Eggman_No_Vehicle ; Eggman without ship
		plcm	Nem_Exhaust,    ArtTile_Eggman_Exhaust       ; exhaust flame
PLC_FZBossend:

; ---------------------------------------------------------------------------
; Pattern load cue IDs
; ---------------------------------------------------------------------------
plcid_Main:			equ (ptr_PLC_Main-ArtLoadCues)/2			; 0
plcid_Main2:		equ (ptr_PLC_Main2-ArtLoadCues)/2			; 1
plcid_Explode:		equ (ptr_PLC_Explode-ArtLoadCues)/2			; 2
plcid_GameOver:		equ (ptr_PLC_GameOver-ArtLoadCues)/2		; 3
plcid_GHZ:			equ (ptr_PLC_GHZ-ArtLoadCues)/2				; 4
plcid_GHZ2:			equ (ptr_PLC_GHZ2-ArtLoadCues)/2			; 5
plcid_LZ:			equ (ptr_PLC_LZ-ArtLoadCues)/2				; 6
plcid_LZ2:			equ (ptr_PLC_LZ2-ArtLoadCues)/2				; 7
plcid_MZ:			equ (ptr_PLC_MZ-ArtLoadCues)/2				; 8
plcid_MZ2:			equ (ptr_PLC_MZ2-ArtLoadCues)/2				; 9
plcid_SLZ:			equ (ptr_PLC_SLZ-ArtLoadCues)/2				; $A
plcid_SLZ2:			equ (ptr_PLC_SLZ2-ArtLoadCues)/2			; $B
plcid_SYZ:			equ (ptr_PLC_SYZ-ArtLoadCues)/2				; $C
plcid_SYZ2:			equ (ptr_PLC_SYZ2-ArtLoadCues)/2			; $D
plcid_SBZ:			equ (ptr_PLC_SBZ-ArtLoadCues)/2				; $E
plcid_SBZ2:			equ (ptr_PLC_SBZ2-ArtLoadCues)/2			; $F

	if NewSBZ3LevelArt
plcid_SBZ3:			equ (ptr_PLC_SBZ3-ArtLoadCues)/2
plcid_SBZ3_2:		equ (ptr_PLC_SBZ3_2-ArtLoadCues)/2
	endif

plcid_Boss:			equ (ptr_PLC_Boss-ArtLoadCues)/2			; $11
plcid_Boss_GHZ:		equ (ptr_PLC_Boss_GHZ-ArtLoadCues)/2		; NEW
plcid_Boss_MZ:		equ (ptr_PLC_Boss_MZ-ArtLoadCues)/2			; NEW
plcid_Boss_SYZ:		equ (ptr_PLC_Boss_SYZ-ArtLoadCues)/2		; NEW
plcid_Boss_SLZ:		equ (ptr_PLC_Boss_SLZ-ArtLoadCues)/2		; NEW
plcid_Signpost:		equ (ptr_PLC_Signpost-ArtLoadCues)/2		; $12
plcid_SpecialStage:	equ (ptr_PLC_SpecialStage-ArtLoadCues)/2	; $14
plcid_GHZAnimals:	equ (ptr_PLC_GHZAnimals-ArtLoadCues)/2		; $15
plcid_LZAnimals:	equ (ptr_PLC_LZAnimals-ArtLoadCues)/2		; $16
plcid_MZAnimals:	equ (ptr_PLC_MZAnimals-ArtLoadCues)/2		; $17
plcid_SLZAnimals:	equ (ptr_PLC_SLZAnimals-ArtLoadCues)/2		; $18
plcid_SYZAnimals:	equ (ptr_PLC_SYZAnimals-ArtLoadCues)/2		; $19
plcid_SBZAnimals:	equ (ptr_PLC_SBZAnimals-ArtLoadCues)/2		; $1A
plcid_SSResult:		equ (ptr_PLC_SSResult-ArtLoadCues)/2		; $1B
plcid_Ending:		equ (ptr_PLC_Ending-ArtLoadCues)/2			; $1C
plcid_TryAgain:		equ (ptr_PLC_TryAgain-ArtLoadCues)/2		; $1D
plcid_EggmanSBZ2:	equ (ptr_PLC_EggmanSBZ2-ArtLoadCues)/2		; $1E
plcid_FZBoss:		equ (ptr_PLC_FZBoss-ArtLoadCues)/2			; $1F
