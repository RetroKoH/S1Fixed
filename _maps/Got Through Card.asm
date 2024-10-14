; ---------------------------------------------------------------------------
; Sprite mappings - "SONIC HAS PASSED" title card
; ---------------------------------------------------------------------------
Map_Got:	mappingsTable
	mappingsTableEntry.w	M_Got_SonicHas
	mappingsTableEntry.w	M_Got_Passed
	mappingsTableEntry.w	M_Got_Score
	mappingsTableEntry.w	M_Got_TBonus
	mappingsTableEntry.w	M_Got_RBonus
; These mappings are taken straight from the title card mappings
	mappingsTableEntry.w	M_Card_Oval
	mappingsTableEntry.w	M_Card_Act1
	mappingsTableEntry.w	M_Card_Act2
	mappingsTableEntry.w	M_Card_Act3

M_Got_SonicHas:	spriteHeader		; SONIC HAS
	spritePiece	-$48, -8, 2, 2, $3E, 0, 0, 0, 0
	spritePiece	-$38, -8, 2, 2, $32, 0, 0, 0, 0
	spritePiece	-$28, -8, 2, 2, $2E, 0, 0, 0, 0
	spritePiece	-$18, -8, 1, 2, $20, 0, 0, 0, 0
	spritePiece	-$10, -8, 2, 2, 8, 0, 0, 0, 0
	spritePiece	$10, -8, 2, 2, $1C, 0, 0, 0, 0
	spritePiece	$20, -8, 2, 2, 0, 0, 0, 0, 0
	spritePiece	$30, -8, 2, 2, $3E, 0, 0, 0, 0
M_Got_SonicHas_End

M_Got_Passed:	spriteHeader		; PASSED
	spritePiece	-$30, -8, 2, 2, $36, 0, 0, 0, 0
	spritePiece	-$20, -8, 2, 2, 0, 0, 0, 0, 0
	spritePiece	-$10, -8, 2, 2, $3E, 0, 0, 0, 0
	spritePiece	0, -8, 2, 2, $3E, 0, 0, 0, 0
	spritePiece	$10, -8, 2, 2, $10, 0, 0, 0, 0
	spritePiece	$20, -8, 2, 2, $C, 0, 0, 0, 0
M_Got_Passed_End

M_Got_Score:	spriteHeader		; SCORE
	spritePiece	-$50, -8, 4, 2, $162, 0, 0, 0, 0	; SCOR
	spritePiece	-$30, -8, 1, 2, $176, 0, 0, 0, 0	; E - USE TIME's E SO IT WONT GET OVERWRITTEN BY DEBUG
	spritePiece	$18, -8, 3, 2, $17A, 0, 0, 0, 0		; SCORE VALUE
	spritePiece	$30, -8, 4, 2, $180, 0, 0, 0, 0		; SCORE VALUE
	spritePiece	-$33, -9, 2, 1, $6E, 0, 0, 0, 0		; Small oval
	spritePiece	-$33, -1, 2, 1, $6E, 1, 1, 0, 0		; Small oval
M_Got_Score_End

M_Got_TBonus:	spriteHeader		; TIME BONUS
	spritePiece	-$50, -8, 4, 2, $170, 0, 0, 0, 0	; TIME
	spritePiece	-$27, -8, 4, 2, $66, 0, 0, 0, 0		; BONU
	spritePiece	-7, -8, 1, 2, $162, 0, 0, 0, 0		; S - USE SCORE's S
	spritePiece	-$A, -9, 2, 1, $6E, 0, 0, 0, 0		; Small oval
	spritePiece	-$A, -1, 2, 1, $6E, 1, 1, 0, 0		; Small oval
	spritePiece	$28, -8, 4, 2, $148, 0, 0, 0, 0		; TIME BONUS VALUE
	spritePiece	$48, -8, 1, 2, $186, 0, 0, 0, 0		; 0
M_Got_TBonus_End

M_Got_RBonus:	spriteHeader		; RING BONUS
	spritePiece	-$50, -8, 4, 2, $168, 0, 0, 0, 0	; RING
	spritePiece	-$27, -8, 4, 2, $66, 0, 0, 0, 0		; BONU
	spritePiece	-7, -8, 1, 2, $162, 0, 0, 0, 0		; S - USE SCORE's S
	spritePiece	-$A, -9, 2, 1, $6E, 0, 0, 0, 0		; Small oval
	spritePiece	-$A, -1, 2, 1, $6E, 1, 1, 0, 0		; Small oval
	spritePiece	$28, -8, 4, 2, $150, 0, 0, 0, 0		; RING BONUS VALUE
	spritePiece	$48, -8, 1, 2, $186, 0, 0, 0, 0		; 0
M_Got_RBonus_End

	even