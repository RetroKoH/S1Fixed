; ---------------------------------------------------------------------------
; Sprite mappings - Eggman's ship (main object's mappings)
; ---------------------------------------------------------------------------
Map_Eggman:	mappingsTable
	mappingsTableEntry.w	.ship

.ship:	spriteHeader
	spritePiece	-$1C, -$14, 1, 2, 0, 0, 0, 0, 0
	spritePiece	$C, -$14, 2, 2, 2, 0, 0, 0, 0
	spritePiece	-$1C, -4, 4, 3, 6, 0, 0, 1, 0
	spritePiece	4, -4, 4, 3, $12, 0, 0, 1, 0
	spritePiece	-$14, $14, 4, 1, $1E, 0, 0, 1, 0
	spritePiece	$C, $14, 1, 1, $22, 0, 0, 1, 0
.ship_End

	even
