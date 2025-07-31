; ---------------------------------------------------------------------------
; Sound commands list
; ---------------------------------------------------------------------------

	phase $E1
bgm__FirstCmd =			*			; ID of the first sound command
bgm_Fade =				*			; $E1 - fade out music
bgm_FadeOut				ds.b 1		; $E1 - fade out music
bgm_Stop				ds.b 1		; $E2 - stop music and sound effects
bgm_MutePSG				ds.b 1		; $E3 - mute all PSG channels
bgm_StopSFX				ds.b 1		; $E4 - stop all sound effects
bgm_FadeOut2			ds.b 1		; $E5 - fade out music (duplicate)
bgm__EndCmd =			*			; next ID after last sound command

bgm_FA =				$FA			; $FA - ???
bgm_StopSEGA =			$FE			; $FE - Stop SEGA sound
bgm_SEGA =				$FF			; $FF - Play SEGA sound

	dephase

; ---------------------------------------------------------------------------
; Music ID's list. These do not affect the sound driver, be careful
; ---------------------------------------------------------------------------

	phase $01
bgm__First =				*		; ID of the first music

; Levels
	if DynamicBGMs
; -----------------------------------------------------------------------
bgm_GHZ1				ds.b 1		; $01
bgm_GHZ2				ds.b 1		; $02
bgm_GHZ3				ds.b 1		; $03
bgm_MZ1					ds.b 1		; $04
bgm_MZ2					ds.b 1		; $05
bgm_MZ3					ds.b 1		; $06
bgm_SYZ1				ds.b 1		; $07
bgm_SYZ2				ds.b 1		; $08
bgm_SYZ3				ds.b 1		; $09
bgm_LZ1					ds.b 1		; $0A
bgm_LZ2					ds.b 1		; $0B
bgm_LZ3					ds.b 1		; $0C
bgm_SLZ1				ds.b 1		; $0D
bgm_SLZ2				ds.b 1		; $0E
bgm_SLZ3				ds.b 1		; $0F
bgm_SBZ1				ds.b 1		; $10
bgm_SBZ2				ds.b 1		; $11
bgm_SBZ3				ds.b 1		; $12
; -----------------------------------------------------------------------
	else
; -----------------------------------------------------------------------
bgm_GHZ					ds.b 1		; $01
bgm_MZ					ds.b 1		; $02
bgm_SYZ					ds.b 1		; $03
bgm_LZ					ds.b 1		; $04
bgm_SLZ					ds.b 1		; $05
bgm_SBZ					ds.b 1		; $06
; ------------------------------------------------------------------------
	endif

; Main
bgm_Invincible			ds.b 1		; $07/13
bgm_ExtraLife			ds.b 1		; $08/14
bgm_SpecialStage		ds.b 1		; $09/15
bgm_Title				ds.b 1		; $0A/16
bgm_Ending				ds.b 1		; $0B/17

; Bosses
bgm_Boss				ds.b 1		; $0C/18
bgm_FZ					ds.b 1		; $0D/19

; End
bgm_GotThrough			ds.b 1		; $0E/1A
bgm_GameOver			ds.b 1		; $0F/1B
bgm_Continue			ds.b 1		; $10/1C
bgm_Credits				ds.b 1		; $11/1D
bgm_Drowning			ds.b 1		; $12/1E
bgm_Emerald				ds.b 1		; $13/1F
bgm_Options				ds.b 1		; $14/20

bgm__End =				*			; next ID after last music

	dephase

; ---------------------------------------------------------------------------
; Sound effect ID's list. These do not affect the sound driver, be careful
; To-do: re-sort these to match the original S1Fixed SFX listing
; Nomenclature matches that of s1disasm (and the other branches)
; ---------------------------------------------------------------------------

	phase $01
sfx__First =				*		; ID of the first sound effect

