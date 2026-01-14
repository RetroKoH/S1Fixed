; ---------------------------------------------------------------------------
; Object 5D - fans (SLZ)
; ---------------------------------------------------------------------------

Fan:
		_move.l	#Fan_Action,obRoutine(a0)
		move.l	#Map_Fan,obMap(a0)
		move.w	#make_art_tile(ArtTile_SLZ_Fan,2,0),obGfx(a0)
		ori.b	#4,obRender(a0)
		move.b	#$10,obDispWid(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
; ---------------------------------------------------------------------------

Fan_Action:	; Routine 2
		btst	#1,obSubtype(a0)			; is object type 02/03 (always on)?
		bne.s	.blow						; if yes, branch
		subq.w	#1,obFan_Time(a0)			; subtract 1 from time delay
		bpl.s	.blow						; if time remains, branch
		move.w	#120,obFan_Time(a0)			; set delay to 2 seconds
		bchg	#0,obFan_Switch(a0)			; switch fan on/off
		beq.s	.blow						; if fan is off, branch
		move.w	#180,obFan_Time(a0)			; set delay to 3 seconds

	.blow:
		tst.b	obFan_Switch(a0)			; is fan switched on?
		bne.w	.chkdel						; if not, branch
		lea		(v_player).w,a1
		move.w	obX(a1),d0
		sub.w	obX(a0),d0					; d0 = distance between fan and Sonic (-ve if Sonic is to the left)
		btst	#staFlipX,obStatus(a0)		; is fan facing right?
		bne.s	.chksonic					; if yes, branch
		neg.w	d0					; positive: face left & Sonic left; face right & Sonic right
									; negative: face left & Sonic right; face right & Sonic left

	.chksonic:
		addi.w	#$50,d0
		cmpi.w	#$F0,d0						; is Sonic more	than $A0 pixels	from the fan?
		bhs.s	.animate					; if yes, branch
		move.w	obY(a1),d1
		addi.w	#96,d1
		sub.w	obY(a0),d1
		bcs.s	.animate					; branch if Sonic is > 96px below fan
		cmpi.w	#112,d1
		bhs.s	.animate					; branch if Sonic is > 112px above fan
		subi.w	#80,d0
		bcc.s	.faraway					; branch if Sonic is not within 80px in front/behind fan
		not.w	d0
		add.w	d0,d0

	.faraway:
		addi.w	#$60,d0
		btst	#staFlipX,obStatus(a0)		; is fan facing right?
		bne.s	.right						; if yes, branch
		neg.w	d0

	.right:
		neg.b	d0
		asr.w	#4,d0
		btst	#0,obSubtype(a0)			; is type 0/2? (blows left)
		beq.s	.blows_left					; if yes, branch
		neg.w	d0

	.blows_left:
		add.w	d0,obX(a1)					; push Sonic left or right, away from the fan
	
	if CameraDashLag	; Camera Lag applied when dashing
		clr.b	(v_cameralag).w				; Spin Dash Enabled
	endif

	.animate:
		subq.b	#1,obTimeFrame(a0)			; decrement animation timer
		bpl.s	.chkdel						; branch if time remains
		clr.b	obTimeFrame(a0)				; reset timer
		addq.b	#1,obAniFrame(a0)			; next frame
		cmpi.b	#3,obAniFrame(a0)
		blo.s	.noreset					; branch if frame is valid
		clr.b	obAniFrame(a0)				; reset frame counter after 4 frames

	.noreset:
		moveq	#0,d0
		btst	#0,obSubtype(a0)			; is type 0/2? (blows left)
		beq.s	.noflip						; if yes, branch
		moveq	#2,d0						; start at frame 2 for opposite spin

	.noflip:
		add.b	obAniFrame(a0),d0			; add to frame counter
		move.b	d0,obFrame(a0)				; update frame

	.chkdel:
		offscreen.w	DeleteObject			; PFM S3K Obj
		bra.w	DisplaySprite				; Clownacy DisplaySprite Fix	
; ===========================================================================