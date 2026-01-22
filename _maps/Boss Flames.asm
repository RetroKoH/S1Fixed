; ---------------------------------------------------------------------------
; Sprite mappings - Eggman's ship flame
; ---------------------------------------------------------------------------

Map_Exhaust:	mappingsTable
	mappingsTableEntry.w	.blank
	mappingsTableEntry.w	.flame1
	mappingsTableEntry.w	.flame2
	mappingsTableEntry.w	.escapeflame1
	mappingsTableEntry.w	.escapeflame2

.blank:	spriteHeader
.blank_End

.flame1:	spriteHeader
	spritePiece	$21, 4, 2, 2, 0, 0, 0, 0, 0
.flame1_End

.flame2:	spriteHeader
	spritePiece	$21, 4, 2, 2, 0, 0, 0, 0, 0
.flame2_End

.escapeflame1:	spriteHeader
	spritePiece	$21, 0, 3, 1, 0, 0, 0, 0, 0
	spritePiece	$21, 8, 3, 1, 0, 0, 1, 0, 0
.escapeflame1_End

.escapeflame2:	spriteHeader
	spritePiece	$21, -8, 3, 4, 0, 0, 0, 0, 0
	spritePiece	$39, 0, 1, 2, $C, 0, 0, 0, 0
.escapeflame2_End

	even
