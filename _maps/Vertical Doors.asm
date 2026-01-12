; ---------------------------------------------------------------------------
; Sprite mappings - small vertical door (LZ)
; ---------------------------------------------------------------------------
Map_DoorV:	mappingsTable
	mappingsTableEntry.w	.lzvert

.lzvert:	spriteHeader
	spritePiece	-8, -$20, 2, 4, 0, 0, 0, 0, 0
	spritePiece	-8, 0, 2, 4, 0, 0, 1, 0, 0
.lzvert_End

	even
