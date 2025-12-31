; ---------------------------------------------------------------------------
; Object 08 - water splash (LZ)
;
; spawned by:
;	SonicPlayer
;
; 38 OST bytes free
; $10-17, $20-22, $25-3F 
; ---------------------------------------------------------------------------
; TO-DO: Init this object along with the Water Surface, and have it appear
; when splashing, and in a hidden state when animation ends.

Splash:
		_move.l	#Spla_Hide,obAddr(a0)
		move.l	#Map_Splash,obMap(a0)
		move.w	#priority1,obPriority(a0)		; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$10,obDispWid(a0)
		move.w	#make_art_tile(ArtTile_Splash,2,0),obGfx(a0)
; ---------------------------------------------------------------------------

Spla_Hide:
		rts										; hide on init, or when animation is complete
; ===========================================================================

Spla_Activate:
		obj_addr	#Spla_Display
		ori.b	#4,obRender(a0)
		move.w	(v_player+obX).w,obX(a0)		; copy X-axis position from Sonic
		clr.w	obAniFrame(a0)					; reset animation and frame duration
; ---------------------------------------------------------------------------

Spla_Display:
		tst.b	obRoutine(a0)					; did animation finish?
		bne.s	.hide							; if yes, branch and hide object
		move.w	(v_waterpos_actual).w,obY(a0)	; copy Y-axis position from water height
		lea		Ani_Splash(pc),a1
		jsr		(AnimateSprite).w
		jmp		(DisplaySprite).l
; ===========================================================================

	.hide:
		clr.b	obRoutine(a0)
		obj_addr	#Spla_Hide
		rts
; ===========================================================================