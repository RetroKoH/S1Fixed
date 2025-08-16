; ----------------------------------------------------------------------------
; Pseudo-object that manages where rings are placed onscreen as you move
; through the level, and otherwise updates them.
;
; Taken from Sonic 2; Upgraded to S3K equivalent
; ----------------------------------------------------------------------------

RingsManager:
	; LavaGaming Object Routine Optimization
		tst.b	(v_ringsroutine).w
		bne.w	RM_Next
	; Object Routine Optimization End

RM_Main:
		addq.b	#2,(v_ringsroutine).w		; => RingsManager_Main

; perform initial setup
		clearRAM	v_ringpos				; clear positions table
		clearRAM	v_ringconsumedata,v_ringconsumedata+$40		; clear consumption table

		moveq	#0,d0

		move.w	(v_zone).w,d0
		ror.b	#2,d0					; lsl.b	#6,d0 > Filter Optimized Shifting
		lsr.w	#4,d0
		lea		(RingPos_Index).l,a1
		movea.l	(a1,d0.w),a1			; Table read optimization - RetroKoH
; If RingPos_Index table entries need to be word-length instead of long-length,
; replace the above line with this code... it's actually faster than the original code:
;		move.w	(a1,d0.w),d0
;		adda.w	d0,a1					; Table read optimization - Vladikcomper
		move.l	a1,(v_ringstart_addr_ROM).w
		addq.w	#4,a1
		moveq	#0,d5
		move.w	#(Max_Rings-1),d0

	.setuploop:
		tst.l	(a1)+
		bmi.s	.setupend
		addq.w	#1,d5
		dbf		d0,.setuploop

	.setupend:
	if PerfectBonusEnabled
		move.w	d5,(v_perfectringsleft).w
	endif
; initial setup end

		movea.l	(v_ringstart_addr_ROM).w,a1	; starting address in ROM
		lea		(v_ringpos).w,a2			; ring status table to a2
		move.w	(v_screenposx).w,d4			; left-most pixel displayed
		subq.w	#8,d4
		bhi.s	.chkring
		moveq	#1,d4						; no negative values allowed
		bra.s	.chkring

.nextring:
		; load next ring
		addq.w	#4,a1						; increment in ROM
		addq.w	#2,a2						; increment in RAM

.chkring:
		cmp.w	(a1),d4						; is the X pos of the ring < camera X pos?
		bhi.s	.nextring					; if it is, check next ring
		move.l	a1,(v_ringstart_addr_ROM).w	; set start address in ROM
		move.w	a2,(v_ringstart_addr_RAM).w	; set start address in RAM
		addi.w	#320+16,d4					; advance by a screen
		bra.s	.chkring_2

.nextring_2:
		addq.w	#4,a1						; load next ring

.chkring_2:
		cmp.w	(a1),d4						; is the X pos of the ring < camera X + 336?
		bhi.s	.nextring_2					; if it is, check next ring
		move.l	a1,(v_ringend_addr_ROM).w	; set end address
		rts
; ===========================================================================

RM_Next:
		lea		(v_ringconsumedata).w,a2
		move.w	(a2)+,d1					; d1 = (v_ringconsumecount).w
		subq.w	#1,d1						; are any rings currently being consumed?
		bcs.s	.RM_3132B8					; if not, branch

.RM_31328C:
		move.w	(a2)+,d0					; is there a ring in this slot?
		beq.s	.RM_31328C					; if not, branch
		movea.w	d0,a1						; load ring address
		subq.b	#1,(a1)						; decrement timer
		bne.s	.RM_3132B4					; if it's not 0 yet, branch
		move.b	#6,(a1)						; reset timer
		addq.b	#1,1(a1)					; increment frame
		cmpi.b	#5,1(a1)					; is it destruction time yet? - Optimized rings (DeltaW/Malachi)
		bne.s	.RM_3132B4					; if not, branch
		move.w	#-1,(a1)					; destroy ring
		clr.w	-2(a2)						; clear ring entry
		subq.w	#1,(v_ringconsumecount).l	; subtract count

.RM_3132B4:
		dbf		d1,.RM_31328C				; repeat for all rings in table

.RM_3132B8:
	; update ring start addresses
		movea.l	(v_ringstart_addr_ROM).w,a1
		movea.w	(v_ringstart_addr_RAM).w,a2
		move.w	(v_screenposx).w,d4
		subq.w	#8,d4
		bhi.s	.RM_3132CC
		moveq	#1,d4
		bra.s	.RM_3132CC

.RM_3132C8:
		addq.w	#4,a1						; increment in ROM
		addq.w	#2,a2						; increment in RAM

.RM_3132CC:
		cmp.w	(a1),d4
		bhi.s	.RM_3132C8
		bra.s	.RM_3132D6

