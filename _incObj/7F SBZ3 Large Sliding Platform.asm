; ---------------------------------------------------------------------------
; Object 7F - large sliding platform (LZ/SBZ3)
; Split from Obj6B by RetroKoH (Special Thanks: Hivebrain)
; ---------------------------------------------------------------------------
; OST Constants
obSlid_StartX:			equ objoff_30		; 2 bytes | starting X-axis position
obSlid_StartY:			equ objoff_32		; 2 bytes | starting Y-axis position
obSlid_ButtonFlag:		equ objoff_34		; 1 byte  | flag set when associated button is pressed
obSlid_ButtonNum:		equ objoff_35		; 1 byte  | button number associated with door
; ---------------------------------------------------------------------------

SlidingPlatform:
		_move.l	#Slid_Action,obAddr(a0)
		move.l	#Map_Slid,obMap(a0)
		move.w	#make_art_tile(ArtTile_LZ_Block_2,2,0),obGfx(a0)
		move.b	#$80,obDispWid(a0)
		move.b	#$40,obHeight(a0)		; TO-DO: Add obDispHgt so this always renders correctly
		bset	#0,(v_obj6B).w			; flag object as loaded
		beq.s	.sbz3_init				; branch if not previously loaded

	.chkdel:
		move.w	obRespawnAddr(a0),d0	; get address in respawn table
		beq.s	.delete					; if it's zero, don't remember object
		movea.w	d0,a2					; load address into a2
		bclr	#7,(a2)					; clear respawn table entry, so object can be loaded again

	.delete:
		jmp		(DeleteObject).l
; ===========================================================================

	.sbz3_init:
		cmpi.w	#$A80,obX(a0)			; is object in its starting position?
		bne.s	.skip_sbz3_init			; if not, branch
		move.w	obRespawnAddr(a0),d0	; get address in respawn table
		beq.s	.skip_sbz3_init			; if it's zero, don't remember object
		movea.w	d0,a2					; load address into a2
		btst	#0,(a2)
		beq.s	.skip_sbz3_init
		clr.b	(v_obj6B).w
		bra.s	.chkdel
; ===========================================================================

	.skip_sbz3_init:
		ori.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.w	obX(a0),obSlid_StartX(a0)
		move.w	obY(a0),obSlid_StartY(a0)
		moveq	#0,d0
		move.b	obSubtype(a0),d0			; get subtype
		beq.s	Slid_Action					; branch if 00

		andi.b	#$F,d0						; read only low nybble
		move.b	d0,obSlid_ButtonNum(a0)		; copy to obSlid_ButtonNum
		bset	#renUseHeight,obRender(a0)	; set height flag, as this is a larger object

	.chkgone:
		move.w	obRespawnAddr(a0),d0		; get address in respawn table
		beq.s	Slid_Action					; if it's zero, don't remember object
		movea.w	d0,a2						; load address into a2
		bclr	#7,(a2)						; clear respawn table entry, so object can be loaded again
; ---------------------------------------------------------------------------

Slid_Action:	; Routine 2
		move.w	obX(a0),-(sp)				; save x pos to stack
		tst.b	obSubtype(a0)				; should it slide?
		beq.s	.type00						; if not, branch
		bsr.w	Slid_SlideDiagonal

	.type00:
		move.w	(sp)+,d4					; retrieve x pos from stack
		tst.b	obRender(a0)
		bpl.s	.chkdel

		; solid
		moveq	#0,d1
		move.b	obDispWid(a0),d1
		addi.w	#$B,d1
		moveq	#$40,d2						; height (jumping)
		moveq	#$41,d3						; height (walking)
		jsr		(SolidObject).l

	.chkdel:
		offscreen.s	.chkgone,obSlid_StartX(a0)
		jmp	(DisplaySprite).l
; ---------------------------------------------------------------------------

	.chkgone:
		clr.b	(v_obj6B).w
		move.w	obRespawnAddr(a0),d0	; get address in respawn table
		beq.s	.delete					; if it's zero, don't remember object
		movea.w	d0,a2					; load address into a2
		bclr	#7,(a2)					; clear respawn table entry, so object can be loaded again

	.delete:
		jmp	(DeleteObject).l
; ===========================================================================

Slid_SlideDiagonal:
		tst.b	obSlid_ButtonFlag(a0)		; has door been activated?
		bne.s	.update_pos					; if yes, branch
		lea		(f_switch).w,a2
		moveq	#0,d0
		move.b	obSlid_ButtonNum(a0),d0
		btst	#0,(a2,d0.w)				; has relevant button been pressed?
		beq.s	.exit						; if not, branch
		move.b	#1,obSlid_ButtonFlag(a0)	; set active flag
		move.w	obRespawnAddr(a0),d0		; get address in respawn table
		beq.s	.update_pos					; if it's zero, don't remember object
		movea.w	d0,a2						; load address into a2
		bclr	#7,(a2)						; clear respawn table entry, so object can be loaded again
; S1 SCE uses 	bset	#0,(a2) here

.update_pos:
		subi.l	#$10000,obX(a0)				; move left 1px
		addi.l	#$8000,obY(a0)				; move down 0.5px
		move.w	obX(a0),obSlid_StartX(a0)
		cmpi.w	#$980,obX(a0)				; has door reached target position?
		beq.s	.finish						; if yes, branch

.exit:
		rts	
; ===========================================================================

.finish:
		clr.b	obSubtype(a0)				; change type to 0 (doesn't move)
		clr.b	obSlid_ButtonFlag(a0)
		rts	
; ===========================================================================