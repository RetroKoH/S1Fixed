# S1Fixed
 A successor to ReadySonic (Bugfixes, Optimizations, Changes)

# Credits
 RetroKoH - S1Fixed
 Mercury - Original ReadySonic
 Clownacy - Updated S1 One Two-Eight Base
 MarkeyJester - Original S1 One Two-Eight Base
 Mods/Fixes, etc. are credited to the respective authors below

# Mods (Can be enabled or disabled)

# Under-the-Hood Changes/Overhauls
 Name: 128x128 Chunk Format
 Credit: Clownacy
 Function: Layout Chunks are now 128x128 in size, akin to Sonic 2 and Sonic 3K
 Date: 2024-04-23

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

 Name: Sega Sound Fix (Will likely be irrelevant once MegaPCM2 is imported)
 Credit: Puto
 Function: Fixes the Sega sound at game start so that it won't garble when code is added to the ROM. Also allows the player to skip it with the Start Button.
 Date: 2024-06-03
 Modifies: s1.sounddriver.asm
