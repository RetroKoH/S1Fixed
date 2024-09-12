; ---------------------------------------------------------------------------
; Subroutine to	find which tile	the object is standing on

; input:
;	d2 = y-position of object's bottom edge
;	d3 = x-position of object

; output:
;	a1 = address within 128x128 mappings where object is standing
;	     (refers to a 16x16 tile number)

; Optimized by RetroKoH, based on Sonic 2's Floor_ChkTile
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


FindNearestTile:
		move.w	d2,d0				; MJ: load Y position
		andi.w	#$780,d0			; MJ: get within 780 (E00 pixels) in multiples of 80
		add.w	d0,d0				; MJ: multiply by 2
		move.w	d3,d1				; MJ: load X position
		lsr.w	#7,d1				; MJ: shift to right side
		andi.w	#$7F,d1				; MJ: get within 7F
		add.w	d1,d0				; MJ: add calc'd Y to calc'd X

	if ChunksInROM=1	;Mercury Chunks In ROM
		moveq	#0,d1
	else
		moveq	#-1,d1
	endif	;Chunks In ROM

		lea		(v_lvllayout).w,a1	; MJ: load address of Layout to a1
		move.b	(a1,d0.w),d1		; MJ: collect correct chunk ID based on the X and Y position

; Credit to IsoKilo
	if ChunksInROM=1	; Mercury Chunks in ROM
		add.w	d1,d1
		move.w	word_1E5D0(pc,d1.w),d1
	else
		andi.w	#$FF,d1				; MJ: keep within FF
		lsl.w	#7,d1				; MJ: multiply by 80
	endif

		move.w	d2,d0				; MJ: load Y position
		andi.w	#$70,d0				; MJ: keep Y within 80 pixels
		add.w	d0,d1				; MJ: add to ror'd chunk ID
		move.w	d3,d0				; MJ: load X position
		lsr.w	#3,d0				; MJ: divide by 8
		andi.w	#$E,d0				; MJ: keep X within 10 pixels
		add.w	d0,d1				; MJ: add to ror'd chunk ID

	if ChunksInROM=1	;Mercury Chunks In ROM
		add.l	(v_128x128).l,d1
	endif	;Chunks In ROM

		movea.l	d1,a1				; MJ: set address (Chunk to read)
		rts							; MJ: return
; End of function FindNearestTile

; ===========================================================================
; precalculated values for Floor_ChkTile
; (Sonic 1 calculated it every time instead of using a table)
word_1E5D0:
		dc.w	 0,  $80
		dc.w  $100, $180
		dc.w  $200, $280
		dc.w  $300, $380
		dc.w  $400, $480
		dc.w  $500, $580
		dc.w  $600, $680
		dc.w  $700, $780
		dc.w  $800, $880
		dc.w  $900, $980
		dc.w  $A00, $A80
		dc.w  $B00, $B80
		dc.w  $C00, $C80
		dc.w  $D00, $D80
		dc.w  $E00, $E80
		dc.w  $F00, $F80
		dc.w $1000,$1080
		dc.w $1100,$1180
		dc.w $1200,$1280
		dc.w $1300,$1380
		dc.w $1400,$1480
		dc.w $1500,$1580
		dc.w $1600,$1680
		dc.w $1700,$1780
		dc.w $1800,$1880
		dc.w $1900,$1980
		dc.w $1A00,$1A80
		dc.w $1B00,$1B80
		dc.w $1C00,$1C80
		dc.w $1D00,$1D80
		dc.w $1E00,$1E80
		dc.w $1F00,$1F80
		dc.w $2000,$2080
		dc.w $2100,$2180
		dc.w $2200,$2280
		dc.w $2300,$2380
		dc.w $2400,$2480
		dc.w $2500,$2580
		dc.w $2600,$2680
		dc.w $2700,$2780
		dc.w $2800,$2880
		dc.w $2900,$2980
		dc.w $2A00,$2A80
		dc.w $2B00,$2B80
		dc.w $2C00,$2C80
		dc.w $2D00,$2D80
		dc.w $2E00,$2E80
		dc.w $2F00,$2F80
		dc.w $3000,$3080
		dc.w $3100,$3180
		dc.w $3200,$3280
		dc.w $3300,$3380
		dc.w $3400,$3480
		dc.w $3500,$3580
		dc.w $3600,$3680
		dc.w $3700,$3780
		dc.w $3800,$3880
		dc.w $3900,$3980
		dc.w $3A00,$3A80
		dc.w $3B00,$3B80
		dc.w $3C00,$3C80
		dc.w $3D00,$3D80
		dc.w $3E00,$3E80
		dc.w $3F00,$3F80
		dc.w $4000,$4080
		dc.w $4100,$4180
		dc.w $4200,$4280
		dc.w $4300,$4380
		dc.w $4400,$4480
		dc.w $4500,$4580
		dc.w $4600,$4680
		dc.w $4700,$4780
		dc.w $4800,$4880
		dc.w $4900,$4980
		dc.w $4A00,$4A80
		dc.w $4B00,$4B80
		dc.w $4C00,$4C80
		dc.w $4D00,$4D80
		dc.w $4E00,$4E80
		dc.w $4F00,$4F80
		dc.w $5000,$5080
		dc.w $5100,$5180
		dc.w $5200,$5280
		dc.w $5300,$5380
		dc.w $5400,$5480
		dc.w $5500,$5580
		dc.w $5600,$5680
		dc.w $5700,$5780
		dc.w $5800,$5880
		dc.w $5900,$5980
		dc.w $5A00,$5A80
		dc.w $5B00,$5B80
		dc.w $5C00,$5C80
		dc.w $5D00,$5D80
		dc.w $5E00,$5E80
		dc.w $5F00,$5F80
		dc.w $6000,$6080
		dc.w $6100,$6180
		dc.w $6200,$6280
		dc.w $6300,$6380
		dc.w $6400,$6480
		dc.w $6500,$6580
		dc.w $6600,$6680
		dc.w $6700,$6780
		dc.w $6800,$6880
		dc.w $6900,$6980
		dc.w $6A00,$6A80
		dc.w $6B00,$6B80
		dc.w $6C00,$6C80
		dc.w $6D00,$6D80
		dc.w $6E00,$6E80
		dc.w $6F00,$6F80
		dc.w $7000,$7080
		dc.w $7100,$7180
		dc.w $7200,$7280
		dc.w $7300,$7380
		dc.w $7400,$7480
		dc.w $7500,$7580
		dc.w $7600,$7680
		dc.w $7700,$7780
		dc.w $7800,$7880
		dc.w $7900,$7980
		dc.w $7A00,$7A80
		dc.w $7B00,$7B80
		dc.w $7C00,$7C80
		dc.w $7D00,$7D80
		dc.w $7E00,$7E80
		dc.w $7F00,$7F80
		even
; ===========================================================================
