; ---------------------------------------------------------------------------
; Object 49 - waterfall	sound effect (GHZ)
; ---------------------------------------------------------------------------

WaterSound:
		_move.l	#WSnd_PlaySnd,obAddr(a0)
		move.b	#4,obRender(a0)			; is this line necessary?
; ---------------------------------------------------------------------------

WSnd_PlaySnd:
		move.b	(v_vbla_byte).w,d0		; get low byte of VBlank counter
		andi.b	#$3F,d0					; read bits 0-5
		bne.s	.skip_sfx				; branch if not 0
		move.w	#sfx_Waterfall,d0
		jsr		(QueueSound2).w			; play waterfall sound (every 64 frames)
; ---------------------------------------------------------------------------

	.skip_sfx:
		offscreen.w	DeleteObject		; ProjectFM S3K Objects Manager
		rts
; ===========================================================================