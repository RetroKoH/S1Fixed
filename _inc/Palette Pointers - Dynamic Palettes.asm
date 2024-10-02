; ---------------------------------------------------------------------------
; Palette pointers - Dynamic Level Palettes
; ---------------------------------------------------------------------------

palp:	macro desinationPaletteLine,sourceAddress
	dc.l sourceAddress
	dc.w v_palette+desinationPaletteLine*$10*2,(sourceAddress_end-sourceAddress)/4-1
	endm

PalPointers:

; palette address, RAM address, colours

	if FadeInSEGA = 0
ptr_Pal_SegaBG:		palp	0,Pal_SegaBG		; 0 - Sega logo palette
	endif

ptr_Pal_Title:		palp	0,Pal_Title			; 1 - title screen -- RetroKoH Title Screen Adjustment
ptr_Pal_LevelSel:	palp	0,Pal_LevelSel		; 2 - level select
ptr_Pal_Sonic:		palp	0,Pal_Sonic			; 3 - Sonic

Pal_Levels:
	; RetroKoH Dynamic Palette Pointers
ptr_Pal_GHZ1:		palp	1,Pal_GHZ			; 4 - GHZ1
ptr_Pal_GHZ2:		palp	1,Pal_GHZ			; 5 - GHZ2
ptr_Pal_GHZ3:		palp	1,Pal_GHZ			; 6 - GHZ3
ptr_Pal_LZ1:		palp	1,Pal_LZ			; 7 - LZ1
ptr_Pal_LZ2:		palp	1,Pal_LZ			; 8 - LZ2
ptr_Pal_LZ3:		palp	1,Pal_LZ			; 9 - LZ3
ptr_Pal_MZ1:		palp	1,Pal_MZ			; $A (10) - MZ1
ptr_Pal_MZ2:		palp	1,Pal_MZ			; $B (11) - MZ2
ptr_Pal_MZ3:		palp	1,Pal_MZ			; $C (12) - MZ3
ptr_Pal_SLZ1:		palp	1,Pal_SLZ			; $D (13) - SLZ1
ptr_Pal_SLZ2:		palp	1,Pal_SLZ			; $E (14) - SLZ2
ptr_Pal_SLZ3:		palp	1,Pal_SLZ			; $F (15) - SLZ3
ptr_Pal_SYZ1:		palp	1,Pal_SYZ			; $10 (16) - SYZ1
ptr_Pal_SYZ2:		palp	1,Pal_SYZ			; $11 (17) - SYZ2
ptr_Pal_SYZ3:		palp	1,Pal_SYZ			; $12 (18) - SYZ3
	; Dynamic Palette Pointers End
ptr_Pal_SBZ1:		palp	1,Pal_SBZ1			; $13 (19) - SBZ1

ptr_Pal_Special:	palp	0,Pal_Special		; $14 (20) - special stage
ptr_Pal_LZ1Water:	palp	0,Pal_LZWater		; $15 (21) - LZ1 underwater -- RetroKoH Dynamic Palette Pointers
ptr_Pal_LZ2Water:	palp	0,Pal_LZWater		; $16 (22) - LZ2 underwater -- RetroKoH Dynamic Palette Pointers
ptr_Pal_LZ3Water:	palp	0,Pal_LZWater		; $17 (23) - LZ3 underwater -- RetroKoH Dynamic Palette Pointers
ptr_Pal_SBZ3:		palp	1,Pal_SBZ3			; $18 (24) - SBZ3
ptr_Pal_SBZ3Water:	palp	0,Pal_SBZ3Water		; $19 (25) - SBZ3 underwater
ptr_Pal_SBZ2:		palp	1,Pal_SBZ2			; $1A (26) - SBZ2
ptr_Pal_LZ1SonWat:	palp	0,Pal_LZSonWater	; $1B (27) - LZ1 Sonic underwater -- RetroKoH Dynamic Palette Pointers
ptr_Pal_LZ2SonWat:	palp	0,Pal_LZSonWater	; $1C (28) - LZ2 Sonic underwater -- RetroKoH Dynamic Palette Pointers
ptr_Pal_LZ3SonWat:	palp	0,Pal_LZSonWater	; $1D (29) - LZ3 Sonic underwater -- RetroKoH Dynamic Palette Pointers
ptr_Pal_SBZ3SonWat:	palp	0,Pal_SBZ3SonWat	; $1E (30) - SBZ3 Sonic underwater
ptr_Pal_SSResult:	palp	0,Pal_SSResult		; $1F (31) - special stage results
ptr_Pal_Continue:	palp	0,Pal_Continue		; $20 (32) - special stage results continue
ptr_Pal_Ending:		palp	0,Pal_Ending		; $21 (33) - ending sequence

	if NewLevelSelect
