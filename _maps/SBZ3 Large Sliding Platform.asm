; ---------------------------------------------------------------------------
; Sprite mappings - large sliding platform (LZ/SBZ3)
; ---------------------------------------------------------------------------
Map_Slid:	mappingsTable
	mappingsTableEntry.w	.platform

.platform:	spriteHeader
	spritePiece	-$80, -$40, 4, 4, 0, 0, 0, 0, 0
	spritePiece	-$60, -$40, 4, 4, $10, 0, 0, 0, 0
	spritePiece	-$40, -$40, 4, 4, $20, 0, 0, 0, 0
	spritePiece	-$20, -$40, 4, 4, $10, 0, 0, 0, 0
	spritePiece	0, -$40, 4, 4, $20, 0, 0, 0, 0
	spritePiece	$20, -$40, 4, 4, $10, 0, 0, 0, 0
	spritePiece	$40, -$40, 4, 4, $30, 0, 0, 0, 0
	spritePiece	$60, -$40, 4, 2, $40, 0, 0, 0, 0
	spritePiece	-$80, -$20, 4, 4, $48, 0, 0, 0, 0
	spritePiece	-$40, -$20, 4, 4, $48, 0, 0, 0, 0
	spritePiece	0, -$20, 4, 4, $58, 0, 0, 0, 0
	spritePiece	-$80, 0, 4, 4, $48, 0, 0, 0, 0
	spritePiece	-$40, 0, 4, 4, $58, 0, 0, 0, 0
	spritePiece	-$80, $20, 4, 4, $58, 0, 0, 0, 0
.platform_End

	even
