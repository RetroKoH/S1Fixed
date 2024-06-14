; ----------------------------------------------------------------------------
; Pseudo-object that manages where rings are placed onscreen as you move
; through the level, and otherwise updates them.
;
; Taken from Sonic 2; Upgraded to S3K equivalent
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
		addq.b	#2,(v_ringsroutine).w		; => RingsManager_Main
		bsr.w	RM_Setup					; perform initial setup
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
; loc_16FDE:
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
		cmpi.b	#$C,1(a1)					; is it destruction time yet? - 8 frame rings. (Caverns4 / IkeyIlex)
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

; loc_170BA:
Touch_Rings:
		cmpi.b	#$5A,obInvuln(a0)			; does the player have three or more seconds of invulnerability left?
		bhs.w	Touch_Rings_Done			; if so, return
		movea.l	(v_ringstart_addr_ROM).w,a1
		movea.l	(v_ringend_addr_ROM).w,a2
		cmpa.l	a1,a2						; are there rings in this area?
		beq.w	Touch_Rings_Done			; if not, return
		movea.w	(v_ringstart_addr_RAM).w,a4

; Add Lightning Shield Attraction later

;Touch_Rings_NoAttraction:
		move.w	obX(a0),d2
		move.w	obY(a0),d3
		subi.w	#8,d2			; assume X radius to be 8
		moveq	#0,d5
		move.b	obHeight(a0),d5
		subq.b	#3,d5
		sub.w	d5,d3			; subtract (Y radius - 3) from Y pos
		cmpi.b	#$4D,obFrame(a0)
		bne.s	.TR_2			; if you're not ducking, branch
		addi.w	#$C,d3
		moveq	#$A,d5

.TR_2:
		move.w	#6,d1			; set ring radius
		move.w	#12,d6			; set ring diameter
		move.w	#16,d4			; set Sonic's X diameter
		add.w	d5,d5			; set Y diameter

; loc_17112:
Touch_Rings_Loop:
		tst.w	(a4)			; has this ring already been collided with?
		bne.w	Touch_NextRing	; if it has, branch
		move.w	(a1),d0			; get ring X pos
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
		move.w	2(a1),d0		; get ring Y pos
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
		move.w	#$608,(a4)		; set frame and destruction timer - $608 instead of $604 for 8-frame rings
		bsr.w	CollectRing
		lea		(v_ringconsumelist).w,a3

.loop:
		tst.w	(a3)+						; is this slot free?
		bne.s	.loop						; if not, repeat until you find one
		move.w	a4,-(a3)					; set ring address
		addq.w	#1,(v_ringconsumedata).w	; increase count

; loc_1715C:
Touch_NextRing:
		addq.w	#4,a1
		addq.w	#2,a4
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
		movea.l	(v_ringstart_addr_ROM).w,a0
		move.l	(v_ringend_addr_ROM).w,d7
		sub.l	a0,d7							; are there any rings on-screen?
		bne.s	.BR_2							; if there are, branch
		rts										; otherwise, return

.BR_2:
		movea.w	(v_ringstart_addr_RAM).w,a4		; load start address
		lea		(v_screenposx).w,a3				; load camera x position

; loc_1718A:
BuildRings_Loop:
		tst.w	(a4)+				; has this ring been consumed?
		bmi.w	BuildRings_NextRing	; if it has, branch
		move.w	(a0),d3				; get ring X pos
		sub.w	(a3),d3				; subtract camera X pos
		addi.w	#128,d3				; screen top is 128x128 not 0x0
		move.w	2(a0),d2			; get ring Y pos
		sub.w	4(a3),d2			; subtract camera Y pos
		andi.w	#$7FF,d2
		addi.w	#8,d2
		bmi.s	BuildRings_NextRing	; dunno how this check is supposed to work
		cmpi.w	#240,d2
		bge.s	BuildRings_NextRing	; if the ring is not on-screen, branch
		addi.w	#128-8,d2
		lea		(Map_RingBIN).l,a1
		moveq	#0,d1
		move.b	-1(a4),d1			; get ring frame
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
		addq.w	#4,a0
		subq.w	#4,d7
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
		move.w	#Rings_Space/4-1,d1		; Thank you ProjectFM

loc_31343C:					  ; Clear positions table
		move.l	d0,(a1)+
		dbf		d1,loc_31343C
	
	; d0 = 0
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
		move.l	a1,(v_ringstart_addr_ROM).w
		addq.w	#4,a1
		moveq	#0,d5
		move.w	#(Max_Rings-1),d0
.RMS_loop:
		tst.l	(a1)+
		bmi.s	.RMS_end
		addq.w	#1,d5
		dbf	d0,	.RMS_loop
.RMS_end:
		rts
; ===========================================================================
