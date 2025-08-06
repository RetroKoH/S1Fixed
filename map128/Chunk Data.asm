; ChunksInROM enabled means that the chunks are uncompressed, and loaded directly from ROM.
; DynamicArt enabled means that each act has its own 128x128 chunks.

	if ChunksInROM	; Mercury Chunks In ROM
; -----------------------------------------------------------------------

	if DynamicArt ; RetroKoH Dynamic Zone Art

Blk128_GHZ:
Blk128_GHZ2:
Blk128_GHZ3:	binclude	"map128/GHZ.unc"
		even
Blk128_LZ:
Blk128_LZ2:
Blk128_LZ3:		binclude	"map128/LZ.unc"
		even
Blk128_MZ:	
Blk128_MZ2:	
Blk128_MZ3:		binclude	"map128/MZ.unc"
		even
Blk128_SLZ:
Blk128_SLZ2:
Blk128_SLZ3:	binclude	"map128/SLZ.unc"
		even
Blk128_SYZ:
Blk128_SYZ2:
Blk128_SYZ3:	binclude	"map128/SYZ.unc"
		even
Blk128_SBZ:
Blk128_SBZ2:
Blk128_FZ:		binclude	"map128/SBZ.unc"
		even

; This mod forces the new SBZ3 art since every level has different art anyways
Blk128_SBZ3:	binclude	"map128/SBZ3.unc"
		even

	else

Blk128_GHZ:		binclude	"map128/GHZ.unc"
		even
Blk128_LZ:		binclude	"map128/LZ.unc"
		even
Blk128_MZ:		binclude	"map128/MZ.unc"
		even
Blk128_SLZ:		binclude	"map128/SLZ.unc"
		even
Blk128_SYZ:		binclude	"map128/SYZ.unc"
		even
Blk128_SBZ:		binclude	"map128/SBZ.unc"
		even

	if NewSBZ3LevelArt ; RetroKoH/Rohan SBZ3 Art
Blk128_SBZ3:	binclude	"map128/SBZ3.unc"
		even
	endif
	
	endif

; -----------------------------------------------------------------------
	else
; -----------------------------------------------------------------------
; By default, 128x128 chunks are Kosinski compressed

	if DynamicArt ; RetroKoH Dynamic Zone Art

Blk128_GHZ:
Blk128_GHZ2:
Blk128_GHZ3:	binclude	"map128/GHZ.kos"
		even
Blk128_LZ:
Blk128_LZ2:
Blk128_LZ3:		binclude	"map128/LZ.kos"
		even
Blk128_MZ:	
Blk128_MZ2:	
Blk128_MZ3:		binclude	"map128/MZ.kos"
		even
Blk128_SLZ:
Blk128_SLZ2:
Blk128_SLZ3:	binclude	"map128/SLZ.kos"
		even
Blk128_SYZ:
Blk128_SYZ2:
Blk128_SYZ3:	binclude	"map128/SYZ.kos"
		even
Blk128_SBZ:
Blk128_SBZ2:
Blk128_FZ:		binclude	"map128/SBZ.kos"
		even

; This mod forces the new SBZ3 art since every level has different art anyways
Blk128_SBZ3:	binclude	"map128/SBZ3.kos"
		even

	else

Blk128_GHZ:		binclude	"map128/GHZ.kos"
		even
Blk128_LZ:		binclude	"map128/LZ.kos"
		even
Blk128_MZ:		binclude	"map128/MZ.kos"
		even
Blk128_SLZ:		binclude	"map128/SLZ.kos"
		even
Blk128_SYZ:		binclude	"map128/SYZ.kos"
		even
Blk128_SBZ:		binclude	"map128/SBZ.kos"
		even

	if NewSBZ3LevelArt
Blk128_SBZ3:	binclude	"map128/SBZ3.kos"
		even
	endif

	endif

; -----------------------------------------------------------------------
	endif	;end Chunks In ROM