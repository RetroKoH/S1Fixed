; ---------------------------------------------------------------------------
; Sprite mappings - special stage results screen
; ---------------------------------------------------------------------------
Map_SSR:	mappingsTable
	mappingsTableEntry.w	M_SSR_Chaos
	mappingsTableEntry.w	M_SSR_Score
	mappingsTableEntry.w	M_SSR_Ring
	mappingsTableEntry.w	M_Card_Oval			; Recycled from Zone Title Cards
	mappingsTableEntry.w	M_SSR_ContSonic1
	mappingsTableEntry.w	M_SSR_ContSonic2
	mappingsTableEntry.w	M_SSR_Continue
	mappingsTableEntry.w	M_SSR_SpecStage
	mappingsTableEntry.w	M_SSR_GotAll

M_SSR_Chaos:	spriteHeader		; "CHAOS EMERALDS"
	spritePiece	-$70, -8, 4, 2, 0, 0, 0, 0, 0		; CH
	spritePiece	-$50, -8, 2, 2, $1C, 0, 0, 0, 0		; A
	spritePiece	-$40, -8, 4, 2, 8, 0, 0, 0, 0		; OS

	spritePiece	-$10, -8, 2, 2, $14, 0, 0, 0, 0		; E
	spritePiece	0, -8, 4, 2, $10, 0, 0, 0, 0		; ME
	spritePiece	$20, -8, 4, 2, $18, 0, 0, 0, 0		; RA
	spritePiece	$40, -8, 4, 2, $20, 0, 0, 0, 0		; LD
	spritePiece	$60, -8, 2, 2, $C, 0, 0, 0, 0		; S
M_SSR_Chaos_End

; BONUS tiles start at $32
M_SSR_Score:	spriteHeader		; "SCORE"
	spritePiece	-$50, -8, 4, 2, $162, 0, 0, 0, 0	; SCOR
	spritePiece	-$30, -8, 1, 2, $176, 0, 0, 0, 0	; E - USE TIME's E SO IT WONT GET OVERWRITTEN BY DEBUG
	spritePiece	$18, -8, 3, 2, $17A, 0, 0, 0, 0		; SCORE VALUE
	spritePiece	$30, -8, 4, 2, $180, 0, 0, 0, 0		; SCORE VALUE
	spritePiece	-$33, -9, 2, 1, $32, 0, 0, 0, 0		; Small oval
	spritePiece	-$33, -1, 2, 1, $32, 1, 1, 0, 0		; Small oval
M_SSR_Score_End

M_SSR_Ring:	spriteHeader
	spritePiece	-$50, -8, 4, 2, $168, 0, 0, 0, 0	; RING
	spritePiece	-$27, -8, 4, 2, $34, 0, 0, 0, 0		; BONU
	spritePiece	-7, -8, 1, 2, $162, 0, 0, 0, 0		; S - USE SCORE's S
	spritePiece	-$A, -9, 2, 1, $32, 0, 0, 0, 0		; Small oval
	spritePiece	-$A, -1, 2, 1, $32, 1, 1, 0, 0		; Small oval
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
	spritePiece	-$64, -8, 4, 2, 0, 0, 0, 0, 0		; SP
	spritePiece	-$44, -8, 4, 2, $C, 0, 0, 0, 0		; EC
	spritePiece	-$24, -8, 1, 2, $14, 0, 0, 0, 0		; I
	spritePiece	-$1C, -8, 4, 2, $1A, 0, 0, 0, 0		; AL

	spritePiece	$14, -8, 2, 2, 0, 0, 0, 0, 0		; S
	spritePiece	$24, -8, 4, 2, $16, 0, 0, 0, 0		; TA
	spritePiece	$44, -8, 4, 2, 8, 0, 0, 0, 0		; GE
M_SSR_SpecStage_End

M_SSR_GotAll:	spriteHeader		; "SONIC GOT THEM ALL"
	spritePiece	-$78, -8, 4, 2, 0, 0, 0, 0, 0		; SO
	spritePiece	-$58, -8, 3, 2, 8, 0, 0, 0, 0		; NI
	spritePiece	-$40, -8, 2, 2, $E, 0, 0, 0, 0		; C

loc_gta: = $12
; GOT THEM ALL tiles start at $12
; (This offset may change if other characters are added)
	spritePiece	-$28, -8, 4, 2, loc_gta, 0, 0, 0, 0		; GO
	spritePiece	-8, -8, 2, 2, loc_gta+8, 0, 0, 0, 0		; T

	spritePiece	$10, -8, 4, 2, loc_gta+8, 0, 0, 0, 0	; TH
	spritePiece	$30, -8, 4, 2, loc_gta+$10, 0, 0, 0, 0	; EM

	spritePiece	$58, -8, 4, 2, loc_gta+$18, 0, 0, 0, 0	; AL
	spritePiece	$78, -8, 2, 2, loc_gta+$1C, 0, 0, 0, 0	; L
M_SSR_GotAll_End

	even