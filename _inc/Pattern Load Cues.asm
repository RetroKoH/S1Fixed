; ---------------------------------------------------------------------------
; Pattern load cues
; ---------------------------------------------------------------------------
ArtLoadCues:		offsetTable
ptr_PLC_Main:			offsetTableEntry.w PLC_Main
ptr_PLC_Main2:			offsetTableEntry.w PLC_Main2
ptr_PLC_Explode:		offsetTableEntry.w PLC_Explode
ptr_PLC_GameOver:		offsetTableEntry.w PLC_GameOver

ptr_PLC_Boss:			offsetTableEntry.w PLC_Boss
ptr_PLC_Boss_GHZ:		offsetTableEntry.w PLC_Boss_GHZ
ptr_PLC_Boss_MZ:		offsetTableEntry.w PLC_Boss_MZ
ptr_PLC_Boss_SYZ:		offsetTableEntry.w PLC_Boss_SYZ
ptr_PLC_Boss_SLZ:		offsetTableEntry.w PLC_Boss_SLZ
ptr_PLC_Signpost:		offsetTableEntry.w PLC_Signpost
ptr_PLC_SpecialStage:	offsetTableEntry.w PLC_SpecialStage

PLC_Animals:
ptr_PLC_GHZAnimals:		offsetTableEntry.w PLC_GHZAnimals
ptr_PLC_LZAnimals:		offsetTableEntry.w PLC_LZAnimals
ptr_PLC_MZAnimals:		offsetTableEntry.w PLC_MZAnimals
ptr_PLC_SLZAnimals:		offsetTableEntry.w PLC_SLZAnimals
ptr_PLC_SYZAnimals:		offsetTableEntry.w PLC_SYZAnimals
ptr_PLC_SBZAnimals:		offsetTableEntry.w PLC_SBZAnimals
			zonewarning PLC_Animals,2

ptr_PLC_SSResult:		offsetTableEntry.w PLC_SSResult
ptr_PLC_Ending:			offsetTableEntry.w PLC_Ending
ptr_PLC_TryAgain:		offsetTableEntry.w PLC_TryAgain
ptr_PLC_EggmanSBZ2:		offsetTableEntry.w PLC_EggmanSBZ2
ptr_PLC_FZBoss:			offsetTableEntry.w PLC_FZBoss

plcm:	macro gfx,vram
	dc.l gfx
	dc.w (vram)*$20
	endm

; ---------------------------------------------------------------------------
; Pattern load cues - standard block 1
; ---------------------------------------------------------------------------
PLC_Main:	dc.w ((PLC_Mainend-PLC_Main-2)/6)-1
		plcm	Nem_Hud,			ArtTile_HUD						; HUD
		plcm	Nem_Lives,			ArtTile_Lives_Counter			; lives counter
PLC_Mainend:

; ---------------------------------------------------------------------------
; Pattern load cues - standard block 2
; ---------------------------------------------------------------------------
PLC_Main2:	dc.w ((PLC_Main2end-PLC_Main2-2)/6)-1
		plcm	Nem_Lamp,			ArtTile_Lamppost				; lamppost
		plcm	Nem_Sparkles,		ArtTile_RingSparkles			; ring sparkles
		plcm	Nem_Monitors,		ArtTile_Monitor					; monitors
		plcm	Nem_Points,			ArtTile_Points					; points from enemies
PLC_Main2end:

; ---------------------------------------------------------------------------
; Pattern load cues - explosion
; ---------------------------------------------------------------------------
PLC_Explode:	dc.w ((PLC_Explodeend-PLC_Explode-2)/6)-1
		plcm	Nem_Explode,		ArtTile_Explosion				; explosion
PLC_Explodeend:

; ---------------------------------------------------------------------------
; Pattern load cues - game over
; ---------------------------------------------------------------------------
PLC_GameOver:	dc.w ((PLC_GameOverend-PLC_GameOver-2)/6)-1
		plcm	Nem_GameOver,		ArtTile_Game_Over				; game over
PLC_GameOverend:

; ---------------------------------------------------------------------------
; Pattern load cues - LZ act 3 boss -- RetroKoH VRAM Overhaul
; ---------------------------------------------------------------------------
PLC_Boss:	dc.w ((PLC_Bossend-PLC_Boss-2)/6)-1
		plcm	Nem_Eggman,			ArtTile_Eggman					; Eggman main patterns
		plcm	Nem_Prison,			ArtTile_Prison_Capsule			; prison capsule
PLC_Bossend:

