; ---------------------------------------------------------------------------
; Sonic 1 Dynamic PLC Script - Eggman's face
; ---------------------------------------------------------------------------

DynPLC_BossFace:	mappingsTable
	mappingsTableEntry.w	.facenormal1
	mappingsTableEntry.w	.facenormal2
	mappingsTableEntry.w	.facelaugh1
	mappingsTableEntry.w	.facelaugh2
	mappingsTableEntry.w	.facehit
	mappingsTableEntry.w	.facepanic
	mappingsTableEntry.w	.facedefeat

.facenormal1:	dplcHeader
	dplcEntry	$A, 0
.facenormal1_End

.facenormal2:	dplcHeader
	dplcEntry	2, 0
	dplcEntry	8, $A
.facenormal2_End

.facelaugh1:	dplcHeader
	dplcEntry	$D, $12
.facelaugh1_End

.facelaugh2:	dplcHeader
	dplcEntry	$D, $1F
.facelaugh2_End

.facehit:	dplcHeader
	dplcEntry	$D, $2C
.facehit_End

.facepanic:	dplcHeader
	dplcEntry	2, 0
	dplcEntry	8, $A
	dplcEntry	2, $3F
.facepanic_End

.facedefeat:	dplcHeader
	dplcEntry	$D, $2C
	dplcEntry	6, $39
.facedefeat_End

	even
