; ---------------------------------------------------------------------------
; Object Status Table Constants (Rearranged for S3K Priority and Object Managers -- RetroKoH)
; Nomenclature adopted from s1disasm, Sorting adopted from s2disasm
;
; All object-specific OST constants are defined here
; ---------------------------------------------------------------------------
; Universal OSTs
obID:					equ 0				; 1 byte  | object ID number
obRender:				equ 1				; 1 byte  | bitfield for x/y flip, display mode	(1 byte)
obGfx:					equ 2				; 2 bytes | palette line & VRAM setting
obMap:					equ 4				; 4 bytes | sprite mappings address
obX:					equ 8				; 2 bytes | x-axis position
obXSub:					equ obX+2			; 2 bytes | x-axis subpixel position
obScreenY:				equ obXSub			; 2 bytes | screen-fixed y-axis position
obY:					equ $C				; 2 bytes | y-axis position
obYSub:					equ obY+2			; 2 bytes | y-axis subpixel position
obPriority:				equ $18				; 2 bytes | sprite stack priority
obFrame:				equ $1A				; 1 byte  | current frame displayed
obDispWid:				equ $23				; 1 byte  | display width/2
; ---------------------------------------------------------------------------
; conventions followed by most objects including Sonic:
obVelX:					equ $10				; 2 bytes | x-axis velocity
obVelY:					equ $12				; 2 bytes | y-axis velocity
obHeight:				equ $16				; 1 byte  | height/2
obWidth:				equ $17				; 1 byte  | width/2
obAniFrame:				equ $1B				; 1 byte  | current frame in animation script
obAnim:					equ $1C				; 1 byte  | current animation
obPrevAni:				equ $1D				; 1 byte  | restart animation flag / next animation number (Sonic)
obTimeFrame:			equ $1E				; 1 byte  | time to next frame (1 byte) / general timer (2 bytes)
obDelayAni:				equ $1F				; 1 byte  | anim delay time (also used as TimeFrame low byte)
obStatus:				equ $22				; 1 byte  | orientation or mode
obRoutine:				equ $24				; 1 byte  | routine number
obAngle:				equ $26				; 1 byte  | angle
; ---------------------------------------------------------------------------
; conventions followed by many objects but NOT Sonic
obRespawnAddr:			equ $14				; 2 bytes | respawn list address
obColType:				equ $20				; 1 byte  | collision response type
obColProp:				equ $21				; 1 byte  | collision extra property
ob2ndRout:				equ $25				; 1 byte  | secondary routine number
obShieldProp:			equ $27				; 1 byte  | How object responds to shields {Reflect-Lightning-Bubble-Flame 0-0-0-0}
obSubtype:				equ $28				; 1 byte  | object subtype
obBossX:				equ $30				; 2 bytes | 
obBossY:				equ $38				; 2 bytes | 
obParent:				equ $3E				; 2 bytes | 
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
; All object-specific OST constants are defined below
; ---------------------------------------------------------------------------

; Obj01 - Sonic
obInertia:				equ $20				; 2 bytes | ground velocity
;						equ $25
;						equ $28
obAutoRollFlag:			equ $2A				; 1 byte  | auto-roll (pinball mode) flag
;						equ $2B
;						equ $2F
obInvuln:				equ $30				; 1 byte  | invulnerablity timer (blinking frames when hurt)
obInvinc:				equ $31				; 1 byte  | invincibility stars timer
obShoes:				equ $32				; 1 byte  | speed shoes timer
obCtrlLock:				equ $35				; 1 byte  | formerly f_playerctrl (0, 1, or $81)
obFrontAngle:			equ $36				; 1 byte  | angle on ground in front of sprite
obRearAngle:			equ $37				; 1 byte  | angle on ground behind sprite
obOnWheel:				equ $38				; 1 byte  | on convex wheel flag
obStatus2nd:			equ $39				; 1 byte  | secondary status counter
obRestartTimer:			equ $3A				; 2 bytes | level restart timer
obJumping:				equ $3C				; 1 byte  | jumping flag
obLRLock:				equ $3D				; 1 byte  | flag preventing left and right input
obPlatformAddr:			equ $3E				; 2 bytes | address of object Sonic's on top of

	if (ShieldsMode|DropDashEnabled)
obDoubleJumpProp:		equ $25				; 1 byte  | Counter for Sonic's Drop Dash (if enabled). Can also be utilized for remaining frames of flight / 2 for Tails, gliding-related for Knuckles.
obDoubleJumpFlag:		equ	$2F				; 1 byte  | Double jump status (0 - not triggered; 1 - triggered; 2 - post-instashield/drop dash revving; 3 - Drop Dash Cancelled)
	endif

	if WallJumpEnabled
obWallJump:				equ $28				; 2 bytes | used for wall jumps
	endif

	if (SpinDashEnabled|PeeloutEnabled)
obSpinDashFlag:			equ obAutoRollFlag	; 1 byte  | spin dash/peelout flag
obSpinDashCounter:		equ obRestartTimer	; 2 bytes | Counter used for the Spin Dash and/or Peelout
	endif
; ---------------------------------------------------------------------------

; Obj03 - Path Swapper Tag
obPSwap_Radius:			equ objoff_32		; 2 bytes | width/height of the tag
obPSwap_Flag:			equ objoff_34		; 1 byte  | flag utilized during handling
; ---------------------------------------------------------------------------

; Obj04 - Auto Roll Tag (identical to Obj03)
obARoll_Radius:			equ obPSwap_Radius	; 2 bytes | width/height of the tag
obARoll_Flag:			equ obPSwap_Flag	; 1 byte  | flag utilized during handling
; ---------------------------------------------------------------------------

; Obj07 - Dust Effects
obEff_DustTimer:		equ objoff_32		; 1 byte  | timer for generating dust
obEff_PrevFrame:		equ objoff_3F		; 1 byte  | stored frame for DPLC handling
; ---------------------------------------------------------------------------

