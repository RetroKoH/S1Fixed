; ---------------------------------------------------------------------------
; Sprite mappings - blocks (LZ)
; ---------------------------------------------------------------------------
Map_LRise:	mappingsTable
	mappingsTableEntry.w	.riseplatform

.riseplatform:	spriteHeader
	spritePiece	-$20, -$C, 4, 3, 0, 0, 0, 0, 0 ; platform, rises when stood on
	spritePiece	0, -$C, 4, 3, $C, 0, 0, 0, 0
.riseplatform_End

	even
