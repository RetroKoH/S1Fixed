; ----------------------------------------------------------------------------
; Pseudo-object that manages where rings are placed onscreen as you move through the level, and otherwise updates them.
; Taken from Sonic 2
;
; RAM Needed for this manager:
; v_ringsroutine ; 1 byte
; v_ringpos ; $600 bytes
; v_ringstart_addr ; 2 bytes
; v_ringend_addr ; 2 bytes
; v_ringconsumedata ; $80 bytes
; ----------------------------------------------------------------------------

; loc_16F88:
RingsManager:
		moveq	#0,d0
		move.b	(v_ringsroutine).w,d0
		move.w	RM_Index(pc,d0.w),d0
		jmp		RM_Index(pc,d0.w)
; ===========================================================================
RM_Index:
		dc.w RM_Main-RM_Index ; 0
		dc.w RM_Next-RM_Index ; 2
; ===========================================================================

RM_Main:
		addq.b	#2,(v_ringsroutine).w	; => RingsManager_Main
		bsr.w	RM_Setup				; perform initial setup
		lea		(v_ringpos).w,a1		; start address in RAM
		move.w	(v_screenposx).w,d4		; left-most pixel displayed
		subq.w	#8,d4
		bhi.s	.chkring
		moveq	#1,d4					; no negative values allowed
		bra.s	.chkring

.nextring:
		lea		6(a1),a1				; load next ring

.chkring:
		cmp.w	2(a1),d4				; is the X pos of the ring < camera X pos?
		bhi.s	.nextring				; if it is, check next ring
		move.w	a1,(v_ringstart_addr).w	; set start address
		addi.w	#320+16,d4				; advance by a screen
		bra.s	.chkring_2

.nextring_2:
		lea		6(a1),a1				; load next ring

.chkring_2:
		cmp.w	2(a1),d4				; is the X pos of the ring < camera X + 336?
		bhi.s	.nextring_2				; if it is, check next ring
		move.w	a1,(v_ringend_addr).w	; set end address
		rts
; ===========================================================================
; loc_16FDE:
RM_Next:
		lea		(v_ringconsumedata).w,a2
		move.w	(a2)+,d1
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
		cmpi.b	#$C,1(a1)					; is it destruction time yet? - 8 frame rings. (Caverns4 / IkeyIlex)
		bne.s	.RM_3132B4					; if not, branch
		move.w	#-1,(a1)					; destroy ring
		clr.w	-2(a2)						; clear ring entry
		subq.w	#1,(v_ringconsumedata).l	; subtract count

.RM_3132B4:
		dbf	d1,.RM_31328C					; repeat for all rings in table

.RM_3132B8:
	; update ring start and end addresses
		movea.w	(v_ringstart_addr).w,a1
		move.w	(v_screenposx).w,d4
		subq.w	#8,d4
		bhi.s	.RM_3132CC
		moveq	#1,d4
		bra.s	.RM_3132CC

.RM_3132C8:
		lea		6(a1),a1

.RM_3132CC:
		cmp.w	2(a1),d4
		bhi.s	.RM_3132C8
		bra.s	.RM_3132D6

.RM_3132D4:
		subq.w	#6,a1

.RM_3132D6:
		cmp.w	-4(a1),d4
		bls.s	.RM_3132D4
		move.w	a1,(v_ringstart_addr).w	; update start address

		movea.w	(v_ringend_addr).w,a2
		addi.w	#320+16,d4
		bra.s	.RM_3132EE

.RM_3132EA:
		lea		6(a2),a2

.RM_3132EE:
		cmp.w	2(a2),d4
		bhi.s	.RM_3132EA
		bra.s	.RM_3132F8

.RM_3132F6:
		subq.w	#6,a2

.RM_3132F8:
		cmp.w	-4(a2),d4
		bls.s	.RM_3132F6
		move.w	a2,(v_ringend_addr).w	; update end address
		rts

; ---------------------------------------------------------------------------
; Subroutine to handle ring collision
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_170BA:
Touch_Rings:
		cmpi.b	#$5A,obInvuln(a0)			; does the player have three or more seconds of invulnerability left?
		bhs.w	Touch_Rings_Done			; if so, return
		movea.w	(v_ringstart_addr).w,a1
		movea.w	(v_ringend_addr).w,a2
		cmpa.l	a1,a2						; are there no rings in this area?
		beq.w	Touch_Rings_Done			; if so, return

