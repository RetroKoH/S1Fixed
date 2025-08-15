; ---------------------------------------------------------------------------
; Animation script - Sonic
; ---------------------------------------------------------------------------
Ani_SuperSonic:
		dc.w SonAni_Null-Ani_SuperSonic
		dc.w SupSonAni_Walk-Ani_SuperSonic
		dc.w SupSonAni_Run-Ani_SuperSonic
		dc.w SupSonAni_Run-Ani_SuperSonic		; Dash
		dc.w SupSonAni_Roll-Ani_SuperSonic
		dc.w SupSonAni_Roll2-Ani_SuperSonic
		dc.w SupSonAni_Push-Ani_SuperSonic
		dc.w SupSonAni_Wait-Ani_SuperSonic
		dc.w SupSonAni_Balance-Ani_SuperSonic
		dc.w SupSonAni_Balance-Ani_SuperSonic
		dc.w SupSonAni_Balance-Ani_SuperSonic
		dc.w SupSonAni_LookUp-Ani_SuperSonic
		dc.w SupSonAni_Duck-Ani_SuperSonic
		dc.w SupSonAni_Spindash-Ani_SuperSonic
		dc.w SupSonAni_Stop-Ani_SuperSonic
		dc.w SupSonAni_Float1-Ani_SuperSonic
		dc.w SupSonAni_Float2-Ani_SuperSonic
		dc.w SupSonAni_Float3-Ani_SuperSonic
		dc.w SupSonAni_Float4-Ani_SuperSonic
		dc.w SupSonAni_Spring-Ani_SuperSonic
		dc.w SupSonAni_Hang-Ani_SuperSonic
		dc.w SonAni_Null-Ani_SuperSonic
		dc.w SupSonAni_GetAir-Ani_SuperSonic
		dc.w SupSonAni_GetAir-Ani_SuperSonic	; Get Air Standing
		dc.w SupSonAni_Death-Ani_SuperSonic
		dc.w SupSonAni_Drown-Ani_SuperSonic
		dc.w SonAni_Null-Ani_SuperSonic			; Shrink
		dc.w SupSonAni_Hurt-Ani_SuperSonic
		dc.w SupSonAni_WaterSlide-Ani_SuperSonic
		dc.w SonAni_Null-Ani_SuperSonic			; Victory Leap
		dc.w SupSonAni_Peelout-Ani_SuperSonic
		dc.w SupSonAni_DropDash-Ani_SuperSonic
		dc.w SupSonAni_Transform-Ani_SuperSonic

SupSonAni_Walk:
		dc.b	$FF, fr_SupSonWalk14, fr_SupSonWalk15, fr_SupSonWalk16, fr_SupSonWalk17, fr_SupSonWalk18, fr_SupSonWalk11, fr_SupSonWalk12, fr_SupSonWalk13, afEnd
		even
SupSonAni_Run:
		dc.b	$FF, fr_SupSonRun11, fr_SupSonRun12, fr_SupSonRun13, fr_SupSonRun14, afEnd, afEnd, afEnd, afEnd, afEnd
		even
SupSonAni_Roll:
		dc.b	$FE, fr_SupSonRoll1, fr_SupSonRoll2, fr_SupSonRoll3, fr_SupSonRoll4, fr_SupSonRoll5, afEnd, afEnd
		even
SupSonAni_Roll2:
		dc.b	$FE, fr_SupSonRoll1, fr_SupSonRoll2, fr_SupSonRoll5, fr_SupSonRoll3, fr_SupSonRoll4, fr_SupSonRoll5, afEnd
		even
SupSonAni_Push:
		dc.b	$FD, fr_SupSonPush1, fr_SupSonPush2, fr_SupSonPush3, fr_SupSonPush4, afEnd, afEnd, afEnd, afEnd, afEnd
		even
SupSonAni_Wait:
		dc.b	7, fr_SupSonStand1, fr_SupSonStand2, fr_SupSonStand3, fr_SupSonStand2, afEnd
		even
SupSonAni_Balance:
		dc.b	9, fr_SupSonBalance1, fr_SupSonBalance2, fr_SupSonBalance3, fr_SupSonBalance4, afEnd
		even
SupSonAni_LookUp:
		dc.b	1, fr_SupSonLookUp1, fr_SupSonLookUp2, fr_SupSonLookUp2, fr_SupSonLookUp2, fr_SupSonLookUp2
		dc.b	fr_SupSonLookUp3, fr_SupSonLookUp3, fr_SupSonLookUp3, fr_SupSonLookUp3
		dc.b	fr_SupSonLookUp4, fr_SupSonLookUp4, fr_SupSonLookUp4, fr_SupSonLookUp4
		dc.b	fr_SupSonLookUp3, fr_SupSonLookUp3, fr_SupSonLookUp3, fr_SupSonLookUp3, afBack, 16
		even
