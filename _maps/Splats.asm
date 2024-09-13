Map_Splats: mappingsTable
	mappingsTableEntry.w	Map_Splats_Down
	mappingsTableEntry.w	Map_Splats_Up

Map_Splats_Down:	spriteHeader
 spritePiece -$C, -$14, 3, 4, 0, 0, 0, 0, 0
 spritePiece -$C, $C, 3, 1, $C, 0, 0, 0, 0
Map_Splats_Down_End

Map_Splats_Up:	spriteHeader
 spritePiece -$C, -$14, 3, 4, $F, 0, 0, 0, 0
 spritePiece -5, $C, 2, 1, $1B, 0, 0, 0, 0
Map_Splats_Up_End

	even