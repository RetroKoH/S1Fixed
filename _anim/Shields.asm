; ---------------------------------------------------------------------------
; Animation script - shields
; ---------------------------------------------------------------------------
Ani_Shield:
ptr_ShiAni_Blue:		dc.w shield-Ani_Shield

	if InstashieldEnabled
ptr_ShiAni_Insta:		dc.w insta1-Ani_Shield
ptr_ShiAni_InstaActive:	dc.w insta2-Ani_Shield
	endif
	
	if ShieldsMode
ptr_ShiAni_Flame:		dc.w flame1-Ani_Shield
ptr_ShiAni_FlameDash:	dc.w flame2-Ani_Shield
ptr_ShiAni_Bubble:		dc.w bubble1-Ani_Shield
ptr_ShiAni_BubbleDown:	dc.w bubble2-Ani_Shield
ptr_ShiAni_BubbleUp:	dc.w bubble3-Ani_Shield
ptr_ShiAni_Lightning:	dc.w lightning1-Ani_Shield
ptr_ShiAni_Lightning2:	dc.w lightning2-Ani_Shield
ptr_ShiAni_Lightning3:	dc.w lightning3-Ani_Shield
	endif


shield:			dc.b 1,	1, 0, 2, 0, 3, 0, afEnd


	if InstashieldEnabled
insta1:			dc.b  $1F,   6,	afEnd

insta2:			dc.b	0,   0,	  1,   2,   3,	 4,   5,   6,	6,   6,	  6,   6,   6,	 6,   7, afChange, aniID_InstaIdle
	endif

	if ShieldsMode
flame1:			dc.b 1, 0, $F, 1, $10, 2, $11, 3, $12, 4, $13, 5, $14, 6, $15, 7, $16, 8, $17, afEnd

flame2:			dc.b 1, 9, $A, $B, $C, $D, $E, 9, $A, $B, $C, $D, $E, afChange, aniID_FlameShield

bubble1:		dc.b    1,   0,   9,   0,   9,   0,   9,   1,  $A,   1,  $A,   1,  $A,   2,   9,   2,   9,   2,   9,   3
				dc.b   $A,   3,  $A,   3,  $A,   4,   9,   4,   9,   4,   9,   5,  $A,   5,  $A,   5,  $A,   6,   9,   6
				dc.b    9,   6,   9,   7,  $A,   7,  $A,   7,  $A,   8,   9,   8,   9,   8,   9, afEnd

bubble2:		dc.b	5,   9,	 $B,  $B,  $B, afChange, aniID_BubbleShield

bubble3:		dc.b	5,  $C,	 $C,  $B, afChange, aniID_BubbleShield, 0

lightning1:		dc.b    1,   0,   0,   1,   1,   2,   2,   3,   3,   4,   4,   5,   5,   6,   6,   7,   7,   8,   8,   9
				dc.b   $A,  $B, $16, $16, $15, $15, $14, $14, $13, $13, $12, $12
				dc.b  $11, $11,	$10, $10,  $F,	$F,  $E,  $E,	9,  $A,	 $B, afEnd

lightning2:		dc.b    0,  $C,  $D, $17,  $C,  $D, $17,  $C,  $D, $17,  $C,  $D, $17,  $C,  $D, $17,  $C,  $D, $17,  $C
				dc.b   $D, afRoutine, -1

lightning3:		dc.b	3,   0,	  1,   2, afRoutine, -1,   0
	endif

		even

aniID_BlueShield:		equ	(ptr_ShiAni_Blue-Ani_Shield)/2			; 0

	if InstashieldEnabled
aniID_InstaIdle:		equ	(ptr_ShiAni_Insta-Ani_Shield)/2			; 1 - Set by default for Sonic
aniID_InstaActive:		equ	(ptr_ShiAni_InstaActive-Ani_Shield)/2	; 2 - Triggered by Sonic_JumpHeight
	endif

	if ShieldsMode
aniID_FlameShield:		equ	(ptr_ShiAni_Flame-Ani_Shield)/2			; 3 - Standard animation for Flame Shield
aniID_FlameDash:		equ	(ptr_ShiAni_FlameDash-Ani_Shield)/2		; 4 - Used by Sonic_JumpHeight when activating double jump
aniID_BubbleShield:		equ	(ptr_ShiAni_Bubble-Ani_Shield)/2		; 5 - Standard animation for Bubble Shield
aniID_BubbleBounce:		equ	(ptr_ShiAni_BubbleDown-Ani_Shield)/2	; 6 - Used by Sonic_JumpHeight when going downward for the bounce
aniID_BubbleBounceUp:	equ	(ptr_ShiAni_BubbleUp-Ani_Shield)/2		; 7 - Used by Sonic_ResetOnFloor when bouncing up
aniID_LightningShield:	equ	(ptr_ShiAni_Lightning-Ani_Shield)/2		; 8 - Standard animation for Lightning Shield
aniID_LightningSpark:	equ	(ptr_ShiAni_Lightning2-Ani_Shield)/2	; 9 - Used by Sonic_JumpHeight when jumping up, and used by sparks
aniID_LightningStars:	equ	(ptr_ShiAni_Lightning3-Ani_Shield)/2	; $A - Apparently used for Super Sonic Stars
	endif
