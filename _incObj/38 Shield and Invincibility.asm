; ---------------------------------------------------------------------------
; Object 38 - shields
; ---------------------------------------------------------------------------

; w/ DPLCs and dynamic pointers -- RetroKoH VRAM Overhaul
obArtLoc	equ	$38
obDPLCLoc	equ	$3C

ShieldItem:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Shi_Index(pc,d0.w),d1
		jmp		Shi_Index(pc,d1.w)
; ===========================================================================
Shi_Index:
		dc.w	Shi_Main-Shi_Index
		dc.w	Shi_Shield-Shi_Index
		dc.w	Shi_Stars-Shi_Index ; Make its own object?
	; Added (Lookup table should follow this order)
		dc.w	Shi_Flame-Shi_Index
		dc.w	Shi_Bubble-Shi_Index
		dc.w	Shi_Lightning-Shi_Index
		dc.w	Shi_Insta-Shi_Index
		dc.w	Shi_LightningSpark-Shi_Index
		dc.w	Shi_LightningDestroy-Shi_Index
; ===========================================================================

Shi_Main:	; Routine 0
		move.b	#4,obRender(a0)
		move.w	#$80,obPriority(a0)	; RetroKoH S2 Priority Manager
		move.b	#$10,obActWid(a0)
		move.w	#make_art_tile(ArtTile_Shield,0,0),obGfx(a0)
	; RetroKoH Shield Optimization
		moveq	#0,d0
		move.b	obSubtype(a0),d0
		lsl.b	#1,d0
		move.b	d0,obRoutine(a0)
		addq.b	#2,obRoutine(a0)	; set next routine
		lsl.b	#3,d0
		lea     ShieldVars,a1		; Load lookup table into a1
		adda.w	d0,a1				; get corresponding shield data
		move.l	(a1)+,d0			; load the first longword, but we'll only use the lowest byte
		move.b	d0,obAnim(a0)		; load correct animation
		move.l	(a1)+,obMap(a0)		; load correct mappings
		move.l	(a1)+,obArtLoc(a0)	; load correct art location (for DPLCs)
		move.l	(a1)+,obDPLCLoc(a0)	; load correct DPLC location

		cmpi.b	#8,obRoutine(a0)	; bubble shield check
		bne.s	.notBubble
		bra.w	ResumeMusic

.notBubble:
;		cmpi.b	#$A,obRoutine(a0)	; lightning shield check
;		bne.s	.notBubble
;		move.l	#Art_Shield_L2,d1		; Load art for sparks
;		move.w	#$ACA0,d2				; load it just after the lightning shield art
;		move.w	#$50,d3
;		jsr		(QueueDMATransfer).l
.notLightning:
		rts
	; Shield Optimization End
; ===========================================================================

Shi_Shield:	; Routine 2
		btst	#sta2ndInvinc,(v_player+obStatus2nd).w	; does Sonic have invincibility?
		bne.s	.remove									; if yes, branch
		btst	#sta2ndShield,(v_player+obStatus2nd).w	; does Sonic have shield?
		beq.s	.delete									; if not, branch
		move.w	(v_player+obX).w,obX(a0)
		move.w	(v_player+obY).w,obY(a0)
		move.b	(v_player+obStatus).w,obStatus(a0)

	; Mercury Shield/Invincibility Positioning Fix
		move.b	obStatus(a0),d0
		move.w	#$A,d1
		cmpi.b	#aniID_Balance,(v_player+obAnim).w
		bne.s	.noshift
		
.shift:
		sub.w	d1,obX(a0)
		btst	#staFlipX,d0	; X-Flip sprite bit
		beq.s	.noshift
		add.w	d1,d1
		add.w	d1,obX(a0)
.noshift:
	; Shield/Invincibility Positioning Fix End

		lea		(Ani_Shield).l,a1
		jsr		(AnimateSprite).l
		bsr.w	Shield_LoadGfx		; RetroKoH VRAM Overhaul
		jmp		(DisplaySprite).l

.remove:
		rts	

; Commented out code is useful for hacks w/ additional characters.
.delete:
;		tst.b	(v_player+obCharID).w	; You would need to add obCharID to player SST to use this.
;		bne.s	.notSonic
		clr.b	obRoutine(a0)
		move.b	#5,obSubtype(a0)			; Replace shield with instashield
		rts

