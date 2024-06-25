; ---------------------------------------------------------------------------
; Sonic	when he	gets hurt
; ---------------------------------------------------------------------------

Sonic_Hurt:	; Routine 4
	; RetroKoH Debug Mode Addition
		tst.w	(f_debugmode).w			; is debug cheat enabled?
		beq.s	Sonic_Hurt_Normal		; if not, branch
		btst	#bitB,(v_jpadpress1).w	; is button B pressed?
		beq.s	Sonic_Hurt_Normal		; if not, branch
		move.w	#1,(v_debuguse).w		; change Sonic into a ring/item
		clr.b	(f_lockctrl).w
		rts

Sonic_Hurt_Normal:
	; Debug Mode Addition End
	if SpinDashEnabled=1
		clr.b	(v_cameralag).w			; Spin Dash Enabled
	endif
		jsr		(SpeedToPos).l
		addi.w	#$30,obVelY(a0)
		btst	#staWater,obStatus(a0)
		beq.s	loc_1380C
		subi.w	#$20,obVelY(a0)

loc_1380C:
		bsr.w	Sonic_HurtStop
		bsr.w	Sonic_LevelBound
		bsr.w	Sonic_RecordPosition
		bsr.w	Sonic_Water				; Mercury Hurt Splash Fix
		bsr.w	Sonic_Animate
		bsr.w	Sonic_LoadGfx
		jmp		(DisplaySprite).l

; ---------------------------------------------------------------------------
; Subroutine to	stop Sonic falling after he's been hurt
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Sonic_HurtStop:
		; Lines omitted -- Mercury Top Boundary Fix
		bsr.w	Sonic_Floor
		btst	#staAir,obStatus(a0)
		bne.s	locret_13860
		clr.w	obVelY(a0)
		clr.w	obVelX(a0)
		clr.w	obInertia(a0)
		move.b	#aniID_Walk,obAnim(a0)
		subq.b	#2,obRoutine(a0)
		move.b	#$78,obInvuln(a0)	; RetroKoH Sonic SST Compaction

locret_13860:
		rts	
; End of function Sonic_HurtStop

; ---------------------------------------------------------------------------
; Sonic	when he	dies
; ---------------------------------------------------------------------------

Sonic_Death:	; Routine 6
	; RetroKoH Debug Mode Addition
		tst.w	(f_debugmode).w			; is debug cheat enabled?
		beq.s	Sonic_Death_Normal		; if not, branch
		btst	#bitB,(v_jpadpress1).w	; is button B pressed?
		beq.s	Sonic_Death_Normal		; if not, branch
		move.w	#1,(v_debuguse).w		; change Sonic into a ring/item
		clr.b	(f_lockctrl).w
		rts

Sonic_Death_Normal:
	; Debug Mode Addition End
	if SpinDashEnabled=1
		clr.b	(v_cameralag).w			; Spin Dash Enabled
	endif
		bsr.w	GameOver
		jsr		(ObjectFall).l
		bsr.w	Sonic_RecordPosition
		bsr.w	Sonic_Animate
		bsr.w	Sonic_LoadGfx
		jmp		(DisplaySprite).l

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


GameOver:
		move.w	(v_screenposy).w,d0	; MarkeyJester Game/Time Over Timing Fix
		addi.w	#$100,d0
		cmp.w	obY(a0),d0
		bge.w	locret_13900		; MarkeyJester Game/Time Over Timing Fix
		move.w	#-$38,obVelY(a0)
		addq.b	#2,obRoutine(a0)
		clr.b	(f_timecount).w		; stop time counter

	; Mercury Lives Over/Underflow Fix
		tst.b	(v_lives).w			; are lives at 0?
		beq.s	.skip
		addq.b	#1,(f_lifecount).w	; update lives counter
		subq.b	#1,(v_lives).w		; subtract 1 from number of lives
		bne.s	loc_138D4
.skip:
	; Lives Over/Underflow Fix End

		clr.w	objoff_3A(a0)
		move.b	#id_GameOverCard,(v_gameovertext1).w ; load GAME object
		move.b	#id_GameOverCard,(v_gameovertext2).w ; load OVER object
		move.b	#1,(v_gameovertext2+obFrame).w ; set OVER object to correct frame
		clr.b	(f_timeover).w

loc_138C2:
		move.w	#bgm_GameOver,d0
		jsr	(PlaySound).l	; play game over music
		moveq	#3,d0
		jmp	(AddPLC).l	; load game over patterns
; ===========================================================================

loc_138D4:
		move.w	#60,objoff_3A(a0)	; set time delay to 1 second
		tst.b	(f_timeover).w	; is TIME OVER tag set?
		beq.s	locret_13900	; if not, branch
		clr.w	objoff_3A(a0)
		move.b	#id_GameOverCard,(v_gameovertext1).w ; load TIME object
		move.b	#id_GameOverCard,(v_gameovertext2).w ; load OVER object
		move.b	#2,(v_gameovertext1+obFrame).w
		move.b	#3,(v_gameovertext2+obFrame).w
		bra.s	loc_138C2
; ===========================================================================

locret_13900:
		rts	
; End of function GameOver

; ---------------------------------------------------------------------------
; Sonic	when the level is restarted
; ---------------------------------------------------------------------------

Sonic_ResetLevel:; Routine 8
		tst.w	objoff_3A(a0)
		beq.s	locret_13914
		subq.w	#1,objoff_3A(a0)	; subtract 1 from time delay
		bne.s	locret_13914
		move.w	#1,(f_restart).w ; restart the level

locret_13914:
		rts

; ---------------------------------------------------------------------------
; Sonic when he's drowning -- RHS Drowning Fix
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Sonic_Drowned:
	; RetroKoH Debug Mode Addition
		tst.w	(f_debugmode).w			; is debug cheat enabled?
		beq.s	Sonic_Drowned_Normal	; if not, branch
		btst	#bitB,(v_jpadpress1).w	; is button B pressed?
		beq.s	Sonic_Drowned_Normal	; if not, branch
		move.w	#1,(v_debuguse).w		; change Sonic into a ring/item
		clr.b	(f_lockctrl).w
		clr.b	(f_nobgscroll).w  		; unlock the screen to reacquire control
		movea.l	a0,a1
		bra.w	ResumeMusic

Sonic_Drowned_Normal:
	; Debug Mode Addition End
		bsr.w	SpeedToPos				; Make Sonic able to move
		addi.w	#$10,obVelY(a0)			; Apply gravity
		bsr.w	Sonic_RecordPosition	; Record position
		bsr.s	Sonic_Animate			; Animate Sonic
		bsr.w	Sonic_LoadGfx			; Load Sonic's DPLCs
		bra.w	DisplaySprite			; And finally, display Sonic
