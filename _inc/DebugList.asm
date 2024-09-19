; ---------------------------------------------------------------------------
; Debug	mode item lists - RetroKoH modified for a wider range of options, meant to closer match Sonic 1 iOS lists.
; Add a separate list for SPECIAL STAGE DEBUG
; ---------------------------------------------------------------------------
DebugList:
	dc.w .GHZ-DebugList
	dc.w .LZ-DebugList
	dc.w .MZ-DebugList
	dc.w .SLZ-DebugList
	dc.w .SYZ-DebugList
	dc.w .SBZ-DebugList
	zonewarning DebugList,2
	dc.w .Ending-DebugList

dbug:	macro map,object,subtype,frame,vram
	dc.l map+(object<<24)
	dc.b subtype,frame
	dc.w vram
	endm

standards:	macro
;			mappings		object				subtype	frame	VRAM setting
	dbug 	Map_Ring,		id_Rings,			0,		0,		make_art_tile(ArtTile_Ring,1,0)
	dbug	Map_Monitor,	id_Monitor,			6,		8,		make_art_tile(ArtTile_Monitor,0,0)				; Super Ring Monitor
	dbug	Map_Monitor,	id_Monitor,			4,		6,		make_art_tile(ArtTile_Monitor,0,0)				; Shield Monitor
	dbug	Map_Monitor,	id_Monitor,			5,		7,		make_art_tile(ArtTile_Monitor,0,0)				; Invincibility Monitor
	dbug	Map_Monitor,	id_Monitor,			3,		5,		make_art_tile(ArtTile_Monitor,0,0)				; Speed Shoes Monitor
	dbug	Map_Monitor,	id_Monitor,			2,		4,		make_art_tile(ArtTile_Monitor,0,0)				; Sonic Monitor
	dbug	Map_Monitor,	id_Monitor,			1,		3,		make_art_tile(ArtTile_Monitor,0,0)				; Eggman Monitor
	if ShieldsMode>1
	dbug	Map_Monitor,	id_Monitor,			7,		9,		make_art_tile(ArtTile_Monitor,0,0)				; Flame Shield Monitor
	dbug	Map_Monitor,	id_Monitor,			8,		$A,		make_art_tile(ArtTile_Monitor,0,0)				; Bubble Shield Monitor
	dbug	Map_Monitor,	id_Monitor,			9,		$B,		make_art_tile(ArtTile_Monitor,0,0)				; Lightning Shield Monitor
	dbug	Map_Monitor,	id_Monitor,			$A,		$C,		make_art_tile(ArtTile_Monitor,0,0)				; Test the NEW "S" Monitor
	dbug	Map_Monitor,	id_Monitor,			$B,		$D,		make_art_tile(ArtTile_Monitor,0,0)				; Test the NEW Goggles Monitor
	else
	dbug	Map_Monitor,	id_Monitor,			7,		9,		make_art_tile(ArtTile_Monitor,0,0)				; Test the NEW "S" Monitor
	dbug	Map_Monitor,	id_Monitor,			8,		$A,		make_art_tile(ArtTile_Monitor,0,0)				; Test the NEW Goggles Monitor
	endif
	dbug	Map_Spring,		id_Springs,			2,		0,		make_art_tile(ArtTile_Spring_Horizontal,1,0)	; Yellow Horizontal Spring
	dbug	Map_Spring,		id_Springs,			$12,	3,		make_art_tile(ArtTile_Spring_Vertical,1,0)		; Yellow Vertical Spring
	dbug	Map_Spring,		id_Springs,			0,		0,		make_art_tile(ArtTile_Spring_Horizontal,0,0)	; Red Horizontal Spring
	dbug	Map_Spring,		id_Springs,			$10,	3,		make_art_tile(ArtTile_Spring_Vertical,0,0)		; Red Vertical Spring
	dbug	Map_Lamp,		id_Lamppost,		1,		0,		make_art_tile(ArtTile_Lamppost,0,0)				; Lamppost
	dbug	Map_Spike,		id_Spikes,			0,		0,		make_art_tile(ArtTile_Spikes,0,0)				; Upward static spikes
	dbug	Map_Spike,		id_Spikes,			1,		0,		make_art_tile(ArtTile_Spikes,0,0)				; Upward moving spikes
	dbug	Map_Spike,		id_Spikes,			$10,	1,		make_art_tile(ArtTile_Spikes,0,0)				; Horizontal static spikes
	dbug	Map_Spike,		id_Spikes,			$12,	1,		make_art_tile(ArtTile_Spikes,0,0)				; Horizontal moving spikes
	dbug	Map_Spike,		id_Spikes,			$20,	2,		make_art_tile(ArtTile_Spikes,0,0)				; Upward static single spike
	dbug	Map_Spike,		id_Spikes,			$21,	2,		make_art_tile(ArtTile_Spikes,0,0)				; Upward moving single spike
	dbug	Map_Spike,		id_Spikes,			$50,	5,		make_art_tile(ArtTile_Spikes,0,0)				; Horizontal static single spike
	dbug	Map_Spike,		id_Spikes,			$52,	5,		make_art_tile(ArtTile_Spikes,0,0)				; Horizontal moving single spike
	dbug	Map_Spike,		id_Spikes,			$30,	3,		make_art_tile(ArtTile_Spikes,0,0)				; Static 3 wide spikes
	dbug	Map_Spike,		id_Spikes,			$31,	3,		make_art_tile(ArtTile_Spikes,0,0)				; Moving 3 wide spikes
	dbug	Map_Spike,		id_Spikes,			$40,	4,		make_art_tile(ArtTile_Spikes,0,0)				; Static 6 wide spikes
	dbug	Map_Spike,		id_Spikes,			$41,	4,		make_art_tile(ArtTile_Spikes,0,0)				; Moving 6 wide spikes
	dbug	Map_Invis,		id_Invisibarrier,	$11,	0,		make_art_tile(ArtTile_Monitor,0,1)				; Invisible Solid Block
	endm