sfx_Ring				ds.b 1		; $01 (panning right)
sfx_RingRight = sfx_Ring
sfx_RingLeft			ds.b 1		; $02
sfx_RingLoss			ds.b 1		; $03
sfx_Jump				ds.b 1		; $04
sfx_Roll				ds.b 1		; $05
sfx_Skid				ds.b 1		; $06
sfx_Death				ds.b 1		; $07
sfx_SpinDash			ds.b 1		; $08
sfx_Splash				ds.b 1		; $09
sfx_Shield				ds.b 1		; $0A Blue Shield
sfx_InstaAttack			ds.b 1		; $0B
sfx_FShield				ds.b 1		; $0C sfx_FireShield
sfx_BShield				ds.b 1		; $0D sfx_BubbleShield
sfx_LShield				ds.b 1		; $0E sfx_LightningShield
sfx_FShieldAtk			ds.b 1		; $0F sfx_FireAttack
sfx_BShieldAtk			ds.b 1		; $10 sfx_BubbleAttack
sfx_LShieldAtk			ds.b 1		; $11 sfx_ElectricAttack
sfx_HitSpikes			ds.b 1		; $12
sfx_SpikesMove			ds.b 1		; $13
sfx_Drown				ds.b 1		; $14
sfx_Lamppost			ds.b 1		; $15
sfx_Spring				ds.b 1		; $16
sfx_Teleport			ds.b 1		; $17 sfx_Dash
sfx_BreakItem			ds.b 1		; $18 sfx_Break
sfx_HitBoss				ds.b 1		; $19
sfx_Warning				ds.b 1		; $1A
sfx_Bubble				ds.b 1		; $1B
sfx_Bomb				ds.b 1		; $1C Explode
sfx_SignpostFloat		ds.b 1		; $1D S3K Signpost (Not used here)
sfx_Switch				ds.b 1		; $1E
sfx_Cash				ds.b 1		; $1F
sfx_Projectile			ds.b 1		; $20
sfx_WallSmash			ds.b 1		; $21 sfx_Collapse
sfx_Collapse			ds.b 1		; $22 sfx_BridgeCollapse
sfx_Bumper				ds.b 1		; $23
sfx_Fireball			ds.b 1		; $24
sfx_Basaran				ds.b 1		; $25
sfx_Burning				ds.b 1		; $26
sfx_BossMagma			ds.b 1		; $27
sfx_ChainRise			ds.b 1		; $28
sfx_ChainStomp			ds.b 1		; $29
sfx_Push				ds.b 1		; $2A ; Push Block
sfx_BossZoom			ds.b 1		; $2B (Not used here)
sfx_Grab				ds.b 1		; $2C (Goggles)
sfx_Flying				ds.b 1		; $2D (Extended)
sfx_FlyTired			ds.b 1		; $2E (Extended)
sfx_GlideLand			ds.b 1		; $2F (Extended)
sfx_GroundSlide			ds.b 1		; $30 (Extended)
sfx_Laser				ds.b 1		; $31 (Not used here)
sfx_Continue			ds.b 1		; $32
sfx_EnterSS				ds.b 1		; $33
sfx_SSGlass				ds.b 1		; $34
sfx_SSItem				ds.b 1		; $35
sfx_SSGoal				ds.b 1		; $36
sfx_Perfect				ds.b 1		; $37 (Might use for Perfect Bonus mod)
sfx_BossHitFloor		ds.b 1		; $38 (Not used here)
sfx_Rumbling			ds.b 1		; $39
sfx_Door				ds.b 1		; $3A
sfx_MissileThrow		ds.b 1		; $3B (Not used here)
sfx_BossProjectile		ds.b 1		; $3C (Not used here)
sfx_Electric			ds.b 1		; $3D
sfx_Harpoon				ds.b 1		; $3E
sfx_Flamethrower		ds.b 1		; $3F
sfx_Saw					ds.b 1		; $40
sfx_SuperEmerald		ds.b 1		; $41 (Not used here)
sfx_SuperTransform		ds.b 1		; $42 (Not used here)
sfx_MechaTransform		ds.b 1		; $43 (Not used here)
sfx_Signpost			ds.b 1		; $44
sfx_Bonus				ds.b 1		; $45 (Hidden Bonuses)
sfx_GiantRing			ds.b 1		; $46
; Peelout sfx
sfx_Charge = sfx_SpinDash
sfx_Release = sfx_Teleport
sfx_Stop = sfx_Switch
;
sfx_DropDash			ds.b 1		;

; Continuous
sfx__FirstContinuous =	*			; ID of the first continuous sound effect
sfx_Waterfall			ds.b 1		; $01

sfx__End =				*			; next ID after the last sound effect

	dephase
	!org 0							; make sure we reset the ROM position to 0
