; ---------------------------------------------------------------------------
; Sprite mappings - special stage chaos	emerald #6
; ---------------------------------------------------------------------------
Map_SS_Chaos6:	mappingsTable
	mappingsTableEntry.w	.color
	mappingsTableEntry.w	.blink

.color:	spriteHeader
	spritePiece	-8, -8, 2, 2, 4, 0, 0, 0, 0
.color_End

.blink:	spriteHeader
	spritePiece	-8, -8, 2, 2, $C, 0, 0, 0, 0
.blink_End

		even