.GHZ:
	dc.w (.GHZend-.GHZ-2)/8
;			mappings		object				subtype	frame	VRAM setting
	; Standard Objects
	standards
	; Badniks
	dbug	Map_Buzz,		id_BuzzBomber,		0,		0,		make_art_tile(ArtTile_Buzz_Bomber,0,0)			; Buzz Bomber badnik
	dbug	Map_Moto,		id_MotoBug,			0,		0,		make_art_tile(ArtTile_Moto_Bug,0,0)				; Motobug badnik
	dbug	Map_Chop,		id_Chopper,			0,		0,		make_art_tile(ArtTile_Chopper,0,0)				; Chopper badnik
	dbug	Map_Crab,		id_Crabmeat,		0,		0,		make_art_tile(ArtTile_Crabmeat,0,0)				; Crabmeat badnik
	dbug	Map_Newt,		id_Newtron,			1,		1,		make_art_tile(ArtTile_Newtron,1,0)				; Green Newtron badnik
	dbug	Map_Newt,		id_Newtron,			0,		1,		make_art_tile(ArtTile_Newtron,0,0)				; Blue Newtron badnik
	; Level Objects
	dbug	Map_GBall,		id_GiantBall,		0,		1,		make_art_tile(ArtTile_GHZ_Giant_Ball,2,0)		; Giant Ball
	dbug	Map_PRock,		id_PurpleRock,		0,		0,		make_art_tile(ArtTile_GHZ_Purple_Rock,3,0)		; Purple Rock
	dbug	Map_Bri,		id_Bridge,			8,		0,		make_art_tile(ArtTile_GHZ_Bridge,2,0)			; Bridge (Add subtypes and Debug Mappings)
	dbug	Map_Swing_GHZ,	id_SwingingPlatform, 5,		0,		make_art_tile(ArtTile_GHZ_MZ_Swing,2,0)			; Swing (Add subtypes and Debug Mappings)
	dbug	Map_Plat_GHZ,	id_BasicPlatform,	0,		0,		make_art_tile(ArtTile_Level,2,0)				; Basic Floating Platform
	dbug	Map_Plat_GHZ,	id_BasicPlatform,	3,		0,		make_art_tile(ArtTile_Level,2,0)				; Falling Platform
	dbug	Map_Plat_GHZ,	id_BasicPlatform,	1,		0,		make_art_tile(ArtTile_Level,2,0)				; Horizontally Moving Platform
	dbug	Map_Plat_GHZ,	id_BasicPlatform,	2,		0,		make_art_tile(ArtTile_Level,2,0)				; Vertically Moving Platform
	dbug	Map_Plat_GHZ,	id_BasicPlatform,	$A,		1,		make_art_tile(ArtTile_Level,2,0)				; Tall Moving Platform
	dbug	Map_Smash,		id_SmashWall,		0,		0,		make_art_tile(ArtTile_GHZ_Smashable_Wall,2,0)	; Smashable Wall (Left side)
	dbug	Map_Smash,		id_SmashWall,		1,		1,		make_art_tile(ArtTile_GHZ_Smashable_Wall,2,0)	; Smashable Wall (Middle)
	dbug	Map_Smash,		id_SmashWall,		2,		2,		make_art_tile(ArtTile_GHZ_Smashable_Wall,2,0)	; Smashable Wall (Right side)
	dbug	Map_Ledge,		id_CollapseLedge,	0,		0,		make_art_tile(ArtTile_Level,2,0)				; Cliff facing left
	dbug	Map_Ledge,		id_CollapseLedge,	1,		1,		make_art_tile(ArtTile_Level,2,0)				; Cliff facing right
	dbug	Map_Hel,		id_Helix,			8,		1,		make_art_tile(ArtTile_GHZ_Spike_Pole,2,0)		; Spiked Pole Helix
	; animals
	; Giant Ball
