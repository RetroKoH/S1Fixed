; ---------------------------------------------------------------------------
; Sprite mappings - zone title cards
; ---------------------------------------------------------------------------
Map_Card:	mappingsTable
	mappingsTableEntry.w	M_Card_GHZ
	mappingsTableEntry.w	M_Card_LZ
	mappingsTableEntry.w	M_Card_MZ
	mappingsTableEntry.w	M_Card_SLZ
	mappingsTableEntry.w	M_Card_SYZ
	mappingsTableEntry.w	M_Card_SBZ
	mappingsTableEntry.w	M_Card_Zone
	mappingsTableEntry.w	M_Card_Act1
	mappingsTableEntry.w	M_Card_Act2
	mappingsTableEntry.w	M_Card_Act3
	mappingsTableEntry.w	M_Card_Oval
	mappingsTableEntry.w	M_Card_FZ

M_Card_GHZ:	spriteHeader		; GREEN HILL
	spritePiece	-$4C, -8, 2, 2, $18, 0, 0, 0, 0
	spritePiece	-$3C, -8, 2, 2, $3A, 0, 0, 0, 0
	spritePiece	-$2C, -8, 2, 2, $10, 0, 0, 0, 0
	spritePiece	-$1C, -8, 2, 2, $10, 0, 0, 0, 0
	spritePiece	-$C, -8, 2, 2, $2E, 0, 0, 0, 0
	spritePiece	$14, -8, 2, 2, $1C, 0, 0, 0, 0
	spritePiece	$24, -8, 1, 2, $20, 0, 0, 0, 0
	spritePiece	$2C, -8, 2, 2, $26, 0, 0, 0, 0
	spritePiece	$3C, -8, 2, 2, $26, 0, 0, 0, 0
M_Card_GHZ_End
	even

M_Card_LZ:	spriteHeader		; LABYRINTH
	spritePiece	-$44, -8, 2, 2, $26, 0, 0, 0, 0
	spritePiece	-$34, -8, 2, 2, 0, 0, 0, 0, 0
	spritePiece	-$24, -8, 2, 2, 4, 0, 0, 0, 0
	spritePiece	-$14, -8, 2, 2, $4A, 0, 0, 0, 0
	spritePiece	-4, -8, 2, 2, $3A, 0, 0, 0, 0
	spritePiece	$C, -8, 1, 2, $20, 0, 0, 0, 0
	spritePiece	$14, -8, 2, 2, $2E, 0, 0, 0, 0
	spritePiece	$24, -8, 2, 2, $42, 0, 0, 0, 0
	spritePiece	$34, -8, 2, 2, $1C, 0, 0, 0, 0
M_Card_LZ_End
	even

M_Card_MZ:	spriteHeader		; MARBLE
	spritePiece	-$31, -8, 2, 2, $2A, 0, 0, 0, 0
	spritePiece	-$20, -8, 2, 2, 0, 0, 0, 0, 0
	spritePiece	-$10, -8, 2, 2, $3A, 0, 0, 0, 0
	spritePiece	 0, -8, 2, 2, 4, 0, 0, 0, 0
	spritePiece	 $10, -8, 2, 2, $26, 0, 0, 0, 0
	spritePiece	 $20, -8, 2, 2, $10, 0, 0, 0, 0
M_Card_MZ_End
	even

M_Card_SLZ:	spriteHeader		; STAR LIGHT
	spritePiece	-$4C, -8, 2, 2, $3E, 0, 0, 0, 0
	spritePiece	-$3C, -8, 2, 2, $42, 0, 0, 0, 0
	spritePiece	-$2C, -8, 2, 2, 0, 0, 0, 0, 0
	spritePiece	-$1C, -8, 2, 2, $3A, 0, 0, 0, 0
	spritePiece	4, -8, 2, 2, $26, 0, 0, 0, 0
	spritePiece	$14, -8, 1, 2, $20, 0, 0, 0, 0
	spritePiece	$1C, -8, 2, 2, $18, 0, 0, 0, 0
	spritePiece	$2C, -8, 2, 2, $1C, 0, 0, 0, 0
	spritePiece	$3C, -8, 2, 2, $42, 0, 0, 0, 0
M_Card_SLZ_End
	even

