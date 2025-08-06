; ---------------------------------------------------------------------------
; Level Headers
; ---------------------------------------------------------------------------

LevelHeaders:

lhead:	macro plc1,lvlgfx,plc2,sixteen,chunks,pal
	dc.l (plc1<<24)+lvlgfx
	dc.l (plc2<<24)+sixteen
	dc.l chunks
	dc.b pal, 0, 0, 0
	endm


	if DynamicArt
; -----------------------------------------------------------------------

SBZ3_Art:		equ $12		; We need this, because SBZ3 is technically LZ Act 4

; Clownacy Level Art Loading
; 1st PLC, level gfx, 2nd PLC, 16x16 data, 128x128 data, palette

;			1st PLC						2nd PLC					128x128 data
;						level gfx					16x16 data					palette

	lhead	plcid_GHZ,	ArtKos_GHZ,		plcid_GHZ2,	Blk16_GHZ,	Blk128_GHZ,		palid_GHZ		; Green Hill 1 (0)
	lhead	plcid_GHZ,	ArtKos_GHZ2,	plcid_GHZ2,	Blk16_GHZ2,	Blk128_GHZ2,	palid_GHZ		; Green Hill 2 (1)
	lhead	plcid_GHZ,	ArtKos_GHZ3,	plcid_GHZ2,	Blk16_GHZ3,	Blk128_GHZ3,	palid_GHZ		; Green Hill 3 (2)
	lhead	plcid_LZ,	ArtKos_LZ,		plcid_LZ2,	Blk16_LZ,	Blk128_LZ,		palid_LZ		; Labyrinth 1 (3)
	lhead	plcid_LZ,	ArtKos_LZ2,		plcid_LZ2,	Blk16_LZ2,	Blk128_LZ2,		palid_LZ		; Labyrinth 2 (4)
	lhead	plcid_LZ,	ArtKos_LZ3,		plcid_LZ2,	Blk16_LZ3,	Blk128_LZ3,		palid_LZ		; Labyrinth 3 (5)
	lhead	plcid_MZ,	ArtKos_MZ,		plcid_MZ2,	Blk16_MZ,	Blk128_MZ,		palid_MZ		; Marble 1 (6)
	lhead	plcid_MZ,	ArtKos_MZ2,		plcid_MZ2,	Blk16_MZ2,	Blk128_MZ2,		palid_MZ		; Marble 2 (7)
	lhead	plcid_MZ,	ArtKos_MZ3,		plcid_MZ2,	Blk16_MZ3,	Blk128_MZ3,		palid_MZ		; Marble 3 (8)
	lhead	plcid_SLZ,	ArtKos_SLZ,		plcid_SLZ2,	Blk16_SLZ,	Blk128_SLZ,		palid_SLZ		; Star Light 1 (9)
	lhead	plcid_SLZ,	ArtKos_SLZ2,	plcid_SLZ2,	Blk16_SLZ2,	Blk128_SLZ2,	palid_SLZ		; Star Light 2 ($A)
	lhead	plcid_SLZ,	ArtKos_SLZ3,	plcid_SLZ2,	Blk16_SLZ3,	Blk128_SLZ3,	palid_SLZ		; Star Light 3 ($B)
	lhead	plcid_SYZ,	ArtKos_SYZ,		plcid_SYZ2,	Blk16_SYZ,	Blk128_SYZ,		palid_SYZ		; Spring Yard 1 ($C)
	lhead	plcid_SYZ,	ArtKos_SYZ2,	plcid_SYZ2,	Blk16_SYZ2,	Blk128_SYZ2,	palid_SYZ		; Spring Yard 2 ($D)
	lhead	plcid_SYZ,	ArtKos_SYZ3,	plcid_SYZ2,	Blk16_SYZ3,	Blk128_SYZ3,	palid_SYZ		; Spring Yard 3 ($E)
	lhead	plcid_SBZ,	ArtKos_SBZ,		plcid_SBZ2,	Blk16_SBZ,	Blk128_SBZ,		palid_SBZ1		; Scrap Brain 1 ($F)
	lhead	plcid_SBZ,	ArtKos_SBZ2,	plcid_SBZ2,	Blk16_SBZ2,	Blk128_SBZ2,	palid_SBZ2		; Scrap Brain 2 ($10)
	lhead	plcid_SBZ,	ArtKos_FZ,		plcid_SBZ2,	Blk16_FZ,	Blk128_FZ,		palid_SBZ2		; Final ($11)			; Technically this is internally SBZ3
	zonewarning LevelHeaders,$30
	lhead	plcid_LZ,	ArtKos_SBZ3,	plcid_LZ2,	Blk16_SBZ3,	Blk128_SBZ3,	palid_SBZ3		; Scrap Brain 3 ($12)	; This still needs to be placed after standard levels
	lhead	0,			ArtKos_GHZ,		0,			Blk16_GHZ,	Blk128_GHZ,		palid_Ending	; Ending ($13)

; -----------------------------------------------------------------------
	else
; -----------------------------------------------------------------------

SBZ3_Art:		equ 7		; We need this, because SBZ3 is technically LZ Act 4

; Clownacy Level Art Loading
; 1st PLC, level gfx, 2nd PLC, 16x16 data, 128x128 data, palette

;			1st PLC					2nd PLC					128x128 data
;						level gfx				16x16 data				palette

	lhead	plcid_GHZ,	ArtKos_GHZ,	plcid_GHZ2,	Blk16_GHZ,	Blk128_GHZ,	palid_GHZ		; Green Hill (0)
	lhead	plcid_LZ,	ArtKos_LZ,	plcid_LZ2,	Blk16_LZ,	Blk128_LZ,	palid_LZ		; Labyrinth (1)
	lhead	plcid_MZ,	ArtKos_MZ,	plcid_MZ2,	Blk16_MZ,	Blk128_MZ,	palid_MZ		; Marble (2)
	lhead	plcid_SLZ,	ArtKos_SLZ,	plcid_SLZ2,	Blk16_SLZ,	Blk128_SLZ,	palid_SLZ		; Star Light (3)
	lhead	plcid_SYZ,	ArtKos_SYZ,	plcid_SYZ2,	Blk16_SYZ,	Blk128_SYZ,	palid_SYZ		; Spring Yard (4)
	lhead	plcid_SBZ,	ArtKos_SBZ,	plcid_SBZ2,	Blk16_SBZ,	Blk128_SBZ,	palid_SBZ1		; Scrap Brain (5)
	zonewarning LevelHeaders,$10
	lhead	0,			ArtKos_GHZ,	0,			Blk16_GHZ,	Blk128_GHZ,	palid_Ending	; Ending (6)

	if NewSBZ3LevelArt
	lhead	plcid_SBZ3,	ArtKos_SBZ3,plcid_SBZ3_2,Blk16_SBZ3,Blk128_SBZ3,palid_SBZ3		; New Scrap Brain 3 (7)
	endif

; -----------------------------------------------------------------------
	endif

	even