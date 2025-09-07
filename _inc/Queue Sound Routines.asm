; ---------------------------------------------------------------------------
; Subroutine to queue a sound into buffer 1, often used for BGM
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

PlaySound:
QueueSound1:
		move.b	d0,(v_snddriver_ram.v_soundqueue0).w	; d0 = sound to play
		rts
; End of function QueueSound1

; ---------------------------------------------------------------------------
; Subroutine to queue a sound into buffer 2, often used for SFX
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

PlaySound_Special:
QueueSound2:
		move.b	d0,(v_snddriver_ram.v_soundqueue1).w	; d0 = sound to play
		rts	
; End of function QueueSound2

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to queue a sound into buffer 3, unused (and broken?).
; ---------------------------------------------------------------------------

PlaySound_Unused:
QueueSound3:
		move.b	d0,(v_snddriver_ram.v_soundqueue2).w	; d0 = sound to play
		rts
; End of function QueueSound3

; ===========================================================================