; ---------------------------------------------------------------------------
; Flamewing Z80 Driver (Flamedriver)
; See https://github.com/flamewing/flamedriver
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

SndDrvInit:
		SMPS_stopZ80a						; stop the Z80
		SMPS_resetZ80						; release Z80 reset

		; load SMPS sound driver
		lea	(z80_SoundDriver).l,a0
		lea	(z80_ram).l,a1
		bsr.w	KosDec

		; load default variables
		moveq	#0,d1
		lea	(z80_ram+z80_stack).l,a1
		moveq	#bytesToXcnt(zTracksStart-z80_stack,8),d0

.copy
		movep.l	d1,0(a1)
		movep.l	d1,1(a1)
		addq.w	#4*2,a1						; next bytes
		dbf	d0,.copy

		; detect PAL region consoles
		btst	#6,(v_megadrive).w
		beq.s	.notpal						; branch if it's not a PAL system
		move.b	#1,(z80_ram+zPalFlag).l

.notpal
		SMPS_resetZ80a						; reset Z80
		nop									; wait 16 cycles
		nop
		nop
		nop
		SMPS_resetZ80						; release reset
		SMPS_startZ80
		rts

; ---------------------------------------------------------------------------
; Always replaces an index previous passed to this function
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Play_Music:
		SMPS_stopZ80
		move.b	d0,(z80_ram+zMusicNumber).l
		SMPS_startZ80
		rts

; ---------------------------------------------------------------------------
; Can handle up to two different indexes in one frame
; ---------------------------------------------------------------------------

; =============== S U B R O U T I N E =======================================

Play_SFX:
		SMPS_stopZ80
		cmp.b	(z80_ram+zSFXNumber0).l,d0
		beq.s	.exit
		tst.b	(z80_ram+zSFXNumber0).l
		bne.s	.next
		move.b	d0,(z80_ram+zSFXNumber0).l
		SMPS_startZ80
		rts

.next
		move.b	d0,(z80_ram+zSFXNumber1).l

.exit
		SMPS_startZ80
		rts

; =============== S U B R O U T I N E =======================================

Change_Music_Tempo:
		SMPS_stopZ80
		move.b	d0,(z80_ram+zTempoSpeedup).l
		SMPS_startZ80
		rts

; =============== S U B R O U T I N E =======================================

Play_Sample:
		SMPS_stopZ80
		move.b  d0,(z80_ram+zDACIndex).l
		SMPS_startZ80
		rts
