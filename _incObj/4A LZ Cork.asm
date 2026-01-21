; ---------------------------------------------------------------------------
; Object 61 - floating corks (LZ)
; Split from Obj61 by RetroKoH (Special Thanks: Hivebrain)
; ---------------------------------------------------------------------------

LZCork:
		_move.l	#Cork_Action,obAddr(a0)
		move.l	#Map_Cork,obMap(a0)
		move.w	#make_art_tile(ArtTile_LZ_Cork,2,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority3,obPriority(a0)				; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$10,obDispWid(a0)						; set width
		move.b	#$10,obHeight(a0)						; set height
; ---------------------------------------------------------------------------

Cork_Action:
	; Make the cork float to the water's surface (run directly instead of calling a subroutine)
		move.w	(v_waterpos_actual).w,d0
		sub.w	obY(a0),d0								; is block level with water?
		beq.s	.stop									; if yes, branch
		bcc.s	.fall									; branch if block is above water
		cmpi.w	#-2,d0									; is block within 2 pixels of water surface?
		bge.s	.near_surface							; if yes, branch
		moveq	#-2,d0									; set maximum rate for block rising

	.near_surface:
		add.w	d0,obY(a0)								; make the block rise with water level
		bsr.w	ObjHitCeiling
		tst.w	d1										; has block hit the ceiling?
		bpl.s	.stop									; if not, branch
		sub.w	d1,obY(a0)								; stop block
		bra.s	.stop
; ===========================================================================

	.fall:
		cmpi.w	#2,d0									; is block within 2 pixels of water surface?
		ble.s	.near_surface2							; if yes, branch
		moveq	#2,d0									; set maximum rate for block sinking

	.near_surface2:
		add.w	d0,obY(a0)								; make the block sink with water level
		bsr.w	ObjFloorDist
		tst.w	d1										; has block hit the floor?
		bpl.s	.stop									; if not, branch
		addq.w	#1,d1
		add.w	d1,obY(a0)								; stop block

	.stop:
		tst.b	obRender(a0)							; is block on-screen?
		bpl.s	.chkdel									; if not, branch
	
	; make cork solid
		moveq	#27,d1									; width
		moveq	#16,d2									; height (jumping)
		moveq	#17,d3									; height (walking)
		move.w	obX(a0),d4								; axis position
		bsr.w	SolidObject

	.chkdel:
		offscreen.w	DeleteObject						; ProjectFM S3K Object Manager
		bra.w	DisplaySprite
; ===========================================================================