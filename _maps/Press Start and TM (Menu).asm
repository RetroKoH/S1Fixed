Map_PSB: mappingsTable
	mappingsTableEntry.w	M_PSB_Blank
	mappingsTableEntry.w	M_PSB_PSB
	mappingsTableEntry.w	M_PSB_Limiter
	mappingsTableEntry.w	M_PSB_TM
	mappingsTableEntry.w	M_Menu_NewGame
	mappingsTableEntry.w	M_Menu_Continue

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

M_PSB_Limiter:	spriteHeader						; sprite line limiter
 spritePiece -$80, -$48, 4, 4, 0, 0, 0, 0, 0
 spritePiece -$80, -$48, 4, 4, 0, 0, 0, 0, 0
 spritePiece -$80, -$48, 4, 4, 0, 0, 0, 0, 0
 spritePiece -$80, -$48, 4, 4, 0, 0, 0, 0, 0
 spritePiece -$80, -$48, 4, 4, 0, 0, 0, 0, 0
 spritePiece -$80, -$48, 4, 4, 0, 0, 0, 0, 0
 spritePiece -$80, -$48, 4, 4, 0, 0, 0, 0, 0
 spritePiece -$80, -$48, 4, 4, 0, 0, 0, 0, 0
 spritePiece -$80, -$48, 4, 4, 0, 0, 0, 0, 0
 spritePiece -$80, -$48, 4, 4, 0, 0, 0, 0, 0
 spritePiece -$80, -$28, 4, 4, 0, 0, 0, 0, 0
 spritePiece -$80, -$28, 4, 4, 0, 0, 0, 0, 0
 spritePiece -$80, -$28, 4, 4, 0, 0, 0, 0, 0
 spritePiece -$80, -$28, 4, 4, 0, 0, 0, 0, 0
 spritePiece -$80, -$28, 4, 4, 0, 0, 0, 0, 0
 spritePiece -$80, -$28, 4, 4, 0, 0, 0, 0, 0
 spritePiece -$80, -$28, 4, 4, 0, 0, 0, 0, 0
 spritePiece -$80, -$28, 4, 4, 0, 0, 0, 0, 0
 spritePiece -$80, -$28, 4, 4, 0, 0, 0, 0, 0
 spritePiece -$80, -$28, 4, 4, 0, 0, 0, 0, 0
 spritePiece -$80, -8, 4, 4, 0, 0, 0, 0, 0
 spritePiece -$80, -8, 4, 4, 0, 0, 0, 0, 0
 spritePiece -$80, -8, 4, 4, 0, 0, 0, 0, 0
 spritePiece -$80, -8, 4, 4, 0, 0, 0, 0, 0
 spritePiece -$80, -8, 4, 4, 0, 0, 0, 0, 0
 spritePiece -$80, -8, 4, 4, 0, 0, 0, 0, 0
 spritePiece -$80, -8, 4, 4, 0, 0, 0, 0, 0
 spritePiece -$80, -8, 4, 4, 0, 0, 0, 0, 0
 spritePiece -$80, -8, 4, 4, 0, 0, 0, 0, 0
 spritePiece -$80, -8, 4, 4, 0, 0, 0, 0, 0
M_PSB_Limiter_End

M_PSB_TM:	spriteHeader							; "TM"
 spritePiece -8, -4, 2, 1, 0, 0, 0, 0, 0
M_PSB_TM_End

M_Menu_NewGame:	spriteHeader						; "> NEW GAME <"
 spritePiece $28, 0, 3, 1, $FD, 0, 0, 0, 0
 spritePiece $48, 0, 4, 1, $100, 0, 0, 0, 0
 spritePiece $2A, $10, 4, 1, $104, 0, 0, 0, 0
 spritePiece $4A, $10, 1, 1, $108, 0, 0, 0, 0
 spritePiece $4D, $10, 3, 1, $109, 0, 0, 0, 0
 spritePiece $10, 0, 2, 1, $10C, 0, 0, 0, 0
 spritePiece $70, 0, 2, 1, $10C, 0, 0, 0, 0
M_Menu_NewGame_End

M_Menu_Continue:	spriteHeader					; "> CONTINUE <"
 spritePiece $28, 0, 3, 1, $FD, 0, 0, 0, 0
 spritePiece $48, 0, 4, 1, $100, 0, 0, 0, 0
 spritePiece $2A, $10, 4, 1, $104, 0, 0, 0, 0
 spritePiece $4A, $10, 1, 1, $108, 0, 0, 0, 0
 spritePiece $4D, $10, 3, 1, $109, 0, 0, 0, 0
 spritePiece $10, $10, 2, 1, $10C, 0, 0, 0, 0
 spritePiece $70, $10, 2, 1, $10C, 0, 0, 0, 0
M_Menu_Continue_End

	even