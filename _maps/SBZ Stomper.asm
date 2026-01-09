; ---------------------------------------------------------------------------
; Sprite mappings - stomper (SBZ)
; ---------------------------------------------------------------------------
Map_Stomp:	mappingsTable
	mappingsTableEntry.w	.stomper

.stomper:	spriteHeader
	spritePiece	-$1C, -$20, 4, 1, $C, 0, 0, 0, 0
	spritePiece	4, -$20, 3, 1, $10, 0, 0, 0, 0
	spritePiece	-$1C, -$18, 4, 3, $13, 0, 0, 1, 0
	spritePiece	4, -$18, 3, 3, $1F, 0, 0, 1, 0
	spritePiece	-$1C, 0, 4, 3, $13, 0, 0, 1, 0
	spritePiece	4, 0, 3, 3, $1F, 0, 0, 1, 0
	spritePiece	-$1C, $18, 4, 1, $C, 0, 0, 0, 0
	spritePiece	4, $18, 3, 1, $10, 0, 0, 0, 0
.stomper_End

	even
