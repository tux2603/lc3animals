; An yes/no animal guessing game for the lc3
; Written by Owen O'Connor while I had nothing better to do with my time
;
; Question storage tree construct format:
; BYTE0: 0 for question, 1 for tree end
; BYTE1: Pointer to node for yes answer
; BYTE2: Pointer to node for no answer
; BYTE3-63: Zero terminated string for question/answer (max length 60)
;
;
; TODO: Enforce maximum question size (Currently, questions/animal names more than 58 characters long will break the binary tree structure)
; TODO: Make it so the user can choose whether the new animal will be yes or no answer for the new question

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
    .FILL x3400
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
    HALT

    ; ##### DATA BLOCK #####
preAnswer
    .STRINGZ "Is the animal you're thinking of a "
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

; ##### DATA BLOCK #####
guessRight
    .STRINGZ  "Yay! I am a smart computer. Would you like to play again? "
guessWrong
    .STRINGZ "Oh well. What was the animal you were thinking of: "
exitString
    .STRINGZ "Okay, bye!"
; ##### END DATA BLOCK #####

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
NEW_GAME_CHECK ; n for new game
    GETC
    LD R2, minusY
    ADD R2, R2, R0
    BRz NEW_GAME
    LD R2, minusN
    ADD R2, R2, R0
    BRz SAY_BYE
    BRnzp NEW_GAME_CHECK

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
    AND R0, R0, x0
    ADD R0, R0, xA
    OUT
    HALT

SAID_NO_A
    OUT
    AND R0, R0, x0
    ADD R0, R0, xA
    OUT
    LEA R0, guessWrong
    PUTS

    ; Save the name of the old animal
    ADD R2, R1, x3
    LEA R3, oldAnimal
SAVE_OLD_ANIMAL
    LDR R4, R2, x0
    STR R4, R3, x0
    ADD R2, R2, x1
    ADD R3, R3, x1
    ADD R4, R4, x0
    BRnp SAVE_OLD_ANIMAL

    LEA R2, newAnimal
    AND R3, R3, x0
    ADD R3, R3, x-A

    ; Load and save the name of the new animal
SAVE_NEW_ANIMAL
    GETC
    OUT
    ADD R4, R0, R3
    BRz END_SAVE_NEW_ANIMAL
    STR R0, R2, x0
    ADD R2, R2, x1
    BRnzp SAVE_NEW_ANIMAL

    
START_GUESSING_RELAY1
    BRnzp START_GUESSING

; ##### DATA BLOCK #####
oldAnimal
    .BLKW x40
newAnimal
    .BLKW x40
newQuestion
    .BLKW x40
; ##### END DATA BLOCK #####

START_GUESSING_RELAY0
    BRnzp START_GUESSING_RELAY1

END_SAVE_NEW_ANIMAL
    AND R0, R0, x0
    STR R0, R2, x0


    ; Prompt the user to enter a new question
    LEA R0, questionPrompt1
    PUTS
    LEA R0, newAnimal
    PUTS
    LEA R0, questionPrompt2
    PUTS
    LEA R0, oldAnimal
    PUTS
    LEA R0, questionPrompt3
    PUTS

    ; R3 is still x-A, so it doesn't have to be reset
    LEA R2, newQuestion
SAVE_QUESTION
    GETC
    OUT
    ADD R4, R0, R3
    BRz END_SAVE_QUESTION
    STR R0, R2, x0
    ADD R2, R2, x1
    BRnzp SAVE_QUESTION
END_SAVE_QUESTION
    AND R0, R0, x0
    ADD R0, R0, xF
    ADD R0, R0, xF
    ADD R0, R0, x2
    STR R0, R2, x0
    AND R0, R0, x0
    STR R0, R2, x1

    ; Compute the locations of the new yes and no nodes
    LD R0, openNode
    STR R0, R1, x1
    LD R2, newNodeSpacing
    ADD R0, R0, R2
    STR R0, R1, x2

    ; Mark that this node is now a question
    AND R0, R0, x0
    ADD R0, R0, x1
    STR R0, R1, x0

    ; Copy the question into the node
    LEA R0, newQuestion
    ADD R2, R1, x3

COPY_NEW_QUESTION
    LDR R3, R0, x0
    STR R3, R2, x0
    ADD R0, R0, x1
    ADD R2, R2, x1
    ADD R3, R3, x0
    BRnp COPY_NEW_QUESTION

    ; Create the new 'yes' node

    ; Get the address to put it at
    LDR R0, R1, x1

    ; Mark that it is a tree-end node
    AND R2, R2, x0
    STR R2, R0, x0

    LEA R2, newAnimal
    ADD R3, R0, x3
    ; Copy the name of the new animal
COPY_NEW_ANIMAL
    LDR R4, R2, x0
    STR R4, R3, x0
    ADD R2, R2, x1
    ADD R3, R3, x1
    ADD R4, R4, x0
    BRnp COPY_NEW_ANIMAL

    ; Create the new 'no' node

    ; Get the address to put it at
    LDR R0, R1, x2

    ; Mark that it is a tree-end node
    AND R2, R2, x0
    STR R2, R0, x0

    LEA R2, oldAnimal
    ADD R3, R0, x3
    ; Copy the name of the new animal
COPY_OLD_ANIMAL
    LDR R4, R2, x0
    STR R4, R3, x0
    ADD R2, R2, x1
    ADD R3, R3, x1
    ADD R4, R4, x0
    BRnp COPY_OLD_ANIMAL

    ; Update the Address of the first open node
    LEA R0, openNode
    LD R1, openNode
    LD R2, newNodeSpacing
    ADD R1, R1, R2
    ADD R1, R1, R2
    STR R1, R0, x0

    LEA R0, playAgain
    PUTS

    ; Start a new game
    BRnzp START_GUESSING_RELAY0


; ##### DATA BLOCK #####
; Slots for variables
openNode
    .FILL x34C0
maxStringLength
    .FILL x3C
newNodeSpacing
    .FILL x0040

questionPrompt1
    .STRINGZ "Please enter a yes/no question that would distinguish a "
questionPrompt2
    .STRINGZ " from a "
questionPrompt3
    .STRINGZ " (please word the question so that the answer for the new animal will be yes): "

playAgain
    .STRINGZ "Thank you! Let's play again. "
; ##### END DATA BLOCK #####
    .END