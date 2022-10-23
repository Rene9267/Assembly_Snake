.ORG $8000
.define Next_Position               $00         ;Here i'll store the next position of the pixel's head 
.define Head_Address                $05  
.define Head_Delay_Address          $07 
.define Next_Instruction            $08 
.define Black_Dot_Position          $09
.define Random_Value                $10
.define Random_Apple_Position       $11
.define Input_Value                 $18         ;Store the value for the auto move
.define Starting_Pixel_Position     $0200       ;Store the value for the starting drawing pixel 
.define Head&BlackDot_Page          $0300       ;I'll store in this page the information about the head commands 
.define End_Game_Colors             $78

.define Zero_Color                  #00
.define Apple_Color                 #03    
.define 16_Value                    #16
.define 1_Value                     #01


COMPAREy:
LDY Input_Value
JMP Down_input


;Move Commands----------------------------------------------------------------------------------------
Move_Commands:
STA Next_Position
TAY
LDA Zero_Color
CMP Starting_Pixel_Position,Y
BNE incerment_apple
LDY Zero_Color
JSR Read_Future_Instruction
JSR Print_pixel
JMP Moving_Black_Dot
;-----------------------------------------------------------------------------------------------------


start:
LDX #$FF
TXS
LDX Zero_Color

;Game loop start---------------------------------------------------------------------------------------
GameLoop:
JSR Random

LDY Random_Apple_Position
LDA Apple_Color
STA Starting_Pixel_Position,Y

LDY $4000
CPY Zero_Color
BEQ COMPAREy
STY Input_Value

;Down Input ------------------------------------------------------------------------------------------
Down_input:
CPY #02
BNE Up_input 
JSR Push_Future_Instruction
CLC
ADC 16_Value
JMP Move_Commands
;-----------------------------------------------------------------------------------------------------


;Up input --------------------------------------------------------------------------------------------
Up_input: 
CPY 1_Value
BNE Left_input
JSR Push_Future_Instruction
SBC 16_Value
JMP Move_Commands
;------------------------------------------------------------------------------------------------------


;Left Input--------------------------------------------------------------------------------------------
Left_input: 
CPY #04
BNE Right_input
JSR Push_Future_Instruction
SBC 1_Value
JMP Move_Commands
;-------------------------------------------------------------------------------------------------------


;Right Input--------------------------------------------------------------------------------------------
Right_input:
CPY #08
BNE GameLoop
JSR Push_Future_Instruction
CLC
ADC 1_Value
JMP Move_Commands
;------------------------------------------------------------------------------------------------------


;Increment Apple---------------------------------------------------------------------------------------
incerment_apple:
LDA 1_Value                                     ;Check if the curret pixel is already red
CMP Starting_Pixel_Position , Y
BEQ EndGame
LDA 1_Value
STA Starting_Pixel_Position , Y
LDA Apple_Color
LDY Random_Value
STA Starting_Pixel_Position , Y
STY Random_Apple_Position
JMP GameLoop
;------------------------------------------------------------------------------------------------------

;Game loop End-----------------------------------------------------------------------------------------


;End Game Loop + Color screen--------------------------------------------------------------------------
EndGame:
LDX End_Game_Colors
INC End_Game_Colors
ADC End_Game_Colors
STA Starting_Pixel_Position,X
JMP EndGame
;-------------------------------------------------------------------------------------------------------


;Check if in the next pixel there is an apple-----------------------------------------------------------
Chechk_Apple:
TAY
LDA Apple_Color
CMP Starting_Pixel_Position,Y
BEQ incerment_apple
LDY Zero_Color
;------------------------------------------------------------------------------------------------------


;Print pixel-------------------------------------------------------------------------------------------
Print_pixel:
LDA 1_Value
LDX Next_Position
STA Starting_Pixel_Position, X
JSR Clear_pixel
RTS
;------------------------------------------------------------------------------------------------------


;Clear pixel------------------------------------------------------------------------------------------
Clear_pixel:
LDA Zero_Color
LDY Black_Dot_Position
STA Starting_Pixel_Position,Y
LDY Zero_Color
RTS
;-----------------------------------------------------------------------------------------------------


;Push in the third page the instruction on Y----------------------------------------------------------
Push_Future_Instruction:
LDX Head_Address
TYA 
STA Head&BlackDot_Page , X
LDA Next_Position
INX
STX Head_Address
RTS
;-----------------------------------------------------------------------------------------------------


;Take the instruction and clear the address-----------------------------------------------------------
Read_Future_Instruction:
LDX Head_Delay_Address
LDA Head&BlackDot_Page , X
STA Next_Instruction
LDA Zero_Color
STA Head&BlackDot_Page , X
INX                                  
STX Head_Delay_Address
RTS
;-----------------------------------------------------------------------------------------------------


;BLack Dot Loop---------------------------------------------------------------------------------------
Moving_Black_Dot:                   ;The black dot follow the player moves, with a delay
LDX Next_Instruction
CPX #08
BEQ RIGHT
CPX #04
BEQ LEFT
CPX #02
BEQ DOWN
CPX 1_Value
BEQ UP
JMP GameLoop
RIGHT:
LDA Black_Dot_Position
CLC
ADC 1_Value
STA Black_Dot_Position
JMP GameLoop
LEFT:
LDA Black_Dot_Position
SBC 1_Value
STA Black_Dot_Position
JMP GameLoop
DOWN:
LDA Black_Dot_Position
CLC
ADC 16_Value
STA Black_Dot_Position
JMP GameLoop
UP:
LDA Black_Dot_Position
SBC 16_Value
STA Black_Dot_Position
JMP GameLoop
;---------------------------------------------------------------------------------------------------


;Pseudo-Random Value -------------------------------------------------------------------------------
Random:
LDA Random_Value
CLC
ADC Next_Instruction
ADC Head_Address
ADC Head_Delay_Address
STA Random_Value
RTS
;---------------------------------------------------------------------------------------------------


; Timer:
; ; LDX $0F
; ; INX
; ; STX $0F
; INC $0F
; RTI 

.goto $FFFA
.dw start ; non maskable
.dw start ; reset
.DW start ; interrupt
