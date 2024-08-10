; ---------------------------------------------------------------------------
; Animation script - Orbinaut enemy
; ---------------------------------------------------------------------------
Ani_Orb:
		dc.w .normal-Ani_Orb
		dc.w .angers-Ani_Orb

.normal:	dc.b $F, 0, afEnd
		even

	if OrbinautAnimationTweak=1	; Mercury Orbinaut Animation Tweak
.angers:	dc.b OrbinautAnimationTweakSpeed, 1, 2, afBack, 1
	else
.angers:	dc.b $F, 1, 2, afBack, 1
	endif	; Orbinaut Animation Tweak End
		even