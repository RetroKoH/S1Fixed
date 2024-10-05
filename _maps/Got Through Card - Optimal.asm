; ---------------------------------------------------------------------------
; Sprite mappings - "SONIC HAS PASSED" title card (Optimized by RetroKoH)
; ---------------------------------------------------------------------------
Map_Got:	mappingsTable
	mappingsTableEntry.w	M_Got_SonicHas
	mappingsTableEntry.w	M_Got_Passed
	mappingsTableEntry.w	M_Got_Score
	mappingsTableEntry.w	M_Got_TBonus
	mappingsTableEntry.w	M_Got_RBonus
	
	if CoolBonusEnabled
		mappingsTableEntry.w	M_Got_CBonus
	endif

; These mappings are taken straight from the title card mappings
	mappingsTableEntry.w	M_Got_Card_Oval
	mappingsTableEntry.w	M_Got_Card_Act1
	mappingsTableEntry.w	M_Got_Card_Act2
	mappingsTableEntry.w	M_Got_Card_Act3

M_Got_SonicHas:	spriteHeader		; SONIC HAS
	spritePiece	-$48, -8, 4, 2, 0, 0, 0, 0, 0		; SO
	spritePiece	-$28, -8, 3, 2, 8, 0, 0, 0, 0		; NI
	spritePiece	-$10, -8, 2, 2, $E, 0, 0, 0, 0		; C

	spritePiece	$10, -8, 2, 2, $12, 0, 0, 0, 0		; H
	spritePiece	$20, -8, 4, 2, $16, 0, 0, 0, 0		; AS
M_Got_SonicHas_End

M_Got_Passed:	spriteHeader		; PASSED
	spritePiece	-$30, -8, 2, 2, $1E, 0, 0, 0, 0		; P
	spritePiece	-$20, -8, 4, 2, $16, 0, 0, 0, 0		; AS
	spritePiece	0, -8, 2, 2, $1A, 0, 0, 0, 0		; S
	spritePiece	$10, -8, 4, 2, $22, 0, 0, 0, 0		; ED
M_Got_Passed_End

; Bonu/Cool and mini oval get loaded right after the HAS PASSED LETTERS, other aspects use the HUD
; Bonuses loaded at $2A, starting w/ mini oval
M_Got_Score:	spriteHeader		; SCORE
	spritePiece	-$50, -8, 4, 2, $162, 0, 0, 0, 0	; SCOR
	spritePiece	-$30, -8, 1, 2, $176, 0, 0, 0, 0	; E - USE TIME's E SO IT WONT GET OVERWRITTEN BY DEBUG
	spritePiece	$18, -8, 3, 2, $17A, 0, 0, 0, 0		; SCORE VALUE
	spritePiece	$30, -8, 4, 2, $180, 0, 0, 0, 0		; SCORE VALUE
	spritePiece	-$33, -9, 2, 1, $4C, 0, 0, 0, 0		; Small oval
	spritePiece	-$33, -1, 2, 1, $4C, 1, 1, 0, 0		; Small oval
M_Got_Score_End

M_Got_TBonus:	spriteHeader		; TIME BONUS
	spritePiece	-$50, -8, 4, 2, $170, 0, 0, 0, 0	; TIME
	spritePiece	-$27, -8, 4, 2, $4E, 0, 0, 0, 0		; BONU
	spritePiece	-7, -8, 1, 2, $162, 0, 0, 0, 0		; S - USE SCORE's S
	spritePiece	-$A, -9, 2, 1, $4C, 0, 0, 0, 0		; Small oval
	spritePiece	-$A, -1, 2, 1, $4C, 1, 1, 0, 0		; Small oval
	spritePiece	$28, -8, 4, 2, $148, 0, 0, 0, 0		; TIME BONUS VALUE
	spritePiece	$48, -8, 1, 2, $186, 0, 0, 0, 0		; 0
M_Got_TBonus_End

