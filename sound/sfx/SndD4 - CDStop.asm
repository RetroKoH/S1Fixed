CD_Stop_Header:
	smpsHeaderStartSong 1
	smpsHeaderVoice     CD_Stop_Voices
	smpsHeaderTempoSFX  $01
	smpsHeaderChanSFX   $01

	smpsHeaderSFXChannel cFM5, CD_Stop_FM5,	$00, $00

; FM5 Data
CD_Stop_FM5:
	smpsStop

; Song seems to not use any FM voices
CD_Stop_Voices:
