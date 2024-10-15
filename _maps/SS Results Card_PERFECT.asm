; ---------------------------------------------------------------------------
; Sprite mappings - special stage results screen
; ---------------------------------------------------------------------------
Map_SSR:	mappingsTable
	mappingsTableEntry.w	M_SSR_Chaos
	mappingsTableEntry.w	M_SSR_Score
	mappingsTableEntry.w	M_SSR_Ring
	mappingsTableEntry.w	M_Card_Oval
	mappingsTableEntry.w	M_SSR_ContSonic1
	mappingsTableEntry.w	M_SSR_ContSonic2
	mappingsTableEntry.w	M_SSR_Continue
	mappingsTableEntry.w	M_SSR_SpecStage
	mappingsTableEntry.w	M_SSR_GotAll
	mappingsTableEntry.w	M_SSR_Perfect

M_SSR_Chaos:	spriteHeader		; "CHAOS EMERALDS"
	spritePiece	-$70, -8, 2, 2, 8, 0, 0, 0, 0
	spritePiece	-$60, -8, 2, 2, $1C, 0, 0, 0, 0
	spritePiece	-$50, -8, 2, 2, 0, 0, 0, 0, 0
	spritePiece	-$40, -8, 2, 2, $32, 0, 0, 0, 0
	spritePiece	-$30, -8, 2, 2, $3E, 0, 0, 0, 0
	spritePiece	-$10, -8, 2, 2, $10, 0, 0, 0, 0
	spritePiece	0, -8, 2, 2, $2A, 0, 0, 0, 0
	spritePiece	$10, -8, 2, 2, $10, 0, 0, 0, 0
	spritePiece	$20, -8, 2, 2, $3A, 0, 0, 0, 0
	spritePiece	$30, -8, 2, 2, 0, 0, 0, 0, 0
	spritePiece	$40, -8, 2, 2, $26, 0, 0, 0, 0
	spritePiece	$50, -8, 2, 2, $C, 0, 0, 0, 0
	spritePiece	$60, -8, 2, 2, $3E, 0, 0, 0, 0
M_SSR_Chaos_End

M_SSR_Score:	spriteHeader		; "SCORE"
	spritePiece	-$50, -8, 4, 2, $162, 0, 0, 0, 0	; SCOR
	spritePiece	-$30, -8, 1, 2, $176, 0, 0, 0, 0	; E - USE TIME's E SO IT WONT GET OVERWRITTEN BY DEBUG
	spritePiece	$18, -8, 3, 2, $17A, 0, 0, 0, 0		; SCORE VALUE
	spritePiece	$30, -8, 4, 2, $180, 0, 0, 0, 0		; SCORE VALUE
	spritePiece	-$33, -9, 2, 1, $6E, 0, 0, 0, 0		; Small oval
	spritePiece	-$33, -1, 2, 1, $6E, 1, 1, 0, 0		; Small oval
M_SSR_Score_End

M_SSR_Ring:	spriteHeader
	spritePiece	-$50, -8, 4, 2, $168, 0, 0, 0, 0	; RING
	spritePiece	-$27, -8, 4, 2, $66, 0, 0, 0, 0		; BONU
	spritePiece	-7, -8, 1, 2, $162, 0, 0, 0, 0		; S - USE SCORE's S
	spritePiece	-$A, -9, 2, 1, $6E, 0, 0, 0, 0		; Small oval
	spritePiece	-$A, -1, 2, 1, $6E, 1, 1, 0, 0		; Small oval
	spritePiece	$28, -8, 4, 2, $150, 0, 0, 0, 0		; RING BONUS VALUE
	spritePiece	$48, -8, 1, 2, $186, 0, 0, 0, 0		; 0
M_SSR_Ring_End

M_SSR_ContSonic1:	spriteHeader
	spritePiece	-$50, -8, 4, 2, $118, 0, 0, 0, 0
	spritePiece	-$30, -8, 4, 2, $120, 0, 0, 0, 0
	spritePiece	-$10, -8, 1, 2, $128, 0, 0, 0, 0
	spritePiece	$40, -8, 2, 3, $12A, 0, 0, 1, 0
