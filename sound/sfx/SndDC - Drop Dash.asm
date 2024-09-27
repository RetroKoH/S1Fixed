SndXX_DropDash_Header:
	smpsHeaderStartSong 2, 1
	smpsHeaderVoice SndXX_DropDash_Voices
	smpsHeaderTempoSFX	$01
	smpsHeaderChanSFX 	$01
		
	smpsHeaderSFXChannel cFM5, SoundXX_FM5, $00, $05
		
; FM4 Data
SoundXX_FM5:
	smpsSetvoice $00
;	smpsAlterVol        $5
	smpsAlterNote       $D4
	dc.b	nBb5, $01, smpsNoAttack
	smpsAlterNote       $00
	dc.b	$01, smpsNoAttack, nB5, smpsNoAttack, nC6, smpsNoAttack, $01, smpsNoAttack, nCs6, smpsNoAttack
	smpsAlterNote       $1B
	dc.b	$01, smpsNoAttack
	smpsAlterNote       $00
	dc.b	nD6, smpsNoAttack, nEb6, smpsNoAttack
	smpsAlterNote       $1E
	dc.b	$01, smpsNoAttack
	smpsAlterNote       $00
	dc.b	nE6, smpsNoAttack, nF6, smpsNoAttack
	smpsAlterNote       $21
	dc.b	$01, smpsNoAttack
	smpsAlterNote       $00
	dc.b	nFs6, smpsNoAttack, nG6, smpsNoAttack
	smpsAlterNote       $25
	dc.b	$01, smpsNoAttack
	smpsAlterNote       $00
	dc.b	nAb6, smpsNoAttack, nA6, $07

Drop_Loop01:
	smpsAlterVol        $02

Drop_Loop00:
	dc.b	smpsNoAttack, $01
	smpsAlterVol        $01
	smpsLoop            $00, $03, Drop_Loop00
	dc.b	smpsNoAttack, nA6
	smpsLoop            $01, $0C, Drop_Loop01
	smpsAlterVol        $02

Drop_Loop02:
	dc.b	nRst
	smpsAlterVol        $01
	dc.b	smpsNoAttack
	smpsLoop            $00, $03, Drop_Loop02
	dc.b	nRst
	smpsAlterVol        $02
	dc.b	smpsNoAttack, nRst
	smpsAlterVol        $01
	dc.b	smpsNoAttack, nRst
	smpsStop
		
SndXX_DropDash_Voices:
;	Voice $00
;	$3C
;	$00, $44, $02, $02, 	$1F, $1F, $1F, $15, 	$00, $1F, $00, $00
;	$00, $00, $00, $00, 	$0F, $0F, $0F, $0F, 	$0D, $00, $28, $00
	smpsVcAlgorithm     $04
	smpsVcFeedback      $07
	smpsVcUnusedBits    $00
	smpsVcDetune        $00, $00, $04, $00
	smpsVcCoarseFreq    $02, $02, $04, $00
	smpsVcRateScale     $00, $00, $00, $00
	smpsVcAttackRate    $15, $1F, $1F, $1F
	smpsVcAmpMod        $00, $00, $00, $00
	smpsVcDecayRate1    $00, $00, $1F, $00
	smpsVcDecayRate2    $00, $00, $00, $00
	smpsVcDecayLevel    $00, $00, $00, $00
	smpsVcReleaseRate   $0F, $0F, $0F, $0F
	smpsVcTotalLevel    $00, $28, $00, $0D		