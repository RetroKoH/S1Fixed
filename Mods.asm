; ================================================================================
; Toggleable Mods (Sorted by Context)
; Press Ctrl+Shift+F (Notepad++) and search a toggle name to find all instances in all files
; ================================================================================

; ----- PLAYER ABILITIES ---------------------------------------------------------

; Name: S2 Skid Dust
; Credit: Mercury
; Function: Enables Sonic 2 Skidding Dust
SkidDustEnabled: = 0						; if set to 1, Skid dust will occur when coming to a stop.

; Name: Spin Dash
; Credit: SCHG, DeltaW, Mercury
; Function: Enables the Sonic 2 Spin Dash
SpinDashEnabled: = 0
	SpinDashCancel: = SpinDashEnabled*0		; if set to 1, Spin Dash can be cancelled by not pressing ABC
	SpinDashNoRevDown: = SpinDashEnabled*0	; if set to 1, Spin Dash will not rev down so long as ABC is held down
; (TO-DO: Add the CD Spindash variant)

; Name: Peelout
; Credit: DeltaW, Mercury
; Function: Enables the Sonic CD Peelout. Also enables the dashing animation while running.
PeeloutEnabled: = 0

; Name: Air Roll
; Credit: RetroKoH (Inspired by a guide by Inferno Gear)
; Function: Enables the Air Roll from Sonic Triple Trouble
AirRollEnabled: = 0						; if set to 1, Sonic can curl into a ball in mid-air by pressing Jump while not rolling
	AutoAirRoll: = AirRollEnabled*0				; if set to 1, air roll will occur automatically when moving downward