; ---------------------------------------------------------------------------
; Pattern load cues - GHZ act 3 boss -- RetroKoH VRAM Overhaul
; ---------------------------------------------------------------------------
PLC_Boss_GHZ:	dc.w ((PLC_Boss_GHZend-PLC_Boss_GHZ-2)/6)-1
		plcm	Nem_Eggman,			ArtTile_Eggman					; Eggman main patterns
		plcm	Nem_Weapons_GHZ,	ArtTile_Eggman_Weapons			; Eggman's chain base (6 tiles)
		plcm	Nem_Prison,			ArtTile_Prison_Capsule			; prison capsule
PLC_Boss_GHZend:

; ---------------------------------------------------------------------------
; Pattern load cues - MZ act 3 boss -- RetroKoH VRAM Overhaul
; ---------------------------------------------------------------------------
PLC_Boss_MZ:	dc.w ((PLC_Boss_MZend-PLC_Boss_MZ-2)/6)-1
		plcm	Nem_Eggman,			ArtTile_Eggman					; Eggman main patterns
		plcm	Nem_Weapons_MZ,		ArtTile_Eggman_Weapons			; Eggman's lava cannon (4 tiles)
		plcm	Nem_Prison,			ArtTile_Prison_Capsule			; prison capsule
PLC_Boss_MZend:

; ---------------------------------------------------------------------------
; Pattern load cues - SYZ act 3 boss -- RetroKoH VRAM Overhaul
; ---------------------------------------------------------------------------
PLC_Boss_SYZ:	dc.w ((PLC_Boss_SYZend-PLC_Boss_SYZ-2)/6)-1
		plcm	Nem_Eggman,			ArtTile_Eggman					; Eggman main patterns
		plcm	Nem_Weapons_SYZ,	ArtTile_Eggman_Weapons			; Eggman's spiker (5 tiles)
		plcm	Nem_Prison,			ArtTile_Prison_Capsule			; prison capsule
PLC_Boss_SYZend:

; ---------------------------------------------------------------------------
; Pattern load cues - SLZ act 3 boss -- RetroKoH VRAM Overhaul
; ---------------------------------------------------------------------------
PLC_Boss_SLZ:	dc.w ((PLC_Boss_SLZend-PLC_Boss_SLZ-2)/6)-1
		plcm	Nem_Eggman,			ArtTile_Eggman					; Eggman main patterns
		plcm	Nem_Weapons_SLZ,	ArtTile_Eggman_Weapons			; Eggman's weapons (6 tiles)
		plcm	Nem_Prison,			ArtTile_Prison_Capsule			; prison capsule
PLC_Boss_SLZend:

; ---------------------------------------------------------------------------
; Pattern load cues - act 1/2 signpost -- RetroKoH VRAM Overhaul
; ---------------------------------------------------------------------------
PLC_Signpost:	dc.w ((PLC_Signpostend-PLC_Signpost-2)/6)-1
		plcm	Nem_Bonus,			ArtTile_Hidden_Points			; hidden bonus points
PLC_Signpostend:

; ---------------------------------------------------------------------------
; Pattern load cues - special stage
; ---------------------------------------------------------------------------
PLC_SpecialStage:	dc.w ((PLC_SpeStageend-PLC_SpecialStage-2)/6)-1
		plcm	Nem_SSBgCloud,  ArtTile_SS_Background_Clouds	; bubble and cloud background
		plcm	Nem_SSBgFish,   ArtTile_SS_Background_Fish		; bird and fish background

	if DynamicSpecialStageWalls=1	; Mercury Dynamic Special Stage Walls
		plcm	Nem_Hud,		ArtTile_SS_HUD					; HUD
		plcm	Nem_Lives,		ArtTile_SS_Lives				; lives
	else
		plcm	Nem_SSWalls,	ArtTile_SS_Wall					; walls
	endif	; Dynamic Special Stage Walls End

		plcm	Nem_Bumper,     ArtTile_SS_Bumper				; bumper
		plcm	Nem_SSGOAL,     ArtTile_SS_Goal					; GOAL block
		plcm	Nem_SSUpDown,   ArtTile_SS_Up_Down				; UP and DOWN blocks
		plcm	Nem_SSRBlock,   ArtTile_SS_R_Block				; R block
		plcm	Nem_SS1UpBlock, ArtTile_SS_Extra_Life			; 1UP block
		plcm	Nem_SSEmStars,  ArtTile_SS_Emerald_Sparkle		; emerald collection stars
		plcm	Nem_SSRedWhite, ArtTile_SS_Red_White_Block		; red and white block
		plcm	Nem_SSGhost,    ArtTile_SS_Ghost_Block			; ghost block
		plcm	Nem_SSWBlock,   ArtTile_SS_W_Block				; W block
		plcm	Nem_SSGlass,    ArtTile_SS_Glass				; glass block
		plcm	Nem_SSEmerald,  ArtTile_SS_Emerald				; emeralds
