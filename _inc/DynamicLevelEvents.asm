; ---------------------------------------------------------------------------
; Dynamic level events
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


DynamicLevelEvents:
	; Mercury Exit DLE In Special Stage And Title
		cmpi.b	#id_Title,(v_gamemode).w	; exit if on the Title Screen
		beq.s	DLE_NoChg
		cmpi.b	#id_Special,(v_gamemode).w	; exit if in a Special Stage
		beq.s	DLE_NoChg
	; Exit DLE In Special Stage And Title end

	; Filter Optimized DLE Manager
		move.w	(v_zone).w,d0
		ror.b	#2,d0 ; lsl.b	#6,d0 > Filter Optimized Shifting
		lsr.w	#5,d0
	; Optimized DLE Manager End
		move.w	DLE_Index(pc,d0.w),d0
		jsr		DLE_Index(pc,d0.w) ; run level-specific events
		moveq	#2,d1
		move.w	(v_limitbtm1).w,d0
		sub.w	(v_limitbtm2).w,d0 ; has lower level boundary changed recently?
		beq.s	DLE_NoChg	; if not, branch
		bcc.s	loc_6DAC

		neg.w	d1
		move.w	(v_screenposy).w,d0
		cmp.w	(v_limitbtm1).w,d0
		bls.s	loc_6DA0
		move.w	d0,(v_limitbtm2).w
		andi.w	#$FFFE,(v_limitbtm2).w

loc_6DA0:
		add.w	d1,(v_limitbtm2).w
		move.b	#1,(f_bgscrollvert).w

DLE_NoChg:
		rts	
; ===========================================================================

loc_6DAC:
		move.w	(v_screenposy).w,d0
		addq.w	#8,d0
		cmp.w	(v_limitbtm2).w,d0
		blo.s	loc_6DC4
		btst	#staAir,(v_player+obStatus).w
		beq.s	loc_6DC4
		add.w	d1,d1
		add.w	d1,d1

loc_6DC4:
		add.w	d1,(v_limitbtm2).w
		move.b	#1,(f_bgscrollvert).w
		rts	
; End of function DynamicLevelEvents

; ===========================================================================

; ---------------------------------------------------------------------------
; Offset index for dynamic level events -- Filter Optimized DLE Manager
; ---------------------------------------------------------------------------
; ===========================================================================
DLE_Index:	offsetTable
		offsetTableEntry.w DLE_GHZ1
		offsetTableEntry.w DLE_GHZ2
		offsetTableEntry.w DLE_GHZ3
		offsetTableEntry.w DLE_GHZ1

		offsetTableEntry.w DLE_LZ12
		offsetTableEntry.w DLE_LZ12
		offsetTableEntry.w DLE_LZ3
		offsetTableEntry.w DLE_SBZ3

		offsetTableEntry.w DLE_MZ1
		offsetTableEntry.w DLE_MZ2
		offsetTableEntry.w DLE_MZ3
		offsetTableEntry.w DLE_MZ1

		offsetTableEntry.w DLE_SLZ12
		offsetTableEntry.w DLE_SLZ12
		offsetTableEntry.w DLE_SLZ3
		offsetTableEntry.w DLE_SLZ12

		offsetTableEntry.w DLE_SYZ1
		offsetTableEntry.w DLE_SYZ2
		offsetTableEntry.w DLE_SYZ3
		offsetTableEntry.w DLE_SYZ1

		offsetTableEntry.w DLE_SBZ1
		offsetTableEntry.w DLE_SBZ2
		offsetTableEntry.w DLE_FZ
		offsetTableEntry.w DLE_SBZ1

		offsetTableEntry.w DLE_Ending
		offsetTableEntry.w DLE_Ending
		offsetTableEntry.w DLE_Ending
		offsetTableEntry.w DLE_Ending
; ===========================================================================

; ---------------------------------------------------------------------------
; Green	Hill Zone dynamic level events
; ---------------------------------------------------------------------------

DLE_GHZ1:
		move.w	#$300,(v_limitbtm1).w ; set lower y-boundary
		cmpi.w	#$1780,(v_screenposx).w ; has the camera reached $1780 on x-axis?
		blo.s	.ret	; if not, branch
		move.w	#$400,(v_limitbtm1).w ; set lower y-boundary

	.ret:
DLE_LZ12:
DLE_SLZ12:
DLE_SYZ1:
DLE_Ending:
		rts	
