; ---------------------------------------------------------------------------
; Sprite mappings - sliding metal bar (SBZ)
; Split from the Stomper mappings
; ---------------------------------------------------------------------------
Map_MetalBar:	mappingsTable
	mappingsTableEntry.w	.door

.door:	spriteHeader
	spritePiece	-$40, -$C, 4, 3, 0, 0, 0, 1, 0
	spritePiece	-$20, -$C, 4, 3, 3, 0, 0, 1, 0
	spritePiece	0, -$C, 4, 3, 3, 0, 0, 1, 0
	spritePiece	$20, -$C, 4, 3, 0, 1, 0, 1, 0
.door_End

	even
