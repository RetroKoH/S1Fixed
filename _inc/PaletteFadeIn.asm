	if PaletteFadeSetting=0
		include "_inc/Fade Effects/PaletteFadeIn 00 - Blue.asm"
	elseif PaletteFadeSetting=1
		include "_inc/Fade Effects/PaletteFadeIn 01 - Green.asm"
	elseif PaletteFadeSetting=2
		include "_inc/Fade Effects/PaletteFadeIn 02 - Red.asm"
	elseif PaletteFadeSetting=3
		include "_inc/Fade Effects/PaletteFadeIn 03 - BlueGreen.asm"
	elseif PaletteFadeSetting=4
		include "_inc/Fade Effects/PaletteFadeIn 04 - BlueRed.asm"
	elseif PaletteFadeSetting=5
		include "_inc/Fade Effects/PaletteFadeIn 05 - GreenRed.asm"
	else
		include "_inc/Fade Effects/PaletteFadeIn 06 - Full.asm"
	endif
