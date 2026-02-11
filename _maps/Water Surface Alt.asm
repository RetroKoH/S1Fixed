; ---------------------------------------------------------------------------
; Sprite mappings - alt water surface (from S2's ARZ)
; ---------------------------------------------------------------------------
Map_Surf:	mappingsTable
	mappingsTableEntry.w	.normal1
	mappingsTableEntry.w	.normal2
	mappingsTableEntry.w	.paused1
	mappingsTableEntry.w	.paused2

.normal1:	spriteHeader
	spritePiece	-$60, -4, 4, 2, 0, 0, 0, 0, 0
	spritePiece	-$20, -4, 4, 2, 0, 0, 0, 0, 0
	spritePiece	$20, -4, 4, 2, 0, 0, 0, 0, 0
.normal1_End

.normal2:	spriteHeader
	spritePiece	-$60, -4, 4, 2, 8, 0, 0, 0, 0
	spritePiece	-$20, -4, 4, 2, 8, 0, 0, 0, 0
	spritePiece	$20, -4, 4, 2, 8, 0, 0, 0, 0
.normal2_End

.paused1:	spriteHeader
	spritePiece	-$60, -4, 4, 2, 0, 0, 0, 0, 0
	spritePiece	-$40, -4, 4, 2, 0, 0, 0, 0, 0
	spritePiece	-$20, -4, 4, 2, 0, 0, 0, 0, 0
	spritePiece	0, -4, 4, 2, 0, 0, 0, 0, 0
	spritePiece	$20, -4, 4, 2, 0, 0, 0, 0, 0
	spritePiece	$40, -4, 4, 2, 0, 0, 0, 0, 0
.paused1_End

.paused2:	spriteHeader
	spritePiece	-$60, -4, 4, 2, 8, 0, 0, 0, 0
	spritePiece	-$40, -4, 4, 2, 8, 0, 0, 0, 0
	spritePiece	-$20, -4, 4, 2, 8, 0, 0, 0, 0
	spritePiece	0, -4, 4, 2, 8, 0, 0, 0, 0
	spritePiece	$20, -4, 4, 2, 8, 0, 0, 0, 0
	spritePiece	$40, -4, 4, 2, 8, 0, 0, 0, 0
.paused2_End

	even
