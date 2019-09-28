; An yes/no animal guessing game for the lc3
; Written by Owen O'Connor while I had nothing better to do with my time
;
; Question storage tree construct format:
; BYTE0: 0 for question, 1 for tree end
; BYTE1: Pointer to node for yes answer
; BYTE2: Pointer to node for no answer
; BYTE3-63: Zero terminated string for question/answer (max length 59)
;
    .ORIG x3000

    ; #########################################################################
    ; #####                       INITIALIZE MEMORY                       #####
    ; #########################################################################

    ; Initialize a basic animal tree
    LD R0, firstNode

    ; Indicate that this node is a question
    AND R1, R1, x0
    ADD R1, R1, x1
    STR R1, R0, x0
    
    ; Compute the address of the yes node
    LD R1, nodeSpacing
    ADD R1, R0, R1

    ; Store the address of the yes node
    STR R1, R0, x1

    ; Compute the address of the no node
    LD R2, nodeSpacing
    ADD R1, R1, R2

    ; Store the address of the no node
    STR R1, R0, x2

    ; Load a pointer to the start of the question 
    LEA R1, question1

    ; Advance the node pointer to the start of the question block
    ADD R0, R0, x3

QUESTION_LOAD_LOOP
    LDR R2, R1, x0
    STR R2, R0, x0
    ADD R0, R0, x1
    ADD R1, R1, x1
    ADD R2, R2, x0
    BRnp QUESTION_LOAD_LOOP

    ; Initialize the yes node
    LD R0, firstNode
    LD R1, nodeSpacing
    ADD R0, R0, R1

    ; Indicate that this is an answer node
    AND R1, R1, x0
    STR R1, R0, x0
    STR R1, R0, x1
    STR R2, R0, x2

    ; Load pointers for string copying
    LEA R1, question1Yes
    ADD R0, R0, x3

ZEBRA_LOAD_LOOP
    LDR R2, R1, x0
    STR R2, R0, x0
    ADD R0, R0, x1
    ADD R1, R1, x1
    ADD R2, R2, x0
    BRnp ZEBRA_LOAD_LOOP

    ; Initialize the no node
    LD R0, firstNode
    LD R1, nodeSpacing
    ADD R0, R0, R1
    ADD R0, R0, R1

    ; Indicate that this is an answer node
    AND R1, R1, x0
    STR R1, R0, x0
    STR R1, R0, x1
    STR R2, R0, x2

    ; Load pointers for string copying
    LEA R1, question1No
    ADD R0, R0, x3

HORSE_LOAD_LOOP
    LDR R2, R1, x0
    STR R2, R0, x0
    ADD R0, R0, x1
    ADD R1, R1, x1
    ADD R2, R2, x0
    BRnp HORSE_LOAD_LOOP

    BRnzp MAIN

    ; ##### DATA BLOCK #####
question1
    .STRINGZ "Please think of an animal. Does the animal have stripes? "
question1Yes
    .STRINGZ "zebra"
question1No
    .STRINGZ "horse"
firstNode
    .FILL x4000
nodeSpacing
    .FILL x0040
startSting
    .STRINGZ "Would you like to play a guessing game? "
minusY
    .FILL x-79
minusN
    .FILL x-6E
    ; ##### END DATA BLOCK #####

MAIN
    LEA R0, startSting
    PUTS

USRIN
    GETC
    LD R1, minusY
    ADD R2, R1, R0
    BRz SAID_YES
    LD R1, minusN
    ADD R2, R1, R0
    BRz SAID_NO
    BRnzp USRIN

SAID_YES
    OUT
    AND R0, R0, x0
    ADD R0, R0, xA
    OUT
    BRnzp START_GUESSING

SAID_NO
    OUT
    AND R0, R0, x0
    ADD R0, R0, xA
    OUT
    BRnzp END

END
    AND R0, R0, x0
    ADD R0, R0, xA
    OUT

    HALT

    ; ##### DATA BLOCK #####
preAnswer
    .STRINGZ "Is the animal you're think of a "
postAnswer
    .STRINGZ  "? "
    ; ##### END DATA BLOCK

START_GUESSING
    ; In this part, R1 will be used as a pointer to the current node and nothing else!
    LD R1, firstNode

GUESS
    ; Figure out whether this is an answer or a question
    LDR R2, R1, x0
    BRz ANSWER
    BRnzp QUESTION

QUESTION
    ADD R0, R1, x3
    PUTS
USRIN_Q
    GETC
    LD R2, minusY
    ADD R2, R2, R0
    BRz SAID_YES_Q
    LD R2, minusN
    ADD R2, R2, R0
    BRz SAID_NO_Q
    BRnzp USRIN_Q

SAID_YES_Q
    OUT
    AND R0, R0, x0
    ADD R0, R0, xA
    OUT
    LDR R1, R1, x1
    BRnzp GUESS

SAID_NO_Q
    OUT
    AND R0, R0, x0
    ADD R0, R0, xA
    OUT
    LDR R1, R1, x2
    BRnzp GUESS

ANSWER
    LEA R0, preAnswer
    PUTS
    ADD R0, R1, x3
    PUTS
    LEA R0, postAnswer
    PUTS

USRIN_A
    GETC
    LD R2, minusY
    ADD R2, R2, R0
    BRz SAID_YES_A
    LD R2, minusN
    ADD R2, R2, R0
    BRz SAID_NO_A
    BRnzp USRIN_A

SAID_YES_A
    OUT
    AND R0, R0, x0
    ADD R0, R0, xA
    OUT
    LEA R0, guessRight
    PUTS
USRIN_N ; n for new game
    GETC
    LD R2, minusY
    ADD R2, R2, R0
    BRz NEW_GAME
    LD R2, minusN
    ADD R2, R2, R0
    BRnzp SAY_BYE

NEW_GAME
    OUT
    AND R0, R0, x0
    ADD R0, R0, xA
    OUT
    BRnzp START_GUESSING

SAY_BYE
    OUT
    AND R0, R0, x0
    ADD R0, R0, xA
    OUT
    LEA R0, exitString
    PUTS
    BRnzp END

SAID_NO_A
    OUT
    AND R0, R0, x0
    ADD R0, R0, xA
    OUT
    LEA R0, guessWrong
    PUTS
    BRnzp END


; ##### DATA BLOCK #####
guessRight
    .STRINGZ  "Yay! I am a smart computer. Would you like to play again? "
guessWrong
    .STRINGZ "Oh well. What was the animal you were thinking of: "
exitString
    .STRINGZ "Okay, bye!"
; ##### END DATA BLOCK


; Slots for variables
numNodes
    .FILL x0003
oldAnimal
    .BLKW x40
newAnimal
    .BLKW x40
newQuestion
    .BLKW x40
    .END