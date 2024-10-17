; ---------------------------------------------------------------------------
; Object 38 - shields
; Invincibility Stars have been removed and moved to their own object ($4F)
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
Shi_Index:		offsetTable
ptr_Shi_Main:		offsetTableEntry.w	Shi_Main
ptr_Shi_Blue:		offsetTableEntry.w	Shi_Shield

	if InstashieldEnabled
ptr_Shi_Insta:		offsetTableEntry.w	Shi_Insta
	endif

	if ShieldsMode
ptr_Shi_Flame:		offsetTableEntry.w	Shi_Flame
ptr_Shi_Bubble:		offsetTableEntry.w	Shi_Bubble
ptr_Shi_Ltning:		offsetTableEntry.w	Shi_Lightning
ptr_Shi_Dissipate:	offsetTableEntry.w	Shi_FlameDissipate
ptr_Shi_Spark:		offsetTableEntry.w	Shi_LightningSpark
ptr_Shi_FlashOut:	offsetTableEntry.w	Shi_LightningDestroy
	endif

id_Shi_Main = ptr_Shi_Main-Shi_Index
id_Shi_Blue = ptr_Shi_Blue-Shi_Index
	if InstashieldEnabled
id_Shi_Insta = ptr_Shi_Insta-Shi_Index
	endif
	if ShieldsMode
id_Shi_Flame = ptr_Shi_Flame-Shi_Index
id_Shi_Bubble = ptr_Shi_Bubble-Shi_Index
id_Shi_Ltning = ptr_Shi_Ltning-Shi_Index
id_Shi_Dissipate = ptr_Shi_Dissipate-Shi_Index
id_Shi_Spark = ptr_Shi_Spark-Shi_Index
id_Shi_FlashOut = ptr_Shi_FlashOut-Shi_Index
	endif

; Dynamic subtypes based on which mods are enabled.
	if S3KDoubleJump
		if InstashieldEnabled
shTypeInsta		equ 1
shTypeFlame		equ 2
shtypeBubble	equ 3
shTypeLtning	equ 4
		else
shTypeFlame		equ 1
shtypeBubble	equ 2
shTypeLtning	equ 3
		endif
	endif
	
; ===========================================================================

Shi_Main:	; Routine 0
		move.b	#4,obRender(a0)
		move.b	#$10,obActWid(a0)
		move.w	#make_art_tile(ArtTile_Shield,0,0),obGfx(a0)

	if (S3KDoubleJump=0)
		addq.b	#2,obRoutine(a0)
		clr.b	obAnim(a0)					; Blue Shield Animation
		move.l	#Map_Shield,obMap(a0)
		move.l	#Art_Shield,obArtLoc(a0)	; load correct art location (for DPLCs)
		move.l	#ShieldDynPLC,obDPLCLoc(a0)	; load correct DPLC location
		rts
	
	else	; RetroKoH Shield Optimization
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
	
		if ShieldsMode
			cmpi.b	#id_Shi_Bubble,obRoutine(a0)	; bubble shield check
			bne.s	.notBubble
			bra.w	ResumeMusic

	.notBubble:
			cmpi.b	#id_Shi_Ltning,obRoutine(a0)	; lightning shield check
			bne.s	.notLightning
			move.l	#Art_Shield_L2,d1				; Load art for sparks
			move.w	#ArtTile_LShield_Sparks*$20,d2	; load it just after the lightning shield art
			move.w	#$50,d3
			jsr		(QueueDMATransfer).w

	.notLightning:
		endif

		rts
	endif; Shield Optimization End
; ===========================================================================

Shi_Shield:	; Routine 2

	if SuperMod
		btst	#sta2ndSuper,(v_player+obStatus2nd).w	; is Sonic Super?
		bne.s	.remove									; if yes, branch
	endif

		btst	#sta2ndInvinc,(v_player+obStatus2nd).w	; does Sonic have invincibility?
		bne.s	.remove									; if yes, branch
		btst	#sta2ndShield,(v_player+obStatus2nd).w	; does Sonic have a shield?
		beq.s	.delete									; if not, branch
		move.w	(v_player+obX).w,obX(a0)
		move.w	(v_player+obY).w,obY(a0)
		move.b	(v_player+obStatus).w,obStatus(a0)

	; Mercury Shield/Invincibility Positioning Fix
		move.b	obStatus(a0),d0
		move.w	#$A,d1

	if CDBalancing
		cmpi.b	#aniID_Balance2,(v_player+obAnim).w
		beq.s	.shift
		cmpi.b	#aniID_Balance3,(v_player+obAnim).w
		bne.s	.noshift
		bchg	#staFacing,d0
		move.w	#4,d1
	else	
		cmpi.b	#aniID_Balance,(v_player+obAnim).w
		bne.s	.noshift
	endif
		
