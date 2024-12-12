; ---------------------------------------------------------------------------
; Object 21 - Invincibility Stars (Moved from Shield to its own object)
; ---------------------------------------------------------------------------

stars_trackdata = objoff_30

Stars_Delete:
		jmp		(DeleteObject).l
; ===========================================================================

StarsItem:
	; LavaGaming Object Routine Optimization
		tst.b	obRoutine(a0)
		bne.s	Stars_Next
	; Object Routine Optimization End

Stars_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.b	#4,obRender(a0)
		bset	#6,obRender(a0)
		move.w	#make_art_tile(ArtTile_Shield,0,0),obGfx(a0)
		move.l	#Map_Shield,obMap(a0)
		move.l	#Art_Stars,obArtLoc(a0)
		move.l	#ShieldDynPLC,obDPLCLoc(a0)

		clr.b	mainspr_routine(a0)			; use this to increment every single star frame using the data table
		moveq	#$10,d0
		move.b	d0,mainspr_width(a0)
		move.b	d0,mainspr_height(a0)
		move.b	#3,mainspr_childsprites(a0)
	; fallthrough to Routine 2


Stars_Next:	; Routine 2
	if SuperMod=1
		btst	#sta2ndSuper,(v_player+obStatus2nd).w	; is Sonic Super?
		bne.s	Stars_Delete							; if yes, destroy stars
	endif
		btst	#sta2ndInvinc,(v_player+obStatus2nd).w	; does Sonic have invincibility?
		beq.s	Stars_Delete							; if not, branch
		moveq	#0,d1
		moveq	#0,d3									; d3 = loop iterator
		moveq	#0,d4
		lea		subspr_data(a0),a2						; starting address for subsprite data
		lea		Star_main(pc),a3						; starting address for animations
		move.b	mainspr_routine(a0),d4					; d4 = current animation frame
		lea		(a3,d4.w),a3							; a3 = location of mapping frame
		lea		stars_trackdata(a0),a4					; previous tracking data for each subsprite

; loop to set track position
.trail:
		move.w	(v_trackpos).w,d0		; get index value for tracking data
		move.l	d3,d1					; d1 = subframe/anim number
		lsl.b	#3,d1					; multiply animation number by 8
		move.b	d1,d2
		add.b	d1,d1
		add.b	d2,d1					; multiply by 3
		addq.b	#4,d1
		sub.b	d1,d0
		move.b	(a4),d1
		sub.b	d1,d0					; use earlier tracking data to create trail
		addq.b	#4,d1
		cmpi.b	#$18,d1
		blo.s	.a
		moveq	#0,d1

.a:
		move.b	d1,(a4)+
		lea		(v_tracksonic).w,a1
		lea		(a1,d0.w),a1
		tst.b	d3						; is this the main anim?
		bne.s	.subanims

.anim0:
		move.w	(a1)+,obX(a0)
		move.w	(a1)+,obY(a0)
		move.b	(a3),mainspr_mapframe(a0)
		bra.s	.setstatus

.subanims:
		move.w	(a1)+,(a2)+				; sub?_x_pos
		move.w	(a1)+,(a2)+				; sub?_y_pos
		adda.w	#$18,a3
		move.b	(a3),1(a2)				; sub?_mapframe
		addq.w	#2,a2					; skip to next sub data

.setstatus:
		move.b	(v_player+obStatus).w,obStatus(a0)

	; Mercury Shield/Invincibility Positioning Fix
		move.b	obStatus(a0),d0
		move.w	#$A,d1

	if CDBalancing=1
		cmpi.b	#aniID_Balance2,(v_player+obAnim).w
		beq.s	.shift
		cmpi.b	#aniID_Balance3,(v_player+obAnim).w
		bne.s	.noshift
		bchg	#staFacing,d0
		move.w	#4,d1
	else	
		cmpi.b	#aniID_Balance,(v_player+obAnim).w
		bne.s	.noshift
	endif
		
.shift:
		sub.w	d1,obX(a0)
		btst	#staFlipX,d0		; X-Flip sprite bit
		beq.s	.noshift
		add.w	d1,d1
		add.w	d1,obX(a0)
.noshift:
	; Shield/Invincibility Positioning Fix End

		addq.b	#1,d3
		cmpi.b	#4,d3
		blo.w	.trail					; if 0-3, loop back
	; loop end
		moveq	#0,d0
		move.b	mainspr_mapframe(a0),d0
		bsr.w	Stars_LoadGfx			; RetroKoH VRAM Overhaul

		move.b	mainspr_routine(a0),d0	; d0 = animation frame to be incremented
		addq.b	#1,d0					; add to animation frame
		cmpi.b	#24,d0					; did we reach the end of the animation?
		blo.b	.setframe
		moveq	#0,d0

.setframe:
		move.b	d0,mainspr_routine(a0)	; set animation frame
		move.w	#priority1,d0			; RetroKoH/Devon S3K+ Priority Manager
		jmp		(DisplaySprite2).l
; ===========================================================================

Stars_SubFrames:	offsetTable
		offsetTableEntry.w	Star_main
		offsetTableEntry.w	Star_sub1
		offsetTableEntry.w	Star_sub2
		offsetTableEntry.w	Star_sub3

Star_main:		dc.b 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6
				dc.b 6,	6, 7, 7, 7, 7, 7, 7
Star_sub1:		dc.b 4, 4, 0, 4, 4, 0, 5, 5, 0, 5, 5, 0, 6, 6, 0, 6
				dc.b 6,	0, 7, 7, 0, 7, 7, 0
Star_sub2:		dc.b 4, 4, 0, 4, 0, 0, 5, 5, 0, 5, 0, 0, 6, 6, 0, 6
				dc.b 0,	0, 7, 7, 0, 7, 0, 0
Star_sub3:		dc.b 4, 0, 0, 4, 0, 0, 5, 0, 0, 5, 0, 0, 6, 0, 0, 6
				dc.b 0,	0, 7, 0, 0, 7, 0, 0
; ===========================================================================