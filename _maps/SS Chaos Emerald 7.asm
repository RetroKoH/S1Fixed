; ---------------------------------------------------------------------------
; Sprite mappings - special stage chaos	emerald #7
; ---------------------------------------------------------------------------
Map_SS_Chaos7:	mappingsTable
	mappingsTableEntry.w	.color
	mappingsTableEntry.w	.blink

.color:	spriteHeader
	spritePiece	-8, -8, 2, 2, 4, 0, 0, 1, 0
.color_End

.blink:	spriteHeader
	spritePiece	-8, -8, 2, 2, $C, 0, 0, 1, 0
.blink_End

		even
