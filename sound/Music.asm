; ---------------------------------------------------------------------------
; Music metadata (pointers, speed shoes tempos, flags)
; ---------------------------------------------------------------------------
; byte_71A94: SpeedUpIndex:
MusicIndex:
ptr_mus01:	SMPS_MUSIC_METADATA	Music01, s1TempotoS3($07), 0	; GHZ
ptr_mus02:	SMPS_MUSIC_METADATA	Music02, s1TempotoS3($72), 0	; LZ
ptr_mus03:	SMPS_MUSIC_METADATA	Music03, s1TempotoS3($73), 0	; MZ
ptr_mus04:	SMPS_MUSIC_METADATA	Music04, s1TempotoS3($26), 0	; SLZ
ptr_mus05:	SMPS_MUSIC_METADATA	Music05, s1TempotoS3($15), 0	; SYZ
ptr_mus06:	SMPS_MUSIC_METADATA	Music06, s1TempotoS3($08), 0	; SBZ
ptr_mus07:	SMPS_MUSIC_METADATA	Music07, s1TempotoS3($FF), 0	; Invincible
ptr_mus08:	SMPS_MUSIC_METADATA	Music08, s1TempotoS3($05), 0	; Extra Life
ptr_mus09:	SMPS_MUSIC_METADATA	Music09, s1TempotoS3($08), 0	; Special Stage
ptr_mus0A:	SMPS_MUSIC_METADATA	Music0A, s1TempotoS3($05), 0	; Title Screen
ptr_mus0B:	SMPS_MUSIC_METADATA	Music0B, s1TempotoS3($05), SMPS_MUSIC_METADATA_FORCE_PAL_SPEED	; Ending
ptr_mus0C:	SMPS_MUSIC_METADATA	Music0C, s1TempotoS3($04)-$20, 0	; Boss
ptr_mus0D:	SMPS_MUSIC_METADATA	Music0D, s1TempotoS3($06)-$20, 0	; Final Zone
ptr_mus0E:	SMPS_MUSIC_METADATA	Music0E, s1TempotoS3($03), 0	; End of Act
ptr_mus0F:	SMPS_MUSIC_METADATA	Music0F, s1TempotoS3($13), 0	; Game Over
ptr_mus10:	SMPS_MUSIC_METADATA	Music10, s1TempotoS3($07), SMPS_MUSIC_METADATA_FORCE_PAL_SPEED	; Continue
ptr_mus11:	SMPS_MUSIC_METADATA	Music11, s1TempotoS3($33), SMPS_MUSIC_METADATA_FORCE_PAL_SPEED	; Credits
ptr_mus12:	SMPS_MUSIC_METADATA	Music12, s1TempotoS3($02), SMPS_MUSIC_METADATA_FORCE_PAL_SPEED	; Drowning
ptr_mus13:	SMPS_MUSIC_METADATA	Music13, s1TempotoS3($06), 0	; Emerald
ptr_musend

; ---------------------------------------------------------------------------
; Music data
; ---------------------------------------------------------------------------

Music01:		include "sound/music/Mus01 - GHZ.asm"
	even
Music02:		include "sound/music/Mus02 - LZ.asm"
	even
Music03:		include "sound/music/Mus03 - MZ.asm"
	even
Music04:		include "sound/music/Mus04 - SLZ.asm"
	even
Music05:		include "sound/music/Mus05 - SYZ.asm"
	even
Music06:		include "sound/music/Mus06 - SBZ.asm"
	even
Music07:		include "sound/music/Mus07 - Invincibility.asm"
	even
Music08:		include "sound/music/Mus08 - Extra Life.asm"
	even
Music09:		include "sound/music/Mus09 - Special Stage.asm"
	even
Music0A:		include "sound/music/Mus0A - Title Screen.asm"
	even
Music0B:		include "sound/music/Mus0B - Ending.asm"
	even
Music0C:		include "sound/music/Mus0C - Boss.asm"
	even
Music0D:		include "sound/music/Mus0D - FZ.asm"
	even
Music0E:		include "sound/music/Mus0E - Sonic Got Through.asm"
	even
Music0F:		include "sound/music/Mus0F - Game Over.asm"
	even
Music10:		include "sound/music/Mus10 - Continue Screen.asm"
	even
Music11:		include "sound/music/Mus11 - Credits.asm"
	even
Music12:		include "sound/music/Mus12 - Drowning.asm"
	even
Music13:		include "sound/music/Mus13 - Get Emerald.asm"
	even
