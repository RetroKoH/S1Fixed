; ---------------------------------------------------------------------------
; Sprite mappings - exploding spikeys that the SLZ boss	drops
; RetroKoH VRAM Overhaul
; ---------------------------------------------------------------------------
Map_BSBall_internal:	mappingsTable
	mappingsTableEntry.w	.fireball1
	mappingsTableEntry.w	.fireball2

.fireball1:	spriteHeader
	spritePiece	-4, -4, 1, 1, 0, 0, 0, 0, 0
.fireball1_End

.fireball2:	spriteHeader
	spritePiece	-4, -4, 1, 1, 1, 0, 0, 0, 0
.fireball2_End

	even
