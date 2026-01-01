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

sfx_Jump				ds.b 1		; $01
sfx_Lamppost			ds.b 1		; $02
sfx_A2					ds.b 1		; $03
sfx_Death				ds.b 1		; $04
sfx_Skid				ds.b 1		; $05
sfx_A5					ds.b 1		; $06
sfx_HitSpikes			ds.b 1		; $07
sfx_Push				ds.b 1		; $08
sfx_SSGoal				ds.b 1		; $09
sfx_SSItem				ds.b 1		; $0A
sfx_Splash				ds.b 1		; $0B
sfx_AB					ds.b 1		; $0C
sfx_HitBoss				ds.b 1		; $0D
sfx_Bubble				ds.b 1		; $0E
sfx_Fireball			ds.b 1		; $0F
sfx_Shield				ds.b 1		; $10
sfx_Saw					ds.b 1		; $11
sfx_Electric			ds.b 1		; $12
sfx_Drown				ds.b 1		; $13
sfx_Flamethrower		ds.b 1		; $14
sfx_Bumper				ds.b 1		; $15
sfx_Ring				ds.b 1		; $16 (panning right)
sfx_SpikesMove			ds.b 1		; $17
sfx_Rumbling			ds.b 1		; $18
sfx_B8					ds.b 1		; $19
sfx_Collapse			ds.b 1		; $1A
sfx_SSGlass				ds.b 1		; $1B
sfx_Door				ds.b 1		; $1C
sfx_Teleport			ds.b 1		; $1D sfx_Dash
sfx_ChainStomp			ds.b 1		; $1E
sfx_Roll				ds.b 1		; $1F
sfx_Continue			ds.b 1		; $20
sfx_Basaran				ds.b 1		; $21
sfx_BreakItem			ds.b 1		; $22 sfx_Break
sfx_Warning				ds.b 1		; $23
sfx_GiantRing			ds.b 1		; $24
sfx_Bomb				ds.b 1		; $25 Explode
sfx_Cash				ds.b 1		; $26
sfx_RingLoss			ds.b 1		; $27
sfx_ChainRise			ds.b 1		; $28
sfx_Burning				ds.b 1		; $29
sfx_Bonus				ds.b 1		; $2A (Hidden Bonuses)
sfx_EnterSS				ds.b 1		; $2B
sfx_WallSmash			ds.b 1		; $2C for now, use sfx_Collapse (Temporary Fix)
sfx_Spring				ds.b 1		; $2D
sfx_Switch				ds.b 1		; $2E
sfx_RingLeft			ds.b 1		; $2F
sfx_Signpost			ds.b 1		; $30
sfx_SpinDash			ds.b 1		; $31
sfx_Charge				ds.b 1		; Placeholder- Peelout sfx
sfx_Release				ds.b 1		; Placeholder- Peelout sfx
sfx_Stop				ds.b 1		; Placeholder- Peelout sfx
sfx_InstaAtk			ds.b 1		; $0B
sfx_FShield				ds.b 1		; $0C sfx_FireShield
sfx_BShield				ds.b 1		; $0D sfx_BubbleShield
sfx_LShield				ds.b 1		; $0E sfx_LightningShield
sfx_FShieldAtk			ds.b 1		; $0F sfx_FireAttack
sfx_BShieldAtk			ds.b 1		; $10 sfx_BubbleAttack
sfx_LShieldAtk			ds.b 1		; $11 sfx_ElectricAttack
sfx_DropDash			ds.b 1		; Placeholder- Dropdash sfx
sfx_Perfect				ds.b 1		; $37 (Might use for Perfect Bonus mod)

sfx_RingRight = sfx_Ring

; Continuous
sfx__FirstContinuous =	*			; ID of the first continuous sound effect
sfx_Waterfall			ds.b 1		; $01

sfx__End =				*			; next ID after the last sound effect

	dephase
	!org 0							; make sure we reset the ROM position to 0