.RM_3132D4:
		subq.w	#4,a1						; increment in ROM
		subq.w	#2,a2						; increment in RAM

.RM_3132D6:
		cmp.w	-4(a1),d4
		bls.s	.RM_3132D4
		move.l	a1,(v_ringstart_addr_ROM).w	; update start address in ROM
		move.w	a2,(v_ringstart_addr_RAM).w	; update start address in RAM
		movea.l	(v_ringend_addr_ROM).w,a2	; set end address
		addi.w	#320+16,d4					; advance by a screen
		bra.s	.RM_3132EE

.RM_3132EA:
		addq.w	#4,a2

.RM_3132EE:
		cmp.w	(a2),d4
		bhi.s	.RM_3132EA
		bra.s	.RM_3132F8

.RM_3132F6:
		subq.w	#4,a2

.RM_3132F8:
		cmp.w	-4(a2),d4
		bls.s	.RM_3132F6
		move.l	a2,(v_ringend_addr_ROM).w	; update end address
		rts

; ---------------------------------------------------------------------------
; Subroutine to handle ring collision
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

Touch_Rings:
		cmpi.b	#90,obInvuln(a0)				; is Sonic too early in invuln frames to collect rings? -- RetroKoH Sonic SST Compaction
		bhs.w	Touch_Rings_Done				; if so, return
		movea.l	(v_ringstart_addr_ROM).w,a1		; load start and end addresses
		movea.l	(v_ringend_addr_ROM).w,a2
		cmpa.l	a1,a2							; are there rings in this area?
		beq.w	Touch_Rings_Done				; if not, return
		movea.w	(v_ringstart_addr_RAM).w,a4		; load start address

	if ShieldsMode
		btst	#sta2ndLShield,obStatus2nd(a0)	; does the player have a lightning shield?
		beq.s	Touch_Rings_NoAttraction		; if not, branch
		move.w	obX(a0),d2						; get character's position
		move.w	obY(a0),d3
		subi.w	#RingMagnetRange,d2				; lightning shield's magnetic range in each direction
		subi.w	#RingMagnetRange,d3
		move.w	#6,d1							; set ring radius
		move.w	#12,d6							; set ring diameter
		move.w	#$80,d4							; set Sonic's X diameter
		move.w	#$80,d5							; set Y diameter
		bra.s	Touch_Rings_Loop
; ---------------------------------------------------------------------------
	endif

Touch_Rings_NoAttraction:
		move.w	obX(a0),d2						; get character's position
		move.w	obY(a0),d3
		subi.w	#8,d2							; assume X radius to be 8
		moveq	#0,d5
		move.b	obHeight(a0),d5
		subq.b	#3,d5
		sub.w	d5,d3							; subtract (Y radius - 3) from Y pos
		cmpi.b	#aniID_Duck,obAnim(a0)
		bne.s	.TR_2							; if you're not ducking, branch
		addi.w	#$C,d3
		moveq	#$A,d5

.TR_2:
		move.w	#6,d1							; set ring radius
		move.w	#12,d6							; set ring diameter
		move.w	#16,d4							; set Sonic's X diameter
		add.w	d5,d5							; set Y diameter

Touch_Rings_Loop:
		tst.w	(a4)							; has this ring already been collided with?
		bne.s	Touch_NextRing					; if it has, branch
		move.w	(a1),d0							; get ring X pos
		sub.w	d1,d0							; get ring left edge X pos
		sub.w	d2,d0							; subtract Sonic's left edge X pos
		bcc.s	.TRL_2							; if Sonic's to the left of the ring, branch
		add.w	d6,d0							; add ring diameter
		bcs.s	.TRL_3							; if Sonic's colliding, branch
		bra.s	Touch_NextRing					; otherwise, test next ring

.TRL_2:
		cmp.w	d4,d0							; has Sonic crossed the ring?
		bhi.s	Touch_NextRing					; if he has, branch

.TRL_3:
		move.w	2(a1),d0						; get ring Y pos
		sub.w	d1,d0							; get ring top edge pos
		sub.w	d3,d0							; subtract Sonic's top edge pos
		bcc.s	.TRL_4							; if Sonic's above the ring, branch
		add.w	d6,d0							; add ring diameter
		bcs.s	.chkshield						; if Sonic's colliding, branch
		bra.s	Touch_NextRing					; otherwise, test next ring

.TRL_4:
		cmp.w	d5,d0							; has Sonic crossed the ring?
		bhi.s	Touch_NextRing					; if he has, branch

.chkshield:
	if ShieldsMode
		btst	#sta2ndLShield,obStatus2nd(a0)	; does the player have a lightning shield?
		bne.s	Touch_Ring_AttractRing			; if yes, branch
	endif

