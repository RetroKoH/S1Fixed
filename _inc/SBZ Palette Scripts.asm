; ---------------------------------------------------------------------------
; Scrap Brain Zone palette cycling script
; ---------------------------------------------------------------------------

mSBZh:	macro {INTLABEL},{GLOBALSYMBOLS}
__LABEL__:
	dc.w ((__LABEL___end-__LABEL__-2)/6)-1
	endm

mSBZp:	macro duration,colours,sourceAddress,destinationPaletteIndex
	dc.b duration, colours
	dc.w sourceAddress, v_palette+destinationPaletteIndex*2
	endm

; duration in frames, number of colours, palette address, RAM address

Pal_SBZCycList1: mSBZh
	mSBZp	 7, 8,Pal_SBZCyc1,$28
	mSBZp	13, 8,Pal_SBZCyc2,$29
	mSBZp	14, 8,Pal_SBZCyc3,$37
	mSBZp	11, 8,Pal_SBZCyc5,$38
	mSBZp	 7, 8,Pal_SBZCyc6,$39
	mSBZp	28,16,Pal_SBZCyc7,$3F
	mSBZp	 3, 3,Pal_SBZCyc8,$3C
	mSBZp	 3, 3,Pal_SBZCyc8+2,$3D
	mSBZp	 3, 3,Pal_SBZCyc8+4,$3E
Pal_SBZCycList1_end:
	even

Pal_SBZCycList2: mSBZh
	mSBZp	 7, 8,Pal_SBZCyc1,$28
	mSBZp	13, 8,Pal_SBZCyc2,$29
	mSBZp	 9, 8,Pal_SBZCyc9,$38
	mSBZp	 7, 8,Pal_SBZCyc6,$39
	mSBZp	 3, 3,Pal_SBZCyc8,$3C
	mSBZp	 3, 3,Pal_SBZCyc8+2,$3D
	mSBZp	 3, 3,Pal_SBZCyc8+4,$3E
Pal_SBZCycList2_end:
	even
