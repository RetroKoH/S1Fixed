DropDash_Header:
	smpsHeaderStartSong 2
	smpsHeaderVoice     DropDash_Voices
	smpsHeaderTempoSFX  $01
	smpsHeaderChanSFX   $01

	smpsHeaderSFXChannel cFM5, DropDash_FM5,	$0C, $03

; FM5 Data
DropDash_FM5:
	smpsSetvoice        $00
	dc.b	nRst, $01
	smpsModSet          $03, $01, $10, $FF
	dc.b	nCs6, $20
	smpsModOff

DropDash_Loop00:
	dc.b	smpsNoAttack
	smpsAlterVol        $02
	dc.b	nA6, $02
	smpsLoop            $00, $15, DropDash_Loop00
	smpsStop

DropDash_Voices:
;	Voice $00
;	$3C
;	$00, $44, $02, $02, 	$0C, $0C, $0C, $0C, 	$00, $1F, $00, $00
;	$00, $00, $00, $00, 	$0F, $0F, $0F, $0F, 	$0D, $00, $28, $00
	smpsVcAlgorithm     $04
	smpsVcFeedback      $07
	smpsVcUnusedBits    $00
	smpsVcDetune        $00, $00, $04, $00
	smpsVcCoarseFreq    $02, $02, $04, $00
	smpsVcRateScale     $00, $00, $00, $00
	smpsVcAttackRate    $0C, $0C, $0C, $0C
	smpsVcAmpMod        $00, $00, $00, $00
	smpsVcDecayRate1    $00, $00, $1F, $00
	smpsVcDecayRate2    $00, $00, $00, $00
	smpsVcDecayLevel    $00, $00, $00, $00
	smpsVcReleaseRate   $0F, $0F, $0F, $0F
	smpsVcTotalLevel    $00, $28, $00, $0D

