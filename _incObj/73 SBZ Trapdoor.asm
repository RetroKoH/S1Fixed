; ---------------------------------------------------------------------------
; Object 73 - trapdoors (SBZ)
; Split from Obj69 by RetroKoH (Special Thanks: Hivebrain)
; ---------------------------------------------------------------------------
; OST Constants
obTrap_WaitTime:		equ objoff_30		; 2 bytes | time until change
obTrap_WaitMaster:		equ objoff_32		; 2 bytes | time between changes
; ---------------------------------------------------------------------------

Trapdoor:
		obj_addr	#Trap_Wait
		move.l	#Map_Trap,obMap(a0)
		move.w	#make_art_tile(ArtTile_SBZ_Trap_Door,2,0),obGfx(a0)
		ori.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$40,obDispWid(a0)			; Devon Trapdoor Glitch Fix

		moveq	#$F,d0						; get subtype's low nybble
		and.b	obSubtype(a0),d0			; SCE Optimization
		add.w	d0,d0						; multiply by 60 (1 second)
		add.w	d0,d0						; SCE Optimization
		move.w	d0,d1
		lsl.w	#4,d0
		sub.w	d1,d0
		move.w	d0,obTrap_WaitMaster(a0)
		move.w	obTrap_WaitMaster(a0),obTrap_WaitTime(a0)

Trap_Wait:
		subq.w	#1,obTrap_WaitTime(a0)		; decrement timer
		bmi.s	.open						; branch if time is up
		moveq	#75,d1						; width; save 4 cycles - Filter
		moveq	#12,d2						; height (jumping); save 4 cycles - Filter
		moveq	#13,d3						; height (walking); save 4 cycles - Filter
		move.w	obX(a0),d4					; axis position
		bsr.w	SolidObject
		bra.w	RememberState
; ===========================================================================

	.open:
		obj_addr	#Trap_Open
		bsr.w	Trap_NotSolid
		tst.b	obRender(a0)
		bpl.s	.no_sound					; branch if off screen
		move.w	#sfx_Door,d0
		jsr		(QueueSound2).w				; play door sound
		
	.no_sound:
		move.b	#0,obAnim(a0)				; opening animation
		bclr	#7,obAnim(a0)				; clear restart flag
; ---------------------------------------------------------------------------

Trap_Open:
		lea		Ani_Trap(pc),a1
		jsr		(AnimateSprite).w
		cmpi.b	#2,obFrame(a0)
		bne.w	RememberState				; branch if animation isn't finished
		obj_addr	#Trap_Wait2
		move.w	obTrap_WaitMaster(a0),obTrap_WaitTime(a0) ; reset timer
		bra.w	RememberState
; ===========================================================================

Trap_Wait2:
		subq.w	#1,obTrap_WaitTime(a0)		; decrement timer
		bmi.s	.close						; branch if time is up
		bra.w	RememberState
		
	.close:
		obj_addr	#Trap_Close
		tst.b	obRender(a0)
		bpl.s	.no_sound					; branch if off screen
		move.w	#sfx_Door,d0
		jsr		(QueueSound2).w				; play door sound
		
	.no_sound:
		move.b	#1,obAnim(a0)				; closing animation
		bclr	#7,obAnim(a0)				; clear restart flag
; ---------------------------------------------------------------------------

Trap_Close:
		lea		Ani_Trap(pc),a1
		jsr		(AnimateSprite).w
		tst.b	obFrame(a0)					; is frame number 0 displayed?
		bne.w	RememberState				; branch if animation isn't finished
		obj_addr	#Trap_Wait
		move.w	obTrap_WaitMaster(a0),obTrap_WaitTime(a0) ; reset timer
		bra.w	RememberState
; ===========================================================================

Trap_NotSolid:
		btst	#staSonicOnObj,obStatus(a0)	; is Sonic standing on the trapdoor?
		beq.w	RememberState				; if not, branch
		bclr	#staOnObj,(v_player+obStatus).w
		bclr	#staSonicOnObj,obStatus(a0)	; removed obSolid
		bra.w	RememberState
; ===========================================================================