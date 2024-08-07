; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to collect the right speed setting for a character
; Originally by redhotsonic. Optimizations by MoDule.
;
; a0 must be character
; a1 will be the result and have the correct speed settings
; a2 is characters' speed
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

ApplySpeedSettings:
		moveq   #0,d0								; Quickly clear d0
		tst.b   obShoes(a0)							; Does character have speedshoes? -- RetroKoH Sonic SST Compaction
		beq.s   .noshoes							; If not, branch
		addq.b  #8,d0

.noshoes:
		btst    #staWater,obStatus(a0)				; Is the character underwater?
		beq.s   .nowater							; If not, branch
		addi.b  #$10,d0

.nowater:
	if SuperMod=1
		btst	#sta2ndSuper,obStatus2nd(a0)		; Is character Super?
		beq.s   .nosuper							; If not, branch
		addi.b  #$20,d0

.nosuper:
	endif
		lea		SpeedSettings(pc,d0.w),a1			; Load correct speed settings into a1
		addq.l  #2,a1                           	; Increment a1 by 2 quickly
		move.l  (a1)+,(a2)+                     	; Set character's new top speed and acceleration
		move.w  (a1),(a2)                       	; Set character's deceleration
		rts
; End of function ApplySpeedSettings

; ----------------------------------------------------------------------------
; Speed Settings Array - This array defines what speeds the character should be set to.
; Set one word value to roll deceleration to fix certain values?
; ----------------------------------------------------------------------------
;               blank   top_speed       acceleration    deceleration    ; #     ; Comment
SpeedSettings:
        dc.w	$0,     $600,           $C,             $80             ; $00   ; Normal
        dc.w	$0,     $C00,           $18,            $80             ; $08   ; Normal Speedshoes
        dc.w	$0,     $300,           $6,             $40             ; $10   ; Normal Underwater
        dc.w	$0,     $600,           $C,             $40             ; $18   ; Normal Underwater Speedshoes
	if SuperMod=1
        dc.w	$0,     $A00,           $30,            $100            ; $20   ; Super
        dc.w	$0,     $C00,           $30,            $100            ; $28   ; Super Speedshoes
        dc.w	$0,     $500,           $18,            $80             ; $30   ; Super Underwater
        dc.w	$0,     $A00,           $30,            $80             ; $38   ; Super Underwater Speedshoes
	endif
; ===========================================================================