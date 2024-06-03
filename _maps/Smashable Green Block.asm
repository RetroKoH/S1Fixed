; ---------------------------------------------------------------------------
; Sprite mappings - smashable green block (MZ)
; ---------------------------------------------------------------------------
Map_Smab_internal:	mappingsTable
	mappingsTableEntry.w	.two
	mappingsTableEntry.w	.four

.two:	spriteHeader
	spritePiece	-$10, -$10, 4, 2, 0, 0, 0, 0, 0	; two fragments, arranged vertically
	spritePiece	-$10, 0, 4, 2, 0, 0, 0, 0, 0
.two_End

.four:	spriteHeader
	spritePiece	-$10, -$10, 2, 2, 0, 0, 0, 0, 1 ; four fragments
	spritePiece	-$10, 0, 2, 2, 0, 0, 0, 0, 1
	spritePiece	0, -$10, 2, 2, 0, 0, 0, 0, 1
	spritePiece	0, 0, 2, 2, 0, 0, 0, 0, 1
.four_End

	even
