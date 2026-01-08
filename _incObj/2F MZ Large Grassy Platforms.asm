; ---------------------------------------------------------------------------
; Object 2F - large grass-covered platforms (MZ)
; Subtype 1x has been split off into Obj2E by RetroKoH
; ---------------------------------------------------------------------------

LargeGrass:
		_move.l	#LGrass_Action,obAddr(a0)
		move.l	#Map_LGrass,obMap(a0)
		move.w	#make_art_tile(ArtTile_Level,2,1),obGfx(a0)
		move.b	#4,obRender(a0)
		move.w	#priority5,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.w	obY(a0),obLGrass_StartY(a0)
		move.w	obX(a0),obLGrass_StartX(a0)
		move.b	#2,obFrame(a0)				; narrow platform frame

		moveq	#$20,d0						; store platform width
		btst	#5,obSubtype(a0)			; read bit 5 of subtype
		bne.s	.no_slope					; if subtype is $2x, this is the flat narrow platform

		move.l	#LGrass_Collision,obLGrass_ColPtr(a0)	; get pointer to heightmap data again
		clr.b	obFrame(a0)					; wide sloped frame
		add.b	d0,d0						; multiply platform width by 2

	.no_slope:
		move.b	d0,obDispWid(a0)			; set to either $20 (narrow, flat) or $40 (wide, sloped)
		andi.b	#$F,obSubtype(a0)			; clear high nybble of subtype
		move.b	#$40,obHeight(a0)
		bset	#4,obRender(a0)
; ---------------------------------------------------------------------------

LGrass_Action:
		bsr.w	LGrass_Types
		btst	#staSonicOnObj,obStatus(a0)	; is platform being stood on? removed obSolid
		beq.s	LGrass_Solid				; if not, branch
		moveq	#11,d1
		add.b	obDispWid(a0),d1			; width; save 8 cycles
		bsr.w	ExitPlatform				; update flags if Sonic leaves plaform
		btst	#staOnObj,obStatus(a1)		; is Sonic still on the platform?
		bne.w	LGrass_Slope				; if yes, branch
		bclr	#staSonicOnObj,obStatus(a0)	; removed obSolid
		bra.w	LGrass_ChkDel
; ===========================================================================

LGrass_Slope:
		cmpi.b	#2,obFrame(a0)			; is this a narrow platform?
		beq.s	LGrass_Flat				; if yes, branch
		moveq	#11,d1
		add.b	obDispWid(a0),d1		; width; save 8 cycles
		movea.l	obLGrass_ColPtr(a0),a2	; pointer to heightmap
		move.w	obX(a0),d2				; axis position
		bsr.w	SlopeObject2
		bra.w	LGrass_ChkDel

LGrass_Flat:
		moveq	#43,d1						; width; save 4 cycles - Filter
		moveq	#48,d2						; height (jumping); save 4 cycles - Filter
		moveq	#48,d3						; height (walking); save 4 cycles - Filter
		move.w	obX(a0),d4					; axis position
		bsr.w	SolidObject
		bra.w	LGrass_ChkDel
; ===========================================================================

LGrass_Solid:
		cmpi.b	#2,obFrame(a0)			; is this a narrow platform?
		beq.s	LGrass_Flat				; if not, branch

		moveq	#11,d1
		add.b	obDispWid(a0),d1		; width; save 8 cycles
		moveq	#32,d2					; height

	.not_narrow:
		movea.l	obLGrass_ColPtr(a0),a2
		bsr.w	SolidObject2F			; SolidObject_Heightmap
		bra.w	LGrass_ChkDel			; Clownacy DisplaySprite Fix
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to update platform position and load burning grass object
; ---------------------------------------------------------------------------

LGrass_Types:
		moveq	#7,d0
		and.b	obSubtype(a0),d0				; read low nybble of subtype (SCE Optimization)
		beq.s	LGrass_Still					; skip if subtype 00
		add.w	d0,d0
		move.w	LGrass_TypeIndex-2(pc,d0.w),d1
		jmp		LGrass_TypeIndex(pc,d1.w)
; End of function LGrass_Types
; ===========================================================================

LGrass_TypeIndex:		offsetTable
		offsetTableEntry.w LGrass_Move32
		offsetTableEntry.w LGrass_Move48
		offsetTableEntry.w LGrass_Move64
		offsetTableEntry.w LGrass_Move96	; unused
		offsetTableEntry.w LGrass_Move96	; duplicate, unused
; ===========================================================================

; Type 0 - doesn't move
LGrass_Still:
		rts
; ===========================================================================

; Type 1 - moves up and down 32 pixels
LGrass_Move32:
		move.b	(v_oscillate+2).w,d0
		move.w	#32,d1
		bra.s	LGrass_Move
; ===========================================================================

; Type 2 - moves up and down 48 pixels
LGrass_Move48:
		move.b	(v_oscillate+6).w,d0
		move.w	#48,d1
		bra.s	LGrass_Move
; ===========================================================================

; Type 3 - moves up and down 64 pixels
LGrass_Move64:
		move.b	(v_oscillate+$A).w,d0
		move.w	#64,d1
		bra.s	LGrass_Move
; ===========================================================================

; Type 4/5 - moves up and down 96 pixels (unused)
LGrass_Move96:
		move.b	(v_oscillate+$E).w,d0
		move.w	#96,d1

LGrass_Move:
		btst	#3,obSubtype(a0)		; is bit 3 of subtype set? (+8)
		beq.s	.no_rev					; if not, branch
		neg.w	d0						; reverse direction
		add.w	d1,d0

	.no_rev:
		move.w	obLGrass_StartY(a0),d1
		sub.w	d0,d1
		move.w	d1,obY(a0)				; update y position
		rts	
; ===========================================================================

LGrass_ChkDel:
		offscreen.w	DeleteObject,obLGrass_StartX(a0)	; ProjectFM S3K Objects Manager
		bra.w	DisplaySprite						; Clownacy DisplaySprite Fix
; ===========================================================================

; ---------------------------------------------------------------------------
; Collision data for large moving platforms (Obj 2E and 2F)
; ---------------------------------------------------------------------------
; Obj 2E
SGrass_Collision:	binclude	"misc/MZ Sinking Platform Heightmap.bin"
		even

; Obj 2F
LGrass_Collision:	binclude	"misc/MZ Moving Platform Heightmap.bin"
		even
; ===========================================================================