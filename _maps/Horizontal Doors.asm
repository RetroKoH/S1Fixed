; ---------------------------------------------------------------------------
; Sprite mappings - large horizontal door (LZ)
; ---------------------------------------------------------------------------
Map_DoorH:	mappingsTable
	mappingsTableEntry.w	.lzhoriz

.lzhoriz:	spriteHeader
	spritePiece	-$40, -$10, 4, 4, 0, 0, 0, 0, 0
	spritePiece	-$20, -$10, 4, 4, 0, 0, 0, 0, 0
	spritePiece	0, -$10, 4, 4, 0, 0, 0, 0, 0
	spritePiece	$20, -$10, 4, 4, 0, 0, 0, 0, 0
.lzhoriz_End

	even