;.notSonic:
; Normal .delete (without instashield) jumps straight to this line.
		jmp		(DeleteObject).l
; ===========================================================================

Shi_Stars:	; Routine 4
		btst	#sta2ndInvinc,(v_player+obStatus2nd).w	; does Sonic have invincibility?
		beq.w	Shi_Start_Delete						; if not, branch
		move.w	(v_trackpos).w,d0						; get index value for tracking data
		move.b	obAnim(a0),d1
		subq.b	#1,d1

;.trail:
		lsl.b	#3,d1		; multiply animation number by 8
		move.b	d1,d2
		add.b	d1,d1
		add.b	d2,d1		; multiply by 3
		addq.b	#4,d1
		sub.b	d1,d0
		move.b	objoff_30(a0),d1
		sub.b	d1,d0		; use earlier tracking data to create trail
		addq.b	#4,d1
		cmpi.b	#$18,d1
		blo.s	.a
		moveq	#0,d1

.a:
		move.b	d1,objoff_30(a0)

.b:
		lea		(v_tracksonic).w,a1
		lea		(a1,d0.w),a1
		move.w	(a1)+,obX(a0)
		move.w	(a1)+,obY(a0)
		move.b	(v_player+obStatus).w,obStatus(a0)

	; Mercury Shield/Invincibility Positioning Fix
		move.b	obStatus(a0),d0
		move.w	#$A,d1
		cmpi.b	#aniID_Balance,(v_player+obAnim).w
		bne.s	.noshift
		
.shift:
		sub.w	d1,obX(a0)
		btst	#staFlipX,d0		; X-Flip sprite bit
		beq.s	.noshift
		add.w	d1,d1
		add.w	d1,obX(a0)
.noshift:
	; Shield/Invincibility Positioning Fix End

		lea		(Ani_Shield).l,a1
		jsr		(AnimateSprite).l
		bsr.w	Stars_LoadGfx		; RetroKoH VRAM Overhaul
		jmp		(DisplaySprite).l
; ===========================================================================

Shi_Start_Delete:	; ensure that this doesn't delete instashield.	
		jmp		(DeleteObject).l
; ===========================================================================

Shi_Flame:	; Routine 6
		btst	#sta2ndInvinc,(v_player+obStatus2nd).w	; does Sonic have invincibility?
		bne.s	.remove									; if yes, branch
;		cmpi.b	#$1C,(v_player+obAnim).w			; Which animation is this???
;		beq.s	.remove
		btst	#sta2ndShield,(v_player+obStatus2nd).w	; does Sonic have shield?
		beq.s	.delete									; if not, branch
		btst	#staWater,(v_player+obStatus).w			; is Sonic underwater?
		bne.s	.delete									; if yes, branch, and destroy the shield
		move.w	(v_player+obX).w,obX(a0)
		move.w	(v_player+obY).w,obY(a0)
		cmpi.b	#6,obAnim(a0)							; is Sonic using the Dash ability?
		beq.s	.noshift								; if yes, branch (avoid flipping the sprite mid-dash)
		move.b	(v_player+obStatus).w,obStatus(a0)
		andi.b	#maskFlipX,obStatus(a0)					; Copy first bit, so the Shield is always facing in the same direction as the player.

.noshift:
		lea		(Ani_Shield).l,a1
		jsr		(AnimateSprite).l
		move.w	#$80,obPriority(a0)
		cmpi.b	#$F,obFrame(a0)
		bcs.s	.display
		move.w	#$200,obPriority(a0)

.display:
		bsr.w	Shield_LoadGfx
		jmp		(DisplaySprite).l

.dissipate: ; SPECIAL EFFECT FOR UNDERWATER (To be added later)
.delete:
		andi.b	#mask2ndRmvShield,(v_player+obStatus2nd).w
;		tst.b	(v_player+obCharID).w
;		bne.s	.notSonic
		clr.b	obRoutine(a0)
		move.b	#5,obSubtype(a0)			; Replace shield with instashield

.remove:
		rts

;.notSonic:
;		jmp		(DeleteObject).l
; ===========================================================================

Shi_Bubble:	; Routine 8
		btst	#sta2ndInvinc,(v_player+obStatus2nd).w	; does Sonic have invincibility?
		bne.s	.remove									; if yes, branch