Touch_DestroyRing:
		move.w	#$601,(a4)					; set frame and destruction timer - $601 instead of $604 for optimal rings

	if PerfectBonusEnabled
		subq.w	#1,(v_perfectringsleft).w
	endif

		bsr.w	CollectRing
		lea		(v_ringconsumelist).w,a3

.loop:
		tst.w	(a3)+						; is this slot free?
		bne.s	.loop						; if not, repeat until you find one
		move.w	a4,-(a3)					; set ring address
		addq.w	#1,(v_ringconsumedata).w	; increase count

Touch_NextRing:
		addq.w	#4,a1
		addq.w	#2,a4
		cmpa.l	a1,a2						; are we at the last ring for this area?
		bne.s	Touch_Rings_Loop			; if not, branch

Touch_Rings_Done:
		rts
; ---------------------------------------------------------------------------

	if ShieldsMode
Touch_Ring_AttractRing:
		movea.l	a1,a3
		jsr		(FindFreeObj).l
		bne.w	.noring
		move.b	#id_RingLoss,obID(a1)	; Create attracted ring in the location of the ring in the Ring Manager
		move.b	#$A,obRoutine(a1)		; Set routine to Attracted Ring
		move.w	(a3),obX(a1)			; Set x-position of object based on x-position in table
		move.w	2(a3),obY(a1)			; Do the same for the y-position
		move.w	a4,$30(a1)
		move.w	#-1,(a4)
		rts
; ---------------------------------------------------------------------------

.noring:
		movea.l	a3,a1
		bra.s	Touch_DestroyRing
; ---------------------------------------------------------------------------
	endif

; ---------------------------------------------------------------------------
; Subroutine to draw on-screen rings
; Partial adaptation of optimizations by Malachi
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

BuildRings_QuickExit:
		rts

BuildRings:
		movea.l	(v_ringstart_addr_ROM).w,a0
		move.l	(v_ringend_addr_ROM).w,d7
		sub.l	a0,d7							; are there any rings on-screen?
		beq.s	BuildRings_QuickExit			; if there aren't, branch and return
		movea.w	(v_ringstart_addr_RAM).w,a4		; load start address
		lea		(v_screenposx).w,a3				; load camera x position

	.loop:
		move.w	(a4)+,d1			; has this ring been consumed? (Store frame value)
		bmi.s	.noren				; if it has, branch
		move.w	(a0),d3				; get ring X pos
		sub.w	(a3),d3				; subtract camera X pos
		addi.w	#128,d3				; screen top is 128x128 not 0x0
		move.w	2(a0),d2			; get ring Y pos
		sub.w	4(a3),d2			; subtract camera Y pos
		andi.w	#$7FF,d2
		addi.w	#8,d2
		bmi.s	.noren				; dunno how this check is supposed to work
		cmpi.w	#240,d2
		bge.s	.noren				; if the ring is not on-screen, branch
		addi.w	#128-8,d2
		move.b	d1,d6				; extract stored ring frame value
		add.b	d6,d6				; this will only affect d6 on a sparkle frame

		move.b	#-8,d0				; get Y offset
		ext.w	d0
		add.w	d2,d0				; add Y offset to Y pos
		move.w	d0,(a2)+			; set Y pos

		move.b	#5,(a2)+			; set size (2x2)
		addq.b	#1,d5
		move.b	d5,(a2)+			; set link field

		move.w	CMap_Ring(pc,d6.w),(a2)+	; set art tile and flags

		move.b	#-8,d0				; get X offset
		ext.w	d0
		add.w	d3,d0				; add Y offset to Y pos
		move.w	d0,(a2)+			; set Y pos

	.noren:
		addq.w	#4,a0
		subq.w	#4,d7
		bne.w	.loop
		rts
; ===========================================================================

; ---------------------------------------------------------------------------
; Custom mappings format

; Differences:
; No offset table (each sprite assumed to be 2 bytes: ArtTile + flags/offset)
; No 'sprite pieces per frame' value (hardcoded to 1)
; X-pos and Y-pos offsets are hardcoded to -8 ($F8)
; No sprite size value (hardcoded to 5; 2x2)

CMap_Ring:
.ring:		dc.w make_art_tile(ArtTile_Ring,1,0)+$0000
.sparkle1:	dc.w make_art_tile(ArtTile_Ring,1,0)+$0008
.sparkle2:	dc.w make_art_tile(ArtTile_Ring,1,0)+$1808
.sparkle3:	dc.w make_art_tile(ArtTile_Ring,1,0)+$0808
.sparkle4:	dc.w make_art_tile(ArtTile_Ring,1,0)+$1008
.blank:		dc.w 0, 0
; ===========================================================================