; Add Lightning Shield Attraction later

		move.w	obX(a0),d2
		move.w	obY(a0),d3
		subi.w	#8,d2	; assume X radius to be 8
		moveq	#0,d5
		move.b	obHeight(a0),d5
		subq.b	#3,d5
		sub.w	d5,d3	; subtract (Y radius - 3) from Y pos
		cmpi.b	#$4D,obFrame(a0)
		bne.s	.TR_2	; if you're not ducking, branch
		addi.w	#$C,d3
		moveq	#$A,d5

.TR_2:
		move.w	#6,d1	; set ring radius
		move.w	#12,d6	; set ring diameter
		move.w	#16,d4	; set Sonic's X diameter
		add.w	d5,d5	; set Y diameter

; loc_17112:
Touch_Rings_Loop:
		tst.w	(a1)			; has this ring already been collided with?
		bne.w	Touch_NextRing	; if it has, branch
		move.w	2(a1),d0		; get ring X pos
		sub.w	d1,d0			; get ring left edge X pos
		sub.w	d2,d0			; subtract Sonic's left edge X pos
		bcc.s	.TRL_2			; if Sonic's to the left of the ring, branch
		add.w	d6,d0			; add ring diameter
		bcs.s	.TRL_3			; if Sonic's colliding, branch
		bra.w	Touch_NextRing	; otherwise, test next ring

.TRL_2:
		cmp.w	d4,d0			; has Sonic crossed the ring?
		bhi.w	Touch_NextRing	; if he has, branch

.TRL_3:
		move.w	4(a1),d0		; get ring Y pos
		sub.w	d1,d0			; get ring top edge pos
		sub.w	d3,d0			; subtract Sonic's top edge pos
		bcc.s	.TRL_4			; if Sonic's above the ring, branch
		add.w	d6,d0			; add ring diameter
		bcs.s	Touch_DestroyRing	; if Sonic's colliding, branch
		bra.w	Touch_NextRing	; otherwise, test next ring

.TRL_4:
		cmp.w	d5,d0			; has Sonic crossed the ring?
		bhi.w	Touch_NextRing	; if he has, branch

; Add Lightning Shield check later

Touch_DestroyRing:
		move.w	#$608,(a1)		; set frame and destruction timer - $608 instead of $604 for 8-frame rings
		bsr.w	CollectRing
		lea		(v_ringconsumedata+2).w,a3

.loop:
		tst.w	(a3)+						; is this slot free?
		bne.s	.loop						; if not, repeat until you find one
		move.w	a1,-(a3)					; set ring address
		addq.w	#1,(v_ringconsumedata).w	; increase count

; loc_1715C:
Touch_NextRing:
		lea		6(a1),a1
		cmpa.l	a1,a2				; are we at the last ring for this area?
		bne.w	Touch_Rings_Loop	; if not, branch

; return_17166:
Touch_Rings_Done:
		rts
; ---------------------------------------------------------------------------


; ---------------------------------------------------------------------------
; Subroutine to draw on-screen rings
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_17178:
BuildRings:
		movea.w	(v_ringstart_addr).w,a0
		movea.w	(v_ringend_addr).w,a4
		cmpa.l	a0,a4					; are there any rings on-screen?
		bne.s	.BR_2					; if there are, branch
		rts								; otherwise, return

.BR_2:
		lea		(v_screenposx).w,a3

; loc_1718A:
BuildRings_Loop:
		tst.w	(a0)		; has this ring been consumed?
		bmi.w	BuildRings_NextRing	; if it has, branch
		move.w	2(a0),d3	; get ring X pos
		sub.w	(a3),d3		; subtract camera X pos
		addi.w	#128,d3		; screen top is 128x128 not 0x0
		move.w	4(a0),d2	; get ring Y pos
		sub.w	4(a3),d2	; subtract camera Y pos
		andi.w	#$7FF,d2
		addi.w	#8,d2
		bmi.s	BuildRings_NextRing	; dunno how this check is supposed to work
		cmpi.w	#240,d2
		bge.s	BuildRings_NextRing	; if the ring is not on-screen, branch
		addi.w	#128-8,d2
		lea		(Map_RingBIN).l,a1
		moveq	#0,d1
		move.b	1(a0),d1			; get ring frame
		bne.s	.BRL_2				; if this ring is using a specific frame, branch
		move.b	(v_ani1_frame).w,d1	; use global frame

