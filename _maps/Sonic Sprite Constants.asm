; ---------------------------------------------------------------------------
; Sprite/Animation Constants for Sonic
; ---------------------------------------------------------------------------

; Sonic Animation IDs
	phase 0
aniID_Null:				ds.b 1		; Null animation
aniID_Walk:				ds.b 1		; Walking animation
aniID_Run:				ds.b 1		; Running animation
aniID_Dash:				ds.b 1		; Dashing animation (Peelout)
aniID_Roll:				ds.b 1		; Rolling animation
aniID_Roll2:			ds.b 1		; Faster rolling animation
aniID_Push:				ds.b 1		; Pushing animation
aniID_Wait:				ds.b 1		; Idle waiting animation
aniID_Balance:			ds.b 1		; Primary Balancing animation
aniID_Balance2:			ds.b 1		; Secondary Balancing animation
aniID_Balance3:			ds.b 1		; Tertiary Balancing Animation
aniID_LookUp:			ds.b 1		; Look Up animation
aniID_Duck:				ds.b 1		; Duck animation
aniID_SpinDash:			ds.b 1		; Spindash animation
aniID_Stop:				ds.b 1		; Stopping animation
aniID_Float1:			ds.b 1		; Floating animation #1
aniID_Float2:			ds.b 1		; Floating animation #2
aniID_Float3:			ds.b 1		; Floating animation #3
aniID_Float4:			ds.b 1		; Floating animation #4
aniID_Spring:			ds.b 1		; Spring animation
aniID_Hang:				ds.b 1		; Hanging animation (LZ Vertical Pole)
aniID_Fall:				ds.b 1		; Falling animation (Unused atm)
aniID_GetAir:			ds.b 1		; Getting Air Bubble animation
aniID_GetAirStand:		ds.b 1		; Getting Air Bubble while standing animation
aniID_Death:			ds.b 1		; Death animation
aniID_Drown:			ds.b 1		; Drown animation
aniID_Shrink:			ds.b 1		; Shrink animation
aniID_Hurt:				ds.b 1		; Hurt animation
aniID_WaterSlide:		ds.b 1		; Water Slide animation
aniID_Peelout:			ds.b 1		; Peelout
aniID_DropDash:			ds.b 1		; Drop Dash
aniID_Transform:		ds.b 1		; Transform
	dephase

; Mapping Frame IDs
	phase 0