; Obj09 - Special Stage Sonic
obSSSonic_SSItemID:		equ objoff_30		; 1 byte  | item id Sonic is touching
obSSSonic_SSItemAddr:	equ objoff_32		; 4 bytes | RAM address of item in layout Sonic is touching
obSSSonic_UpDownTime:	equ objoff_36		; 1 byte  | time until UP/DOWN can be triggered again
obSSSonic_ReverseTime:	equ objoff_37		; 1 byte  | time until Reverse can be triggered again
obSSSonic_RestartTime:	equ objoff_38		; 2 bytes | time until game mode changes after exiting SS (nonfunctional)
obSSSonic_GhostStatus:	equ objoff_3A		; 1 byte  | status of ghost blocks (0 = ghost; 1 = passed; 2 = solid)
; ---------------------------------------------------------------------------

; Obj0A - LZ Drowning Countdown Numbers
obDrown_RestartTime:	equ objoff_2C		; 2 bytes | time to restart after Sonic drowns
obDrown_StartX:			equ objoff_30		; 2 bytes | starting X-axis position
obDrown_DisplayTime:	equ objoff_32		; 1 byte  | time to display each number
obDrown_BubbleType:		equ objoff_33		; 1 byte  | bubble type
obDrown_ExtraBubbles:	equ objoff_34		; 1 byte  | number of extra bubbles to create
obDrown_ExtraFlag:		equ objoff_36		; 2 bytes | flags for extra bubbles
obDrown_NumberTime:		equ objoff_38		; 2 bytes | time between each number changes
obDrown_DelayTime:		equ objoff_3A		; 2 bytes | delay between bubbles
; ---------------------------------------------------------------------------

; Obj0B - LZ Breakable Pole
obPole_GrabTime:		equ objoff_30		; 2 bytes | time between grabbing the pole & breaking
; ---------------------------------------------------------------------------

; Obj0C - LZ Flapping Door
obFlap_Wait:			equ objoff_30		; 2 bytes | time until change
obFlap_Time:			equ objoff_32		; 2 bytes | time between opening/closing
; ---------------------------------------------------------------------------

; Obj0D - Signpost
obSign_SpinTime:		equ objoff_30		; 2 bytes | time for signpost to spin
obSign_SparkleTime:		equ objoff_32		; 2 bytes | time between sparkles
obSign_SparkleCount:	equ objoff_34		; 1 byte  | counter to keep track of sparkles
obSign_StartY:			equ objoff_36		; 2 bytes | starting Y-axis position (For Floating Signpost mod)
obSign_PrevFrame:		equ objoff_3F		; 1 byte  | stored frame for DPLC handling
; ---------------------------------------------------------------------------

; Obj0E - Title Screen Sonic
obTitlSon_PrevFrame:	equ objoff_3F		; 1 byte  | stored frame for DPLC handling
; ---------------------------------------------------------------------------

; Obj0F - Press Start + TM (& Menu)
obPSB_MenuOption:		equ objoff_30		; 1 byte  | option chosen in the menu (For SaveProgressMod)
; ---------------------------------------------------------------------------

; Obj10 - Subsprite Test Object
obTest_ChildObj:		equ objoff_3E		; 2 bytes | address of the child object with the subsprites
; ---------------------------------------------------------------------------

; Obj11 - GHZ Bridge
obBridge_ChildObj1:		equ objoff_30		; 2 bytes | address of the first child object with log subsprites
obBridge_ChildObj2:		equ objoff_32		; 2 bytes | address of the second child object with log subsprites
obBridge_StartY:		equ objoff_3C		; 2 bytes | starting Y-axis position
obBridge_BendPixels:	equ objoff_3E		; 1 byte  | number of pixels a log has been depressed
obBridge_CurrentLog:	equ objoff_3F		; 1 byte  | log Sonic is currently standing on (left to right, starts at 0)
; ---------------------------------------------------------------------------

; Obj14 - MZ/LZ Fireballs
obFBall_StartY:			equ objoff_30		; 2 bytes | starting Y-axis position
; ---------------------------------------------------------------------------

; Obj15 - GHZ, MZ, SLZ Swinging Platforms/SBZ Spikeball on Chain
obSwing_Angle:			equ $10				; 2 bytes | precise rotation angle
	; ^^^ We need this so that obShieldProp isn't overwritten, otherwise
	; Insta-Shield negates its collision property. Upper byte written to obAngle.
	; Unlike other similar objects, I set this to $10 because the GHZ boss chain
	; uses up much of its scratch RAM, and that object uses this object's movement
	; routines.
obSwing_StartY:			equ objoff_38		; 2 bytes | starting Y-axis position
obSwing_StartX:			equ objoff_3A		; 2 bytes | starting X-axis position
obSwing_Radius:			equ objoff_3C		; 1 byte  | distance of chainlink from anchor
obSwing_Unk:			equ objoff_3E		; 2 bytes | unused (obBossBall_Speed)
; ---------------------------------------------------------------------------

; Obj16 - LZ Harpoon
obHarpoon_Time:			equ objoff_30		; 1 byte  | time between stabbing/retracting
; ---------------------------------------------------------------------------

; Obj17 - GHZ Spiked Log Helix
obHel_ChildObj:			equ objoff_30		; 2 bytes | pointer to the helix subsprite object
obHel_OffsetX:			equ objoff_38		; 2 bytes | x-offset amount to ensure proper rendering
obHel_StartX:			equ objoff_3A		; 2 bytes | starting X-axis offset position (obX+OffsetX)
; ---------------------------------------------------------------------------

; Obj18 - GHZ, SYZ, SLZ Platforms
obPlat_Unk:				equ objoff_25		; 1 byte  | unused; it gets cleared once, and that's it...
obPlat_Movement:		equ objoff_26		; 1 byte  | Type 01 platform movement variable
obPlat_YPosActual:		equ objoff_2C		; 2 bytes | y position ignoring dip when Sonic is on the platform
obPlat_StartX:			equ objoff_32		; 2 bytes | starting X-axis position
obPlat_StartY:			equ objoff_34		; 2 bytes | starting Y-axis position
obPlat_NudgeY:			equ objoff_38		; 1 byte  | amount of dip when Sonic is on the platform
obPlat_WaitTime:		equ objoff_3A		; 2 bytes | time delay for platform moving when stood on
; ---------------------------------------------------------------------------

