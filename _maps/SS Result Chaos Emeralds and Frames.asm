; ---------------------------------------------------------------------------
; Sprite mappings - chaos emeralds from	the special stage results screen
; New frames added for empty Chaos Emerald slots
; ---------------------------------------------------------------------------

Map_SSRC:	mappingsTable
	mappingsTableEntry.w	SSRC_0
	mappingsTableEntry.w	SSRC_1
	mappingsTableEntry.w	SSRC_2
	mappingsTableEntry.w	SSRC_3
	mappingsTableEntry.w	SSRC_4
	mappingsTableEntry.w	SSRC_5
	if SuperMod
	mappingsTableEntry.w	SSRC_6
	endif

; New frames for missing emeralds
	mappingsTableEntry.w	SSRC_Empty1
	mappingsTableEntry.w	SSRC_Empty2
	mappingsTableEntry.w	SSRC_Empty3
	mappingsTableEntry.w	SSRC_Empty4
	mappingsTableEntry.w	SSRC_Empty5
	mappingsTableEntry.w	SSRC_Empty6
	if SuperMod
	mappingsTableEntry.w	SSRC_Empty7
	endif

SSRC_0:	spriteHeader
	spritePiece	-8, -8, 2, 2, 4, 0, 0, 1, 0
SSRC_0_End

SSRC_1:	spriteHeader
	spritePiece	-8, -8, 2, 2, 0, 0, 0, 0, 0
SSRC_1_End

SSRC_2:	spriteHeader
	spritePiece	-8, -8, 2, 2, 4, 0, 0, 2, 0
SSRC_2_End

SSRC_3:	spriteHeader
	spritePiece	-8, -8, 2, 2, 4, 0, 0, 3, 0
SSRC_3_End

SSRC_4:	spriteHeader
	spritePiece	-8, -8, 2, 2, 8, 0, 0, 1, 0
SSRC_4_End

SSRC_5:	spriteHeader
	spritePiece	-8, -8, 2, 2, $C, 0, 0, 1, 0
SSRC_5_End

	if SuperMod
SSRC_6:	spriteHeader
	spritePiece	-8, -8, 2, 2, 0, 0, 0, 2, 0
SSRC_6_End
	endif

SSRC_Empty1:	spriteHeader
	spritePiece -8, -8, 2, 2, $10, 0, 0, 1, 0
	spritePiece -8, -8, 2, 2, $20, 0, 0, 1, 0
SSRC_Empty1_End

SSRC_Empty2:	spriteHeader
	spritePiece -8, -8, 2, 2, $14, 0, 0, 0, 0
	spritePiece -8, -8, 2, 2, $20, 0, 0, 1, 0
SSRC_Empty2_End

SSRC_Empty3:	spriteHeader
	spritePiece -8, -8, 2, 2, $10, 0, 0, 2, 0
	spritePiece -8, -8, 2, 2, $20, 0, 0, 1, 0
SSRC_Empty3_End

SSRC_Empty4:	spriteHeader
	spritePiece -8, -8, 2, 2, $10, 0, 0, 3, 0
	spritePiece -8, -8, 2, 2, $20, 0, 0, 1, 0
SSRC_Empty4_End

SSRC_Empty5:	spriteHeader
	spritePiece -8, -8, 2, 2, $18, 0, 0, 1, 0
	spritePiece -8, -8, 2, 2, $20, 0, 0, 1, 0
SSRC_Empty5_End

SSRC_Empty6:	spriteHeader
	spritePiece -8, -8, 2, 2, $1C, 0, 0, 1, 0
	spritePiece -8, -8, 2, 2, $20, 0, 0, 1, 0
SSRC_Empty6_End

	if SuperMod
SSRC_Empty7:	spriteHeader
	spritePiece -8, -8, 2, 2, $14, 0, 0, 2, 0
	spritePiece -8, -8, 2, 2, $20, 0, 0, 1, 0
SSRC_Empty7_End
	endif

	even