.GHZend:

.LZ:
	dc.w (.LZend-.LZ-2)/8
;			mappings		object				subtype	frame	VRAM setting
	; Standard Objects
	standards
	; Badniks
	dbug	Map_Jaws,		id_Jaws,			8,		0,		make_art_tile(ArtTile_Jaws,1,0)
	dbug	Map_Burro,		id_Burrobot,		0,		2,		make_art_tile(ArtTile_Burrobot,0,1)
	dbug	Map_Orb,		id_Orbinaut,		0,		0,		make_art_tile(ArtTile_Orbinaut,0,0)				; LZ Orbinaut
	dbug	Map_Orb,		id_Orbinaut,		2,		0,		make_art_tile(ArtTile_Orbinaut,1,0)				; SLZ Orbinaut
	; Level Objects
	dbug	Map_Bub,		id_Bubble,			$84,	$13,	make_art_tile(ArtTile_LZ_Bubbles,0,1)			; Bubble Spawner
	dbug	Map_Harp,		id_Harpoon,			0,		0,		make_art_tile(ArtTile_LZ_Harpoon,0,0)			; Vertical Harpoon
	dbug	Map_Harp,		id_Harpoon,			2,		3,		make_art_tile(ArtTile_LZ_Harpoon,0,0)			; Horizontal Harpoon
	dbug	Map_Gar,		id_Gargoyle,		0,		0,		make_art_tile(ArtTile_LZ_Gargoyle,2,0)			; Gargoyle
	dbug	Map_LConv,		id_LabyrinthConvey,	$7F,	0,		make_art_tile(ArtTile_LZ_Conveyor_Belt,0,0)		; Conveyor Belt Wheel
	dbug	Map_SBall,		id_SpikeBall,		$D5,	0,		make_art_tile(ArtTile_SYZ_Spikeball_Chain,0,0)	; Chained Spikeball (5 links, speed: 3, counter-clockwise)
	dbug	Map_Flap,		id_FlapDoor,		2,		0,		make_art_tile(ArtTile_LZ_Flapping_Door,2,0)		; Flapping Door
	dbug	Map_But,		id_Button,			0,		0,		make_art_tile(ArtTile_Button,0,0)				; Button
	dbug	Map_LBlock,		id_LabyrinthBlock,	$30,	3,		make_art_tile(ArtTile_LZ_Blocks,2,0)			; Solid Masked Block
	dbug	Map_MBlockLZ,	id_MovingBlock,		4,		0,		make_art_tile(ArtTile_LZ_Moving_Block,2,0)		; Small Moving Block
	dbug	Map_FBlock,		id_FloatingBlock,	$E0,	6,		make_art_tile(ArtTile_LZ_Door,2,0)				; Switch activated door
	dbug	Map_LBlock,		id_LabyrinthBlock,	$27,	2,		make_art_tile(ArtTile_LZ_Blocks,2,0)			; Cork
	dbug	Map_FBlock,		id_FloatingBlock,	$F0,	7,		make_art_tile(ArtTile_LZ_Door,2,0)				; Horizontal witch activated block door
	dbug	Map_LBlock,		id_LabyrinthBlock,	$13,	1,		make_art_tile(ArtTile_LZ_Blocks,2,0)			; Lifting Platform
	dbug	Map_Push,		id_PushBlock,		0,		0,		make_art_tile(ArtTile_LZ_Push_Block,2,0)		; Pushable Block
	dbug	Map_Push,		id_PushBlock,		$81,	1,		make_art_tile(ArtTile_LZ_Push_Block,2,0)		; Long Pushable Block
	dbug	Map_LBlock,		id_LabyrinthBlock,	5,		0,		make_art_tile(ArtTile_LZ_Blocks,2,0)			; Sinking Block (Only sinks when pushed)
	dbug	Map_LBlock,		id_LabyrinthBlock,	1,		0,		make_art_tile(ArtTile_LZ_Blocks,2,0)			; Sinking Block (Sinks when stood upon)
	dbug	Map_Pole,		id_Pole,			0,		0,		make_art_tile(ArtTile_LZ_Pole,2,0)				; Grabbable Pole
	dbug	Map_Stomp,		id_ScrapStomp,		$CB,	4,		make_art_tile(ArtTile_LZ_Block_2,2,0)			; SBZ3 Giant Platform
