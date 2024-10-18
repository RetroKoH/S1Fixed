; ---------------------------------------------------------------
; DAC Samples Files
; ---------------------------------------------------------------

;			| Filename	| Folder
		incdac	SegaPCM, "sound/dac/SegaPCM.pcm"

    if SMPS_S1DACSamples||SMPS_S2DACSamples
		incdac	Kick, "sound/dac/Sonic 1 & 2/Kick.pcm"
		incdac	Snare, "sound/dac/Sonic 1 & 2/Snare.pcm"
		incdac	Timpani, "sound/dac/Sonic 1 & 2/Timpani.pcm"
    endif

    if SMPS_S2DACSamples
		incdac	Clap, "sound/dac/Sonic 1 & 2/Clap.pcm"
		incdac	Scratch, "sound/dac/Sonic 1 & 2/Scratch.pcm"
		incdac	Tom, "sound/dac/Sonic 1 & 2/Tom.pcm"
		incdac	Bongo, "sound/dac/Sonic 1 & 2/Bongo.pcm"
    endif

    if SMPS_S3DACSamples||SMPS_SKDACSamples||SMPS_S3DDACSamples
		incdac	SnareS3, "sound/dac/Sonic 3 & K & 3D/SnareS3.pcm"
		incdac	TomS3, "sound/dac/Sonic 3 & K & 3D/TomS3.pcm"
		incdac	KickS3, "sound/dac/Sonic 3 & K & 3D/KickS3.pcm"
		incdac	MuffledSnare, "sound/dac/Sonic 3 & K & 3D/MuffledSnare.pcm"
		incdac	CrashCymbal, "sound/dac/Sonic 3 & K & 3D/CrashCymbal.pcm"
		incdac	RideCymbal, "sound/dac/Sonic 3 & K & 3D/RideCymbal.pcm"
		incdac	MetalHit, "sound/dac/Sonic 3 & K & 3D/MetalHit.pcm"
		incdac	MetalHit2, "sound/dac/Sonic 3 & K & 3D/MetalHit2.pcm"
		incdac	MetalHit3, "sound/dac/Sonic 3 & K & 3D/MetalHit3.pcm"
		incdac	ClapS3, "sound/dac/Sonic 3 & K & 3D/ClapS3.pcm"
		incdac	ElectricTom, "sound/dac/Sonic 3 & K & 3D/ElectricTom.pcm"
		incdac	SnareS32, "sound/dac/Sonic 3 & K & 3D/SnareS32.pcm"
		incdac	TimpaniS3, "sound/dac/Sonic 3 & K & 3D/TimpaniS3.pcm"
		incdac	SnareS33, "sound/dac/Sonic 3 & K & 3D/SnareS33.pcm"
		incdac	Click, "sound/dac/Sonic 3 & K & 3D/Click.pcm"
		incdac	PowerKick, "sound/dac/Sonic 3 & K & 3D/PowerKick.pcm"
		incdac	QuickGlassCrash, "sound/dac/Sonic 3 & K & 3D/QuickGlassCrash.pcm"
    endif

    if SMPS_S3DACSamples||SMPS_SKDACSamples
		incdac	GlassCrashSnare, "sound/dac/Sonic 3 & K & 3D/GlassCrashSnare.pcm"
		incdac	GlassCrash, "sound/dac/Sonic 3 & K & 3D/GlassCrash.pcm"
		incdac	GlassCrashKick, "sound/dac/Sonic 3 & K & 3D/GlassCrashKick.pcm"
		incdac	QuietGlassCrash, "sound/dac/Sonic 3 & K & 3D/QuietGlassCrash.pcm"
		incdac	SnareKick, "sound/dac/Sonic 3 & K & 3D/SnareKick.pcm"
		incdac	KickBass, "sound/dac/Sonic 3 & K & 3D/KickBass.pcm"
		incdac	ComeOn, "sound/dac/Sonic 3 & K & 3D/ComeOn.pcm"
		incdac	DanceSnare, "sound/dac/Sonic 3 & K & 3D/DanceSnare.pcm"
		incdac	LooseKick, "sound/dac/Sonic 3 & K & 3D/LooseKick.pcm"
		incdac	LooseKick2, "sound/dac/Sonic 3 & K & 3D/LooseKick2.pcm"
		incdac	Woo, "sound/dac/Sonic 3 & K & 3D/Woo.pcm"
		incdac	Go, "sound/dac/Sonic 3 & K & 3D/Go.pcm"
		incdac	SnareGo, "sound/dac/Sonic 3 & K & 3D/SnareGo.pcm"
		incdac	PowerTom, "sound/dac/Sonic 3 & K & 3D/PowerTom.pcm"
		incdac	WoodBlock, "sound/dac/Sonic 3 & K & 3D/WoodBlock.pcm"
		incdac	HitDrum, "sound/dac/Sonic 3 & K & 3D/HitDrum.pcm"
		incdac	MetalCrashHit, "sound/dac/Sonic 3 & K & 3D/MetalCrashHit.pcm"
		incdac	EchoedClapHit, "sound/dac/Sonic 3 & K & 3D/EchoedClapHit.pcm"
		incdac	HipHopHitKick, "sound/dac/Sonic 3 & K & 3D/HipHopHitKick.pcm"
		incdac	HipHopPowerKick, "sound/dac/Sonic 3 & K & 3D/HipHopPowerKick.pcm"
		incdac	BassHey, "sound/dac/Sonic 3 & K & 3D/BassHey.pcm"
		incdac	DanceStyleKick, "sound/dac/Sonic 3 & K & 3D/DanceStyleKick.pcm"
		incdac	HipHopHitKick2, "sound/dac/Sonic 3 & K & 3D/HipHopHitKick2.pcm"
		incdac	RevFadingWind, "sound/dac/Sonic 3 & K & 3D/RevFadingWind.pcm"
		incdac	ScratchS3, "sound/dac/Sonic 3 & K & 3D/ScratchS3.pcm"
		incdac	LooseSnareNoise, "sound/dac/Sonic 3 & K & 3D/LooseSnareNoise.pcm"
		incdac	PowerKick2, "sound/dac/Sonic 3 & K & 3D/PowerKick2.pcm"
		incdac	CrashNoiseWoo, "sound/dac/Sonic 3 & K & 3D/CrashNoiseWoo.pcm"
		incdac	QuickHit, "sound/dac/Sonic 3 & K & 3D/QuickHit.pcm"
		incdac	KickHey, "sound/dac/Sonic 3 & K & 3D/KickHey.pcm"
    endif

    if SMPS_S3DDACSamples
		incdac	MetalCrashS3D, "sound/dac/Sonic 3 & K & 3D/MetalCrashS3D.pcm"
		incdac	IntroKickS3D, "sound/dac/Sonic 3 & K & 3D/IntroKickS3D.pcm"
    endif

    if SMPS_S3DACSamples
		incdac	EchoedClapHitS3, "sound/dac/Sonic 3 & K & 3D/EchoedClapHitS3.pcm"
    endif

    if SMPS_SCDACSamples
		incdac	Beat, "sound/dac/Sonic Crackers/Beat.pcm"
		incdac	SnareSC, "sound/dac/Sonic Crackers/SnareSC.pcm"
		incdac	TimTom, "sound/dac/Sonic Crackers/TimTom.pcm"
		incdac	LetsGo, "sound/dac/Sonic Crackers/LetsGo.pcm"
		incdac	Hey, "sound/dac/Sonic Crackers/Hey.pcm"
    endif
	even