.shift:
		sub.w	d1,obX(a0)
		btst	#staFlipX,d0	; X-Flip sprite bit
		beq.s	.noshift
		add.w	d1,d1
		add.w	d1,obX(a0)
.noshift:
	; Shield/Invincibility Positioning Fix End

		lea		Ani_Shield(pc),a1
		jsr		(AnimateSprite).w
		bsr.w	Shield_LoadGfx		; RetroKoH VRAM Overhaul
		move.w	#priority1,d0		; RetroKoH/Devon S3K+ Priority Manager
		jmp		(DisplaySprite2).l

.remove:
		rts	

; Commented out code is useful for hacks w/ additional characters.
.delete:
	if InstashieldEnabled
;		tst.b	(v_player+obCharID).w		; You would need to add obCharID to player SST to use this.
;		bne.s	.notSonic
		clr.b	obRoutine(a0)
		move.b	#shTypeInsta,obSubtype(a0)	; Replace shield with instashield
		rts

;.notSonic:
; Normal .delete (without instashield) jumps straight to this line.
	endif
		jmp		(DeleteObject).l			; Delete if instashield isn't enabled
; ===========================================================================
	if InstashieldEnabled
Shi_Insta:	; Routine 4

		if SuperMod
			btst	#sta2ndSuper,(v_player+obStatus2nd).w	; is Sonic Super?
			bne.s	.remove									; if yes, branch
		endif

		btst	#sta2ndInvinc,(v_player+obStatus2nd).w	; does Sonic have invincibility?
		bne.s	.remove									; if yes, branch
		move.w	(v_player+obX).w,obX(a0)
		move.w	(v_player+obY).w,obY(a0)
		move.b	(v_player+obStatus).w,obStatus(a0)
		andi.b	#maskFlipX,obStatus(a0)					; Copy first bit, so the Shield is always facing in the same direction as the player.
		lea		Ani_Shield(pc),a1
		jsr		(AnimateSprite).w
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
		move.w	#priority1,d0		; RetroKoH/Devon S3K+ Priority Manager
		jmp		(DisplaySprite2).l

.remove:
		rts
; ===========================================================================
	endif
	
	if ShieldsMode
Shi_Flame:	; Routine 6

		if SuperMod
			btst	#sta2ndSuper,(v_player+obStatus2nd).w	; is Sonic Super?
			bne.w	.remove									; if yes, branch
		endif

		btst	#sta2ndInvinc,(v_player+obStatus2nd).w	; does Sonic have invincibility?
		bne.w	.remove									; if yes, branch
		btst	#sta2ndShield,(v_player+obStatus2nd).w	; does Sonic have a shield?
		beq.w	.delete									; if not, branch
		btst	#staWater,(v_player+obStatus).w			; is Sonic underwater?
		bne.s	.dissipate								; if yes, branch, and destroy the shield
		move.w	(v_player+obX).w,obX(a0)
		move.w	(v_player+obY).w,obY(a0)
		cmpi.b	#aniID_FlameDash,obAnim(a0)				; is Sonic using the Dash ability?
		beq.s	.noshift								; if yes, branch (avoid flipping the sprite mid-dash)
		move.b	(v_player+obStatus).w,obStatus(a0)
		andi.b	#maskFlipX,obStatus(a0)					; Copy first bit, so the Shield is always facing in the same direction as the player.

	; Mercury Shield/Invincibility Positioning Fix
		move.b	obStatus(a0),d0
		move.w	#$A,d1

	if CDBalancing
		cmpi.b	#aniID_Balance2,(v_player+obAnim).w
		beq.s	.shift
		cmpi.b	#aniID_Balance3,(v_player+obAnim).w
		bne.s	.noshift
		bchg	#staFacing,d0
		move.w	#4,d1
	else	
		cmpi.b	#aniID_Balance,(v_player+obAnim).w
		bne.s	.noshift
	endif
	
.shift:
		sub.w	d1,obX(a0)
		btst	#staFlipX,d0	; X-Flip sprite bit
		beq.s	.noshift
		add.w	d1,d1
		add.w	d1,obX(a0)
