; ---------------------------------------------------------------------------
; Object 7F - chaos emeralds from the special stage results screen
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
; X-axis positions for chaos emeralds
; ---------------------------------------------------------------------------

	if ~~SuperMod
SSRC_PosData:
	; 6 emeralds
		dc.w $110	; blue
		dc.w $128	; yellow
		dc.w $F8	; pink
		dc.w $140	; green
		dc.w $E0	; red
		dc.w $158	; gray
	else
SSRC_PosData:
	; 7 emeralds
		dc.w $120	; blue
		dc.w $138	; yellow
		dc.w $108	; pink
		dc.w $150	; green
		dc.w $F0	; red
		dc.w $168	; gray
		dc.w $D8	; cyan
	endif
; ===========================================================================

SSRChaos:
	; LavaGaming Object Routine Optimization
		tst.b	obRoutine(a0)
		bne.s	SSRC_Flash
	; Object Routine Optimization End
; ---------------------------------------------------------------------------

SSRC_Main:	; Routine 0
		movea.l	a0,a1						; replace current object with 1st emerald
		lea		(SSRC_PosData).l,a2
		moveq	#0,d1
		moveq	#0,d2
		move.b	(v_emeralds).w,d1			; d1 is number of emeralds
		subq.b	#1,d1						; subtract 1 from d1
		bcs.w	DeleteObject				; if you have 0	emeralds, branch
		move.b	(v_emldlist).w,d3			; d3 is the array stating which emeralds we have

	.loop:
		btst	d2,d3						; did you get the emerald?
		beq.s   .noemerald					; if not, skip and check for the next emerald

		_move.b	#id_SSRChaos,obID(a1)
		move.w	(a2)+,obX(a1)				; set x-position
		move.w	#$F0,obScreenY(a1)			; set y-position
		move.b	d2,obFrame(a1)				; get list of individual emeralds (numbered 0 to 5/6)
		move.b	d2,obAnim(a1)				; read value of current emerald
		addq.b	#2,obRoutine(a1)			; -> SSRC_Flash
		move.l	#Map_SSRC,obMap(a1)
		move.w	#make_art_tile(ArtTile_SS_Results_Emeralds,0,1),obGfx(a1)
		clr.b	obRender(a1)
		move.w	#priority0,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		lea		object_size(a1),a1			; next object
		addq.b  #1,d2						; check for the next emerald
		dbf		d1,.loop					; loop for d1 number of	emeralds

		bra.s	SSRC_Flash
; ===========================================================================

	.noemerald:
		addq.b	#1,d2						; check for the next emerald
		addq.b  #1,d1						; +1 to the loop, to continue checking for the rest of the emeralds
		dbf		d1,.loop					; loop for d1 number of	emeralds
; ---------------------------------------------------------------------------

SSRC_Flash:	; Routine 2
		move.b	obFrame(a0),d0				; get previous frame
		move.b	#emldCount,obFrame(a0)		; load 6th/7th frame (blank)
		cmpi.b	#emldCount,d0				; was previous frame blank?
		bne.w	DisplaySprite				; if not, branch
		move.b	obAnim(a0),obFrame(a0)		; load visible frame
		bra.w	DisplaySprite
; ===========================================================================