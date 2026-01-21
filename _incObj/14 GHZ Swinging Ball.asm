; ----------------------------------------------------------------------------
; Object 14 - swinging ball (GHZ)
; Based on Object 15, which was adapted from Sonic Clean Engine
; ----------------------------------------------------------------------------
; OST Constants (Shared with Object 15)
;obSwing_StartX:			equ objoff_30		; 2 bytes | starting X-axis position
;obSwing_StartY:			equ objoff_32		; 2 bytes | starting Y-axis position
;obSwing_Chain:				equ objoff_3E		; 2 bytes | object RAM address of chain
; ----------------------------------------------------------------------------

WreckingBall:
		_move.l	#WBall_Action,obAddr(a0)		; initialize to normal swinging platform routine
		move.l	#Map_GBall,obMap(a0)
		move.w	#make_art_tile(ArtTile_GHZ_Giant_Ball,2,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority3,obPriority(a0)		; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$14,obDispWid(a0)
		move.b	#8,obHeight(a0)
		move.b	#1,obFrame(a0)
		move.b	#(colHarmful|colSz_20x20),obColType(a0)	; make object hurt when touched
		move.w	obX(a0),obSwing_StartX(a0)
		move.w	obY(a0),obSwing_StartY(a0)

	; create chain
		bsr.w	FindFreeObj
		bne.w	Swing_OffScreen

		_move.l	#Swing_Sub,obAddr(a1)			; load subsprite object
		move.l	#Map_Swing_GHZ,obMap(a1)
		move.w	#make_art_tile(ArtTile_GHZ_MZ_Swing,1,0),obGfx(a1)
		move.b	obRender(a0),obRender(a1)
		bset	#renMultiDraw,obRender(a1)		; set multi-draw flag
		bset	#renUseHeight,obRender(a1)
		move.w	a1,obSwing_Chain(a0)			; save chain address
		move.w	obX(a0),d2
		move.w	d2,obX(a1)						; store x, but retain for later use
		move.w	obY(a0),d3
		move.w	d3,obY(a1)						; store y, but retain for later use

		moveq	#$F,d1
		and.b	obSubtype(a0),d1
		move.b	d1,d0
		addq.b	#1,d0
		lsl.b	#4,d0							; multiply by $10
		move.b	d0,mainspr_width(a1)			; width/height is (chainlinks+1)*$10
		move.b	d0,mainspr_height(a1)
		move.b	d1,mainspr_childsprites(a1)		; number of chain links
		subq.b	#1,d1							; loop iterator
		blo.w	Swing_OffScreen

        lea		subspr_posdata(a1),a2
		lea		subspr_frames(a1),a3

	.loop:
        move.w	d2,(a2)+                        ; sub?_x_pos
        move.w	d3,(a2)+                        ; sub?_y_pos
        move.b	#1,(a3)+                        ; sub?_mapframe
        dbf		d1,.loop

		move.b	#2,mainspr_mapframe(a1)			; set frame for anchor
		rts
; ===========================================================================

WBall_Action:
		bsr.w	Swing_Move

WBall_ChkDel:
        move.w	obSwing_StartX(a0),d0	; get object position
        andi.w	#$FF80,d0				; round down to nearest $80
        move.w	(v_screenposx).w,d1		; get screen position
        subi.w	#$80,d1
        andi.w	#$FF80,d1
        sub.w	d1,d0					; approx distance between object and screen
        cmpi.w	#$280,d0
        bhi.w	Swing_OffScreen

	; Wrecking Ball logic
		moveq	#0,d0
		tst.b	obFrame(a0)				; is ball showing checkered?
		bne.s	.vanish					; if yes, branch to alt frame (frame 0)

	; RetroKoH angled ball mod
		move.b	(v_oscillate+$1A).w,d0	; fetch chain's current angle; store it in d0
		; no subtraction, as this value already ranges from 0-$80
		lsr.b	#1,d0					; cut range down to 0-$40
		
		lea		(GBall_Angles).l,a2		; a2 = GBall_Angles address
		lea		(a2,d0.w),a2			; a2 = GBall_Angles + angle offset
		move.b	(a2),d0
	; angled ball mod end

	.vanish:
		move.b	d0,obFrame(a0)
		bra.w	DisplayAndCollision
; ===========================================================================