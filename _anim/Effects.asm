; ---------------------------------------------------------------------------
; Animation script - Graphic Effects: Spindash dust, skid dust, drop dash dust
; ---------------------------------------------------------------------------
Ani_Effects:
		dc.w	.null-Ani_Effects
		dc.w	.dash-Ani_Effects
		dc.w	.skid-Ani_Effects
		dc.w	.drop-Ani_Effects

.null:		dc.b $1F,  0, afEnd
.dash:		dc.b 1, 1, 2, 3, 4, 5, 6, 7, afEnd
.skid:		dc.b 3, 8, 9, $A, $B, afRoutine
.drop:		dc.b 1, $C, $D, $E, $F, $10, $11, $12, $13, afRoutine
;.splash:	dc.b 4,	0, 1, 2, afRoutine			; Will migrate this over later

		even
