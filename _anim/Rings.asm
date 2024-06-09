; ---------------------------------------------------------------------------
; Animation script - ring
; (Animation is actually for the sparkle, not the ring itself)
; RetroKoH 8-Frame Rings Change
; ---------------------------------------------------------------------------
Ani_Ring:	dc.w .ring-Ani_Ring
.ring:		dc.b 5,	8, 9, $A, $B, afRoutine
		even