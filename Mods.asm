; ================================================================================
; Toggleable Mods (Sorted by Context)
; ================================================================================

; ----- PLAYER ABILITIES ---------------------------------------------------------

; Name: Spin Dash
; Credit: SCHG, DeltaW, Mercury
; Function: Enables the Sonic 2 Spin Dash
SpinDashEnabled: = 1
	SkidDustEnabled: = 1					; if set to 1, Skid dust will occur when coming to a stop.
	SpinDashCancel: = SpinDashEnabled*1		; if set to 1, Spin Dash can be cancelled by not pressing ABC
	SpinDashNoRevDown: = SpinDashEnabled*1	; if set to 1, Spin Dash will not rev down so long as ABC is held down
; (TO-DO: Add the CD Spindash variant)

; Name: Peelout
; Credit: DeltaW, Mercury
; Function: Enables the Sonic CD Peelout. Also enables the dashing animation while running.
PeeloutEnabled: = 1

; Name: Air Roll
; Credit: RetroKoH (Inspired by a guide by Inferno Gear)
; Function: Enables the Air Roll from Sonic Triple Trouble
AirRollEnabled: = 0						; double-jumps are not enabled when air rolling (toggleable perhaps?)

; Name: Drop Dash (Incomplete: Need to reset animation if Drop Dash is cancelled)
; Credit: DeltaW, Gio.vanni, Hitaxas, RetroKoH
; Function: Enables the Drop Dash from Sonic Mania & Origins
DropDashEnabled: = 1

; Name: Elemental Shields (Incomplete: Minor bugfixes)
; Credit: RetroKoH, DeltaW
; Function: Enables the usage of S3K Shields and abilities.
ShieldsMode: = 0						; 0 - Blue Shield only, 1 - Blue + Instashield, 2 - Blue + Elementals, 3 - Elementals only.

; Name: 7th Emerald and Super Sonic (Incomplete: Minor Bugfixes)
; Credit: RetroKoH (Palette Credit: Clownacy)
; Function: Adds 7th Special Stage, 7th Emerald and Super Sonic Form
SuperMod: = 1

; ----- GAMEPLAY TWEAKS ----------------------------------------------------------