;		plcm	Nem_SSZone1,    ArtTile_SS_Zone_1				; ZONE X block
		plcm	Nem_Sparkles,	ArtTile_SS_RingSparkles			; ring sparkles
		plcm	Nem_SSCursor,	ArtTile_SS_Cursor				; Debug Mode Cursor
		plcm	Nem_SSDelete,	ArtTile_SS_Delete				; Delete Icon (Debug)
PLC_SpeStageend:

; ---------------------------------------------------------------------------
; Pattern load cues - GHZ animals
; ---------------------------------------------------------------------------
PLC_GHZAnimals:	dc.w ((PLC_GHZAnimalsend-PLC_GHZAnimals-2)/6)-1
		plcm	Nem_Rabbit, ArtTile_Animal_1 ; rabbit
		plcm	Nem_Flicky, ArtTile_Animal_2 ; flicky
PLC_GHZAnimalsend:

; ---------------------------------------------------------------------------
; Pattern load cues - LZ animals
; ---------------------------------------------------------------------------
PLC_LZAnimals:	dc.w ((PLC_LZAnimalsend-PLC_LZAnimals-2)/6)-1
		plcm	Nem_Penguin, ArtTile_Animal_1 ; penguin
		plcm	Nem_Seal,    ArtTile_Animal_2 ; seal
PLC_LZAnimalsend:

; ---------------------------------------------------------------------------
; Pattern load cues - MZ animals
; ---------------------------------------------------------------------------
PLC_MZAnimals:	dc.w ((PLC_MZAnimalsend-PLC_MZAnimals-2)/6)-1
		plcm	Nem_Squirrel, ArtTile_Animal_1 ; squirrel
		plcm	Nem_Seal,     ArtTile_Animal_2 ; seal
PLC_MZAnimalsend:

; ---------------------------------------------------------------------------
; Pattern load cues - SLZ animals
; ---------------------------------------------------------------------------
PLC_SLZAnimals:	dc.w ((PLC_SLZAnimalsend-PLC_SLZAnimals-2)/6)-1
		plcm	Nem_Pig,    ArtTile_Animal_1 ; pig
		plcm	Nem_Flicky, ArtTile_Animal_2 ; flicky
PLC_SLZAnimalsend:

; ---------------------------------------------------------------------------
; Pattern load cues - SYZ animals
; ---------------------------------------------------------------------------
PLC_SYZAnimals:	dc.w ((PLC_SYZAnimalsend-PLC_SYZAnimals-2)/6)-1
		plcm	Nem_Pig,     ArtTile_Animal_1 ; pig
		plcm	Nem_Chicken, ArtTile_Animal_2 ; chicken
PLC_SYZAnimalsend:

; ---------------------------------------------------------------------------
; Pattern load cues - SBZ animals
; ---------------------------------------------------------------------------
PLC_SBZAnimals:	dc.w ((PLC_SBZAnimalsend-PLC_SBZAnimals-2)/6)-1
		plcm	Nem_Rabbit,  ArtTile_Animal_1 ; rabbit
		plcm	Nem_Chicken, ArtTile_Animal_2 ; chicken
PLC_SBZAnimalsend:

; ---------------------------------------------------------------------------
; Pattern load cues - special stage results screen
; ---------------------------------------------------------------------------
PLC_SSResult:dc.w ((PLC_SpeStResultend-PLC_SSResult-2)/6)-1
		plcm	Nem_ResultEm,  ArtTile_SS_Results_Emeralds ; emeralds
		plcm	Nem_MiniSonic, ArtTile_Mini_Sonic          ; mini Sonic
PLC_SpeStResultend:

; ---------------------------------------------------------------------------
; Pattern load cues - ending sequence
; ---------------------------------------------------------------------------
PLC_Ending:	dc.w ((PLC_Endingend-PLC_Ending-2)/6)-1
		plcm	Nem_Stalk,     ArtTile_GHZ_Flower_Stalk ; flower stalk (4)
		plcm	Nem_EndFlower, ArtTile_Ending_Flowers   ; flowers (37)
		plcm	Nem_EndEm,     ArtTile_Ending_Emeralds  ; emeralds (28)
		plcm	Nem_EndSonic,  ArtTile_Ending_Sonic     ; Sonic (323)
		plcm	Nem_Rabbit,    ArtTile_Ending_Rabbit    ; rabbit (18)
		plcm	Nem_Chicken,   ArtTile_Ending_Chicken   ; chicken (14)
		plcm	Nem_Penguin,   ArtTile_Ending_Penguin   ; penguin (18)
		plcm	Nem_Seal,      ArtTile_Ending_Seal      ; seal (14)
		plcm	Nem_Pig,       ArtTile_Ending_Pig       ; pig (18)
		plcm	Nem_Flicky,    ArtTile_Ending_Flicky    ; flicky (14)
		plcm	Nem_Squirrel,  ArtTile_Ending_Squirrel  ; squirrel (18)
		plcm	Nem_EndStH,    ArtTile_Ending_STH       ; "SONIC THE HEDGEHOG" (48)
