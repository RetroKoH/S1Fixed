# S1Fixed
 A successor to ReadySonic (Bugfixes, Optimizations, Changes)

# Credits
 RetroKoH - S1Fixed
 Mercury - Original ReadySonic
 Clownacy - Updated S1 One Two-Eight Base
 MarkeyJester - Original S1 One Two-Eight Base
 Mods/Fixes, etc. are credited to the respective authors below

# Mods (Can be enabled or disabled using the noted variables at the start of sonic.asm)
 Name: Dynamic Special Stage Walls (and Smmoth Rotation)
 Credit: Mercury/Cinossu
 Function: Dynamically loads the wall art in the Special Stages to free VRAM (for things like the HUD)
 Date: 2024-06-04
 Modifies: sonic.asm, _maps\SS Walls.asm, _inc\Pattern Load Cues.asm, 09 Sonic in Special Stage.asm
 Variables: DynamicSpecialStageWalls, SmoothSpecialStages
 
 Name: Fade-In SEGA Screen
 Credit: RetroKoH
 Function: Causes the SEGA Screen to fade in, instead of just popping in.
 Date: 2024-06-06
 Variable: FadeInSEGA

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
