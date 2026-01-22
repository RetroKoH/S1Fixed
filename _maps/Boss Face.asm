; ---------------------------------------------------------------------------
; Sprite mappings - Eggman's face
; Mappings altered by Mercury so that his moustache isn't cut off (ReadySonic).
; ---------------------------------------------------------------------------
Map_BossFace:	mappingsTable
	mappingsTableEntry.w	.facenormal
	mappingsTableEntry.w	.facenormal
	mappingsTableEntry.w	.facelaugh
	mappingsTableEntry.w	.facelaugh
	mappingsTableEntry.w	.facelaugh		; hit face (identical mapping)
	mappingsTableEntry.w	.facepanic
	mappingsTableEntry.w	.facedefeat

.facenormal:	spriteHeader
	spritePiece	-$C, -$1C, 2, 1, 0, 0, 0, 0, 0
	spritePiece	-$14, -$14, 4, 2, 2, 0, 0, 0, 0
.facenormal_End

.facelaugh:	spriteHeader
	spritePiece	-$C, -$1C, 3, 1, 0, 0, 0, 0, 0
	spritePiece	-$14, -$14, 3, 2, 3, 0, 0, 0, 0
	spritePiece	4, -$14, 2, 2, 9, 0, 0, 0, 0
.facelaugh_End

.facepanic:	spriteHeader
	spritePiece	4, -$1C, 2, 1, $A, 0, 0, 0, 0
	spritePiece	-$C, -$1C, 2, 1, 0, 0, 0, 0, 0
	spritePiece	-$14, -$14, 4, 2, 2, 0, 0, 0, 0
.facepanic_End

.facedefeat:	spriteHeader
	spritePiece	-$C, -$1C, 3, 2, $D, 0, 0, 0, 0
	spritePiece	-$C, -$1C, 3, 1, 0, 0, 0, 0, 0
	spritePiece	-$14, -$14, 3, 2, 3, 0, 0, 0, 0
	spritePiece	4, -$14, 2, 2, 9, 0, 0, 0, 0
.facedefeat_End

	even
