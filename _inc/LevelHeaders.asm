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

SBZ3_Art:		equ 7

; Clownacy Level Art Loading
; 1st PLC, level gfx, 2nd PLC, 16x16 data, 128x128 data, palette

;			1st PLC					2nd PLC					128x128 data
;						level gfx				16x16 data				palette

	lhead	plcid_GHZ,	ArtKos_GHZ,	plcid_GHZ2,	Blk16_GHZ,	Blk128_GHZ,	palid_GHZ		; Green Hill
	lhead	plcid_LZ,	ArtKos_LZ,	plcid_LZ2,	Blk16_LZ,	Blk128_LZ,	palid_LZ		; Labyrinth
	lhead	plcid_MZ,	ArtKos_MZ,	plcid_MZ2,	Blk16_MZ,	Blk128_MZ,	palid_MZ		; Marble
	lhead	plcid_SLZ,	ArtKos_SLZ,	plcid_SLZ2,	Blk16_SLZ,	Blk128_SLZ,	palid_SLZ		; Star Light
	lhead	plcid_SYZ,	ArtKos_SYZ,	plcid_SYZ2,	Blk16_SYZ,	Blk128_SYZ,	palid_SYZ		; Spring Yard
	lhead	plcid_SBZ,	ArtKos_SBZ,	plcid_SBZ2,	Blk16_SBZ,	Blk128_SBZ,	palid_SBZ1		; Scrap Brain
	zonewarning LevelHeaders,$10
	lhead	0,			ArtKos_GHZ,	0,			Blk16_GHZ,	Blk128_GHZ,	palid_Ending	; Ending

	if NewSBZ3LevelArt
	lhead	plcid_LZ,	ArtKos_SBZ3,plcid_LZ2,	Blk16_SBZ3,	Blk128_SBZ3,palid_SBZ3		; New Scrap Brain 3
	endif

	even