.BRL_2:
		add.w	d1,d1
		adda.w	(a1,d1.w),a1		; get frame data address
		move.b	(a1)+,d0			; get Y offset
		ext.w	d0
		add.w	d2,d0				; add Y offset to Y pos
		move.w	d0,(a2)+			; set Y pos
		move.b	(a1)+,(a2)+			; set size
		addq.b	#1,d5
		move.b	d5,(a2)+			; set link field
		move.w	(a1)+,d0			; get art tile from mapping
		addi.w	#make_art_tile(ArtTile_Ring,1,0),d0	; add base art tile
		move.w	d0,(a2)+			; set art tile and flags
		move.b	(a1)+,d0			; get X offset
		ext.w	d0
		add.w	d3,d0				; add Y offset to Y pos
		move.w	d0,(a2)+			; set Y pos

; loc_171EC:
BuildRings_NextRing:
		lea		6(a0),a0
		cmpa.l	a0,a4
		bne.w	BuildRings_Loop
		rts

; ---------------------------------------------------------------------------
; Subroutine to perform initial rings manager setup
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_172A4:
RM_Setup:
		lea		(v_ringpos).w,a1
		moveq	#0,d0
		move.w	#$17F,d1

loc_31343C:					  ; Clear positions table
		move.l	d0,(a1)+
		dbf		d1,loc_31343C
		lea		(v_ringconsumedata).w,a1
		move.w	#$F,d1
.RMS_2:
		move.l	d0,(a1)+
		dbf		d1,.RMS_2

		moveq	#0,d5
		moveq	#0,d0

		move.w	(v_zone).w,d0
		lsl.b	#6,d0
		lsr.w	#4,d0
		lea		(RingPos_Index).l,a1
		move.w	(a1,d0.w),d0
		lea		(a1,d0.w),a1

		;movea.l	(a1,d0.w),a1
		;lea	d0,a1
		;lea	(a1,d0.w),a1
		lea		(v_ringpos+6).w,a2		; first ring is left blank

; loc_172E0:
RingsMgr_NextRowOrCol:
		move.w	(a1)+,d2			; is this the last ring? (Value will usually be $FFFF)
		bmi.s	RingsMgr_SortRings	; if it is, sort the rings
		move.w	(a1)+,d3			; is this a column of rings?
		bmi.s	RingsMgr_RingCol	; if it is, branch
		move.w	d3,d0
		rol.w	#4,d0
		andi.w	#7,d0				; store number of rings
		andi.w	#$FFF,d3			; store Y pos
; loc_172F4:
RingsMgr_NextRingInRow:
		clr.w	(a2)+				; set initial status
		move.w	d2,(a2)+			; set X pos
		move.w	d3,(a2)+			; set Y pos
		addi.w	#$18,d2				; increment X pos
		;addq.w	#1,d5				; increment perfect counter
		dbf		d0,RingsMgr_NextRingInRow
		bra.s	RingsMgr_NextRowOrCol
; ===========================================================================
; loc_17308:
RingsMgr_RingCol:
		move.w	d3,d0
		rol.w	#4,d0
		andi.w	#7,d0		; store number of rings
		andi.w	#$FFF,d3	; store Y pos
; loc_17314:
RingsMgr_NextRingInCol:
		clr.w	(a2)+		; set initial status
		move.w	d2,(a2)+	; set X pos
		move.w	d3,(a2)+	; set Y pos
		addi.w	#$18,d3		; increment Y pos
		;addq.w	#1,d5		; increment perfect counter
		dbf		d0,RingsMgr_NextRingInCol
		bra.s	RingsMgr_NextRowOrCol
; ===========================================================================
; loc_17328:
RingsMgr_SortRings:
		;move.w	d5,(Perfect_rings_left).w
		;move.w	#0,(Perfect_rings_flag).w	; no idea what this is
		moveq	#-1,d0
		move.l	d0,(a2)+					; set X pos of last ring to -1
		lea		(v_ringpos+2).w,a1			; X pos of first ring
		move.w	#$FE,d3						; sort 255 rings

.RMSR_2:
		move.w	d3,d4
		lea		6(a1),a2					; load next ring for comparison
		move.w	(a1),d0						; get X pos of current ring

.RMSR_3:
		tst.w	(a2)						; is the next ring blank?
		beq.s	.RMSR_4						; if it is, branch
		cmp.w	(a2),d0						; is the X pos of current ring <= X pos of next ring?
		bls.s	.RMSR_4						; if so, branch
		move.l	(a1),d1						; otherwise, swap the rings
		move.l	(a2),d0
		move.l	d0,(a1)
		move.l	d1,(a2)
		swap	d0
.RMSR_4:
		lea		6(a2),a2					; load next comparison ring
		dbf		d4,.RMSR_3					; repeat

		lea		6(a1),a1					; load next ring
		dbf		d3,.RMSR_2					; repeat

		rts
; ===========================================================================
