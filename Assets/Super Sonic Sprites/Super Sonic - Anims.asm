; ---------------------------------------------------------------------------
; Animation script - Super Sonic
; Only contains data for non-duplicate animations
; ---------------------------------------------------------------------------
Ani_SuperSonic:
		dc.w SonAni_Null-Ani_SuperSonic
		dc.w SupSonAni_Walk-Ani_SuperSonic
		dc.w SupSonAni_Run-Ani_SuperSonic
		dc.w SupSonAni_Run-Ani_SuperSonic ; DASH (Unused in Super)
		dc.w SonAni_Roll-Ani_SuperSonic
		dc.w SonAni_Roll2-Ani_SuperSonic
		dc.w SonAni_Push-Ani_SuperSonic
		dc.w SupSonAni_Wait-Ani_SuperSonic
		dc.w SonAni_Balance-Ani_SuperSonic
		dc.w SonAni_BalanceForward-Ani_SuperSonic
		dc.w SonAni_BalanceBack-Ani_SuperSonic
		dc.w SupSonAni_LookUp-Ani_SuperSonic
		dc.w SupSonAni_Duck-Ani_SuperSonic
		dc.w SonAni_Spindash-Ani_SuperSonic
		dc.w SonAni_Stop-Ani_SuperSonic
		dc.w SonAni_Float1-Ani_SuperSonic
		dc.w SonAni_Float2-Ani_SuperSonic
		dc.w SonAni_Float3-Ani_SuperSonic
		dc.w SonAni_Float4-Ani_SuperSonic
		dc.w SonAni_Spring-Ani_SuperSonic
		dc.w SonAni_Hang-Ani_SuperSonic
		dc.w SonAni_Null-Ani_SuperSonic ; FALL
		dc.w SonAni_GetAir-Ani_SuperSonic
		dc.w SonAni_GetAirStand-Ani_SuperSonic
		dc.w SonAni_Death-Ani_SuperSonic
		dc.w SonAni_Drown-Ani_SuperSonic
		dc.w SonAni_Shrink-Ani_SuperSonic
		dc.w SonAni_Hurt-Ani_SuperSonic
		dc.w SonAni_WaterSlide-Ani_SuperSonic
		dc.w SonAni_Peelout-Ani_SuperSonic
		dc.w SonAni_DropDash-Ani_SuperSonic
		dc.w SonAni_Null-Ani_SuperSonic

SupSonAni_Walk:	dc.b $FF, $B, $C, $D, $E, $F, 8, 9, $A, afEnd
		even

SupSonAni_Run:	dc.b $FF, $B, $C, $D, $E, $F, 8, 9, $A, afEnd
		even

SupSonAni_Wait:	dc.b 9, 1, 2, 3, 2, afEnd
		even

SupSonAni_LookUp:	dc.b 1, 4, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 6, 6, 6, 6, 6, afBack, 20
		even

SupSonAni_Duck:	dc.b 1, $10, $11, $11, $11, $11, $11, $12, $12, $12, $12, $12, $13, $13, $13, $13, $13, $12, $12, $12, $12, $12, afBack, 20
		even


; For now, this is a duplicate of non-Super's animation.
SupSonAni_Transform:	dc.b 2, fr_SonTransform1, fr_SonTransform1, fr_SonTransform2, fr_SonTransform2, fr_SonTransform3
						dc.b fr_SonTransform4, fr_SonTransform5, fr_SonTransform4, fr_SonTransform5, fr_SonTransform4
						dc.b fr_SonTransform5, fr_SonTransform4, fr_SonTransform5, $FD,  aniID_Walk
		even