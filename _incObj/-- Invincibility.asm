; ---------------------------------------------------------------------------
; Object - Invincibility Stars (Moved from Shield to its own object)
; ---------------------------------------------------------------------------

Stars_Delete:
		jmp		(DeleteObject).l
; ===========================================================================

StarsItem:
		_move.l	#Stars_Trail,obAddr(a0)
		move.b	#4,obRender(a0)
		bset	#renMultiDraw,obRender(a0)				; multi-draw (sub-sprites) flag
		move.w	#make_art_tile(ArtTile_Shield,0,0),obGfx(a0)
		move.l	#Map_Shield,obMap(a0)					; TO-DO: split mappings and DPLCs
		clr.b	mainspr_routine(a0)						; use this to increment every single star frame using the data table
		move.w	#$1010,mainspr_height(a0)				; height and width
		move.b	#3,mainspr_childsprites(a0)
	; fallthrough to Routine 2
; ---------------------------------------------------------------------------

Stars_Trail:	; Routine 2
	if SuperMod
		btst	#sta2ndSuper,(v_player+obStatus2nd).w	; is Sonic Super?
		bne.s	Stars_Delete							; if yes, destroy stars
	endif
		btst	#sta2ndInvinc,(v_player+obStatus2nd).w	; does Sonic have invincibility?
		beq.s	Stars_Delete							; if not, branch
		moveq	#0,d1
		moveq	#0,d3									; d3 = loop iterator
		moveq	#0,d4
		lea		subspr_posdata(a0),a2					; starting address for subsprite position data
		lea		subspr_frames(a0),a5					; starting address for subsprite frame data
		lea		Star_main(pc),a3						; starting address for animations
		move.b	mainspr_routine(a0),d4					; d4 = current animation frame
		lea		(a3,d4.w),a3							; a3 = location of mapping frame
		lea		obStars_TrackData(a0),a4				; previous tracking data for each subsprite
		move.b	(v_player+obStatus).w,obStatus(a0)		; set status early (we'll need it for position adjustment later
		move.b	(v_player+obAnim).w,d5					; more efficient to store this once and compare 4-8 times later

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
		adda.w	d0,a1					; jump to current index (HAME: Replace lea instruction)
		move.w	(a1)+,d4				; current x-position, pre-adjustment

	; Mercury Shield/Invincibility Positioning Fix
		move.b	obStatus(a0),d0
		moveq	#10,d1

	if CDBalancing
		cmpi.b	#aniID_Balance2,d5
		beq.s	.shift
		cmpi.b	#aniID_Balance3,d5
		bne.s	.noshift
		bchg	#staFacing,d0
		moveq	#4,d1
	else	
		cmpi.b	#aniID_Balance,d5
		bne.s	.noshift
	endif
		
	.shift:
		sub.w	d1,d4
		btst	#staFlipX,d0		; X-Flip sprite bit
		beq.s	.noshift
		add.w	d1,d1
		add.w	d1,d4

	.noshift:
	; Shield/Invincibility Positioning Fix End
		tst.b	d3						; is this the main anim?
		bne.s	.subanims

	.anim0:
		move.w	d4,obX(a0)
		move.w	(a1)+,obY(a0)
		move.b	(a3),mainspr_mapframe(a0)
		bra.s	.skipsubanims

	.subanims:
		move.w	d4,(a2)+				; sub?_x_pos
		move.w	(a1)+,(a2)+				; sub?_y_pos
		adda.w	#$18,a3
		move.b	(a3),(a5)+				; sub?_mapframe

	.skipsubanims:
		addq.b	#1,d3
		cmpi.b	#4,d3
		blo.w	.trail					; if 0-3, loop back
	; loop end

		moveq	#0,d0
		move.b	mainspr_mapframe(a0),d0
;Stars_LoadGfx:
		lea		ShieldDynPLC(pc),a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		moveq	#0,d5
		move.w	(a2)+,d5					; read "number of entries" value -- S3k: .b to .w
		subq.w	#1,d5
		bmi.s	.nochange					; if zero, branch
		move.w	#(ArtTile_Shield*tile_size),d4

	.readentry:
		moveq	#0,d1
		move.w	(a2)+,d1					; S3K .b to .w
		move.w	d1,d3						; S3K
		lsr.w	#8,d3						; S3K
		andi.w	#$F0,d3
		addi.w	#$10,d3
		andi.w	#$FFF,d1
		lsl.l	#5,d1
		add.l	#Art_Stars,d1
		move.w	d4,d2
		add.w	d3,d4
		add.w	d3,d4
		jsr		(QueueDMATransfer).w
		dbf		d5,.readentry				; repeat for number of entries

	.nochange:
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