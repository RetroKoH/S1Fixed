; ---------------------------------------------------------------------------
; Sprite mappings - SCORE, TIME, RINGS (Special Stage)
; Mercury HUD Centiseconds + RetroKoH VRAM Overhaul
; ---------------------------------------------------------------------------
Map_HUD_SS:	mappingsTable
		mappingsTableEntry.w	.allyellow
		mappingsTableEntry.w	.ringred
		mappingsTableEntry.w	.timered
		mappingsTableEntry.w	.allred

	; Normal
	if SpecialStageHUDType=0
.allyellow:	spriteHeader
		spritePiece	0, -$80, 4, 2, 0, 0, 0, 0, 1		; SCOR
		spritePiece	$20, -$80, 4, 2, $16, 0, 0, 0, 1	; E ###
		spritePiece	$40, -$80, 4, 2, $1E, 0, 0, 0, 1	; ####
		spritePiece	0, -$70, 4, 2, $E, 0, 0, 0, 1		; TIME
		spritePiece	$28, -$70, 4, 2, $26, 0, 0, 0, 1	; #'##
		spritePiece	$48, -$70, 3, 2, -6, 0, 0, 0, 1		; "##
		spritePiece	0, -$60, 4, 2, 6, 0, 0, 0, 1		; RING
		spritePiece	$20, -$60, 1, 2, 0, 0, 0, 0, 1		; S
		spritePiece	$30, -$60, 3, 2, $2E, 0, 0, 0, 1	; ###
		spritePiece	0, $40, 2, 2, $36, 0, 0, 0, 1		; Lives Icon
		spritePiece	$10, $40, 4, 2, $3A, 0, 0, 0, 1		; Lives x ##
.allyellow_End
	even

.ringred:	spriteHeader
		spritePiece	0, -$80, 4, 2, 0, 0, 0, 0, 1		; SCOR
		spritePiece	$20, -$80, 4, 2, $16, 0, 0, 0, 1	; E ###
		spritePiece	$40, -$80, 4, 2, $1E, 0, 0, 0, 1	; ####
		spritePiece	0, -$70, 4, 2, $E, 0, 0, 0, 1		; TIME
		spritePiece	$28, -$70, 4, 2, $26, 0, 0, 0, 1	; #'##
		spritePiece	$48, -$70, 3, 2, -6, 0, 0, 0, 1		; "##
	if HUDBlinking=0
		spritePiece	0, -$60, 4, 2, 6, 0, 0, 1, 1		; RING
		spritePiece	$20, -$60, 1, 2, 0, 0, 0, 1, 1		; S
	endif
		spritePiece	$30, -$60, 3, 2, $2E, 0, 0, 0, 1	; ###
		spritePiece	0, $40, 2, 2, $36, 0, 0, 0, 1		; Lives Icon
		spritePiece	$10, $40, 4, 2, $3A, 0, 0, 0, 1		; Lives x ##
.ringred_End
	even

.timered:	spriteHeader
		spritePiece	0, -$80, 4, 2, 0, 0, 0, 0, 1		; SCOR
		spritePiece	$20, -$80, 4, 2, $16, 0, 0, 0, 1	; E ###
		spritePiece	$40, -$80, 4, 2, $1E, 0, 0, 0, 1	; ####
	if HUDBlinking=0
		spritePiece	0, -$70, 4, 2, $E, 0, 0, 1, 1		; TIME
	endif
		spritePiece	$28, -$70, 4, 2, $26, 0, 0, 0, 1	; #'##
		spritePiece	$48, -$70, 3, 2, -6, 0, 0, 0, 1		; "##
		spritePiece	0, -$60, 4, 2, 6, 0, 0, 0, 1		; RING
		spritePiece	$20, -$60, 1, 2, 0, 0, 0, 0, 1		; S
		spritePiece	$30, -$60, 3, 2, $2E, 0, 0, 0, 1	; ###
		spritePiece	0, $40, 2, 2, $36, 0, 0, 0, 1		; Lives Icon
		spritePiece	$10, $40, 4, 2, $3A, 0, 0, 0, 1		; Lives x ##
.timered_End
	even

