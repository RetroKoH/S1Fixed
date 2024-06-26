; ---------------------------------------------------------------------------
; Object 2E - contents of monitors
; ---------------------------------------------------------------------------

PowerUp:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Pow_Index(pc,d0.w),d1
		jmp		Pow_Index(pc,d1.w)
; ===========================================================================
Pow_Index:
		dc.w	Pow_Main-Pow_Index
		dc.w	Pow_Move-Pow_Index
		dc.w	Pow_Delete-Pow_Index
; ===========================================================================

Pow_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.w	#make_art_tile(ArtTile_Monitor,0,0),obGfx(a0)
		move.b	#$24,obRender(a0)
		move.w	#$180,obPriority(a0)	; RetroKoH S2 Priority Manager
		move.b	#8,obActWid(a0)
		move.w	#-$300,obVelY(a0)
		moveq	#0,d0
		move.b	obAnim(a0),d0	; get subtype
		addq.b	#2,d0
		move.b	d0,obFrame(a0)	; use correct frame
		movea.l	#Map_Monitor,a1
		add.b	d0,d0
		adda.w	(a1,d0.w),a1
		addq.w	#1,a1
		move.l	a1,obMap(a0)

Pow_Move:	; Routine 2
		bsr.s	.moveup
		bra.w	DisplaySprite	; Clownacy DisplaySprite Fix (Alt method by RetroKoH based on S2)
		
.moveup:
		tst.w	obVelY(a0)		; is object moving?
		bpl.w	Pow_Checks		; if not, branch
		bsr.w	SpeedToPos
		addi.w	#$18,obVelY(a0)	; reduce object	speed
		rts
; ===========================================================================

Pow_Checks:
		addq.b	#2,obRoutine(a0)
		move.w	#29,obTimeFrame(a0) ; display icon for half a second

	; RetroKoH Powerup Optimization
		moveq	#0,d0
		move.b	obAnim(a0),d0
		add.w	d0,d0
		move.w	Pow_Types(pc,d0.w),d0
		jmp		Pow_Types(pc,d0.w)
; ===========================================================================
	; Lookup table replaces the old system
Pow_Types:
		dc.w Pow_Null-Pow_Types		; 0 - Static
		dc.w Pow_Eggman-Pow_Types	; 1 - Eggman/Robotnik
		dc.w Pow_Sonic-Pow_Types	; 2 - 1-Up
		dc.w Pow_Shoes-Pow_Types	; 3 - Speed Shoes
		dc.w Pow_Shield-Pow_Types	; 4 - Shield
		dc.w Pow_Invinc-Pow_Types	; 5 - Invincibility
		dc.w Pow_Rings-Pow_Types	; 6 - Rings
	if ShieldsMode>1
		dc.w Pow_FShield-Pow_Types	; 7 - Flame Shield		; Added
		dc.w Pow_BShield-Pow_Types	; 8 - Bubble Shield		; Added
		dc.w Pow_LShield-Pow_Types	; 9 - Lightning Shield	; Added
	endif
		dc.w Pow_S-Pow_Types		; A - S
		dc.w Pow_Goggles-Pow_Types	; B - Goggles
; ===========================================================================
	; Each powerup no longer requires a series of cmpi checks and branches.

Pow_Null:
Pow_Eggman:
		rts					; Eggman monitor does nothing
; ===========================================================================

Pow_Sonic:
ExtraLife:
	; Mercury Lives Over/Underflow Fix
		cmpi.b	#99,(v_lives).w		; are lives at max?
		beq.s	.playbgm
		addq.b	#1,(v_lives).w		; add 1 to number of lives
		addq.b	#1,(f_lifecount).w	; update the lives counter
.playbgm:
	; Lives Over/Underflow Fix End
		move.w	#bgm_ExtraLife,d0
		jmp		(PlaySound).l		; play extra life music
; ===========================================================================

Pow_Shoes:
		bset	#sta2ndShoes,(v_player+obStatus2nd).w	; speed up the BG music
		move.b	#$96,(v_player+obShoes).w				; time limit for the power-up -- RetroKoH Sonic SST Compaction
		movem.l a0-a2,-(sp)								; Move a0, a1 and a2 onto stack
		lea     (v_player).w,a0							; Load Sonic to a0
		lea		(v_sonspeedmax).w,a2					; Load Sonic_top_speed into a2
		jsr		ApplySpeedSettings						; Fetch Speed settings
		movem.l (sp)+,a0-a2								; Move a0, a1 and a2 from stack
		move.w	#bgm_Speedup,d0
		jmp		(PlaySound).l							; Speed	up the music
; ===========================================================================

