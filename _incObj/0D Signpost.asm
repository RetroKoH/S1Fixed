; ---------------------------------------------------------------------------
; Object 0D - signpost at the end of a level
; ---------------------------------------------------------------------------

spintime = objoff_30		; time for signpost to spin
sparkletime = objoff_32		; time between sparkles
sparkle_id = objoff_34		; counter to keep track of sparkles
sign_origy = objoff_36		; original y-position (For Floating Signpost mod)

Signpost:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Sign_Index(pc,d0.w),d1
		jsr		Sign_Index(pc,d1.w)
		lea		Ani_Sign(pc),a1
		jsr		(AnimateSprite).w
	; RetroKoH VRAM Overhaul Edit
	; The code below checks how close to the signpost the camera is,
	; If the sign is nearly onscreen, the art loads.
		move.w	(v_player+obX).w,d0		; Get the player's X position.
		addi.w	#224,d0					; add 224 ($E0).
		sub.w	obX(a0),d0				; Subtract the signpost's x postion.
		tst.w	d0						; Check if d0 is 0 or great (Sonic is less than
		blt.s	.skip					; If d0 is lower than 0, branch.

	; Add this to prevent DPLCs from loading AFTER the signpost stops spinning
	; This will prevent graphic bugs in the Special Stage
		cmpi.b	#6,obRoutine(a0)
		bgt.s	.skip
		bsr.w	Signpost_LoadGfx
	.skip:
	; VRAM Overhaul Edit End
		offscreen.w	DeleteObject	; ProjectFM S3K Object Manager
		bra.w	DisplaySprite		; Clownacy DisplaySprite Fix
; ===========================================================================
Sign_Index:		offsetTable
		offsetTableEntry.w	Sign_Main
		offsetTableEntry.w	Sign_Touch
		offsetTableEntry.w	Sign_Spin
		offsetTableEntry.w	Sign_SonicRun
		offsetTableEntry.w	Sign_Exit
; ===========================================================================

Sign_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Sign,obMap(a0)
		move.w	#make_art_tile(ArtTile_Signpost,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.b	#$18,obActWid(a0)
		move.w	#priority4,obPriority(a0)			; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$FF,objoff_3F(a0)					; Added for DPLC frame check

Sign_Touch:	; Routine 2
		lea		(v_player).w,a1
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		bcs.s	.notouch
		cmpi.w	#$20,d0								; is Sonic within $20 pixels of	the signpost?
		bhs.s	.notouch							; if not, branch
		move.b	#sfx_Signpost,d0
		jsr		(PlaySound).w						; play signpost sound

; RetroKoH Floating Signpost Mechanic
	if FloatingSignposts=1
		moveq	#0,d0
		move.b	obInertia(a1),d0					; ground speed if on the ground
		btst	#staAir,obStatus(a1)				; is Sonic in the air?
		beq.s	.notinair							; if not, branch
		move.b	obVelX(a1),d0						; horizontal air speed

.notinair:
		tst.b	d0									; is speed already negative (we somehow triggered from the left)
		bpl.s	.notnegative						; if not, branch
		neg.b	d0									; we don't want a negative value just yet

.notnegative:
		cmpi.b	#4,d0
		ble.s	.tooslow							; if under 4, don't let the sign fly
		cmpi.b	#$A,d0
		ble.s	.dontcap
		move.b	#$A,d0								; set max cap of $A

.dontcap:
		lsr.b	#1,d0								; vel / 2
		neg.b	d0									; make value negative
		move.b	d0,obVelY(a0)						; set y speed of signpost

.tooslow:
		move.w	obY(a0),sign_origy(a0)				; store starting y-position so we know when to land
		move.w	#60,spintime(a0)					; set spin cycle time to 1 second
		addq.b	#1,obAnim(a0)						; set to first spin cycle early
	endif

		clr.b	obShoes(a1)							; Mercury Remove Speed Shoes At Signpost Fix (Moved from the Got_Through Card and improved) -- RetroKoH Sonic SST Compaction
		clr.b	(f_timecount).w						; stop time counter
		move.w	(v_limitright2).w,(v_limitleft2).w	; lock screen position
		addq.b	#2,obRoutine(a0)

.notouch:
		rts	
; ===========================================================================

Sign_Spin:	; Routine 4

; RetroKoH Floating Signpost Mechanic
	if FloatingSignposts=1
		tst.b	ob2ndRout(a0)
		bne.s	.onground
		bsr.w	SpeedToPos_YOnly
		move.w	sign_origy(a0),d1
		sub.w	obY(a0),d1
		bpl.s	.inair
		add.w	d1,obY(a0)						; latch to the floor
		clr.w	obVelY(a0)
		move.b	#1,ob2ndRout(a0)
		bra.s	.onground

.inair:
		addi.w	#$28,obVelY(a0)
		cmpi.b	#$E,sparkletime(a0)
		bne.s	.skipreset
		clr.b	sparkletime(a0)

.skipreset:
		subq.w	#1,spintime(a0)					; subtract 1 from spin time
		bpl.s	.chksparkle						; if time remains, branch
		move.w	#60,spintime(a0)				; set spin cycle time to 1 second
		cmpi.b	#3,obAnim(a0)					; have 3 spin cycles completed?
		beq.s	.chksparkle						; if yes, branch
		addq.b	#1,obAnim(a0)					; next spin cycle
		bra.s	.chksparkle

.onground:
	endif

		subq.w	#1,spintime(a0)					; subtract 1 from spin time
		bpl.s	.chksparkle						; if time remains, branch
		move.w	#60,spintime(a0)				; set spin cycle time to 1 second
		addq.b	#1,obAnim(a0)					; next spin cycle
		cmpi.b	#3,obAnim(a0)					; have 3 spin cycles completed?
		bne.s	.chksparkle						; if not, branch
	if EndLevelFadeMusic=1
		move.b	#bgm_Fade,d0
		jsr		(PlaySound_Special).w			; fade out music (RetroKoH)
	endif
		addq.b	#2,obRoutine(a0)

.chksparkle:
		subq.w	#1,sparkletime(a0)				; subtract 1 from time delay
		bpl.s	.fail							; if time remains, branch
		move.w	#$B,sparkletime(a0)				; set time between sparkles to $B frames
		moveq	#0,d0
		move.b	sparkle_id(a0),d0				; get sparkle id
		addq.b	#2,sparkle_id(a0)				; increment sparkle counter
		andi.b	#$E,sparkle_id(a0)
		lea		Sign_SparkPos(pc,d0.w),a2		; load sparkle position data
		bsr.w	FindFreeObj
		bne.s	.fail
		_move.b	#id_Rings,obID(a1)				; load rings object
		move.b	#id_Ring_Sparkle,obRoutine(a1)	; jump to ring sparkle subroutine
		move.b	(a2)+,d0
		ext.w	d0
		add.w	obX(a0),d0
		move.w	d0,obX(a1)
		move.b	(a2)+,d0
		ext.w	d0
		add.w	obY(a0),d0
		move.w	d0,obY(a1)
		move.l	#Map_Ring,obMap(a1)
		move.w	#make_art_tile(ArtTile_Ring,1,0),obGfx(a1)
		move.b	#4,obRender(a1)
		move.w	#priority2,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#8,obActWid(a1)

.fail:
		rts	
; ===========================================================================
Sign_SparkPos:
		dc.b -$18,-$10		; x-position, y-position
		dc.b	8,   8
		dc.b -$10,   0
		dc.b  $18,  -8
		dc.b	0,  -8
		dc.b  $10,   0
		dc.b -$18,   8
		dc.b  $18, $10
; ===========================================================================

Sign_SonicRun:	; Routine 6
		tst.w	(v_debuguse).w	; is debug mode	on?
		bne.s	ret_EC86	; if yes, branch
	; Signpost Routine Fix
	; This function's checks are a mess, creating an edgecase where it's
	; possible for the player to avoid having their controls locked by
	; jumping at the right side of the screen just as the score tally
	; appears.
		tst.b	(v_player+obID).w			; Check if Sonic's object has been deleted (because he entered the giant ring)
		beq.s	loc_EC86
		btst	#staAir,(v_player+obStatus).w
		bne.s	ret_EC86
	; Signpost Routine Fix End
		move.b	#1,(f_lockctrl).w			; lock controls
		move.w	#btnR<<8,(v_jpadhold2).w	; make Sonic run to the right
	; Old check moved to above -- Signpost Routine Fix
		move.w	(v_player+obX).w,d0
		move.w	(v_limitright2).w,d1
		addi.w	#$128,d1
		cmp.w	d1,d0
		bhs.s	loc_EC86

ret_EC86:		; Added this rts label to optimize three branches above.
		rts

loc_EC86:
		addq.b	#2,obRoutine(a0)


; ---------------------------------------------------------------------------
; Subroutine to	set up bonuses at the end of an	act
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


GotThroughAct:
		tst.b	(v_endcard).w
		bne.w	locret_ECEE
		move.w	(v_limitright2).w,(v_limitleft2).w
		bclr	#sta2ndInvinc,(v_player+obStatus2nd).w	; disable invincibility
		clr.b	(f_timecount).w							; stop time counter
		move.b	#id_GotThroughCard,(v_endcard).w
		
	if OptimalTitleCardArt
	; RetroKoH Optimal Title Cards for VRAM/SpritePiece Reduction
		move.l	a0,-(sp)										; save object address to stack
		locVRAM	ArtTile_Title_Card*tile_size
		lea		Art_TitCardSonic,a0													; load title card patterns
		move.l	#((Art_TitCardSonic_End-Art_TitCardSonic)/tile_size)-1,d0			; # of tiles
		jsr		(LoadUncArt).w														; load uncompressed art
		lea		Art_TitCardHasPassed,a0												; load title card patterns
		move.l	#((Art_TitCardHasPassed_End-Art_TitCardHasPassed)/tile_size)-1,d0	; # of tiles
		jsr		(LoadUncArt).w														; load uncompressed art
		lea		Art_TitCardItems,a0													; load title card patterns
		move.l	#((Art_TitCardItems_End-Art_TitCardItems)/tile_size)-1,d0			; # of tiles
		jsr		(LoadUncArt).w														; load uncompressed art
		lea		Art_TitCardBonuses,a0												; load title card patterns
		move.l	#((Art_TitCardBonuses_End-Art_TitCardBonuses)/tile_size)-1,d0		; # of tiles
		jsr		(LoadUncArt).w														; load uncompressed art
		move.l	(sp)+,a0										; get object address from stack
	; Optimal Title Cards End
	else
	; AURORA☆FIELDS Title Card Optimization
		move.l	a0,-(sp)										; save object address to stack
		locVRAM	ArtTile_Title_Card*tile_size
		lea		Art_TitleCard,a0								; load title card patterns
		move.l	#((Art_TitleCard_End-Art_TitleCard)/$20)-1,d0	; the title card art lenght, in tiles
		jsr		(LoadUncArt).w									; load uncompressed art
		move.l	(sp)+,a0										; get object address from stack
	; Title Card Optimization End
	endif
		
		move.b	#1,(f_endactbonus).w
		moveq	#0,d0
		move.b	(v_timemin).w,d0
		mulu.w	#60,d0		; convert minutes to seconds
		moveq	#0,d1
		move.b	(v_timesec).w,d1
		add.w	d1,d0		; add up your time
		divu.w	#15,d0		; divide by 15
		moveq	#$14,d1
		cmp.w	d1,d0		; is time 5 minutes or higher?
		blo.s	.hastimebonus	; if not, branch
		move.w	d1,d0		; use minimum time bonus (0)

.hastimebonus:
		add.w	d0,d0
		move.w	TimeBonuses(pc,d0.w),(v_timebonus).w	; set time bonus
		move.w	(v_rings).w,d0							; load number of rings
		mulu.w	#10,d0									; multiply by 10
		move.w	d0,(v_ringbonus).w						; set ring bonus

	if CoolBonusEnabled
		moveq	#0,d0
		move.b	(v_hitscount).w,d0						; get hits count (starts at 10, counts down toward 0 w/ each hit)
		mulu.w	#100,d0									; multiply by 100
		move.w	d0,(v_coolbonus).w						; set cool bonus
	endif

		move.b	#bgm_GotThrough,d0
		jmp		(PlaySound_Special).w					; play "Sonic got through" music

locret_ECEE:
		rts	
; End of function GotThroughAct

; ===========================================================================
TimeBonuses:
		dc.w 5000, 5000, 1000, 500, 400, 400, 300, 300,	200, 200
		dc.w 200, 200, 100, 100, 100, 100, 50, 50, 50, 50, 0
; ===========================================================================

Sign_Exit:	; Routine 8
		rts	
; ===========================================================================

; ---------------------------------------------------------------------------
; Signpost dynamic pattern loading subroutine -- RetroKoH VRAM Overhaul
; ---------------------------------------------------------------------------

Signpost_LoadGfx:
		moveq	#0,d0
		move.b	obFrame(a0),d0			; load frame number
		cmp.b	objoff_3F(a0),d0		; has frame changed?
		beq.s	.nochange				; if not, branch and exit

		move.b	d0,objoff_3F(a0)		; update frame number for next check
		lea		SignpostDynPLC(pc),a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		moveq	#0,d5
		move.w	(a2)+,d5					; read "number of entries" value -- S3k: .b to .w
		subq.w	#1,d5
		bmi.s	.nochange					; if zero, branch
		move.w	#(ArtTile_Signpost*$20),d4

.readentry:
		moveq	#0,d1
		move.w	(a2)+,d1	; S3K .b to .w
		move.w	d1,d3		; S3K
		lsr.w	#8,d3		; S3K
		andi.w	#$F0,d3
		addi.w	#$10,d3
		andi.w	#$FFF,d1
		lsl.l	#5,d1
		add.l	#Art_Signpost,d1
		move.w	d4,d2
		add.w	d3,d4
		add.w	d3,d4
		jsr		(QueueDMATransfer).w
		dbf		d5,.readentry	; repeat for number of entries

.nochange:
		rts