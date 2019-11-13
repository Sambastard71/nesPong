.db "NES", $1A, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

.define PPUCTRL $2000
.define PPUMASK $2001
.define PPUSTATUS $2002
.define OAMADDR $2003
.define OAMDATA $2004
.define PPUADDR $2006
.define PPUDATA $2007

.define JOYPAD1 $4016

.define RIGHT_KEY 1
.define LEFT_KEY 2
.define B_KEY 64
.define A_KEY 128

.define PLAYER_X $03f
.define PLAYER_Y $00
.define PLAYER_SPEED 1

.org $0000
buttons: .ram 1

player11_y: .ram 1
player11_tile: .ram 1
player11_attributes: .ram 1
player11_x: .ram 1 ; 0 = left 1 = right

player12_y: .ram 1
player12_tile: .ram 1
player12_attributes: .ram 1
player12_x: .ram 1 ; 0 = left 1 = right

player13_y: .ram 1
player13_tile: .ram 1
player13_attributes: .ram 1
player13_x: .ram 1 ; 0 = left 1 = right

player14_y: .ram 1
player14_tile: .ram 1
player14_attributes: .ram 1
player14_x: .ram 1 ; 0 = left 1 = right

player21_y: .ram 1
player21_tile: .ram 1
player21_attributes: .ram 1
player21_x: .ram 1 ; 0 = left 1 = right

player22_y: .ram 1
player22_tile: .ram 1
player22_attributes: .ram 1
player22_x: .ram 1 ; 0 = left 1 = right

player23_y: .ram 1
player23_tile: .ram 1
player23_attributes: .ram 1
player23_x: .ram 1 ; 0 = left 1 = right

player24_y: .ram 1
player24_tile: .ram 1
player24_attributes: .ram 1
player24_x: .ram 1 ; 0 = left 1 = right

ball_y: .ram 1
ball_tile: .ram 1
ball_attributes: .ram 1
ball_x: .ram 1 ; 0 = left 1 = right

player1_point_y: .ram 1
player1_point_tile: .ram 1
player1_point_attributes: .ram 1
player1_point_x: .ram 1 ; 0 = left 1 = right

player2_point_y: .ram 1
player2_point_tile: .ram 1
player2_point_attributes: .ram 1
player2_point_x: .ram 1 ; 0 = left 1 = right

ball_dir_x_bool: .ram 1
ball_dir_y_bool: .ram 1
ball_dir_index: .ram 1

player1_velocity: .ram 1
player2_velocity: .ram 1
ball_x_velocity: .ram 1
ball_y_velocity: .ram 1

.org $8000 $fff9

.macro makePalette color1 color2 color3 color4
LDA #color1
STA PPUDATA
LDA #color2
STA PPUDATA
LDA #color3
STA PPUDATA
LDA #color4
STA PPUDATA
.endmacro

.macro createSprite posY spriteIndex attributes posX ramY ramSprIndex ramAttr ramX 

LDA #posY
STA ramY

LDA #spriteIndex
STA ramSprIndex

LDA #attributes ;B1
STA ramAttr

LDA #posX
STA ramX
.endmacro

.macro UpdateSprite ramAddr

LDA ramAddr
STA OAMDATA

LDA ramAddr+
STA OAMDATA

LDA ramAddr++
STA OAMDATA

LDA ramAddr+++
STA OAMDATA
.endmacro

main:

LDA #%00001000
STA PPUCTRL

LDA #$3F    
STA PPUADDR
LDA #$00
STA PPUADDR


makePalette $22 $29 $1A $0F
makePalette $22 $36 $17 $0F
makePalette $22 $30 $21 $0F
makePalette $22 $27 $17 $0F

makePalette $22 $03 $14 $0F
makePalette $22 $25 $30 $0F
makePalette $22 $0A $27 $0F
makePalette $22 $01 $23 $0F

LDA #%00010000
STA PPUMASK

LDA #00
STA OAMADDR
createSprite 94 %01010111 %00100000 16 player11_y player11_tile player11_attributes player11_x
createSprite 102 %01010111 %00100000 16 player12_y player12_tile player12_attributes player12_x
createSprite 110 %01011000 %00100000 16 player13_y player13_tile player13_attributes player13_x
createSprite 116 %01011000 %00100000 16 player14_y player14_tile player14_attributes player14_x

