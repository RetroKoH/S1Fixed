; ---------------------------------------------------------------------------
; Sprite mappings - chaos emeralds from	the special stage results screen
; ---------------------------------------------------------------------------
Map_SSRC_internal:	mappingsTable
	mappingsTableEntry.w	SSRC_1
	mappingsTableEntry.w	SSRC_2
	mappingsTableEntry.w	SSRC_3
	mappingsTableEntry.w	SSRC_4
	mappingsTableEntry.w	SSRC_5
	mappingsTableEntry.w	SSRC_6
	if SuperMod=1
	mappingsTableEntry.w	SSRC_7
	endif
	mappingsTableEntry.w	SSRC_Blank
	

SSRC_1:	spriteHeader
	spritePiece	-8, -8, 2, 2, 4, 0, 0, 1, 0
SSRC_1_End

SSRC_2:	spriteHeader
	spritePiece	-8, -8, 2, 2, 0, 0, 0, 0, 0
SSRC_2_End

SSRC_3:	spriteHeader
	spritePiece	-8, -8, 2, 2, 4, 0, 0, 2, 0
SSRC_3_End

SSRC_4:	spriteHeader
	spritePiece	-8, -8, 2, 2, 4, 0, 0, 3, 0
SSRC_4_End

SSRC_5:	spriteHeader
	spritePiece	-8, -8, 2, 2, 8, 0, 0, 1, 0
SSRC_5_End

SSRC_6:	spriteHeader
	spritePiece	-8, -8, 2, 2, $C, 0, 0, 1, 0
SSRC_6_End

	if SuperMod=1
SSRC_7:	spriteHeader
	spritePiece	-8, -8, 2, 2, 0, 0, 0, 2, 0
SSRC_7_End
	endif

SSRC_Blank:	spriteHeader	; Blank frame
SSRC_Blank_End

	even
