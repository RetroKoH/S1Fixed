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

	; Get Sonic's Bottom-Right Edge
		move.w	obY(a0),d2		; this is only called from Sonic, using a0 is fine
		move.w	obX(a0),d3
		moveq	#0,d0
		move.b	obHeight(a0),d0		; Get Sonic's height
		ext.w	d0			; Make it word sized so that we we only get to the value of Sonic's bottom edge, not some far-off place
		add.w	d0,d2			; d2 = y pos. of Sonic's bottom edge
		move.b	obWidth(a0),d0		; Get Sonic's width
		ext.w	d0			; Make it word sized so that we we only get to the value of Sonic's right edge, not some far-off place
		add.w	d0,d3			; d3 = x pos. of Sonic's right edge

		bsr.w	FindNearestTile
		move.w	(a1),d0			; get value for solidness, orientation and 16x16 tile number (we only need the 16x16 tile)
		andi.w	#$3FF,d0		; Extract the 16x16 tile number from it

	.chklava:
		lea	(MarbleZone_LavaBlk).l,a3
		moveq	#0,d4
		move.w	#(MarbleZone_LavaBlk_end-MarbleZone_LavaBlk)/2-1,d4	; Checks 6 words

	.loop:
		cmp.w	(a3)+,d0		; Does the object ID match the table?
		beq.s	.hurt			; If so, branch
		dbf	d4,.loop

	.nolava:
		rts

	.hurt:
		andi.w	#$FFF0,d3		; align X to the block's left edge
		addq.w	#8,d3			; use the block center for knockback
		jmp	(HurtSonic_FromTerrain).l
; ===========================================================================

MarbleZone_LavaBlk:	; These are the same in stock S1
			; $16E and $16F are the surface
		dc.w	$16A, $16B, $16C, $16D, $16E, $16F
MarbleZone_LavaBlk_end:
; ===========================================================================