; ===========================================================================

DLE_GHZ2:
		move.w	#$300,(v_limitbtm1).w
		cmpi.w	#$ED0,(v_screenposx).w
		blo.s	.ret
		move.w	#$200,(v_limitbtm1).w
		cmpi.w	#$1600,(v_screenposx).w
		blo.s	.ret
		move.w	#$400,(v_limitbtm1).w
		cmpi.w	#$1D60,(v_screenposx).w
		blo.s	.ret
		move.w	#$300,(v_limitbtm1).w

.ret:
		rts	
; ===========================================================================

	; RetroKoH Routine Optimization
DLE_GHZ3:
		move.w	(v_dle_routine).w,d0	; Now word-length so we don't need to clear d0 -- Filter Optimized DLE Manager
		jmp		GHZ3_Index(pc,d0.w)
; ===========================================================================
GHZ3_Index:
		bra.s	DLE_GHZ3main
		bra.s	DLE_GHZ3boss
		;bra.s	DLE_GHZ3end
; ===========================================================================
	; Routine Optimization End

DLE_GHZ3end:
		move.w	(v_screenposx).w,(v_limitleft2).w
		rts	
; ===========================================================================

DLE_GHZ3main:
		move.w	#$300,(v_limitbtm1).w
		cmpi.w	#$380,(v_screenposx).w
		blo.s	locret_6E96
		move.w	#$310,(v_limitbtm1).w
		cmpi.w	#$960,(v_screenposx).w
		blo.s	locret_6E96
		cmpi.w	#$280,(v_screenposy).w
		blo.s	loc_6E98
		move.w	#$400,(v_limitbtm1).w
		cmpi.w	#$1380,(v_screenposx).w
		bhs.s	loc_6E8E
		move.w	#$4C0,(v_limitbtm1).w
		move.w	#$4C0,(v_limitbtm2).w

loc_6E8E:
		cmpi.w	#$1700,(v_screenposx).w
		bhs.s	loc_6E98

locret_6E96:
		rts	
; ===========================================================================

loc_6E98:
		move.w	#boss_ghz_y,(v_limitbtm1).w
		addq.w	#2,(v_dle_routine).w	; Now word-length so we don't need to clear d0 -- Filter Optimized DLE Manager
		rts	
; ===========================================================================

DLE_GHZ3boss:
		cmpi.w	#$960,(v_screenposx).w
		bhs.s	loc_6EB0
		subq.w	#2,(v_dle_routine).w	; Now word-length so we don't need to clear d0 -- Filter Optimized DLE Manager

loc_6EB0:
		cmpi.w	#boss_ghz_x,(v_screenposx).w
		blo.s	locret_6E96
		bsr.w	FindFreeObj
		bne.s	loc_6ED0
		_move.b	#id_BossGreenHill,obID(a1) ; load GHZ boss	object
		move.w	#boss_ghz_x+$100,obX(a1)
		move.w	#boss_ghz_y-$80,obY(a1)

loc_6ED0:
		move.w	#bgm_Boss,d0
		bsr.w	PlaySound				; play boss music
		move.b	d0,(v_lastbgmplayed).w	; store last played music
		move.b	#1,(f_lockscreen).w		; lock screen
		addq.w	#2,(v_dle_routine).w	; Now word-length so we don't need to clear d0 -- Filter Optimized DLE Manager
		moveq	#plcid_Boss_GHZ,d0		; RetroKoH VRAM Overhaul
		bra.w	AddPLC					; load boss patterns
; ===========================================================================

; ---------------------------------------------------------------------------
; Labyrinth Zone dynamic level events
; ---------------------------------------------------------------------------

DLE_LZ3:
		tst.b	(f_switch+$F).w				; has switch $F	been pressed? (At the start, next to the endless slide)
		beq.s	loc_6F28					; if not, branch
		lea		(v_lvllayout+$50C).w,a1
		cmpi.w	#$1718,(a1)
		beq.s	loc_6F28
		move.w	#$1718,(a1)					; modify level layout to open a path out of the endless slide
		move.w	#sfx_Rumbling,d0
		bsr.w	PlaySound_Special			; play rumbling sound

