; ---------------------------------------------------------------------------
; Sprite mappings - special stage chaos	emerald #5
; ---------------------------------------------------------------------------
Map_SS_Chaos5:	mappingsTable
	mappingsTableEntry.w	.color
	mappingsTableEntry.w	.blink

.color:	spriteHeader
	spritePiece	-8, -8, 2, 2, 0, 0, 0, 0, 0
.color_End

.blink:	spriteHeader
	spritePiece	-8, -8, 2, 2, $C, 0, 0, 0, 0
.blink_End

		even
