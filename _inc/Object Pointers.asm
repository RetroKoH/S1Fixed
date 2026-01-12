; ---------------------------------------------------------------------------
; Object pointers
; This list only contains objects that are loaded by ObjPosLoad
; Dynamically spawned objects are no longer in this list
; ---------------------------------------------------------------------------

ptr_Obj01:				dc.l DeleteObject	; $01
ptr_Obj02:				dc.l DeleteObject
ptr_PathSwapper:		dc.l PathSwapper
ptr_AutoRollTag:		dc.l AutoRollTag
ptr_Obj05:				dc.l DeleteObject
ptr_Obj06:				dc.l DeleteObject
ptr_Obj07:				dc.l DeleteObject
ptr_Obj08:				dc.l DeleteObject	; $08
ptr_Obj09:				dc.l DeleteObject
ptr_Obj0A:				dc.l DeleteObject
ptr_Pole:				dc.l Pole
ptr_FlapDoor:			dc.l FlapDoor
ptr_Signpost:			dc.l Signpost
ptr_Obj0E:				dc.l DeleteObject
ptr_Obj0F:				dc.l DeleteObject
ptr_Obj10:				dc.l DeleteObject	; $10
ptr_Bridge:				dc.l Bridge
ptr_SpinningLight:		dc.l SpinningLight
ptr_FireMaker:			dc.l FireMaker
ptr_Obj14:				dc.l DeleteObject
ptr_SwingingPlatform:	dc.l SwingingPlatform
ptr_Harpoon:			dc.l Harpoon
ptr_Helix:				dc.l Helix
ptr_BasicPlatform:		dc.l BasicPlatform	; $18
ptr_GiantBall:			dc.l GiantBall
ptr_CollapseLedge:		dc.l CollapseLedge
ptr_Obj1B:				dc.l DeleteObject
ptr_Scenery:			dc.l Scenery
ptr_MagicSwitch:		dc.l MagicSwitch
ptr_BallHog:			dc.l BallHog
ptr_Crabmeat:			dc.l Crabmeat
ptr_Obj20:				dc.l DeleteObject	; $20
ptr_Obj21:				dc.l DeleteObject
ptr_BuzzBomber:			dc.l BuzzBomber
ptr_Obj23:				dc.l DeleteObject
ptr_Obj24:				dc.l DeleteObject
ptr_Rings:				dc.l Rings
ptr_Monitor:			dc.l Monitor
ptr_Obj27:				dc.l DeleteObject
ptr_Animals:			dc.l Animals		; $28
ptr_Obj29:				dc.l DeleteObject
ptr_AutoDoor:			dc.l AutoDoor
ptr_Chopper:			dc.l Chopper
ptr_Jaws:				dc.l Jaws
ptr_Burrobot:			dc.l Burrobot
ptr_SGrass:				dc.l SinkingGrass
ptr_LargeGrass:			dc.l LargeGrass
ptr_GlassBlock:			dc.l GlassBlock		; $30
ptr_ChainStomp:			dc.l ChainStomp
ptr_Button:				dc.l Button
ptr_PushBlock:			dc.l PushBlock
ptr_Obj34:				dc.l DeleteObject
ptr_Obj35:				dc.l DeleteObject
ptr_Spikes:				dc.l Spikes
ptr_Obj37:				dc.l DeleteObject
ptr_Obj38:				dc.l DeleteObject	; $38
ptr_Obj39:				dc.l DeleteObject
ptr_Obj3A:				dc.l DeleteObject
ptr_PurpleRock:			dc.l PurpleRock
ptr_SmashWall:			dc.l SmashWall
ptr_LZDoorVert:			dc.l LZDoorVert	; LZ Vertical Door (from obj56)
ptr_Prison:				dc.l Prison
ptr_Obj3F:				dc.l DeleteObject	; LZ Large Horizontal Door (from obj56)
ptr_MotoBug:			dc.l MotoBug		; $40
ptr_Springs:			dc.l Springs
ptr_Newtron:			dc.l Newtron
ptr_Roller:				dc.l Roller
ptr_EdgeWalls:			dc.l EdgeWalls
ptr_SideStomp:			dc.l SideStomp
ptr_MarbleBrick:		dc.l MarbleBrick
ptr_Bumper:				dc.l Bumper
ptr_LZRisePlat:			dc.l LZRisePlat		; $48
ptr_WaterSound:			dc.l WaterSound
ptr_LZCork:				dc.l LZCork
ptr_GiantRing:			dc.l GiantRing
ptr_GeyserMaker:		dc.l GeyserMaker
ptr_SpikeBar:			dc.l SpikeBar
ptr_LavaWall:			dc.l LavaWall
ptr_Splats:				dc.l Splats
ptr_Yadrin:				dc.l Yadrin			; $50
ptr_SmashBlock:			dc.l SmashBlock
ptr_MovingBlock:		dc.l MovingBlock
ptr_CollapseFloor:		dc.l CollapseFloor
ptr_LavaTag:			dc.l LavaTag
ptr_Basaran:			dc.l Basaran
ptr_FloatingBlock:		dc.l FloatingBlock	; SYZ Floating Blocks
ptr_SpikeBall:			dc.l SpikeBall
ptr_BigSpikeBall:		dc.l BigSpikeBall	; $58
ptr_Elevator:			dc.l Elevator
ptr_CirclingPlatform:	dc.l CirclingPlatform
ptr_Staircase:			dc.l Staircase
ptr_Obj5C:				dc.l DeleteObject	; SLZ Floating Block Contraption (from obj56)
ptr_Fan:				dc.l Fan
ptr_Seesaw:				dc.l Seesaw
ptr_Bomb:				dc.l Bomb
ptr_Orbinaut:			dc.l Orbinaut		; $60
ptr_LabyrinthBlock:		dc.l LabyrinthBlock
ptr_Gargoyle:			dc.l Gargoyle
ptr_LabyrinthConvey:	dc.l LabyrinthConvey
ptr_Bubble:				dc.l Bubble
ptr_Waterfall:			dc.l Waterfall
ptr_Junction:			dc.l Junction
ptr_RunningDisc:		dc.l RunningDisc
ptr_Conveyor:			dc.l Conveyor		; $68
ptr_SpinPlatform:		dc.l SpinPlatform
ptr_Saws:				dc.l Saws
ptr_ScrapStomp:			dc.l ScrapStomp
ptr_VanishPlatform:		dc.l VanishPlatform
ptr_Flamethrower:		dc.l Flamethrower
ptr_Electro:			dc.l Electro
ptr_SpinConvey:			dc.l SpinConvey
ptr_Girder:				dc.l Girder			; $70
ptr_Invisibarrier:		dc.l Invisibarrier
ptr_Teleport:			dc.l Teleport
ptr_Trapdoor:			dc.l Trapdoor
ptr_Obj74:				dc.l DeleteObject
ptr_Obj75:				dc.l DeleteObject
ptr_Obj76:				dc.l DeleteObject
ptr_Obj77:				dc.l DeleteObject
ptr_Caterkiller:		dc.l Caterkiller	; $78
ptr_Lamppost:			dc.l Lamppost
ptr_MetalBar:			dc.l MetalBar
ptr_Obj7B:				dc.l DeleteObject
ptr_Obj7C:				dc.l DeleteObject
ptr_HiddenBonus:		dc.l HiddenBonus
ptr_Obj7E:				dc.l DeleteObject
ptr_SlidingPlatform:	dc.l SlidingPlatform

