; ---------------------------------------------------------------------------
; Special Stage Debug mode item lists - (RetroKoH)
; ---------------------------------------------------------------------------

sdbug:	macro map,object,frame,vram
	dc.l map+(object<<24)
	dc.b object,frame
	dc.w vram
	endm

DebugList_Special:
	dc.w (DebugList_SpecialEnd-DebugList_Special-2)/8
;			mappings		block				frame	VRAM setting
	sdbug	Map_SSWalls,	SSBlock_BlueWall,		0,		make_art_tile(ArtTile_SS_Wall,0,0)				; Blue Wall
	sdbug	Map_SSWalls,	SSBlock_YellowWall,		0,		make_art_tile(ArtTile_SS_Wall,1,0)				; Yellow Wall
	sdbug	Map_SSWalls,	SSBlock_PinkWall,		0,		make_art_tile(ArtTile_SS_Wall,2,0)				; Pink Wall
	sdbug	Map_SSWalls,	SSBlock_GreenWall,		0,		make_art_tile(ArtTile_SS_Wall,3,0)				; Green Wall
	sdbug	Map_Bump,		SSBlock_Bumper,			0,		make_art_tile(ArtTile_SS_Bumper,0,0)			; Bumper
; W Block Unused
	sdbug	Map_SS_R,		SSBlock_GOAL,			0,		make_art_tile(ArtTile_SS_Goal,0,0)				; Goal
	sdbug	Map_SS_R,		SSBlock_1Up,			0,		make_art_tile(ArtTile_SS_Extra_Life,0,0)		; 1-Up

	if S4SpecialStages=0
	sdbug	Map_SS_Up,		SSBlock_UP,				0,		make_art_tile(ArtTile_SS_Up_Down,0,0)			; Speed UP rotation
	sdbug	Map_SS_Down,	SSBlock_DOWN,			0,		make_art_tile(ArtTile_SS_Up_Down,0,0)			; Speed DOWN rotation
	sdbug	Map_SS_R,		SSBlock_R,				0,		make_art_tile(ArtTile_SS_R_Block,1,0)			; Reverse rotation
	endif

	sdbug	Map_SS_Glass,	SSBlock_GhostSolid,		0,		make_art_tile(ArtTile_SS_Red_White_Block,0,0)	; Ghost Block Solid (Peppermint)
	sdbug	Map_SS_Glass,	SSBlock_Glass1,			0,		make_art_tile(ArtTile_SS_Glass,0,0)				; Glass #1
	sdbug	Map_SS_Glass,	SSBlock_Glass2,			0,		make_art_tile(ArtTile_SS_Glass,3,0)				; Glass #2
	sdbug	Map_SS_Glass,	SSBlock_Glass3,			0,		make_art_tile(ArtTile_SS_Glass,1,0)				; Glass #3
	sdbug	Map_SS_Glass,	SSBlock_Glass4,			0,		make_art_tile(ArtTile_SS_Glass,2,0)				; Glass #4
; Zone Block Spaces Unused
	sdbug	Map_Ring,		SSBlock_Ring,			0,		make_art_tile(ArtTile_SS_Ring,1,0)				; Ring
	sdbug	Map_SS_Chaos3,	SSBlock_Emld1,			0,		make_art_tile(ArtTile_SS_Emerald,0,0)			; Emerald 1 (Blue)
	sdbug	Map_SS_Chaos3,	SSBlock_Emld2,			0,		make_art_tile(ArtTile_SS_Emerald,1,0)			; Emerald 2 (Yellow)
	sdbug	Map_SS_Chaos3,	SSBlock_Emld3,			0,		make_art_tile(ArtTile_SS_Emerald,2,0)			; Emerald 3 (Pink)
	sdbug	Map_SS_Chaos3,	SSBlock_Emld4,			0,		make_art_tile(ArtTile_SS_Emerald,3,0)			; Emerald 4 (Green)
	sdbug	Map_SS_Chaos1,	SSBlock_Emld5,			0,		make_art_tile(ArtTile_SS_Emerald,0,0)			; Emerald 5 (Red)
	sdbug	Map_SS_Chaos2,	SSBlock_Emld6,			0,		make_art_tile(ArtTile_SS_Emerald,0,0)			; Emerald 6 (Gray)

	if SuperMod=1
	sdbug	Map_SS_Chaos2,	SSBlock_Emld7,			0,		make_art_tile(ArtTile_SS_Emerald,1,0)			; Emerald 7 (Cyan)
	endif

	sdbug	Map_SS_R,		SSBlock_GhostSolid,		0,		make_art_tile(ArtTile_SS_Ghost_Block,0,0)		; Ghost Block (Peppermint)
	sdbug	Map_Cursor,		0,						0,		make_art_tile(ArtTile_SS_Delete,0,0)			; Delete Icon
DebugList_SpecialEnd:
	even