; Obj1A - GHZ Collapsing Ledge
obLedge_WaitTime:		equ objoff_38		; 1 byte  | time between touching the ledge and it collapsing
obLedge_CollapseFlag:	equ objoff_3A		; 1 byte  | flag set when ledge is stood on
; ---------------------------------------------------------------------------

; Obj1B - LZ Water Surface
obSurf_StartX:			equ objoff_30		; 2 bytes | starting X-axis position
obSurf_Freeze:			equ objoff_32		; 1 byte  | flag to freeze animation
; ---------------------------------------------------------------------------

; Obj1D - LZ Water Surface
obSwi_StartY:			equ objoff_30		; 2 bytes | starting Y-axis position
; ---------------------------------------------------------------------------

; Obj1E - BallHog Badnik
obHog_LaunchFlag:		equ objoff_32		; 1 byte  | 0 to launch a cannonball
; ---------------------------------------------------------------------------

; Obj1F - Crabmeat Badnik
obCrab_WaitTime:		equ objoff_30		; 2 bytes | time until crabmeat fires
obCrab_Mode:			equ objoff_32		; 1 byte  | current action - 0/1 = not firing; 2/3 = firing
; ---------------------------------------------------------------------------

; Obj20 - BallHog Cannonball
obCBall_Time:			equ objoff_30		; 2 bytes | time until the cannonball explodes
; ---------------------------------------------------------------------------

; Obj21 - Invincibility Stars
obStars_TrackData:		equ objoff_30		; 4 bytes | tracking data for stars
; ---------------------------------------------------------------------------

; Obj22 - Buzz Bomber Badnik
obBuzz_WaitTime:		equ objoff_32		; 2 bytes | time delay for each action
obBuzz_Mode:			equ objoff_34		; 1 byte  | current action - 0 = flying; 1 = recently fired; 2 = near Sonic
; ---------------------------------------------------------------------------

; Obj23 - Buzz Bomber's Missile
obMissile_WaitTime:		equ objoff_32		; 2 bytes | time delay
obMissile_Parent:		equ objoff_3E		; 2 bytes | RAM address of parent object
; ---------------------------------------------------------------------------

; Obj25 - Ring (Debug Mode Exclusive)
obRing_MainX:			equ objoff_32		; 2 bytes | stored X-axis position of ring (unnecessary?)
; ---------------------------------------------------------------------------

; Obj27 - Explosion from Enemy or Monitor (unsure which object this should be assigned to)
obEnemy_Combo:			equ objoff_3E		; 2 bytes | number of enemies broken in a row (0-$A)
; ---------------------------------------------------------------------------

; Obj28 - Animals
obAnimal_Direction:		equ objoff_29		; 1 byte  | animal goes left/right
obAnimal_Type:			equ objoff_30		; 1 byte  | type of animal (0-$B)
obAnimal_VelX:			equ objoff_32		; 2 bytes | horizontal speed
obAnimal_VelY:			equ objoff_34		; 2 bytes | vertical speed
obAnimal_PrisonNum:		equ objoff_36		; 2 bytes | id num for animals in prison capsule, lets them jump out 1 at a time
obAnimal_CapsuleAddr:	equ objoff_3C		; 2 bytes | address of prison capsule that spawned this animal (if applicable)
;obEnemy_Combo:			equ objoff_3E		; 2 bytes | number of enemies broken in a row (0-$A)
; ---------------------------------------------------------------------------

; Obj2B - Chopper Badnik
obChop_StartY:			equ objoff_30		; 2 bytes | starting Y-axis position
; ---------------------------------------------------------------------------

; Obj2C - Jaws Badnik
obJaws_TurnTime:		equ objoff_30		; 2 bytes | time until jaws turns
obJaws_TimeDelay:		equ objoff_32		; 2 bytes | time between turns, copied to ost_jaws_turn_time every turn
; ---------------------------------------------------------------------------

; Obj2D - Burrobot Badnik
obBurro_TurnTime:		equ objoff_30		; 2 bytes | time between direction changes
obBurro_FloorDetect:	equ objoff_32		; 1 byte  | flag set every other frame to detect edge of floor
; ---------------------------------------------------------------------------

; Obj2F - MZ Large Grass-Covered Platform
obLGrass_StartX:		equ objoff_2A		; 2 bytes | starting X-axis position
obLGrass_StartY:		equ objoff_2C		; 2 bytes | starting Y-axis position
obLGrass_ColPtr:		equ objoff_30		; 4 bytes | pointer to collision data
obLGrass_SinkPixels:	equ objoff_34		; 1 byte  | pixels the platform has sunk when stood on
obLGrass_BurnFlag:		equ objoff_35		; 1 byte  | 0 = not burning; 1 = burning
obLGrass_Children:		equ objoff_36		; 8 bytes | OST indices of child objects
;TO-DO Make the Children use word-length pointers
; ---------------------------------------------------------------------------

; Obj30 - MZ Large Green Glass Blocks
obGlass_StartY:			equ objoff_30		; 2 bytes | starting Y-axis position
obGlass_DistY:			equ objoff_32		; 2 bytes | distance block moves when switch is pressed
obGlass_MoveMode:		equ objoff_34		; 1 byte  | 1 when block moves after switch is pressed
obGlass_JumpInit:		equ objoff_35		; 1 byte  | 1 when block has been jumped on at least once
obGlass_SinkDist:		equ objoff_36		; 2 bytes | distance to make block sink when jumped on (unused type 3 block)
obGlass_SinkDelay:		equ objoff_38		; 1 byte  | time to delay block sinking
obGlass_Parent:			equ objoff_3E		; 2 bytes | RAM address of parent object
; ---------------------------------------------------------------------------

