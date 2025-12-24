; ---------------------------------------------------------------------------
; Object 6C - vanishing	platforms (SBZ)
; ---------------------------------------------------------------------------

VanishPlatform:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	VanP_Index(pc,d0.w),d1
		jmp		VanP_Index(pc,d1.w)
; ===========================================================================

VanP_Index:		offsetTable
		offsetTableEntry.w 	VanP_Main
		offsetTableEntry.w 	VanP_Detect ; VanP_Vanish
		offsetTableEntry.w 	VanP_StoodOn ; VanP_Appear
		offsetTableEntry.w 	VanP_Sync
; ===========================================================================

VanP_Main:	; Routine 0
		addq.b	#6,obRoutine(a0)			; -> VanP_Sync
		move.l	#Map_VanP,obMap(a0)
		move.w	#make_art_tile(ArtTile_SBZ_Vanishing_Block,2,0),obGfx(a0)
		ori.b	#4,obRender(a0)
		move.b	#$10,obDispWid(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		moveq	#$F,d0
		and.b	obSubtype(a0),d0			; get object subtype's low nybble
		addq.w	#1,d0						; add 1
		lsl.w	#7,d0						; multiply by $80
		move.w	d0,d1						; copy to d1
		subq.w	#1,d0
		move.w	d0,obVanPtfm_WaitTime(a0)
		move.w	d0,obVanPtfm_WaitMaster(a0)	; set as time between changes
		moveq	#0,d0
		move.b	obSubtype(a0),d0			; get object type
		andi.w	#$F0,d0						; read only the	high nybble
		addi.w	#$80,d1
		mulu.w	d1,d0
		lsr.l	#8,d0
		move.w	d0,obVanPtfm_SyncDec(a0)
		subq.w	#1,d1						; d1 = $FF if type $x0; $3FF if type $x6
		move.w	d1,obVanPtfm_SyncBitMask(a0)
; ---------------------------------------------------------------------------

VanP_Sync:	; Routine 6
		move.w	(v_framecount).w,d0
		sub.w	obVanPtfm_SyncDec(a0),d0
		and.w	obVanPtfm_SyncBitMask(a0),d0	; apply bitmask
		bne.s	.animate						; branch if any bits are set
		subq.b	#4,obRoutine(a0)				; -> VanP_Detect (every $100 or $400 frames)
		bra.s	VanP_Detect
; ===========================================================================

	.animate:
		lea		Ani_Van(pc),a1
		jsr		(AnimateSprite).w
		jmp		(RememberState).l
; ===========================================================================

VanP_Detect:	; Routine 2
VanP_StoodOn:	; Routine 4
		subq.w	#1,obVanPtfm_WaitTime(a0)	; decrement timer
		bpl.s	.wait						; branch if time remains
		move.w	#127,obVanPtfm_WaitTime(a0)
		tst.b	obAnim(a0)					; is platform vanishing?
		beq.s	.isvanishing				; if yes, branch
		move.w	obVanPtfm_WaitMaster(a0),obVanPtfm_WaitTime(a0) ; reset timer to $80 (type $x0) or $380 (type $x6)

	.isvanishing:
		bchg	#0,obAnim(a0)				; switch between vanishing/appearing animations
		bclr	#7,obAnim(a0)				; clear restart flag

	.wait:
		lea		Ani_Van(pc),a1
		jsr		(AnimateSprite).w
		btst	#1,obFrame(a0)				; has platform vanished?
		bne.s	.notsolid					; if yes, branch
		cmpi.b	#2,obRoutine(a0)			; is platform being stood on?
		bne.s	.stood_on					; if yes, branch
		moveq	#0,d1
		move.b	obDispWid(a0),d1			; width
		jsr		(PlatformObject).l			; detect collision and goto VanP_StoodOn next if true
		jmp		(RememberState).l
; ===========================================================================

	.stood_on:
		moveq	#0,d1
		move.b	obDispWid(a0),d1
		jsr		(ExitPlatform).l			; goto VanP_Detect next if Sonic leaves platform
		move.w	obX(a0),d2
		jsr		(MvSonicOnPtfm2).l
		jmp		(RememberState).l
; ===========================================================================

	.notsolid:
		btst	#staSonicOnObj,obStatus(a0)	; is Sonic on the platform?
		beq.s	.display					; if not, branch
		lea		(v_player).w,a1
		bclr	#staOnObj,obStatus(a1)		; clear all platform flags
		bclr	#staSonicOnObj,obStatus(a0)	; Removed obSolid
		move.b	#2,obRoutine(a0)			; -> VanP_Detect

	.display:
		jmp		(RememberState).l
; ===========================================================================