.noshift:
	; Shield/Invincibility Positioning Fix End

		lea		Ani_Shield(pc),a1
		jsr		(AnimateSprite).w
		bsr.w	Shield_LoadGfx

		move.w	#priority1,d0		; RetroKoH/Devon S3K+ Priority Manager
		cmpi.b	#$F,obFrame(a0)
		bcs.s	.display
		move.w	#priority4,d0		; RetroKoH/Devon S3K+ Priority Manager

.display:
		jmp		(DisplaySprite2).l

.remove:
		rts

.dissipate: ; SPECIAL EFFECT FOR UNDERWATER
		bsr.s	Flame_Dissipate

; Commented out code is useful for hacks w/ additional characters.
.delete:
		andi.b	#mask2ndRmvShield,(v_player+obStatus2nd).w
	if InstashieldEnabled
;		tst.b	(v_player+obCharID).w		; You would need to add obCharID to player SST to use this.
;		bne.s	.notSonic
		clr.b	obRoutine(a0)
		move.b	#shTypeInsta,obSubtype(a0)	; Replace shield with instashield
		rts

;.notSonic:
; Normal .delete (without instashield) jumps straight to this line.
	endif
		jmp		(DeleteObject).l			; Delete if instashield isn't enabled
; ===========================================================================

Flame_Dissipate:
		lea		(v_sparksobj).w,a1
		move.b	#id_ShieldItem,obID(a1)
		move.b	#id_Shi_Dissipate,obRoutine(a1)		; Flame_Dissipate routine
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.l	#Map_ExplodeItem,obMap(a1)
		move.w	#make_art_tile(ArtTile_Explosion,0,0),obGfx(a1)
		move.b	#4,obRender(a1)
		move.b	#$C,obActWid(a1)
		move.b	#3,obTimeFrame(a1)
		move.b	#1,obFrame(a1)
		rts
; ===========================================================================

Shi_Bubble:	; Routine 8

		if SuperMod
			btst	#sta2ndSuper,(v_player+obStatus2nd).w	; is Sonic Super?
			bne.w	.remove									; if yes, branch
		endif

		btst	#sta2ndInvinc,(v_player+obStatus2nd).w	; does Sonic have invincibility?
		bne.w	.remove									; if yes, branch
		btst	#sta2ndShield,(v_player+obStatus2nd).w	; does Sonic have shield?
		beq.s	.delete									; if not, branch
		move.w	(v_player+obX).w,obX(a0)
		move.w	(v_player+obY).w,obY(a0)
		move.b	(v_player+obStatus).w,obStatus(a0)
		andi.b	#maskFlipX,obStatus(a0)		; Copy first bit, so the Shield is always facing in the same direction as the player.

	; Mercury Shield/Invincibility Positioning Fix
		move.b	obStatus(a0),d0
		move.w	#$A,d1

		if CDBalancing
			cmpi.b	#aniID_Balance2,(v_player+obAnim).w
			beq.s	.shift
			cmpi.b	#aniID_Balance3,(v_player+obAnim).w
			bne.s	.noshift
			bchg	#staFacing,d0
			move.w	#4,d1
		else	
			cmpi.b	#aniID_Balance,(v_player+obAnim).w
			bne.s	.noshift
		endif
		
.shift:
		sub.w	d1,obX(a0)
		btst	#staFlipX,d0	; X-Flip sprite bit
		beq.s	.noshift
		add.w	d1,d1
		add.w	d1,obX(a0)
.noshift:
	; Shield/Invincibility Positioning Fix End

		lea		Ani_Shield(pc),a1
		jsr		(AnimateSprite).w
		bsr.w	Shield_LoadGfx

		move.w	#priority1,d0		; RetroKoH/Devon S3K+ Priority Manager
		cmpi.b	#$F,obFrame(a0)
		bcs.s	.display
		move.w	#priority4,d0		; RetroKoH/Devon S3K+ Priority Manager

.display:
		jmp		(DisplaySprite2).l

.remove:
		rts

; Commented out code is useful for hacks w/ additional characters.
.delete:
		andi.b	#mask2ndRmvShield,(v_player+obStatus2nd).w
	if InstashieldEnabled
;		tst.b	(v_player+obCharID).w		; You would need to add obCharID to player SST to use this.
;		bne.s	.notSonic
		clr.b	obRoutine(a0)
		move.b	#shTypeInsta,obSubtype(a0)	; Replace shield with instashield
		rts