M_SSR_ContSonic1_End

M_SSR_ContSonic2:	spriteHeader
	spritePiece	-$50, -8, 4, 2, $118, 0, 0, 0, 0
	spritePiece	-$30, -8, 4, 2, $120, 0, 0, 0, 0
	spritePiece	-$10, -8, 1, 2, $128, 0, 0, 0, 0
	spritePiece	$40, -8, 2, 3, $130, 0, 0, 1, 0
M_SSR_ContSonic2_End

M_SSR_Continue:	spriteHeader
	spritePiece	-$50, -8, 4, 2, $118, 0, 0, 0, 0
	spritePiece	-$30, -8, 4, 2, $120, 0, 0, 0, 0
	spritePiece	-$10, -8, 1, 2, $128, 0, 0, 0, 0
M_SSR_Continue_End

M_SSR_SpecStage:	spriteHeader		; "SPECIAL STAGE"
	spritePiece	-$64, -8, 2, 2, $3E, 0, 0, 0, 0
	spritePiece	-$54, -8, 2, 2, $36, 0, 0, 0, 0
	spritePiece	-$44, -8, 2, 2, $10, 0, 0, 0, 0
	spritePiece	-$34, -8, 2, 2, 8, 0, 0, 0, 0
	spritePiece	-$24, -8, 1, 2, $20, 0, 0, 0, 0
	spritePiece	-$1C, -8, 2, 2, 0, 0, 0, 0, 0
	spritePiece	-$C, -8, 2, 2, $26, 0, 0, 0, 0
	spritePiece	$14, -8, 2, 2, $3E, 0, 0, 0, 0
	spritePiece	$24, -8, 2, 2, $42, 0, 0, 0, 0
	spritePiece	$34, -8, 2, 2, 0, 0, 0, 0, 0
	spritePiece	$44, -8, 2, 2, $18, 0, 0, 0, 0
	spritePiece	$54, -8, 2, 2, $10, 0, 0, 0, 0
M_SSR_SpecStage_End

M_SSR_GotAll:	spriteHeader		; "SONIC GOT THEM ALL"
	spritePiece	-$78, -8, 2, 2, $3E, 0, 0, 0, 0
	spritePiece	-$68, -8, 2, 2, $32, 0, 0, 0, 0
	spritePiece	-$58, -8, 2, 2, $2E, 0, 0, 0, 0
	spritePiece	-$48, -8, 1, 2, $20, 0, 0, 0, 0
	spritePiece	-$40, -8, 2, 2, 8, 0, 0, 0, 0
	spritePiece	-$28, -8, 2, 2, $18, 0, 0, 0, 0
	spritePiece	-$18, -8, 2, 2, $32, 0, 0, 0, 0
	spritePiece	-8, -8, 2, 2, $42, 0, 0, 0, 0
	spritePiece	$10, -8, 2, 2, $42, 0, 0, 0, 0
	spritePiece	$20, -8, 2, 2, $1C, 0, 0, 0, 0
	spritePiece	$30, -8, 2, 2, $10, 0, 0, 0, 0
	spritePiece	$40, -8, 2, 2, $2A, 0, 0, 0, 0
	spritePiece	$58, -8, 2, 2, 0, 0, 0, 0, 0
	spritePiece	$68, -8, 2, 2, $26, 0, 0, 0, 0
	spritePiece	$78, -8, 2, 2, $26, 0, 0, 0, 0
M_SSR_GotAll_End

M_SSR_Perfect:	spriteHeader
	spritePiece	-$50, -8, 4, 2, $108, 0, 0, 0, 0	; PERF
	spritePiece	-$30, -8, 3, 2, $110, 0, 0, 0, 0	; ECT
	spritePiece	-$24, -9, 2, 1, $6E, 0, 0, 0, 0		; Small oval
	spritePiece	-$24, -1, 2, 1, $6E, 1, 1, 0, 0		; Small oval
	spritePiece	$28, -8, 4, 2, $140, 0, 0, 0, 0		; PERFECT BONUS VALUE
	spritePiece	$48, -8, 1, 2, $186, 0, 0, 0, 0		; 0
M_SSR_Perfect_End

	even