; Name: Drop Dash (Incomplete: Need to reset animation if Drop Dash is cancelled)
; Credit: DeltaW, giovanni.gen, Hitaxas, RetroKoH
; Function: Enables the Drop Dash from Sonic Mania & Origins
DropDashEnabled: = 0
	DropDustEnabled: = DropDashEnabled*SkidDustEnabled*1	; if set to 1, dust will emanate when drop-dashing
	ReusableDropDash: = DropDashEnabled*0					; if set to 1, you can try drop dashing again after cancelling (original behavior doesn't allow this)
	AirRollIntoDropDash: = AirRollEnabled*DropDashEnabled*1	; if set to 1, you can transition from Air Roll into Drop Dash by holding the jump button.
; NOTE: Auto-Air Roll currently does not allow for a Drop Dash transition unless ReusableDropDash is enabled

; Name: Elemental Shields (Incomplete: Minor bugfixes)
; Credit: RetroKoH, DeltaW
; Function: Enables the usage of S3K Shields and abilities.
InstashieldEnabled: = 0					; if set to 1, instashield is now enabled (Now split from Elemental Shields toggle).
ShieldsMode: = 0						; 0 - Blue Shield only, 1 - Blue + Elementals, 2 - Elementals only.
S3KDoubleJump: = (InstashieldEnabled|ShieldsMode)>0
	RingMagnetRange: = $40				; The range of the lightning shield's ring magnetism

; Name: Wall Jump (Incomplete -- Not fully compatible with all double jump mechanics)
; Credit: Mercury, RetroKoH
; Function: Enables the Wall Jump used by Mighty in Chaotix
WallJumpEnabled: = 0					; if set to 1, the wall jump is enabled
	WallDustEnabled: = WallJumpEnabled*SkidDustEnabled*1	; if set to 1, dust will emanate when latched to a wall

; Name: 7th Emerald and Super Sonic (Incomplete: Minor Bugfixes)
; Credit: RetroKoH (Palette Credit: Clownacy)
; Function: Adds 7th Special Stage, 7th Emerald and Super Sonic Form
SuperMod: = 0
; NOTE: Super Sonic breaks some objects and foreground elements, visually, due to the changes to blues in Pal Line 0.
; Adjustments will not be made in S1Fixed, as it's far too cumbersome to make a toggleable mod.
; I might make a separate branch for this in the future.

; ----- GAMEPLAY TWEAKS ----------------------------------------------------------

; Name: Disable Speed Caps
; Credit: Mercury (Ground/Air), RetroKoH (Applied to Devon's Rolling Speed Cap Fix)
; Function: Toggles the speed caps (The original game has speed caps active by default)
GroundSpeedCapEnabled: = 1				; if set to 1, the ground speed cap is active
AirSpeedCapEnabled: = 1					; if set to 1, the air speed cap is active
RollSpeedCapEnabled: = 1				; if set to 1, the rolling speed cap is active (fixed by Devon)

; Name: Original Roll Jump Toggle
; Credit: Mercury
; Function: When turned on, Sonic retains his original roll jump lock (See _incObj/Sonic Jump.asm)
RollJumpLockActive: = 1					; if set to 1, the original roll jump lock is maintained

; Name: Spike Fix Mod
; Credit: FraGag
; Function: Prevents spikes from harming Sonic while he's flashing.
SpikeBugFix: = 0						; if set to 1, the spike "bug" is fixed

; Name: Rebound Mod
; Credit: Mercury
; Function: Makes rebounding from enemies/monitors after rolling off a cliff onto them function the same as if they were jumped on - the rebound is cut short if the jump button is released. 
ReboundMod: = 0

; Name: CD Balancing Mod
; Credit: Mercury
; Function: Uses the Sonic CD balancing sprites (forward and back) instead of Sonic 1's.
CDBalancing: = 0

; Name: CD Camera Panning
; Credit: Naoto
; Function: Applies a panning effect to the screen when moving quickly, a la Sonic CD
CDCamera: = 0							; if set to 1, screen will pan forward, a la Sonic CD

; Name: Centralized Camera
; Credit: TomatoWave_0
; Function: Centralizes the standard camera
CenteredCamera: = 0*(CDCamera==0)		; if set to 1, screen will be tighter, locking Sonic in the center

; Name: Camera Scroll Delay
; Credit: Mercury
; Function: Adds a delay before scrolling the camera up and down
ScrollDelay: = 0						; if set to 1, looking up and down will have a delay before the camera scrolls
	ScrollDelayTime: = 120				; number of frames to wait before the camera scrolls when looking up/down
; NOTE: This mod is forced whenever Spin Dash is enabled. THIS toggle is purely for those who don't want the spindash, but still want a delay.

; Name: S3K AfterImages (Incomplete: Add for Super Sonic)
; Credit: Hitaxas (Wooloo Engine)
; Function: Applies After-Image effects to the Speed Shoes
AfterImagesOn: = 0

; Name: Random Monitors
; Credit: RetroKoH
; Function: All monitors are randomized a la Sonic 2 (2P)
RandomMonitors: = 0

; Name: GHZ Boss Battle Delay
; Credit: RetroKoH
; Function: You cannot hit Eggman until he lowers the wrecking ball, per the 2013 remake and Origins
GHZBossDelay: = 0						; if set to 1, the boss can't be hit until he lowers the wrecking ball.
; ???NOTE???: I am NOT happy with the hackish manner in which I implemented this. I'll revisit later.

; Name: Limit LZ Block Rising Speed
; Credit: Mercury
; Function: Limits the rising speed of blocks in LZ so that Sonic can jump off them more comfortably.
LimitLZBlockRisingSpeed: = 0			; if set to 1, LZ Rising platforms are speed-capped

; Name: Orbinaut Animation Tweak
; Credit: Mercury
; Function: Makes Orbinaut "notice" Sonic at a closer range so that it's more likely to happen onscreen, and "get angry" quicker.
OrbinautAnimationTweak: = 0
	OrbinautAnimationTweakRange: = $80	; horizontal range in pixels at which Sonic is noticed by the Orbinaut
	OrbinautAnimationTweakSpeed: = $8	; animation speed of the Orbinaut's "getting angry" animation
	
; Name: SLZ Orbinaut Behaviour Mod (Incomplete: Remove grey frame from SLZ Orbinaut)
; Credit: Mercury
; Function: Makes the SLZ Orbinauts beatable by giving them behaviour similar to Sonic 4's.
SLZOrbinautBehaviourMod: = 0

; Name: Signpost Control Lock Bypass Fix
; Credit: Fix by Clownacy, reintroduced as mod by Amy Farbright
; Function: Fixes an edge case where being offscreen and in the air as the score tally starts avoids locking controls to run forward
SignpostControlLockFix: = 0

; Name: Post-Boss Instant Screen Unlock
; Credit: RetroKoH
; Function: Allows the right side screen lock to open immediately (as in the remakes) instead of gradually.
PostBossScreenUnlock: = 0
; This function may be necessary depending on how you wish to alter End-of-Level sequences.

; Name: Speed Up/Instant Score Tally
; Credit: Mercury/RetroKoH
; Function: Allows the player to hold a button to speed up the score tally, or just have it occur immediately
SpeedUpScoreTally: = 0					; if set to 1, score tally can be sped up w/ ABC. If 2, it automatically tallies immediately.

; Name: Floating Signposts
; Credit: RetroKoH
; Function: The Signpost flies into the air when you run past it fast enough.
FloatingSignposts: = 0

; Name: Cool and Perfect Bonuses
; Credit: RetroKoH
; Cool Bonus Function: Sonic gets an additional 10000 points if he doesn't get hit (decrements by 100 for each hit).
; Perfect Bonus Function: Sonic gets an additional 50000 points if he collects every ring in a level or Special Stage.
CoolBonusEnabled: = 0
PerfectBonusEnabled: = 0
ExtraBonuses: = CoolBonusEnabled+PerfectBonusEnabled	; if either bonus is enabled, SCORE is removed from the score tally cards.
	CoolBonusHits: = 10		; Number of hits allowed to attain any bonus in a level.
	PerfectScore: = 5000	; Score awarded for Perfect Bonus / 10.
; If both are enabled, the Got Through Card has a 4th tally mapping

; Name: Enemies Drop Rings
; Credit: RetroKoH, DeltaW
; Function: Enemies drop rings instead of animals
EnemiesDropRings: = 0
	EnemyRingsAttract: = 1*ShieldsMode	; if set, the Lightning Shield will attract these rings

; Name: Invincibility Buffer
; Credit: RetroKoH
; Function: Gives Sonic a second of invulnerability frames after Invincibility expires
InvincBuffer: = 0
; I saw this in a Sonic 3 AIR Superstars mod. Not sure if that existed in Superstars, but I implemented it here.

; Name: 50k Points Lives Mod
; Credit: RetroKoH
; Function: Simply enables/disables the REV01 addition of extra lives for 50k points
ScoreLives: = 0
	ScoreLivesFactor: = 5000	; Score multiple at which lives are awarded (By default, 1 life for every 50k points)
; NOTE: The game sometimes erroneously gives lives when this is enabled (likely due to incorrect setting of v_scorelife

; Name: Rings Lives Mod
; Credit: RetroKoH
; Function: Simply enables/disables acquisition of lives via rings.
RingsLives: = 1
	RingsLivesFactor: = 100		; Rings multiple at which lives are awarded (only twice). By default: 100; Proto: 50.
	; NOTE: Setting this to 50 MIGHT interfere with Continues in the Special Stage.

; ----- FLAIR MODS ---------------------------------------------------------------

; Name: Fade-In SEGA Screen
; Credit: RetroKoH
; Function: Causes the SEGA Screen to fade in, instead of just popping in.
FadeInSEGA: = 1							; if set to 1, the SEGA screen smoothly fades in

; Name: Screen Fading Options
; Credit: RetroKoH/MarkeyJester
; Function: Screens now fade in/out in one of 7 different ways: (Blue, Green, Red, Cyan, Magenta, Yellow, and Full)
PaletteFadeSetting: = 0					; 0 - Blue (Original), 1 - Green, 2 - Red, 3 - Cyan (B+G), 4 - Pink (B+R), 5 - Yellow (G+R), 6 - Full

; Name: GHZ Water Palette Mod
; Credit: Sonic 1 Forever Team
; Function: Toggles GHZ palette between original and Sonic 1 Forever's altered bg water.
GHZForeverPal: = 0						; if set to 1, GHZ is set to Sonic 1 Forever's palette

; Name: Active Death Sequences
; Credit: RetroKoH
; Function: Active elements will not freeze when the player dies.
ActiveDeathSequence: = 0				; if set to 1, active elements don't freeze on death a la Sonic CD
; NOTE (Bugs when enabled):
; Causes Labyrinth Zone BG to scroll vertically; (Skipping DeformLayers fixes this, but causes the GHZ clouds to not scroll)
; Also, New dynamic rings glitch out if no other objects are active on screen (seemingly unrelated to this mod, but not sure)

; Name: End-of-Level Music Fade
; Credit: RetroKoH
; Function: Toggles whether music will fade out after the level ends.
EndLevelFadeMusic: = 0

; Name: HUD Scrolls Into View
; Credit: RetroKoH
; Function: HUD Scrolls into view during gameplay.
HUDScrolling: = 0						; if set to 1, the HUD scrolls into frame at the start of a level
	HUDScrollOut: = HUDScrolling*1			; if set to 1, the HUD scrolls out once you hit a signpost, OR hit a Prison Capsule.

; Name: HUD w/ Leading Zeroes
; Credit: Mercury
; Function: Adds Leading 0's to HUD values (Score, Rings, Lives)
HUDHasLeadingZeroes: = 0				; if set to 1, leading zeroes appear on HUD

; Name: HUD Centiseconds
; Credit: Mercury
; Function: Adds Sonic CD-style centiseconds to the HUD
HUDCentiseconds: = 0

; Name: Blinking HUD
; Credit: Mercury
; Function: Makes "TIME" and "RINGS" will blink on and off instead of flashing red. Useful when changing palettes.
HUDBlinking: = 0

; Name: Updated Signposts
; Credit: RetroKoH
; Function: Gives the Signposts a base, similar to those in Sonic CD.
UpdatedSignposts: = 0				; 0 = default signposts; 1 = CD signposts; 2 = hybrid (shorter CD) signposts

; Name: SBZ3 New Art Mod
; Credit: Trickster/Rohan, RetroKoH
; Function: Provides new art for SBZ Act 3
NewSBZ3LevelArt: = 0

; Name: Ambience Mode
; Credit: RetroKoH
; Function: Disables playing music tracks, allowing only sfx to play
AmbienceMode: = 0

; ----- SPECIAL STAGES -----------------------------------------------------------

; Name: Dynamic Special Stage Walls
; Credit: Mercury
; Function: Dynamically loads the wall art in the Special Stages to free VRAM (for things like the HUD)
DynamicSpecialStageWalls: = 0

; Name: Smooth Special Stage Rotation and Jumping
; Credit: Cinossu and Devon
; Function: Special Stage scrolls smoothly. Movement/Jump angles are also affected.
SmoothSpecialStages: = 0

; Name: Special Stage Index Increases Only If Won
; Credit: Mercury
; Function: Makes the Special Stage index not increase when you fail the stage, allowing you to retry the previous stage.
SpecialStageAdvancementMod: = 0

; Name: HUD (and Time Limits) In Special Stage
; Credit: Mercury/RetroKoH
; Function: Adds HUD to Special Stage. I also fixed one bug w/ Mercury's implementation.
; Depends On: Dynamic Special Stage Walls
HUDInSpecialStage: = DynamicSpecialStageWalls*1
	SpecialStageHUDType: = 3			; 0=normal; 1=score not shown; 2=score & time not shown; 3=rings only
	TimeLimitInSpecialStage: = 0		; if set, time counts down in the Special Stage from a specified time limit
		SSTimeLimitPinch: = $00001E00	; "pinch" threshold that time must reach in order to trigger "TIME" to flash. Format: $000MSSCC
		SSTimeLimitStart: = $00010000	; time on the clock to start with when Special Stage is entered. Format: $000MSSCC
		; NOTE: SSTimeLimitStart must always end in 00
		; To-Do: Make time limits for all 7 stages

; Mods listed below alter the layouts in real-time. See variable: AlteredSpecialStages
; Name: Sonic 4 Controls in Special Stage
; Credit: RetroKoH
; Function: If active, Special Stages control like Sonic 4 Ep 1 (Left/Right rotate the stage).
S4SpecialStages: = 0	; (Removes UP/DOWN, and R Blocks)
; NOTE: Add a sub-toggle for disabling jump in the S4 special stage. (Bounce off walls)

; Name: Special Stages Still Appear With All Emeralds
; Credit: Mercury
; Function: Makes the Special Stages still accessible even once all emeralds are collected.
SpecialStagesWithAllEmeralds: = 0		; (Replaces Emeralds w/ 1-Ups if Emeralds are obtained)

; To-Do: Add Special Stages to SBZ 1 and 2 Toggle from ReadySonic

; Perfect Bonuses are included here because it helps keep SS_Load efficient.
AlteredSpecialStages: = (S4SpecialStages+SpecialStagesWithAllEmeralds+PerfectBonusEnabled)

; ----- PROTO ELEMENTS -----------------------------------------------------------

; Name: Original Level Order
; Credit: RetroKoH
; Function: Toggles level order between Original and Final
OriginalLevelOrder: = 0						; if set to 1, Level Order is that seen in the original level select screen

; Name: Proto Sonic Palette Mod
; Credit: Ikey Ilex
; Function: Gives Sonic his prototype palette found in the Tom Payne archives. Also seen in Crackers and Sonic CD.
ProtoSonicPalette: = 0

; Name: Proto Percussion
; Credit: OrionNavattan
; Function: Gives the percussion the sound style as heard in earlier prototype versions of the game.
ProtoPercussion: = 0

; Name: Proto Zone Names
; Credit: RetroKoH
; Function: Changes the names of Spring Yard and Scrap Brain to Sparkling and Clock Work, respectively.
ProtoZoneNames: = 0

; Name: Proto Victory Leap
; Credit: RetroKoH
; Function: Restores the victory leap Sonic performs at the end of a level.
ProtoVictoryLeap: = 0
; Unlike the actual prototype, this triggers as soon as Sonic hits a Signpost.
; NOTE: Need to fix Drop Dash bug

; ----- UNDER-THE-HOOD -----------------------------------------------------------

; Name: Debug Path Swappers
; Credit: Clownacy/MarkeyJester
; Function: Sound alert when running through the path swapper while Debug Mode is enabled
DebugPathSwappers: = 1
; To-Do: Add Forced Roll object from Sonic 2, and give it a similar debug function to this

; Name: Save Game Functionality
; Credit: RetroKoH, s1Disasm Team
; Function: Allows the player to continue from the previous save point (level start, checkpoint)
EnableSRAM:	  = 1	; change to 1 to enable SRAM
BackupSRAM:	  = 1
AddressSRAM:  = 3	; 0 = odd+even; 2 = even only; 3 = odd only
; Below is the variable for the actual mod. SRAM must be enabled to use this mod.
SaveProgressMod: = EnableSRAM*1

; Name: S2 Level Select
; Credit: RetroKoH
; Function: Replaces the Sonic 1 Level Select with a Sonic 2-inspired Level Select
NewLevelSelect:	= 0

; Name: Chunks In ROM
; Credit: Mercury/FraGag
; Loads Chunks (256x256)/Blocks (16x16) directly from ROM, freeing a huge amount of RAM.
BlocksInROM: = 1						; if set to 1, frees RAM ($0000-$A3FF)
ChunksInROM: = 1						; if set to 1, frees RAM ($B000-$C7FF)

; Name: Optimal Title Card Art
; Credit: RetroKoH
; Loads only necessary tiles for various cards. The benefit is less VRAM taken up by cards.
; The drawback is that they may be harder to edit for new users, and ROM size is slightly larger.
OptimalTitleCardArt: = 1				; if set to 1, new art and mappings are used, reducing VRAM footprint and sprite piece count

; Name: S3K Underwater Palette Handling
; Credit: ProjectFM (https://sonicresearch.org/community/index.php?threads/removing-the-water-surface-object-in-sonic-1.5975)
; Uses S3K's method of applying the underwater palette, removing the need for the water surface object (if desired)
S3KUnderwaterPalette: = 0				; if set to 1, the HBlank method is changed to that of S3K's.
; I've made this a toggle because the visuals may or may not be desirable to the user.

; Name: Dynamic Level Palettes
; Credit: RetroKoH (Based on my S1C Difficulty Mod)
; Loads a different palette for every act (Scrap Brain is unaffected, as it has dynamic palettes by default)
; (By default, they are identical to the original. It'll be up to you to edit them if you use this mod)
DynamicPalettes: = 0					; if set to 1, there will be a separate palette for each act

; Name: Dynamic BGM Music
; Credit: RetroKoH
; Plays a different BGM track for each act (Scrap Brain is unaffected, as it has dynamic palettes by default)
; (By default, they are identical to the original. It'll be up to you to add music if you use this mod)
DynamicBGMs: = 0						; if set to 1, there will be a separate BGM track for each act

; Name: Dynamic Art
; Credit: RetroKoH
; Plays a different BGM track for each act
; (By default, they are identical to the original. It'll be up to you to add music if you use this mod)
DynamicArt: = 0							; if set to 1, there will be separate art loaded for each act
; LevelHeaders is expanded by this mod. In some respects, this might make DynamicPalettes and NewSBZ3LevelArt seem redundant as solo mods.

; Name: Dynamic Collision
; Credit: RetroKoH
; Plays a different BGM track for each act (Scrap Brain is unaffected, as it has dynamic palettes by default)
; (By default, they are identical to the original. It'll be up to you to add collision data if you use this mod)
DynamicCollision: = DynamicArt*0		; if set to 1, there will be separate collision loaded for each act
; This mod is dependant on the DynamicArt mod, if only because there is little reason to have this one, without the other one.
