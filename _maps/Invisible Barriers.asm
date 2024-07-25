; ---------------------------------------------------------------------------
; Sprite mappings - invisible solid blocks
; ---------------------------------------------------------------------------
Map_Invis_internal:	mappingsTable
	mappingsTableEntry.w	.solid

.solid:	spriteHeader
	spritePiece	-$10, -$10, 2, 2, $18, 0, 0, 0, 0
	spritePiece	0, -$10, 2, 2, $18, 0, 0, 0, 0
	spritePiece	-$10, 0, 2, 2, $18, 0, 0, 0, 0
	spritePiece	0, 0, 2, 2, $18, 0, 0, 0, 0
.solid_End

	even