; Obj31 - MZ Chained Stompers
obCStom_StartY:			equ objoff_30		; 2 bytes | starting Y-axis position
obCStom_ChainLength:	equ objoff_32		; 2 bytes | current chain length
obCStom_ChainMax:		equ objoff_34		; 2 bytes | maximum chain length
obCStom_RiseFlag:		equ objoff_36		; 2 bytes | 0 = falling; 1 = rising
obCStom_DelayTime:		equ objoff_38		; 2 bytes | time delay between fully extended and rising again
obCStom_SwitchID:		equ objoff_3A		; 1 byte  | switch number for the current stomper
obCStom_Parent:			equ objoff_3E		; 2 bytes | RAM address of parent object
; ---------------------------------------------------------------------------

; Obj33 - MZ Pushable Blocks
obPushB_LavaSpeed:		equ objoff_30		; 2 bytes | x axis speed when block is on lava
obPushB_LavaFlag:		equ objoff_32		; 1 byte  | 1 = block is on lava
obPushB_StartX:			equ objoff_34		; 2 bytes | starting X-axis position
obPushB_StartY:			equ objoff_36		; 2 bytes | starting Y-axis position
; ---------------------------------------------------------------------------

; Obj34 - Title Cards
obTCard_DisplayX:		equ objoff_30		; 2 bytes | position for card to display on
obTCard_FinalX:			equ objoff_32		; 2 bytes | position for card to finish on
; ---------------------------------------------------------------------------

; Obj35 - MZ Burning Grass
obGFire_StartX:			equ objoff_2A		; 2 bytes | starting X-axis position
obGFire_StartY:			equ objoff_2C		; 2 bytes | starting Y-axis position
obGFire_ColPtr:			equ objoff_30		; 4 bytes | pointer to collision data
obGFire_Parent:			equ objoff_38		; 2 bytes | RAM address of parent object
obGFire_SinkPixels:		equ objoff_3C		; 2 bytes | pixels the platform has sunk when stood on
; ---------------------------------------------------------------------------

; Obj36 - Spikes
obSpike_StartX:			equ objoff_30		; 2 bytes | starting X-axis position
obSpike_StartY:			equ objoff_32		; 2 bytes | starting Y-axis position
obSpike_MoveDist:		equ objoff_34		; 2 bytes | pixel distance to move object * $100, either direction
obSpike_MoveFlag:		equ objoff_36		; 2 bytes | 0 = original position; 1 = moved position
obSpike_MoveTime:		equ objoff_38		; 2 bytes | time until object moves again
; ---------------------------------------------------------------------------

; Obj38 - Shields
obShield_ArtLoc			equ	objoff_38		; 4 bytes | pointer to art data
obShield_DPLCLoc		equ	objoff_3C		; 4 bytes | pointer to DPLC data
; ---------------------------------------------------------------------------

; Obj3A - Has Passed Card (shared offstes with Title Cards)
obEoLCard_DisplayX:	equ obTCard_DisplayX	; 2 bytes | position for card to display on
obEoLCard_FinalX:	equ obTCard_FinalX		; 2 bytes | position for card to finish on
; ---------------------------------------------------------------------------

; Obj3E - Animal Prison
obPrison_StartY:		equ objoff_30		; 2 bytes | starting Y-axis position
obPrison_AnimalCount:	equ objoff_3F		; 1 byte  | number of animals spawned from the prison
; ---------------------------------------------------------------------------

; Obj40 - Moto Bug
obMoto_TurnTime:		equ objoff_30		; 2 bytes | time delay before changing direction
obMoto_SmokeDelay:		equ objoff_33		; 1 byte  | time delay between smoke puffs
; ---------------------------------------------------------------------------

; Obj41 - Springs
obSpring_Power:			equ objoff_30		; 2 bytes | power of current spring
; ---------------------------------------------------------------------------

; Obj42 - Newtron
obNewt_FireFlag:		equ objoff_32		; 1 byte  | set to 1 after newtron fires a missile
; ---------------------------------------------------------------------------

; Obj43 - Roller
obRoller_OpenTime:		equ objoff_30		; 2 bytes | time roller stays open for
obRoller_Mode:			equ objoff_32		; 1 byte  | +1 = roller has jumped; +$80 = roller has stopped
; ---------------------------------------------------------------------------

; Obj45 - MZ Unused Sideways Stomper (Similar to obobCStom, but not identical)
obSStom_StartX:			equ objoff_30		; 2 bytes | starting X-axis position
obSStom_ChainLength:	equ objoff_32		; 2 bytes | current pole length
obSStom_ChainMax:		equ objoff_34		; 2 bytes | maximum pole length
obSStom_RiseFlag:		equ objoff_36		; 2 bytes | 1 = retract
obSStom_DelayTime:		equ objoff_38		; 2 bytes | time to wait while fully extended
obSStom_StartY:			equ objoff_3A		; 2 bytes | starting Y-axis position
obSStom_Parent:			equ objoff_3E		; 2 bytes | RAM address of parent object
; ---------------------------------------------------------------------------

; Obj46 - MZ Brick (some fall from above)
obBrick_StartY:			equ objoff_30		; 2 bytes | starting Y-axis position
; ---------------------------------------------------------------------------

; Obj48 - GHZ Boss Swinging Ball
obBossBall_ChainHead:	equ objoff_30		; 2 bytes | chain head address (for swinging ball visual effect)
obBossBall_BossDist:	equ objoff_32		; 2 bytes | distance of base from boss
obBossBall_Parent:		equ objoff_34		; 4 bytes | address of OST of parent object (need to truncate to 2 bytes)
obBossBall_BaseY:		equ objoff_38		; 2 bytes | Y-axis position of base
obBossBall_BaseX:		equ objoff_3A		; 2 bytes | X-axis position of base
obBossBall_Radius:		equ objoff_3C		; 1 byte  | distance of ball/link from base
obBossBall_Side:		equ objoff_3D		; 1 byte  | which side the ball is on - 0 = right; 1 = left
obBossBall_Speed:		equ objoff_3E		; 2 bytes | rate of change of angle
; ---------------------------------------------------------------------------

; Obj4A - Unused Special Stage Entry Vanishing Sprite
obVanish_Timer:			equ objoff_30		; 1 byte  | time for Sonic to disappear
; ---------------------------------------------------------------------------

