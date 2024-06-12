; ---------------------------------------------------------------------------
; Sprite mappings - advancing wall of lava (MZ)
; ---------------------------------------------------------------------------
Map_LWall_internal:	mappingsTable
	mappingsTableEntry.w	byte_F538
	mappingsTableEntry.w	byte_F566
	mappingsTableEntry.w	byte_F594
	mappingsTableEntry.w	byte_F5C2
	mappingsTableEntry.w	byte_F5F0

; RetroKoH VRAM Overhaul
lwall_offset: equ $7E2

byte_F538:	spriteHeader
	spritePiece	$20, -$20, 4, 4, $60, 0, 0, 0, 0
	spritePiece	$3C, 0, 4, 4, $70, 0, 0, 0, 0
	spritePiece	$20, 0, 4, 4, lwall_offset, 1, 1, 3, 1
	spritePiece	0, -$20, 4, 4, lwall_offset, 1, 1, 3, 1
	spritePiece	0, 0, 4, 4, lwall_offset, 1, 1, 3, 1
	spritePiece	-$20, -$20, 4, 4, lwall_offset, 1, 1, 3, 1
	spritePiece	-$20, 0, 4, 4, lwall_offset, 1, 1, 3, 1
	spritePiece	-$40, -$20, 4, 4, lwall_offset, 1, 1, 3, 1
	spritePiece	-$40, 0, 4, 4, lwall_offset, 1, 1, 3, 1
byte_F538_End

byte_F566:	spriteHeader
	spritePiece	$20, -$20, 4, 4, $70, 0, 0, 0, 0
	spritePiece	$3C, 0, 4, 4, $80, 0, 0, 0, 0
	spritePiece	$20, 0, 4, 4, lwall_offset, 1, 1, 3, 1
	spritePiece	0, -$20, 4, 4, lwall_offset, 1, 1, 3, 1
	spritePiece	0, 0, 4, 4, lwall_offset, 1, 1, 3, 1
	spritePiece	-$20, -$20, 4, 4, lwall_offset, 1, 1, 3, 1
	spritePiece	-$20, 0, 4, 4, lwall_offset, 1, 1, 3, 1
	spritePiece	-$40, -$20, 4, 4, lwall_offset, 1, 1, 3, 1
	spritePiece	-$40, 0, 4, 4, lwall_offset, 1, 1, 3, 1
byte_F566_End

byte_F594:	spriteHeader
	spritePiece	$20, -$20, 4, 4, $80, 0, 0, 0, 0
	spritePiece	$3C, 0, 4, 4, $70, 0, 0, 0, 0
	spritePiece	$20, 0, 4, 4, lwall_offset, 1, 1, 3, 1
	spritePiece	0, -$20, 4, 4, lwall_offset, 1, 1, 3, 1
	spritePiece	0, 0, 4, 4, lwall_offset, 1, 1, 3, 1
	spritePiece	-$20, -$20, 4, 4, lwall_offset, 1, 1, 3, 1
	spritePiece	-$20, 0, 4, 4, lwall_offset, 1, 1, 3, 1
	spritePiece	-$40, -$20, 4, 4, lwall_offset, 1, 1, 3, 1
	spritePiece	-$40, 0, 4, 4, lwall_offset, 1, 1, 3, 1
byte_F594_End

byte_F5C2:	spriteHeader
	spritePiece	$20, -$20, 4, 4, $70, 0, 0, 0, 0
	spritePiece	$3C, 0, 4, 4, $60, 0, 0, 0, 0
	spritePiece	$20, 0, 4, 4, lwall_offset, 1, 1, 3, 1
	spritePiece	0, -$20, 4, 4, lwall_offset, 1, 1, 3, 1
	spritePiece	0, 0, 4, 4, lwall_offset, 1, 1, 3, 1
	spritePiece	-$20, -$20, 4, 4, lwall_offset, 1, 1, 3, 1
	spritePiece	-$20, 0, 4, 4, lwall_offset, 1, 1, 3, 1
	spritePiece	-$40, -$20, 4, 4, lwall_offset, 1, 1, 3, 1
	spritePiece	-$40, 0, 4, 4, lwall_offset, 1, 1, 3, 1
byte_F5C2_End

byte_F5F0:	spriteHeader
	spritePiece	$20, -$20, 4, 4, lwall_offset, 1, 1, 3, 1
	spritePiece	$20, 0, 4, 4, lwall_offset, 1, 1, 3, 1
	spritePiece	0, -$20, 4, 4, lwall_offset, 1, 1, 3, 1
	spritePiece	0, 0, 4, 4, lwall_offset, 1, 1, 3, 1
	spritePiece	-$20, -$20, 4, 4, lwall_offset, 1, 1, 3, 1
	spritePiece	-$20, 0, 4, 4, lwall_offset, 1, 1, 3, 1
	spritePiece	-$40, -$20, 4, 4, lwall_offset, 1, 1, 3, 1
	spritePiece	-$40, 0, 4, 4, lwall_offset, 1, 1, 3, 1
byte_F5F0_End

	even