PLC_Endingend:

; ---------------------------------------------------------------------------
; Pattern load cues - "TRY AGAIN" and "END" screens
; ---------------------------------------------------------------------------
PLC_TryAgain:	dc.w ((PLC_TryAgainend-PLC_TryAgain-2)/6)-1
		plcm	Nem_EndEm,      ArtTile_Try_Again_Emeralds ; emeralds
		plcm	Nem_TryAgain,   ArtTile_Try_Again_Eggman   ; Eggman
		plcm	Nem_CreditText, ArtTile_Credits_Font       ; credits alphabet
PLC_TryAgainend:

; ---------------------------------------------------------------------------
; Pattern load cues - Eggman in SBZ2
; ---------------------------------------------------------------------------
PLC_EggmanSBZ2:	dc.w ((PLC_EggmanSBZ2end-PLC_EggmanSBZ2-2)/6)-1
		plcm	Nem_SbzBlock,   ArtTile_Eggman_Trap_Floor	; block
		plcm	Nem_Sbz2Eggman, ArtTile_Eggman				; Eggman
		plcm	Nem_LzSwitch,   ArtTile_Eggman_Button		; switch
PLC_EggmanSBZ2end:

; ---------------------------------------------------------------------------
; Pattern load cues - final boss
; ---------------------------------------------------------------------------
PLC_FZBoss:	dc.w ((PLC_FZBossend-PLC_FZBoss-2)/6)-1
		plcm	Nem_FzEggman,   ArtTile_FZ_Eggman_Fleeing    ; Eggman after boss
		plcm	Nem_FzBoss,     ArtTile_FZ_Boss              ; FZ boss
		plcm	Nem_Eggman,     ArtTile_Eggman               ; Eggman main patterns
		plcm	Nem_Sbz2Eggman, ArtTile_FZ_Eggman_No_Vehicle ; Eggman without ship
PLC_FZBossend:

; ---------------------------------------------------------------------------
; Pattern load cue IDs
; ---------------------------------------------------------------------------
plcid_Main:			equ (ptr_PLC_Main-ArtLoadCues)/2			; 0
plcid_Main2:		equ (ptr_PLC_Main2-ArtLoadCues)/2			; 1
plcid_Explode:		equ (ptr_PLC_Explode-ArtLoadCues)/2			; 2
plcid_GameOver:		equ (ptr_PLC_GameOver-ArtLoadCues)/2		; 3

plcid_Boss:			equ (ptr_PLC_Boss-ArtLoadCues)/2			; 4
plcid_Boss_GHZ:		equ (ptr_PLC_Boss_GHZ-ArtLoadCues)/2		; 5
plcid_Boss_MZ:		equ (ptr_PLC_Boss_MZ-ArtLoadCues)/2			; 6
plcid_Boss_SYZ:		equ (ptr_PLC_Boss_SYZ-ArtLoadCues)/2		; 7
plcid_Boss_SLZ:		equ (ptr_PLC_Boss_SLZ-ArtLoadCues)/2		; 8
plcid_Signpost:		equ (ptr_PLC_Signpost-ArtLoadCues)/2		; 9
plcid_SpecialStage:	equ (ptr_PLC_SpecialStage-ArtLoadCues)/2	; $A

plcid_GHZAnimals:	equ (ptr_PLC_GHZAnimals-ArtLoadCues)/2		; $B
plcid_LZAnimals:	equ (ptr_PLC_LZAnimals-ArtLoadCues)/2		; $C
plcid_MZAnimals:	equ (ptr_PLC_MZAnimals-ArtLoadCues)/2		; $D
plcid_SLZAnimals:	equ (ptr_PLC_SLZAnimals-ArtLoadCues)/2		; $E
plcid_SYZAnimals:	equ (ptr_PLC_SYZAnimals-ArtLoadCues)/2		; $F
plcid_SBZAnimals:	equ (ptr_PLC_SBZAnimals-ArtLoadCues)/2		; $10

plcid_SSResult:		equ (ptr_PLC_SSResult-ArtLoadCues)/2		; $11
plcid_Ending:		equ (ptr_PLC_Ending-ArtLoadCues)/2			; $12
plcid_TryAgain:		equ (ptr_PLC_TryAgain-ArtLoadCues)/2		; $13
plcid_EggmanSBZ2:	equ (ptr_PLC_EggmanSBZ2-ArtLoadCues)/2		; $14
plcid_FZBoss:		equ (ptr_PLC_FZBoss-ArtLoadCues)/2			; $15