loc_6F28:
	; New DLE by RetroKoH to seal off the boss area near the fight
		tst.b	(f_switch+8).w				; has switch 8 been triggered? (At the start, next to the endless slide)
		bne.s	DLE_LZ3_BossChk				; if yes, branch
		cmpi.w	#$1BE8,(v_screenposx).w
		blo.s	locret_6F8C
		cmpi.w	#$598,(v_screenposy).w
		bhs.s	locret_6F8C
		move.b	#1,(f_switch+8).w			; trigger the door
		move.w	#sfx_Rumbling,d0
		bsr.w	PlaySound_Special			; play rumbling sound

DLE_LZ3_BossChk:
		tst.w	(v_dle_routine).w			; Now word-length so we don't need to clear d0 -- Filter Optimized DLE Manager
		bne.s	locret_6F8C
		cmpi.w	#boss_lz_x-$140,(v_screenposx).w
		blo.s	locret_6F8C
		cmpi.w	#boss_lz_y+$540,(v_screenposy).w
		bhs.s	locret_6F8C
		bsr.w	FindFreeObj
		bne.s	loc_6F4A
		_move.b	#id_BossLabyrinth,obID(a1)	; load LZ boss object

loc_6F4A:
		move.w	#bgm_Boss,d0
		bsr.w	PlaySound					; play boss music
		move.b	d0,(v_lastbgmplayed).w		; store last played music
		move.b	#1,(f_lockscreen).w			; lock screen
		addq.w	#2,(v_dle_routine).w		; Now word-length so we don't need to clear d0 -- Filter Optimized DLE Manager
		moveq	#plcid_Boss,d0
		bra.w	AddPLC						; load boss patterns
; ===========================================================================

DLE_SBZ3:
; Would this warrant a music fade mod???
		cmpi.w	#$D00,(v_screenposx).w
		blo.s	locret_6F8C
		cmpi.w	#$18,(v_player+obY).w		; has Sonic reached the top of the level?
		bhs.s	locret_6F8C					; if not, branch
		clr.b	(v_lastlamp).w
		move.b	#1,(f_restart).w			; restart level
		move.w	#(id_SBZ<<8)+2,(v_zone).w	; set level number to 0502 (FZ)
		move.b	#1,(v_player+obCtrlLock).w	; lock controls
		; Clear Super Sonic?

locret_6F8C:
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Marble Zone dynamic level events
; ---------------------------------------------------------------------------

	; RetroKoH Routine Optimization
DLE_MZ1:
		move.w	(v_dle_routine).w,d0		; Now word-length so we don't need to clear d0 -- Filter Optimized DLE Manager
		jmp		MZ1_Index(pc,d0.w)
; ===========================================================================
MZ1_Index:
		bra.s loc_6FBA
		bra.s loc_6FEA
		bra.s loc_702E
		bra.w loc_7050
; ===========================================================================
	; Routine Optimization End

loc_6FBA:
		move.w	#$1D0,(v_limitbtm1).w
		cmpi.w	#$700,(v_screenposx).w
		blo.s	locret_6FE8
		move.w	#$220,(v_limitbtm1).w
		cmpi.w	#$D00,(v_screenposx).w
		blo.s	locret_6FE8
		move.w	#$340,(v_limitbtm1).w
		cmpi.w	#$340,(v_screenposy).w
		blo.s	locret_6FE8
		addq.w	#2,(v_dle_routine).w		; Now word-length so we don't need to clear d0 -- Filter Optimized DLE Manager

locret_6FE8:
		rts	
; ===========================================================================

loc_6FEA:
		cmpi.w	#$340,(v_screenposy).w
		bhs.s	loc_6FF8
		subq.w	#2,(v_dle_routine).w		; Now word-length so we don't need to clear d0 -- Filter Optimized DLE Manager
		rts	
; ===========================================================================

loc_6FF8:
		clr.w	(v_limittop2).w
		cmpi.w	#$E00,(v_screenposx).w
		bhs.s	locret_702C
		move.w	#$340,(v_limittop2).w
		move.w	#$340,(v_limitbtm1).w
		cmpi.w	#$A90,(v_screenposx).w
		bhs.s	locret_702C
		move.w	#$500,(v_limitbtm1).w
		cmpi.w	#$370,(v_screenposy).w
		blo.s	locret_702C
		addq.w	#2,(v_dle_routine).w		; Now word-length so we don't need to clear d0 -- Filter Optimized DLE Manager

locret_702C:
		rts	
; ===========================================================================