.allred:	spriteHeader
		spritePiece	0, -$80, 4, 2, 0, 0, 0, 0, 1		; SCOR
		spritePiece	$20, -$80, 4, 2, $16, 0, 0, 0, 1	; E ###
		spritePiece	$40, -$80, 4, 2, $1E, 0, 0, 0, 1	; ####
	if HUDBlinking=0
		spritePiece	0, -$70, 4, 2, $E, 0, 0, 1, 1		; TIME
	endif
		spritePiece	$28, -$70, 4, 2, $26, 0, 0, 0, 1	; #'##
		spritePiece	$48, -$70, 3, 2, -6, 0, 0, 0, 1		; "##
	if HUDBlinking=0
		spritePiece	0, -$60, 4, 2, 6, 0, 0, 1, 1		; RING
		spritePiece	$20, -$60, 1, 2, 0, 0, 0, 1, 1		; S
	endif
		spritePiece	$30, -$60, 3, 2, $2E, 0, 0, 0, 1	; ###
		spritePiece	0, $40, 2, 2, $36, 0, 0, 0, 1		; Lives Icon
		spritePiece	$10, $40, 4, 2, $3A, 0, 0, 0, 1		; Lives x ##
.allred_End
	even
	endif

	; Score Missing
	if SpecialStageHUDType=1
.allyellow:	spriteHeader
		spritePiece	0, -$80, 4, 2, $E, 0, 0, 0, 1		; TIME
		spritePiece	$28, -$80, 4, 2, $26, 0, 0, 0, 1	; #'##
		spritePiece	$48, -$80, 3, 2, -6, 0, 0, 0, 1		; "##
		spritePiece	0, -$70, 4, 2, 6, 0, 0, 0, 1		; RING
		spritePiece	$20, -$70, 1, 2, 0, 0, 0, 0, 1		; S
		spritePiece	$30, -$70, 3, 2, $2E, 0, 0, 0, 1	; ###
		spritePiece	0, $40, 2, 2, $36, 0, 0, 0, 1		; Lives Icon
		spritePiece	$10, $40, 4, 2, $3A, 0, 0, 0, 1		; Lives x ##
.allyellow_End
	even

.ringred:	spriteHeader
		spritePiece	0, -$80, 4, 2, $E, 0, 0, 0, 1		; TIME
		spritePiece	$28, -$80, 4, 2, $26, 0, 0, 0, 1	; #'##
		spritePiece	$48, -$80, 3, 2, -6, 0, 0, 0, 1		; "##
	if HUDBlinking=0
		spritePiece	0, -$70, 4, 2, 6, 0, 0, 1, 1		; RING
		spritePiece	$20, -$70, 1, 2, 0, 0, 0, 1, 1		; S
	endif
		spritePiece	$30, -$70, 3, 2, $2E, 0, 0, 0, 1	; ###
		spritePiece	0, $40, 2, 2, $36, 0, 0, 0, 1		; Lives Icon
		spritePiece	$10, $40, 4, 2, $3A, 0, 0, 0, 1		; Lives x ##
.ringred_End
	even

.timered:	spriteHeader
	if HUDBlinking=0
		spritePiece	0, -$80, 4, 2, $E, 0, 0, 1, 1		; TIME
	endif
		spritePiece	$28, -$80, 4, 2, $26, 0, 0, 0, 1	; #'##
		spritePiece	$48, -$80, 3, 2, -6, 0, 0, 0, 1		; "##
		spritePiece	0, -$70, 4, 2, 6, 0, 0, 0, 1		; RING
		spritePiece	$20, -$70, 1, 2, 0, 0, 0, 0, 1		; S
		spritePiece	$30, -$70, 3, 2, $2E, 0, 0, 0, 1	; ###
		spritePiece	0, $40, 2, 2, $36, 0, 0, 0, 1		; Lives Icon
		spritePiece	$10, $40, 4, 2, $3A, 0, 0, 0, 1		; Lives x ##
.timered_End
	even

.allred:	spriteHeader
	if HUDBlinking=0
		spritePiece	0, -$80, 4, 2, $E, 0, 0, 1, 1		; TIME
	endif
		spritePiece	$28, -$80, 4, 2, $26, 0, 0, 0, 1	; #'##
		spritePiece	$48, -$80, 3, 2, -6, 0, 0, 0, 1		; "##
	if HUDBlinking=0
		spritePiece	0, -$70, 4, 2, 6, 0, 0, 1, 1		; RING
		spritePiece	$20, -$70, 1, 2, 0, 0, 0, 1, 1		; S
	endif
		spritePiece	$30, -$70, 3, 2, $2E, 0, 0, 0, 1	; ###
		spritePiece	0, $40, 2, 2, $36, 0, 0, 0, 1		; Lives Icon
		spritePiece	$10, $40, 4, 2, $3A, 0, 0, 0, 1		; Lives x ##
