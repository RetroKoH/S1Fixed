; ---------------------------------------------------------------------------
; Sprite mappings - SCORE, TIME, RINGS
; RetroKoH VRAM Overhaul
; ---------------------------------------------------------------------------
Map_HUD_internal:	mappingsTable
		mappingsTableEntry.w	.allyellow
		mappingsTableEntry.w	.ringred
		mappingsTableEntry.w	.timered
		mappingsTableEntry.w	.allred

.allyellow:	spriteHeader
		spritePiece	0, -$80, 4, 2, 0, 0, 0, 0, 1		; SCOR
		spritePiece	$20, -$80, 4, 2, $16, 0, 0, 0, 1	; E ###
		spritePiece	$40, -$80, 4, 2, $1E, 0, 0, 0, 1	; ####
		spritePiece	0, -$70, 4, 2, $E, 0, 0, 0, 1		; TIME
		spritePiece	$28, -$70, 4, 2, $26, 0, 0, 0, 1	; #:##
		spritePiece	0, -$60, 4, 2, 6, 0, 0, 0, 1		; RING
		spritePiece	$20, -$60, 1, 2, 0, 0, 0, 0, 1		; S
		spritePiece	$30, -$60, 3, 2, $2E, 0, 0, 0, 1	; ###
		spritePiece	0, $40, 2, 2, $10A, 0, 0, 0, 1		; Lives Icon
		spritePiece	$10, $40, 4, 2, $10E, 0, 0, 0, 1	; Lives x ##
.allyellow_End
	even

.ringred:	spriteHeader
		spritePiece	0, -$80, 4, 2, 0, 0, 0, 0, 1		; SCOR
		spritePiece	$20, -$80, 4, 2, $16, 0, 0, 0, 1	; E ###
		spritePiece	$40, -$80, 4, 2, $1E, 0, 0, 0, 1	; ####
		spritePiece	0, -$70, 4, 2, $E, 0, 0, 0, 1		; TIME
		spritePiece	$28, -$70, 4, 2, $26, 0, 0, 0, 1	; #:##
		spritePiece	0, -$60, 4, 2, 6, 0, 0, 1, 1		; RING
		spritePiece	$20, -$60, 1, 2, 0, 0, 0, 1, 1		; S
		spritePiece	$30, -$60, 3, 2, $2E, 0, 0, 0, 1	; ###
		spritePiece	0, $40, 2, 2, $10A, 0, 0, 0, 1		; Lives Icon
		spritePiece	$10, $40, 4, 2, $10E, 0, 0, 0, 1	; Lives x ##
.ringred_End
	even

.timered:	spriteHeader
		spritePiece	0, -$80, 4, 2, 0, 0, 0, 0, 1
		spritePiece	$20, -$80, 4, 2, $16, 0, 0, 0, 1
		spritePiece	$40, -$80, 4, 2, $1E, 0, 0, 0, 1
		spritePiece	0, -$70, 4, 2, $E, 0, 0, 1, 1
		spritePiece	$28, -$70, 4, 2, $26, 0, 0, 0, 1
		spritePiece	0, -$60, 4, 2, 6, 0, 0, 0, 1
		spritePiece	$20, -$60, 1, 2, 0, 0, 0, 0, 1
		spritePiece	$30, -$60, 3, 2, $2E, 0, 0, 0, 1
		spritePiece	0, $40, 2, 2, $10A, 0, 0, 0, 1
		spritePiece	$10, $40, 4, 2, $10E, 0, 0, 0, 1
.timered_End
	even

.allred:	spriteHeader
		spritePiece	0, -$80, 4, 2, 0, 0, 0, 0, 1
		spritePiece	$20, -$80, 4, 2, $16, 0, 0, 0, 1
		spritePiece	$40, -$80, 4, 2, $1E, 0, 0, 0, 1
		spritePiece	0, -$70, 4, 2, $E, 0, 0, 1, 1
		spritePiece	$28, -$70, 4, 2, $26, 0, 0, 0, 1
		spritePiece	0, -$60, 4, 2, 6, 0, 0, 1, 1
		spritePiece	$20, -$60, 1, 2, 0, 0, 0, 1, 1
		spritePiece	$30, -$60, 3, 2, $2E, 0, 0, 0, 1
		spritePiece	0, $40, 2, 2, $10A, 0, 0, 0, 1
		spritePiece	$10, $40, 4, 2, $10E, 0, 0, 0, 1
.allred_End
	even
