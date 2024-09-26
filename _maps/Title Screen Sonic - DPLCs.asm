; Uncomment this only if you need to ensure art is within a 128kB bank
dplcTiles := Art_TitleSonic

TSonDynPLC:	mappingsTable
	mappingsTableEntry.w	TSonDPLC_0
	mappingsTableEntry.w	TSonDPLC_1
	mappingsTableEntry.w	TSonDPLC_2
	mappingsTableEntry.w	TSonDPLC_3
	mappingsTableEntry.w	TSonDPLC_4
	mappingsTableEntry.w	TSonDPLC_5
	mappingsTableEntry.w	TSonDPLC_6
	mappingsTableEntry.w	TSonDPLC_7

TSonDPLC_0:	dplcHeader
	dplcEntry $10, 0
	dplcEntry $10, $10
	dplcEntry $10, $20
	dplcEntry $10, $30
	dplcEntry $F, $40
TSonDPLC_0_End

TSonDPLC_1:	dplcHeader
	dplcEntry $10, $1BD
	dplcEntry 3, $1CD
	dplcEntry $10, $4F
	dplcEntry $10, $5F
	dplcEntry $10, $6F
	dplcEntry $10, $7F
	dplcEntry $10, $8F
	dplcEntry 4, $9F
TSonDPLC_1_End

TSonDPLC_2:	dplcHeader
	dplcEntry $10, $1BD
	dplcEntry 3, $1CD
	dplcEntry $10, $1A9
	dplcEntry 4, $1B9
	dplcEntry $10, $4F
	dplcEntry $10, $5F
	dplcEntry $10, $6F
	dplcEntry $10, $7F
	dplcEntry $10, $8F
	dplcEntry 4, $9F
TSonDPLC_2_End

TSonDPLC_3:	dplcHeader
	dplcEntry $10, $A3
	dplcEntry $10, $B3
	dplcEntry $10, $C3
	dplcEntry $10, $D3
	dplcEntry $10, $E3
	dplcEntry 3, $F3
TSonDPLC_3_End

TSonDPLC_4:	dplcHeader
	dplcEntry $10, $F6
	dplcEntry $10, $106
	dplcEntry $10, $116
	dplcEntry $10, $126
	dplcEntry $10, $136
	dplcEntry 4, $146
TSonDPLC_4_End

TSonDPLC_5:	dplcHeader
	dplcEntry $10, $1E4
	dplcEntry 5, $1F4
	dplcEntry $10, $14A
	dplcEntry $10, $15A
	dplcEntry $10, $16A
	dplcEntry $10, $17A
	dplcEntry $10, $18A
	dplcEntry $F, $19A
TSonDPLC_5_End

TSonDPLC_6:	dplcHeader
	dplcEntry $10, $1E4
	dplcEntry 5, $1F4
	dplcEntry $10, $1D0
	dplcEntry 4, $1E0
	dplcEntry $10, $14A
	dplcEntry $10, $15A
	dplcEntry $10, $16A
	dplcEntry $10, $17A
	dplcEntry $10, $18A
	dplcEntry $F, $19A
TSonDPLC_6_End

TSonDPLC_7:	dplcHeader
	dplcEntry $10, $1F9
	dplcEntry 4, $209
	dplcEntry $10, $1D0
	dplcEntry 4, $1E0
	dplcEntry $10, $14A
	dplcEntry $10, $15A
	dplcEntry $10, $16A
	dplcEntry $10, $17A
	dplcEntry $10, $18A
	dplcEntry $F, $19A
TSonDPLC_7_End

	even

; Uncomment this only if you need to ensure art is within a 128kB bank
dplcTiles := 0