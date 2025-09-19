; ---------------------------------------------------------------------------
; Sprite mappings - "PRESS START BUTTON" and "TM" from title screen
; ---------------------------------------------------------------------------
Map_PSB: 	mappingsTable
	mappingsTableEntry.w	M_PSB_Blank
	mappingsTableEntry.w	M_PSB_PSB
	mappingsTableEntry.w	M_PSB_Limiter
	mappingsTableEntry.w	M_PSB_TM

M_PSB_Blank:	spriteHeader
M_PSB_Blank_End

M_PSB_PSB:	spriteHeader							; "PRESS START BUTTON"
	spritePiece 0, 0, 4, 1, $F0, 0, 0, 0, 0
	spritePiece $20, 0, 1, 1, $F3, 0, 0, 0, 0
	spritePiece $30, 0, 4, 1, $F3, 0, 0, 0, 0
	spritePiece $50, 0, 1, 1, $F4, 0, 0, 0, 0
	spritePiece $60, 0, 4, 1, $F7, 0, 0, 0, 0
	spritePiece $80, 0, 2, 1, $FB, 0, 0, 0, 0
M_PSB_PSB_End

M_PSB_Limiter:	spriteHeader						; sprite line limiter (by Iso Kilo)
	spritePiece -8, -$30, 1, 4, 0, 0, 0, 0, 0
	spritePiece 0, -$30, 1, 4, 0, 0, 0, 0, 0
	spritePiece -8, -$10, 1, 4, 0, 0, 0, 0, 0
	spritePiece 0, -$10, 1, 4, 0, 0, 0, 0, 0
	spritePiece -8, $10, 1, 4, 0, 0, 0, 0, 0
	spritePiece 0, $10, 1, 4, 0, 0, 0, 0, 0
M_PSB_Limiter_End

M_PSB_TM:	spriteHeader							; "TM"
	spritePiece -8, -4, 2, 1, 0, 0, 0, 0, 0
M_PSB_TM_End

	even