; Obj4C - MZ Lava Geyser Maker
obGMake_WaitTime:		equ objoff_32		; 2 bytes | current time remaining
obGMake_WaitTotal:		equ objoff_34		; 2 bytes | time delay
obGMake_Parent:			equ objoff_3E		; 2 bytes | RAM address of parent object
; ---------------------------------------------------------------------------

; Obj4D - MZ Lava Geyser / Lavafall
obGeyser_StartY:		equ objoff_30		; 2 bytes | starting Y-axis position
obGeyser_Parent:		equ objoff_3E		; 2 bytes | RAM address of parent object
; ---------------------------------------------------------------------------

; Obj4E - MZ Lava Wall
obLWall_MoveFlag:		equ objoff_36		; 1 byte  | flag to start wall moving
obLWall_Parent:			equ objoff_3E		; 2 bytes | RAM address of parent object
; ---------------------------------------------------------------------------

; Obj50 - Yadrin Badnik
obYadrin_WaitTime:		equ objoff_3E		; 2 bytes | time to wait before changing direction
; ---------------------------------------------------------------------------

; Obj51 - MZ Smashable Green Block
obSmab_SonicAnim:		equ objoff_32		; 1 byte  | Sonic's current animation number
obSmab_HitCount:		equ objoff_34		; 2 bytes | number of blocks hit + enemies previously hit in a single jump
; ---------------------------------------------------------------------------

; Obj52 - MZ, LZ, SBZ Moving Blocks
obMBlock_StartX:		equ objoff_30		; 2 bytes | starting X-axis position
obMBlock_StartY:		equ objoff_32		; 2 bytes | starting Y-axis position
obMBlock_WaitTime:		equ objoff_34		; 2 bytes | time delay before moving platform back - subtype x9/xA only
obMBlock_MoveFlag:		equ objoff_36		; 2 bytes | 1 = move platform back to its original position - subtype x9/xA only
; ---------------------------------------------------------------------------

; Obj53 - MZ, LZ, SBZ Collapsing Floors
obCFloor_WaitTime:		equ objoff_38		; 2 bytes | time delay for collapsing floor
obCFloor_TouchFlag:		equ objoff_3A		; 2 bytes | 1 = Sonic has touched the floor
; ---------------------------------------------------------------------------

; Obj55 - Basaran/Batbrain Badnik
obBas_SonicPosY:		equ objoff_36		; 2 bytes | Sonic's Y-axis position
; ---------------------------------------------------------------------------

; Obj56 - Floating Blocks (SYZ/SLZ), Large Doors (LZ)
obFBlock_StartY:		equ objoff_30		; 2 bytes | starting Y-axis position
obFBlock_StartX:		equ objoff_34		; 2 bytes | starting X-axis position
obFBlock_MoveFlag:		equ objoff_38		; 1 byte  | 1 = block/door is moving
obFBlock_MoveDist:		equ objoff_3A		; 2 bytes | distance to move
obFBlock_ButtonNum:		equ objoff_3C		; 1 byte  | which button the block is linked to
; ---------------------------------------------------------------------------

; Obj57 - Spiked Balls (SYZ, LZ)
obSBall_ObjCount:		equ objoff_29		; 1 byte  | number of child objects
obSBall_ChildObjs:		equ objoff_2A		; 14 bytes| object RAM indices of child objects and parent
; ^^^ S1Fixed has this documented as 8 bytes. hivebrain has it documented as 14. I need to double check this.
; If this is indeed 14 bytes, then this could conflict with the Angle OST below.
; COULD this be one of the things that is corrupting Ring Sprites?

obSBall_Angle:			equ objoff_36		; 2 bytes | precise rotation angle
	; ^^^ We need this so that obShieldProp isn't overwritten, otherwise
	; Insta-Shield negates its collision property. Upper byte written to obAngle.

obSBall_CenterY:		equ objoff_38		; 2 bytes | center Y-axis position
obSBall_CenterX:		equ objoff_3A		; 2 bytes | center X-axis position
obSBall_Radius:			equ objoff_3C		; 1 byte  | radius
obSBall_Speed:			equ objoff_3E		; 2 bytes | rate of spin
; ---------------------------------------------------------------------------

; Obj58 - SYZ Giant Spiked Ball
obBBall_StartY:			equ objoff_38		; 2 bytes | starting Y-axis position
obBBall_StartX:			equ objoff_3A		; 2 bytes | starting X-axis position
obBBall_Radius:			equ objoff_3C		; 1 byte  | radius of circular movement
obBBall_Speed:			equ objoff_3E		; 2 bytes | speed
; ---------------------------------------------------------------------------

; Obj59 - SLZ Elevator
obElev_StartY:			equ objoff_30		; 2 bytes | starting Y-axis position
obElev_StartX:			equ objoff_32		; 2 bytes | starting X-axis position
obElev_DistMoved:		equ objoff_34		; 4 bytes | distance moved
obElev_AccelRate:		equ objoff_38		; 2 bytes | acceleration - i.e. its movement is not linear
obElev_DecelFlag:		equ objoff_3A		; 1 byte  | 1 = decelerate
obElev_Dist:			equ objoff_3C		; 2 bytes | half distance to move
obElev_DistCopy:		equ objoff_3E		; 2 bytes | master copy of obElev_Dist
; ---------------------------------------------------------------------------

; Obj5A - SLZ Circular Platform
obCirc_StartY:			equ objoff_30		; 2 bytes | starting Y-axis position
obCirc_StartX:			equ objoff_32		; 2 bytes | starting X-axis position
; ---------------------------------------------------------------------------

; Obj5B - SLZ Staircase
obStair_StartX:			equ objoff_30		; 2 bytes | starting X-axis position
obStair_StartY:			equ objoff_32		; 2 bytes | starting Y-axis position
obStair_WaitTime:		equ objoff_34		; 2 bytes | time delay for stairs to move
obStair_Flag:			equ objoff_36		; 1 byte  | 1 = stood on; $80+ = hit from below
obStair_ChildID:		equ objoff_37		; 1 byte  | which child the current object is; $38-$3B
obStair_YDistList:		equ objoff_38		; 4 bytes | distance moved by each child object
obStair_Parent:			equ objoff_3E		; 2 bytes | address of parent object
; ---------------------------------------------------------------------------

