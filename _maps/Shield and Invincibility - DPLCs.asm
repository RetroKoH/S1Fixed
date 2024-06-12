; ---------------------------------------------------------------------------
; Uncompressed graphics	loading	array for Shields
; RetroKoH VRAM Overhaul
; ---------------------------------------------------------------------------
ShieldDynPLC:	mappingsTable
	mappingsTableEntry.w	ShieldPLC_1
	mappingsTableEntry.w	ShieldPLC_2
	mappingsTableEntry.w	ShieldPLC_3
	mappingsTableEntry.w	ShieldPLC_4
	mappingsTableEntry.w	StarPLC_1
	mappingsTableEntry.w	StarPLC_2
	mappingsTableEntry.w	StarPLC_3
	mappingsTableEntry.w	StarPLC_4

ShieldPLC_1:	dplcHeader
ShieldPLC_1_End

ShieldPLC_2:	dplcHeader
	dplcEntry	9, 0
	dplcEntry	9, 9
ShieldPLC_2_End

ShieldPLC_3:	dplcHeader
	dplcEntry	9, $12
ShieldPLC_3_End

ShieldPLC_4:	dplcHeader
	dplcEntry	9, 0
	dplcEntry	9, 9
ShieldPLC_4_End

StarPLC_1:	dplcHeader
	dplcEntry	9, 0
	dplcEntry	9, 9
StarPLC_1_End

StarPLC_2:	dplcHeader
	dplcEntry	9, 0
	dplcEntry	9, 9
StarPLC_2_End

StarPLC_3:	dplcHeader
	dplcEntry	9, $12
	dplcEntry	9, $1B
StarPLC_3_End

StarPLC_4:	dplcHeader
	dplcEntry	9, $12
	dplcEntry	9, $1B
StarPLC_4_End

	even
