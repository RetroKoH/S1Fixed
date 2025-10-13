; ---------------------------------------------------------------------------
; Subroutine calculate a sine

; input:
;	d0 = angle (360 degrees = 256)

; output:
;	d0 = sine
;	d1 = cosine

; Slight optimization thanks to Sonic 1 Co-Op
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


CalcSine:
		clr.w	d1
		andi.w	#$FF,d0						; use only single-byte input (256 angles)
		add.w	d0,d0						; double, as we're handling word values
		move.w	d0,d1
		move.w	Sine_Data(pc,d0.w),d0		; return sine of angle
		addq.w	#8,d1						; add 8 so we can use the faster addressing mode below
		move.w	Cosine_Data-8(pc,d1.w),d1	; return cosine of angle
		rts
; End of function CalcSine

; ===========================================================================
Sine_Data:
	dc.w   $00, $06, $0C, $12, $19, $1F, $25, $2B, $31, $38, $3E, $44, $4A, $50, $56, $5C	;00-0F
	dc.w   $61, $67, $6D, $73, $78, $7E, $83, $88, $8E, $93, $98, $9D, $A2, $A7, $AB, $B0	;10-1F
	dc.w   $B5, $B9, $BD, $C1, $C5, $C9, $CD, $D1, $D4, $D8, $DB, $DE, $E1, $E4, $E7, $EA	;20-2F
	dc.w   $EC, $EE, $F1, $F3, $F4, $F6, $F8, $F9, $FB, $FC, $FD, $FE, $FE, $FF, $FF, $FF	;30-3F

Cosine_Data:
	dc.w  $100, $FF, $FF, $FF, $FE, $FE, $FD, $FC, $FB, $F9, $F8, $F6, $F4, $F3, $F1, $EE	;40-4F
	dc.w   $EC, $EA, $E7, $E4, $E1, $DE, $DB, $D8, $D4, $D1, $CD, $C9, $C5, $C1, $BD, $B9	;50-5F
	dc.w   $B5, $B0, $AB, $A7, $A2, $9D, $98, $93, $8E, $88, $83, $7E, $78, $73, $6D, $67	;60-6F
	dc.w   $61, $5C, $56, $50, $4A, $44, $3E, $38, $31, $2B, $25, $1F, $19, $12, $0C, $06	;70-7F

	dc.w   $00,-$06,-$0C,-$12,-$19,-$1F,-$25,-$2B,-$31,-$38,-$3E,-$44,-$4A,-$50,-$56,-$5C	;80-8F
	dc.w  -$61,-$67,-$6D,-$73,-$78,-$7E,-$83,-$88,-$8E,-$93,-$98,-$9D,-$A2,-$A7,-$AB,-$B0	;90-9F
	dc.w  -$B5,-$B9,-$BD,-$C1,-$C5,-$C9,-$CD,-$D1,-$D4,-$D8,-$DB,-$DE,-$E1,-$E4,-$E7,-$EA	;A0-AF
	dc.w  -$EC,-$EE,-$F1,-$F3,-$F4,-$F6,-$F8,-$F9,-$FB,-$FC,-$FD,-$FE,-$FE,-$FF,-$FF,-$FF	;B0-BF

	dc.w -$100,-$FF,-$FF,-$FF,-$FE,-$FE,-$FD,-$FC,-$FB,-$F9,-$F8,-$F6,-$F4,-$F3,-$F1,-$EE	;C0-CF
	dc.w  -$EC,-$EA,-$E7,-$E4,-$E1,-$DE,-$DB,-$D8,-$D4,-$D1,-$CD,-$C9,-$C5,-$C1,-$BD,-$B9	;D0-DF
	dc.w  -$B5,-$B0,-$AB,-$A7,-$A2,-$9D,-$98,-$93,-$8E,-$88,-$83,-$7E,-$78,-$73,-$6D,-$67	;E0-EF
	dc.w  -$61,-$5C,-$56,-$50,-$4A,-$44,-$3E,-$38,-$31,-$2B,-$25,-$1F,-$19,-$12,-$0C,-$06	;F0-FF

; Extension used for Cosine calculation (since we move $80 bytes ahead for the cosine)
	dc.w   $00, $06, $0C, $12, $19, $1F, $25, $2B, $31, $38, $3E, $44, $4A, $50, $56, $5C
	dc.w   $61, $67, $6D, $73, $78, $7E, $83, $88, $8E, $93, $98, $9D, $A2, $A7, $AB, $B0
	dc.w   $B5, $B9, $BD, $C1, $C5, $C9, $CD, $D1, $D4, $D8, $DB, $DE, $E1, $E4, $E7, $EA
	dc.w   $EC, $EE, $F1, $F3, $F4, $F6, $F8, $F9, $FB, $FC, $FD, $FE, $FE, $FF, $FF, $FF
; ===========================================================================