;.notSonic:
; Normal .delete (without instashield) jumps straight to this line.
	endif
		jmp		(DeleteObject).l			; Delete if instashield isn't enabled
; ===========================================================================

Shi_Lightning:	; Routine $A

		if SuperMod
			btst	#sta2ndSuper,(v_player+obStatus2nd).w	; is Sonic Super?
			bne.w	.remove									; if yes, branch
		endif

		btst	#sta2ndInvinc,(v_player+obStatus2nd).w	; does Sonic have invincibility?
		bne.w	.remove									; if yes, branch
		btst	#sta2ndShield,(v_player+obStatus2nd).w	; does Sonic have shield?
		beq.w	.delete									; if not, branch
		btst	#staWater,(v_player+obStatus).w			; is Sonic underwater?
		bne.w	.checkflash								; if yes, branch, and destroy the shield
		move.w	(v_player+obX).w,obX(a0)
		move.w	(v_player+obY).w,obY(a0)
		move.b	(v_player+obStatus).w,obStatus(a0)
		andi.b	#maskFlipX,obStatus(a0)					; Copy first bit, so the Shield is always facing in the same direction as the player.

	; Mercury Shield/Invincibility Positioning Fix
		move.b	obStatus(a0),d0
		move.w	#$A,d1

		if CDBalancing
			cmpi.b	#aniID_Balance2,(v_player+obAnim).w
			beq.s	.shift
			cmpi.b	#aniID_Balance3,(v_player+obAnim).w
			bne.s	.noshift
			bchg	#staFacing,d0
			move.w	#4,d1
		else	
			cmpi.b	#aniID_Balance,(v_player+obAnim).w
			bne.s	.noshift
		endif
		
.shift:
		sub.w	d1,obX(a0)
		btst	#staFlipX,d0	; X-Flip sprite bit
		beq.s	.noshift
		add.w	d1,d1
		add.w	d1,obX(a0)
.noshift:
	; Shield/Invincibility Positioning Fix End
	
		cmpi.b	#aniID_LightningShield,obAnim(a0)
		beq.s	.animate
		bsr.w	Lightning_CreateSpark
		move.b	#aniID_LightningShield,obAnim(a0)

.animate:
		lea		Ani_Shield(pc),a1
		jsr		(AnimateSprite).w
		bsr.w	Shield_LoadGfx

		move.w	#priority1,d0		; RetroKoH/Devon S3K+ Priority Manager
		cmpi.b	#$F,obFrame(a0)
		bcs.s	.display
		move.w	#priority4,d0		; RetroKoH/Devon S3K+ Priority Manager

.display:
		jmp		(DisplaySprite2).l

.remove:
		rts

.checkflash: ; SPECIAL EFFECT FOR UNDERWATER (To be added later)
		;tst.w	(v_pcyc_time).w
		bra.s	Lightning_FlashWater

; Commented out code is useful for hacks w/ additional characters.
.delete:
		andi.b	#mask2ndRmvShield,(v_player+obStatus2nd).w
	if InstashieldEnabled
;		tst.b	(v_player+obCharID).w		; You would need to add obCharID to player SST to use this.
;		bne.s	.notSonic
		clr.b	obRoutine(a0)
		move.b	#shTypeInsta,obSubtype(a0)	; Replace shield with instashield
		rts

;.notSonic:
; Normal .delete (without instashield) jumps straight to this line.
	endif
		jmp		(DeleteObject).l			; Delete if instashield isn't enabled
; ===========================================================================

Lightning_FlashWater:
		move.b	#id_Shi_FlashOut,obRoutine(a0)		; set to Lightning_Destroy routine
		andi.b	#mask2ndRmvShield,(v_player+obStatus2nd).w
		lea		(v_palette_water).w,a1
		lea		(v_palette_water_fading).w,a2
		move.w	#$1F,d0

.loop:
		move.l	(a1),(a2)+
		move.l	#$EEE0EEE,(a1)+
		dbf		d0,.loop
		move.w	#0,-$40(a1)
		rts
; ===========================================================================
Lightning_CreateSpark:
		lea		(v_sparksobj).w,a1
		lea		(SparkVelocities).l,a2
		moveq	#3,d1

