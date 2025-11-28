; ---------------------------------------------------------------------------
; Sprite mappings - platforms on a conveyor belt (LZ)
; Wheels now use only one frame, as art is dynamically loaded
; ---------------------------------------------------------------------------
Map_LConv:	mappingsTable
	mappingsTableEntry.w	.platform
	mappingsTableEntry.w	.wheel

.platform:	spriteHeader
	spritePiece	-$10, -8, 4, 2, 0, 0, 0, 0, 0
.platform_End

.wheel:	spriteHeader
	spritePiece	-$10, -$10, 4, 4, 0, 0, 0, 0, 0
.wheel_End

	even
