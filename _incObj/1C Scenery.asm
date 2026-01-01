; ---------------------------------------------------------------------------
; Object 1C - scenery (GHZ bridge stump, LZ Wheel, SLZ lava thrower)
; ---------------------------------------------------------------------------

Scenery:
		obj_addr	#Scen_ChkDel

	; New Scenery Loading (RetroKoH)
		moveq	#0,d0
		move.b	(v_zone).w,d0			; d0 = zone
		add.w	d0,d0
		lea		Scen_Index(pc),a1
		move.w	(a1,d0.w),d0
		adda.w	d0,a1					; Table read optimization - Vladikcomper

		move.l	(a1)+,obMap(a0)
		move.w	(a1)+,obGfx(a0)
		ori.b	#4,obRender(a0)
		move.b	(a1)+,obFrame(a0)
		move.b	(a1)+,obDispWid(a0)
		move.w	(a1)+,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
; ---------------------------------------------------------------------------

Scen_ChkDel:	; Routine 2
		offscreen.w	DeleteObject		; ProjectFM S3K Objects Manager
		bra.w	DisplaySprite
; ===========================================================================

Scen_Index:		offsetTable
		offsetTableEntry.w	Scen_Bridge
		offsetTableEntry.w	Scen_Wheel
		offsetTableEntry.w	Scen_Bridge		; Marble (Replace with NULL)
		offsetTableEntry.w	Scen_Cannon
		offsetTableEntry.w	Scen_Cannon		; Spring Yard (This will be the Light)
		offsetTableEntry.w	Scen_Cannon		; Scrap Brain (Replace with NULL)
; ===========================================================================

; ---------------------------------------------------------------------------
; Object Variables
; ---------------------------------------------------------------------------
Scen_Bridge:
		dc.l Map_Bri											; mappings address
		dc.w make_art_tile(ArtTile_GHZ_Bridge,2,0)				; VRAM setting
		dc.b 1,	$10                                   			; frame, width
		dc.w priority1											; priority

Scen_Wheel:
		dc.l Map_LConv
		dc.w make_art_tile(ArtTile_LZ_Conveyor_Wheel,0,0)
		dc.b 1,	$10
		dc.w priority1

Scen_Cannon:
		dc.l Map_Scen
		dc.w make_art_tile(ArtTile_SLZ_Fireball_Launcher,2,0)
		dc.b 0,	8
		dc.w priority2

		even
; ===========================================================================