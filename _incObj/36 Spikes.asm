; ---------------------------------------------------------------------------
; Object 36 - spikes
; ---------------------------------------------------------------------------
; OST Constants
obSpike_StartX:			equ objoff_30		; 2 bytes | starting X-axis position
obSpike_StartY:			equ objoff_32		; 2 bytes | starting Y-axis position
obSpike_MoveDist:		equ objoff_34		; 1 byte  | pixel distance to move object * $100, either direction
obSpike_MoveFlag:		equ objoff_35		; 1 byte  | 0 = original position; 1 = moved position
obSpike_MoveTime:		equ objoff_36		; 1 byte  | time until object moves again
; ---------------------------------------------------------------------------

; ===========================================================================

Spik_Var:
		; frame	number,	object width
		dc.b 0,	$14			; $0x (3 up)
		dc.b 1,	$10			; $1x (3 left)
		dc.b 2,	4			; $2x (1 up)
		dc.b 3,	$1C			; $3x (3 up -- wide)
		dc.b 4,	$40			; $4x (6 up -- wide)
		dc.b 5,	$10			; $5x (1 left)
; ===========================================================================

Spikes:
		obj_addr	#Spik_Solid
		move.l	#Map_Spike,obMap(a0)
		move.w	#make_art_tile(ArtTile_Spikes,0,0),obGfx(a0)
		ori.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	obSubtype(a0),d0
		andi.b	#$F,obSubtype(a0)			; reduce subtype to just the low nybble
		andi.w	#$F0,d0						; get high nybble of original subtype
		lea		(Spik_Var).l,a1
		lsr.w	#3,d0
		adda.w	d0,a1						; use high nybble of subtype to get frame & width info
		move.b	(a1)+,obFrame(a0)
		move.b	(a1)+,obDispWid(a0)
		move.w	obX(a0),obSpike_StartX(a0)
		move.w	obY(a0),obSpike_StartY(a0)
; ---------------------------------------------------------------------------

Spik_Solid:
		bsr.w	Spike_Move					; update position
		moveq	#4,d2						; height for type $5x (jumping); save 4 cycles - Filter
		cmpi.b	#5,obFrame(a0)				; is object type $5x ?
		beq.s	Spik_SideWays				; if yes, branch
		cmpi.b	#1,obFrame(a0)				; is object type $1x ?
		bne.s	Spik_Upright				; if not, branch
		moveq	#20,d2						; height for type $1x (jumping); save 4 cycles - Filter

; Spikes types $1x and $5x face	sideways
Spik_SideWays:
		moveq	#27,d1						; width; save 4 cycles - Filter
		move.w	d2,d3						; height (walking)
		addq.w	#1,d3						; add 1 for walking height
		move.w	obX(a0),d4					; axis position
		bsr.w	SolidObject					; detect collision
		btst	#staSonicOnObj,obStatus(a0)
		bne.s	Spik_Display
		cmpi.w	#1,d4
		beq.s	Spik_Hurt
		bra.s	Spik_Display
; ===========================================================================

; Spikes types $0x, $2x, $3x and $4x face up or	down
Spik_Upright:
		moveq	#11,d1
		add.b	obDispWid(a0),d1			; width; save 8 cycles
		moveq	#16,d2						; height (jumping); save 4 cycles - Filter
		moveq	#17,d3						; height (walking); save 4 cycles - Filter
		move.w	obX(a0),d4
		bsr.w	SolidObject					; detect collision
		btst	#staSonicOnObj,obStatus(a0)	; is Sonic on top of the spikes?
		bne.s	Spik_Hurt					; if yes, branch
		tst.w	d4
		bpl.s	Spik_Display				; branch if Sonic is touching sides, or not touching at all

