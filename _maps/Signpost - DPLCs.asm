; ---------------------------------------------------------------------------
; Uncompressed graphics	loading	array for the Signpost
; RetroKoH VRAM Overhaul
; ---------------------------------------------------------------------------
SignpostDynPLC:	mappingsTable
	mappingsTableEntry.w	SignpostPLC_Eggman
	mappingsTableEntry.w	SignpostPLC_Spin1
	mappingsTableEntry.w	SignpostPLC_Spin2
	mappingsTableEntry.w	SignpostPLC_Spin3
	mappingsTableEntry.w	SignpostPLC_Sonic

SignpostPLC_Eggman:	dplcHeader
	dplcEntry	$C, 0
	dplcEntry	5, $38
SignpostPLC_Eggman_End

SignpostPLC_Spin1:	dplcHeader
	dplcEntry	$10, $C
	dplcEntry	2, $38
SignpostPLC_Spin1_End

SignpostPLC_Spin2:	dplcHeader
	dplcEntry	4, $1C
	dplcEntry	2, $38
SignpostPLC_Spin2_End

SignpostPLC_Spin3:	dplcHeader
	dplcEntry	$10, $C
	dplcEntry	2, $38
SignpostPLC_Spin3_End

SignpostPLC_Sonic:	dplcHeader
	dplcEntry	$C, $20
	dplcEntry	$C, $2C
	dplcEntry	2, $38
SignpostPLC_Sonic_End

	even