; Name: Disable Speed Caps
; Credit: Mercury (Ground/Air), RetroKoH (Applied to Devon's Rolling Speed Cap Fix)
; Function: Toggles the speed caps (The original game has all 3 caps active by default)
GroundSpeedCapEnabled: = 0				; if set to 1, the ground speed cap is active
AirSpeedCapEnabled: = 0					; if set to 1, the air speed cap is active
RollSpeedCapEnabled: = 0				; if set to 1, the rolling speed cap is active (fixed by Devon)

; Name: Original Roll Jump Toggle
; Credit: Mercury
; Function: When turned on, Sonic retains his original roll jump lock (See _incObj/Sonic Jump.asm)
RollJumpLockActive: = 0					; if set to 1, the original roll jump lock is maintained

; Name: Spike Fix Mod
; Credit: FraGag
; Function: Prevents spikes from harming Sonic while he's flashing.
SpikeBugFix: = 1						; if set to 1, the spike "bug" is fixed

; Name: Rebound Mod
; Credit: Mercury
; Function: Makes rebounding from enemies/monitors after rolling off a cliff onto them function the same as if they were jumped on - the rebound is cut short if the jump button is released. 
ReboundMod: = 0

; Name: CD Balancing Mod
; Credit: Mercury
; Function: Uses the Sonic CD balancing sprites (forward and back) instead of Sonic 1's.
CDBalancing: = 1

; Name: CD Camera Panning
; Credit: DeltaW's Wooloo Engine
; Function: Applies a panning effect to the screen when moving quickly, a la Sonic CD
CDCamera: = 0							; if set to 1, screen will pan forward, a la Sonic CD

; Name: S3K AfterImages (Incomplete: Add for Super Sonic)
; Credit: Hitaxas (Wooloo Engine)
; Function: Applies After-Image effects to the Speed Shoes
AfterImagesOn: = 1

; Name: Limit LZ Block Rising Speed
; Credit: Mercury
; Function: Limits the rising speed of blocks in LZ so that Sonic can jump off them more comfortably.
LimitLZBlockRisingSpeed: = 1			; if set to 1, LZ Rising platforms are speed-capped

; Name: Speed Up/Instant Score Tally
; Credit: Mercury/RetroKoH
; Function: Allows the player to hold a button to speed up the score tally, or just have it occur immediately
SpeedUpScoreTally: = 2					; if set to 1, score tally can be sped up w/ ABC. If 2, it automatically tallies immediately.

; ----- FLAIR MODS ---------------------------------------------------------------

; Name: Fade-In SEGA Screen
; Credit: RetroKoH
; Function: Causes the SEGA Screen to fade in, instead of just popping in.
FadeInSEGA: = 1							; if set to 1, the SEGA screen smoothly fades in

; Name: Screen Fading Options
; Credit: RetroKoH/MarkeyJester
; Function: Screens now fade in/out in one of 7 different ways: (Blue, Green, Red, Cyan, Magenta, Yellow, and Full)
PaletteFadeSetting: = 6					; 0 - Blue (Original), 1 - Green, 2 - Red, 3 - Cyan (B+G), 4 - Pink (B+R), 5 - Yellow (G+R), 6 - Full

; Name: GHZ Water Palette Mod
; Credit: Sonic 1 Forever Team
; Function: Toggles GHZ palette between original and Sonic 1 Forever's altered bg water.
GHZForeverPal: = 1						; if set to 1, GHZ is set to Sonic 1 Forever's palette

; Name: Warm Palette Mod (Incomplete)
; Credit: Mercury/RetroKoH
; Function: Gives the game a warmer, Chaotix-like feel. (Continuation of Mercury's mod)
WarmPalettes: = 0

; Name: Objects Don't Freeze
; Credit: RetroKoH
; Function: Objects will not freeze when the player dies.
ObjectsFreeze: = 0						; if set to 1, objects freeze on death as normal

; Name: End-of-Level Music Fade
; Credit: RetroKoH
; Function: Toggles whether music will fade out after the level ends.
EndLevelFadeMusic: = 0

; Name: HUD Scrolls Into View
; Credit: RetroKoH
; Function: HUD Scrolls into view during gameplay.
HUDScrolling: = 1

; Name: HUD w/ Leading Zeroes
; Credit: Mercury
; Function: Adds Leading 0's to HUD values (Score, Rings, Lives)
HUDHasLeadingZeroes: = 1				; if set to 1, leading zeroes appear on HUD

; Name: HUD Centiseconds (CURRENTLY BREAKS RING COUNT in Labyrinth Zone)
; Credit: Mercury
; Function: Adds Sonic CD-style centiseconds to the HUD
HUDCentiseconds: = 0

; ----- SPECIAL STAGES -----------------------------------------------------------

; Name: Dynamic Special Stage Walls
; Credit: Mercury
; Function: Dynamically loads the wall art in the Special Stages to free VRAM (for things like the HUD)
DynamicSpecialStageWalls: = 1

; Name: Smooth Special Stage Rotation and Jumping
; Credit: Cinossu and Devon
; Function: Special Stage scrolls smoothly. Movement/Jump angles are also affected.
SmoothSpecialStages: = 1

; Name: Special Stage Index Increases Only If Won
; Credit: Mercury
; Function: Makes the Special Stage index not increase when you fail the stage, allowing you to retry the previous stage.
SpecialStageAdvancementMod: = 1

; Name: HUD (and Time Limits) In Special Stage
; Credit: Mercury/RetroKoH
; Function: Adds HUD to Special Stage. I also fixed one bug w/ Mercury's implementation.
; Depends On: Dynamic Special Stage Walls
HUDInSpecialStage: = DynamicSpecialStageWalls*1
	SpecialStageHUDType: = 1			; 0=normal; 1=score not shown; 2=score & time not shown; 3=rings only
	TimeLimitInSpecialStage: = 1		; if set, time counts down in the Special Stage from a specified time limit
		SSTimeLimitPinch: = $00001E00	; "pinch" threshold that time must reach in order to trigger "TIME" to flash. Format: $000MSSCC
		SSTimeLimitStart: = $00010000	; time on the clock to start with when Special Stage is entered. Format: $000MSSCC
		; NOTE: SSTimeLimitStart must always end in 00

; Mods listed below alter the layouts in real-time. See variable: AlteredSpecialStages
; Name: Sonic 4 Controls in Special Stage
; Credit: RetroKoH
; Function: If active, Special Stages control like Sonic 4 Ep 1 (Left/Right rotate the stage).
S4SpecialStages: = 1	; (Removes UP/DOWN, and R Blocks)

; Name: Special Stages Still Appear With All Emeralds
; Credit: Mercury
; Function: Makes the Special Stages still accessible even once all emeralds are collected.
SpecialStagesWithAllEmeralds: = 1		; (Replaces Emeralds w/ 1-Ups if Emeralds are obtained)

AlteredSpecialStages: = (S4SpecialStages+SpecialStagesWithAllEmeralds)

; ----- UNDER-THE-HOOD -----------------------------------------------------------

; Name: Debug Path Swappers
; Credit: Clownacy/MarkeyJester
; Function: Sound alert when running through the path swapper while Debug Mode is enabled
DebugPathSwappers: = 1

; Name: Chunks In ROM
; Credit: Mercury/FraGag
; Loads Chunks (256x256)/Blocks (16x16) directly from ROM, freeing a huge amount of RAM.
BlocksInROM: = 1						; if set to 1, frees RAM ($0000-$A3FF)
ChunksInROM: = 1						; if set to 1, frees RAM ($B000-$C7FF)