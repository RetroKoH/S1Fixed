; ---------------------------------------------------------------------------
; Animation script - Sonic
; ---------------------------------------------------------------------------
Ani_Sonic:
		dc.w SonAni_Null-Ani_Sonic
		dc.w SonAni_Walk-Ani_Sonic
		dc.w SonAni_Run-Ani_Sonic
		dc.w SonAni_Dash-Ani_Sonic
		dc.w SonAni_Roll-Ani_Sonic
		dc.w SonAni_Roll2-Ani_Sonic
		dc.w SonAni_Push-Ani_Sonic
		dc.w SonAni_Wait-Ani_Sonic
		dc.w SonAni_Balance-Ani_Sonic
		dc.w SonAni_BalanceForward-Ani_Sonic
		dc.w SonAni_BalanceBack-Ani_Sonic
		dc.w SonAni_LookUp-Ani_Sonic
		dc.w SonAni_Duck-Ani_Sonic
		dc.w SonAni_Spindash-Ani_Sonic
		dc.w SonAni_Stop-Ani_Sonic
		dc.w SonAni_Float1-Ani_Sonic
		dc.w SonAni_Float2-Ani_Sonic
		dc.w SonAni_Float3-Ani_Sonic
		dc.w SonAni_Float4-Ani_Sonic
		dc.w SonAni_Spring-Ani_Sonic
		dc.w SonAni_Hang-Ani_Sonic
		dc.w SonAni_Null-Ani_Sonic ; FALL
		dc.w SonAni_GetAir-Ani_Sonic
		dc.w SonAni_GetAirStand-Ani_Sonic
		dc.w SonAni_Death-Ani_Sonic
		dc.w SonAni_Drown-Ani_Sonic
		dc.w SonAni_Shrink-Ani_Sonic
		dc.w SonAni_Hurt-Ani_Sonic
		dc.w SonAni_WaterSlide-Ani_Sonic
		dc.w SonAni_Transform-Ani_Sonic
		dc.w SonAni_Peelout-Ani_Sonic

SonAni_Null:	dc.b $77, fr_SonNull, afChange, aniID_Walk
		even
SonAni_Walk:	dc.b $FF, fr_SonWalk13, fr_SonWalk14, fr_SonWalk15, fr_SonWalk16, fr_SonWalk11, fr_SonWalk12, afEnd
		even
SonAni_Run:	dc.b $FF,  fr_SonRun11, fr_SonRun12, fr_SonRun13, fr_SonRun14, afEnd, afEnd, afEnd
		even
SonAni_Dash:	dc.b $FF,  fr_SonDash11, fr_SonDash12, fr_SonDash13, fr_SonDash14, afEnd, afEnd, afEnd
		even
SonAni_Roll:	dc.b $FE,  fr_SonRoll1, fr_SonRoll2, fr_SonRoll3, fr_SonRoll4, fr_SonRoll5, afEnd, afEnd
		even
SonAni_Roll2:	dc.b $FE,  fr_SonRoll1, fr_SonRoll2, fr_SonRoll5, fr_SonRoll3, fr_SonRoll4, fr_SonRoll5, afEnd
		even
SonAni_Push:	dc.b $FD,  fr_SonPush1, fr_SonPush2, fr_SonPush3, fr_SonPush4, afEnd, afEnd, afEnd
		even
SonAni_Wait:	dc.b $17, fr_SonStand, fr_SonStand, fr_SonStand, fr_SonStand, fr_SonStand, fr_SonStand, fr_SonStand, fr_SonStand, fr_SonStand
		dc.b fr_SonStand, fr_SonStand, fr_SonStand, fr_SonWait2, fr_SonWait1, fr_SonWait1, fr_SonWait1, fr_SonWait2, fr_SonWait3, afBack, 2
		even
SonAni_Balance:	dc.b $1F, fr_SonBalance1, fr_SonBalance2, afEnd
		even
SonAni_BalanceForward: dc.b $F, fr_SonBalanceForward1, fr_SonBalanceForward2, fr_SonBalanceForward3, fr_SonBalanceForward4, afEnd
		even
SonAni_BalanceBack: dc.b $F, fr_SonBalanceBack1, fr_SonBalanceBack2, fr_SonBalanceBack3,fr_SonBalanceBack4, afEnd
		even
SonAni_LookUp:	dc.b 1, fr_SonLookUp1, fr_SonLookUp2, afBack, 1
		even
SonAni_Duck:	dc.b 1, fr_SonDuck1, fr_SonDuck2, afBack, 1
		even
SonAni_Spindash: dc.b 0, fr_SonSpindash1, fr_SonSpindash2, fr_SonSpindash1, fr_SonSpindash3, fr_SonSpindash1, fr_SonSpindash4
		dc.b fr_SonSpindash1, fr_SonSpindash5, fr_SonSpindash1, fr_SonSpindash6, afEnd
		even
SonAni_Stop:	dc.b 7,	fr_SonStop1, fr_SonStop2, afEnd
		even
SonAni_Float1:	dc.b 7,	fr_SonFloat1, fr_SonFloat4, afEnd
		even