Spik_Hurt:
		btst	#sta2ndInvinc,(v_player+obStatus2nd).w	; is Sonic invincible?
		bne.s	Spik_Display							; if yes, branch

	if SpikeBugFix		; Mercury Spike Bug Fix
		tst.b	(v_player+obInvuln).w					; is Sonic invulnerable? -- RetroKoH Sonic SST Compaction
		bne.s	Spik_Display							; if yes, branch
	endif	; Spike Bug Fix End

		move.l	a0,-(sp)					; save address of the spikes to the stack
		movea.l	a0,a2						; load the spikes to a2
		lea		(v_player).w,a0				; a0 is temporarily Sonic now
		cmpi.b	#4,obRoutine(a0)			; is Sonic hurt or dead?
		bhs.s	.is_hurt					; if yes, branch
		move.l	obY(a0),d3
		move.w	obVelY(a0),d0
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d3
		move.l	d3,obY(a0)					; move Sonic away from spikes, based on his y speed
		jsr		(HurtSonic).l				; lose rings/die

	.is_hurt:
		movea.l	(sp)+,a0					; restore OST address for spikes from stack

Spik_Display:
		offscreen.w	DeleteObject,obSpike_StartX(a0)	; ProjectFM S3K Object Manager
		bra.w	DisplaySprite					; Clownacy DisplaySprite Fix
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to move spikes
; ---------------------------------------------------------------------------

Spike_Move:
	; LavaGaming Object Routine Optimization
		moveq	#0,d0
		move.b	obSubtype(a0),d0			; get subtype (only low nybble remains)
		subq.b	#1,d0
		tst.b	d0
		beq.s	Spike_UpDown
		bpl.s	Spike_LeftRight

; Type 0 - doesn't move
Spik_Type00:
		rts
	; Object Routine Optimization End
; ===========================================================================

; Type 1 - moves up and down
Spike_UpDown:
		bsr.w	Spik_Wait					; run timer and update obSpike_MoveDist
		moveq	#0,d0
		move.b	obSpike_MoveDist(a0),d0		; get distance to move
		add.w	obSpike_StartY(a0),d0		; add to initial y position
		move.w	d0,obY(a0)					; update position
		rts	
; ===========================================================================

; Type 2 - moves side-to-side
Spike_LeftRight:
		bsr.w	Spik_Wait					; run timer and update obSpike_MoveDist
		moveq	#0,d0
		move.b	obSpike_MoveDist(a0),d0		; get distance to move
		add.w	obSpike_StartX(a0),d0		; add to initial x position
		move.w	d0,obX(a0)					; update position
		rts	
; ===========================================================================

Spik_Wait:
		tst.b	obSpike_MoveTime(a0)		; is time delay	= zero?
		beq.s	.update						; if yes, branch
		subq.b	#1,obSpike_MoveTime(a0)		; subtract 1 from time delay
		bne.s	.exit						; branch if not 0
		tst.b	obRender(a0)				; is spikes object on-screen?
		bpl.s	.exit						; if not, branch
		move.w	#sfx_SpikesMove,d0
		jmp		(QueueSound2).w				; play "spikes moving" sound
; ===========================================================================

	.update:
		tst.b	obSpike_MoveFlag(a0)		; are spikes in original position?
		beq.s	.original_pos				; if yes, branch
		subi.b	#8,obSpike_MoveDist(a0)		; subtract 8px from distance
		bcc.s	.exit						; branch if 0 or more
		clr.w	obSpike_MoveDist(a0)		; clear obSpike_MoveDist and obSpike_MoveFlag
		move.b	#60,obSpike_MoveTime(a0)	; set time delay to 1 second
		rts
; ===========================================================================

	.original_pos:
		addi.b	#8,obSpike_MoveDist(a0)		; add 8px to move distance
		cmpi.b	#$20,obSpike_MoveDist(a0)	; has it moved 32px?
		blo.s	.exit						; if not, branch
		move.b	#$20,obSpike_MoveDist(a0)	; set max distance
		move.b	#1,obSpike_MoveFlag(a0)		; set flag that spikes are in new position
		move.b	#60,obSpike_MoveTime(a0)	; set time delay to 1 second

	.exit:
		rts	
; ===========================================================================