.LZend:

.MZ:
	dc.w (.MZend-.MZ-2)/8
;			mappings		object				subtype	frame	VRAM setting
	; Standard Objects
	standards
	; Badniks
	dbug	Map_Buzz,		id_BuzzBomber,		0,		0,		make_art_tile(ArtTile_Buzz_Bomber,0,0)
	dbug	Map_Cat,		id_Caterkiller,		0,		0,		make_art_tile(ArtTile_Caterkiller,1,0)
	dbug	Map_Bas,		id_Basaran,			0,		0,		make_art_tile(ArtTile_Basaran,0,0)
	dbug	Map_Yad,		id_Yadrin,			0,		0,		make_art_tile(ArtTile_Yadrin,1,0)
	; Level Objects
	dbug	Map_LGrass,		id_LargeGrass,		1,		0,		make_art_tile(ArtTile_Level,2,1)				; Large Grassy Platform (have 4 speeds that match Sonic 1 iOS)
	dbug	Map_LGrass,		id_LargeGrass,		$20,	2,		make_art_tile(ArtTile_Level,2,1)				; Narrow Grassy Platform (have 4 speeds that match Sonic 1 iOS)
	dbug	Map_LGrass,		id_LargeGrass,		$15,	1,		make_art_tile(ArtTile_Level,2,1)				; Grassy Platform that spawns fire.
	dbug	Map_Glass,		id_GlassBlock,		1,		0,		make_art_tile(ArtTile_MZ_Glass_Pillar,2,1)		; Moving Glass Block.
	dbug	Map_Glass,		id_GlassBlock,		$14,	2,		make_art_tile(ArtTile_MZ_Glass_Pillar,2,1)		; Glass Block that is activated by a switch.
	dbug	Map_CStom,		id_ChainStomp,		2,		0,		make_art_tile(ArtTile_MZ_Spike_Stomper,0,0)		; Spiked Chain Stomper (have more chain lengths available)
	dbug	Map_CStom,		id_ChainStomp, 		$23,	$A,		make_art_tile(ArtTile_MZ_Spike_Stomper,0,0)		; Chain Block Stomper (have more chain lengths available)
	dbug	Map_But,		id_Button,			0,		0,		make_art_tile(ArtTile_Button,2,0)				; Button
	dbug	Map_Push,		id_PushBlock,		0,		0,		make_art_tile(ArtTile_MZ_Block,2,0)				; Pushable Block
	dbug	Map_Push,		id_PushBlock,		$81,	1,		make_art_tile(ArtTile_MZ_Block,2,0)				; Long Pushable Block
	dbug	Map_Brick,		id_MarbleBrick,		0,		0,		make_art_tile(ArtTile_Level,2,0)				; Purple Brick
	dbug	Map_Brick,		id_MarbleBrick,		1,		0,		make_art_tile(ArtTile_Level,2,0)				; Purple Brick - Moving block
	dbug	Map_Brick,		id_MarbleBrick,		2,		0,		make_art_tile(ArtTile_Level,2,0)				; Purple Brick - Falling block
	dbug	Map_MBlock,		id_MovingBlock,		0,		0,		make_art_tile(ArtTile_MZ_Block,2,0)				; Moving Block
	dbug	Map_Fire,		id_LavaMaker,		0,		0,		make_art_tile(ArtTile_Fireball,0,0)				; Fireball Spawner - spawns upward, add downward one, and sideward one
	dbug	Map_Swing_GHZ,	id_SwingingPlatform, 5,		0,		make_art_tile(ArtTile_GHZ_MZ_Swing,2,0)			; Swing (Add subtypes and Debug Mappings)
	dbug	Map_Smab,		id_SmashBlock,		0,		0,		make_art_tile(ArtTile_MZ_Block,2,0)				; Smashable Block
	dbug	Map_MBlock,		id_MovingBlock,		2,		0,		make_art_tile(ArtTile_MZ_Block,2,0)				; Moving Block, activated by Sonic stepping on it.
	dbug	Map_LWall,		id_LavaWall,		0,		0,		make_art_tile(ArtTile_MZ_Lava,3,0)				; Moving Lava Wall
	dbug	Map_Geyser,		id_GeyserMaker,		1,		0,		make_art_tile(ArtTile_MZ_Lava,3,0)				; Lava Fall Spawner
	dbug	Map_CFlo,		id_CollapseFloor,	1,		0,		make_art_tile(ArtTile_MZ_Block,2,0)				; Collapsing Floor
