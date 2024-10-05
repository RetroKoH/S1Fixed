; Art files for Optimal Title Card loading

Art_TitleCardZones:
	dc.l	Art_TitCardGHZ, ((Art_TitCardGHZ_End-Art_TitCardGHZ)/tile_size)-1
	dc.l	Art_TitCardLZ, ((Art_TitCardLZ_End-Art_TitCardLZ)/tile_size)-1
	dc.l	Art_TitCardMZ, ((Art_TitCardMZ_End-Art_TitCardMZ)/tile_size)-1
	dc.l	Art_TitCardSLZ, ((Art_TitCardSLZ_End-Art_TitCardSLZ)/tile_size)-1
	dc.l	Art_TitCardSYZ, ((Art_TitCardSYZ_End-Art_TitCardSYZ)/tile_size)-1
	dc.l	Art_TitCardSBZ, ((Art_TitCardSBZ_End-Art_TitCardSBZ)/tile_size)-1
; Final Zone is handled as an exception
; SBZ3 is technically LZ

Art_TitCardGHZ:
	binclude	"artunc/Title and End Cards/Green Hill.bin"
Art_TitCardGHZ_End:	even

Art_TitCardLZ:
	binclude	"artunc/Title and End Cards/Labyrinth.bin"
Art_TitCardLZ_End:	even

Art_TitCardMZ:
	binclude	"artunc/Title and End Cards/Marble.bin"
Art_TitCardMZ_End:	even

Art_TitCardSLZ:
	binclude	"artunc/Title and End Cards/Star Light.bin"
Art_TitCardSLZ_End:	even

Art_TitCardSYZ:
	binclude	"artunc/Title and End Cards/Spring Yard.bin"
Art_TitCardSYZ_End:	even

Art_TitCardSBZ:
	binclude	"artunc/Title and End Cards/Scrap Brain.bin"
Art_TitCardSBZ_End:	even

Art_TitCardFZ:
	binclude	"artunc/Title and End Cards/Final.bin"
Art_TitCardFZ_End:	even

Art_TitCardZone:
	binclude	"artunc/Title and End Cards/Zone.bin"
Art_TitCardZone_End:	even

Art_TitCardItems:
	binclude	"artunc/Title and End Cards/Card Items.bin"
Art_TitCardItems_End:	even

Art_TitCardOval: equ (Art_TitCardItems+($12*tile_size))
Art_TitCardOvalCt: equ $F	; number of tiles for the oval - 1
	even

Art_TitCardSonic:
	binclude	"artunc/Title and End Cards/Sonic.bin"
Art_TitCardSonic_End:	even

Art_TitCardHasPassed:
	binclude	"artunc/Title and End Cards/Has Passed.bin"
Art_TitCardHasPassed_End:	even

Art_TitCardSpecStage:
	binclude	"artunc/Title and End Cards/Special Stage.bin"
Art_TitCardSpecStage_End:	even

Art_TitCardChaosEmlds:
	binclude	"artunc/Title and End Cards/Chaos Emeralds.bin"
Art_TitCardChaosEmlds_End:	even

Art_TitCardGotThemAll:
	binclude	"artunc/Title and End Cards/Got Them All.bin"
Art_TitCardGotThemAll_End:	even

Art_TitCardContinue:
	binclude	"artunc/Title and End Cards/Continue.bin"
Art_TitCardContinue_End:	even

Art_TitCardBonuses:
	binclude	"artunc/Title and End Cards/Bonuses.bin"
Art_TitCardBonuses_End:	even
