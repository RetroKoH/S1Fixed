; ---------------------------------------------------------------------------
; Object - water surface (LZ)
; ---------------------------------------------------------------------------
; OST Constants
obSurf_Freeze:			equ objoff_30				; 1 byte  | flag to freeze animation

	if AltWaterSurface
surf_frames:			equ 2
	else
surf_frames:			equ 3
	endif
; ---------------------------------------------------------------------------

WaterSurface:
		_move.l	#Surf_Action,obAddr(a0)
		move.l	#Map_Surf,obMap(a0)
		move.w	#make_art_tile(ArtTile_LZ_Water_Surface,2,1),obGfx(a0)
		move.b	#4,obRender(a0)
		bset	#renMultiDraw,obRender(a0)			; multi-draw (sub-sprites) flag
		move.b	#$80,mainspr_width(a0)				; width
		move.b	#1,mainspr_childsprites(a0)

	; TomatoWave Subsprite Mod
		lea		subspr_posdata(a0),a2				; starting address for subsprite position data
		move.w	obX(a0),(a2)
		addi.w	#$C0,(a2)+
		move.w	obY(a0),(a2)
	; Subsprite Mod end
; ---------------------------------------------------------------------------

Surf_Action:
		move.w	(v_screenposx).w,d1					; get camera x position
		andi.w	#$FFC0,d1							; round down to $20 (Change to FFC0?)
		addi.w	#$60,d1								; add initial position (Change to #$60?)
	; LuigiXHero Water Surface Fix
	;	btst	#bitStart,(v_jpadpressed_actual).w	; is Start button pressed?
	;	bne.s	.even								; if yes, branch
	; Water Surface Fix End
		btst	#0,(v_framebyte).w
		beq.s	.even								; branch on even frames
		addi.w	#$20,d1								; add $20 every other frame to create flicker

	.even:
		move.w	d1,obX(a0)							; match	obj x-position to screen position
		move.w	(v_waterpos_actual).w,d1
		move.w	d1,obY(a0)							; match	obj y-position to water	height
	; TomatoWave Subsprite Mod
		lea		subspr_posdata(a0),a2				; starting address for subsprite position data
		move.w	obX(a0),(a2)
		addi.w	#$C0,(a2)+
		move.w	obY(a0),(a2)
	; Subsprite Mod end
		moveq	#0,d2
		move.b	mainspr_mapframe(a0),d2				; for quick edits and copying

		tst.b	obSurf_Freeze(a0)
		bne.s	.stopped
		btst	#bitStart,(v_jpadpressed_actual).w	; is Start button pressed?
		beq.s	.animate							; if not, branch
		addq.b	#surf_frames,d2						; use different	frames
		move.b	#1,obSurf_Freeze(a0)				; stop animation
		bra.s	.display
; ===========================================================================

	.stopped:
		tst.b	(f_pause).w							; is the game paused?
		bne.s	.display							; if yes, branch
		clr.b	obSurf_Freeze(a0)					; resume animation
		subq.b	#surf_frames,d2						; use normal frames

	.animate:
		subq.b	#1,obTimeFrame(a0)					; decrement animation timer
		bpl.s	.display							; branch if time remains
		move.b	#7,obTimeFrame(a0)					; reset timer
		addq.b	#1,d2								; next frame
		cmpi.b	#surf_frames,d2
		blo.s	.display
		clr.b	d2									; reset to frame 0 when animation finishes

	.display:
		move.b	d2,mainspr_mapframe(a0)
		move.b	d2,sub2_mapframe(a0)
		move.w	#priority0,d0
		bra.w	DisplaySprite2
; ===========================================================================