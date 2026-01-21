; ---------------------------------------------------------------------------
; Object - ball on a chain that Eggman swings (GHZ)
; ---------------------------------------------------------------------------
; OST Constants
obBossBall_Angle:		equ $10				; 2 bytes | precise rotation angle
	; ^^^ We need this so that obShieldProp isn't overwritten, otherwise
	; Insta-Shield negates its collision property. Upper byte written to obAngle.
	; Unlike other similar objects, I set this to $10 because the GHZ boss chain
	; uses up much of its scratch RAM, and that object uses this object's movement
	; routines.
obBossBall_ChainHead:	equ objoff_30		; 2 bytes | chain head address (for swinging ball visual effect)
obBossBall_BossDist:	equ objoff_32		; 2 bytes | distance of base from boss
obBossBall_Parent:		equ objoff_34		; 4 bytes | address of OST of parent object (need to truncate to 2 bytes)
obBossBall_BaseY:		equ objoff_38		; 2 bytes | Y-axis position of base
obBossBall_BaseX:		equ objoff_3A		; 2 bytes | X-axis position of base
obBossBall_Radius:		equ objoff_3C		; 1 byte  | distance of ball/link from base
obBossBall_Side:		equ objoff_3D		; 1 byte  | which side the ball is on - 0 = right; 1 = left
obBossBall_Speed:		equ objoff_3E		; 2 bytes | rate of change of angle
; ---------------------------------------------------------------------------

BossBall:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	GBall_Index(pc,d0.w),d1
		jmp		GBall_Index(pc,d1.w)
; ===========================================================================

GBall_Index:	offsetTable
		offsetTableEntry.w GBall_Main
		offsetTableEntry.w GBall_Base
		offsetTableEntry.w GBall_Base2
		offsetTableEntry.w GBall_Link
		offsetTableEntry.w GBall_Ball
; ===========================================================================

GBall_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)			; -> GBall_Base
		move.w	#$4080,obBossBall_Angle(a0)
		move.b	obBossBall_Angle(a0),obAngle(a0)
		move.w	#-$200,obBossBall_Speed(a0)
		move.l	#Map_BossItems,obMap(a0)
		move.w	#make_art_tile(ArtTile_Eggman_Weapons,0,0),obGfx(a0)
		lea		obSubtype(a0),a2
		clr.b	(a2)+
		moveq	#5,d1						; load 5 additional objects
		movea.l	a0,a1						; replace current object with chain base
		bra.s	.chain_base
; ===========================================================================

	.loop:
		jsr		(FindNextFreeObj).l			; find free object slot
		bne.s	.make_ball					; branch if not found
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		_move.l	#BossBall,obAddr(a1)		; load chain link object
		move.b	#6,obRoutine(a1)
		move.l	#Map_Swing_GHZ,obMap(a1)
		move.w	#make_art_tile(ArtTile_GHZ_MZ_Swing,0,0),obGfx(a1)
		move.b	#1,obFrame(a1)
		addq.b	#1,obSubtype(a0)

	.chain_base:
		move.w	a1,d5						; address of current object
		subi.w	#v_objspace&$FFFF,d5
		lsr.w	#object_size_bits,d5
		andi.w	#$7F,d5						; convert address to object index
		move.b	d5,(a2)+					; add to list in parent object
		move.b	#4,obRender(a1)
		move.b	#8,obDispWid(a1)
		move.w	#priority6,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		move.w	obBossBall_Parent(a0),obBossBall_Parent(a1)
		dbf		d1,.loop					; repeat sequence 5 more times

	.make_ball:
		move.b	#8,obRoutine(a1)
		move.l	#Map_GBall,obMap(a1)			; load different mappings for final link
		move.w	#make_art_tile(ArtTile_GHZ_Giant_Ball,2,0),obGfx(a1)	; use different graphics
		move.b	#1,obFrame(a1)
		move.w	#priority5,obPriority(a1)		; RetroKoH/Devon S3K+ Priority Manager
		move.b	#(colHarmful|colSz_20x20),obColType(a1)		; make object hurt Sonic
		move.w	a0,obBossBall_ChainHead(a1)				; store address of head chain object to transfer angle to the ball
		rts	
; ===========================================================================

