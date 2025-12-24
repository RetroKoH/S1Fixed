; ---------------------------------------------------------------------------
; Subroutine to find a free object space

; output:
;	a1 = free position in object RAM
; ---------------------------------------------------------------------------

;SingleObjLoad:
FindFreeObj:
	; Slight improvement by Malachi
		lea		(v_lvlobjspace-object_size).w,a1	; start address for object RAM
		move.w	#v_lvlobjcount,d0

	.loop:
		lea		object_size(a1),a1	; goto next object RAM slot
		tst.l	obAddr(a1)			; is object RAM	slot empty?
		dbeq	d0,.loop			; if not, branch
		rts							; if yes, exit
; End of function FindFreeObj
; ===========================================================================

; ---------------------------------------------------------------------------
; Subroutine to find a free object space AFTER the current one

; output:
;	a1 = free position in object RAM
; ---------------------------------------------------------------------------

;SingleObjLoad2:
FindNextFreeObj:
		movea.l	a0,a1
		move.w	#v_lvlobjend&$FFFF,d0
		sub.w	a0,d0
		lsr.w	#6,d0
		subq.w	#1,d0
		bcs.s	NFree_Found

NFree_Loop:
		tst.l	obAddr(a1)
		beq.s	NFree_Found
		lea		object_size(a1),a1
		dbf		d0,NFree_Loop

NFree_Found:
		rts	
; End of function FindNextFreeObj
; ===========================================================================