; Lava Geyser Spawner
	dbug	Map_CStom,		id_SideStomp, 		0,		1,		make_art_tile(ArtTile_MZ_Spike_Stomper,0,0)		; Sideways Stomper
;	dbug	Map_UFO,	id_UFO,		$F1,	2,	ArtNem_UFO		; UFO Spawner* - Setting this will create a spawner, that will load Unc. art into the background. Setting it again will remove the UFOs.
.MZend:

.SLZ:
	dc.w (.SLZend-.SLZ-2)/8

;			mappings		object				subtype	frame	VRAM setting
	; Standard Objects
	standards
	; Badniks
	dbug	Map_Bomb,		id_Bomb,			0,		0,		make_art_tile(ArtTile_Bomb,0,0)					; Bomb Enemy
	dbug	Map_Orb,		id_Orbinaut,		0,		0,		make_art_tile(ArtTile_Orbinaut,0,0)				; LZ Orbinaut
	dbug	Map_Orb,		id_Orbinaut,		2,		0,		make_art_tile(ArtTile_Orbinaut,1,0)				; SLZ Orbinaut
	; Level Objects
	dbug	Map_Smash,		id_SmashWall,		0,		0,		make_art_tile(ArtTile_SLZ_Smashable_Wall,2,0)	; Smashable Wall
	dbug	Map_Fire,		id_LavaMaker,		0,		0,		make_art_tile(ArtTile_Fireball,0,0)				; Fireball Spawner - spawns upward, add downward one, and sideward one	
	dbug	Map_CFlo,		id_CollapseFloor,	0,		2,		make_art_tile(ArtTile_SLZ_Collapsing_Floor,2,0)	; Collapsing Floor
	dbug	Map_Stair,		id_Staircase,		0,		0,		make_art_tile(ArtTile_Level,2,0)				; Staircase (Activates when stood on)
							; Giant Stairs: id_FloatingBlock,	$58,59,5A,5B (Need a new object to put these together)
	dbug	Map_Plat_SLZ,	id_BasicPlatform,	0,		0,		make_art_tile(ArtTile_Level,2,0)				; Basic Floating Platform
	dbug	Map_Plat_SLZ,	id_BasicPlatform,	3,		0,		make_art_tile(ArtTile_Level,2,0)				; Falling Platform
	dbug	Map_Plat_SLZ,	id_BasicPlatform,	1,		0,		make_art_tile(ArtTile_Level,2,0)				; Horizontally Moving Platform
	dbug	Map_Plat_SLZ,	id_BasicPlatform,	2,		0,		make_art_tile(ArtTile_Level,2,0)				; Vertically Moving Platform
	dbug	Map_Elev,		id_Elevator,		0,		0,		make_art_tile(ArtTile_Level,2,0)				; Blue lights, moves up when stood on.
	dbug	Map_Elev,		id_Elevator,		$8A,	0,		make_art_tile(ArtTile_Level,2,0)				; Blue lights, Spawner
	dbug	Map_Swing_SLZ,	id_SwingingPlatform, 5,		0,		make_art_tile(ArtTile_SLZ_Swing,2,0)			; Spiked Swing Platform
	dbug	Map_Circ,		id_CirclingPlatform, 0,		0,		make_art_tile(ArtTile_Level,2,0)				; Small Rotating Platform
	dbug	Map_Seesaw,		id_Seesaw,			0,		0,		make_art_tile(ArtTile_SLZ_Seesaw,0,0)			; Seesaw (Spikeball is created upon spawn)
	dbug	Map_Fan,		id_Fan,				0,		0,		make_art_tile(ArtTile_SLZ_Fan,2,0)				; Fan - Blows periodically.
	dbug	Map_Fan,		id_Fan,				2,		1,		make_art_tile(ArtTile_SLZ_Fan,2,0)				; Fan - Blows constantly.
