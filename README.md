# S1Fixed
 A successor to ReadySonic (Bugfixes, Optimizations, Changes)
 Base: Updated Sonic One Two-Eight disassembly for AS by Clownacy
 Version: REV01. Revision options removed.

# Credits
 RetroKoH - S1Fixed
 Mercury - Original ReadySonic
 Clownacy - Updated S1 One Two-Eight Base
 MarkeyJester - Original S1 One Two-Eight Base
 Mods/Fixes, etc. are credited to the respective authors below

# Mods (Can be enabled or disabled using the noted variables at the start of sonic.asm)
 Name: Dynamic Special Stage Walls (and Smmoth Rotation/Jumping)
 Credit: Mercury/Cinossu and Devon
 Function: Dynamically loads the wall art in the Special Stages to free VRAM (for things like the HUD)
 Date: 2024-06-04
 Modifies: sonic.asm, _maps\SS Walls.asm, _inc\Pattern Load Cues.asm, 09 Sonic in Special Stage.asm
 Variables: DynamicSpecialStageWalls, SmoothSpecialStages
 
 Name: Fade-In SEGA Screen
 Credit: RetroKoH
 Function: Causes the SEGA Screen to fade in, instead of just popping in.
 Date: 2024-06-06
 Variable: FadeInSEGA
 
 Name: Screen Fading Options
 Credit: RetroKoH/MarkeyJester
 Function: Screens now fade in/out in one of 7 different ways: (Blue, Green, Red, Cyan, Magenta, Yellow, and Full)
 Date: 2024-06-18
 Variable: PaletteFadeSetting

 Name: Original Roll Jump Toggle
 Credit: Mercury
 Function: When turned on, Sonic retains his original roll jump lock (See _incObj/Sonic Jump.asm)
 Date: 2024-06-18
 Variable: RollJumpLockActive
 
 Name: Disable Speed Caps
 Credit: Mercury, RetroKoH (Applied to Devon's Rolling Speed Cap Fix)
 Function: Disables the speed cap in the air and on the ground.
 Date: 2024-06-18
 Variable: GroundSpeedCapEnabled, AirSpeedCapEnabled

 Name: Spike Fix Mod
 Credit: FraGag
 Function: Prevents spikes from harming Sonic while he's flashing.
 Date: 2024-06-18
 Variable: SpikeBugFix

 Name: GHZ Water Palette Mod
 Credit: Sonic 1 Forever Team
 Function: Toggles GHZ palette between original and Sonic 1 Forever's altered bg water.
 Date: 2024-06-18
 Variable: GHZForeverPal
 
 Name: End-of-Level Music Fade
 Credit: RetroKoH
 Function: Toggles whether music will fade out after the level ends.
 Date: 2024-06-20
 Variable: EndLevelFadeMusic
 
 Name: Warm Palette Mod (Incomplete)
 Credit: Mercury/RetroKoH
 Function: Gives the game a Chaotix-like feel.
 Date: 2024-06-21
 Variable: WarmPalettes
 
 Name: Objects Don't Freeze
 Credit: RetroKoH
 Function: Objects will not freeze when the player dies.
 Date: 2024-06-21
 Variable: ObjectsFreeze
 
 Name: Speed Up/Instant Score Tally
 Credit: Mercury/RetroKoH
 Function: Allows the player to hold a button to speed up the score tally, or just have it occur immediately
 Date: 2024-06-21
 Variable: SpeedUpScoreTally
 
 Name: Spin Dash
 Credit: SCHG, DeltaW, Mercury
 Function: Enables the Sonic 2 Spin Dash
 Date: 2024-06-23
 Variable: SpinDashEnabled
 Also:
	SkiddustEnabled: Toggle this for S2 skid dust clouds
	SpinDashCancel: Makes Sonic stop Spin Dashing if the A/B/C button is let up for long enough
	SpinDashNoRevDown: Makes the Spin Dash not rev down so long as A/B/C button is held down

 Name: Peelout
 Credit: DeltaW, Mercury
 Function: Enables the Sonic CD Peelout. Also enables the dashing animation while running.
 Date: 2024-06-23
 Variable: PeeloutEnabled
 
 Name: Elemental Shields
 Credit: RetroKoH, DeltaW
 Function: Enables the usage of S3K Shields and abilities in Sonic 1
 Date: 2024-06-30
 Variable: ShieldsMode (0-Blue Only, 1-Instashield added, 2-S1+S3K Scaling Shields, 3-S3K Shields only)
 
 Name: Air Roll
 Credit: RetroKoH (Inspired by a guide by Inferno Gear)
 Function: Enabled the Air Roll from Sonic Triple Trouble
 Date: 2024-07-01
 Variable: AirRollEnabled
 
 Name: CD Balancing
 Credit: Mercury
 Function: Uses the Sonic CD balancing sprites (forward and back) instead of Sonic 1's.
 Date: 2024-07-01
 Variable: CDBalancing

# Under-the-Hood Optimizations/Overhauls
 Name: 128x128 Chunk Format
 Credit: Clownacy
 Function: Layout Chunks are now 128x128 in size, akin to Sonic 2 and Sonic 3K
 Date: 2024-04-23
 
 Name: MegaPCM2 Sound Driver
 Credit: Vladikcomper
 Function: High-quality sound driver
 Date: 2024-06-04
 
 Name: MD Debugger and Error Handler v.2.5
 Credit: Vladikcomper
 Function: New Error Handling System and Built-in Debugger
 Date: 2024-06-04
 
 Name: Art Limit Extensions
 Credit: MarkeyJester
 Function: Extends limits of animation, sprite mappings, and art tiles for Sonic (as well as animations for other objects)
 Date: 2024-06-05

 Name: Faster CheckSum Check
 Credit: MarkeyJester
 Function: Faster Checksum check
 Date: 2024-06-06
 Note: I don't remember WHERE I saw MJ post this... and I'll revisit this later, but I imported it from my old ROM hack project.
 
 Name: Ultra DMA Queue
 Credit: Flamewing and MarkeyJester
 Function: Uses a DMA queue to load Sonic's art, freeing RAM and allowing other dynamic art to function.
 Date: 2024-06-07
 
 Name: Sonic 3K Priority Manager
 Credit: Redhotsonic
 Function: Objects' Priority value is now a word instead of a byte, optimizing DisplaySprite considerably.
 Date: 2024-06-07
 
 Name: Optimized Object Movement
 Credit: Redhotsonic (and DeltaW w/ BossMove)
 Function: SpeedToPos and ObjectFall are optimized, working akin to their S3K iterations.
 Date: 2024-06-07
 
 Name: Optimized In-Air Collision Detection
 Credit: Devon/Ralakimus
 Function: Avoiding CalcAngle When Performing Collision in the Air. Based on a design choice utilized in Orbinaut Framework.
 Date: 2024-06-08
 
 Name: Optimized Decompression (Nemesis, Kosinski, Comper*)
 Credit: Vladikcomper
 Function: Provides faster decompression for quicker loading.
 Date: 2024-06-08
 
 Name: move.x to clr.x
 Credit: RetroKoH
 Function: Minor optimization w/ instruction changes across the entire ROM.
 Date: 2024-06-09
 
 Name: Optimized Ring Loss
 Credit: Redhotsonic/Spirituinsanum
 Function: Speeds up ring loss by removing calculation
 Date: 2024-06-09
 
 Name: Reorganized VRAM
 Credit: RetroKoH
 Function: Reorganized VRAM to make better use of VRAM space and allow for more art to be loaded, as well as existing art to be loaded more efficiently.
 Date: 2024-06-12
 
 Name: S3K Game Mode Array
 Credit: RetroKoH
 Function: Slight optimization to game mode handling, ported from S3K
 Date: 2024-06-12
 
 Name: Uncompressed Title Cards
 Credit: AURORA☆FIELDS/Natsumi
 Function: Uses uncompressed art to optimize Title Card processing.
 Date 2024-06-12
 
 Name: S2 HUD Display
 Credit: RetroKoH
 Function: HUD is drawn as a non-object entity
 Date 2024-06-13

 Name: S3K Rings Manager
 Credit: Shobiz and Pokepunch (SCHG), ProjectFM (Hivebrain guide), MarkeyJester (bugfix), RetroKoH (Initial S2 Port)
 Date 2024-06-14

 Name: S3K Object Manager -- (Needs further testing)
 Credit: ProjectFM (Hivebrain guide), MoDule (SCHG S2 guide), DeltaW (Bugfixes), RetroKoH (Initial S2 Port)
 Date 2024-06-15
 
 Name: Speed Settings Table
 Credit: Redhotsonic/MoDule
 Function: Resolves Speed Setting issues such as having Speed Shoes underwater, or select instances of Debug Mode usage.
 Date: 2024-06-20
 
 Name: Subsprites System
 Credit: Devon
 Function: Allows one object to draw out multiple sprites. This paves the way for various optimizations.
 Date: 2024-06-21
 
# Visual Changes
 Name: Title Screen Tweaks
 Credit: RetroKoH
 Function: Visual Adjustments to the Title Screen. (GHZ palette, Title Screen centered, Letter E corrected)
 Date: 2024-06-03
 Modifies: sonic.asm, _inc\PaletteCycle.asm, _inc\Palette Pointers.asm, _incObj/0E Title Screen Sonic.asm, _incObj/0F Press Start and TM.asm

 Name: Flashing Lost Rings
 Credit: Mercury
 Function: Lost rings now flicker before disappearing.
 Date: 2024-06-03
 Modifies: 25 & 37 Rings.asm
 
 Name: Smooth Ring Rotation
 Credit: RetroKoH (Giant Ring Sprite from Sonic 1 iOS)
 Function: Rings and Giant Rings now use smooth rotation akin to the remakes.
 Date: 2024-06-12

# Fixes
 Name: Sonic Roll Frame Fix
 Credit: Mercury
 Function: Changes Sonic's frame immediately when he rolls up in order to fix flickering while in S-Tunnels (and potentially elsewhere)
 Date: 2024-06-03
 Modifies: _incObj\Sonic Roll.asm

 Name: Top Boundary Fix
 Credit: Mercury
 Function: Prevents Sonic from dying when he passes the top boundary while hurt
 Date: 2024-06-03
 Modifies: _incObj\Sonic (part 2).asm
 
 Name: Hurt Splash Fix
 Credit: Mercury
 Function: Fixes the missing splash and applies underwater behavior when Sonic hits the water surface while hurt
 Date: 2024-06-03
 Modifies: _incObj\Sonic (part 2).asm
 
 Name: Pushing/Walking Animation Fixes: 1. Pushing While Walking Fix & 2. Walking In Air Fix
 Credit: Mercury
 Function: Fixes Sonic using the push animation while walking away from walls, and the airwalk glitch.
 Date: 2024-06-03
 Modifies: 1. _incObj\Sonic Animate.asm; 2. _incObj\sub SolidObject.asm, _incObj\26 Monitor.asm, sonic.asm

 Name: Screen Scroll While Rolling Fix
 Credit: Mercury
 Function: Fixes the bug that prevents the screen from scrolling back to neutral while Sonic is rolling.
 Date: 2024-06-03
 Modifies: _incObj\Sonic RollSpeed.asm
 
 Name: Ducking Size Fix
 Credit: Mercury
 Function: Makes Sonic's hitbox the correct size in regards to solids when he is ducking
 Date: 2024-06-03
 Modifies: _incObj\sub SolidObject.asm, _incObj\sub ReactToItem.asm, sonic.asm

 Name: Exit DLE In Special Stage And Title
 Credit: Mercury
 Function: Prevents the DLE from running while on the Title Screen and in the Special Stage, preventing serious problems.
 Date: 2024-06-03
 Modifies: _inc\DynamicLevelEvents.asm
 
 Name: Clear Control Lock When Jumping
 Credit: Mercury
 Function: Clears control lock when Sonic jumps, preventing it from lingering when he lands again and causing a frustrating lag in input.
 Date: 2024-06-03
 Modifies: _incObj\Sonic Jump.asm
 
 Name: Debug Mode Improvements
 Credit: Mercury
 Function: Makes a slew of improvements to Debug Mode. Sonic's speed and "atop object" flag are cleared when turning into an item, plus rings/monitors can be placed even after collecting one.
 Date: 2024-06-03
 Modifies: _incObj\Debug Mode.asm
 
 Name: Demo Playback Fix
 Credit: FraGag
 Function: Fixes an issue that makes demo playback interpret the button being held for more than one frame as continual new presses of the button.
 Date: 2024-06-03
 Modifies: _inc\MoveSonicInDemo.asm
 
 Name: Hidden Bonus Points Fix
 Credit: 1337Rooster
 Function: Makes the 100pt Hidden Bonuses actually give Sonic 100pts.
 Date: 2024-06-03
 Modifies: _incObj\7D Hidden Bonuses.asm
 
 Name: Remove Speed Shoes At Signpost Fix
 Credit: Mercury
 Function: Removes Speed Shoes when Sonic passes the Signpost so the Level Clear jingle won't play sped up.
 Date: 2024-06-03
 Modifies: _incObj\3A Got Through Card.asm
 
 Name: Game/Time Over Timing and Drowning Fixes
 Credit: MarkeyJester and Mercury, respectively
 Function: Makes the Game/Time Over message timing consistent, rather than waiting for Sonic to fall. Also fixes a Title Screen scrolling bug if getting Game Over after drowning.
 Date: 2024-06-03
 Modifies: _incObj\Sonic (part 2).asm, sonic.asm

 Name: Lives Over/Underflow Fix
 Credit: Mercury
 Function: Prevents life count from over-/underflowing when 1 is added/subtracted.
 Date: 2024-06-03
 Modifies: _incObj\09 Sonic in Special Stage.asm, _incObj\25 & 37 Rings.asm, _incObj\2E Monitor Content Power-Up.asm, _incObj\Sonic (part 2).asm, sonic.asm
 
 Name: ClearScreen RAM Fix
 Credit: ***Unknown (Clownacy?)***
 Function: Fixes a small bug in which too much RAM is cleared when clearing the screen.
 Date: 2024-06-03
 Modifies: sonic.asm (ClearScreen:)

 Name: Shield/Invincibility Positioning Fix
 Credit: Mercury
 Function: Correctly positions the Shield/Invincibility sprites when balancing on ledges.
 Date: 2024-06-03
 Modifies: _incObj\38 Shield and Invincibility.asm

 Name: FZ Boss Hit Count Fix
 Credit: Mercury
 Function: Prevents an underflow glitch when hitting the Final Zone boss an extra time.
 Date: 2024-06-03
 Modifies: _incObj\85 Boss - Final.asm
 
 Name: Fix Race Condition w/ Pattern Load Cues
 Credit: FraGag
 Function: Fixes bug that sometimes crashes the game if roll and look down after passing End Sign in LZ1 and LZ2
 Date: 2024-06-03
 Modifies: sonic.asm (RunPLC:)
 
 Name: Title Screen PSB Fix ***(Investigate bg shift bug reported by Iso Kilo)***
 Credit: Quickman
 Function: Some adjustments to the Title Screen to make it look more correct. Under-the-hood tweaks as well. (PSB fix, GHZ palette, Title Screen centered)
 Date: 2024-06-03
 Modifies: sonic.asm, _inc\PaletteCycle.asm, _inc\Palette Pointers.asm, _incObj/0E Title Screen Sonic.asm, _incObj/0F Press Start and TM.asm

 Name: Accidental Deletion of Scattered Rings
 Credit: Redhotsonic
 Function: Fixed a bug related to rings deleting themselves incorrectly in a vertically wrapping level (LZ3 or SBZ2)
 Date: 2024-06-03
 Modifies: _incObj/25 & 37 Rings.asm
 
 Name: Fixed Ring Timers
 Credit: Redhotsonic
 Function: Fixed lost rings so that they have individual expiration timers
 Date: 2024-06-03
 Modifies: _incObj/25 & 37 Rings.asm
 
 Name: Fixed Drowning Bugs
 Credit: Redhotsonic
 Function: Fixed bugs that occur when drowning in the Hurt State or on a Time Over. Added Drowning routine to Sonic
 Date: 2024-06-04
 Modifies: _incObj/0A - Drowning Countdown.asm, sonic.asm; Added _incObj/Sonic Drowns.asm
 
 Name: Horizontal Camera Scrolling Fixes
 Credit: MarkeyJester
 Function: Adds a check for scrolling to the left (Useful fix for those adding cutscenes), and prevents horizontal wrapping glitches.
 Date: 2024-06-04
 Modifies: _inc\DeformLayers.asm (MoveScreenHoriz:)

 Name: Game Over Flicker Fix
 Credit: RetroKoH
 Function: Removes the unintentional flicker of the GAME OVER object once it reaches center screen.
 Date: 2024-06-04
 Modifies: _incObj/39 Game Over.asm

 Name: Bottom Boundary Death Fix
 Credit: RetroKoH
 Function: Prevents accidental sudden deaths by handling the bottom boundary appropriately.
 Date: 2024-06-04
 Modifies: _incObj/Sonic LevelBound.asm

 Name: RememberSprite Bugfix
 Credit: MarkeyJester
 Function: Fixes a bug in which objects load that are set as destroyed, or vise versa.
 Date: 2024-06-05
 Modifies: sonic.asm
 
 Name: DisplaySprite Bugfix
 Credit: Clownacy
 Function: Fixes an absolute mess of a bug that can occur if using newer mappings formats.
 Date: 2024-06-06

 Name: Fix Scattered Rings Underwater Physics
 Credit: Redhotsonic
 Function: Gives proper underwater physics to scattered rings.
 Date: 2024-06-07
 
 Name: Buzz Bomber Missile Positioning Fix
 Credit: Clownacy
 Function: Positions the fired missile to be properly underneath the Buzz Bomber.
 Date: 2024-06-07
 
 Name: Water Surface Gap Fix
 Credit: LuigiXHero
 Function: Fixes a minor gap on the left side of the water surface when pausing the game.
 Date: 2024-06-07

 Name: Fixed Special Stage Jump Physics
 Credit: Mercury
 Function: Gives Sonic a variable jump height in the special stage.
 Date: 2024-06-07

 Name: Proper Push Sensors While Rolling
 Credit: Devon/Ralakimus
 Function: Sonic's push sensors will be adjusted properly while rolling, much as they are while walking/running.
 Date: 2024-06-07

 Name: Proper Detection of Invisible Solid Barriers
 Credit: Devon/Ralakimus
 Function: This resolves the bugs in MZ and SBZ1 where you can duck through invisible solids while on a solid object.
 Date: 2024-06-07

 Name: Final Zone Plasma Ball Positioning Fix
 Credit: Devon/Ralakimus
 Function: This fixes a minor bug with positioning. The plasma balls work as they do in the 2013 remake.
 Date: 2024-06-07

 Name: SBZ Trapdoor Glitch Fix
 Credit: Devon/Ralakimus
 Function: This fixes a minor visual bug where trapdoor sprites can appear on-screen just before despawning.
 Date: 2024-06-07

 Name: GHZ Vertical Scrolling Fix
 Credit: OrionNavattan
 Function: This fix makes the background scroll in a more "correct" direction vertically.
 Date: 2024-06-07

 Name: PLC Queue Shifting Bug Fix
 Credit: Vladikcomper
 Function: This fix allows users to put a full $10 (16) entries into a single PLC queue as intended.
 Date: 2024-06-08
 
 Name: Spike SFX Fix
 Credit: Mercury
 Function: Makes the proper sound effect play when Sonic is harmed by Spikes/LZ Harpoons.
 Date: 2024-06-08
 
 Name: Various Sound Driver Fixes
 Credit: Clownacy, ValleyBell, et al.
 Function: Fixed various issues including a corrupted roll sfx.
 Date: 2024-06-15
 
 Name: Look Shift Fix
 Credit: Mercury
 Function: Fixing the looking up/down camera shift so that it stops at zone boundaries, preventing a delay when returning to the neutral position.
 Date: 2024-06-18
 Modifies: _incObj/Sonic Move.asm
 
 Name: Caterkiller Fix
 Credit: Mercury
 Function: Fixes an issue where Caterkiller would sometimes hurt you if you roll into its head quickly.
 Date 2024-06-18
 Modifies: _incObj/ReactToItem.asm, _incObj/78 Caterkiller.asm

 Name: Continue Sonic Art Fix
 Credit: Mercury
 Function: Fixes some incorrect pixels in Sonic's Continue screen sprite.
 Date: 2024-06-18
 Modifies: artnem\Continue Screen Sonic.nem

 Name: Special Stage Palette Fix
 Credit: Mercury
 Function: Fixed the base palette to prevent clouds flickering when first fading in, plus altered the fading palette to not have ugly clashing purples
 Date: 2024-06-18
 Modifies: palette\Cycle - Special Stage 1.bin, palette\Special Stage.bin

 Name: Sonic Shoe Stripe Fix
 Credit: Mercury
 Function: Adds stripe to Sonic's shoe for the sprites it's missing in (using Sonic 2's tiles)
 Date: 2024-06-18
 Modifies: artunc\Sonic.bin

 Name: Rolling Jump Fix
 Credit: RetroKoH
 Function: Fixes a bug with landing in air from a rolling jump
 Date: 2024-06-18
 Modifies: _incObj/Sonic Jump.asm

 Name: Rolling Speed Cap Fix
 Credit: Devon
 Function: Fixes an inconsistency with the rolling speed cap. (Only applied if GroundSpeedCapEnabled=1)
 Date: 2024-06-18
 Modifies: _incObj/Sonic RollSpeed.asm
 
 Name: GHZ3 Wall Solidity
 Credit: Mercury
 Function: Fixes a wall object in GHZ3 after the Lamppost that was set to be solid. (It was, of course, solid for a reason: to fix a bug with the platform right next to it. However, the platform could be moved to the right by 16 pixels to solve the problem, too, so that's what I did.)
 Date: 2024-06-18
 Modifies: objpos\GHZ3 (JP1).bin
 
 Name: GHZ2 Spring Fix
 Credit: Mercury
 Function: Fixes an incorrectly flipped red spring on the lower route of GHZ2
 Date: 2024-06-18
 Modifies: objpos\GHZ2.bin
 
 Name: GHZ BG Mountain Fix
 Credit: Mercury
 Function: Fixes a tile in the GHZ mountain background that makes it looks like there's a hole in the biggest peaks.
 Date: 2024-06-18
 Modifies: map128\GHZ.bin

 Name: Low End Signs Fix
 Credit: Mercury
 Function: Some End Signs have been raised to rest properly on the ground.
 Date: 2024-06-18
 Modifies: objpos\SYZ1.bin, objpos\LZ1.bin, objpos\LZ2.bin, objpos\SBZ1.bin, objpos\SBZ2.bin

 Name: SLZ Pylons Fix
 Credit: Mercury
 Function: Removes the SLZ pylons from the object layout files and instead loads them manually when the zone starts. This allows them to appear even when respawning at a Lamppost.
 Date: 2024-06-18
 Modifies: objpos\SLZ1.bin, objpos\SLZ2.bin, objpos\SLZ3.bin

 Name: Greater Debug Mode Control
 Credit: RetroKoH
 Function: User can now enter/exit Debug Mode in non-normal control states properly.
 Date: 2024-06-20
 
 Name: Angled Animation Improvement
 Credit: Mercury
 Function: Makes Sonic appear correctly when running down certain angles (notably GHZ1) akin to the remakes.
 Date: 2024-06-21
 
 Name: Rolling Turn Around Fix
 Credit: Mercury
 Function: Prevents Sonic from turning around while rolling (which without this fix could be abused to roll in place forever).
 Date: 2024-06-22
 Modifies: Sonic RollSpeed.asm
 
 Name: Fix modulation during rests
 Credit: ValleyBell
 Function: Sound driver applies the modulation effect on rests where the frequency is set to 0, so it sort of corrupts the frequency.
 Date: 2024-06-23
  Modifies: s1.sounddriver.asm
  
 Name: Fix Modulation Frequency bug on note-on
 Credit: AURORA☆FIELDS/Natsumi
 Function: Sound driver forgets to include modulation frequency when updating frequency just after reading the tracker
 Date: 2024-06-23
 Modifies: s1.sounddriver.asm
 
 Name: NE Corner Reloading Glitch Fix
 Credit: SpirituInsanum
 Function: Fixed some graphical glitching that'd occur in the top-right corner when going very fast.
 Date: 2024-06-24
 Modifies: sonic.asm