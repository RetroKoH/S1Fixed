; ---------------------------------------------------------------------------
; Subroutine to	animate	a sprite using an animation script
; ---------------------------------------------------------------------------

AnimateSprite:
		moveq	#0,d0
		move.b	obAnim(a0),d0			; move animation number	to d0
		btst	#7,d0					; is animation set to restart?
		bne.s	Anim_Run				; if not, branch

		bset	#7,obAnim(a0)			; set to "no restart"
		clr.w	obAniFrame(a0)			; reset animation and frame duration

Anim_Run:
		subq.b	#1,obTimeFrame(a0)		; subtract 1 from frame duration
		bpl.s	Anim_Wait				; if time remains, branch
		andi.b	#$7F,d0					; ignore high bit (the no-restart flag)
		add.w	d0,d0
		adda.w	(a1,d0.w),a1			; jump to appropriate animation	script
		move.b	(a1),obTimeFrame(a0)	; load frame duration
		moveq	#0,d1
		move.b	obAniFrame(a0),d1		; load current frame number
		move.b	1(a1,d1.w),d0			; read sprite number from script
		; MarkeyJester Art Limit Extensions (extended from [$00 - $7F] to [$00 - $F9])
		cmp.b	#$FA,d0					; is it a flag from FA to FF?
		bhs.s	Anim_End_FF				; if animation is complete, branch
		; Art Limit Extensions End

Anim_Next:
		move.b	d0,d1
		andi.b	#$1F,d0
		move.b	d0,obFrame(a0)			; load sprite number
		move.b	obStatus(a0),d0
		rol.b	#3,d1
		eor.b	d0,d1
		andi.b	#3,d1					; (maskFlipX + maskFlipY)?
		andi.b	#$FC,obRender(a0)
		or.b	d1,obRender(a0)
		addq.b	#1,obAniFrame(a0)		; next frame number

Anim_Wait:
		rts	
; ===========================================================================

Anim_End_FF:					; code FF - return to beginning of animation
		addq.b	#1,d0					; is the end flag = $FF	?
		bne.s	Anim_End_FE				; if not, branch
		clr.b	obAniFrame(a0)			; restart the animation
		move.b	1(a1),d0				; read sprite number
		bra.s	Anim_Next
; ===========================================================================

Anim_End_FE:					; code FE - go back (specified number) bytes
		addq.b	#1,d0					; is the end flag = $FE	?
		bne.s	Anim_End_FD				; if not, branch
		move.b	2(a1,d1.w),d0			; read the next	byte in	the script
		sub.b	d0,obAniFrame(a0)		; jump back d0 bytes in the script
		sub.b	d0,d1
		move.b	1(a1,d1.w),d0			; read sprite number
		bra.s	Anim_Next
; ===========================================================================

Anim_End_FD:					; code FD - run specified animation
		addq.b	#1,d0					; is the end flag = $FD	?
		bne.s	Anim_End_FC				; if not, branch
		move.b	2(a1,d1.w),obAnim(a0)	; read next byte, run that animation
		rts
; ===========================================================================

Anim_End_FC:					; code FC - increment routine counter
		addq.b	#1,d0					; is the end flag = $FC	?
		bne.s	Anim_End_FB				; if not, branch
		addq.b	#2,obRoutine(a0)		; jump to next routine
		rts
; ===========================================================================

Anim_End_FB:					; code FB - reset animation and 2nd object routine counter
		addq.b	#1,d0					; is the end flag = $FB	?
		bne.s	Anim_End_FA				; if not, branch
		clr.b	obAniFrame(a0)			; reset animation
		clr.b	ob2ndRout(a0)			; reset	2nd routine counter
		rts
; ===========================================================================

Anim_End_FA:					; code FA - increment 2nd routine counter
		addq.b	#1,d0					; is the end flag = $FA	?
		bne.s	.end					; if not, branch
		addq.b	#2,ob2ndRout(a0)		; jump to next routine

.end:
		rts	
; End of function AnimateSprite
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to	update the animation id of an object if it changes
;
; input:
;	d0 = new animation id

; output:
;	d1 = previous animation id
; ---------------------------------------------------------------------------

NewAnim:
		moveq	#$7F,d1					; ignore high bit (the no-restart flag)
		and.b	obAnim(a0),d1			; get previous animation id
		cmp.b	d0,d1					; compare with new id
		beq.s	.keepanim				; branch if same
		move.b	d0,obAnim(a0)			; update animation id (and clear high bit)

	.keepanim:
		rts
; End of function NewAnim
; ===========================================================================