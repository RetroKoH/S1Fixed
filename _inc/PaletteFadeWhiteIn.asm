	if PaletteFadeSetting=0
		include "_inc/Fade Effects/PaletteFadeWhiteIn 00 - Blue.asm"
	elseif PaletteFadeSetting=1
		include "_inc/Fade Effects/PaletteFadeWhiteIn 01 - Green.asm"
	elseif PaletteFadeSetting=2
		include "_inc/Fade Effects/PaletteFadeWhiteIn 02 - Red.asm"
	elseif PaletteFadeSetting=3
		include "_inc/Fade Effects/PaletteFadeWhiteIn 03 - BlueGreen.asm"
	elseif PaletteFadeSetting=4
		include "_inc/Fade Effects/PaletteFadeWhiteIn 04 - BlueRed.asm"
	elseif PaletteFadeSetting=5
		include "_inc/Fade Effects/PaletteFadeWhiteIn 05 - GreenRed.asm"
	else
		include "_inc/Fade Effects/PaletteFadeWhiteIn 06 - Full.asm"
	endif