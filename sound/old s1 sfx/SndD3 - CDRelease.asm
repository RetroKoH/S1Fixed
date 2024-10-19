FM_No01_Header:
	smpsHeaderStartSong 1
	smpsHeaderVoice     FM_No01_Voices
	smpsHeaderTempoSFX  $01
	smpsHeaderChanSFX   $02

	smpsHeaderSFXChannel cFM4, FM_No01_FM4,	$00, $0A
	smpsHeaderSFXChannel cFM5, FM_No01_FM5,	$00, $00

; FM4 Data
FM_No01_FM4:
	smpsSetvoice        $00
	smpsModSet          $01, $01, $20, $08
	dc.b	nRst, $0A

FM_No01_Loop01:
	dc.b	nG0, $0F
	smpsLoop            $00, $03, FM_No01_Loop01

FM_No01_Loop02:
	dc.b	nG0, $0A
	smpsAlterVol        $05
	smpsLoop            $00, $06, FM_No01_Loop02
	smpsStop

; FM5 Data
FM_No01_FM5:
	smpsSetvoice        $01
	smpsModSet          $01, $01, $C5, $1A
	dc.b	nE6, $07
	smpsAlterPitch      $0C
	smpsAlterVol        $09
	smpsSetvoice        $02
	smpsModSet          $03, $01, $09, $FF
	dc.b	nCs6, $25
	smpsModOn

FM_No01_Loop00:
	dc.b	smpsNoAttack
	smpsAlterVol        $01
	dc.b	nD6, $02
	smpsLoop            $00, $2A, FM_No01_Loop00
	smpsStop

FM_No01_Voices:
;	Voice $00
;	$FA
;	$21, $30, $10, $32, 	$1F, $1F, $1F, $1F, 	$05, $18, $09, $02
;	$06, $0F, $06, $02, 	$1F, $2F, $4F, $2F, 	$0F, $1A, $0E, $80
	smpsVcAlgorithm     $02
	smpsVcFeedback      $07
	smpsVcUnusedBits    $03
	smpsVcDetune        $03, $01, $03, $02
	smpsVcCoarseFreq    $02, $00, $00, $01
	smpsVcRateScale     $00, $00, $00, $00
	smpsVcAttackRate    $1F, $1F, $1F, $1F
	smpsVcAmpMod        $00, $00, $00, $00
	smpsVcDecayRate1    $02, $09, $18, $05
	smpsVcDecayRate2    $02, $06, $0F, $06
	smpsVcDecayLevel    $02, $04, $02, $01
	smpsVcReleaseRate   $0F, $0F, $0F, $0F
	smpsVcTotalLevel    $00, $0E, $1A, $0F

;	Voice $01
;	$FD
;	$09, $03, $00, $00, 	$1F, $1F, $1F, $1F, 	$10, $0C, $0C, $0C
;	$0B, $1F, $10, $05, 	$1F, $2F, $4F, $2F, 	$09, $80, $8E, $88
	smpsVcAlgorithm     $05
	smpsVcFeedback      $07
	smpsVcUnusedBits    $03
	smpsVcDetune        $00, $00, $00, $00
	smpsVcCoarseFreq    $00, $00, $03, $09
	smpsVcRateScale     $00, $00, $00, $00
	smpsVcAttackRate    $1F, $1F, $1F, $1F
	smpsVcAmpMod        $00, $00, $00, $00
	smpsVcDecayRate1    $0C, $0C, $0C, $10
	smpsVcDecayRate2    $05, $10, $1F, $0B
	smpsVcDecayLevel    $02, $04, $02, $01
	smpsVcReleaseRate   $0F, $0F, $0F, $0F
	smpsVcTotalLevel    $08, $0E, $00, $09

;	Voice $02
;	$3C
;	$00, $44, $02, $02, 	$1F, $1F, $1F, $15, 	$00, $1F, $00, $00
;	$00, $00, $00, $00, 	$0F, $0F, $0F, $0F, 	$0D, $80, $28, $80
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

