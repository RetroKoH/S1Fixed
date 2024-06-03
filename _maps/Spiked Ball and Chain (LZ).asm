; ---------------------------------------------------------------------------
; Sprite mappings - spiked ball	on a chain (LZ)
; ---------------------------------------------------------------------------
Map_SBall2_internal:	mappingsTable
	mappingsTableEntry.w	.chain
	mappingsTableEntry.w	.spikeball
	mappingsTableEntry.w	.base

.chain:	spriteHeader
	spritePiece	-8, -8, 2, 2, 0, 0, 0, 0, 0	; chain link
.chain_End

.spikeball:	spriteHeader
	spritePiece	-$10, -$10, 4, 4, 4, 0, 0, 0, 0	; spikeball
.spikeball_End

.base:	spriteHeader
	spritePiece	-8, -8, 2, 2, $14, 0, 0, 0, 0 ; wall attachment
.base_End

	even
