; BlocksInROM enabled means that the blocks are uncompressed, and loaded directly from ROM.
; DynamicArt enabled means that each act has its own 16x16 blocks.

	if BlocksInROM	; Mercury Blocks In ROM
; -----------------------------------------------------------------------

	if DynamicArt ; RetroKoH Dynamic Zone Art

Blk16_GHZ:
Blk16_GHZ2:
Blk16_GHZ3:		binclude	"map16/GHZ.unc"
		even
Blk16_LZ:
Blk16_LZ2:
Blk16_LZ3:		binclude	"map16/LZ.unc"
		even
Blk16_MZ:	
Blk16_MZ2:	
Blk16_MZ3:		binclude	"map16/MZ.unc"
		even
Blk16_SLZ:
Blk16_SLZ2:
Blk16_SLZ3:		binclude	"map16/SLZ.unc"
		even
Blk16_SYZ:
Blk16_SYZ2:
Blk16_SYZ3:		binclude	"map16/SYZ.unc"
		even
Blk16_SBZ:
Blk16_SBZ2:
Blk16_FZ:		binclude	"map16/SBZ.unc"
		even

; This mod forces the new SBZ3 art since every level has different art anyways
Blk16_SBZ3:		binclude	"map16/SBZ3.unc"
		even

	else

Blk16_GHZ:		binclude	"map16/GHZ.unc"
		even
Blk16_LZ:		binclude	"map16/LZ.unc"
		even
Blk16_MZ:		binclude	"map16/MZ.unc"
		even
Blk16_SLZ:		binclude	"map16/SLZ.unc"
		even
Blk16_SYZ:		binclude	"map16/SYZ.unc"
		even
Blk16_SBZ:		binclude	"map16/SBZ.unc"
		even

	if NewSBZ3LevelArt ; RetroKoH/Rohan SBZ3 Art
Blk16_SBZ3:		binclude	"map16/SBZ3.unc"
		even
	endif
	
	endif

; -----------------------------------------------------------------------
	else
; -----------------------------------------------------------------------
; By default, 16x16 blocks are Enigma compressed

	if DynamicArt ; RetroKoH Dynamic Zone Art

Blk16_GHZ:
Blk16_GHZ2:
Blk16_GHZ3:		binclude	"map16/GHZ.eni"
		even
Blk16_LZ:
Blk16_LZ2:
Blk16_LZ3:		binclude	"map16/LZ.eni"
		even
Blk16_MZ:	
Blk16_MZ2:	
Blk16_MZ3:		binclude	"map16/MZ.eni"
		even
Blk16_SLZ:
Blk16_SLZ2:
Blk16_SLZ3:		binclude	"map16/SLZ.eni"
		even
Blk16_SYZ:
Blk16_SYZ2:
Blk16_SYZ3:		binclude	"map16/SYZ.eni"
		even
Blk16_SBZ:
Blk16_SBZ2:
Blk16_FZ:		binclude	"map16/SBZ.eni"
		even

; This mod forces the new SBZ3 art since every level has different art anyways
Blk16_SBZ3:		binclude	"map16/SBZ3.eni"
		even

	else

Blk16_GHZ:		binclude	"map16/GHZ.eni"
		even
Blk16_LZ:		binclude	"map16/LZ.eni"
		even
Blk16_MZ:		binclude	"map16/MZ.eni"
		even
Blk16_SLZ:		binclude	"map16/SLZ.eni"
		even
Blk16_SYZ:		binclude	"map16/SYZ.eni"
		even
Blk16_SBZ:		binclude	"map16/SBZ.eni"
		even

	if NewSBZ3LevelArt
Blk16_SBZ3:		binclude	"map16/SBZ3.eni"
		even
	endif

	endif

; -----------------------------------------------------------------------
	endif	;end Blocks In ROM