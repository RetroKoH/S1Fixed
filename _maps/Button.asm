; ---------------------------------------------------------------------------
; Sprite mappings - switches (MZ, SYZ, LZ, SBZ)
; ---------------------------------------------------------------------------
Map_But_internal:	mappingsTable
	mappingsTableEntry.w	byte_BEAC
	mappingsTableEntry.w	byte_BEB7

byte_BEAC:	spriteHeader
	spritePiece	-$10, -$B, 2, 2, 0, 0, 0, 0, 0
	spritePiece	0, -$B, 2, 2, 0, 1, 0, 0, 0
byte_BEAC_End

byte_BEB7:	spriteHeader
	spritePiece	-$10, -$B, 2, 2, 4, 0, 0, 0, 0
	spritePiece	0, -$B, 2, 2, 4, 1, 0, 0, 0
byte_BEB7_End

	even