GBall_PosData:	; distances of objects from base
		dc.b 0						; base
		dc.b $10, $20, $30, $40		; chain links
		dc.b $60					; ball
; ===========================================================================

GBall_Base:	; Routine 2
		lea		GBall_PosData(pc),a3
		lea		obSubtype(a0),a2
		moveq	#0,d6
		move.b	(a2)+,d6					; get number of child objects

	.loop:
		moveq	#0,d4
		move.b	(a2)+,d4					; get child object object index
		lsl.w	#object_size_bits,d4
		addi.l	#v_objspace&$FFFFFF,d4
		movea.l	d4,a1						; convert to RAM address
		move.b	(a3)+,d0					; get target distance from base
		cmp.b	obBossBall_Radius(a1),d0	; has object reached target?
		beq.s	.reached_dist				; if yes, branch
		addq.b	#1,obBossBall_Radius(a1)

	.reached_dist:
		dbf		d6,.loop					; repeat for all children

		cmp.b	obBossBall_Radius(a1),d0	; has final object (ball) reached target?
		bne.s	.not_finished				; if not, branch
		movea.w	obBossBall_Parent(a0),a1	; a1 = Eggman
		cmpi.b	#6,ob2ndRout(a1)			; is boss in back-and-forth phase?
		bne.s	.not_finished				; if not, branch
		addq.b	#2,obRoutine(a0)

	if GHZBossDelay
		st.b	obBossGHZ_Active(a1)		; once lowered, Eggman can be hit
	endif

	.not_finished:
		cmpi.w	#$20,obBossBall_BossDist(a0)	; has base moved an additional 32px? (aligned with bottom of ship)
		beq.s	.display					; if yes, branch
		addq.w	#1,obBossBall_BossDist(a0)	; increment distance

	.display:
		bsr.w	GBall_UpdateBase			; update base animation/position
		move.b	obAngle(a0),d0
		bsr.w	BossBall_MoveAll			; update positions of all chain links & ball
		jmp		(DisplayAndCollision).l		; S3K TouchResponse
; ===========================================================================

GBall_Base2:	; Routine 4
		bsr.w	GBall_UpdateBase			; update base animation/position
		bsr.w	GBall_Move					; update angle and positions of child objects
		jmp		(DisplayAndCollision).l		; S3K TouchResponse
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to animate, update position and destroy base
; ---------------------------------------------------------------------------

GBall_UpdateBase:
		movea.w	obBossBall_Parent(a0),a1	; get address of parent
		addi.b	#$20,obAniFrame(a0)			; increment frame counter
		bcc.s	.no_chg						; branch if byte doesn't wrap from $C0 to 0
		bchg	#0,obFrame(a0)				; alternate blinking light every 8th frame

	.no_chg:
		move.w	obX(a1),obBossBall_BaseX(a0)	; get position from parent (ship)
		move.w	obY(a1),d0
		add.w	obBossBall_BossDist(a0),d0
		move.w	d0,obBossBall_BaseY(a0)
		move.b	obStatus(a1),obStatus(a0)
		tst.b	obStatus(a1)					; has boss been beaten?
		bpl.s	.not_beaten						; if not, branch
		_move.l	#ExplosionBomb,obAddr(a0)	; replace base with explosion object
		clr.b	obRoutine(a0)

	.not_beaten:
		rts	
; End of function GBall_UpdateBase
; ===========================================================================

GBall_Link:	; Routine 6
		movea.w	obBossBall_Parent(a0),a1		; get address of OST of parent (ship)
		tst.b	obStatus(a1)					; has boss been beaten?
		bpl.s	.not_beaten						; if not, branch
		_move.l	#ExplosionBomb,obAddr(a0)	; replace chain with explosion object
		clr.b	obRoutine(a0)

.not_beaten:
		jmp		(DisplayAndCollision).l			; S3K TouchResponse
; ===========================================================================

GBall_Ball:	; Routine 8
		moveq	#0,d0
		tst.b	obFrame(a0)				; is ball showing checkered?
		bne.s	GBall_Vanish			; if yes, branch to alt frame (frame 0)
	; RetroKoH angled ball mod
		movea.w	obBossBall_ChainHead(a0),a2	; store chain head address in a2
		move.b	obAngle(a2),d0			; fetch chain's current angle; store it in d0
		subq.b	#1,d0					; subtract 1, because it ranges from 1-$81
		lsr.b	#1,d0					; cut range down to 0-$40
		move.b	GBall_Angles(pc,d0.w),d0
	; angled ball mod end

