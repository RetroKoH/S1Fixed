; ---------------------------------------------------------------------------
; Object 87 - Sonic on ending sequence
; ---------------------------------------------------------------------------

EndSonic:
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	ESon_Index(pc,d0.w),d1
		jmp		ESon_Index(pc,d1.w)
; ===========================================================================
ESon_Index:		offsetTable
		offsetTableEntry.w ESon_Main
		offsetTableEntry.w ESon_MakeEmeralds
		offsetTableEntry.w ESon_Animate
		offsetTableEntry.w ESon_LookUp
		offsetTableEntry.w ESon_ClrEmeralds
		offsetTableEntry.w ESon_Animate
		offsetTableEntry.w ESon_MakeLogo
		offsetTableEntry.w ESon_Animate
		offsetTableEntry.w ESon_Leap
		offsetTableEntry.w ESon_Animate
; ===========================================================================

ESon_Main:	; Routine 0
		cmpi.b	#emldCount,(v_emeralds).w		; do you have all emeralds?
		beq.s	.all_emeralds					; if yes, branch
		addi.b	#$10,ob2ndRout(a0)				; -> ESon_Leap
		move.b	#216,obESonic_WaitTime(a0)		; set wait timer
		jmp		(DisplaySprite).l	
; ===========================================================================

	.all_emeralds:
		addq.b	#2,ob2ndRout(a0)				; -> ESon_MakeEmeralds
		move.l	#Map_ESon,obMap(a0)
		move.w	#make_art_tile(ArtTile_Ending_Sonic,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		clr.b	obStatus(a0)
		move.w	#priority2,obPriority(a0)		; RetroKoH/Devon S3K+ Priority Manager
		clr.b	obFrame(a0)
		move.b	#80,obESonic_WaitTime(a0)		; set duration for Sonic to pause
; ---------------------------------------------------------------------------

ESon_MakeEmeralds:	; Routine 2
		subq.b	#1,obESonic_WaitTime(a0)		; subtract 1 from duration
		bne.s	.wait							; if time remains, branch
		addq.b	#2,ob2ndRout(a0)				; -> ESon_Animate
		moveq	#0,d0
		move.b	d0,obAnim(a0)					; use "hold emeralds" animation
		move.b	d0,obAniFrame(a0)				; reset animation
		move.b	d0,obTimeFrame(a0)				; reset frame duration
		move.b	#id_EndChaos,(v_endemeralds).w	; load chaos emeralds objects

	.wait:
		jmp		(DisplaySprite).l	
; ===========================================================================

ESon_LookUp:	; Routine 6
		cmpi.w	#$2000,((v_endemeralds+echa_radius)&$FFFFFF).l	; has emerald circle expanded fully?
		bne.s	.wait							; if not, branch

		move.b	#1,(f_restart).w				; set level to restart (causes flash)
		move.b	#90,obESonic_WaitTime(a0)		; set delay to 1.5 seconds
		addq.b	#2,ob2ndRout(a0)				; -> ESon_ClrEmeralds

	.wait:
		jmp		(DisplaySprite).l	
; ===========================================================================

ESon_ClrEmeralds:	; Routine 8
		subq.b	#1,obESonic_WaitTime(a0)		; decrement timer
		bne.s	.wait

		lea		(v_endemeralds).w,a1			; address of emeralds
		move.w	#(v_endemeralds_end-v_endemeralds)/4-1,d1

	.loop:
		clr.l	(a1)+
		dbf		d1,.loop						; clear the object RAM

		move.b	#1,(f_restart).w
		addq.b	#2,ob2ndRout(a0)				; -> ESon_Animate
		move.b	#1,obAnim(a0)					; use "confused" animation
		move.b	#60,obESonic_WaitTime(a0)		; set delay to 1 second

	.wait:
		jmp		(DisplaySprite).l	
; ===========================================================================

ESon_MakeLogo:	; Routine $C
		subq.b	#1,obESonic_WaitTime(a0)		; decrement timer
		bne.s	.wait							; if time remains, branch

		addq.b	#2,ob2ndRout(a0)				; -> ESon_Animate
		move.b	#180,obESonic_WaitTime(a0)		; set delay to 3 seconds
		move.b	#2,obAnim(a0)					; use "leaping" animation
		move.b	#id_EndSTH,(v_endlogo).w		; load "SONIC THE HEDGEHOG" object

	.wait:
		jmp		(DisplaySprite).l	
; ===========================================================================

ESon_Leap:	; Routine $10
		subq.b	#1,obESonic_WaitTime(a0)		; decrement timer
		bne.s	ESon_Display					; if time remains, branch

		addq.b	#2,ob2ndRout(a0)				; -> ESon_Animate
		move.l	#Map_ESon,obMap(a0)
		move.w	#make_art_tile(ArtTile_Ending_Sonic,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		clr.b	obStatus(a0)
		move.w	#priority2,obPriority(a0)		; RetroKoH/Devon S3K+ Priority Manager
		move.b	#5,obFrame(a0)
		move.b	#2,obAnim(a0)					; use "leaping" animation
		move.b	#id_EndSTH,(v_endlogo).w		; load "SONIC THE HEDGEHOG" object

ESon_Animate:	; Routine 4, $A, $E, $12
		lea		AniScript_ESon(pc),a1
		jsr		(AnimateSprite).w

ESon_Display:
		jmp		(DisplaySprite).l
; ===========================================================================