.SLZend:

.SYZ:
	dc.w (.SYZend-.SYZ-2)/8

;			mappings		object				subtype	frame	VRAM setting
	; Standard Objects
	standards
	; Badniks
	dbug	Map_Buzz,		id_BuzzBomber,		0,		0,		make_art_tile(ArtTile_Buzz_Bomber,0,0)				; Buzz Bomber badnik
	dbug	Map_Crab,		id_Crabmeat,		0,		0,		make_art_tile(ArtTile_Crabmeat,0,0)					; Crabmeat badnik
	dbug	Map_Yad,		id_Yadrin,			0,		0,		make_art_tile(ArtTile_Yadrin,1,0)					; Yadrin badnik
	dbug	Map_Cat,		id_Caterkiller,		0,		0,		make_art_tile(ArtTile_Caterkiller,1,0)				; Caterkiller badnik
	dbug	Map_Roll,		id_Roller,			0,		0,		make_art_tile(ArtTile_Roller,0,0)					; Roller badnik
	dbug	Map_Splats,		id_Splats,			0,		0,		make_art_tile(ArtTile_Splats,0,0)					; Splats badnik
	; Level Objects
	dbug	Map_FBlock,		id_FloatingBlock,	0,		0,		make_art_tile(ArtTile_Level,2,0)
	dbug	Map_Bump,		id_Bumper,			0,		0,		make_art_tile(ArtTile_SYZ_Bumper,0,0)				; Bumper
	dbug	Map_Light,		id_SpinningLight,	0,		0,		make_art_tile(ArtTile_Level,0,0)					; Light Animation
	dbug	Map_Plat_SYZ,	id_BasicPlatform,	0,		0,		make_art_tile(ArtTile_Level,2,0)					; Basic Floating Platform
	dbug	Map_Plat_SYZ,	id_BasicPlatform,	3,		0,		make_art_tile(ArtTile_Level,2,0)					; Falling Platform
	dbug	Map_Plat_SYZ,	id_BasicPlatform,	1,		0,		make_art_tile(ArtTile_Level,2,0)					; Horizontally Moving Platform
	dbug	Map_Plat_SYZ,	id_BasicPlatform,	2,		0,		make_art_tile(ArtTile_Level,2,0)					; Vertically Moving Platform
	dbug	Map_But,		id_Button,			0,		0,		make_art_tile(ArtTile_Button,0,0)					; Button
.SYZend:

.SBZ:
	dc.w (.SBZend-.SBZ-2)/8

;			mappings		object				subtype	frame	VRAM setting
	; Standard Objects 
	standards
	; Badniks
	dbug	Map_Cat,		id_Caterkiller,		0,		0,		make_art_tile(ArtTile_Caterkiller,1,0)				; Caterkiller badnik
	dbug	Map_Bomb,		id_Bomb,			0,		0,		make_art_tile(ArtTile_Bomb,0,0)						; Bomb badnik
