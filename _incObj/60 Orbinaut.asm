; ---------------------------------------------------------------------------
; Object 60 - Orbinaut enemy (LZ, SLZ, SBZ)
; ---------------------------------------------------------------------------

Orbinaut:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Orb_Index(pc,d0.w),d1
		jmp		Orb_Index(pc,d1.w)
; ===========================================================================
Orb_Index:	offsetTable
		offsetTableEntry.w Orb_Main
		offsetTableEntry.w Orb_ChkSonic
		offsetTableEntry.w Orb_MoveHead
		offsetTableEntry.w Orb_MoveOrb
		offsetTableEntry.w Orb_FireOrb

	if SLZOrbinautBehaviourMod	; Mercury SLZ Orbinaut Behaviour Mod
		offsetTableEntry.w Orb_Pause
		offsetTableEntry.w Orb_MoveOut
	endif	; SLZ Orbinaut Behaviour Mod End
; ===========================================================================

Orb_Main:	; Routine 0
		move.l	#Map_Orb,obMap(a0)
		move.w	#make_art_tile(ArtTile_Orbinaut,0,0),obGfx(a0)	; RetroKoH VRAM Overhaul
		cmpi.b	#id_SLZ,(v_zone).w								; check if level is SLZ
		bne.s	.notSLZ
		bset	#gfxPalLower,obGfx(a0)							; Set to the next palette line -- RetroKoH VRAM Overhaul

	.notSLZ:
	if SLZOrbinautBehaviourMod	; Mercury SLZ Orbinaut Behaviour Mod
		move.b	#4,obOrb_OrbDist(a0)
	endif	; SLZ Orbinaut Behaviour Mod

		ori.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#(colEnemy|colSz_8x8),obColType(a0)
		move.b	#$C,obDispWid(a0)
		moveq	#0,d2
		lea		obOrb_ObjCount(a0),a2
		movea.l	a2,a3						; (a3) = number of orbs
		addq.w	#1,a2						; a2 = address of list of orbs' object RAM indices
		moveq	#3,d1						; create 4 spiked orbs

	; RetroKoH Object Load Optimization -- Based on Spirituinsanum Guides
	; Here we begin what's replacing FindNextFreeObj. It'll be quicker to loop through here.
		movea.l	a0,a1
		move.w	#v_lvlobjend&$FFFF,d0
		sub.w	a0,d0
		lsr.w	#6,d0
		subq.w	#1,d0
		bcs.s	.fail

	.loop:
		tst.l	obAddr(a1)					; is object RAM	slot empty?
		beq.s	.makesatellites				; if so, create object piece
		lea		object_size(a1),a1
		dbf		d0,.loop					; loop through object RAM
		bne.s	.fail						; We're moving this line here.

	.makesatellites:
		addq.b	#1,(a3)
		move.w	a1,d5
		subi.w	#v_objspace&$FFFF,d5
		lsr.w	#object_size_bits,d5
		andi.w	#$7F,d5						; convert OST RAM address to id
		move.b	d5,(a2)+					; add to list
		_move.l	obAddr(a0),obAddr(a1)		; load spiked orb object
		move.b	#6,obRoutine(a1)			; use Orb_MoveOrb routine
		move.l	obMap(a0),obMap(a1)
		move.w	obGfx(a0),obGfx(a1)
		ori.b	#4,obRender(a1)
		move.w	#priority4,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#8,obDispWid(a1)
		move.b	#3,obFrame(a1)
		move.b	#(colHarmful|colSz_4x4),obColType(a1)
		move.b	d2,obAngle(a1)				; set position around orbinaut
		addi.b	#$40,d2						; next orb is a quarter circle ahead
		move.w	a0,obOrb_Parent(a1)
		dbf		d1,.loop					; repeat sequence 3 more times

	.fail:
		moveq	#1,d0

	if SLZOrbinautBehaviourMod	;Mercury SLZ Orbinaut Behaviour Mod
		cmpi.b	#2,obSubtype(a0)
		bne.s	.add
		neg.w	d0
	.add:
	endif	;end SLZ Orbinaut Behaviour Mod

		btst	#staFlipX,obStatus(a0)		; is orbinaut facing left?
		beq.s	.noflip						; if not, branch
		neg.w	d0

	.noflip:
		move.b	d0,obOrb_Direction(a0)

	if ~~SLZOrbinautBehaviourMod	;Mercury SLZ Orbinaut Behaviour Mod
		move.b	obSubtype(a0),obRoutine(a0)	; if type is 02, skip Orb_ChkSonic
	endif	;end SLZ Orbinaut Behaviour Mod

		addq.b	#2,obRoutine(a0)			; goto Orb_ChkSonic (type 0) or Orb_MoveHead (type 2) next
		move.w	#-$40,obVelX(a0)			; move orbinaut to the left
		btst	#staFlipX,obStatus(a0)		; is orbinaut facing left??
		beq.s	.noflip2					; if not, branch
		neg.w	obVelX(a0)					; move orbinaut	to the right

	.noflip2:
		rts	
