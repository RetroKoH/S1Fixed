; ---------------------------------------------------------------------------
; Sonic 1 Dynamic PLC Script - Eggman's ship flame
; ---------------------------------------------------------------------------

DynPLC_Exhaust:	mappingsTable
	mappingsTableEntry.w	.blank
	mappingsTableEntry.w	.flame1
	mappingsTableEntry.w	.flame2
	mappingsTableEntry.w	.escapeflame1
	mappingsTableEntry.w	.escapeflame2

.blank:	dplcHeader
.blank_End

.flame1:	dplcHeader
	dplcEntry	4, $11
.flame1_End

.flame2:	dplcHeader
	dplcEntry	4, $15
.flame2_End

.escapeflame1:	dplcHeader
	dplcEntry	3, 0
.escapeflame1_End

.escapeflame2:	dplcHeader
	dplcEntry	$E, 3
.escapeflame2_End

	even
