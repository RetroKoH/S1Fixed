; ---------------------------------------------------------------------------
; Object 43 - Roller enemy (SYZ)
; ---------------------------------------------------------------------------

Roller:
	; LavaGaming Object Routine Optimization
		tst.b	obRoutine(a0)
		bne.s	Roll_Action
	; Object Routine Optimization End

Roll_Main:	; Routine 0
		move.b	#$E,obHeight(a0)
		move.b	#8,obWidth(a0)
		bsr.w	ObjectFall
		jsr		(ObjFloorDist).l
		tst.w	d1
		bpl.s	locret_E052
		add.w	d1,obY(a0)	; match	roller's position with the floor
		clr.w	obVelY(a0)
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Roll,obMap(a0)
		move.w	#make_art_tile(ArtTile_Roller,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#$200,obPriority(a0)	; RetroKoH S2 Priority Manager
		move.b	#$10,obActWid(a0)

locret_E052:
		rts	
; ===========================================================================

Roll_Action:	; Routine 2
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	Roll_Index2(pc,d0.w),d1
		jsr		Roll_Index2(pc,d1.w)
		lea		(Ani_Roll).l,a1
		bsr.w	AnimateSprite
		move.w	obX(a0),d0
		andi.w	#$FF80,d0
		move.w	(v_screenposx).w,d1
		subi.w	#$80,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0
		cmpi.w	#$280,d0
		bgt.w	Roll_ChkGone
		bra.w	DisplaySprite
; ===========================================================================

Roll_ChkGone:
	; ProjectFM S3K Object Manager
		move.w	obRespawnNo(a0),d0		; get address in respawn table
		beq.w	DeleteObject			; if it's zero, don't remember object
		movea.w	d0,a2					; load address into a2
		bclr	#7,(a2)					; clear respawn table entry, so object can be loaded again
	; S3K Object Manager End
		bra.w	DeleteObject
; ===========================================================================
Roll_Index2:
		dc.w Roll_RollChk-Roll_Index2
		dc.w Roll_RollNoChk-Roll_Index2
		dc.w Roll_ChkJump-Roll_Index2
		dc.w Roll_MatchFloor-Roll_Index2
; ===========================================================================

Roll_RollChk:
		move.w	(v_player+obX).w,d0
		subi.w	#$100,d0
		bcs.s	loc_E0D2
		sub.w	obX(a0),d0	; check	distance between Roller	and Sonic
		bcs.s	loc_E0D2
		addq.b	#4,ob2ndRout(a0)
		move.b	#2,obAnim(a0)
		move.w	#$700,obVelX(a0) ; move Roller horizontally
		move.b	#$8E,obColType(a0) ; make Roller invincible

loc_E0D2:
		addq.l	#4,sp
		rts	
; ===========================================================================

Roll_RollNoChk:
		cmpi.b	#2,obAnim(a0)
		beq.s	loc_E0F8
		subq.w	#1,objoff_30(a0)
		bpl.s	locret_E0F6
		move.b	#1,obAnim(a0)
		move.w	#$700,obVelX(a0)
		move.b	#$8E,obColType(a0)

locret_E0F6:
		rts	
; ===========================================================================

loc_E0F8:
		addq.b	#2,ob2ndRout(a0)
		rts	
; ===========================================================================

Roll_ChkJump:
		bsr.w	Roll_Stop
		bsr.w	SpeedToPos
		jsr		(ObjFloorDist).l
		cmpi.w	#-8,d1
		blt.s	Roll_Jump
		cmpi.w	#$C,d1
		bge.s	Roll_Jump
		add.w	d1,obY(a0)
		rts	
; ===========================================================================

Roll_Jump:
		addq.b	#2,ob2ndRout(a0)
		bset	#0,objoff_32(a0)
		beq.s	locret_E12E
		move.w	#-$600,obVelY(a0)	; move Roller vertically

locret_E12E:
		rts	
; ===========================================================================

Roll_MatchFloor:
		bsr.w	ObjectFall
		tst.w	obVelY(a0)
		bmi.s	locret_E150
		jsr		(ObjFloorDist).l
		tst.w	d1
		bpl.s	locret_E150
		add.w	d1,obY(a0)	; match	Roller's position with the floor
		subq.b	#2,ob2ndRout(a0)
		clr.w	obVelY(a0)

locret_E150:
		rts	

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Roll_Stop:
		tst.b	objoff_32(a0)
		bmi.s	locret_E188
		move.w	(v_player+obX).w,d0
		subi.w	#$30,d0
		sub.w	obX(a0),d0
		bcc.s	locret_E188
		clr.b	obAnim(a0)
		move.b	#$E,obColType(a0)
		clr.w	obVelX(a0)
		move.w	#120,objoff_30(a0)	; set waiting time to 2	seconds
		move.b	#2,ob2ndRout(a0)
		bset	#7,objoff_32(a0)

locret_E188:
		rts	
; End of function Roll_Stop
