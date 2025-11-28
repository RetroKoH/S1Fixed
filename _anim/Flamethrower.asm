; ---------------------------------------------------------------------------
; Animation script - flamethrower (SBZ)
; ---------------------------------------------------------------------------
Ani_Flame:
		dc.w .pipe1-Ani_Flame
		dc.w .pipe2-Ani_Flame
		dc.w .valve1-Ani_Flame
		dc.w .valve2-Ani_Flame

.pipe1:		dc.b 3,	0, 1, 2, 3, 4, 5, 6, 7,	8, 9, $A, afBack, 2
		even

.pipe2:		dc.b 0,	9, 7, 5, 3, 1, 0, afRoutine
		even

.valve1:	dc.b 3,	$B, $C,	$D, $E,	$F, $10, $11, $12, $13,	$14, $15, afBack, 2
		even

.valve2:	dc.b 0,	$14, $12, $11, $F, $D, $B, afRoutine
		even