loc_702E:
		cmpi.w	#$370,(v_screenposy).w
		bhs.s	loc_703C
		subq.w	#2,(v_dle_routine).w		; Now word-length so we don't need to clear d0 -- Filter Optimized DLE Manager
		rts	
; ===========================================================================

loc_703C:
		cmpi.w	#$500,(v_screenposy).w
		blo.s	locret_704E
		cmpi.w	#$B80,(v_screenposx).w
		bcs.s	locret_704E
		move.w	#$500,(v_limittop2).w
		addq.w	#2,(v_dle_routine).w		; Now word-length so we don't need to clear d0 -- Filter Optimized DLE Manager

locret_704E:
		rts	
; ===========================================================================

loc_7050:
		cmpi.w	#$B80,(v_screenposx).w
		bcc.s	locj_76B8
		cmpi.w	#$340,(v_limittop2).w
		beq.s	locret_7072
		subq.w	#2,(v_limittop2).w
		rts

locj_76B8:
		cmpi.w	#$500,(v_limittop2).w
		beq.s	locj_76CE
		cmpi.w	#$500,(v_screenposy).w
		bcs.s	locret_7072
		move.w	#$500,(v_limittop2).w

locj_76CE:
		cmpi.w	#$E70,(v_screenposx).w
		blo.s	locret_7072
		clr.w	(v_limittop2).w
		move.w	#$500,(v_limitbtm1).w
		cmpi.w	#$1430,(v_screenposx).w
		blo.s	locret_7072
		move.w	#$210,(v_limitbtm1).w

locret_7072:
		rts	
; ===========================================================================

DLE_MZ2:
		move.w	#$520,(v_limitbtm1).w
		cmpi.w	#$1700,(v_screenposx).w
		blo.s	locret_7088
		move.w	#$200,(v_limitbtm1).w

locret_7088:
		rts	
; ===========================================================================

DLE_MZ3:
	; Lavagaming/RetroKoH Optimized Routine Handling
		tst.w	(v_dle_routine).w		; Now word-length so we don't need to clear d0 -- Filter Optimized DLE Manager
		beq.s	DLE_MZ3boss
	; Optimized Routine Handling End

;DLE_MZ3end:
		move.w	(v_screenposx).w,(v_limitleft2).w
locret_70E8:
		rts

DLE_MZ3boss:
		move.w	#$720,(v_limitbtm1).w
		cmpi.w	#boss_mz_x-$2A0,(v_screenposx).w
		blo.s	locret_70E8
		move.w	#boss_mz_y,(v_limitbtm1).w
		cmpi.w	#boss_mz_x-$10,(v_screenposx).w
		blo.s	locret_70E8
		bsr.w	FindFreeObj
		bne.s	loc_70D0
		_move.b	#id_BossMarble,obID(a1) ; load MZ boss object
		move.w	#boss_mz_x+$1F0,obX(a1)
		move.w	#boss_mz_y+$1C,obY(a1)

loc_70D0:
		move.w	#bgm_Boss,d0
		bsr.w	PlaySound				; play boss music
		move.b	d0,(v_lastbgmplayed).w	; store last played music
		move.b	#1,(f_lockscreen).w		; lock screen
		addq.w	#2,(v_dle_routine).w	; Now word-length so we don't need to clear d0 -- Filter Optimized DLE Manager
		moveq	#plcid_Boss_MZ,d0		; RetroKoH VRAM Overhaul
		bra.w	AddPLC					; load boss patterns
; ===========================================================================

; ---------------------------------------------------------------------------
; Star Light Zone dynamic level events
; ---------------------------------------------------------------------------

DLE_SLZ3:
	; RetroKoH Optimized Routine Handling
		move.w	(v_dle_routine).w,d0	; Now word-length so we don't need to clear d0 -- Filter Optimized DLE Manager
		jmp		SLZ3_Index(pc,d0.w)
; ===========================================================================
SLZ3_Index:
		bra.s	DLE_SLZ3main
		bra.s	DLE_SLZ3boss
		bra.s	DLE_SLZ3end
; ===========================================================================
	; Optimized Routine Handling End

DLE_SLZ3main:
		cmpi.w	#boss_slz_x-$190,(v_screenposx).w
		blo.s	locret_7130
		move.w	#boss_slz_y,(v_limitbtm1).w
		addq.w	#2,(v_dle_routine).w	; Now word-length so we don't need to clear d0 -- Filter Optimized DLE Manager