.allred_End
	even
	endif

	; Score and Time Missing
	if SpecialStageHUDType=2
.allyellow:	spriteHeader
		spritePiece	0, -$80, 4, 2, 6, 0, 0, 0, 1		; RING
		spritePiece	$20, -$80, 1, 2, 0, 0, 0, 0, 1		; S
		spritePiece	$30, -$80, 3, 2, $2E, 0, 0, 0, 1	; ###
		spritePiece	0, $40, 2, 2, $36, 0, 0, 0, 1		; Lives Icon
		spritePiece	$10, $40, 4, 2, $3A, 0, 0, 0, 1		; Lives x ##
.allyellow_End
	even

.ringred:	spriteHeader
	if HUDBlinking=0
		spritePiece	0, -$80, 4, 2, 6, 0, 0, 1, 1		; RING
		spritePiece	$20, -$80, 1, 2, 0, 0, 0, 1, 1		; S
	endif
		spritePiece	$30, -$80, 3, 2, $2E, 0, 0, 0, 1	; ###
		spritePiece	0, $40, 2, 2, $36, 0, 0, 0, 1		; Lives Icon
		spritePiece	$10, $40, 4, 2, $3A, 0, 0, 0, 1		; Lives x ##
.ringred_End
	even

.timered:	spriteHeader
		spritePiece	0, -$80, 4, 2, 6, 0, 0, 0, 1		; RING
		spritePiece	$20, -$80, 1, 2, 0, 0, 0, 0, 1		; S
		spritePiece	$30, -$80, 3, 2, $2E, 0, 0, 0, 1	; ###
		spritePiece	0, $40, 2, 2, $36, 0, 0, 0, 1		; Lives Icon
		spritePiece	$10, $40, 4, 2, $3A, 0, 0, 0, 1		; Lives x ##
.timered_End
	even

.allred:	spriteHeader
	if HUDBlinking=0
		spritePiece	0, -$80, 4, 2, 6, 0, 0, 1, 1		; RING
		spritePiece	$20, -$80, 1, 2, 0, 0, 0, 1, 1		; S
	endif
		spritePiece	$30, -$80, 3, 2, $2E, 0, 0, 0, 1	; ###
		spritePiece	0, $40, 2, 2, $36, 0, 0, 0, 1		; Lives Icon
		spritePiece	$10, $40, 4, 2, $3A, 0, 0, 0, 1		; Lives x ##
.allred_End
	even
	endif

	; Rings Only
	if SpecialStageHUDType=3
.allyellow:	spriteHeader
		spritePiece	0, -$80, 4, 2, 6, 0, 0, 0, 1		; RING
		spritePiece	$20, -$80, 1, 2, 0, 0, 0, 0, 1		; S
		spritePiece	$30, -$80, 3, 2, $2E, 0, 0, 0, 1	; ###
.allyellow_End
	even

.ringred:	spriteHeader
	if HUDBlinking=0
		spritePiece	0, -$80, 4, 2, 6, 0, 0, 1, 1		; RING
		spritePiece	$20, -$80, 1, 2, 0, 0, 0, 1, 1		; S
	endif
		spritePiece	$30, -$80, 3, 2, $2E, 0, 0, 0, 1	; ###
.ringred_End
	even

.timered:	spriteHeader
		spritePiece	0, -$80, 4, 2, 6, 0, 0, 0, 1		; RING
		spritePiece	$20, -$80, 1, 2, 0, 0, 0, 0, 1		; S
		spritePiece	$30, -$80, 3, 2, $2E, 0, 0, 0, 1	; ###
.timered_End
	even

.allred:	spriteHeader
	if HUDBlinking=0
		spritePiece	0, -$80, 4, 2, 6, 0, 0, 1, 1		; RING
		spritePiece	$20, -$80, 1, 2, 0, 0, 0, 1, 1		; S
	endif
		spritePiece	$30, -$80, 3, 2, $2E, 0, 0, 0, 1	; ###
.allred_End
	even
	endif