;		cmpi.b	#$1C,(v_player+obAnim).w			; Which animation is this???
;		beq.s	.remove
		btst	#sta2ndShield,(v_player+obStatus2nd).w	; does Sonic have shield?
		beq.s	.delete									; if not, branch
		move.w	(v_player+obX).w,obX(a0)
		move.w	(v_player+obY).w,obY(a0)
		move.b	(v_player+obStatus).w,obStatus(a0)
		andi.b	#maskFlipX,obStatus(a0)		; Copy first bit, so the Shield is always facing in the same direction as the player.

		lea		(Ani_Shield).l,a1
		jsr		(AnimateSprite).l
		move.w	#$80,obPriority(a0)
		cmpi.b	#$F,obFrame(a0)
		bcs.s	.display
		move.w	#$200,obPriority(a0)

.display:
		bsr.w	Shield_LoadGfx
		jmp		(DisplaySprite).l

.delete:
		andi.b	#mask2ndRmvShield,(v_player+obStatus2nd).w
;		tst.b	(v_player+obCharID).w
;		bne.s	.notSonic
		clr.b	obRoutine(a0)
		move.b	#5,obSubtype(a0)			; Replace shield with instashield

.remove:
		rts

;.notSonic:
;		jmp		(DeleteObject).l
; ===========================================================================

Shi_Lightning:	; Routine 8
		btst	#sta2ndInvinc,(v_player+obStatus2nd).w	; does Sonic have invincibility?
		bne.s	.remove									; if yes, branch
;		cmpi.b	#$1C,(v_player+obAnim).w			; Which animation is this???
;		beq.s	.remove
		btst	#sta2ndShield,(v_player+obStatus2nd).w	; does Sonic have shield?
		beq.s	.delete									; if not, branch
		btst	#staWater,(v_player+obStatus).w			; is Sonic underwater?
		bne.s	.checkflash								; if yes, branch, and destroy the shield
		move.w	(v_player+obX).w,obX(a0)
		move.w	(v_player+obY).w,obY(a0)
		move.b	(v_player+obStatus).w,obStatus(a0)
		andi.b	#maskFlipX,obStatus(a0)		; Copy first bit, so the Shield is always facing in the same direction as the player.

		lea		(Ani_Shield).l,a1
		jsr		(AnimateSprite).l
		move.w	#$80,obPriority(a0)
		cmpi.b	#$F,obFrame(a0)
		bcs.s	.display
		move.w	#$200,obPriority(a0)

.display:
		bsr.w	Shield_LoadGfx
		jmp		(DisplaySprite).l

.checkflash: ; SPECIAL EFFECT FOR UNDERWATER (To be added later)
		;tst.w	(v_pcyc_time).w
		;bra.s	Lightning_FlashWater

.delete:
		andi.b	#mask2ndRmvShield,(v_player+obStatus2nd).w
;		tst.b	(v_player+obCharID).w
;		bne.s	.notSonic
		clr.b	obRoutine(a0)
		move.b	#5,obSubtype(a0)			; Replace shield with instashield

.remove:
		rts

;.notSonic:
;		jmp		(DeleteObject).l
; ===========================================================================

Lightning_CreateSpark:
;		moveq	#$C,d2
;		lea		(v_sparkspace).w,a1
;		lea		(SparkVelocities).l,a2
;		moveq	#3,d1

;.loop:
;		move.b	#id_ShieldItem,obID(a1)
;		move.b	#$E,routine(a1)
;		move.w	obX(a0),obX(a1)
;		move.w	obY(a0),obY(a1)
;		move.l	obMap(a0),obMap(a1)
;		move.w	obGfx(a0),obGfx(a1)
;		move.b	#4,obRender(a1)
;		move.w	#$80,obPriority(a1)
;		move.b	#8,obActWid(a1)
;		move.b	d2,obAnim(a1)
;		move.w	(a2)+,obVelX(a1)
;		move.w	(a2)+,obVelY(a1)
;		lea		object_size(a1),a1
;		dbf		d1,.loop

;.end:
		rts
; End of function Lightning_CreateSpark
; ===========================================================================

