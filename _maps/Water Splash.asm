; ---------------------------------------------------------------------------
; Sprite mappings - water splash (LZ)
; ---------------------------------------------------------------------------
Map_Splash:	mappingsTable
	mappingsTableEntry.w	.splash1
	mappingsTableEntry.w	.splash2
	mappingsTableEntry.w	.splash3

.splash1:	spriteHeader
	spritePiece	-8, -$E, 2, 1, 0, 0, 0, 0, 0
	spritePiece	-$10, -6, 4, 1, 2, 0, 0, 0, 0
.splash1_End

.splash2:	spriteHeader
	spritePiece	-8, -$1E, 1, 1, 6, 0, 0, 0, 0
	spritePiece	-$10, -$16, 4, 3, 7, 0, 0, 0, 0
.splash2_End

.splash3:	spriteHeader
	spritePiece	-$10, -$1E, 4, 4, $13, 0, 0, 0, 0
.splash3_End

	even
