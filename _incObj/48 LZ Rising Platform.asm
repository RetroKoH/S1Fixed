; ---------------------------------------------------------------------------
; Object 48 - rising platform (LZ)
; ---------------------------------------------------------------------------

LZRisePlat:
		_move.l	#LRise_Action,obAddr(a0)
		move.l	#Map_LRise,obMap(a0)
		move.w	#make_art_tile(ArtTile_LZ_Rising_Platform,2,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority3,obPriority(a0)				; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$20,obDispWid(a0)						; set width
		move.b	#$C,obHeight(a0)						; set height
		move.w	obY(a0),obLBlock_StartY(a0)
		move.b	#1,obLBlock_Flag(a0)					; set "untouched" flag
; ---------------------------------------------------------------------------

LRise_Action:	; Routine 2
		tst.b	obSubtype(a0)							; is it already rising?
		bne.s	LRise_Rising
		tst.w	obLBlock_WaitTime(a0)					; does time remain?
		bne.s	.wait									; if yes, branch
		btst	#staSonicOnObj,obStatus(a0)				; is Sonic standing on the object?
		beq.s	LRise_Solid								; if not, branch
		move.w	#30,obLBlock_WaitTime(a0)				; wait for half second
		bra.s	LRise_Solid
; ===========================================================================

	.wait:
		subq.w	#1,obLBlock_WaitTime(a0)				; decrement waiting time
		bne.s	LRise_Solid								; if time remains, branch
		addq.b	#1,obSubtype(a0)						; goto LRise_Type_Sinks_Now or LRise_Type_Rises_Now
		clr.b	obLBlock_Flag(a0)						; flag block as touched
		bra.s	LRise_Solid	
; ===========================================================================

LRise_Rising:
	; !!! Devon Note: Placing this object within Fully Solid tiles breaks this
	; object. See SBZ3 Lower right section after the water tunnel.
	; Make sure to place within Top-Solid tiles if placing in the ground as
	; a trap. Consult Clownacy to see if the Top-Solid tiles were a One-28 error.
		bsr.w	SpeedToPos_YOnly
		
	if LimitLZBlockRisingSpeed	; Mercury Limit LZ Block Rising Speed
		cmpi.w	#-$200,obVelY(a0)
		beq.s	.attopspeed
		subq.w	#8,obVelY(a0)							; make block rise
		
	.attopspeed:
	else
		subq.w	#8,obVelY(a0)							; make block rise
	endif	; Limit LZ Block Rising Speed End
		
		bsr.w	ObjHitCeiling
		tst.w	d1										; has block hit the ceiling?
		bpl.w	LRise_Solid								; if not, branch
		sub.w	d1,obY(a0)								; align to ceiling
		clr.w	obVelY(a0)								; stop when it touches the ceiling
		clr.b	obSubtype(a0)							; set type to 00 (non-moving type)
; ---------------------------------------------------------------------------

LRise_Solid:
		tst.b	obRender(a0)							; is block on-screen?
		bpl.s	.chkdel									; if not, branch
		moveq	#43,d1									; width; save 8 cycles
		moveq	#12,d2									; height (jumping)
		moveq	#13,d3									; height (walking)
		move.w	obX(a0),d4								; axis position
		bsr.w	SolidObject
		bsr.w	LBlk_Sink								; use LZ Block's subroutine

	.chkdel:
		offscreen.w	DeleteObject						; ProjectFM S3K Object Manager
		bra.w	DisplaySprite
; ===========================================================================