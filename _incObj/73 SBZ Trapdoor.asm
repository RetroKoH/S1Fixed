; ---------------------------------------------------------------------------
; Object 73 - trapdoors (SBZ)
; ---------------------------------------------------------------------------

Trapdoor:
		obj_addr	#Trap_Action
		move.l	#Map_Trap,obMap(a0)
		move.w	#make_art_tile(ArtTile_SBZ_Trap_Door,2,0),obGfx(a0)
		ori.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$40,obDispWid(a0)			; Ralakimus Trapdoor Glitch Fix

		move.b	obSubtype(a0),d2			; load subtype for repeated use
		moveq	#$F,d0
		and.b	d2,d0						; get subtype's low nybble
		add.w	d0,d0						; multiply by 60 (1 second)
		add.w	d0,d0						; Optimization from S1 in S.C.E.
		move.w	d0,d1
		lsl.w	#4,d0
		sub.w	d1,d0
		move.w	d0,obSpin_WaitMaster(a0)

Trap_Action:
		subq.w	#1,obSpin_WaitTime(a0)		; decrement timer
		bpl.s	.animate					; if time remains, branch

		move.w	obSpin_WaitMaster(a0),obSpin_WaitTime(a0)
		bchg	#0,obAnim(a0)				; switch between opening/closing animations
		bclr	#7,obAnim(a0)				; clear restart flag
		tst.b	obRender(a0)
		bpl.s	.animate
		move.w	#sfx_Door,d0
		jsr		(QueueSound2).w				; play door sound

	.animate:
		lea		Ani_Spin(pc),a1
		jsr		(AnimateSprite).w
		tst.b	obFrame(a0)					; is frame number 0 displayed?
		bne.s	.notsolid					; if not, branch
		moveq	#75,d1						; width; save 4 cycles - Filter
		moveq	#12,d2						; height (jumping); save 4 cycles - Filter
		moveq	#13,d3						; height (walking); save 4 cycles - Filter
		move.w	obX(a0),d4					; axis position
		bsr.w	SolidObject
		bra.w	RememberState
; ===========================================================================

	.notsolid:
		btst	#staSonicOnObj,obStatus(a0)	; is Sonic standing on the trapdoor?
		beq.w	RememberState				; if not, branch
		bclr	#staOnObj,(v_player+obStatus).w
		bclr	#staSonicOnObj,obStatus(a0)	; removed obSolid
		bra.w	RememberState
; ===========================================================================