createSprite 94 %01010111 %00100000 240 player21_y player21_tile player21_attributes player21_x
createSprite 102 %01010111 %00100000 240 player22_y player22_tile player22_attributes player22_x
createSprite 110 %01011000 %00100000 240 player23_y player23_tile player23_attributes player23_x
createSprite 116 %01011000 %00100000 240 player24_y player24_tile player24_attributes player24_x

createSprite 124 %11110000 %00100000 124 ball_y ball_tile ball_attributes ball_x

createSprite 8 %00000000 %00100000 104 player1_point_y player1_point_tile player1_point_attributes player1_point_x
createSprite 8 %00000000 %00100000 144 player2_point_y player2_point_tile player2_point_attributes player2_point_x


JSR UpdateGfx

LDA #00
STA ball_dir_index
JSR BallDir

loop:
JSR readjoy
JSR checkInputP1
JSR checkInputP2
JSR CheckCollision
JSR Update
wait_for_vblank:
LDA PPUSTATUS ; 10000000
BPL wait_for_vblank
JSR UpdateGfx

JMP loop

Update:
JSR UpdatePlayer1
JSR UpdatePlayer2
JSR UpdateBall
RTS

CheckCollision:
JSR CheckY
JSR CheckCollisionWitPlayers
JSR CheckX
RTS

UpdateGfx:
JSR UpdatePlayerSprite1
JSR UpdatePlayerSprite2
JSR UpdateBallSprite
JSR UpdatePointSprite
RTS

UpdateBall:
CLC
LDX ball_x_velocity
LDA ball_x
ADC ball_x_velocity
STA ball_x
CLC
LDY ball_y_velocity
LDA ball_y
ADC ball_y_velocity
STA ball_y
RTS

UpdatePlayer1:
LDA player11_y
CLC
ADC player1_velocity
STA player11_y
LDA player12_y
CLC
ADC player1_velocity
STA player12_y
LDA player13_y
CLC
ADC player1_velocity
STA player13_y
LDA player14_y
CLC
ADC player1_velocity
STA player14_y
RTS

UpdatePlayer2:
LDA player21_y
CLC
ADC player2_velocity
STA player21_y
LDA player22_y
CLC
ADC player2_velocity
STA player22_y
LDA player23_y
CLC
ADC player2_velocity
STA player23_y
LDA player24_y
CLC
ADC player2_velocity
STA player24_y
RTS

BallDir:
LDA ball_dir_index
CMP #4
BEQ ResetBallIndex
CMP #0
BEQ ballUpperLeft
CMP #3
BEQ ballBottomLeft
CMP #1
BEQ ballUpperRight
CMP #2
BEQ ballBottomRight
RTS

ResetBallIndex:
LDA #0
STA ball_dir_index
RTS

ballUpperLeft:
LDA #-1
STA ball_x_velocity
STA ball_y_velocity
INC ball_dir_index
RTS

ballBottomLeft:
LDA #-1
STA ball_x_velocity
LDA #1
STA ball_y_velocity
INC ball_dir_index
RTS

ballUpperRight:
LDA #1
STA ball_x_velocity
LDA #-1
STA ball_y_velocity
INC ball_dir_index
RTS

ballBottomRight:
LDA #1
STA ball_x_velocity
LDA #1
STA ball_y_velocity
INC ball_dir_index
RTS

CheckY:
LDA ball_y
CMP #10
BCC InvertY
CMP #210
BCS InvertY
RTS

CheckCollisionWitPlayers:
JSR CheckColWitPlayer1X
JSR CheckColWitPlayer2X
RTS

InvertY:
LDA ball_y_velocity
CMP #-1
BEQ YFromPosToNeg
LDA #-1
STA ball_y_velocity
RTS
YFromPosToNeg:
LDA #1
STA ball_y_velocity
RTS

InvertX:
LDA ball_x_velocity
CMP #-1
BEQ XFromOneToZero
LDA #-1
STA ball_x_velocity
RTS
XFromOneToZero:
LDA #1
STA ball_x_velocity
RTS