Shi_Insta:	; Routine $C
		btst	#sta2ndInvinc,(v_player+obStatus2nd).w	; does Sonic have invincibility?
		bne.s	.remove									; if yes, branch
		move.w	(v_player+obX).w,obX(a0)
		move.w	(v_player+obY).w,obY(a0)
		move.b	(v_player+obStatus).w,obStatus(a0)
		andi.b	#maskFlipX,obStatus(a0)					; Copy first bit, so the Shield is always facing in the same direction as the player.
		lea		(Ani_Shield).l,a1
		jsr		(AnimateSprite).l
		cmpi.b	#7,obFrame(a0)
		bne.s	.chkframe
		tst.b	(v_player+obDoubleJumpFlag).w
		beq.s	.chkframe
		move.b	#2,(v_player+obDoubleJumpFlag).w		; Advance flag (We can now rev the Drop Dash)

.chkframe:
		tst.b	obFrame(a0)
		beq.s	.loaddplc
		cmpi.b	#3,obFrame(a0)
		bne.s	.display

.loaddplc:
		bsr.w	Shield_LoadGfx
.display:
		jmp		(DisplaySprite).l
.remove:
		rts
; ===========================================================================

Shi_LightningSpark: ; Routine $E
		jsr		(SpeedToPos).l
		addi.w	#$18,obVelY(a0)
		lea		(Ani_Shield).l,a1
		jsr		(AnimateSprite).l
		cmpi.b	#$E,obRoutine(a0)
		bne.s	.delete
		jmp		(DisplaySprite).l

.delete:
		jmp		(DeleteObject).l
; ===========================================================================

Shi_LightningDestroy: ; Routine $10
		subq.b	#1,obTimeFrame(a0)
		bpl.s	.return
;		tst.b	(v_player+obCharID).w
;		bne.s	.notSonic
		clr.b	obRoutine(a0)
		move.b	#5,obSubtype(a0)			; Replace shield with instashield
;		bra.s	.continue

;.notSonic:
;		jsr		(DeleteObject).l

.continue:
		lea		(v_pal_water_dup).w,a1
		lea		(v_pal_water).w,a2
		move.w	#$1F,d0

.loop:
		move.l	(a1)+,(a2)+
		dbf		d0,.loop

.return:
		rts
; ===========================================================================

; ---------------------------------------------------------------------------
; Shield and Stars dynamic pattern loading subroutine
; RetroKoH VRAM Overhaul
; ---------------------------------------------------------------------------

Stars_LoadGfx:
		moveq	#0,d0
		move.b	(v_starsobj1+obFrame).w,d0	; load frame number
		bra.s   ShieldPLC_Cont

Shield_LoadGfx:
		moveq	#0,d0
		move.b	(v_shieldobj+obFrame).w,d0	; load frame number

ShieldPLC_Cont:
		movea.l	obDPLCLoc(a0),a2
		add.w	d0,d0
		adda.w	(a2,d0.w),a2
		moveq	#0,d5
		move.b	(a2)+,d5					; read "number of entries" value
		subq.w	#1,d5
		bmi.s	ShieldDPLC_Return			; if zero, branch
		move.w	#(ArtTile_Shield*$20),d4

ShieldPLC_ReadEntry:
		moveq	#0,d1
		move.b	(a2)+,d1
		lsl.w	#8,d1
		move.b	(a2)+,d1
		move.w	d1,d3
		lsr.w	#8,d3
		andi.w	#$F0,d3
		addi.w	#$10,d3
		andi.w	#$FFF,d1
		lsl.l	#5,d1
		add.l	obArtLoc(a0),d1
		move.w	d4,d2
		add.w	d3,d4
		add.w	d3,d4
		jsr		(QueueDMATransfer).l
		dbf		d5,ShieldPLC_ReadEntry		; repeat for number of entries

ShieldDPLC_Return:
		rts
; ===========================================================================
; Shield variables
; ===========================================================================
ShieldVars:
				; anim	; map			; artLoc		; dplcLoc
		dc.l	0,		Map_Shield,			Art_Shield,		ShieldDynPLC		; 0 - Blue Shield
		dc.l	1,		Map_Shield,			Art_Shield,		ShieldDynPLC		; $10 - Stars - Make its own object?
		dc.l	5,		Map_FlameShield,	Art_Shield_F,	DPLC_FlameShield	; $20 - Flame
		dc.l	7,		Map_BubbleShield,	Art_Shield_B,	DPLC_BubbleShield	; $30 - Bubble
		dc.l	$A,		Map_LightningShield,Art_Shield_L,	DPLC_LightningShield; $40 - Lightning
		dc.l	$D,		Map_InstaShield,	Art_Insta,		DPLC_InstaShield	; $50 - InstaShield
; ===========================================================================