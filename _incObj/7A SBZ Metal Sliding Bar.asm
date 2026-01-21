; ---------------------------------------------------------------------------
; Object 7A - thin metal horizontal sliding bar (SBZ)
; Split from Obj6B by RetroKoH (Special Thanks: Hivebrain)
; ---------------------------------------------------------------------------
; OST Constants
obMBar_StartX:			equ objoff_30		; 2 bytes | starting X-axis position
obMBar_StartY:			equ objoff_32		; 2 bytes | starting Y-axis position
obMBar_WaitTime:		equ objoff_34		; 1 byte  | time until next action
obMBar_ButtonFlag:		equ objoff_35		; 1 byte  | flag set when associated button is pressed
obMBar_DistMoved:		equ objoff_36		; 2 bytes | distance moved
obMBar_DistToMove:		equ objoff_38		; 2 bytes | distance to move
obMBar_ButtonNum:		equ objoff_3A		; 1 byte  | button number associated with door
; ---------------------------------------------------------------------------

MetalBar:
		_move.l	#MBar_Action,obAddr(a0)
		move.l	#Map_MetalBar,obMap(a0)
		move.w	#make_art_tile(ArtTile_SBZ_Horizontal_Door,1,0),obGfx(a0)
		ori.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$40,obDispWid(a0)
		move.b	#$C,obHeight(a0)
		move.w	obX(a0),obMBar_StartX(a0)
		move.w	obY(a0),obMBar_StartY(a0)
		move.w	#$80,obMBar_DistToMove(a0)	; set distance to move
		moveq	#$F,d0						; read only low nybble of subtype
		and.b	obSubtype(a0),d0			; SCE Optimization
		move.b	d0,obMBar_ButtonNum(a0)
		move.b	#1,obSubtype(a0)			; update subtype with value from list

		move.w	obRespawnAddr(a0),d0		; get address in respawn table
		beq.s	MBar_Action					; if it's zero, don't remember object
		movea.w	d0,a2						; load address into a2
		bclr	#7,(a2)						; clear respawn table entry, so object can be loaded again
; ---------------------------------------------------------------------------

MBar_Action:	; Routine 2
		move.w	obX(a0),-(sp)				; save x pos to stack
		moveq	#$F,d0						; get last digit of subtype
		and.b	obSubtype(a0),d0			; SCE optimization
		beq.s	.type00						; skip if subtype 00
		add.w	d0,d0
		move.w	MBar_Index-2(pc,d0.w),d1
		jsr		MBar_Index(pc,d1.w)

	.type00:
		move.w	(sp)+,d4					; retrieve x pos from stack
		tst.b	obRender(a0)
		bpl.s	.chkdel

		; solid
		moveq	#0,d1
		move.b	obDispWid(a0),d1
		addi.w	#$B,d1
		moveq	#0,d2
		move.b	obHeight(a0),d2
		move.w	d2,d3
		addq.w	#1,d3
		jsr		(SolidObject).l

	.chkdel:
		offscreen.s	.delete,obMBar_StartX(a0)
		jmp	(DisplaySprite).l
; ---------------------------------------------------------------------------

	.delete:
		jmp	(DeleteObject).l
; ===========================================================================
MBar_Index:	offsetTable
		offsetTableEntry.w MBar_SlideOpen
		offsetTableEntry.w MBar_SlideClose
; ===========================================================================

; Type 1
; Horizonal door, opens when button (ost_stomp_button_num) is pressed
MBar_SlideOpen:
		tst.b	obMBar_ButtonFlag(a0)		; has door been activated?
		bne.s	.isactive01					; if yes, branch
		lea	(f_switch).w,a2
		moveq	#0,d0
		move.b	obMBar_ButtonNum(a0),d0
		btst	#0,(a2,d0.w)				; has button been pressed?
		beq.s	.update_pos					; if not, branch
		move.b	#1,obMBar_ButtonFlag(a0)

	.isactive01:
		move.w	obMBar_DistToMove(a0),d0	; get target distance
		cmp.w	obMBar_DistMoved(a0),d0		; has door moved that distance?
		beq.s	.finished01					; if yes, branch
		addq.w	#2,obMBar_DistMoved(a0)		; move 2px

	.update_pos:
		move.w	obMBar_DistMoved(a0),d0
		btst	#staFlipX,obStatus(a0)
		beq.s	.noflip01
		neg.w	d0
		addi.w	#$80,d0

	.noflip01:
		move.w	obMBar_StartX(a0),d1		; get initial x pos
		sub.w	d0,d1						; apply difference
		move.w	d1,obX(a0)					; update position
		rts	
; ===========================================================================

	.finished01:
		addq.b	#1,obSubtype(a0)			; change to subtype 2
		move.b	#180,obMBar_WaitTime(a0)	; set timer to 3 seconds
		clr.b	obMBar_ButtonFlag(a0)		; clear active flag
		move.w	obRespawnAddr(a0),d0		; get address in respawn table
		beq.s	.update_pos					; if it's zero, don't remember object
		movea.w	d0,a2						; load address into a2
		bset	#0,(a2)
		bra.s	.update_pos
; ===========================================================================

; Type 2
; Horizonal door, returns to its original position after 3 seconds
MBar_SlideClose:
		tst.b	obMBar_ButtonFlag(a0)		; has door been activated?
		bne.s	.isactive02					; if yes, branch
		subq.b	#1,obMBar_WaitTime(a0)		; decrement timer
		bne.s	.update_pos					; branch if time remains
		move.b	#1,obMBar_ButtonFlag(a0)

	.isactive02:
		tst.w	obMBar_DistMoved(a0)		; has door reached its original position?
		beq.s	.finished02					; if yes, branch
		subq.w	#2,obMBar_DistMoved(a0)		; move back 2px

	.update_pos:
		move.w	obMBar_DistMoved(a0),d0
		btst	#staFlipX,obStatus(a0)
		beq.s	.noflip02
		neg.w	d0
		addi.w	#$80,d0

	.noflip02:
		move.w	obMBar_StartX(a0),d1		; get initial x pos
		sub.w	d0,d1						; apply difference
		move.w	d1,obX(a0)					; update position
		rts	
; ===========================================================================

	.finished02:
		subq.b	#1,obSubtype(a0)			; change back to type 1
		clr.b	obMBar_ButtonFlag(a0)		; clear active flag
		move.w	obRespawnAddr(a0),d0		; get address in respawn table
		beq.s	.update_pos					; if it's zero, don't remember object
		movea.w	d0,a2						; load address into a2
		bclr	#0,(a2)
		bra.s	.update_pos
; ===========================================================================