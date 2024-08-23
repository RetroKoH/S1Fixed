; RNG by Devon; Adapted to current mods by RetroKoH
MonitorRandomizer:

		jsr		(RandomNumber).w	; call for random number

	if ShieldsMode>1
	; Get random factor for elemental shield (1, 2, 3)
		move.l	d0,d1
		swap	d1
		andi.l	#$FFFF,d1	; Make sure division will always work
		divu.w	#3,d1		; Divide by adjusted maximum number > #(MAX_NUM-MIN_NUM)+1,d0 MAX = 3; MIN = 1.
		swap	d1
		; This time we won't add 1, giving us a range of 0-2
	endif

	; randomize monitor icon (Add further randomness modification here before continuing)
		andi.l	#$FFFF,d0	; Make sure division will always work
		divu.w	#6,d0		; Divide by adjusted maximum number > #(MAX_NUM-MIN_NUM)+1,d0 MAX = 6; MIN = 1.
		swap	d0			; Get remainder of division
		addi.w	#1,d0		; Add minimum number
	
	if ShieldsMode>1
		cmpi.b	#4,d0					; is this a shield?
		bne.s	.skipcheck				; if not, skip and exit
		
		if ShieldsMode=2
			btst	#sta2ndShield,(v_player+obStatus2nd).w	; does Sonic already have a shield?
			beq.s	.skipcheck								; if no, don't change it.
		endif
	
	; Set to elemental shield
		move.b	#7,d0					; set to flame shield
		add.b	d1,d0					; randomize elemental shields

.skipcheck:
	endif
		move.b	d0,obAnim(a0)		; get subtype