ptr_Pal_LevSelIcon:	palp	2,Pal_LevSelIcons	; $22 (34) - S2 Level Select Icons
	endif
			even

	if FadeInSEGA = 0
palid_SegaBG:		equ	(ptr_Pal_SegaBG-PalPointers)/8
	endif

palid_Title:		equ (ptr_Pal_Title-PalPointers)/8
palid_LevelSel:		equ (ptr_Pal_LevelSel-PalPointers)/8
palid_Sonic:		equ (ptr_Pal_Sonic-PalPointers)/8

	; RetroKoH Dynamic Palette Pointers
palid_GHZ:			equ (ptr_Pal_GHZ1-PalPointers)/8
palid_GHZ2:			equ (ptr_Pal_GHZ2-PalPointers)/8
palid_GHZ3:			equ (ptr_Pal_GHZ3-PalPointers)/8
palid_LZ:			equ (ptr_Pal_LZ1-PalPointers)/8
palid_LZ2:			equ (ptr_Pal_LZ2-PalPointers)/8
palid_LZ3:			equ (ptr_Pal_LZ3-PalPointers)/8
palid_MZ:			equ (ptr_Pal_MZ1-PalPointers)/8
palid_MZ2:			equ (ptr_Pal_MZ2-PalPointers)/8
palid_MZ3:			equ (ptr_Pal_MZ3-PalPointers)/8
palid_SLZ:			equ (ptr_Pal_SLZ1-PalPointers)/8
palid_SLZ2:			equ (ptr_Pal_SLZ2-PalPointers)/8
palid_SLZ3:			equ (ptr_Pal_SLZ3-PalPointers)/8
palid_SYZ:			equ (ptr_Pal_SYZ1-PalPointers)/8
palid_SYZ2:			equ (ptr_Pal_SYZ2-PalPointers)/8
palid_SYZ3:			equ (ptr_Pal_SYZ3-PalPointers)/8
	; Dynamic Palette Pointers End

palid_SBZ1:			equ (ptr_Pal_SBZ1-PalPointers)/8
palid_Special:		equ (ptr_Pal_Special-PalPointers)/8

	; RetroKoH Dynamic Palette Pointers
palid_LZWater:		equ (ptr_Pal_LZ1Water-PalPointers)/8
palid_LZ2Water:		equ (ptr_Pal_LZ2Water-PalPointers)/8
palid_LZ3Water:		equ (ptr_Pal_LZ3Water-PalPointers)/8
	; Dynamic Palette Pointers End

palid_SBZ3:			equ (ptr_Pal_SBZ3-PalPointers)/8
palid_SBZ3Water:	equ (ptr_Pal_SBZ3Water-PalPointers)/8
palid_SBZ2:			equ (ptr_Pal_SBZ2-PalPointers)/8

	; RetroKoH Dynamic Palette Pointers
palid_LZSonWater:	equ (ptr_Pal_LZ1SonWat-PalPointers)/8
palid_LZ2SonWat:	equ (ptr_Pal_LZ2SonWat-PalPointers)/8
palid_LZ3SonWat:	equ (ptr_Pal_LZ3SonWat-PalPointers)/8
	; Dynamic Palette Pointers End

palid_SBZ3SonWat:	equ (ptr_Pal_SBZ3SonWat-PalPointers)/8
palid_SSResult:		equ (ptr_Pal_SSResult-PalPointers)/8
palid_Continue:		equ (ptr_Pal_Continue-PalPointers)/8
palid_Ending:		equ (ptr_Pal_Ending-PalPointers)/8

	if NewLevelSelect
palid_LevSelIcon:	equ (ptr_Pal_LevSelIcon-PalPointers)/8
	endif
