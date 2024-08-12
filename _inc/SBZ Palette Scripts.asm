; ---------------------------------------------------------------------------
; Scrap Brain Zone palette cycling script
; ---------------------------------------------------------------------------

mSBZp:	macro duration,colours,paladdress,ramaddress
	dc.b duration, colours
	dc.w paladdress, ramaddress
	endm

; duration in frames, number of colours, palette address, RAM address

Pal_SBZCycList1:
	dc.w	((end_SBZCycList1-Pal_SBZCycList1-2)/6)-1
	mSBZp	7,8,Pal_SBZCyc1,v_palette+$50
	mSBZp	$D,8,Pal_SBZCyc2,v_palette+$52
	mSBZp	$E,8,Pal_SBZCyc3,v_palette+$6E
	mSBZp	$B,8,Pal_SBZCyc5,v_palette+$70
	mSBZp	7,8,Pal_SBZCyc6,v_palette+$72
	mSBZp	$1C,$10,Pal_SBZCyc7,v_palette+$7E
	mSBZp	3,3,Pal_SBZCyc8,v_palette+$78
	mSBZp	3,3,Pal_SBZCyc8+2,v_palette+$7A
	mSBZp	3,3,Pal_SBZCyc8+4,v_palette+$7C
end_SBZCycList1:
	even

Pal_SBZCycList2:
	dc.w	((end_SBZCycList2-Pal_SBZCycList2-2)/6)-1
	mSBZp	7,8,Pal_SBZCyc1,v_palette+$50
	mSBZp	$D,8,Pal_SBZCyc2,v_palette+$52
	mSBZp	9,8,Pal_SBZCyc9,v_palette+$70
	mSBZp	7,8,Pal_SBZCyc6,v_palette+$72
	mSBZp	3,3,Pal_SBZCyc8,v_palette+$78
	mSBZp	3,3,Pal_SBZCyc8+2,v_palette+$7A
	mSBZp	3,3,Pal_SBZCyc8+4,v_palette+$7C
end_SBZCycList2:
	even
