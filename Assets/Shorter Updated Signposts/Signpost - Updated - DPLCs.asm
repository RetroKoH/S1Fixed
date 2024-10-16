SignpostDynPLC: mappingsTable
	mappingsTableEntry.w	SignpostDynPLC_0
	mappingsTableEntry.w	SignpostDynPLC_1
	mappingsTableEntry.w	SignpostDynPLC_2
	mappingsTableEntry.w	SignpostDynPLC_3
	mappingsTableEntry.w	SignpostDynPLC_4

SignpostDynPLC_0:	dplcHeader
 dplcEntry $C, 0
 dplcEntry 8, $38
SignpostDynPLC_0_End

SignpostDynPLC_1:	dplcHeader
 dplcEntry $10, $C
 dplcEntry 8, $38
SignpostDynPLC_1_End

SignpostDynPLC_2:	dplcHeader
 dplcEntry 4, $1C
 dplcEntry 8, $38
SignpostDynPLC_2_End

SignpostDynPLC_3:	dplcHeader
 dplcEntry $10, $C
 dplcEntry 8, $38
SignpostDynPLC_3_End

SignpostDynPLC_4:	dplcHeader
 dplcEntry $C, $20
 dplcEntry $C, $2C
 dplcEntry 8, $38
SignpostDynPLC_4_End

	even