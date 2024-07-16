; ---------------------------------------------------------------------------
; Object 7F - chaos emeralds from the special stage results screen
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
; X-axis positions for chaos emeralds
; ---------------------------------------------------------------------------
	if SuperMod=0
SSRC_PosData:	dc.w $110, $128, $F8, $140, $E0, $158			; 6 emeralds
	else
SSRC_PosData:	dc.w $120, $138, $108, $150, $F0, $168, $D8		; 7 emeralds
	endif
; ===========================================================================

SSRChaos:
	; LavaGaming Object Routine Optimization
		tst.b	obRoutine(a0)
		bne.s	SSRC_Flash
	; Object Routine Optimization End

SSRC_Main:	; Routine 0
		movea.l	a0,a1
		lea		(SSRC_PosData).l,a2
		moveq	#0,d2
		moveq	#0,d1
		move.b	(v_emeralds).w,d1	; d1 is number of emeralds
		subq.b	#1,d1				; subtract 1 from d1
		bcs.w	DeleteObject		; if you have 0	emeralds, branch
		move.b	(v_emldlist).w,d3	; d3 is the array stating which emeralds we have

.loop:
		btst	d2,d3				; Did you get the emerald?
		beq.s   .noemerald			; if not, skip and check for the next emerald

		_move.b	#id_SSRChaos,obID(a1)
		move.w	(a2)+,obX(a1)		; set x-position
		move.w	#$F0,obScreenY(a1)	; set y-position
		move.b	d2,obFrame(a1)
		move.b	d2,obAnim(a1)
		addq.b	#2,obRoutine(a1)
		move.l	#Map_SSRC,obMap(a1)
		move.w	#make_art_tile(ArtTile_SS_Results_Emeralds,0,1),obGfx(a1)
		clr.b	obRender(a1)
		lea		object_size(a1),a1	; next object
		addq.b  #1,d2				; check for the next emerald
		dbf		d1,.loop			; loop for d1 number of	emeralds
		bra.s	SSRC_Flash

.noemerald:
		addq.b	#1,d2				; check for the next emerald
		addq.b  #1,d1				; +1 to the loop, to continue checking for the rest of the emeralds
		dbf		d1,.loop			; loop for d1 number of	emeralds

SSRC_Flash:	; Routine 2
		move.b	obFrame(a0),d0
		move.b	#emldCount,obFrame(a0)	; load 6th/7th frame (blank)
		cmpi.b	#emldCount,d0
		bne.w	DisplaySprite
		move.b	obAnim(a0),obFrame(a0)	; load visible frame
		bra.w	DisplaySprite