GBall_Vanish:
		move.b	d0,obFrame(a0)				; set ball frame
		movea.w	obBossBall_Parent(a0),a1	; get address of OST of parent (ship)
		tst.b	obStatus(a1)				; has boss been beaten?
		bpl.s	.display					; if not, branch
		clr.b	obColType(a0)				; make ball harmless
		bsr.w	BossDefeated				; spawn explosions
		subq.b	#1,obBossBall_Radius(a0)	; use radius as timer, decrements from 96
		bpl.s	.display					; branch if time remains
		_move.l	#ExplosionBomb,obAddr(a0)	; replace ball with explosion after 1.5 seconds
		clr.b	obRoutine(a0)

.display:
		jmp		(DisplayAndCollision).l		; S3K TouchResponse
; ===========================================================================

GBall_Angles:
		dc.b	1,1,1,1,1,2,2,2,2,2,2,2,2,3,3,3		; 0 - $F
		dc.b	3,3,3,3,3,3,3,3,1,1,1,1,1,1,1,1		; $10 - $1F
		dc.b	1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2		; $20 - $2F
		dc.b	2,2,2,2,3,3,3,3,3,3,3,3,1,1,1,1,1	; $30 - $40
		even
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to update swinging angle and positions for chain links and boss ball
; (Belongs to the BossBall object)
; ---------------------------------------------------------------------------

GBall_Move:
		tst.b	obBossBall_Side(a0)				; is ball on the left side of the screen?
		bne.s	.left_side						; if yes, branch
		move.w	obBossBall_Speed(a0),d0
		addq.w	#8,d0
		move.w	d0,obBossBall_Speed(a0)			; increase swing speed
		add.w	d0,obBossBall_Angle(a0)			; update angle
		move.b	obBossBall_Angle(a0),obAngle(a0)
		cmpi.w	#$200,d0						; is speed at max?
		bne.s	.not_at_highest					; if not, branch
		move.b	#1,obBossBall_Side(a0)			; switch side flag
		bra.s	.not_at_highest
; ===========================================================================

	.left_side:
		move.w	obBossBall_Speed(a0),d0
		subq.w	#8,d0
		move.w	d0,obBossBall_Speed(a0)			; decrease swing speed
		add.w	d0,obBossBall_Angle(a0)			; update angle
		move.b	obBossBall_Angle(a0),obAngle(a0)
		cmpi.w	#-$200,d0						; is speed at max?
		bne.s	.not_at_highest					; if not, branch
		clr.b	obBossBall_Side(a0)				; switch side flag

	.not_at_highest:
		move.b	obAngle(a0),d0					; get latest angle
; End of function GBall_Move
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to convert angle to position for all chain links
;
; input:
;	d0 = current swing angle
; ---------------------------------------------------------------------------

BossBall_MoveAll:
		calcsine_direct							; convert d0 to sine

		move.w	obBossBall_BaseY(a0),d2
		move.w	obBossBall_BaseX(a0),d3
		lea		obSubtype(a0),a2				; (a2) = chain length, followed by child OST index list
		moveq	#0,d6
		move.b	(a2)+,d6						; get chain length

	.loop:
		moveq	#0,d4
		move.b	(a2)+,d4						; get child OST index
		lsl.w	#object_size_bits,d4
		addi.l	#v_objspace&$FFFFFF,d4			; convert to RAM address
		movea.l	d4,a1
		moveq	#0,d4
		move.b	obBossBall_Radius(a1),d4		; get distance of object from anchor
		move.l	d4,d5
		muls.w	d0,d4
		asr.l	#8,d4
		muls.w	d1,d5
		asr.l	#8,d5
		add.w	d2,d4
		add.w	d3,d5
		move.w	d4,obY(a1)						; update position
		move.w	d5,obX(a1)
		dbf		d6,.loop						; repeat for all chainlinks and platform

		rts	
; End of function BossBall_MoveAll
; ===========================================================================