; Add new object pointers here
; ===========================================================================

; Index numbers (Used in _inc/DebugList.asm)
id_Obj01:				equ ((ptr_Obj01-Obj_Index)/4)+1				; $01
id_Obj02:				equ ((ptr_Obj02-Obj_Index)/4)+1
id_PathSwapper:			equ ((ptr_PathSwapper-Obj_Index)/4)+1
id_AutoRollTag:			equ ((ptr_AutoRollTag-Obj_Index)/4)+1
id_Obj05:				equ ((ptr_Obj05-Obj_Index)/4)+1
id_Obj06:				equ ((ptr_Obj06-Obj_Index)/4)+1
id_Obj07:				equ ((ptr_Obj07-Obj_Index)/4)+1
id_Obj08:				equ ((ptr_Obj08-Obj_Index)/4)+1				; $08
id_Obj09:				equ ((ptr_Obj09-Obj_Index)/4)+1
id_Obj0A:				equ ((ptr_Obj0A-Obj_Index)/4)+1
id_Pole:				equ ((ptr_Pole-Obj_Index)/4)+1
id_FlapDoor:			equ ((ptr_FlapDoor-Obj_Index)/4)+1
id_Signpost:			equ ((ptr_Signpost-Obj_Index)/4)+1
id_Obj0E:				equ ((ptr_Obj0E-Obj_Index)/4)+1
id_Obj0F:				equ ((ptr_Obj0F-Obj_Index)/4)+1
id_Obj10:				equ ((ptr_Obj10-Obj_Index)/4)+1				; $10
id_Bridge:				equ ((ptr_Bridge-Obj_Index)/4)+1
id_SpinningLight:		equ ((ptr_SpinningLight-Obj_Index)/4)+1
id_FireMaker:			equ ((ptr_FireMaker-Obj_Index)/4)+1
id_Obj14:				equ ((ptr_Obj14-Obj_Index)/4)+1
id_SwingingPlatform:	equ ((ptr_SwingingPlatform-Obj_Index)/4)+1
id_Harpoon:				equ ((ptr_Harpoon-Obj_Index)/4)+1
id_Helix:				equ ((ptr_Helix-Obj_Index)/4)+1
id_BasicPlatform:		equ ((ptr_BasicPlatform-Obj_Index)/4)+1		; $18
id_GiantBall:			equ ((ptr_GiantBall-Obj_Index)/4)+1
id_CollapseLedge:		equ ((ptr_CollapseLedge-Obj_Index)/4)+1
id_Obj1B:				equ ((ptr_Obj1B-Obj_Index)/4)+1
id_Scenery:				equ ((ptr_Scenery-Obj_Index)/4)+1
id_MagicSwitch:			equ ((ptr_MagicSwitch-Obj_Index)/4)+1
id_BallHog:				equ ((ptr_BallHog-Obj_Index)/4)+1
id_Crabmeat:			equ ((ptr_Crabmeat-Obj_Index)/4)+1
id_Obj20:				equ ((ptr_Obj20-Obj_Index)/4)+1				; $20
id_Obj21:				equ ((ptr_Obj21-Obj_Index)/4)+1
id_BuzzBomber:			equ ((ptr_BuzzBomber-Obj_Index)/4)+1
id_Obj23:				equ ((ptr_Obj23-Obj_Index)/4)+1
id_Obj24:				equ ((ptr_Obj24-Obj_Index)/4)+1
id_Rings:				equ ((ptr_Rings-Obj_Index)/4)+1
id_Monitor:				equ ((ptr_Monitor-Obj_Index)/4)+1
id_Obj27:				equ ((ptr_Obj27-Obj_Index)/4)+1
id_Animals:				equ ((ptr_Animals-Obj_Index)/4)+1			; $28
id_Obj29:				equ ((ptr_Obj29-Obj_Index)/4)+1
id_AutoDoor:			equ ((ptr_AutoDoor-Obj_Index)/4)+1
id_Chopper:				equ ((ptr_Chopper-Obj_Index)/4)+1
id_Jaws:				equ ((ptr_Jaws-Obj_Index)/4)+1
id_Burrobot:			equ ((ptr_Burrobot-Obj_Index)/4)+1
id_SGrass:				equ ((ptr_SGrass-Obj_Index)/4)+1
id_LargeGrass:			equ ((ptr_LargeGrass-Obj_Index)/4)+1
id_GlassBlock:			equ ((ptr_GlassBlock-Obj_Index)/4)+1		; $30
id_ChainStomp:			equ ((ptr_ChainStomp-Obj_Index)/4)+1
id_Button:				equ ((ptr_Button-Obj_Index)/4)+1
id_PushBlock:			equ ((ptr_PushBlock-Obj_Index)/4)+1
id_Obj34:				equ ((ptr_Obj34-Obj_Index)/4)+1
id_Obj35:				equ ((ptr_Obj35-Obj_Index)/4)+1
id_Spikes:				equ ((ptr_Spikes-Obj_Index)/4)+1
id_Obj37:				equ ((ptr_Obj37-Obj_Index)/4)+1
id_Obj38:				equ ((ptr_Obj38-Obj_Index)/4)+1				; $38
id_Obj39:				equ ((ptr_Obj39-Obj_Index)/4)+1
id_Obj3A:				equ ((ptr_Obj3A-Obj_Index)/4)+1
id_PurpleRock:			equ ((ptr_PurpleRock-Obj_Index)/4)+1
id_SmashWall:			equ ((ptr_SmashWall-Obj_Index)/4)+1
id_LZDoorVert:			equ ((ptr_LZDoorVert-Obj_Index)/4)+1
id_Prison:				equ ((ptr_Prison-Obj_Index)/4)+1
id_Obj3F:				equ ((ptr_Obj3F-Obj_Index)/4)+1
id_MotoBug:				equ ((ptr_MotoBug-Obj_Index)/4)+1			; $40
id_Springs:				equ ((ptr_Springs-Obj_Index)/4)+1
id_Newtron:				equ ((ptr_Newtron-Obj_Index)/4)+1
id_Roller:				equ ((ptr_Roller-Obj_Index)/4)+1
id_EdgeWalls:			equ ((ptr_EdgeWalls-Obj_Index)/4)+1
id_SideStomp:			equ ((ptr_SideStomp-Obj_Index)/4)+1
id_MarbleBrick:			equ ((ptr_MarbleBrick-Obj_Index)/4)+1
id_Bumper:				equ ((ptr_Bumper-Obj_Index)/4)+1
id_LZRisePlat:			equ ((ptr_LZRisePlat-Obj_Index)/4)+1		; $48
id_WaterSound:			equ ((ptr_WaterSound-Obj_Index)/4)+1
id_LZCork:				equ ((ptr_LZCork-Obj_Index)/4)+1
id_GiantRing:			equ ((ptr_GiantRing-Obj_Index)/4)+1
id_GeyserMaker:			equ ((ptr_GeyserMaker-Obj_Index)/4)+1
id_SpikeBar:			equ ((ptr_SpikeBar-Obj_Index)/4)+1
id_LavaWall:			equ ((ptr_LavaWall-Obj_Index)/4)+1
id_Splats:				equ ((ptr_Splats-Obj_Index)/4)+1
id_Yadrin:				equ ((ptr_Yadrin-Obj_Index)/4)+1			; $50
id_SmashBlock:			equ ((ptr_SmashBlock-Obj_Index)/4)+1
id_MovingBlock:			equ ((ptr_MovingBlock-Obj_Index)/4)+1
id_CollapseFloor:		equ ((ptr_CollapseFloor-Obj_Index)/4)+1
id_LavaTag:				equ ((ptr_LavaTag-Obj_Index)/4)+1
id_Basaran:				equ ((ptr_Basaran-Obj_Index)/4)+1
id_FloatingBlock:		equ ((ptr_FloatingBlock-Obj_Index)/4)+1
id_SpikeBall:			equ ((ptr_SpikeBall-Obj_Index)/4)+1
id_BigSpikeBall:		equ ((ptr_BigSpikeBall-Obj_Index)/4)+1		; $58
id_Elevator:			equ ((ptr_Elevator-Obj_Index)/4)+1
id_CirclingPlatform:	equ ((ptr_CirclingPlatform-Obj_Index)/4)+1
id_Staircase:			equ ((ptr_Staircase-Obj_Index)/4)+1
id_Obj5C:				equ ((ptr_Obj5C-Obj_Index)/4)+1
id_Fan:					equ ((ptr_Fan-Obj_Index)/4)+1
id_Seesaw:				equ ((ptr_Seesaw-Obj_Index)/4)+1
id_Bomb:				equ ((ptr_Bomb-Obj_Index)/4)+1
id_Orbinaut:			equ ((ptr_Orbinaut-Obj_Index)/4)+1			; $60
id_LabyrinthBlock:		equ ((ptr_LabyrinthBlock-Obj_Index)/4)+1
id_Gargoyle:			equ ((ptr_Gargoyle-Obj_Index)/4)+1
id_LabyrinthConvey:		equ ((ptr_LabyrinthConvey-Obj_Index)/4)+1
id_Bubble:				equ ((ptr_Bubble-Obj_Index)/4)+1
id_Waterfall:			equ ((ptr_Waterfall-Obj_Index)/4)+1
id_Junction:			equ ((ptr_Junction-Obj_Index)/4)+1
id_RunningDisc:			equ ((ptr_RunningDisc-Obj_Index)/4)+1
id_Conveyor:			equ ((ptr_Conveyor-Obj_Index)/4)+1			; $68
id_SpinPlatform:		equ ((ptr_SpinPlatform-Obj_Index)/4)+1
id_Saws:				equ ((ptr_Saws-Obj_Index)/4)+1
id_ScrapStomp:			equ ((ptr_ScrapStomp-Obj_Index)/4)+1
id_VanishPlatform:		equ ((ptr_VanishPlatform-Obj_Index)/4)+1
id_Flamethrower:		equ ((ptr_Flamethrower-Obj_Index)/4)+1
id_Electro:				equ ((ptr_Electro-Obj_Index)/4)+1
id_SpinConvey:			equ ((ptr_SpinConvey-Obj_Index)/4)+1
id_Girder:				equ ((ptr_Girder-Obj_Index)/4)+1			; $70
id_Invisibarrier:		equ ((ptr_Invisibarrier-Obj_Index)/4)+1
id_Teleport:			equ ((ptr_Teleport-Obj_Index)/4)+1
id_Trapdoor:			equ ((ptr_Trapdoor-Obj_Index)/4)+1
id_Obj74:				equ ((ptr_Obj74-Obj_Index)/4)+1
id_Obj75:				equ ((ptr_Obj75-Obj_Index)/4)+1
id_Obj76:				equ ((ptr_Obj76-Obj_Index)/4)+1
id_Obj77:				equ ((ptr_Obj77-Obj_Index)/4)+1
id_Caterkiller:			equ ((ptr_Caterkiller-Obj_Index)/4)+1		; $78
id_Lamppost:			equ ((ptr_Lamppost-Obj_Index)/4)+1
id_MetalBar:			equ ((ptr_MetalBar-Obj_Index)/4)+1
id_Obj7B:				equ ((ptr_Obj7B-Obj_Index)/4)+1
id_Obj7C:				equ ((ptr_Obj7C-Obj_Index)/4)+1
id_HiddenBonus:			equ ((ptr_HiddenBonus-Obj_Index)/4)+1
id_Obj7E:				equ ((ptr_Obj7E-Obj_Index)/4)+1
id_ptr_SlidingPlatform:	equ ((ptr_SlidingPlatform-Obj_Index)/4)+1

; Add new object IDs here
; ===========================================================================