; Obj5D - SLZ Fan
obFan_Time:				equ objoff_30		; 2 bytes | time between switching on/off
obFan_Switch:			equ objoff_32		; 1 byte  | on/off switch
; ---------------------------------------------------------------------------

; Obj5E - SLZ Seesaw
obSeesaw_StartX:		equ objoff_30		; 2 bytes | starting X-axis position
obSeesaw_StartY:		equ objoff_34		; 2 bytes | starting Y-axis position
obSeesaw_Impact:		equ objoff_38		; 2 bytes | speed Sonic hits the seesaw
obSeesaw_State:			equ objoff_3A		; 1 byte  | seesaw: 0 = left raised; 2 = right raised; 1 = flat
										; spikeball: 0 = on/launched from right side; 2 = on/launched from left side
obSeesaw_Parent:		equ objoff_3E		; 2 bytes | address of parent object
; ---------------------------------------------------------------------------

; Obj5F - Bomb Badnik
obBomb_FuseTime:		equ objoff_30		; 2 bytes | time of fuse
obBomb_StartY:			equ objoff_34		; 2 bytes | original y-axis position
obBomb_Parent:			equ objoff_3E		; 2 bytes | address of parent object (unused?)
; ---------------------------------------------------------------------------

; Obj60 - Orbinaut Badnik

	if SLZOrbinautBehaviourMod	; Mercury SLZ Orbinaut Behaviour Mod
obOrb_OrbDist:			equ objoff_2A		; 1 byte  | distance of child orbs
	endif

obOrb_direction:		equ objoff_36		; 1 byte  | direction orbs rotate: 1 = clockwise; -1 = anticlockwise
obOrb_ObjCount:			equ objoff_37		; 1 byte  | number of child objects
obOrb_ChildObjs:		equ objoff_38		; 4 bytes | object RAM indices of child objects (4 bytes - 1 byte per ball)
obOrb_Parent:			equ objoff_3E		; 2 bytes | address of parent object
; ---------------------------------------------------------------------------

; Obj61 - LZ Blocks
obLBlock_StartY:		equ objoff_30		; 2 bytes | starting Y-axis position
obLBlock_StartX:		equ objoff_34		; 2 bytes | starting X-axis position
obLBlock_WaitTime:		equ objoff_36		; 2 bytes | time delay for block movement
obLBlock_Flag:			equ objoff_38		; 1 byte  | 1 = untouched; 0 = touched
obLBlock_SinkPixels:	equ objoff_3E		; 1 byte  | pixels the platform has sunk when stood on
obLBlock_ColFlag:		equ objoff_3F		; 1 byte  | 0 = none; 1 = side collision; -1 = top/bottom collision
; ---------------------------------------------------------------------------

; Obj63 - LZ Conveyor Platforms
LCon_SpawnType:			equ objoff_2F		; 1 byte  | saved subtype
LCon_StartX:			equ objoff_30		; 2 bytes | starting X-axis position
LCon_TargetX:			equ objoff_34		; 2 bytes | target X-axis position to move platform towards
LCon_TargetY:			equ objoff_36		; 2 bytes | target Y-axis position to move platform towards
LCon_PosNext:			equ objoff_38		; 1 byte  | index of next corner position
LCon_PosCount:			equ objoff_39		; 1 byte  | total number of corners +1, times 4
LCon_PosInc:			equ objoff_3A		; 1 byte  | amount to add to corner index (4 or -4)
LCon_Reverse:			equ objoff_3B		; 1 byte  | 1 = conveyors run in reverse
LCon_PosPtr:			equ objoff_3C		; 4 bytes | address where platform's position data is located
; ---------------------------------------------------------------------------

; Obj64 - LZ Bubbles
obBubble_Inhalable		equ objoff_2E		; 2 bytes | flag set when bubble is collectable
obBubble_StartX:		equ objoff_30		; 2 bytes | starting X-axis position
obBubble_WaitTime:		equ objoff_32		; 1 byte  | time until next bubble spawn
obBubble_WaitMaster:	equ objoff_33		; 1 byte  | time between bubble spawns
obBubble_MiniCount:		equ objoff_34		; 1 byte  | number of smaller bubbles to spawn
obBubble_Flag:			equ objoff_36		; 2 bytes | 1 = bubbles currently spawning; +$4000 = large bubble spawned; +$8000 = allow large bubble
obBubble_RandomTime:	equ objoff_38		; 2 bytes | randomised time between mini bubble spawns
obBubble_TypeList:		equ objoff_3C		; 4 bytes | address of bubble type list
; ---------------------------------------------------------------------------

; Obj66 - SBZ Rotating Junction
obJun_GrabFrame:		equ objoff_32		; 1 byte  | which frame the junction grabbed Sonic on
obJun_Direction:		equ objoff_34		; 1 byte  | direction of rotation: 1 or -1 (added to the frame number)
obJun_ButtonFlag:		equ objoff_36		; 1 byte  | flag set when button is pressed
obJun_ButtonNum:		equ objoff_38		; 1 byte  | which button will reverse the disc
; ---------------------------------------------------------------------------

; Obj67 - SBZ Running Disc
obDisc_StartY:			equ objoff_30		; 2 bytes | starting Y-axis position
obDisc_StartX:			equ objoff_32		; 2 bytes | starting X-axis position
obDisc_RadiusInner:		equ objoff_34		; 1 byte  | distance of small circle from centre
obDisc_Rotation:		equ objoff_36		; 2 bytes | rate/direction of small circle rotation
obDisc_RadiusOuter:		equ objoff_38		; 1 byte  | distance of Sonic from centre
obDisc_SonicAttached:	equ objoff_3A		; 1 byte  | flag set when Sonic lands on the disc
; ---------------------------------------------------------------------------

