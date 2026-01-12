; ---------------------------------------------------------------------------
; Sprite mappings - moving blocks (SYZ)
; ---------------------------------------------------------------------------
Map_FBlock:	mappingsTable
	mappingsTableEntry.w	.syz1x1
	mappingsTableEntry.w	.syz2x2
	mappingsTableEntry.w	.syz1x2
	mappingsTableEntry.w	.syzrect2x2
	mappingsTableEntry.w	.syzrect1x3

.syz1x1:	spriteHeader
	spritePiece	-$10, -$10, 4, 4, $61, 0, 0, 0, 0 ; SYZ - 1x1 square block
.syz1x1_End

.syz2x2:	spriteHeader
	spritePiece	-$20, -$20, 4, 4, $61, 0, 0, 0, 0 ; SYZ - 2x2 square blocks
	spritePiece	0, -$20, 4, 4, $61, 0, 0, 0, 0
	spritePiece	-$20, 0, 4, 4, $61, 0, 0, 0, 0
	spritePiece	0, 0, 4, 4, $61, 0, 0, 0, 0
.syz2x2_End

.syz1x2:	spriteHeader
	spritePiece	-$10, -$20, 4, 4, $61, 0, 0, 0, 0 ; SYZ - 1x2 square blocks
	spritePiece	-$10, 0, 4, 4, $61, 0, 0, 0, 0
.syz1x2_End

.syzrect2x2:	spriteHeader
	spritePiece	-$20, -$1A, 4, 4, $81, 0, 0, 0, 0 ; SYZ - 2x2 rectangular blocks
	spritePiece	0, -$1A, 4, 4, $81, 0, 0, 0, 0
	spritePiece	-$20, 0, 4, 4, $81, 0, 0, 0, 0
	spritePiece	0, 0, 4, 4, $81, 0, 0, 0, 0
.syzrect2x2_End

.syzrect1x3:	spriteHeader
	spritePiece	-$10, -$27, 4, 4, $81, 0, 0, 0, 0 ; SYZ - 1x3 rectangular blocks
	spritePiece	-$10, -$D, 4, 4, $81, 0, 0, 0, 0
	spritePiece	-$10, $D, 4, 4, $81, 0, 0, 0, 0
.syzrect1x3_End

	even
