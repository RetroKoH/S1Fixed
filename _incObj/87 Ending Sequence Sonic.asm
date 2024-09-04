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
		offsetTableEntry.w ESon_ClrObjRam
		offsetTableEntry.w ESon_Animate
		offsetTableEntry.w ESon_MakeLogo
		offsetTableEntry.w ESon_Animate
		offsetTableEntry.w ESon_Leap
		offsetTableEntry.w ESon_Animate

eson_time = objoff_30	; time to wait between events (truncated down to 1 byte)
; ===========================================================================

ESon_Main:	; Routine 0
		cmpi.b	#emldCount,(v_emeralds).w		; do you have all emeralds?
		beq.s	ESon_Main2						; if yes, branch
		addi.b	#$10,ob2ndRout(a0)				; else, skip emerald sequence
		move.b	#216,eson_time(a0)				; set wait timer
		jmp		(DisplaySprite).l	
; ===========================================================================

ESon_Main2:
		addq.b	#2,ob2ndRout(a0)
		move.l	#Map_ESon,obMap(a0)
		move.w	#make_art_tile(ArtTile_Ending_Sonic,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		clr.b	obStatus(a0)
		move.w	#priority2,obPriority(a0)		; RetroKoH/Devon S3K+ Priority Manager
		clr.b	obFrame(a0)
		move.b	#80,eson_time(a0)				; set duration for Sonic to pause

ESon_MakeEmeralds:	; Routine 2
		subq.b	#1,eson_time(a0)				; subtract 1 from duration
		bne.s	ESon_Wait						; if time remains, branch
		addq.b	#2,ob2ndRout(a0)				; set to Routine 4
		move.w	#1,obAnim(a0)
		move.b	#id_EndChaos,(v_endemeralds).w	; load chaos emeralds objects

ESon_Wait:
		jmp		(DisplaySprite).l	
; ===========================================================================

ESon_LookUp:	; Routine 6
		cmpi.w	#$2000,((v_endemeralds+echa_radius)&$FFFFFF).l
		bne.s	locret_5480
		move.b	#1,(f_restart).w				; set level to restart (causes flash)
		move.b	#90,eson_time(a0)
		addq.b	#2,ob2ndRout(a0)

locret_5480:
		jmp		(DisplaySprite).l	
; ===========================================================================

ESon_ClrObjRam:	; Routine 8
		subq.b	#1,eson_time(a0)
		bne.s	ESon_Wait2
		lea		(v_endemeralds).w,a1
		move.w	#(v_endemeralds_end-v_endemeralds)/4-1,d1

ESon_ClrLoop:
		clr.l	(a1)+
		dbf		d1,ESon_ClrLoop					; clear the object RAM
		move.b	#1,(f_restart).w
		addq.b	#2,ob2ndRout(a0)
		move.b	#1,obAnim(a0)
		move.b	#60,eson_time(a0)

ESon_Wait2:
		jmp		(DisplaySprite).l	
; ===========================================================================

ESon_MakeLogo:	; Routine $C
		subq.b	#1,eson_time(a0)
		bne.s	ESon_Wait3
		addq.b	#2,ob2ndRout(a0)
		move.b	#180,eson_time(a0)
		move.b	#2,obAnim(a0)
		move.b	#id_EndSTH,(v_endlogo).w		; load "SONIC THE HEDGEHOG" object

ESon_Wait3:
		jmp		(DisplaySprite).l	
; ===========================================================================

ESon_Leap:	; Routine $10
		subq.b	#1,eson_time(a0)
		bne.s	ESon_Wait4
		addq.b	#2,ob2ndRout(a0)
		move.l	#Map_ESon,obMap(a0)
		move.w	#make_art_tile(ArtTile_Ending_Sonic,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		clr.b	obStatus(a0)
		move.w	#priority2,obPriority(a0)		; RetroKoH/Devon S3K+ Priority Manager
		move.b	#5,obFrame(a0)
		move.b	#2,obAnim(a0)					; use "leaping"	animation
		move.b	#id_EndSTH,(v_endlogo).w		; load "SONIC THE HEDGEHOG" object

ESon_Animate:	; Routine 4, $A, $E, $12
		lea		AniScript_ESon(pc),a1
		jsr		(AnimateSprite).w

ESon_Wait4:
		jmp		(DisplaySprite).l
