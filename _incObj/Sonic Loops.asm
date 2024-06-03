; ---------------------------------------------------------------------------
; Subroutine to	make Sonic run around loops (GHZ/SLZ)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Loops:
	; The name's a misnomer: loops are no longer handled here, only the windtunnels. Loops are dealt with by pathswappers
	;	cmpi.b	#id_SLZ,(v_zone).w ; is level SLZ ?	; MJ: Commented out, we don't want SLZ having any rolling chunks =P
	;	beq.s	.isstarlight	; if yes, branch
		tst.b	(v_zone).w	; is level GHZ ?
		bne.w	.noloops	; if not, branch

;.isstarlight:
		move.w	obY(a0),d0		; MJ: Load Y position
		move.w	obX(a0),d1		; MJ: Load X position
		andi.w	#$780,d0		; MJ: keep Y position within 800 pixels (in multiples of 80)
		add.w	d0,d0			; MJ: multiply by 2 (Because every 80 bytes switch from FG to BG..)
		lsr.w	#7,d1			; MJ: divide X position by 80 (00 = 0, 80 = 1, etc)
		andi.w	#$7F,d1			; MJ: keep within 4000 pixels (4000 / 80 = 80)
		add.w	d1,d0			; MJ: add together
		lea	(v_lvllayout).w,a1	; MJ: Load address of layout
		move.b	(a1,d0.w),d1		; MJ: collect correct 128x128 chunk ID based on the position of Sonic

		lea	STunnel_Chunks_End(pc),a2			; MJ: lead list of S-Tunnel chunks
		moveq	#(STunnel_Chunks_End-STunnel_Chunks)-1,d2	; MJ: get size of list

.loop:
		cmp.b	-(a2),d1	; MJ: is the chunk an S-Tunnel chunk?
		dbeq	d2,.loop	; MJ: check for each listed S-Tunnel chunk
		beq.w	Sonic_ChkRoll	; MJ: if so, branch

.noloops:
		rts	
; End of function Sonic_Loops

; ===========================================================================
STunnel_Chunks:		; MJ: list of S-Tunnel chunks
		dc.b	$75,$76,$77,$78
		dc.b	$79,$7A,$7B,$7C
STunnel_Chunks_End