Pow_Shield:
		andi.b	#mask2ndRmvShield,(v_player+obStatus2nd).w	; remove shield status
		bset	#sta2ndShield,(v_player+obStatus2nd).w		; give Sonic a shield
		move.b	#id_ShieldItem,(v_shieldobj).w				; load shield object ($38)
		clr.b	(v_shieldobj+obRoutine).w
		clr.b	(v_shieldobj+obSubtype).w
		move.w	#sfx_Shield,d0
		jmp		(PlaySound).l								; play shield sound
; ===========================================================================

Pow_Invinc:
		bset	#sta2ndInvinc,(v_player+obStatus2nd).w	; make Sonic invincible
		move.b	#$96,(v_player+obInvinc).w				; time limit for the power-up -- RetroKoH Sonic SST Compaction
		move.b	#id_StarsItem,(v_starsobj1).w			; load stars object
		move.b	#1,(v_starsobj1+obAnim).w
		move.b	#id_StarsItem,(v_starsobj2).w			; load stars object
		move.b	#2,(v_starsobj2+obAnim).w
		move.b	#id_StarsItem,(v_starsobj3).w			; load stars object
		move.b	#3,(v_starsobj3+obAnim).w
		move.b	#id_StarsItem,(v_starsobj4).w			; load stars object
		move.b	#4,(v_starsobj4+obAnim).w
		tst.b	(f_lockscreen).w						; is boss mode on?
		bne.s	.nomusic								; if yes, branch
		cmpi.b	#$C,(v_air).w
		bls.s	.nomusic
		move.w	#bgm_Invincible,d0
		jmp		(PlaySound).l							; play invincibility music
; ===========================================================================

.nomusic:
		rts	
; ===========================================================================

Pow_Rings:
		addi.w	#10,(v_rings).w	; add 10 rings to the number of rings you have
		ori.b	#1,(f_ringcount).w ; update the ring counter
		cmpi.w	#100,(v_rings).w ; check if you have 100 rings
		blo.s	Pow_RingSound
		bset	#1,(v_lifecount).w
		beq.w	ExtraLife
		cmpi.w	#200,(v_rings).w ; check if you have 200 rings
		blo.s	Pow_RingSound
		bset	#2,(v_lifecount).w
		beq.w	ExtraLife

Pow_RingSound:
		move.w	#sfx_Ring,d0
		jmp		(PlaySound).l	; play ring sound
; ===========================================================================

Pow_S:
Pow_Goggles:
		rts			; 'S' and goggles monitors do nothing
; ===========================================================================

	if ShieldsMode>1
Pow_FShield:
		andi.b	#mask2ndRmvShield,(v_player+obStatus2nd).w	; remove shield status
		bset	#sta2ndShield,(v_player+obStatus2nd).w		; give Sonic a shield
		bset	#sta2ndFShield,(v_player+obStatus2nd).w		; give Sonic a flame shield
		move.b	#id_ShieldItem,(v_shieldobj).w				; load shield object
		clr.b	(v_shieldobj+obRoutine).w
		move.b	#2,(v_shieldobj+obSubtype).w
		move.w	#sfx_FShield,d0
		jmp		(PlaySound_Special).l						; play shield sound
; ===========================================================================

Pow_BShield:
		andi.b	#mask2ndRmvShield,(v_player+obStatus2nd).w	; remove shield status
		bset	#sta2ndShield,(v_player+obStatus2nd).w		; give Sonic a shield
		bset	#sta2ndBShield,(v_player+obStatus2nd).w		; give Sonic a bubble shield
		move.b	#id_ShieldItem,(v_shieldobj).w				; load shield object
		clr.b	(v_shieldobj+obRoutine).w
		move.b	#3,(v_shieldobj+obSubtype).w
		move.w	#sfx_BShield,d0
		jmp		(PlaySound_Special).l						; play shield sound
; ===========================================================================

Pow_LShield:
		andi.b	#mask2ndRmvShield,(v_player+obStatus2nd).w	; remove shield status
		bset	#sta2ndShield,(v_player+obStatus2nd).w		; give Sonic a shield
		bset	#sta2ndLShield,(v_player+obStatus2nd).w		; give Sonic a lightning shield
		move.b	#id_ShieldItem,(v_shieldobj).w				; load shield object
		clr.b	(v_shieldobj+obRoutine).w
		move.b	#4,(v_shieldobj+obSubtype).w
		move.w	#sfx_LShield,d0
		jmp		(PlaySound_Special).l						; play shield sound
; ===========================================================================
	endif

Pow_Delete:	; Routine 4
		subq.w	#1,obTimeFrame(a0)
		bmi.w	DeleteObject	; delete after half a second
		bra.w	DisplaySprite	; Clownacy DisplaySprite Fix (Alt method by RetroKoH based on S2)
