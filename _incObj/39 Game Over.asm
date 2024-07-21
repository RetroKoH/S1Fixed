; ---------------------------------------------------------------------------
; Object 39 - "GAME OVER" and "TIME OVER"
; ---------------------------------------------------------------------------

GameOverCard:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Over_Index(pc,d0.w),d1
		jmp		Over_Index(pc,d1.w)
; ===========================================================================
Over_Index:		offsetTable
		offsetTableEntry.w Over_ChkPLC
		offsetTableEntry.w Over_Move
		offsetTableEntry.w Over_Wait
; ===========================================================================

Over_ChkPLC:	; Routine 0
		tst.l	(v_plc_buffer).w	; are the pattern load cues empty?
		beq.s	Over_Main			; if yes, branch
		rts	
; ===========================================================================

Over_Main:
		addq.b	#2,obRoutine(a0)
		move.w	#$50,obX(a0)	; set x-position
		btst	#0,obFrame(a0)	; is the object	"OVER"?
		beq.s	Over_1stWord	; if not, branch
		move.w	#$1F0,obX(a0)	; set x-position for "OVER"

Over_1stWord:
		move.w	#$F0,obScreenY(a0)
		move.l	#Map_Over,obMap(a0)
		move.w	#make_art_tile(ArtTile_Game_Over,0,1),obGfx(a0)
		clr.b	obRender(a0)
		move.w	#priority0,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager

Over_Move:	; Routine 2
		moveq	#$10,d1		; set horizontal speed
		cmpi.w	#$120,obX(a0)	; has item reached its target position?
		beq.s	Over_SetWait	; if yes, branch
		bcs.s	Over_UpdatePos
		neg.w	d1

Over_UpdatePos:
		add.w	d1,obX(a0)	; change item's position
		bra.w	DisplaySprite
; ===========================================================================

Over_SetWait:
		move.w	#720,obTimeFrame(a0)	; set time delay to 12 seconds
		addq.b	#2,obRoutine(a0)
		bra.w	DisplaySprite			; RetroKoH GAME OVER Flicker fix	
; ===========================================================================

Over_Wait:	; Routine 4
		move.b	(v_jpadpress1).w,d0
		andi.b	#btnABC,d0	; is button A, B or C pressed?
		bne.s	Over_ChgMode	; if yes, branch
		btst	#0,obFrame(a0)
		bne.w	DisplaySprite
		tst.w	obTimeFrame(a0)	; has time delay reached zero?
		beq.s	Over_ChgMode	; if yes, branch
		subq.w	#1,obTimeFrame(a0) ; subtract 1 from time delay
		bra.w	DisplaySprite
; ===========================================================================

Over_ChgMode:
		tst.b	(f_timeover).w	; is time over flag set?
		bne.s	Over_ResetLvl	; if yes, branch
		move.b	#id_Continue,(v_gamemode).w ; set mode to $14 (continue screen)
		tst.b	(v_continues).w	; do you have any continues?
		bne.w	DisplaySprite	; if yes, branch
		move.b	#id_Sega,(v_gamemode).w ; set mode to 0 (Sega screen)
		bra.w	DisplaySprite
; ===========================================================================

Over_ResetLvl:
		clr.l	(v_lamp_time).w		; reset lamp time
		move.w	#1,(f_restart).w	; restart level
		bra.w	DisplaySprite
