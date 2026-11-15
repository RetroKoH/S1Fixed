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
	binclude	"artunc/Title and End Cards/Green Hill.unc"
Art_TitCardGHZ_End:	even

Art_TitCardLZ:
	binclude	"artunc/Title and End Cards/Labyrinth.unc"
Art_TitCardLZ_End:	even

Art_TitCardMZ:
	binclude	"artunc/Title and End Cards/Marble.unc"
Art_TitCardMZ_End:	even

Art_TitCardSLZ:
	binclude	"artunc/Title and End Cards/Star Light.unc"
Art_TitCardSLZ_End:	even

Art_TitCardSYZ:
	if ProtoZoneNames
	binclude	"artunc/Title and End Cards/Sparkling.unc"
	else
	binclude	"artunc/Title and End Cards/Spring Yard.unc"
	endif
Art_TitCardSYZ_End:	even

Art_TitCardSBZ:
	if ProtoZoneNames
	binclude	"artunc/Title and End Cards/Clock Work.unc"
	else
	binclude	"artunc/Title and End Cards/Scrap Brain.unc"
	endif
Art_TitCardSBZ_End:	even

Art_TitCardFZ:
	binclude	"artunc/Title and End Cards/Final.unc"
Art_TitCardFZ_End:	even

Art_TitCardZone:
	binclude	"artunc/Title and End Cards/Zone.unc"
Art_TitCardZone_End:	even

Art_TitCardItems:
	binclude	"artunc/Title and End Cards/Card Items.unc"
Art_TitCardItems_End:	even

Art_TitCardOval: equ (Art_TitCardItems+($12*tile_size))
Art_TitCardOvalCt: equ $F	; number of tiles for the oval - 1
	even

Art_TitCardSonic:
	binclude	"artunc/Title and End Cards/Sonic.unc"
Art_TitCardSonic_End:	even

Art_TitCardHasPassed:
	binclude	"artunc/Title and End Cards/Has Passed.unc"
Art_TitCardHasPassed_End:	even

Art_TitCardSpecStage:
	binclude	"artunc/Title and End Cards/Special Stage.unc"
Art_TitCardSpecStage_End:	even

Art_TitCardChaosEmlds:
	binclude	"artunc/Title and End Cards/Chaos Emeralds.unc"
Art_TitCardChaosEmlds_End:	even

Art_TitCardGotThemAll:
	binclude	"artunc/Title and End Cards/Got Them All.unc"
Art_TitCardGotThemAll_End:	even

Art_TitCardContinue:
	binclude	"artunc/Title and End Cards/Continue.unc"
Art_TitCardContinue_End:	even

Art_TitCardBonuses:
	binclude	"artunc/Title and End Cards/Bonuses.unc"
Art_TitCardBonuses_End:	even

; RetroKoH Perfect Bonus Mod
	if PerfectBonusEnabled
Art_Perfect:	binclude	"artunc/Title and End Cards/Perfect Bonus.unc"	; Result Perfect Bonus Text
Art_Perfect_End:
	endif
