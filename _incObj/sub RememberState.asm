; ---------------------------------------------------------------------------
; Subroutine to remember whether an object is destroyed/collected
; ---------------------------------------------------------------------------

RememberState:
		out_of_range.w	.offscreen
		bsr.w	DisplaySprite
		bra.s	Add_SpriteToCollisionResponseList

.offscreen:
		move.w	obRespawnNo(a0),d0	; get address in respawn table
		beq.w	DeleteObject		; if it's zero, don't remember object
		movea.w	d0,a2				; load address into a2
		bclr	#7,(a2)				; clear respawn table entry, so object can be loaded again
		bra.w	DeleteObject

; -----------------------------------------------------------------------------------------------------------
; Subroutine to collide an object with player (so it works under S3K's touch collision response list
; -----------------------------------------------------------------------------------------------------------

Add_SpriteToCollisionResponseList:
		lea		(v_col_response_list).w,a1
		cmpi.w	#$7E,(a1)	; Is list full?
		bhs.s	.return		; If so, return
		addq.w	#2,(a1)		; Count this new entry
		adda.w	(a1),a1		; Offset into right area of list
		move.w	a0,(a1)		; Store RAM address in list

	.return:
		rts
; End of function Add_SpriteToCollisionResponseList
; ---------------------------------------------------------------------------
DisplayAndCollision:
		bsr.w	DisplaySprite
		bra.s	Add_SpriteToCollisionResponseList