SonAni_Float2:	dc.b 7,	fr_SonFloat1, fr_SonFloat2, fr_SonFloat5, fr_SonFloat3, fr_SonFloat6, afEnd
		even
SonAni_Float3:	dc.b 3,	fr_SonFloat1, fr_SonFloat2, fr_SonFloat5, fr_SonFloat3, fr_SonFloat6, afEnd
		even
SonAni_Float4:	dc.b 3,	fr_SonFloat1, afChange, aniID_Walk
		even
SonAni_Spring:	dc.b $2F, fr_SonSpring, afChange, aniID_Walk
		even
SonAni_Hang:	dc.b 4,	fr_SonHang1, fr_SonHang2, afEnd
		even
SonAni_GetAir:	dc.b $B, fr_SonGetAir, fr_SonGetAir, fr_SonWalk15, fr_SonWalk16, afChange, aniID_Walk
		even
SonAni_GetAirStand: dc.b $B, fr_SonBubStand, fr_SonBubStand, fr_SonBubStand, afEnd
		even
SonAni_Death:	dc.b 3,	fr_SonDeath, afEnd
		even
SonAni_Drown:	dc.b $2F, fr_SonDrown, afEnd
		even
SonAni_Shrink:	dc.b 3,	fr_SonShrink1, fr_SonShrink2, fr_SonShrink3, fr_SonShrink4, fr_SonShrink5, fr_SonNull, afBack, 1
		even
SonAni_Hurt:	dc.b 3,	fr_SonHurt, afEnd
		even
SonAni_WaterSlide: dc.b 7, fr_SonHurt, fr_SonWaterSlide, afEnd
		even
SonAni_Transform:	dc.b 2, fr_SonTransform1, fr_SonTransform1, fr_SonTransform2, fr_SonTransform2, fr_SonTransform3
					dc.b fr_SonTransform4, fr_SonTransform5, fr_SonTransform4, fr_SonTransform5, fr_SonTransform4
					dc.b fr_SonTransform5, fr_SonTransform4, fr_SonTransform5, $FD,  aniID_Walk
		even
SonAni_Peelout:	dc.b 0,  fr_SonWalk13, fr_SonWalk13, fr_SonWalk13, fr_SonWalk13, fr_SonWalk13, fr_SonWalk13, fr_SonWalk13, fr_SonWalk13
		dc.b	fr_SonWalk14, fr_SonWalk14, fr_SonWalk14, fr_SonWalk14, fr_SonWalk15, fr_SonWalk15, fr_SonRun14, fr_SonRun14
		dc.b	fr_SonRun11,  fr_SonRun12,  fr_SonRun13,  fr_SonRun14, fr_SonRun11,  fr_SonRun12,  fr_SonRun13,  fr_SonRun14
		dc.b	fr_SonDash11,  fr_SonDash12,  fr_SonDash13,  fr_SonDash14, afBack, 4
		even

;Ani_SuperSonic:
;		dc.w SonAni_Null-Ani_Sonic
;		dc.w SonAni_Walk-Ani_Sonic
;		dc.w SonAni_Run-Ani_Sonic
;		dc.w SonAni_Dash-Ani_Sonic
;		dc.w SonAni_Roll-Ani_Sonic
;		dc.w SonAni_Roll2-Ani_Sonic
;		dc.w SonAni_Push-Ani_Sonic
;		dc.w SonAni_Wait-Ani_Sonic
;		dc.w SonAni_Balance-Ani_Sonic
;		dc.w SonAni_BalanceForward-Ani_Sonic
;		dc.w SonAni_BalanceBack-Ani_Sonic
;		dc.w SonAni_LookUp-Ani_Sonic
;		dc.w SonAni_Duck-Ani_Sonic
;		dc.w SonAni_Spindash-Ani_Sonic
;		dc.w SonAni_Stop-Ani_Sonic
;		dc.w SonAni_Float1-Ani_Sonic
;		dc.w SonAni_Float2-Ani_Sonic
;		dc.w SonAni_Float3-Ani_Sonic
;		dc.w SonAni_Float4-Ani_Sonic
;		dc.w SonAni_Spring-Ani_Sonic
;		dc.w SonAni_Hang-Ani_Sonic
;		dc.w SonAni_Null-Ani_Sonic ; FALL
;		dc.w SonAni_GetAir-Ani_Sonic
;		dc.w SonAni_GetAirStand-Ani_Sonic
;		dc.w SonAni_Death-Ani_Sonic
;		dc.w SonAni_Drown-Ani_Sonic
;		dc.w SonAni_Shrink-Ani_Sonic
;		dc.w SonAni_Hurt-Ani_Sonic
;		dc.w SonAni_WaterSlide-Ani_Sonic
;		dc.w SupSonAni_Transform-Ani_SuperSonic
;		dc.w SonAni_Peelout-Ani_Sonic

;SupSonAni_Transform:	dc.b   2,$6D,$6D,$6E,$6E,$6F,$70,$71,$70,$71,$70,$71,$70,$71,$FD,  0