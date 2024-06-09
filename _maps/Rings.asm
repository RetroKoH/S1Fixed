; ---------------------------------------------------------------------------
; Sprite mappings - rings
; RetroKoH 8-Frame Rings Change
; ---------------------------------------------------------------------------
Map_Ring_internal:	mappingsTable
	mappingsTableEntry.w	.front
	mappingsTableEntry.w	.angle1
	mappingsTableEntry.w	.angle2
	mappingsTableEntry.w	.angle3
	mappingsTableEntry.w	.edge
	mappingsTableEntry.w	.angle4
	mappingsTableEntry.w	.angle5
	mappingsTableEntry.w	.angle6
	mappingsTableEntry.w	.sparkle1
	mappingsTableEntry.w	.sparkle2
	mappingsTableEntry.w	.sparkle3
	mappingsTableEntry.w	.sparkle4
	mappingsTableEntry.w	.blank

.front:	spriteHeader
	spritePiece	-8, -8, 2, 2, 0, 0, 0, 0, 0		; ring front
.front_End

.angle1:	spriteHeader
	spritePiece	-8, -8, 2, 2, 4, 0, 0, 0, 0		; ring angle
.angle1_End

.angle2:	spriteHeader
	spritePiece	-8, -8, 2, 2, 8, 0, 0, 0, 0		; ring angle
.angle2_End

.angle3:	spriteHeader
	spritePiece	-4, -8, 1, 2, $C, 0, 0, 0, 0	; ring angle
.angle3_End

.edge:	spriteHeader
	spritePiece	-4, -8, 1, 2, $E, 0, 0, 0, 0 	; ring perpendicular
.edge_End

.angle4:	spriteHeader
	spritePiece	-4, -8, 1, 2, $C, 1, 0, 0, 0	; ring angle
.angle4_End

.angle5:	spriteHeader
	spritePiece	-8, -8, 2, 2, 8, 1, 0, 0, 0		; ring angle
.angle5_End

.angle6:	spriteHeader
	spritePiece	-8, -8, 2, 2, 4, 1, 0, 0, 0		; ring angle
.angle6_End

.sparkle1:	spriteHeader
	spritePiece	-8, -8, 2, 2, $10, 0, 0, 0, 0	; sparkle
.sparkle1_End

.sparkle2:	spriteHeader
	spritePiece	-8, -8, 2, 2, $10, 1, 1, 0, 0	; sparkle
.sparkle2_End

.sparkle3:	spriteHeader
	spritePiece	-8, -8, 2, 2, $10, 1, 0, 0, 0	; sparkle
.sparkle3_End

.sparkle4:	spriteHeader
	spritePiece	-8, -8, 2, 2, $10, 0, 1, 0, 0	; sparkle
.sparkle4_End

.blank:	spriteHeader
.blank_End

	even
