; ---------------------------------------------------------------------------
; Subroutine to	smash a	block (GHZ/SLZ walls [Obj3C] and MZ blocks [Obj51])
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


SmashObject:
		moveq	#0,d0
		move.b	obFrame(a0),d0
		add.w	d0,d0
		movea.l	obMap(a0),a3
		adda.w	(a3,d0.w),a3
	; S2 BuildSprites
; This is actually where we set the number of fragments to be created.
; The original game set it in the object code itself.
		move.w	(a3)+,d1						; amount of pieces the frame consists of
		subq.w	#2,d1							; set iterator based on piece count, and decrement for the first part created
	; S2 BuildSprites End
		bset	#5,obRender(a0)
		_move.b	obID(a0),d4
		move.b	obRender(a0),d5

	; RetroKoH Optimization; Built off of Spirituinsanum's Mass Object Load Optimization
	; Init the first ring right away (which is already created)
		move.b	#4,obRoutine(a0)
		move.l	a3,obMap(a0)
		move.l	(a4)+,obVelX(a0)				; move the data contained in the array to obVelX and obVelY, and increment the address in a4

	; Here we begin what's replacing FindFreeObj/SingleObjLoad,
		moveq	#0,d3
		lea		(v_lvlobjspace).w,a1
		move.w	#v_lvlobjcount,d3

.loop:
	; REMOVE FindFreeObj. It's the routine that causes such slowdown
		tst.b	obID(a1)						; is object RAM	slot empty?
		beq.s	.loadfrag						; Let's correct the branches. Here we can also skip the bne that was originally after bsr.w FindFreeObj because we already know there's a free object slot in memory.
		lea		object_size(a1),a1
		dbf		d3,.loop						; Branch correction again.
		bne.s	.playsnd						; We're moving this line here.

.loadfrag:
		move.b	#4,obRoutine(a1)
		_move.b	d4,obID(a1)
		addq.w	#8,a3							; S2 BuildSprites Change: 5 > 8
		move.l	a3,obMap(a1)
		move.b	d5,obRender(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.w	obGfx(a0),obGfx(a1)
		move.w	obPriority(a0),obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	obActWid(a0),obActWid(a1)
		move.l	(a4)+,obVelX(a1)				; move the data contained in the array to obVelX and obVelY, and increment the address in a4
		cmpa.l	a0,a1							; has this fragment's RAM space already been passed over by the Object Manager?
		bhs.s	.loc_D268						; if not, branch.

	; We run this to ensure that all fragments move at the same rate
		move.l	a0,-(sp)
		movea.l	a1,a0
		bsr.w	SpeedToPos
		add.w	d2,obVelY(a0)
		movea.l	(sp)+,a0
		bsr.w	DisplaySprite1

.loc_D268:
		dbf		d1,.loop

.playsnd:
		move.w	#sfx_WallSmash,d0
		jmp		(PlaySound_Special).w ; play smashing sound

; End of function SmashObject