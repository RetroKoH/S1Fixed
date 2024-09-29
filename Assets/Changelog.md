# S1Fixed
 A successor to ReadySonic (Bugfixes, Optimizations, Changes)  
 Base: Updated Sonic One Two-Eight disassembly for AS by Clownacy  
 Version: REV01. Revision options removed. All FixBugs changes applied.

# Credits
 RetroKoH - S1Fixed  
 Mercury - Original ReadySonic  
 Clownacy - Updated S1 One Two-Eight Base  
 MarkeyJester - Original S1 One Two-Eight Base  
 Mods/Fixes, etc. are credited to the respective authors noted below

# Mods
 These can be enabled or disabled using the corresponding variables in Mods.asm

## Dynamic Special Stage Walls (and Smmoth Rotation/Jumping)  
 Credit: Mercury
 Function: Frees up VRAM in Special Stages to allow for greater modification.
 Date: 2024-06-04  

## Smooth Special Stage Rotation/Jumping  
 Credit: Cinossu and Devon 
 Function: Smoother Special Stages akin to Sonic 1 (2013) 
 Date: 2024-06-04  
 
## Fade-In SEGA Screen  
 Credit: RetroKoH
 Function: Applies a fade-in effect to the SEGA Screen.
 Date: 2024-06-06  
 
## Screen Fading Options  
 Credit: RetroKoH/MarkeyJester
 Function: Offers one of 8 different styles of colored screen fades.
 Date: 2024-06-18  

## Original Roll Jump Toggle  
 Credit: Mercury  
 Function: When turned on, Sonic retains his original roll jump lock (See _incObj/Sonic Jump.asm).
 Date: 2024-06-18  
 