; ===========================================================================

Orb_ChkSonic:	; Routine 2
		move.w	(v_player+obX).w,d0
		sub.w	obX(a0),d0					; is Sonic to the right of the orbinaut?
		bcc.s	.isright					; if yes, branch
		neg.w	d0

	.isright:
	if OrbinautAnimationTweak	; Mercury Orbinaut Animation Tweak
		cmpi.w	#OrbinautAnimationTweakRange,d0
	else
		cmpi.w	#160,d0						; is Sonic within 160 pixels of orbinaut?
	endif	; Orbinaut Animation Tweak End

		bhs.s	.animate					; if not, branch
		move.w	(v_player+obY).w,d0
		sub.w	obY(a0),d0					; is Sonic above the orbinaut?
		bcc.s	.isabove					; if yes, branch
		neg.w	d0							; d0 = y dist between Sonic and orbinaut

	.isabove:
		cmpi.w	#$50,d0						; is Sonic within $50 pixels of	orbinaut?
		bhs.s	.animate					; if not, branch
		tst.w	(v_debuguse).w				; is debug mode	on?
		bne.s	.animate					; if yes, branch
		moveq	#1,d0						; use "angry" animation
		jsr		(NewAnim).w

	.animate:
		lea		Ani_Orb(pc),a1
		jsr		(AnimateSprite).w
		bra.w	Orb_ChkDel
; ===========================================================================

;Orb_Display:
Orb_MoveHead:	; Routine 4
		bsr.w	SpeedToPos_XOnly

Orb_ChkDel:
		out_of_range.w	.chkgone
		bra.w	DisplayAndCollision			; S3K TouchResponse

	.chkgone:
		move.w	obRespawnAddr(a0),d0		; get address in respawn table
		beq.s	.no_respawn_id				; if it's zero, don't remember object
		movea.w	d0,a2						; load address into a2
		bclr	#7,(a2)						; clear respawn table entry, so object can be loaded again

	.no_respawn_id:
		lea		obOrb_ObjCount(a0),a2
		moveq	#0,d2
		move.b	(a2)+,d2					; d2 = number of child objects
		subq.w	#1,d2						; decrement loop counter
		bcs.w	DeleteObject

	.del_loop:
		moveq	#0,d0
		move.b	(a2)+,d0					; get OST index for child
		lsl.w	#object_size_bits,d0
		addi.l	#v_objspace&$FFFFFF,d0		; convert to RAM address
		movea.l	d0,a1
		bsr.w	DeleteChild					; delete child object
		dbf		d2,.del_loop				; repeat for all children

		bra.w	DeleteObject
; ===========================================================================

