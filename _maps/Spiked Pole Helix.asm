; ---------------------------------------------------------------------------
; Sprite mappings - helix of spikes on a pole (GHZ)
; ---------------------------------------------------------------------------
Map_Hel_internal:	mappingsTable
	mappingsTableEntry.w	byte_7E08
	mappingsTableEntry.w	byte_7E0E
	mappingsTableEntry.w	byte_7E14
	mappingsTableEntry.w	byte_7E1A
	mappingsTableEntry.w	byte_7E20
	mappingsTableEntry.w	byte_7E26
	mappingsTableEntry.w	byte_7E2C+2	; This is a nasty hack to render the sprite invisible by pointing at a random 00 byte.
	mappingsTableEntry.w	byte_7E2C

byte_7E08:	spriteHeader
	spritePiece	-4, -$10, 1, 2, 0, 0, 0, 0, 0	; points straight up (harmful)
byte_7E08_End

byte_7E0E:	spriteHeader
	spritePiece	-8, -$B, 2, 2, 2, 0, 0, 0, 0	; 45 degree
byte_7E0E_End

byte_7E14:	spriteHeader
	spritePiece	-8, -8, 2, 2, 6, 0, 0, 0, 0	; 90 degree
byte_7E14_End

byte_7E1A:	spriteHeader
	spritePiece	-8, -5, 2, 2, $A, 0, 0, 0, 0	; 45 degree
byte_7E1A_End

byte_7E20:	spriteHeader
	spritePiece	-4, 0, 1, 2, $E, 0, 0, 0, 0	; straight down
byte_7E20_End

byte_7E26:	spriteHeader
	spritePiece	-3, 4, 1, 1, $10, 0, 0, 0, 0	; 45 degree
byte_7E26_End

byte_7E2C:	spriteHeader
	spritePiece	-3, -$C, 1, 1, $11, 0, 0, 0, 0 ; 45 degree
byte_7E2C_End

	even