M_Got_RBonus:	spriteHeader		; RING BONUS
	spritePiece	-$50, -8, 4, 2, $168, 0, 0, 0, 0	; RING
	spritePiece	-$27, -8, 4, 2, $4E, 0, 0, 0, 0		; BONU
	spritePiece	-7, -8, 1, 2, $162, 0, 0, 0, 0		; S - USE SCORE's S
	spritePiece	-$A, -9, 2, 1, $4C, 0, 0, 0, 0		; Small oval
	spritePiece	-$A, -1, 2, 1, $4C, 1, 1, 0, 0		; Small oval
	spritePiece	$28, -8, 4, 2, $150, 0, 0, 0, 0		; RING BONUS VALUE
	spritePiece	$48, -8, 1, 2, $186, 0, 0, 0, 0		; 0
M_Got_RBonus_End

	if CoolBonusEnabled
M_Got_CBonus:	spriteHeader		; COOL BONUS
	spritePiece	-$50, -8, 4, 2, $56, 0, 0, 0, 0		; COOL
	spritePiece	-$27, -8, 4, 2, $4E, 0, 0, 0, 0		; BONU
	spritePiece	-7, -8, 1, 2, $162, 0, 0, 0, 0		; S - USE SCORE's S
	spritePiece	-$A, -9, 2, 1, $4C, 0, 0, 0, 0		; Small oval
	spritePiece	-$A, -1, 2, 1, $4C, 1, 1, 0, 0		; Small oval
	spritePiece	$28, -8, 4, 2, $158, 0, 0, 0, 0		; COOL BONUS VALUE
	spritePiece	$48, -8, 1, 2, $186, 0, 0, 0, 0		; 0
M_Got_CBonus_End
	endif

M_Got_Card_Oval:	spriteHeader		; Oval (starts at $3C)
	spritePiece	-$C, -$1C, 4, 1, $3C, 0, 0, 0, 0
	spritePiece	$14, -$1C, 1, 3, $40, 0, 0, 0, 0
	spritePiece	-$14, -$14, 2, 1, $43, 0, 0, 0, 0
	spritePiece	-$1C, -$C, 2, 2, $45, 0, 0, 0, 0
	spritePiece	-$14, $14, 4, 1, $3C, 1, 1, 0, 0
	spritePiece	-$1C, 4, 1, 3, $40, 1, 1, 0, 0
	spritePiece	4, $C, 2, 1, $43, 1, 1, 0, 0
	spritePiece	$C, -4, 2, 2, $45, 1, 01, 0, 0
	spritePiece	-4, -$14, 3, 1, $49, 0, 0, 0, 0
	spritePiece	-$C, -$C, 4, 1, $48, 0, 0, 0, 0
	spritePiece	-$C, -4, 3, 1, $48, 0, 0, 0, 0
	spritePiece	-$14, 4, 4, 1, $48, 0, 0, 0, 0
	spritePiece	-$14, $C, 3, 1, $48, 0, 0, 0, 0
M_Got_Card_Oval_End

M_Got_Card_Act1:	spriteHeader		; ACT 1 (starts at $2A)
	spritePiece	-$14, 4, 3, 1, $2A, 0, 0, 0, 0
	spritePiece	$C, -$C, 1, 3, $2D, 0, 0, 0, 0
M_Got_Card_Act1_End

M_Got_Card_Act2:	spriteHeader		; ACT 2
	spritePiece	-$14, 4, 3, 1, $2A, 0, 0, 0, 0
	spritePiece	8, -$C, 2, 3, $30, 0, 0, 0, 0
M_Got_Card_Act2_End

M_Got_Card_Act3:	spriteHeader		; ACT 3
	spritePiece	-$14, 4, 3, 1, $2A, 0, 0, 0, 0
	spritePiece	8, -$C, 2, 3, $36, 0, 0, 0, 0
M_Got_Card_Act3_End

	even