SupSonAni_Duck:
		dc.b	1, fr_SupSonDuck1
		dc.b	fr_SupSonDuck2, fr_SupSonDuck2, fr_SupSonDuck2, fr_SupSonDuck2
		dc.b	fr_SupSonDuck3, fr_SupSonDuck3, fr_SupSonDuck3, fr_SupSonDuck3
		dc.b	fr_SupSonDuck4, fr_SupSonDuck4, fr_SupSonDuck4, fr_SupSonDuck4
		dc.b	fr_SupSonDuck3, fr_SupSonDuck3, fr_SupSonDuck3, fr_SupSonDuck3, afBack, 16
		even
SupSonAni_Spindash:
		dc.b	0, fr_SupSonSpindash1, fr_SupSonSpindash2, fr_SupSonSpindash1, fr_SupSonSpindash3, fr_SupSonSpindash1, fr_SupSonSpindash4, fr_SupSonSpindash1, fr_SupSonSpindash5, fr_SupSonSpindash1, fr_SupSonSpindash6, afEnd
		even
SupSonAni_Stop:
		dc.b	5, fr_SupSonStop1, fr_SupSonStop2, fr_SupSonStop1, fr_SupSonStop2, afChange, aniID_Walk
		even
SupSonAni_Float1:
		dc.b	7, fr_SupSonFloat1, fr_SupSonFloat4, afEnd
		even
SupSonAni_Float2:
		dc.b	7, fr_SupSonFloat1, fr_SupSonFloat2, fr_SupSonFloat5, fr_SupSonFloat3, fr_SupSonFloat6, afEnd
		even
SupSonAni_Float3:
		dc.b	3, fr_SupSonFloat1, fr_SupSonFloat2, fr_SupSonFloat5, fr_SupSonFloat3, fr_SupSonFloat6, afEnd
		even
SupSonAni_Float4:
		dc.b	3, fr_SupSonFloat1, afChange, aniID_Walk
		even
SupSonAni_Spring:
		dc.b	3, fr_SupSonSpring1, fr_SupSonSpring2, fr_SupSonSpring1, fr_SupSonSpring2
		dc.b	fr_SupSonSpring1, fr_SupSonSpring2, fr_SupSonSpring1, fr_SupSonSpring2
		dc.b	fr_SupSonSpring1, fr_SupSonSpring2, fr_SupSonSpring1, fr_SupSonSpring2, afChange, aniID_Walk
		even
SupSonAni_Hang:
		dc.b	4, fr_SupSonHang1, fr_SupSonHang2, afEnd
		even
SupSonAni_GetAir:
		dc.b	$B, fr_SupSonGetAir, fr_SupSonGetAir, fr_SupSonWalk15, fr_SupSonWalk16, afChange, aniID_Walk
		even
SupSonAni_Death:
		dc.b	3, fr_SupSonDeath, afEnd
		even
SupSonAni_Drown:
		dc.b	$2F, fr_SupSonDrown, afEnd
		even
SupSonAni_Hurt:
		dc.b	3, fr_SupSonHurt, afEnd
		even
SupSonAni_WaterSlide:
		dc.b	7, fr_SupSonHurt, fr_SupSonWaterSlide, afEnd
		even
SupSonAni_Peelout:
		dc.b	0, fr_SupSonWalk14, fr_SupSonWalk14, fr_SupSonWalk14, fr_SupSonWalk14, fr_SupSonWalk14, fr_SupSonWalk14, fr_SupSonWalk14, fr_SupSonWalk14
		dc.b	fr_SupSonWalk15, fr_SupSonWalk15, fr_SupSonWalk15, fr_SupSonWalk15, fr_SupSonWalk16, fr_SupSonWalk16, fr_SupSonWalk17, fr_SupSonWalk17
		dc.b	fr_SupSonRun11, fr_SupSonRun12, fr_SupSonRun13, fr_SupSonRun14, fr_SupSonRun11, fr_SupSonRun12, fr_SupSonRun13, fr_SupSonRun14
		dc.b	fr_SupSonRun11, fr_SupSonRun12, fr_SupSonRun13, fr_SupSonRun14, afBack, 4
		even
SupSonAni_DropDash:
		dc.b	$0, fr_SupSonDropDash1, fr_SupSonRoll5, fr_SupSonDropDash2, fr_SupSonRoll5, fr_SupSonDropDash3, fr_SupSonRoll5, fr_SupSonDropDash4, fr_SupSonRoll5
		dc.b	fr_SupSonDropDash5, fr_SupSonRoll5, fr_SupSonDropDash6, fr_SupSonRoll5, fr_SupSonDropDash7, fr_SupSonRoll5, fr_SupSonDropDash8, fr_SupSonRoll5, afEnd
		even
SupSonAni_Transform:
		dc.b	2, fr_SupSonTransform1, fr_SupSonTransform1, fr_SupSonTransform2, fr_SupSonTransform2, fr_SupSonTransform3, fr_SupSonTransform4, fr_SupSonTransform5, fr_SupSonTransform4, fr_SupSonTransform5, fr_SupSonTransform4, fr_SupSonTransform5, fr_SupSonTransform4, fr_SupSonTransform5, afChange, aniID_Walk
		even