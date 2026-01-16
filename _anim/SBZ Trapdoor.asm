; ---------------------------------------------------------------------------
; Animation script - trapdoor (SBZ)
; ---------------------------------------------------------------------------
Ani_Trap:
		dc.w .trapopen-Ani_Trap
		dc.w .trapclose-Ani_Trap

.trapopen:	dc.b 3,	0, 1, 2, afBack, 1
.trapclose:	dc.b 3,	2, 1, 0, afBack, 1
		even