; Obj68 - SBZ Conveyor Belt
obConv_Speed:			equ objoff_36		; 2 bytes | speed - can also be negative
obConv_Width:			equ objoff_38		; 1 byte  | width/2
; ---------------------------------------------------------------------------

; Obj69 - SBZ Spinning Conveyor Platform
obSpin_WaitTime:		equ objoff_30		; 2 bytes | time until change
obSpin_WaitMaster:		equ objoff_32		; 2 bytes | time between changes
obSpin_SpinFlag:		equ objoff_34		; 1 byte  | 1 = switch between animations, spinning platforms only
obSpin_TimeSync:		equ objoff_36		; 2 bytes | bitmask used to synchronise timing: subtype $8x = $3F; subtype $9x = $7F
; ---------------------------------------------------------------------------

; Obj6A - SBZ Saws
obSaw_StartY:			equ objoff_38		; 2 bytes | starting Y-axis position
obSaw_StartX:			equ objoff_3A		; 2 bytes | starting X-axis position
obSaw_GroundFlag:		equ objoff_3D		; 1 byte  | flag set when the ground saw appears
; ---------------------------------------------------------------------------

; Obj6B - SBZ Stompers and Sliding Door
obStomp_StartY:			equ objoff_30		; 2 bytes | starting Y-axis position
obStomp_StartX:			equ objoff_34		; 2 bytes | starting X-axis position
obStomp_WaitTime:		equ objoff_36		; 2 bytes | time until next action
obStomp_ButtonFlag:		equ objoff_38		; 1 byte  | flag set when associated button is pressed
obStomp_DistMoved:		equ objoff_3A		; 2 bytes | distance moved
obStomp_DistToMove:		equ objoff_3C		; 2 bytes | distance to move
obStomp_ButtonNum:		equ objoff_3E		; 1 byte  | button number associated with door
; ---------------------------------------------------------------------------

; Obj6C - SBZ Vanishing Platform
obVanPtfm_WaitTime:		equ objoff_30		; 2 bytes | time until change
obVanPtfm_WaitMaster:	equ objoff_32		; 2 bytes | time between changes
obVanPtfm_SyncDec:		equ objoff_36		; 2 bytes | value to subtract from framecount for synchronising
obVanPtfm_SyncBitMask:	equ objoff_38		; 2 bytes | bitmask for synchronising
; ---------------------------------------------------------------------------

; Obj6D - SBZ Flamethrower
obFlame_WaitTime:		equ objoff_30		; 2 bytes | time until current action is complete
obFlame_OnTime:			equ objoff_32		; 2 bytes | time flame is on
obFlame_OffTime:		equ objoff_34		; 2 bytes | time flame is off
obFlame_LastFrame:		equ objoff_36		; 1 byte  | last frame of animation
; ---------------------------------------------------------------------------

; Obj6E - SBZ Electric Orb
obElecOrb_ZapRate:		equ objoff_34		; 2 bytes | zap rate - applies bitmask to frame counter
; ---------------------------------------------------------------------------

; Obj6F - SBZ Spinning Conveyor Platform (Nearly identical to Obj63)
SpinCon_SpawnType:		equ objoff_2F		; 1 byte  | saved subtype
SpinCon_CenterX:		equ objoff_30		; 2 bytes | approximate X-axis position of center of conveyor
SpinCon_TargetX:		equ objoff_34		; 2 bytes | target X-axis position to move platform towards
SpinCon_TargetY:		equ objoff_36		; 2 bytes | target Y-axis position to move platform towards
SpinCon_PosNext:		equ objoff_38		; 1 byte  | index of next corner position
SpinCon_PosCount:		equ objoff_39		; 1 byte  | total number of corners +1, times 4
SpinCon_PosInc:			equ objoff_3A		; 1 byte  | amount to add to corner index (4 or -4)
SpinCon_Reverse:		equ objoff_3B		; 1 byte  | 1 = conveyors run in reverse
SpinCon_PosPtr:			equ objoff_3C		; 4 bytes | address where platform's position data is located
; ---------------------------------------------------------------------------

; Obj70 - SBZ Girder Block
obGird_StartY:			equ objoff_30		; 2 bytes | starting Y-axis position
obGird_StartX:			equ objoff_32		; 2 bytes | starting X-axis position
obGird_MoveTime:		equ objoff_34		; 2 bytes | duration for movement in a direction
obGird_MoveSetting:		equ objoff_38		; 1 byte  | which movement settings to use (0/8/16/24)
obGird_MoveDelay:		equ objoff_3A		; 2 bytes | delay for movement
; ---------------------------------------------------------------------------

; Obj72 - SBZ Teleporter
obTele_MoveTime:		equ objoff_2E		; 2 bytes | travel time between each bend (2 bytes; only high byte is read)
obTele_DelayTime:		equ objoff_32		; 1 byte  | time to wait before starting teleportation
obTele_TargetX:			equ objoff_36		; 2 bytes | target X-axis position to send Sonic to
obTele_TargetY:			equ objoff_38		; 2 bytes | target Y-axis position to send Sonic to
obTele_PassedCoords:	equ objoff_3A		; 1 byte  | coords Sonic's already passed through, increments by 4
obTele_TotalCoords:		equ objoff_3B		; 1 byte  | total number of coord pairs in this set (in bytes)
obTele_CoordPtr:		equ objoff_3C		; 4 bytes | address of coord pairs data
; ---------------------------------------------------------------------------

; Obj78 - Caterkiller Badnik
obCat_Intertia:			equ obVelY			; 2 bytes | formerly obInertia. Needed to change after shifting SSTs for the Priority Manager.
										; Caterkiller uses obXVel but doesn't use obYVel (unless broken), and this causes no glitches.

obCat_WaitTime:			equ objoff_2A		; 1 byte  | time to wait between actions
obCat_Mode:				equ objoff_2B		; 1 byte  | bit 4 (+$10) = mouth is open/segment moving up; bit 7 (+$80) = update animation
obCat_FloorMap:			equ objoff_2C		; 16 bytes| height map of floor beneath caterkiller (16 bytes)
obCat_Parent:			equ objoff_3C		; 4 bytes | address of OST of parent object (4 bytes - high byte is obCat_segment_pos)
obCat_SegmentPos:		equ obCat_Parent	; 1 byte  | segment position - starts as 0/4/8/$A, increments as it moves
; ---------------------------------------------------------------------------

