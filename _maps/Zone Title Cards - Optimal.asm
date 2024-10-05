; ---------------------------------------------------------------------------
; Sprite mappings - zone title cards (Optimized by RetroKoH)
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
	spritePiece	-$4C, -8, 4, 2, 0, 0, 0, 0, 0		; GR
	spritePiece	-$2C, -8, 2, 2, 8, 0, 0, 0, 0		; E
	spritePiece	-$1C, -8, 4, 2, 8, 0, 0, 0, 0		; EN

	spritePiece	$14, -8, 3, 2, $10, 0, 0, 0, 0		; HI
	spritePiece	$2C, -8, 4, 2, $16, 0, 0, 0, 0		; LL
M_Card_GHZ_End
	even

M_Card_LZ:	spriteHeader		; LABYRINTH
	spritePiece	-$44, -8, 4, 2, 0, 0, 0, 0, 0		; LA
	spritePiece	-$24, -8, 4, 2, 8, 0, 0, 0, 0		; BY
	spritePiece	-4, -8, 3, 2, $10, 0, 0, 0, 0		; RI
	spritePiece	$14, -8, 4, 2, $16, 0, 0, 0, 0		; NT
	spritePiece	$34, -8, 2, 2, $1E, 0, 0, 0, 0		; H
M_Card_LZ_End
	even

M_Card_MZ:	spriteHeader		; MARBLE
	spritePiece	-$31, -8, 4, 2, 0, 0, 0, 0, 0		; MA
	spritePiece	-$10, -8, 4, 2, 8, 0, 0, 0, 0		; RB
	spritePiece	 $10, -8, 4, 2, $10, 0, 0, 0, 0		; LE
M_Card_MZ_End
	even

M_Card_SLZ:	spriteHeader		; STAR LIGHT
	spritePiece	-$4C, -8, 4, 2, 0, 0, 0, 0, 0		; ST
	spritePiece	-$2C, -8, 4, 2, 8, 0, 0, 0, 0		; AR

	spritePiece	4, -8, 3, 2, $10, 0, 0, 0, 0		; LI
	spritePiece	$1C, -8, 4, 2, $16, 0, 0, 0, 0		; GH
	spritePiece	$3C, -8, 2, 2, 4, 0, 0, 0, 0		; T
M_Card_SLZ_End
	even

M_Card_SYZ:	spriteHeader		; SPRING YARD
	spritePiece	-$54, -8, 4, 2, 0, 0, 0, 0, 0		; SP
	spritePiece	-$34, -8, 2, 2, $1A, 0, 0, 0, 0		; R
	spritePiece	-$24, -8, 3, 2, 8, 0, 0, 0, 0		; IN
	spritePiece	-$C, -8, 2, 2, $E, 0, 0, 0, 0		; G

	spritePiece	$14, -8, 4, 2, $12, 0, 0, 0, 0		; YA
	spritePiece	$34, -8, 4, 2, $1A, 0, 0, 0, 0		; RD
M_Card_SYZ_End
	even

M_Card_SBZ:	spriteHeader		; SCRAP BRAIN
	spritePiece	-$54, -8, 4, 2, 0, 0, 0, 0, 0		; SC
	spritePiece	-$34, -8, 4, 2, 8, 0, 0, 0, 0		; RA
	spritePiece	-$14, -8, 2, 2, $10, 0, 0, 0, 0		; P

	spritePiece	$C, -8, 2, 2, $14, 0, 0, 0, 0		; B
	spritePiece	$1C, -8, 4, 2, 8, 0, 0, 0, 0		; RA
	spritePiece	$3C, -8, 3, 2, $18, 0, 0, 0, 0		; IN
M_Card_SBZ_End
	even

M_Card_Zone:	spriteHeader		; ZONE (starts at $22)
	spritePiece	-$20, -8, 4, 2, $22, 0, 0, 0, 0
	spritePiece	0, -8, 4, 2, $2A, 0, 0, 0, 0
M_Card_Zone_End
	even

M_Card_Act1:	spriteHeader		; ACT 1 (starts at $32)
	spritePiece	-$14, 4, 3, 1, $32, 0, 0, 0, 0
	spritePiece	$C, -$C, 1, 3, $35, 0, 0, 0, 0
M_Card_Act1_End

M_Card_Act2:	spriteHeader		; ACT 2
	spritePiece	-$14, 4, 3, 1, $32, 0, 0, 0, 0
	spritePiece	8, -$C, 2, 3, $38, 0, 0, 0, 0
M_Card_Act2_End

M_Card_Act3:	spriteHeader		; ACT 3
	spritePiece	-$14, 4, 3, 1, $32, 0, 0, 0, 0
	spritePiece	8, -$C, 2, 3, $3E, 0, 0, 0, 0
M_Card_Act3_End

M_Card_Oval:	spriteHeader		; Oval (starts at $44)
	spritePiece	-$C, -$1C, 4, 1, $44, 0, 0, 0, 0
	spritePiece	$14, -$1C, 1, 3, $48, 0, 0, 0, 0
	spritePiece	-$14, -$14, 2, 1, $4B, 0, 0, 0, 0
	spritePiece	-$1C, -$C, 2, 2, $4D, 0, 0, 0, 0
	spritePiece	-$14, $14, 4, 1, $44, 1, 1, 0, 0
	spritePiece	-$1C, 4, 1, 3, $48, 1, 1, 0, 0
	spritePiece	4, $C, 2, 1, $4B, 1, 1, 0, 0
	spritePiece	$C, -4, 2, 2, $4D, 1, 01, 0, 0
	spritePiece	-4, -$14, 3, 1, $51, 0, 0, 0, 0
	spritePiece	-$C, -$C, 4, 1, $50, 0, 0, 0, 0
	spritePiece	-$C, -4, 3, 1, $50, 0, 0, 0, 0
	spritePiece	-$14, 4, 4, 1, $50, 0, 0, 0, 0
	spritePiece	-$14, $C, 3, 1, $50, 0, 0, 0, 0
M_Card_Oval_End
	even

M_Card_FZ:	spriteHeader		; FINAL
	spritePiece	-$24, -8, 3, 2, 0, 0, 0, 0, 0		; FI
	spritePiece	-$C, -8, 4, 2, 6, 0, 0, 0, 0		; NA
	spritePiece	$14, -8, 2, 2, $E, 0, 0, 0, 0		; L
M_Card_FZ_End
	even