.loop:
		move.b	obID(a0),obID(a1)
		move.b	#id_Shi_Spark,obRoutine(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.l	obMap(a0),obMap(a1)
		move.w	obGfx(a0),obGfx(a1)
		move.b	#4,obRender(a1)
		move.b	#8,obActWid(a1)
		move.b	#aniID_LightningSpark,obAnim(a1)
		move.w	(a2)+,obVelX(a1)
		move.w	(a2)+,obVelY(a1)
		lea		object_size(a1),a1
		dbf		d1,.loop

.end:
		rts
; End of function Lightning_CreateSpark
; ===========================================================================
; ---------------------------------------------------------------------------
SparkVelocities:
		dc.w  $FE00, $FE00
		dc.w   $200, $FE00
		dc.w  $FE00,  $200
		dc.w   $200,  $200
; ---------------------------------------------------------------------------

Shi_FlameDissipate: ; Routine $C
		jsr		(SpeedToPos).l
		subq.b	#1,obTimeFrame(a0)
		bpl.s	.display
		move.b	#3,obTimeFrame(a0)
		addq.b	#1,obFrame(a0)
		cmpi.b	#5,obFrame(a0)
		beq.s	.delete

.display:
		move.w	#priority5,d0		; RetroKoH/Devon S3K+ Priority Manager
		jmp		(DisplaySprite2).l

.delete:
		jmp		(DeleteObject).l
; ===========================================================================

Shi_LightningSpark: ; Routine $E
		jsr		(SpeedToPos).l
		addi.w	#$18,obVelY(a0)
		lea		Ani_Shield(pc),a1
		jsr		(AnimateSprite).w
		cmpi.b	#id_Shi_Spark,obRoutine(a0)
		bne.s	.delete
		move.w	#priority1,d0		; RetroKoH/Devon S3K+ Priority Manager
		jmp		(DisplaySprite2).l

.delete:
		jmp		(DeleteObject).l
; ===========================================================================

Shi_LightningDestroy: ; Routine $10
		subq.b	#1,obTimeFrame(a0)
		bpl.s	.return
	if InstashieldEnabled
;		tst.b	(v_player+obCharID).w		; You would need to add obCharID to player SST to use this.
;		bne.s	.notSonic
		clr.b	obRoutine(a0)
		move.b	#shTypeInsta,obSubtype(a0)	; Replace shield with instashield
		bra.s	.cont

;.notSonic:
	endif
		jsr		(DeleteObject).l			; Delete if instashield isn't enabled

.cont:
		lea		(v_palette_water_fading).w,a1
		lea		(v_palette_water).w,a2
		move.w	#$1F,d0

.loop:
		move.l	(a1)+,(a2)+
		dbf		d0,.loop

.return:
		rts
; ===========================================================================
	endif

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
		move.w	(a2)+,d5					; read "number of entries" value -- S3k: .b to .w
		subq.w	#1,d5
		bmi.s	.nochange					; if zero, branch
		move.w	#(ArtTile_Shield*$20),d4

.readentry:
		moveq	#0,d1
		move.w	(a2)+,d1	; S3K .b to .w
		move.w	d1,d3		; S3K
		lsr.w	#8,d3		; S3K
		andi.w	#$F0,d3
		addi.w	#$10,d3
		andi.w	#$FFF,d1
		lsl.l	#5,d1
		add.l	obArtLoc(a0),d1
		move.w	d4,d2
		add.w	d3,d4
		add.w	d3,d4
		jsr		(QueueDMATransfer).w
		dbf		d5,.readentry		; repeat for number of entries

.nochange:
		rts
	
	if (ShieldsMode | InstashieldEnabled)
; ===========================================================================
; Shield variables
; ===========================================================================
ShieldVars:
				; anim					; map				; artLoc		; dplcLoc
		dc.l	aniID_BlueShield,		Map_Shield,			Art_Shield,		ShieldDynPLC		; $00 - Blue Shield
	if InstashieldEnabled
		dc.l	aniID_InstaIdle,		Map_InstaShield,	Art_Insta,		DPLC_InstaShield	; $10 - InstaShield
	endif
	if ShieldsMode
		dc.l	aniID_FlameShield,		Map_FlameShield,	Art_Shield_F,	DPLC_FlameShield	; $20 - Flame
		dc.l	aniID_BubbleShield,		Map_BubbleShield,	Art_Shield_B,	DPLC_BubbleShield	; $30 - Bubble
		dc.l	aniID_LightningShield,	Map_LightningShield,Art_Shield_L,	DPLC_LightningShield; $40 - Lightning
	endif
; ===========================================================================
	endif