; Obj79 - Lamppost
obLamp_StartX:			equ objoff_30		; 2 bytes | starting X-axis position
obLamp_StartY:			equ objoff_32		; 2 bytes | starting Y-axis position
obLamp_SpinTime:		equ objoff_36		; 2 bytes | length of time to twirl the lamp
; ---------------------------------------------------------------------------

; Obj7D - Hidden Bonus Flags
obBonus_WaitTime:		equ objoff_30		; 2 bytes | length of time to display bonus sprites
; ---------------------------------------------------------------------------

; Obj7E - Special Stage Results Card
obSSR_MainX:			equ objoff_30		; 2 bytes | position for card to display on
; ---------------------------------------------------------------------------

; Obj87 - Ending Sequence Sonic
obESonic_WaitTime:		equ objoff_30		; 1 byte  | time to wait between events
; ---------------------------------------------------------------------------

; Obj88 - Ending Sequence Emeralds
obEChaos_StartX:		equ objoff_38		; 2 bytes | x-axis centre of emerald circle
obEChaos_StartY:		equ objoff_3A		; 2 bytes | y-axis centre of emerald circle
obEChaos_Radius:		equ objoff_3C		; 2 bytes | radius
obEChaos_Angle:			equ objoff_3E		; 2 bytes | angle for rotation
; ---------------------------------------------------------------------------

; Obj89 - Ending Sequence Sonic
obESTH_WaitTime:		equ objoff_30		; 2 bytes | time to wait between events
; ---------------------------------------------------------------------------

; Obj8B - Try Again/End Eggman
obEndEgg_WaitTime:		equ objoff_30		; 2 bytes | time to wait between events
; ---------------------------------------------------------------------------

; Obj8C - Try Again Emeralds
obECTry_StartX:			equ objoff_38		; 2 bytes | x-axis centre of emerald circle
obECTry_StartY:			equ objoff_3A		; 2 bytes | y-axis centre of emerald circle
obECTry_Radius:			equ objoff_3C		; 1 byte  | radius
obECTry_Speed:			equ objoff_3E		; 2 bytes | speed at which emeralds rotate around central point
; ---------------------------------------------------------------------------
; ---------------------------------------------------------------------------

; Boss variables (Any unique variables are found within the object file itself)
obBoss_3rdRout:			equ obSubtype		; 1 byte  | bosses may use this OST as a tertiary routine counter
obBoss_BufferX:			equ objoff_30		; 2 bytes | stored X-axis position
obBoss_Parent:			equ objoff_34		; 2 bytes | parent address (Used by face, flame, and weapon)
obBoss_BufferY:			equ objoff_38		; 2 bytes | stored Y-axis position
obBoss_DelayTime:		equ objoff_3C		; 2 bytes | delay timer
obBoss_FlashTime:		equ objoff_3E		; 1 byte  | # of frames to flash white when hit
obBoss_HoverAngle:		equ objoff_3F		; 1 byte  | Used w/ CalcSine for the ship's hover effect
; ---------------------------------------------------------------------------

; Marble Zone Boss
obMZBoss_FireBallTimer:	equ objoff_34		; 1 byte  | delay timer for random fireball spawning

; ---------------------------------------------------------------------------
; Miscellaneous object scratch-RAM
; ---------------------------------------------------------------------------

objoff_25:	equ $25
objoff_26:	equ $26
objoff_27:	equ $27	; unused
objoff_28:	equ $28	; unused
objoff_29:	equ $29
objoff_2A:	equ $2A
objoff_2B:	equ $2B
objoff_2C:	equ $2C
objoff_2E:	equ $2E
objoff_2F:	equ $2F
objoff_30:	equ $30
objoff_31:	equ $31	; unused
objoff_32:	equ $32
objoff_33:	equ $33
objoff_34:	equ $34
objoff_35:	equ $35
objoff_36:	equ $36
objoff_37:	equ $37
objoff_38:	equ $38
objoff_39:	equ $39
objoff_3A:	equ $3A
objoff_3B:	equ $3B
objoff_3C:	equ $3C
objoff_3D:	equ $3D
objoff_3E:	equ $3E
objoff_3F:	equ $3F

object_size_bits:		equ 6
object_size:			equ 1<<object_size_bits

; Devon Subsprite OSTs -- Subsprite properties set DO override some standard object SSTs.
; What is overridden really depends on the amount of sub sprites you have set to display.
mainspr_routine:		equ $A	; added by RetroKoH
mainspr_mapframe:		equ $B	; last byte of obX (2nd byte of obScreenY)
mainspr_width:			equ $E
mainspr_childsprites:	equ $F	; amount of child sprites
mainspr_height:			equ $14
subspr_data:			equ $10
sub2_x_pos:				equ $10	; x_vel
sub2_y_pos:				equ $12	; y_vel
sub2_mapframe:			equ $15
sub3_x_pos:				equ $16	; y_radius
sub3_y_pos:				equ $18 ; priority
sub3_mapframe:			equ $1B ; anim_frame
sub4_x_pos:				equ $1C ; anim
sub4_y_pos:				equ $1E ; anim_frame_duration
sub4_mapframe:			equ $21 ; collision_property
sub5_x_pos:				equ $22 ; status
sub5_y_pos:				equ $24 ; routine
sub5_mapframe:			equ $27
sub6_x_pos:				equ $28 ; subtype
sub6_y_pos:				equ $2A
sub6_mapframe:			equ $2D
sub7_x_pos:				equ $2E
sub7_y_pos:				equ $30
sub7_mapframe:			equ $33
sub8_x_pos:				equ $34
sub8_y_pos:				equ $36
sub8_mapframe:			equ $39
sub9_x_pos:				equ $3A
sub9_y_pos:				equ $3C
sub9_mapframe:			equ $3F
next_subspr:			equ $6
