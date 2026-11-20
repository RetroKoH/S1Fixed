; ---------------------------------------------------------------------------
; Subroutine to react to harmful level terrain (RobiWan)
;
; Currently only used in Marble Zone
; ---------------------------------------------------------------------------

ReactToHazardTiles:
		cmpi.b	#id_MZ,(v_zone).w	; Only apply this in Marble Zone
		bne.s	.nolava			; branch if not in Marble
	
	; If multiple Zones and tiles are accounted for, it's better to
	; check after tile is found, or in HurtSonic_FromTerrain.
	; for now, it's easier to call it here.
	if ShieldsMode
		btst	#sta2ndFShield,obStatus2nd(a0)
		bne.s	.nolava
	endif

	; Check three points at Sonic's base (left, middle, right)
	; a0 is always Sonic... easy
		moveq	#0,d0			; clear. No need to extend
		move.b	obHeight(a0),d0		; get Sonic's height
		move.w	obY(a0),d2
		add.w	d0,d2			; d2 = y pos. of Sonic's bottom edge (all sensors)
		
		move.b	obWidth(a0),d0		; get Sonic's width
		move.w	obX(a0),d3
		move.w	d3,d5
		sub.w	d0,d3			; left edge
		add.w	d0,d5			; right edge
		andi.w	#$FFF0,d3		; start of the leftmost block's left edge

	.column:
		bsr.w	FindNearestTile
		move.w	(a1),d0			; get value for solidness, orientation and 16x16 tile number (we only need the 16x16 tile)
		andi.w	#$3FF,d0		; extract the 16x16 tile number from it
		lea	MarbleZone_LavaBlk(pc),a3
		move.w	#(MarbleZone_LavaBlk_end-MarbleZone_LavaBlk)/2-1,d4	; checks 6 words

	.loop:
		cmp.w	(a3)+,d0		; does the block ID match the table entry in (a3)?
		beq.s	.hurt			; if so, branch
		dbf	d4,.loop		; if not, check the next one
	
	.gotoNextColumn:
		addi.w	#$10,d3			; advance one block column to the right
		cmp.w	d5,d3
		ble.s	.column			; check block

	.nolava:
		rts

	; check tile height and hurt Sonic
	.hurt:
		movea.l	(v_collindex).w,a2
		move.b	(a2,d0.w),d0		; get collision for the block ID in d0
		andi.w	#$FF,d0			; we only want the lower byte (Clears 1 from the old block ID)
		lsl.w	#4,d0			; ID * 16
		lea	(CollArray1).l,a2	; a2 = heightmaps (normal)
		move.b	(a2,d0.w),d0		; since lava blocks are flat, just get the first heightmap value
		ble.s	.gotoNextColumn		; if heightmap value is 0 or negative, check next block column
		
		move.w	d2,d1			; d1 = y-position of Sonic's base
		andi.w	#$F,d1			; get the row within the current block (0-F)
		add.b	d0,d1			; add heightmpa value (d0) to Sonic's row (collision check)
		cmpi.b	#$10,d1
		blo.s	.gotoNextColumn		; if Sonic is above the "surface", check next block column
		jmp	(HurtSonic_FromTerrain).l
; ===========================================================================

MarbleZone_LavaBlk:	; These are the same in stock S1
			; $16E and $16F are the surface
		dc.w	$16A, $16B, $16C, $16D, $16E, $16F
MarbleZone_LavaBlk_end:
; ===========================================================================