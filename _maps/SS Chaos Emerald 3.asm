; ---------------------------------------------------------------------------
; Sprite mappings - special stage chaos	emerald #3
; ---------------------------------------------------------------------------
Map_SS_Chaos3:	mappingsTable
	mappingsTableEntry.w	.color
	mappingsTableEntry.w	.blink

.color:	spriteHeader
	spritePiece	-8, -8, 2, 2, 8, 0, 0, 2, 0
.color_End

.blink:	spriteHeader
	spritePiece	-8, -8, 2, 2, $C, 0, 0, 2, 0
.blink_End

		even
