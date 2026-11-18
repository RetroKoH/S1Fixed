BGScrollSize_GHZ:
		dc.w	$20		; cloud 1, 32 pixels
		dc.w	$10		; cloud 2, 16 pixels
		dc.w	$10		; cloud 3, 16 pixels
		dc.w	$30		; distant mountains, 48 pixels
		dc.w	$28		; hills with waterfall, 40 pixels
		dc.w	$8068	; water (pixelwise), 104 individual scanlines

BGScrollSize_MZ:
		dc.w	$200	; unused 4 chunks above the scenery
	rept	$A		; clouds
		dc.w	8		; ten 8-pixel cloud bands
	endr
		dc.w	$20		; mountains, 32 pixels
		dc.w	$90		; bushes & buildings, 144 pixels
		dc.w	$7FFF	; dungeon interior

BGScrollSize_SLZ:
		dc.w	$C0		; unused star block
	rept	$1C		; stars
		dc.w	$10		; 28 16-pixel star bands
	endr
		dc.w	$50		; upper buildings, 80 pixels
		dc.w	$50		; lower buildings, 80 pixels
		dc.w	$7FFF	; all of the low section (fixes the old camera BG bug)

BGScrollSize_SYZ:
	rept	8		; clouds
		dc.w	$10		; eight 16-pixel cloud bands
	endr
		dc.w	$50		; mountains, 80 pixels
		dc.w	$60		; buildings, 96 pixels
	rept	$E		; bushes
		dc.w	$10		; 14 16-pixel cloud bands
	endr
		dc.w	$7FFF	; everything else
		
BGScrollSize_SBZ1:
	rept	4		; clouds
		dc.w	$10		; four 16-pixel cloud bands
	endr
		dc.w	$A0		; distant brown buildings, 160 pixels
		dc.w	$70		; upper black buildings, 112 pixels
		dc.w	$7FFF	; lower black buildings