locret_7130:
		rts	
; ===========================================================================

DLE_SLZ3boss:
		cmpi.w	#boss_slz_x,(v_screenposx).w
		blo.s	locret_7130
		bsr.w	FindFreeObj
		bne.s	loc_7144
		move.b	#id_BossStarLight,obID(a1) ; load SLZ boss object

loc_7144:
		move.w	#bgm_Boss,d0
		bsr.w	PlaySound				; play boss music
		move.b	d0,(v_lastbgmplayed).w	; store last played music
		move.b	#1,(f_lockscreen).w		; lock screen
		addq.w	#2,(v_dle_routine).w	; Now word-length so we don't need to clear d0 -- Filter Optimized DLE Manager
		moveq	#plcid_Boss_SLZ,d0		; RetroKoH VRAM Overhaul
		bra.w	AddPLC					; load boss patterns
; ===========================================================================

DLE_SLZ3end:
		move.w	(v_screenposx).w,(v_limitleft2).w
		rts
; ===========================================================================
; ---------------------------------------------------------------------------
; Spring Yard Zone dynamic level events
; ---------------------------------------------------------------------------

DLE_SYZ2:
		move.w	#$520,(v_limitbtm1).w
		cmpi.w	#$25A0,(v_screenposx).w
		blo.s	locret_71A2
		move.w	#$420,(v_limitbtm1).w
		cmpi.w	#$4D0,(v_player+obY).w
		blo.s	locret_71A2
		move.w	#$520,(v_limitbtm1).w

locret_71A2:
		rts	
; ===========================================================================

DLE_SYZ3:
	; RetroKoH Optimized Routine Handling
		move.w	(v_dle_routine).w,d0	; Now word-length so we don't need to clear d0 -- Filter Optimized DLE Manager
		jmp		SYZ3_Index(pc,d0.w)
; ===========================================================================

SYZ3_Index:
		bra.s	DLE_SYZ3main
		bra.s	DLE_SYZ3boss
		bra.s	DLE_SYZ3end
; ===========================================================================
	; Optimized Routine Handling End

DLE_SYZ3main:
		cmpi.w	#boss_syz_x-$140,(v_screenposx).w
		blo.s	locret_71CE
		bsr.w	FindFreeObj
		bne.s	locret_71CE
		move.b	#id_BossBlock,obID(a1)	; load blocks that boss picks up
		addq.w	#2,(v_dle_routine).w	; Now word-length so we don't need to clear d0 -- Filter Optimized DLE Manager

locret_71CE:
		rts	
; ===========================================================================

DLE_SYZ3boss:
		cmpi.w	#boss_syz_x,(v_screenposx).w
		blo.s	locret_7200
		move.w	#boss_syz_y,(v_limitbtm1).w
		bsr.w	FindFreeObj
		bne.s	loc_71EC
		move.b	#id_BossSpringYard,obID(a1)	; load SYZ boss object
		addq.w	#2,(v_dle_routine).w		; Now word-length so we don't need to clear d0 -- Filter Optimized DLE Manager

loc_71EC:
		move.w	#bgm_Boss,d0
		bsr.w	PlaySound				; play boss music
		move.b	d0,(v_lastbgmplayed).w	; store last played music
		move.b	#1,(f_lockscreen).w		; lock screen
		moveq	#plcid_Boss_SYZ,d0		; RetroKoH VRAM Overhaul
		bra.w	AddPLC					; load boss patterns
; ===========================================================================

DLE_SYZ3end:
		move.w	(v_screenposx).w,(v_limitleft2).w
locret_7200:
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Scrap	Brain Zone dynamic level events
; ---------------------------------------------------------------------------

DLE_SBZ1:
		move.w	#$720,(v_limitbtm1).w
		cmpi.w	#$1880,(v_screenposx).w
		blo.s	locret_7242
		move.w	#$620,(v_limitbtm1).w
		cmpi.w	#$2000,(v_screenposx).w
		blo.s	locret_7242
		move.w	#$2A0,(v_limitbtm1).w

locret_7242:
		rts	
; ===========================================================================

DLE_SBZ2:
		move.w	(v_dle_routine).w,d0	; Now word-length so we don't need to clear d0 -- Filter Optimized DLE Manager
		move.w	SBZ2_Index(pc,d0.w),d0
		jmp		SBZ2_Index(pc,d0.w)
