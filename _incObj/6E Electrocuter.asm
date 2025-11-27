; ---------------------------------------------------------------------------
; Object 6E - electrocution orbs (SBZ)
; Rewritten based on S1Squared
; ---------------------------------------------------------------------------

Electro:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		jmp		Elec_Index(pc,d0.w)
; ===========================================================================
Elec_Index:
		bra.s Elec_Main
		bra.s Elec_Wait
		bra.s Elec_Zap
		bra.s Elec_Reset
; ===========================================================================

Elec_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Elec,obMap(a0)
		move.w	#make_art_tile(ArtTile_SBZ_Electric_Orb,0,0),obGfx(a0)
		ori.b	#4,obRender(a0)
		move.w	#priority1,obPriority(a0)			; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$28,obDispWid(a0)

		bset	#shPropLightning,obShieldProp(a0)	; Negated by Lightning Shield

		moveq	#$F,d0
		and.b	obSubtype(a0),d0					; read object subtype (cap at $F)
		lsl.w	#4,d0								; multiply by $10
		subq.w	#1,d0
		move.w	d0,obElecOrb_ZapRate(a0)			; set zap frequency
; ---------------------------------------------------------------------------

Elec_Wait:	; Routine 2
		move.w	(v_framecount).w,d0
		and.w	obElecOrb_ZapRate(a0),d0			; is it time to zap?
		bne.s	Elec_Display						; if not, branch

		tst.b	obRender(a0)						; is object on-screen?
		bpl.s	Elec_Display						; if not, branch
		move.w	#sfx_Electric,d0
		jsr		(QueueSound2).w						; play electricity sound
		addq.b	#2,obRoutine(a0)					; -> Elec_Zap
		clr.b	obAniFrame(a0)						; reset animation
; ---------------------------------------------------------------------------

Elec_Zap:	; Routine 4
		lea		Ani_Elec(pc),a1
		jsr		(AnimateSprite).w					; only animate if zapping
		moveq	#0,d0
		move.b	obFrame(a0),d0
		move.b	Elec_Hurt(pc,d0.w),obColType(a0)	; convert frame id to collision type

Elec_Display:
		jmp		(RememberState).l
; ===========================================================================

; table used for quicker obColType assignment
Elec_Hurt:	dc.b 0, 0, 0, 0, (colHarmful|colSz_72x8), 0
		even
; ===========================================================================

Elec_Reset:	; Routine 6
		subq.b	#4,obRoutine(a0)					; -> Elec_Wait
		clr.b	obColType(a0)
		bra.s	Elec_Wait
; ===========================================================================