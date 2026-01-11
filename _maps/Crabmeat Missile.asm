; ---------------------------------------------------------------------------
; Sprite mappings - Crabmeat's missile
; ---------------------------------------------------------------------------
Map_CrabBall:	mappingsTable
	mappingsTableEntry.w	.ball1
	mappingsTableEntry.w	.ball2

.ball1:	spriteHeader
	spritePiece	-8, -8, 2, 2, $3C, 0, 0, 0, 0 ; projectile
.ball1_End

.ball2:	spriteHeader
	spritePiece	-8, -8, 2, 2, $40, 0, 0, 0, 0 ; projectile
.ball2_End

	even