fr_SonNull:				ds.b 1
fr_SonStand:			ds.b 1
fr_SonWait1:			ds.b 1
fr_SonWait2:			ds.b 1
fr_SonWait3:			ds.b 1
fr_SonLookUp1:			ds.b 1
fr_SonLookUp2:			ds.b 1
fr_SonWalk11:			ds.b 1
fr_SonWalk12:			ds.b 1
fr_SonWalk13:			ds.b 1
fr_SonWalk14:			ds.b 1
fr_SonWalk15:			ds.b 1
fr_SonWalk16:			ds.b 1
fr_SonWalk17:			ds.b 1
fr_SonWalk18:			ds.b 1
fr_SonWalk21:			ds.b 1
fr_SonWalk22:			ds.b 1
fr_SonWalk23:			ds.b 1
fr_SonWalk24:			ds.b 1
fr_SonWalk25:			ds.b 1
fr_SonWalk26:			ds.b 1
fr_SonWalk27:			ds.b 1
fr_SonWalk28:			ds.b 1
fr_SonWalk31:			ds.b 1
fr_SonWalk32:			ds.b 1
fr_SonWalk33:			ds.b 1
fr_SonWalk34:			ds.b 1
fr_SonWalk35:			ds.b 1
fr_SonWalk36:			ds.b 1
fr_SonWalk37:			ds.b 1
fr_SonWalk38:			ds.b 1
fr_SonWalk41:			ds.b 1
fr_SonWalk42:			ds.b 1
fr_SonWalk43:			ds.b 1
fr_SonWalk44:			ds.b 1
fr_SonWalk45:			ds.b 1
fr_SonWalk46:			ds.b 1
fr_SonWalk47:			ds.b 1
fr_SonWalk48:			ds.b 1
fr_SonRun11:			ds.b 1
fr_SonRun12:			ds.b 1
fr_SonRun13:			ds.b 1
fr_SonRun14:			ds.b 1
fr_SonRun21:			ds.b 1
fr_SonRun22:			ds.b 1
fr_SonRun23:			ds.b 1
fr_SonRun24:			ds.b 1
fr_SonRun31:			ds.b 1
fr_SonRun32:			ds.b 1
fr_SonRun33:			ds.b 1
fr_SonRun34:			ds.b 1
fr_SonRun41:			ds.b 1
fr_SonRun42:			ds.b 1
fr_SonRun43:			ds.b 1
fr_SonRun44:			ds.b 1
fr_SonRoll1:			ds.b 1
fr_SonRoll2:			ds.b 1
fr_SonRoll3:			ds.b 1
fr_SonRoll4:			ds.b 1
fr_SonRoll5:			ds.b 1
fr_SonSpindash1:		ds.b 1
fr_SonSpindash2:		ds.b 1
fr_SonSpindash3:		ds.b 1
fr_SonSpindash4:		ds.b 1
fr_SonSpindash5:		ds.b 1
fr_SonSpindash6:		ds.b 1
fr_SonStop1:			ds.b 1
fr_SonStop2:			ds.b 1
fr_SonDuck1:			ds.b 1
fr_SonDuck2:			ds.b 1
fr_SonBalance1:			ds.b 1
fr_SonBalance2:			ds.b 1
fr_SonBalanceForward1:	ds.b 1
fr_SonBalanceForward2:	ds.b 1
fr_SonBalanceForward3:	ds.b 1
fr_SonBalanceForward4:	ds.b 1
fr_SonBalanceBack1:		ds.b 1
fr_SonBalanceBack2:		ds.b 1
fr_SonBalanceBack3:		ds.b 1
fr_SonBalanceBack4:		ds.b 1
fr_SonFloat1:			ds.b 1
fr_SonFloat2:			ds.b 1
fr_SonFloat3:			ds.b 1
fr_SonFloat4:			ds.b 1
fr_SonFloat5:			ds.b 1
fr_SonFloat6:			ds.b 1
fr_SonSpring:			ds.b 1
fr_SonHang1:			ds.b 1
fr_SonHang2:			ds.b 1
fr_SonPush1:			ds.b 1
fr_SonPush2:			ds.b 1
fr_SonPush3:			ds.b 1
fr_SonPush4:			ds.b 1
fr_SonBubStand:			ds.b 1
fr_SonDeath:			ds.b 1
fr_SonDrown:			ds.b 1
fr_SonShrink1:			ds.b 1
fr_SonShrink2:			ds.b 1
fr_SonShrink3:			ds.b 1
fr_SonShrink4:			ds.b 1
fr_SonShrink5:			ds.b 1
fr_SonHurt:				ds.b 1
fr_SonGetAir:			ds.b 1
fr_SonWaterSlide:		ds.b 1
fr_SonDash11:			ds.b 1
fr_SonDash12:			ds.b 1
fr_SonDash13:			ds.b 1
fr_SonDash14:			ds.b 1
fr_SonDash21:			ds.b 1
fr_SonDash22:			ds.b 1
fr_SonDash23:			ds.b 1
fr_SonDash24:			ds.b 1
fr_SonDash31:			ds.b 1
fr_SonDash32:			ds.b 1
fr_SonDash33:			ds.b 1
fr_SonDash34:			ds.b 1
fr_SonDash41:			ds.b 1
fr_SonDash42:			ds.b 1
fr_SonDash43:			ds.b 1
fr_SonDash44:			ds.b 1
fr_SonDropDash1:		ds.b 1
fr_SonDropDash2:		ds.b 1
fr_SonDropDash3:		ds.b 1
fr_SonDropDash4:		ds.b 1
fr_SonDropDash5:		ds.b 1
fr_SonDropDash6:		ds.b 1
fr_SonDropDash7:		ds.b 1
fr_SonDropDash8:		ds.b 1
fr_SonTransform1:		ds.b 1
fr_SonTransform2:		ds.b 1
fr_SonTransform3:		ds.b 1
fr_SonTransform4:		ds.b 1
fr_SonTransform5:		ds.b 1
	dephase
