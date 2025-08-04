; ---------------------------------------------------------------------------
; Subroutine to	move Sonic in demo mode
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


MoveSonicInDemo:
		tst.w	(f_demo).w					; is demo mode on?
		bne.s	MDemo_On					; if yes, branch
		rts	
; ===========================================================================

MDemo_On:
		tst.b	(v_jpadhold1).w				; is start button pressed?
		bpl.s	.dontquit					; if not, branch
		tst.w	(f_demo).w					; is this an ending sequence demo?
		bmi.s	.dontquit					; if yes, branch
		move.b	#id_Title,(v_gamemode).w	; go to title screen

.dontquit:
		moveq	#0,d0
		move.b	(v_zone).w,d0
		cmpi.b	#id_Special,(v_gamemode).w	; is this a special stage?
		bne.s	.notspecial					; if not, branch
		moveq	#6,d0						; use demo #6

.notspecial:
		add.w	d0,d0
		movea.w	DemoDataPtr(pc,d0.w),a1		; fetch address for demo data -- Filter Optimization
		tst.w	(f_demo).w					; is this an ending sequence demo?
		bpl.s	.notcredits					; if not, branch
		move.w	(v_creditsnum).w,d0
		subq.w	#1,d0
		add.w	d0,d0
		movea.w	DemoEndDataPtr(pc,d0.w),a1	; fetch address for credits demo data -- Filter Optimization

.notcredits:
		move.w	(v_btnpushtime1).w,d0
		adda.w	d0,a1
		move.b	(a1),d0
		lea		(v_jpadhold1).w,a0
		move.b	d0,d1
		move.b	-2(a0),d2					; FraGag Demo Playback Fix
		eor.b	d2,d0
		move.b	d1,(a0)+
		and.b	d1,d0
		move.b	d0,(a0)+
		subq.b	#1,(v_btnpushtime2).w
		bcc.s	.end
		move.b	3(a1),(v_btnpushtime2).w
		addq.w	#2,(v_btnpushtime1).w

.end:
		rts	
; End of function MoveSonicInDemo

; ===========================================================================
; ---------------------------------------------------------------------------
; Demo sequence	pointers
; ---------------------------------------------------------------------------
DemoDataPtr:
		dc.w Demo_GHZ		; demos run after the title screen
		dc.w Demo_GHZ
		dc.w Demo_MZ
		dc.w Demo_MZ
		dc.w Demo_SYZ
		dc.w Demo_SYZ
		dc.w Demo_SS
		dc.w Demo_SS

DemoEndDataPtr:
		dc.w Demo_EndGHZ1	; demos run during the credits
		dc.w Demo_EndMZ
		dc.w Demo_EndSYZ
		dc.w Demo_EndLZ
		dc.w Demo_EndSLZ
		dc.w Demo_EndSBZ1
		dc.w Demo_EndSBZ2
		dc.w Demo_EndGHZ2

		dc.b 0,	$8B, 8,	$37, 0,	$42, 8,	$5C, 0,	$6A, 8,	$5F, 0,	$2F, 8,	$2C
		dc.b 0,	$21, 8,	3, $28,	$30, 8,	8, 0, $2E, 8, $15, 0, $F, 8, $46
		dc.b 0,	$1A, 8,	$FF, 8,	$CA, 0,	0, 0, 0, 0, 0, 0, 0, 0,	0
		even
