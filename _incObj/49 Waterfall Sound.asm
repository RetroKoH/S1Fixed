; ---------------------------------------------------------------------------
; Object 49 - waterfall	sound effect (GHZ)
; ---------------------------------------------------------------------------

WaterSound:
	; LavaGaming Object Routine Optimization
		tst.b	obRoutine(a0)
		bne.s	WSnd_PlaySnd
	; Object Routine Optimization End
; ---------------------------------------------------------------------------

WSnd_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)		; -> WSnd_PlaySnd
		move.b	#4,obRender(a0)

WSnd_PlaySnd:	; Routine 2
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