; Can we add Orbinauts?
	dbug	Map_Hog,		id_BallHog,			4,		0,		make_art_tile(ArtTile_Ball_Hog,1,0)					; Ball Hog badnik
	; Level Objects
	dbug	Map_But,		id_Button,			0,		0,		make_art_tile(ArtTile_Button,0,0)					; Button
	dbug	Map_CFlo,		id_CollapseFloor,	0,		0,		make_art_tile(ArtTile_SBZ_Collapsing_Floor,2,0)		; Collapsing Floor
	dbug	Map_Elec,		id_Electro,			4,		0,		make_art_tile(ArtTile_SBZ_Electric_Orb,0,0)			; Electrocuter
	dbug	Map_Jun,		id_Junction,		0,		0,		make_art_tile(ArtTile_SBZ_Junction,2,0)				; Rotating Junction
	dbug	Map_Gird,		id_Girder,			0,		0,		make_art_tile(ArtTile_SBZ_Girder,2,0)				; Solid Moving Girder
	dbug	Map_Stomp,		id_ScrapStomp,		0,		0,		make_art_tile(ArtTile_SBZ_Moving_Block_Short,1,0)	; Thin Metal Moving Block
	dbug	Map_MBlock,		id_MovingBlock,		$39,	3,		make_art_tile(ArtTile_SBZ_Moving_Block_Long,2,0)	; Red Sideways Moving Platform (Moves into the wall when stood upon)
	dbug	Map_ADoor,		id_AutoDoor,		0,		0,		make_art_tile(ArtTile_SBZ_Door,2,0)					; One Way Door
; New Holowall object?
	dbug	Map_Spin,		id_SpinPlatform,	$83,	0,		make_art_tile(ArtTile_SBZ_Spinning_Platform,0,0)	; Spinning Solid Platform
	dbug	Map_VanP,		id_VanishPlatform,	0,		0,		make_art_tile(ArtTile_SBZ_Vanishing_Block,2,0)		; Vanishing Platform
	dbug	Map_Trap,		id_SpinPlatform,	3,		0,		make_art_tile(ArtTile_SBZ_Trap_Door,2,0)			; Flapping Trap Door
	dbug	Map_Flame,		id_Flamethrower,	$64,	0,		make_art_tile(ArtTile_SBZ_Flamethrower,0,1)			; Flamethrower (Broken Pipe)
	dbug	Map_Flame,		id_Flamethrower,	$64,	$B,		make_art_tile(ArtTile_SBZ_Flamethrower,0,1)			; Flamethrower (Proper)
	dbug	Map_BBall,		id_SwingingPlatform, 7,		2,		make_art_tile(ArtTile_SYZ_Big_Spikeball,2,0)		; Swinging Spikeball
	dbug	Map_Saw,		id_Saws,			1,		0,		make_art_tile(ArtTile_SBZ_Saw,2,0)					; Sideways moving pizza cutter
	dbug	Map_Saw,		id_Saws,			2,		0,		make_art_tile(ArtTile_SBZ_Saw,2,0)					; Vertical Pizza Cutter
	dbug	Map_Saw,		id_Saws,			4,		2,		make_art_tile(ArtTile_SBZ_Saw,2,0)					; Ambushing Sawblade (Right to left)
	dbug	Map_Stomp,		id_ScrapStomp,		$13,	1,		make_art_tile(ArtTile_SBZ_Moving_Block_Short,1,0)	; Stomper (This one zips up, then moves back down slowly)
	dbug	Map_Stomp,		id_ScrapStomp,		$24,	1,		make_art_tile(ArtTile_SBZ_Moving_Block_Short,1,0)	; Stomper (Back and Forth Rapid Movement)
	dbug	Map_Stomp,		id_ScrapStomp,		$34,	1,		make_art_tile(ArtTile_SBZ_Moving_Block_Short,1,0)	; Stomper (Back and Forth Movement)
	dbug	Map_Disc,		id_RunningDisc,		$E0,	0,		make_art_tile(ArtTile_SBZ_Disc,2,1)					; Convex Wheel Object
	dbug	Map_MBlock,		id_MovingBlock,		$28,	2,		make_art_tile(ArtTile_SBZ_Moving_Block_Short,1,0)	; Up/Down Platform
.SBZend:

.Ending:
	dc.w (.Endingend-.Ending-2)/8

;			mappings		object				subtype	frame	VRAM setting
	dbug 	Map_Ring,		id_Rings,			0,		0,		make_art_tile(ArtTile_Ring,1,0)
.Endingend:

	even