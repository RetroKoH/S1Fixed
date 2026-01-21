; ---------------------------------------------------------------------------
; Object 6D - flamethrower (SBZ)
; Rewritten based on S1Squared

; subtypes:
;	%FFFFWWWW
;	FFFF - time flame is on (*32 frames)
;	WWWW - wait time between flames (*32 frames)
; ---------------------------------------------------------------------------
; OST Constants
obFlame_WaitTime:		equ objoff_30		; 2 bytes | time until current action is complete
obFlame_OnTime:			equ objoff_32		; 2 bytes | time flame is on
obFlame_OffTime:		equ objoff_34		; 2 bytes | time flame is off
; ---------------------------------------------------------------------------

Flamethrower:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Flame_Index(pc,d0.w),d1
		jmp		Flame_Index(pc,d1.w)
; ===========================================================================

Flame_Index:	offsetTable
		offsetTableEntry.w Flame_Main
		offsetTableEntry.w Flame_On
		offsetTableEntry.w Flame_Off
		offsetTableEntry.w Flame_Off2
; ===========================================================================

Flame_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)				; -> Flame_On
		move.l	#Map_Flame,obMap(a0)
		move.w	#make_art_tile(ArtTile_SBZ_Flamethrower,0,1),obGfx(a0)
		ori.b	#4,obRender(a0)
		move.w	#priority1,obPriority(a0)		; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$C,obDispWid(a0)

		bset	#shPropFlame,obShieldProp(a0)	; Negated by Flame Shield

		move.b	obSubtype(a0),d0
		andi.w	#$F0,d0							; read high nybble of object subtype
		add.w	d0,d0							; multiply by 2
		move.w	d0,obFlame_WaitTime(a0)
		move.w	d0,obFlame_OnTime(a0)			; set flaming time
		move.b	obSubtype(a0),d0
		andi.w	#$F,d0							; read low nybble of object subtype
		lsl.w	#5,d0							; multiply by $20
		move.w	d0,obFlame_OffTime(a0)			; set pause time
		moveq	#2,d0							; 2 = yFlip bitmask (set this up in Constants.asm)
		and.b	obStatus(a0),d0					; get yflip flag (0 or 2)
		move.b	d0,obAnim(a0)					; use as animation
		move.w	#sfx_Flamethrower,d0
		jsr		(QueueSound2).w					; play flame sound
; ---------------------------------------------------------------------------

Flame_On:	; Routine 2
		lea		Ani_Flame(pc),a1
		jsr		(AnimateSprite).w
		cmpi.b	#$A,obAniFrame(a0)						; final frame is now hard-coded here
		bne.s	.wait_anim								; branch if not at final animation frame
		move.b	#(colHarmful|colSz_12x24),obColType(a0)	; make flame harmful

	.wait_anim:
		subq.w	#1,obFlame_WaitTime(a0)			; decrement timer
		bpl.w	RememberState					; if time remains, branch
		move.w	obFlame_OffTime(a0),obFlame_WaitTime(a0)	; begin pause time
		bchg	#0,obAnim(a0)					; switch between on/off animations
		bclr	#7,obAnim(a0)					; clear restart flag
		addq.b	#2,obRoutine(a0)				; -> Flame_Off
		clr.b	obColType(a0)					; make object harmless
		bra.w	RememberState
; ===========================================================================

Flame_Off:		; Routine 4
		lea		Ani_Flame(pc),a1
		jsr		(AnimateSprite).w

Flame_Off2:		; Routine 6
		subq.w	#1,obFlame_WaitTime(a0)			; decrement timer
		bpl.w	RememberState					; if time remains, branch
		move.w	obFlame_OffTime(a0),obFlame_WaitTime(a0)	; begin pause time
		bchg	#0,obAnim(a0)					; switch between on/off animations
		subq.b	#4,obRoutine(a0)				; -> Flame_On
		tst.b	obRender(a0)
		bpl.w	RememberState					; branch if off screen
		move.w	#sfx_Flamethrower,d0
		jsr		(QueueSound2).w					; play flame sound
		bra.w	RememberState
; ===========================================================================