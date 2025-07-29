; ---------------------------------------------------------------------------
; Sonic	graphics loading subroutine (Mercury Use DMA Queue)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_LoadGfx:
		moveq	#0,d0
		move.b	obFrame(a0),d0			; d0 = Sonic's current frame number
		cmp.b	(v_sonframenum).w,d0	; has frame changed?
		beq.s	.nochange				; if not, branch and exit

		move.b	d0,(v_sonframenum).w	; update frame number for next check
		lea		SonicDynPLC(pc),a2		; a2 = PLC script

	if SuperMod
		move.l	#Art_Sonic,d6
		btst	#sta2ndSuper,obStatus2nd(a0)	; is Sonic super?
		beq.s	.notsuper						; if not, branch
		move.l	#Art_SuperSonic,d6
		lea		SuperSonicDynPLC(pc),a2
	
	.notsuper:
	endif
		add.w	d0,d0					; multiply current frame number by 2
		adda.w	(a2,d0.w),a2			; a2 = corresponding PLC
		moveq	#0,d5
		move.w	(a2)+,d5				; read "number of PLC entries" value						; S3K Changed from .b to .w
		subq.w	#1,d5					; decrement for .readentry loop
		bmi.s	.nochange				; if there are no entries, branch and exit
		move.w	#(ArtTile_Sonic*$20),d4	; d4 = Sonic's VRAM location

	.readentry:
		moveq	#0,d1
		move.w	(a2)+,d1				; d1 = (number of tiles to load - 1)*$10; aka "tile count"	; S3K Changed from .b to .w
		move.w	d1,d3
		lsr.w	#8,d3					; d3 = (tile count-1)*$10
		andi.w	#$F0,d3
		addi.w	#$10,d3					; get actual tile count*$10				-- DMATransfer Length
		andi.w	#$FFF,d1				; clear the counter to remove tile count from the far left nybble
		lsl.l	#5,d1					; changed to .l (allows for more than $FFFF bytes)

	if SuperMod
		add.l	d6,d1					; d1 = Sonic or Super Sonic's art file + tile offset) -- DMATransfer Source 
	else
		add.l	#Art_Sonic,d1			; d1 = (Sonic's art file + tile offset) -- DMATransfer Source
	endif

		move.w	d4,d2					; d2 = Sonic's VRAM location			-- DMATransfer Destination
		add.w	d3,d4
		add.w	d3,d4					; d4 = Sonic's VRAM loc + (tile count * 2)
		jsr		(QueueDMATransfer).w
		dbf		d5,.readentry			; repeat for number of entries

	.nochange:
		rts
; End of function Sonic_LoadGfx

