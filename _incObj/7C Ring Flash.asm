; ---------------------------------------------------------------------------
; Object 7C - flash effect when	you collect the	giant ring
; ---------------------------------------------------------------------------

RingFlash:
	; LavaGaming Object Routine Optimization
		move.b	obRoutine(a0),d0
		cmpi.b	#2,d0
		beq.w	Flash_ChkDel	; routine = 2
		
		tst.b	d0
		bne.w	DeleteObject	; routine = 4
	; Object Routine Optimization End

Flash_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Flash,obMap(a0)
		move.w	#make_art_tile(ArtTile_Giant_Ring_Flash,1,0),obGfx(a0)
		ori.b	#4,obRender(a0)
		move.w	#priority0,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$20,obActWid(a0)
		move.b	#$FF,obFrame(a0)

Flash_ChkDel:	; Routine 2
		bsr.s	Flash_Collect
		offscreen.w	DeleteObject			; ProjectFM S3K Objects Manager
		bra.w	DisplaySprite

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Flash_Collect:
		subq.b	#1,obTimeFrame(a0)
		bpl.s	locret_9F76
		move.b	#1,obTimeFrame(a0)
		addq.b	#1,obFrame(a0)
		cmpi.b	#8,obFrame(a0)			; has animation	finished?
		bhs.s	Flash_End				; if yes, branch
		cmpi.b	#3,obFrame(a0)			; is 3rd frame displayed?
		bne.s	locret_9F76				; if not, branch
		movea.l	objoff_3C(a0),a1		; get parent object address
		move.b	#6,obRoutine(a1)		; delete parent object
		clr.b	(v_player+obAnim).w		; make Sonic invisible
		move.b	#1,(f_bigring).w		; stop Sonic getting bonuses
		andi.b	#~(mask2ndShield+mask2ndInvinc),(v_player+obStatus2nd).w	; Should clear Shield and Invincibility ($FC)

locret_9F76:
		rts	
; ===========================================================================

Flash_End:
		addq.b	#2,obRoutine(a0)
		clr.w	(v_player).w 			; remove Sonic object (clears both ID and render flags)
		addq.l	#4,sp
		rts	
; End of function Flash_Collect
; ===========================================================================