; ===========================================================================
SBZ2_Index:		offsetTable
		offsetTableEntry.w DLE_SBZ2main
		offsetTableEntry.w DLE_SBZ2boss
		offsetTableEntry.w DLE_SBZ2boss2
		offsetTableEntry.w DLE_SBZ2end
; ===========================================================================

DLE_SBZ2main:
		move.w	#$800,(v_limitbtm1).w
		cmpi.w	#$1800,(v_screenposx).w
		blo.s	locret_727A
		move.w	#boss_sbz2_y,(v_limitbtm1).w
		cmpi.w	#$1E00,(v_screenposx).w
		blo.s	locret_727A
		addq.w	#2,(v_dle_routine).w	; Now word-length so we don't need to clear d0 -- Filter Optimized DLE Manager

locret_727A:
		rts	
; ===========================================================================

DLE_SBZ2boss:
		cmpi.w	#boss_sbz2_x-$1A0,(v_screenposx).w
		blo.s	locret_7298
		bsr.w	FindFreeObj
		bne.s	locret_7298
		move.b	#id_FalseFloor,obID(a1) ; load collapsing block object
		addq.w	#2,(v_dle_routine).w	; Now word-length so we don't need to clear d0 -- Filter Optimized DLE Manager
		moveq	#plcid_EggmanSBZ2,d0
		bra.w	AddPLC					; load SBZ2 Eggman patterns
; ===========================================================================

locret_7298:
		rts	
; ===========================================================================

DLE_SBZ2boss2:
		cmpi.w	#boss_sbz2_x-$F0,(v_screenposx).w
		blo.s	loc_72C2
		bsr.w	FindFreeObj
		bne.s	loc_72B0
		move.b	#id_ScrapEggman,obID(a1)	; load SBZ2 Eggman object
		addq.w	#2,(v_dle_routine).w		; Now word-length so we don't need to clear d0 -- Filter Optimized DLE Manager

loc_72B0:
		move.b	#1,(f_lockscreen).w			; lock screen
		bra.s	loc_72C2
; ===========================================================================

DLE_SBZ2end:
		cmpi.w	#boss_sbz2_x,(v_screenposx).w
		blo.s	loc_72C2
		rts	
; ===========================================================================

loc_72C2:
		move.w	(v_screenposx).w,(v_limitleft2).w
		rts	
; ===========================================================================

DLE_FZ:
		move.w	(v_dle_routine).w,d0		; Now word-length so we don't need to clear d0 -- Filter Optimized DLE Manager
		move.w	FZ_Index(pc,d0.w),d0
		jmp		FZ_Index(pc,d0.w)
; ===========================================================================
FZ_Index:		offsetTable
		offsetTableEntry.w DLE_FZmain
		offsetTableEntry.w DLE_FZboss
		offsetTableEntry.w DLE_FZend
		offsetTableEntry.w locret_7322
		offsetTableEntry.w loc_72C2		; DLE_FZend2
; ===========================================================================

DLE_FZmain:
		cmpi.w	#boss_fz_x-$308,(v_screenposx).w
		blo.s	loc_72C2
		addq.w	#2,(v_dle_routine).w		; Now word-length so we don't need to clear d0 -- Filter Optimized DLE Manager
		moveq	#plcid_FZBoss,d0
		bsr.w	AddPLC						; load FZ boss patterns
		bra.s	loc_72C2
; ===========================================================================

DLE_FZboss:
		cmpi.w	#boss_fz_x-$150,(v_screenposx).w
		blo.s	loc_72C2
		bsr.w	FindFreeObj
		bne.s	loc_72C2
		move.b	#id_BossFinal,obID(a1)	; load FZ boss object
		addq.w	#2,(v_dle_routine).w	; Now word-length so we don't need to clear d0 -- Filter Optimized DLE Manager
		move.b	#1,(f_lockscreen).w		; lock screen
		bra.s	loc_72C2
; ===========================================================================

DLE_FZend:
		cmpi.w	#boss_fz_x,(v_screenposx).w
		blo.s	loc_72C2
		addq.w	#2,(v_dle_routine).w	; Now word-length so we don't need to clear d0 -- Filter Optimized DLE Manager
		bra.s	loc_72C2
; ===========================================================================

locret_7322:
		rts	
; ===========================================================================
