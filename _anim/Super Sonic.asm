; ---------------------------------------------------------------------------
; Animation script - Sonic
; ---------------------------------------------------------------------------
Ani_SuperSonic:
		dc.w SonAni_Null-Ani_SuperSonic
		dc.w SupSonAni_Walk-Ani_SuperSonic
		dc.w SupSonAni_Run-Ani_SuperSonic
		dc.w SupSonAni_Run-Ani_SuperSonic		; Dash
		dc.w SonAni_Roll-Ani_SuperSonic
		dc.w SonAni_Roll2-Ani_SuperSonic
		dc.w SupSonAni_Push-Ani_SuperSonic
		dc.w SupSonAni_Wait-Ani_SuperSonic
		dc.w SupSonAni_Balance-Ani_SuperSonic
		dc.w SupSonAni_Balance-Ani_SuperSonic
		dc.w SupSonAni_Balance-Ani_SuperSonic
		dc.w SonAni_LookUp-Ani_SuperSonic
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
		dc.w SonAni_Shrink-Ani_SuperSonic
		dc.w SupSonAni_Hurt-Ani_SuperSonic
		dc.w SupSonAni_WaterSlide-Ani_SuperSonic
		dc.w SupSonAni_Peelout-Ani_SuperSonic
		dc.w SupSonAni_DropDash-Ani_SuperSonic
		dc.w SupSonAni_Transform-Ani_SuperSonic

SupSonAni_Walk: dc.b $FF, $A, $B, $C, $D, $E, 7, 8, 9, afEnd
		even
SupSonAni_Run: dc.b $FF, $27, $27, $28, $28, $29, $29, $2A, $2A, afEnd
		even
SupSonAni_Push: dc.b $FD, $4E, $4F, $50, $51, afEnd, afEnd, afEnd, afEnd, afEnd
		even
SupSonAni_Wait:	dc.b 7, $67, $68, $69, $68, afEnd
		even
SupSonAni_Balance: dc.b 9, $6B, $6C, $6B, $6D, $6B, $6E, afEnd
		even
SupSonAni_Duck:	dc.b $3F, $6A, $6A, afEnd, 0
		even
SupSonAni_Spindash:
		dc.b 0, $61, $62, $61, $63, $61, $64, $61, $65, $61, $66, afEnd
		even
SupSonAni_Stop:	dc.b 5,	$40, $41, $40, $41, afChange, aniID_Walk
		even
SupSonAni_Float1:	dc.b 7,	$45, $48, afEnd
		even
SupSonAni_Float2:	dc.b 7,	$45, $46, $5C, $47, $5D, afEnd
		even
SupSonAni_Float3:	dc.b 3,	$45, $46, $5C, $47, $5D, afEnd
		even
SupSonAni_Float4:	dc.b 3,	$45, afChange, aniID_Walk
		even
SupSonAni_Spring: dc.b $2F, $49, afChange, aniID_Walk
		even
SupSonAni_Hang:	dc.b 4,	$4A, $4B, afEnd
		even
SupSonAni_GetAir: dc.b $B, $5F, $5F, $B, $C, afChange, aniID_Walk
		even
SupSonAni_Death: dc.b 3, $56, afEnd
		even
SupSonAni_Drown: dc.b $2F, $55, afEnd
		even
SupSonAni_Hurt:	dc.b 3,	$5E, afEnd
		even
SupSonAni_WaterSlide:
		dc.b 7, $5E, $60, afEnd
		even
SupSonAni_Peelout:
		dc.b	0, $A, $A, $A, $A, $A, $A, $A, $A
		dc.b	$B, $B, $B, $B, $C, $C, $2A, $2A
		dc.b	$27, $28, $29, $2A, $27, $28, $29, $2A
		dc.b	$27, $28, $29, $2A, afBack, 4
		even
SupSonAni_DropDash:	dc.b $0, $77, fr_SonRoll5, $78, fr_SonRoll5, $79, fr_SonRoll5, $7A, fr_SonRoll5
		dc.b	$7B, fr_SonRoll5, $7C, fr_SonRoll5, $7D, fr_SonRoll5, $7E, fr_SonRoll5, afEnd
		even
SupSonAni_Transform:
		dc.b	2, $6F, $6F, $70, $70, $71, $72, $73, $72, $73, $72, $73, $72, $73, afChange, aniID_Walk
		even