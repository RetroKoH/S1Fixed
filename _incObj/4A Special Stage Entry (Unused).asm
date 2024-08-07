; ---------------------------------------------------------------------------
; Object 4A - special stage entry from beta
; ---------------------------------------------------------------------------

VanishSonic:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		jmp		Van_Index(pc,d0.w)
; ===========================================================================
Van_Index:
		bra.s Van_Main
		bra.s Van_RmvSonic
		bra.s Van_LoadSonic

van_time = objoff_30		; time for Sonic to disappear
; ===========================================================================

Van_Main:	; Routine 0
		tst.l	(v_plc_buffer).w ; are pattern load cues empty?
		beq.s	.isempty	; if yes, branch
		rts	

.isempty:
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Vanish,obMap(a0)
		move.b	#4,obRender(a0)
		move.w	#priority1,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$38,obActWid(a0)
		move.w	#make_art_tile(ArtTile_Warp,0,0),obGfx(a0)
		move.w	#120,van_time(a0) ; set time for Sonic's disappearance to 2 seconds

Van_RmvSonic:	; Routine 2
		move.w	(v_player+obX).w,obX(a0)
		move.w	(v_player+obY).w,obY(a0)
		move.b	(v_player+obStatus).w,obStatus(a0)
		lea		Ani_Vanish(pc),a1
		jsr		(AnimateSprite).w
		cmpi.b	#2,obFrame(a0)
		bne.s	.display
		tst.b	(v_player).w
		beq.s	.display
		clr.b	(v_player).w	; remove Sonic
		move.w	#sfx_SSGoal,d0
		jsr		(PlaySound_Special).w	; play Special Stage "GOAL" sound

.display:
		jmp		(DisplaySprite).l
; ===========================================================================

Van_LoadSonic:	; Routine 4
		subq.w	#1,van_time(a0)	; subtract 1 from time
		bne.s	.wait		; if time remains, branch
		move.b	#id_SonicPlayer,(v_player).w ; load Sonic object
		jmp		(DeleteObject).l

.wait:
		rts	