CheckColWitPlayer1X:
LDA player11_x
CLC
ADC #8
CLC
CMP ball_x 
BCC EndCollP1XCheck
LDA ball_y
CLC
ADC #8
CMP player11_y
BCC EndCollP1YCheck
LDA player14_y
CLC
ADC #8
CLC
CMP ball_y
BCS InvertBallP1
EndCollP1YCheck:
EndCollP1XCheck:
RTS

InvertBallP1:
INC ball_x
INC ball_x
JSR InvertX
RTS

InvertBallP2:
DEC ball_x
DEC ball_x
JSR InvertX
RTS

CheckColWitPlayer2X:
LDA ball_x
CLC
ADC #8
CLC
CMP player21_x 
BCC EndCollP2XCheck
LDA ball_y
CLC
ADC #8
CLC
CMP player21_y
BCC EndCollP2YCheck
LDA player24_y
CLC
ADC #8
CLC
CMP ball_y
BCS InvertBallP2
EndCollP2YCheck:
EndCollP2XCheck:
RTS

CheckX:
LDA ball_x
CLC
CMP #8
BCC ReastartGamePoint1
LDA ball_x
CLC
ADC #8
CMP #250
BCS ReastartGamePoint2
RTS

ReastartGamePoint1:
LDA player1_point_tile
CMP #09
BEQ EndGame
INC player1_point_tile
LDA #124
STA ball_x
STA ball_y
JSR BallDir
RTS

ReastartGamePoint2:
LDA player2_point_tile
CMP #09
BEQ EndGame
INC player2_point_tile
LDA #124
STA ball_x
STA ball_y
JSR BallDir
RTS

EndGame:
JMP EndGame
RTS

vblank:
RTI

ignore:
RTI

UpdatePlayerSprite1:
UpdateSprite player11_y
UpdateSprite player12_y
UpdateSprite player13_y
UpdateSprite player14_y
RTS

UpdatePlayerSprite2:
UpdateSprite player21_y
UpdateSprite player22_y
UpdateSprite player23_y
UpdateSprite player24_y
RTS

UpdateBallSprite:
UpdateSprite ball_y
RTS

UpdatePointSprite:
UpdateSprite player1_point_y
UpdateSprite player2_point_y
RTS

; At the same time that we strobe bit 0, we initialize the ring counter
; so we're hitting two birds with one stone here
readjoy:
LDA #$01
    ; While the strobe bit is set, buttons will be continuously reloaded.
    ; This means that reading from JOYPAD1 will only return the state of the
    ; first button: button A.
STA JOYPAD1
STA buttons
LSR a        ; now A is 0
    ; By storing 0 into JOYPAD1, the strobe bit is cleared and the reloading stops.
    ; This allows all 8 buttons (newly reloaded) to be read from JOYPAD1.
STA JOYPAD1
readjoy_loop:
LDA JOYPAD1
LSR a	       ; bit 0 -> Carry
ROL buttons  ; Carry -> bit 0; bit 7 -> Carry
BCC readjoy_loop
RTS

checkInputP1:
LDA buttons
AND #RIGHT_KEY
BNE Set_Player1_Vel_pos
LDA buttons
AND #LEFT_KEY
BNE Set_Player1_Vel_neg
JSR Set_Player1_Vel_Zero
RTS

checkInputP2:
LDA buttons
AND #A_KEY
BNE Set_Player2_Vel_pos
LDA buttons
AND #B_KEY
BNE Set_Player2_Vel_neg
JSR Set_Player2_Vel_Zero
RTS

Set_Player1_Vel_pos:
LDA #2
STA player1_velocity
RTS

Set_Player1_Vel_neg:
LDA #-2
STA player1_velocity
RTS

Set_Player1_Vel_Zero:
LDA #0
STA player1_velocity
RTS

Set_Player2_Vel_pos:
LDA #2
STA player2_velocity
RTS

Set_Player2_Vel_neg:
LDA #-2
STA player2_velocity
RTS

Set_Player2_Vel_Zero:
LDA #0
STA player2_velocity
RTS

.org $fffa
.dw vblank
.dw main
.dw ignore