M_Card_SYZ:	spriteHeader		; SPRING YARD
	spritePiece	-$54, -8, 2, 2, $3E, 0, 0, 0, 0
	spritePiece	-$44, -8, 2, 2, $36, 0, 0, 0, 0
	spritePiece	-$34, -8, 2, 2, $3A, 0, 0, 0, 0
	spritePiece	-$24, -8, 1, 2, $20, 0, 0, 0, 0
	spritePiece	-$1C, -8, 2, 2, $2E, 0, 0, 0, 0
	spritePiece	-$C, -8, 2, 2, $18, 0, 0, 0, 0
	spritePiece	$14, -8, 2, 2, $4A, 0, 0, 0, 0
	spritePiece	$24, -8, 2, 2, 0, 0, 0, 0, 0
	spritePiece	$34, -8, 2, 2, $3A, 0, 0, 0, 0
	spritePiece	$44, -8, 2, 2, $C, 0, 0, 0, 0
M_Card_SYZ_End
	even

M_Card_SBZ:	spriteHeader		; SCRAP BRAIN
	spritePiece	-$54, -8, 2, 2, $3E, 0, 0, 0, 0
	spritePiece	-$44, -8, 2, 2, 8, 0, 0, 0, 0
	spritePiece	-$34, -8, 2, 2, $3A, 0, 0, 0, 0
	spritePiece	-$24, -8, 2, 2, 0, 0, 0, 0, 0
	spritePiece	-$14, -8, 2, 2, $36, 0, 0, 0, 0
	spritePiece	$C, -8, 2, 2, 4, 0, 0, 0, 0
	spritePiece	$1C, -8, 2, 2, $3A, 0, 0, 0, 0
	spritePiece	$2C, -8, 2, 2, 0, 0, 0, 0, 0
	spritePiece	$3C, -8, 1, 2, $20, 0, 0, 0, 0
	spritePiece	$44, -8, 2, 2, $2E, 0, 0, 0, 0
M_Card_SBZ_End
	even

M_Card_Zone:	spriteHeader		; ZONE
	spritePiece	-$20, -8, 2, 2, $4E, 0, 0, 0, 0
	spritePiece	-$10, -8, 2, 2, $32, 0, 0, 0, 0
	spritePiece	0, -8, 2, 2, $2E, 0, 0, 0, 0
	spritePiece	$10, -8, 2, 2, $10, 0, 0, 0, 0
M_Card_Zone_End
	even

M_Card_Act1:	spriteHeader		; ACT 1
	spritePiece	-$14, 4, 4, 1, $53, 0, 0, 0, 0
	spritePiece	$C, -$C, 1, 3, $57, 0, 0, 0, 0
M_Card_Act1_End

M_Card_Act2:	spriteHeader		; ACT 2
	spritePiece	-$14, 4, 4, 1, $53, 0, 0, 0, 0
	spritePiece	8, -$C, 2, 3, $5A, 0, 0, 0, 0
M_Card_Act2_End

M_Card_Act3:	spriteHeader		; ACT 3
	spritePiece	-$14, 4, 4, 1, $53, 0, 0, 0, 0
	spritePiece	8, -$C, 2, 3, $60, 0, 0, 0, 0
M_Card_Act3_End

M_Card_Oval:	spriteHeader		; Oval
	spritePiece	-$C, -$1C, 4, 1, $70, 0, 0, 0, 0
	spritePiece	$14, -$1C, 1, 3, $74, 0, 0, 0, 0
	spritePiece	-$14, -$14, 2, 1, $77, 0, 0, 0, 0
	spritePiece	-$1C, -$C, 2, 2, $79, 0, 0, 0, 0
	spritePiece	-$14, $14, 4, 1, $70, 1, 1, 0, 0
	spritePiece	-$1C, 4, 1, 3, $74, 1, 1, 0, 0
	spritePiece	4, $C, 2, 1, $77, 1, 1, 0, 0
	spritePiece	$C, -4, 2, 2, $79, 1, 01, 0, 0
	spritePiece	-4, -$14, 3, 1, $7D, 0, 0, 0, 0
	spritePiece	-$C, -$C, 4, 1, $7C, 0, 0, 0, 0
	spritePiece	-$C, -4, 3, 1, $7C, 0, 0, 0, 0
	spritePiece	-$14, 4, 4, 1, $7C, 0, 0, 0, 0
	spritePiece	-$14, $C, 3, 1, $7C, 0, 0, 0, 0
M_Card_Oval_End
	even

M_Card_FZ:	spriteHeader		; FINAL
	spritePiece	-$24, -8, 2, 2, $14, 0, 0, 0, 0
	spritePiece	-$14, -8, 1, 2, $20, 0, 0, 0, 0
	spritePiece	-$C, -8, 2, 2, $2E, 0, 0, 0, 0
	spritePiece	4, -8, 2, 2, 0, 0, 0, 0, 0
	spritePiece	$14, -8, 2, 2, $26, 0, 0, 0, 0
M_Card_FZ_End
	even