Orb_MoveOrb:	; Routine 6
		movea.w	obOrb_Parent(a0),a1
		; does parent object still exist? (d1 = obAddr)?
		cmp_addr	#Orbinaut,obAddr(a1),d1
		bne.w	DeleteObject				; if not, delete
		cmpi.b	#2,obFrame(a1)				; is orbinaut angry?
		bne.w	.circle						; if not, branch

	if SLZOrbinautBehaviourMod	; Mercury SLZ Orbinaut Behaviour Mod
		cmpi.b	#2,obSubtype(a1)
		beq.s	.fire2
	endif	; end SLZ Orbinaut Behaviour Mod

		cmpi.b	#$40,obAngle(a0)		; is spikeorb directly under the orbinaut?
		bne.s	.circle					; if not, branch
		addq.b	#2,obRoutine(a0)		; -> Orb_FireOrb
		subq.b	#1,obOrb_ObjCount(a1)	; decrement orb count
		bne.s	.fire					; branch if not 0
		addq.b	#2,obRoutine(a1)		; if all orbs have been thrown, goto Orb_MoveHead next

	.fire:
		move.w	#-$200,obVelX(a0)		; move orb to the left (quickly)
		btst	#staFlipX,obStatus(a1)
		beq.s	.noflip
		neg.w	obVelX(a0)

	if SLZOrbinautBehaviourMod	; Mercury SLZ Orbinaut Behaviour Mod
		bra.s	.noflip

	.fire2:
		cmpi.b	#3,obOrb_OrbDist(a1)	; is the orb distance high enough?
		beq.s	.circle					; if so, branch to the code that makes them circle
		move.b	#12,obRoutine(a0)		; change orb to the routine that moves it outward
		move.b	#30,obOrb_OrbTimer(a0)	; set the orb timer to 30 steps
		subq.b	#1,obOrb_ObjCount(a1)	; decrease the number of orbs left to be fired off
		bne.s	.skip					; if there are still orbs, branch
		move.b	#10,obRoutine(a1)		; change to the routine that pauses movement
		move.b	#3,obOrb_OrbDist(a1)	; set orb distance
		move.b	obOrb_Direction(a1),d0	; double orbit speed
		asl.b	#1,d0
		move.b	d0,obOrb_Direction(a1)
		move.b	#30,obOrb_OrbTimer(a1)	; set a timer to 30 steps
	
	.skip:
		move.w	obX(a0),d2				; set the velocity of the orb based on its position
		sub.w	obX(a1),d2				; relative to the Orbinaut
		asl.w	#3,d2
		move.w	d2,obVelX(a0)
		move.w	obY(a0),d2
		sub.w	obY(a1),d2
		asl.w	#3,d2
		move.w	d2,obVelY(a0)
	endif	; end SLZ Orbinaut Behaviour Mod

	.noflip:
		bra.w	DisplayAndCollision		; S3K TouchResponse
; ===========================================================================

	.circle:
	if SLZOrbinautBehaviourMod	; Mercury SLZ Orbinaut Behaviour Mod
		move.b	obOrb_OrbDist(a1),d2	; put orb distance into d2
	endif	; end SLZ Orbinaut Behaviour Mod

		move.b	obAngle(a0),d0			; get angle
		calcsine_direct					; convert to sine/cosine

	if SLZOrbinautBehaviourMod	; Mercury SLZ Orbinaut Behaviour Mod
		asr.w	d2,d1
	else
		asr.w	#4,d1
	endif	; end SLZ Orbinaut Behaviour Mod

		add.w	obX(a1),d1
		move.w	d1,obX(a0)

	if SLZOrbinautBehaviourMod	; Mercury SLZ Orbinaut Behaviour Mod
		asr.w	d2,d0
	else
		asr.w	#4,d0
	endif	; end SLZ Orbinaut Behaviour Mod

		add.w	obY(a1),d0
		move.w	d0,obY(a0)
		move.b	obOrb_Direction(a1),d0	; get direction (1 or -1)
		add.b	d0,obAngle(a0)			; add to angle
		bra.w	DisplayAndCollision		; S3K TouchResponse
; ===========================================================================

	if SLZOrbinautBehaviourMod	;Mercury SLZ Orbinaut Behaviour Mod
Orb_Pause:	; Routine 10
		subq.b	#1,obOrb_OrbTimer(a0)	; decrease timer
		bne.s	Orb_ChkDel2Skip			; if it hasn't run out, branch
		move.b	#4,obRoutine(a0)		; go back to the normal routine
		bra.s	Orb_ChkDel2Skip

Orb_MoveOut:	; Routine 12
		subq.b	#1,obOrb_OrbTimer(a0)	; decrease timer
		bne.s	Orb_FireOrb				; if it hasn't run out, branch
		move.b	#6,obRoutine(a0)		; go back to the normal routine
	endif	;end SLZ Orbinaut Behaviour Mod

;Orb_ChkDel2:	; Routine 8
Orb_FireOrb:
		bsr.w	SpeedToPos
		
	if SLZOrbinautBehaviourMod	; Mercury SLZ Orbinaut Behaviour Mod
Orb_ChkDel2Skip:
	endif	;end SLZ Orbinaut Behaviour Mod

		tst.b	obRender(a0)		; is orb on-screen?
		bpl.w	DeleteObject		; if not, branch
		bra.w	DisplayAndCollision	; S3K TouchResponse
; ===========================================================================