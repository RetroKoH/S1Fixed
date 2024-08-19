; ---------------------------------------------------------------------------
; Sprite mappings - "GAME OVER"	and "TIME OVER"
; ---------------------------------------------------------------------------
Map_Over:	mappingsTable
	mappingsTableEntry.w	MGO_GAME
	mappingsTableEntry.w	MGO_OVER
	mappingsTableEntry.w	MTO_TIME
	mappingsTableEntry.w	MTO_OVER

MGO_GAME:	spriteHeader
	spritePiece	-$48, -8, 4, 2, 0, 0, 0, 0, 0	; GAME
	spritePiece	-$28, -8, 4, 2, 8, 0, 0, 0, 0
MGO_GAME_End

MGO_OVER:	spriteHeader
	spritePiece	8, -8, 4, 2, $14, 0, 0, 0, 0	; OVER
	spritePiece	$28, -8, 4, 2, $C, 0, 0, 0, 0
MGO_OVER_End

MTO_TIME:	spriteHeader
	spritePiece	-$3C, -8, 3, 2, 2, 0, 0, 0, 0	; TIME (Modified; RetroKoH VRAM Overhaul)
	spritePiece	-$24, -8, 4, 2, 8, 0, 0, 0, 0
MTO_TIME_End

MTO_OVER:	spriteHeader
	spritePiece	$C, -8, 4, 2, $14, 0, 0, 0, 0	; OVER
	spritePiece	$2C, -8, 4, 2, $C, 0, 0, 0, 0
MTO_OVER_End

	even