## Disable Speed Caps  
 Credit: Mercury, RetroKoH (Applied to Devon's Rolling Speed Cap Fix)  
 Function: Disables the speed cap in the air and on the ground.  
 Date: 2024-06-18  

## Spike Fix Mod  
 Credit: FraGag  
 Function: Prevents spikes from harming Sonic while he's flashing.
 Date: 2024-06-18

## GHZ Water Palette Mod
 Credit: Sonic 1 Forever Team
 Function: Toggles GHZ palette between original and Sonic 1 Forever's altered bg water.
 Date: 2024-06-18
 
## End-of-Level Music Fade
 Credit: RetroKoH
 Function: Toggles whether music will fade out after the level ends.
 Date: 2024-06-20
 
## Objects Don't Freeze
 (Incomplete: GHZ Clouds shouldn't freeze if this is enabled)
 Credit: RetroKoH
 Function: Objects will not freeze when the player dies.
 Date: 2024-06-21
 
## Speed Up/Instant Score Tally
 Credit: Mercury/RetroKoH
 Function: Allows the player to hold a button to speed up the score tally, or just have it occur immediately
 Date: 2024-06-21
 
## Spin Dash
 Credit: SCHG, DeltaW, Mercury
 Function: Enables the Sonic 2 Spin Dash
 Date: 2024-06-23

## Peelout
 Credit: DeltaW, Mercury
 Function: Enables the Sonic CD Peelout. Also enables the dashing animation while running.
 Date: 2024-06-23
 
## Elemental Shields
 Credit: RetroKoH, DeltaW
 Function: Enables the usage of S3K Shields and abilities
 Date: 2024-06-30
 
## Air Roll
 Credit: RetroKoH (Inspired by a guide by Inferno Gear)
 Function: Enables the Air Roll from Sonic Triple Trouble
 Date: 2024-07-01

## CD Balancing
 Credit: Mercury
 Function: Uses the Sonic CD balancing sprites (forward and back) instead of Sonic 1's.
 Date: 2024-07-01

## HUD Scrolls Into View
 Credit: RetroKoH
 Function: HUD Scrolls into view during gameplay.
 Date: 2024-07-04
 
## S3K AfterImages
 Credit: Hitaxas (WoolooEngine)
 Function: Applies After-Image effects to the Speed Shoes
 Date: 2024-07-07
 
## 7th Emerald and Super Sonic (Incomplete)
 Credit: RetroKoH (Palette Credit: Clownacy)
 Function: Adds 7th Special Stage, 7th Emerald and Super Sonic Form
 Date: 2024-07-10
 
## Rebound Mod
 Credit: Mercury
 Function: Makes rebounding from enemies/monitors after rolling off a cliff onto them function the same as if they were jumped on - the rebound is cut short if the jump button is released.
 Date: 2011-07-16
 
## HUD Centiseconds
 (Incomplete: LZ Ring Count bug)
 Credit: Mercury
 Function: Adds Sonic CD-style centiseconds to the HUD
 Date: 2024-07-17

## Chunks In ROM
 Credit: Mercury/FraGag
 Function: Loads Chunks (256x256) directly from ROM, freeing a huge amount of RAM ($0000-$A3FF)
 Date: 2024-07-18

## Blocks In ROM
 Credit: Mercury/FraGag
 Function: Similar to "Chunks In ROM" only with Blocks (16x16), freeing a huge amount of RAM ($B000-$C7FF)
 Date: 2024-07-18
 
## Sonic 4 Controls in Special Stage
 Credit: RetroKoH
 Function: If toggled on, player rotates the stage instead of moving Sonic, a la Sonic 4. (Removes UP/DOWN, and R Blocks)
 Date: 2024-07-21

## Special Stage Index Increases Only If Won  
 Credit: Mercury  
 Function: Makes the Special Stage index not increase if you fail the stage.  
 Date: 2024-07-21  
 
## Special Stages Still Appear With All Emeralds
 Credit: Mercury
 Function: Makes the Special Stages still accessible even once all emeralds are collected.
 Date: 2024-07-21

## HUD In Special Stage
 Credit: Mercury/RetroKoH
 Function: Adds HUD to Special Stage. I also fixed one bug w/ Mercury's implementation. (Depends On: Dynamic Special Stage Walls)
 Date: 2024-07-22

## Time Limits in Special Stages
 Credit: Mercury/RetroKoH
 Function: Adds countdown time limits to Special Stages. Makes use of the Shrink animation. (Depends On: HUD In Special Stage)
 Date: 2024-07-23
 
## CD Camera Panning
 Credit: Naoto
 Function: Applies a panning effect to the screen when moving quickly, a la Sonic CD
 Date: 2024-07-26
 
## Drop Dash
 Credit: DeltaW, giovanni.gen, Hitaxas, RetroKoH
 Function: Enables the Drop Dash from Sonic Mania & Origins
 Date: 2024-08-06
 
## HUD w/ Leading Zeroes
 Credit: Mercury
 Function: Adds Leading 0's to HUD values (Score, Rings, Lives)
 Date: 2024-08-07
 
## Limit LZ Block Rising Speed
 Credit: Mercury
 Function: Limits the rising speed of blocks in LZ so that Sonic can jump off them more comfortably.
 Date: 2024-08-07

## Orbinaut Animation Tweak
 Credit: Mercury
 Function: Makes Orbinaut "notice" Sonic at a closer range so that it's more likely to happen onscreen, and "get angry" quicker.
 Date: 2024-08-10

## SLZ Orbinaut Behaviour Mod
 Credit: Mercury
 Function: Makes the SLZ Orbinauts beatable by giving them behaviour similar to Sonic 4's.
 Date: 2024-08-10

## SRAM Support and Progress Saving
 Credit: Kilo/RetroKoH
 Function: Save Game Support, and new menu built off the PRESS START BUTTON object.
 Date: 2024-08-15

## Randomized Monitors
 Credit: RetroKoH/Devon
 Function: Randomizes monitors (akin to S2's 2 PLAYER mode). Randomization thanks to Devon.
 Date: 2024-08-23

## Blinking HUD
 Credit: Mercury
 Function: Makes "TIME" and "RINGS" will blink on and off instead of flashing red. Useful when changing palettes.
 Date: 2024-09-03

## Proto Sonic Palette
 Credit: Ikey Ilex
 Function: Gives Sonic a more saturated color palette. From the Tom Payne archives. Also seen in Crackers and Sonic CD.
 Date: 2024-09-04
 
## Beta Level Order
 Credit: RetroKoH
 Function: If toggled on, lets you play the game in the original intended order
 Date: 2024-09-04
 
## Cool Bonus
 Credit: RetroKoH
 Function: Adds a COOL BONUS to the End of Level tally, from Sonic Mania
 Date: 2024-09-29

# Under-the-Hood Optimizations/Overhauls
 These are larger-scale changes to one or more aspects of the engine that cannot be toggled on/off.

## 128x128 Chunk Format
 Credit: Clownacy
 Function: Layout Chunks are now 128x128 in size, akin to Sonic 2 and Sonic 3K
 Date: 2024-04-23
 
## MegaPCM2 Sound Driver
 Credit: Vladikcomper
 Function: High-quality sound driver
 Date: 2024-06-04
 
## MD Debugger and Error Handler v.2.5
 Credit: Vladikcomper
 Function: New Error Handling System and Built-in Debugger
 Date: 2024-06-04
 
## Art Limit Extensions
 Credit: MarkeyJester
 Function: Extends limits of animation, sprite mappings, and art tiles for Sonic (as well as animations for other objects)
 Date: 2024-06-05

## Faster CheckSum Check
 (Incomplete)
 Credit: MarkeyJester
 Function: Faster Checksum check
 Date: 2024-06-06
 Note: I don't remember WHERE I saw MJ post this... and I'll revisit this later, but I imported it from my old ROM hack project.
 
## Ultra DMA Queue
 Credit: Flamewing and MarkeyJester
 Function: Uses a DMA queue to load Sonic's art, freeing RAM and allowing other dynamic art to function.
 Date: 2024-06-07
 
## Sonic 3K+ Priority Manager
 Credit: Redhotsonic/RetroKoH/Devon
 Function: Objects' Priority value is now a word instead of a byte, optimizing DisplaySprite considerably.
 Date: 2024-06-07
 
## Optimized Object Movement
 Credit: Redhotsonic/DeltaW
 Function: SpeedToPos (and one in the teleporter object that uses a1), ObjectFall, BossMove and  are optimized... way more than S3K's
 Date: 2024-06-07
 
## Optimized In-Air Collision Detection
 Credit: Devon/Ralakimus
 Function: Avoiding CalcAngle When Performing Collision in the Air. Based on a design choice utilized in Orbinaut Framework.
 Date: 2024-06-08
 
## Optimized Decompression (Nemesis, Kosinski, Comper*)
 Credit: Vladikcomper
 Function: Provides faster decompression for quicker loading.
 Date: 2024-06-08
 
## Optimized Ring Loss
 Credit: Redhotsonic/Spirituinsanum
 Function: Speeds up ring loss by removing calculation
 Date: 2024-06-09
 
## Reorganized VRAM
 Credit: RetroKoH
 Function: Reorganized VRAM to make better use of VRAM space and allow for more art to be loaded, as well as existing art to be loaded more efficiently.
 Date: 2024-06-12
 
## S3K Game Mode Array
 Credit: RetroKoH
 Function: Slight optimization to game mode handling, ported from S3K
 Date: 2024-06-12
 
## Uncompressed Title Cards
 Credit: AURORA☆FIELDS/Natsumi
 Function: Uses uncompressed art to optimize Title Card processing.
 Date 2024-06-12
 
## S2 HUD Display
 Credit: RetroKoH
 Function: HUD is drawn as a non-object entity
 Date 2024-06-13

## S3K Rings Manager
 Credit: Shobiz and Pokepunch (SCHG), ProjectFM (Hivebrain guide), MarkeyJester (bugfix), RetroKoH (Initial S2 Port)
 Date 2024-06-14

## S3K Object Manager
 Credit: ProjectFM (Hivebrain guide), MoDule (SCHG S2 guide), DeltaW (Bugfixes), RetroKoH (Initial S2 Port)
 Date 2024-06-15
 
## Speed Settings Table
 Credit: Redhotsonic/MoDule
 Function: Resolves Speed Setting issues such as having Speed Shoes underwater, or select instances of Debug Mode usage.
 Date: 2024-06-20
 
## Subsprites System
 Credit: Devon
 Function: Allows one object to draw out multiple sprites. This paves the way for various optimizations.
 Date: 2024-06-21
 
## Optimized Routine Handling
 Credit: Lavagaming1/RetroKoH
 Function: Many objects employ new methods to navigate routines, saving cycles.
 Date: 2024-07-03
 
## Optimized CalcAngle
 Credit: Devon/DeltaW
 Function: Optimized angle calculation.
 Date: 2024-07-03
 
## S3K TouchResponse Object Collision System
 Credit: DeltaW/RetroKoH
 Function: Optimized Object Detection for Sonic
 Date: 2024-07-07
 
## S2+ DPLCs
 Credit: DeltaW
 Function: Uses the DPLC format from Sonic 2/3K
 Date: 2024-07-28
 
## S2 BuildSprites
 Credit: RetroKoH
 Function: Uses Sonic 2 format mappings (Display/Delete bug occurs w/ buzz bomber missile)
 Date: 2024-08-02

## ASCII Level Select
 Credit: Soulless Sentinel
 Function: Makes editing level select text easier for newer users.
 https://forums.sonicretro.org/index.php?threads/how-to-convert-sonic-1-level-select-to-ascii.31729/
 Date: 2024-09-04
 
## Extended Sound Index
 (Temporarily Removed)
 Credit: Alex Field
 Function: Sounds can be played from 00-FF (Users will need to add them, of course)
 Date: ???
 
# Design Changes
 These are relatively minor changes that merely provide a little bit of added flair, or clean things up.

## Title Screen Tweaks
 Credit: RetroKoH
 Function: Visual Adjustments to the Title Screen. (GHZ palette, Title Screen centered, Letter E corrected)
 Date: 2024-06-03
 Modifies: sonic.asm, _inc\PaletteCycle.asm, _inc\Palette Pointers.asm, _incObj/0E Title Screen Sonic.asm, _incObj/0F Press Start and TM.asm

## Flashing Lost Rings
 Credit: Mercury
 Function: Lost rings now flicker before disappearing.
 Date: 2024-06-03
 Modifies: 25 & 37 Rings.asm
 
## Smooth Ring Rotation
 Credit: RetroKoH (Giant Ring Sprite from Sonic 1 2013)
 Function: Rings and Giant Rings now use smooth rotation akin to the remakes.
 Date: 2024-06-12
 
## 8-Frame Walking Sonic; Smooth Looking Up/Down Animations; Larger, more consistent hands.
 Credit: RetroKoH
 (8-frame walking art by Bennascar on DeviantArt: https://www.deviantart.com/bennascar/art/The-Ultimate-Sonic-1-Sheet-690414373)
 (Looking Up/Down mid-frames from Sonic 1 2013)
 (Hand edits courtesy of Orbinaut Framework)
 Function: Sonic now has an 8-frame walking cycle, like in later games. He also has smoother animations in some areas and certain parts look more consistent.
 Date: 2024-07-12

## Modified LZ3 Dynamic Level Event
 Credit: RetroKoH
 Function: The horizontal door that blocked off the tunnel just before the LZ3 boss has been moved up to the start of the chase area.
 It now triggers when you reach the top, and even features a sound effect. This was moved due to complications with the S3K Object Manager
 and level wrapping. Without it, you could completely backtrack, which would break water in the level.
 Date: 2024-08-21

## Rotating Wrecking Ball in GHZ Boss
 Credit: RetroKoH
 Function: Adds a rotation effect to Eggman's wrecking ball, akin to Taxman's Sonic 1.
 Date: 2024-09-14

# Fixes
 These changes fix notable bugs in the original game. Some bugs were game-breaking, while others were miniscule in nature.

## Sonic Roll Frame Fix
 Credit: Mercury
 Function: Changes Sonic's frame immediately when he rolls up in order to fix flickering while in S-Tunnels (and potentially elsewhere)
 Date: 2024-06-03
 Modifies: _incObj\Sonic Roll.asm

## Top Boundary Fix
 Credit: Mercury
 Function: Prevents Sonic from dying when he passes the top boundary while hurt
 Date: 2024-06-03
 Modifies: _incObj\Sonic (part 2).asm
 
## Hurt Splash Fix
 Credit: Mercury
 Function: Fixes the missing splash and applies underwater behavior when Sonic hits the water surface while hurt
 Date: 2024-06-03
 Modifies: _incObj\Sonic (part 2).asm
 
## Pushing/Walking Animation Fixes: 1. Pushing While Walking Fix & 2. Walking In Air Fix
 Credit: Mercury
 Function: Fixes Sonic using the push animation while walking away from walls, and the airwalk glitch.
 Date: 2024-06-03
 Modifies: 1. _incObj\Sonic Animate.asm; 2. _incObj\sub SolidObject.asm, _incObj\26 Monitor.asm, sonic.asm

## Screen Scroll While Rolling Fix
 Credit: Mercury
 Function: Fixes the bug that prevents the screen from scrolling back to neutral while Sonic is rolling.
 Date: 2024-06-03
 Modifies: _incObj\Sonic RollSpeed.asm
 
## Ducking Size Fix
 Credit: Mercury
 Function: Makes Sonic's hitbox the correct size in regards to solids when he is ducking
 Date: 2024-06-03
 Modifies: _incObj\sub SolidObject.asm, _incObj\sub ReactToItem.asm, sonic.asm

## Exit DLE In Special Stage And Title
 Credit: Mercury
 Function: Prevents the DLE from running while on the Title Screen and in the Special Stage, preventing serious problems.
 Date: 2024-06-03
 Modifies: _inc\DynamicLevelEvents.asm
 
## Clear Control Lock When Jumping
 Credit: Mercury
 Function: Clears control lock when Sonic jumps, preventing it from lingering when he lands again and causing a frustrating lag in input.
 Date: 2024-06-03
 Modifies: _incObj\Sonic Jump.asm
 
## Debug Mode Improvements
 Credit: Mercury
 Function: Makes a slew of improvements to Debug Mode. Sonic's speed and "atop object" flag are cleared when turning into an item, plus rings/monitors can be placed even after collecting one.
 Date: 2024-06-03
 Modifies: _incObj\Debug Mode.asm
 
## Demo Playback Fix
 Credit: FraGag
 Function: Fixes an issue that makes demo playback interpret the button being held for more than one frame as continual new presses of the button.
 Date: 2024-06-03
 Modifies: _inc\MoveSonicInDemo.asm
 
## Hidden Bonus Points Fix
 Credit: 1337Rooster
 Function: Makes the 100pt Hidden Bonuses actually give Sonic 100pts.
 Date: 2024-06-03
 Modifies: _incObj\7D Hidden Bonuses.asm
 
## Remove Speed Shoes At Signpost Fix
 Credit: Mercury
 Function: Removes Speed Shoes when Sonic passes the Signpost so the Level Clear jingle won't play sped up.
 Date: 2024-06-03
 Modifies: _incObj\3A Got Through Card.asm
 
## Game/Time Over Timing and Drowning Fixes
 Credit: MarkeyJester and Mercury, respectively
 Function: Makes the Game/Time Over message timing consistent, rather than waiting for Sonic to fall. Also fixes a Title Screen scrolling bug if getting Game Over after drowning.
 Date: 2024-06-03
 Modifies: _incObj\Sonic (part 2).asm, sonic.asm

## Lives Over/Underflow Fix
 Credit: Mercury
 Function: Prevents life count from over-/underflowing when 1 is added/subtracted.
 Date: 2024-06-03
 Modifies: _incObj\09 Sonic in Special Stage.asm, _incObj\25 & 37 Rings.asm, _incObj\2E Monitor Content Power-Up.asm, _incObj\Sonic (part 2).asm, sonic.asm
 
## ClearScreen RAM Fix
 Credit: ***Unknown (Clownacy?)***
 Function: Fixes a small bug in which too much RAM is cleared when clearing the screen.
 Date: 2024-06-03
 Modifies: sonic.asm (ClearScreen:)

## Shield/Invincibility Positioning Fix
 Credit: Mercury
 Function: Correctly positions the Shield/Invincibility sprites when balancing on ledges.
 Date: 2024-06-03
 Modifies: _incObj\38 Shield and Invincibility.asm

## FZ Boss Hit Count Fix
 Credit: Mercury
 Function: Prevents an underflow glitch when hitting the Final Zone boss an extra time.
 Date: 2024-06-03
 Modifies: _incObj\85 Boss - Final.asm
 
## Fix Race Condition w/ Pattern Load Cues
 Credit: FraGag
 Function: Fixes bug that sometimes crashes the game if roll and look down after passing End Sign in LZ1 and LZ2
 Date: 2024-06-03
 Modifies: sonic.asm (RunPLC:)
 
## Title Screen PSB Fix
 Credit: Quickman
 Function: Some adjustments to the Title Screen to make it look more correct. Under-the-hood tweaks as well. (PSB fix, GHZ palette, Title Screen centered)
 Date: 2024-06-03
 Modifies: sonic.asm, _inc\PaletteCycle.asm, _inc\Palette Pointers.asm, _incObj/0E Title Screen Sonic.asm, _incObj/0F Press Start and TM.asm

## Accidental Deletion of Scattered Rings
 Credit: Redhotsonic
 Function: Fixed a bug related to rings deleting themselves incorrectly in a vertically wrapping level (LZ3 or SBZ2)
 Date: 2024-06-03
 Modifies: _incObj/25 & 37 Rings.asm
 
## Fixed Ring Timers
 Credit: Redhotsonic
 Function: Fixed lost rings so that they have individual expiration timers
 Date: 2024-06-03
 Modifies: _incObj/25 & 37 Rings.asm
 
## Fixed Drowning Bugs
 Credit: Redhotsonic
 Function: Fixed bugs that occur when drowning in the Hurt State or on a Time Over. Added Drowning routine to Sonic
 Date: 2024-06-04
 Modifies: _incObj/0A - Drowning Countdown.asm, sonic.asm; Added _incObj/Sonic Drowns.asm
 
## Horizontal Camera Scrolling Fixes
 Credit: MarkeyJester
 Function: Adds a check for scrolling to the left (Useful fix for those adding cutscenes), and prevents horizontal wrapping glitches.
 Date: 2024-06-04
 Modifies: _inc\DeformLayers.asm (MoveScreenHoriz:)

## Game Over Flicker Fix
 Credit: RetroKoH
 Function: Removes the unintentional flicker of the GAME OVER object once it reaches center screen.
 Date: 2024-06-04
 Modifies: _incObj/39 Game Over.asm

## Bottom Boundary Death Fix
 Credit: RetroKoH
 Function: Prevents accidental sudden deaths by handling the bottom boundary appropriately.
 Date: 2024-06-04
 Modifies: _incObj/Sonic LevelBound.asm

## RememberSprite Bugfix
 Credit: MarkeyJester
 Function: Fixes a bug in which objects load that are set as destroyed, or vise versa.
 Date: 2024-06-05
 Modifies: sonic.asm
 
## DisplaySprite Bugfix
 Credit: Clownacy
 Function: Fixes an absolute mess of a bug that can occur if using newer mappings formats.
 Date: 2024-06-06

## Fix Scattered Rings Underwater Physics
 Credit: Redhotsonic
 Function: Gives proper underwater physics to scattered rings.
 Date: 2024-06-07
 
## Buzz Bomber Missile Positioning Fix
 Credit: Clownacy
 Function: Positions the fired missile to be properly underneath the Buzz Bomber.
 Date: 2024-06-07
 
## Water Surface Gap Fix
 Credit: LuigiXHero
 Function: Fixes a minor gap on the left side of the water surface when pausing the game.
 Date: 2024-06-07

## Fixed Special Stage Jump Physics
 Credit: Mercury
 Function: Gives Sonic a variable jump height in the special stage.
 Date: 2024-06-07

## Proper Push Sensors While Rolling
 Credit: Devon/Ralakimus
 Function: Sonic's push sensors will be adjusted properly while rolling, much as they are while walking/running.
 Date: 2024-06-07

## Proper Detection of Invisible Solid Barriers
 Credit: Devon/Ralakimus
 Function: This resolves the bugs in MZ and SBZ1 where you can duck through invisible solids while on a solid object.
 Date: 2024-06-07

## Final Zone Plasma Ball Positioning Fix
 Credit: Devon/Ralakimus
 Function: This fixes a minor bug with positioning. The plasma balls work as they do in the 2013 remake.
 Date: 2024-06-07

## SBZ Trapdoor Glitch Fix
 Credit: Devon/Ralakimus
 Function: This fixes a minor visual bug where trapdoor sprites can appear on-screen just before despawning.
 Date: 2024-06-07

## GHZ Vertical Scrolling Fix
 Credit: OrionNavattan
 Function: This fix makes the background scroll in a more "correct" direction vertically.
 Date: 2024-06-07

## PLC Queue Shifting Bug Fix
 Credit: Vladikcomper
 Function: This fix allows users to put a full $10 (16) entries into a single PLC queue as intended.
 Date: 2024-06-08
 
## Spike SFX Fix
 Credit: Mercury
 Function: Makes the proper sound effect play when Sonic is harmed by Spikes/LZ Harpoons.
 Date: 2024-06-08
 
## Various Sound Driver Fixes
 Credit: Clownacy, ValleyBell, et al.
 Function: Fixed various issues including a corrupted roll sfx.
 Date: 2024-06-15
 
## Look Shift Fix
 Credit: Mercury
 Function: Fixing the looking up/down camera shift so that it stops at zone boundaries, preventing a delay when returning to the neutral position.
 Date: 2024-06-18
 Modifies: _incObj/Sonic Move.asm
 
## Caterkiller Fix
 Credit: Mercury
 Function: Fixes an issue where Caterkiller would sometimes hurt you if you roll into its head quickly.
 Date 2024-06-18
 Modifies: _incObj/ReactToItem.asm, _incObj/78 Caterkiller.asm

## Continue Sonic Art Fix
 Credit: Mercury
 Function: Fixes some incorrect pixels in Sonic's Continue screen sprite.
 Date: 2024-06-18
 Modifies: artnem\Continue Screen Sonic.nem

## Special Stage Palette Fix
 Credit: Mercury
 Function: Fixed the base palette to prevent clouds flickering when first fading in, plus altered the fading palette to not have ugly clashing purples
 Date: 2024-06-18
 Modifies: palette\Cycle - Special Stage 1.bin, palette\Special Stage.bin

## Sonic Shoe Stripe Fix
 Credit: Mercury
 Function: Adds stripe to Sonic's shoe for the sprites it's missing in (using Sonic 2's tiles)
 Date: 2024-06-18
 Modifies: artunc\Sonic.bin

## Rolling Jump Fix
 Credit: RetroKoH
 Function: Fixes a bug with landing in air from a rolling jump
 Date: 2024-06-18
 Modifies: _incObj/Sonic Jump.asm

## Rolling Speed Cap Fix
 Credit: Devon
 Function: Fixes an inconsistency with the rolling speed cap. (Only applied if GroundSpeedCapEnabled=1)
 Date: 2024-06-18
 Modifies: _incObj/Sonic RollSpeed.asm
 
## GHZ3 Wall Solidity
 Credit: Mercury
 Function: Fixes a wall object in GHZ3 after the Lamppost that was set to be solid. (It was, of course, solid for a reason: to fix a bug with the platform right next to it. However, the platform could be moved to the right by 16 pixels to solve the problem, too, so that's what I did.)
 Date: 2024-06-18
 Modifies: objpos\GHZ3 (JP1).bin
 
## GHZ2 Spring Fix
 Credit: Mercury
 Function: Fixes an incorrectly flipped red spring on the lower route of GHZ2
 Date: 2024-06-18
 Modifies: objpos\GHZ2.bin
 
## GHZ BG Mountain Fix
 Credit: Mercury
 Function: Fixes a tile in the GHZ mountain background that makes it looks like there's a hole in the biggest peaks.
 Date: 2024-06-18
 Modifies: map128\GHZ.bin

## Low End Signs Fix
 Credit: Mercury
 Function: Some End Signs have been raised to rest properly on the ground.
 Date: 2024-06-18
 Modifies: objpos\SYZ1.bin, objpos\LZ1.bin, objpos\LZ2.bin, objpos\SBZ1.bin, objpos\SBZ2.bin

## SLZ Pylons Fix
 Credit: Mercury
 Function: Removes the SLZ pylons from the object layout files and instead loads them manually when the zone starts. This allows them to appear even when respawning at a Lamppost.
 Date: 2024-06-18
 Modifies: objpos\SLZ1.bin, objpos\SLZ2.bin, objpos\SLZ3.bin

## Greater Debug Mode Control
 Credit: RetroKoH
 Function: User can now enter/exit Debug Mode in non-normal control states properly.
 Date: 2024-06-20
 
## Angled Animation Improvement
 Credit: Mercury
 Function: Makes Sonic appear correctly when running down certain angles (notably GHZ1) akin to the remakes.
 Date: 2024-06-21
 
## Rolling Turn Around Fix
 Credit: Mercury
 Function: Prevents Sonic from turning around while rolling (which without this fix could be abused to roll in place forever).
 Date: 2024-06-22
 Modifies: Sonic RollSpeed.asm
 
## Fix modulation during rests
 Credit: ValleyBell
 Function: Sound driver applies the modulation effect on rests where the frequency is set to 0, so it sort of corrupts the frequency.
 Date: 2024-06-23
  Modifies: s1.sounddriver.asm
  
## Fix Modulation Frequency bug on note-on
 Credit: AURORA☆FIELDS/Natsumi
 Function: Sound driver forgets to include modulation frequency when updating frequency just after reading the tracker
 Date: 2024-06-23
 Modifies: s1.sounddriver.asm
 
## NE Corner Reloading Glitch Fix
 Credit: SpirituInsanum
 Function: Fixed some graphical glitching that'd occur in the top-right corner when going very fast.
 Date: 2024-06-24
 Modifies: sonic.asm
 
## Boundary SpinDash Bugfix
 Credit: RHS/Esrael?
 Function: Fixed a bug that caused Sonic to lock in place when trying to spindash at the edge of the screen.
 Date: 2024-07-07
 
## SLZ Solidity Fix
 Credit: Mercury/RetroKoH (Fixed a few things that Mercury missed)
 Function: Fixes goofy solidity in SLZ that allows Sonic to fall through the tops of some chunks.
 Date: 2024-07-16
 
## MZ2 Layout Fix
 Credit: Mercury
 Function: Moves the End Sign further right so the level won't feel so truncated.
 Date: 2024-07-16
 Depends On: Exit DLE In Special Stage And Title
 Modifies: levels\mz2.bin, objpos\mz2.bin, _inc\LevelSizeLoad & BgScrollSpeed.asm

## Eggman Art Fix
 Credit: Mercury
 Function: Fixes Eggman's mappings so that his moustache isn't cut off.
 Date: 2024-07-16
 Modifies: _maps\Eggman.asm

## Fixed Shields and SpinDash Dust Misalignment
 Credit: RetroKoH
 Function: Shields and Spindash dust now stay aligned w/ Sonic on moving platforms.
 Date: 2024-08-20

## Fixed Animation Resetting
 Credit: Hame
 Function: Fixes a minor issue where animations don't always reset upon landing on the floor.
 Date: 2024-08-20

## LZ3 Zip Fix
 Credit: Hame
 Function: Prevents a potential zip due to faulty collision at the start of LZ3.
 (Only possible due to added abilities, but is a result of Sonic 1's collision)
 Date: 2024-08-21

## Spring Direction Fix
 Credit: RetroKoH
 Function: Fixes a minor bug w/ horizontal springs sometimes making Sonic face incorrectly.
 Date: 2024-08-21

## Monitor Solidity Fix
 (Incomplete)
 Credit: RetroKoH
 Function: Fixes the monitor's wonky solidity.
 Date: 2024-08-22
