; ---------------------------------------------------------------------------
; Sprite mappings - blocks (LZ)
; ---------------------------------------------------------------------------
Map_LBlock:	mappingsTable
	mappingsTableEntry.w	.block
	mappingsTableEntry.w	.sinkblock

.block:	spriteHeader
	spritePiece	-$10, -$10, 4, 4, $62C, 1, 1, 3, 1 ; standard block
.block_End

.sinkblock:	spriteHeader
	spritePiece	-$10, -$10, 4, 4, 0, 0, 0, 0, 0	; block, sinks when stood on or pushed
.sinkblock_End

	even
