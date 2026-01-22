; ---------------------------------------------------------------------------
; Animation script - Eggman (bosses)
; ---------------------------------------------------------------------------
Ani_Eggman:
		dc.w .facenormal1-Ani_Eggman
		dc.w .facenormal2-Ani_Eggman
		dc.w .facenormal3-Ani_Eggman
		dc.w .facelaugh-Ani_Eggman
		dc.w .facehit-Ani_Eggman
		dc.w .facepanic-Ani_Eggman
		dc.w .facedefeat-Ani_Eggman

.facenormal1:	dc.b 5,	0, 1, afEnd
		even
.facenormal2:	dc.b 3,	0, 1, afEnd
		even
.facenormal3:	dc.b 1,	0, 1, afEnd
		even
.facelaugh:		dc.b 4,	2, 3, afEnd
		even
.facehit:		dc.b $1F, 4, 0,	afEnd
		even
.facepanic:		dc.b 3,	5, 0, afEnd
		even
.facedefeat:	dc.b $F, 6, afEnd
		even

; Eggman Animation IDs
	phase 0
aniID_NormalFace1:		ds.b 1		; 0 - Face 1
aniID_NormalFace2:		ds.b 1		; 1 - Face 2
aniID_NormalFace3:		ds.b 1		; 2 - Face 3
aniID_LaughFace:		ds.b 1		; 3 - Laughing face
aniID_HurtFace:			ds.b 1		; 4 - Face when hit
aniID_PanicFace:		ds.b 1		; 5 - Panicking face
aniID_DefeatFace:		ds.b 1		; 6 - Face when defeated
	dephase
	even

; ---------------------------------------------------------------------------
; Animation script - Eggman's Exhaust Flame
; ---------------------------------------------------------------------------
Ani_Exhaust:
		dc.w .blank-Ani_Exhaust
		dc.w .flame1-Ani_Exhaust
		dc.w .flame2-Ani_Exhaust
		dc.w .escapeflame-Ani_Exhaust

.blank:			dc.b $F, 0, afEnd
		even
.flame1:		dc.b 3,	1, 2, afEnd
		even
.flame2:		dc.b 1,	1, 2, afEnd
		even
.escapeflame:	dc.b 2,	2, 1, 3, 4, 3, 4, 2, 1, afBack, 2
		even

; Eggman Animation IDs
	phase 0
aniID_Blank:			ds.b 1		; 0 - Blank (Sometimes used when flames shouldn't appear)
aniID_Flame1:			ds.b 1		; 1 - Flame 1
aniID_Flame2:			ds.b 1		; 2 - Flame 2
aniID_EscapeFlame:		ds.b 1		; 3 - Flame 3 (When escaping)
	dephase