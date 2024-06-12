; ---------------------------------------------------------------------------
; Sprite mappings - blocks (LZ)
; ---------------------------------------------------------------------------
Map_LBlock_internal:	mappingsTable
	mappingsTableEntry.w	.sinkblock
	mappingsTableEntry.w	.riseplatform
	mappingsTableEntry.w	.cork
	mappingsTableEntry.w	.block

.sinkblock:	spriteHeader
	spritePiece	-$10, -$10, 4, 4, 0, 0, 0, 0, 0	; block, sinks when stood on
.sinkblock_End

.riseplatform:	spriteHeader
	spritePiece	-$20, -$C, 4, 3, $58, 0, 0, 0, 0 ; platform, rises when stood on
	spritePiece	0, -$C, 4, 3, $64, 0, 0, 0, 0
.riseplatform_End

.cork:	spriteHeader
	spritePiece	-$10, -$10, 4, 4, $8F, 0, 0, 0, 0 ; cork, floats on water
.cork_End

.block:	spriteHeader
	spritePiece	-$10, -$10, 4, 4, $62C, 1, 1, 3, 1 ; block
.block_End

	even
