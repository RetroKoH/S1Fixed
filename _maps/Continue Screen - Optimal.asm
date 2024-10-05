; ---------------------------------------------------------------------------
; Sprite mappings - Continue screen
; ---------------------------------------------------------------------------
Map_ContScr:	mappingsTable
	mappingsTableEntry.w	M_Cont_text
	mappingsTableEntry.w	M_Cont_Sonic1
	mappingsTableEntry.w	M_Cont_Sonic2
	mappingsTableEntry.w	M_Cont_Sonic3
	mappingsTableEntry.w	M_Cont_oval
	mappingsTableEntry.w	M_Cont_Mini1
	mappingsTableEntry.w	M_Cont_Mini1
	mappingsTableEntry.w	M_Cont_Mini2

M_Cont_text:	spriteHeader	; "CONTINUE", stars and countdown
; The 1st letter starts at relative offset $68, as opposed to 0 like other card mappings
	spritePiece	-$3C, -8, 4, 2, $68, 0, 0, 0, 0	; CO
	spritePiece	-$1C, -8, 4, 2, $72, 0, 0, 0, 0	; NT
	spritePiece	4, -8, 3, 2, $70, 0, 0, 0, 0	; IN
	spritePiece	$1C, -8, 4, 2, $7A, 0, 0, 0, 0	; UE

	spritePiece	-$18, $38, 2, 2, $21, 0, 0, 1, 0
	spritePiece	8, $38, 2, 2, $21, 0, 0, 1, 0
	spritePiece	-8, $36, 2, 2, $1FC, 0, 0, 0, 0
M_Cont_text_End

M_Cont_Sonic1:	spriteHeader
	spritePiece	-4, 4, 2, 2, $15, 0, 0, 0, 0	; Sonic	on floor
	spritePiece	-$14, -$C, 3, 3, 6, 0, 0, 0, 0
	spritePiece	4, -$C, 2, 3, $F, 0, 0, 0, 0
M_Cont_Sonic1_End

M_Cont_Sonic2:	spriteHeader
	spritePiece	-4, 4, 2, 2, $19, 0, 0, 0, 0	; Sonic	on floor #2
	spritePiece	-$14, -$C, 3, 3, 6, 0, 0, 0, 0
	spritePiece	4, -$C, 2, 3, $F, 0, 0, 0, 0
M_Cont_Sonic2_End

M_Cont_Sonic3:	spriteHeader
	spritePiece	-4, 4, 2, 2, $1D, 0, 0, 0, 0	; Sonic	on floor #3
	spritePiece	-$14, -$C, 3, 3, 6, 0, 0, 0, 0
	spritePiece	4, -$C, 2, 3, $F, 0, 0, 0, 0
M_Cont_Sonic3_End

M_Cont_oval:	spriteHeader
	spritePiece	-$18, $60, 3, 2, 0, 0, 0, 1, 0 ; circle on the floor
	spritePiece	0, $60, 3, 2, 0, 1, 0, 1, 0
M_Cont_oval_End

M_Cont_Mini1:	spriteHeader
	spritePiece	0, 0, 2, 3, $12, 0, 0, 0, 0	; mini Sonic
M_Cont_Mini1_End

M_Cont_Mini2:	spriteHeader
	spritePiece	0, 0, 2, 3, $18, 0, 0, 0, 0	; mini Sonic #2
M_Cont_Mini2_End

	even
