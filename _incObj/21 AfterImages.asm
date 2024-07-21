; ---------------------------------------------------------------------------
; Object 21 - After-images
; Credit to Hitaxas, ported from WoolooEngine, cleaned up by RetroKoH
; This checks data in v_followobject, which is currently unused
; ---------------------------------------------------------------------------

AfterImages:
		tst.b	obRoutine(a0)
		bne.s	AfterImages_Main

AfterImages_Init:
		addq.b	#2,obRoutine(a0)
	; More compact code section by RetroKoH
		lea		(v_player).w,a1					; followerobj1: Pulls from v_player
		cmpi.b	#2,obSubtype(a0)
		beq.s	.skip
		lea		(v_followobject).w,a1			; followerobj2: Pulls from v_followobject

.skip:
		move.l	obMap(a1),obMap(a0)				; Character obMap = afterimage obMap
		move.w	obGfx(a1),obGfx(a0)				; use player 1's art
		move.w	#priority2,obPriority(a0)
		move.b	#$18,obWidth(a0)
		move.b	#$18,obHeight(a0)
		move.b	#4,obRender(a0)	

AfterImages_Main:
		moveq	#$C,d1							; This will be subtracted from Pos_table_index, giving the object an older entry
		btst	#0,(v_framebyte).w				; Even frame? (Think of it as 'every other number' logic)
		beq.s	.evenframe						; If so, branch
		moveq	#$14,d1							; On every other frame, use a different number to subtract, giving the object an even older entry

.evenframe:
		move.w	(v_trackpos).w,d0
		lea		(v_tracksonic).w,a1
		sub.b	d1,d0
		lea		(a1,d0.w),a1
		move.w	(a1)+,obX(a0)					; Use previous player x_pos
		move.w	(a1)+,obY(a0)					; Use previous player y_pos

    ; if obMap for player changes, so do the obMap for the after images
	; More compact code section by RetroKoH
		lea		(v_player).w,a1					; followerobj1: Pulls from v_player
		cmpi.b	#2,obSubtype(a0)
		beq.s	.skip
		lea		(v_followobject).w,a1			; followerobj2: Pulls from v_followobject

.skip:
		tst.b	(v_player+obShoes).w			; check	time remaining
		beq.s	.exit
		move.l	obMap(a1),obMap(a0)				; Use player's current obMap - added by hitaxas	   
		move.b	obFrame(a1),obFrame(a0)			; Use player's current obFrame
		move.b	obRender(a1),obRender(a0)		; Use player's current obRender
		move.w	obPriority(a1),obPriority(a0)	; Use player's current obPriority
		jmp		(DisplaySprite).l
	
.exit:
		jmp		(DeleteObject).l				; Destroy if no speed shoes
