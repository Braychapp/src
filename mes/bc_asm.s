@
@FILE : bc_asm.s
@PROJECT : A3 Blinking Lights
@PROGRAMMER : Brayden Chapple
@FIRST VERSION : 2022-11-11
@DESCRIPTION : This program was created to run a game where the user needs to press a specific light when it is turned on
@if the user wins the lights will all flicker twice and if they lose the target light will stay on.
@


@ Test code for my own new function called from C
@ This is a comment. Anything after an @ symbol is ignored.
@@ This is also a comment. Some people use double @@ symbols.
.code 16 @ This directive selects the instruction set being generated.
@ The value 16 selects Thumb, with the value 32 selecting ARM.
.text @ Tell the assembler that the upcoming section is to be considered
@ assembly language instructions - Code section (text -> ROM)
@@ Function Header Block
.align 2 @ Code alignment - 2^n alignment (n=2)
@ This causes the assembler to use 4 byte alignment
.syntax unified @ Sets the instruction set to the new unified ARM + THUMB
@ instructions. The default is divided (separate instruction sets)
.global add_test @ Make the symbol name for the function visible to the linker
.code 16 @ 16bit THUMB code (BOTH .code and .thumb_func are required)
.thumb_func @ Specifies that the following symbol is the name of a THUMB
@ encoded function. Necessary for interlinking between ARM and THUMB code.
.type add_test, %function @ Declares that the symbol is a function (not strictly required)
@ Function Declaration : int add_test(int x, int y)
@
@ Input: r0, r1 (i.e. r0 holds x, r1 holds y)
@ Returns: r0
@r
@
@ Here is the actual add_test function
add_test:
push {r4, r6, r7, lr} @preserve r4 and r6 and lr

add r0, r0, r1 @adding r0 and r1 and storing it in r0

mov r6, r0 @moving r0 to r4

mov r7, r3 @move the value of r3 into r7 to be restored after the led toggle messes up all my registers

mov r0, #1 @storing a constant into r0

bl BSP_LED_Toggle @toggling a light with index 1

bl busy_delay

mov r3, r7 @restoring r3 to be 10

bl blink_led

mov r0, r6 @moving the original value of the sum back to r0 to be returned

pop {r4, r6, r7, lr} @popping r4 and r6 and lr
@put stuff back to how you found it right before you leave

bx lr @ Return (Branch eXchange) to the address in the link register (lr)

.size add_test, .-add_test @@ - symbol size (not strictly required, but makes the debugger happy)
@ Assembly file ended by single .end directive on its own line

@ Function Declaration : int busy_delay(int cycles)
@
@ Input: r0 (i.e. r0 holds number of cycles to delay)
@ Returns: r0
@
@ Here is the actual function. DO NOT MODIFY THIS FUNCTION.
busy_delay:
push {r0, r5} @pushing register 5
mov r5, r0 @moving the value within r0 to r5
delay_1oop:
    subs r5, r5, #1
    bge delay_1oop
mov r0, #0 @ Return zero (success)
pop {r0, r5} @popping off r5
bx lr @ Return (Branch eXchange) to the address in the link register (lr

@ Function Declaration : int busy_delay(int cycles)
@
@ Input: r0, r3 
@ Returns: r0, r3
@
blink_led:
push {r0, r3, r5, r7, lr}
mov r3, #0 @move the value 0 into r3
start_loop:
cmp r3, r7 @compare r3 to r7
bge end_loop 
    mov r0, #1 @r0 always gets messed up in BSP_LED_Toggle so i will keep making it 1 every loop
    mov r5, r3 @move r3 into r5 so it doesn't get messed up in BSP_LED_Toggle
    bl BSP_LED_Toggle @toggling a light with index 1
    mov r3, r5 @bring r3 original value back
    add r3, r3, #1
    b start_loop @branch back to the beginning of the loop
end_loop:
    pop {r0, r3, r5, r7, lr}
    bx lr





@ Test code for my own new function called from C
@ This is a comment. Anything after an @ symbol is ignored.
@@ This is also a comment. Some people use double @@ symbols.
.code 16 @ This directive selects the instruction set being generated.
@ The value 16 selects Thumb, with the value 32 selecting ARM.
.text @ Tell the assembler that the upcoming section is to be considered
@ assembly language instructions - Code section (text -> ROM)
@@ Function Header Block
.align 2 @ Code alignment - 2^n alignment (n=2)
@ This causes the assembler to use 4 byte alignment
.syntax unified @ Sets the instruction set to the new unified ARM + THUMB
@ instructions. The default is divided (separate instruction sets)
.global bc_led_demo_a2 @ Make the symbol name for the function visible to the linker
.code 16 @ 16bit THUMB code (BOTH .code and .thumb_func are required)
.thumb_func @ Specifies that the following symbol is the name of a THUMB
@ encoded function. Necessary for interlinking between ARM and THUMB code.
.type bc_led_demo_a2, %function @ Declares that the symbol is a function (not strictly required)
@ Function Declaration : int bc_led_demo_a2(int x, int y)


@
@Function: bc_led_demo_a2
@Description: This function is mostly used to push the registers that I will be using in led_delay
@then it calls led_delay
@Parameters: none
@Returns: nothing
@
bc_led_demo_a2:
@r0 is count and r1 is delay
push {r0-r7, lr} @pushing all available registers because I don't know what I'll end up using

bl led_delay

@
@Function: led_delay
@Description: This function is essentially my main(), where my program is going to run from once it is called from the minicom window.
@it turns on and off all the lights on the board one after another as many times as the user wants and as fast as the user wants
@Parameters: none
@Returns: nothing
@
led_delay:
    mov r2, #0 @r2 is used to see if an led is on or off, if it's an even number the led should be off and if it's odd it should be on
    mov r3, r1 @moving the delay value to r4
    mov r4, r1 @moving the delay value to r4 for use later when resetting the loop
    mov r5, r0 @moving count into r5
    mov r6, #0 @r6 is going to keep track of how many times we have gone through a complete cycle
    mov r7, #0 @r7 is going to hold which led is supposed to be toggled
    bl first_light @turning the light on to start
    led_1oop: @repeat r5 times
        subs r3, r3, #1
        bge led_1oop
        @loop over
    @if r6 is greater than r5
    add r2, r2, #1
    cmp r7, #8
        beq else1
    mov r0, r7 @update the led to be toggled
    bl BSP_LED_Toggle @calling BSP_LED_Toggle
    mov r3, r4 @moving the delay back into r3 for another loop
    @need to put an if statement inside an if statement here
    cmp r2, #2
        bge else2
    mov r0, r7 @make r0 the original number again 
    bl led_1oop @if the led is toggled on and hasnt been turned off its going to loop again

@used for switching which led is toggled

@
@Function: else2
@Description: This function is used for switching which led is going to be toggled next
@Parameters: none
@Returns: nothing
@
else2:
    add r7, r7, #1 @change which led is being toggled
    mov r2, #0 @move the status of the LED back to being off
    cmp r7, #8 @comparing again to try and avoid unnessecary loops
        beq else1
    bl led_1oop @going back to loop again

@used for adding to the total times that the program has looped

@
@Function: else1
@Description: This function is used to add the total times that the program has ran through one cycle
@then it loops from the beginning again
@Parameters: none
@Returns: nothing
@
else1:
    add r6, r6, #1 @the program has officially looped and r6 needs to be updated to reflect that
    mov r7, #0 @resetting the number incase there is more than one cycle
    @need to put an if statement to check if the count is the same as the one that the user entered
    bl else3 @going back to the loop

@
@Function: else3
@Description: This function is the third else statement to pair with my if statements that I have used in the program
@it compared r6 to r5 and if they are equal it will exit and if not it will go back and loop from the beginning again
@Parameters: none
@Returns: nothing
@
else3:
    cmp r6, r5 @compare r6 to r5
        beq exit @if theyre equal go to exit
    mov r2, #0 @if theyre not then make r2 0
    bl led_1oop @go back to the loop

@
@Function: exit
@Description: This function is used when the program has finished looping and running through itself.
@it pops all the registers to how they were before entering the main looping function
@Parameters: none
@Returns: nothing
@
exit:
    pop {r0-r7, lr} @popping off everything
    bx lr @ Return (Branch eXchange) to the address in the link register (lr


@
@Function: first_light
@Description: This function is used only for the first turning on of light 0 on the board
@Parameters: none
@Returns: nothing
@
first_light:
    mov r0, r7 @making r0 the same as r7
    bl BSP_LED_Toggle @toggling the light
    add r2, r2, #1 @adding 1 to r2 to tell the program that the light is on
    mov r3, r4
    bl led_1oop @going back to the loop


.size bc_led_demo_a2, .-bc_led_demo_a2 @@ - symbol size (not strictly required, but makes the debugger happy)




@ Test code for my own new function called from C
@ This is a comment. Anything after an @ symbol is ignored.
@@ This is also a comment. Some people use double @@ symbols.
.code 16 @ This directive selects the instruction set being generated.
@ The value 16 selects Thumb, with the value 32 selecting ARM.
.text @ Tell the assembler that the upcoming section is to be considered
@ assembly language instructions - Code section (text -> ROM)
@@ Function Header Block
.align 2 @ Code alignment - 2^n alignment (n=2)
@ This causes the assembler to use 4 byte alignment
.syntax unified @ Sets the instruction set to the new unified ARM + THUMB
@ instructions. The default is divided (separate instruction sets)
.global get_string @ Make the symbol name for the function visible to the linker
.code 16 @ 16bit THUMB code (BOTH .code and .thumb_func are required)
.thumb_func @ Specifies that the following symbol is the name of a THUMB
@ encoded function. Necessary for interlinking between ARM and THUMB code.
.type get_string, %function @ Declares that the symbol is a function (not strictly required)
@ Function Declaration : int bc_led_demo_a2(int x, int y)
get_string:
    push {lr}
    mov r1, #0 @setting up index
    @string lives in r0

    
    @ldrb only loads the byte being pointed to not the entire string

    @load a byte into a target register, the byte is going to be at a base address plus an offset
    @use the ASCII table
    @you know you're at the end of the string if you get to 0 because the ASCII value for null is #0

    @cmp the value to 0

    @if 0 then branch out of the loop

    @if not 0 then do other stuff
    @turn the ascii value into something
    @bl iterateLoop

    @iterateLoop:
    @{
        ldrb r1, [r0] @dereference the character that r0 points to
        @puts the byte that was in r0 into r1

        mov r0, r1 @move the ascii value back into r0 maybe?
        pop {lr}
        bx lr        
    @}

.size get_string, .-get_string @@ - symbol size (not strictly required, but makes the debugger happy)






@ Test code for my own new function called from C
@ This is a comment. Anything after an @ symbol is ignored.
@@ This is also a comment. Some people use double @@ symbols.
.code 16 @ This directive selects the instruction set being generated.
@ The value 16 selects Thumb, with the value 32 selecting ARM.
.text @ Tell the assembler that the upcoming section is to be considered
@ assembly language instructions - Code section (text -> ROM)
@@ Function Header Block
.align 2 @ Code alignment - 2^n alignment (n=2)
@ This causes the assembler to use 4 byte alignment
.syntax unified @ Sets the instruction set to the new unified ARM + THUMB
@ instructions. The default is divided (separate instruction sets)
.global bc_Game @ Make the symbol name for the function visible to the linker
.code 16 @ 16bit THUMB code (BOTH .code and .thumb_func are required)
.thumb_func @ Specifies that the following symbol is the name of a THUMB
@ encoded function. Necessary for interlinking between ARM and THUMB code.
.type bc_Game, %function @ Declares that the symbol is a function (not strictly required)


@ Function Declaration : int bc_Game(int delay, char * pattern, int target)
@
@ Input: r0, r1, r2 (r0 holds delay, r1 holds the pattern, and r2 holds the target light)
@ Returns: nothing
@r
@
@ Here is the actual add_test function
bc_Game:
    @this function gets input from the program at r0 r1 and r2 so I need to do something with all of those values
    push {r0-r9, lr}
    @lets first get the pattern becasue it is arguably the most inportant
    mov r4, r1 @loading the whole string into r4
    mov r5, r0 @moving delay into r5 for use later
    mov r6, r2 @moving the winning number into r6 for us later
    @since r2 is not used currently I will use it to turn off all the lights
    mov r2, #7 @7 for the amount of leds on the board



    mov r3, #1000 @for some reason I can't just multiply r5 by 1000 so I needed to put that number somewhere that hadn't been touched by the input from C
    @after this line r3 being 1000 does not matter and is not needed

    mul r5, r5, r3 @getting the delay to be larger, ie original delay = 500, and the new delay is 500,000
    mov r7, r5 @moving the delay into a safer register that will only be used to replenish the delay after the loops
    mov r2, #0 @make sure r2 is 0 because it is now going to be used for the index of the string
        mov r9, #0 @make r9 0
    bl all_off_loop
    
@
@Function: all_off_loop
@Description: This loop is called at the beginning of the program to ensure all lights are starting turned off
@Parameters: none
@Returns: nothing
@
all_off_loop:
    mov r0, r2
    bl BSP_LED_Off
    subs r2, #1
    bge first_light

@
@Function: pattern_loop
@Description: This loop is the big loop for my entire program, this loop is the poll that will wait constantly for the button to be pressed
@and if its pressed it will see if the user wins or loses, it also turns on and off the lights in the order that is specified by the user
@Parameters: none
@Returns: nothing
@
pattern_loop:
    @loop while delay > 0
    mov r0, #0 @make sure r0 is 0 before calling get state
    bl BSP_PB_GetState @comparing the button to 1
    cmp r0, #1
    beq win_or_lose
    subs r5, r5, #1 @subtract one from r5 every time    
    bge pattern_loop @looping

@when done looping
    b toggle_light


@
@Function: toggle_light
@Description: This function toggles a light based on the pattern supplied by the user
@Parameters: none
@Returns: nothing
@
toggle_light:
@this function is going to toggle the light that is currently turned on
    ldrb r8, [r4, r2] @loading r8 with the ascii character that is at r3 of the string r4
    @going to check if r8 is null
    @make an if statement to check if r8 is 0 because it shouldn't ever be unles the string has reached the end
    @if it has reached the end the function is goint o be called again after the index has been reset
    cmp r8, #0 @if r8 == 0
    beq reset_iterator
    @if r8 is not == 8
    @need to use a variable to demonstrate if the loop has currently gone through and the light is on still
    @ill use r9 for now    
    add r9, r9, #1 @add 1 into r9

    subs r8, r8, 48 @subtracting 48 from r8 to get the actual integer value instead of the ascii value
    mov r0, r8 @move r8 into r0 to be used when calling BSP_LED_TOGGLE
    bl BSP_LED_Toggle @turn on the light that r0 is equal to
    mov r5, r7 @move r7 into r5 to loop again
    cmp r9, #2 @if r9 is 2
    bge update_iterator @go to update the iterator if r9 is 2 meaning this is the second loop through

    bl pattern_loop @go back into the loop


@
@Function: toggle_light_first
@Description: This function toggles the first light on when the program just started
@Parameters: none
@Returns: nothing
@
toggle_light_first:
@this function is just for the first instance of turning on the light
    ldrb r8, [r4, r2] @loading r8 with the ascii character that is at r3 of the string r4
    add r9, r9, #1 @add 1 into r9
    subs r8, r8, 48 @subtracting 48 from r8 to get the actual integer value instead of the ascii value
    mov r0, r8 @move r8 into r0 to be used when calling BSP_LED_TOGGLE
    bl BSP_LED_Toggle @turn on the light that r0 is equal to
    bl pattern_loop @go back into the loop


@
@Function: reset_iterator
@Description: This function resets the register that has been used to iterate through the string passed by the user
@Parameters: none
@Returns: nothing
@
reset_iterator:
    mov r2, #0 @resetting r2 to be 0
    bl toggle_light @going back to try again now that the index is reset


@
@Function: update_iterator
@Description: This function is used to updat the iterator to be the next item in the string that has been passed in
@Parameters: none
@Returns: nothing
@
update_iterator:
    add r2, r2, #1 @increment the index
    mov r9, #0 @put 0 back into r9
    @we need to reset the dealy and then go back to the loop from here
    mov r5, r7 @move delay back
    bl pattern_loop @going back to loop again


@
@Function: win_or_lose
@Description: This function is used to tell whether the user has won or has lost through comparing r6 (target) and r8 (current light)
@Parameters: none
@Returns: nothing
@
win_or_lose:
@this function is going to check if the user pressed the button at the right time
    mov r4, #3 @used for if the player wins
    @need to turn off the curent light that is on
    mov r0, r8 @getting the led thats currently on
    @need to see if the led is currently on or not
    cmp r9, #1 @if the light is currently turned on it will turn it off
    beq final_toggle
    cmp r6, r8 @comparing the target button to the current light that is active
    beq winner @if they are the same then the user wins and if theyre not then they lose
    @if its not the same then they lose
    bl loser @branch to the losing function

@
@Function: final_toggle
@Description: This function turns off the light if the usr happened to press the button while the light was still on
@Parameters: none
@Returns: nothing
@
final_toggle:
    bl BSP_LED_Toggle
    mov r9, #0 @signifying the led is off
    bl win_or_lose

@
@Function: winner
@Description: This function is called if the player has won the game, it calls upon another function winner_loop to go through all the lights and make sure they are 
@turned on together and off together
@Parameters: none
@Returns: nothing
@
winner:
    @this function needs to turn on all lights twice then bx lr
    @this is the end of the program so the registers values are not important any more seeing as most of them will not be touched any more
    @I want to try looping the led toggle inside of here so I'll make a winner loop 
    mov r5, r7 @moving the delay back to r5 for use inside winner_delay
    mov r6, #7 @r6 holds the amount of leds on the board and the amount of times the program is going to loop (counting 0 as a light)

    bl winner_loop


@
@Function: winner_delay
@Description: This function is used to delay the time where the lights are blinked on and off if the user has won
@Parameters: none
@Returns: nothing
@
winner_delay:
    subs r5, r5, #1 @subtracting 1 every time it loops
    bge winner_delay

    @if the loop is over
    bl winner @go back to winner

@
@Function: winner_loop
@Description: This loop will loop through all the lights on the board and turn them all on, if the program is done looping through it will exit
@Parameters: none
@Returns: nothing
@
winner_loop:
    mov r0, r6 @move the led into r0
    bl BSP_LED_Toggle @toggling led
    subs r6, #1 @taking 1 away from the loop total
    bge winner_loop

    @if the loop is over
    subs r4, #1
    bge winner_delay @going back because we need to blink the lights twice

    @if all the lights have been turned on and off twice
    pop {r0-r9, lr}
    bx lr @return


@
@Function: loser
@Description: This function is called if the user loses, it turns on the light that was supposed to be pressed and it stays on then it will exit
@Parameters: none
@Returns: nothing
@
loser:
    @this function turns on the led that was the target
    mov r0, r6 @moving the target into r0 to be turned on
    bl BSP_LED_Toggle
    pop {r0-r9, lr}
    bx lr @return
.size bc_Game, .-bc_Game @@ - symbol size (not strictly required, but makes the debugger happy)



@ Test code for my own new function called from C
@ This is a comment. Anything after an @ symbol is ignored.
@@ This is also a comment. Some people use double @@ symbols.
.code 16 @ This directive selects the instruction set being generated.
@ The value 16 selects Thumb, with the value 32 selecting ARM.
.text @ Tell the assembler that the upcoming section is to be considered
@ assembly language instructions - Code section (text -> ROM)
@@ Function Header Block
.align 2 @ Code alignment - 2^n alignment (n=2)
@ This causes the assembler to use 4 byte alignment
.syntax unified @ Sets the instruction set to the new unified ARM + THUMB
@ instructions. The default is divided (separate instruction sets)
.global accel_test @ Make the symbol name for the function visible to the linker
.code 16 @ 16bit THUMB code (BOTH .code and .thumb_func are required)
.thumb_func @ Specifies that the following symbol is the name of a THUMB
@ encoded function. Necessary for interlinking between ARM and THUMB code.
.type accel_test, %function @ Declares that the symbol is a function (not strictly required)

@define constants
.equ I2C_Address, 0x32
.equ X_LO, 0x28
.equ X_HI, 0x29

.equ Y_HI, 0x2B
.equ READ_DELAY, 0xFFFFF


@ Function Declaration : int accel_test()
@
@ Input: r0 (i.e. r0 holds an integer for which accelerometer value to read)
@ Returns: r0 - current accelerometer value
@r
@
@ Here is the actual add_test function

@ LIGHTS ON THE BOARD
@ (-X, +Y)          0           (+X, -Y)
@
@           1               2   
@
@       3                       4
@
@           5               6
@
@ (-X, -Y)          7           (+X, -Y)


accel_test:
    push {lr}

    ldr r0, =READ_DELAY
    bl busy_delay
    
    mov r0, #I2C_Address
    mov r1, #Y_HI @reads the Y value at high order
    bl COMPASSACCELERO_IO_Read @called to read the accelerometer value
    
    sxtb r0, r0 @turn 8 bit value into 32 bit value

    @at this point r0 holds a useful value in the range of -128 to +127 represnting the tilt on the axis read

    pop {lr}
    bx lr @ Return (Branch eXchange) to the address in the link register (lr)

.size accel_test, .-accel_test @@ - symbol size (not strictly required, but makes the debugger happy)
@ Assembly file ended by single .end directive on its own line


@ Test code for my own new function called from C
@ This is a comment. Anything after an @ symbol is ignored.
@@ This is also a comment. Some people use double @@ symbols.
.code 16 @ This directive selects the instruction set being generated.
@ The value 16 selects Thumb, with the value 32 selecting ARM.
.text @ Tell the assembler that the upcoming section is to be considered
@ assembly language instructions - Code section (text -> ROM)
@@ Function Header Block
.align 2 @ Code alignment - 2^n alignment (n=2)
@ This causes the assembler to use 4 byte alignment
.syntax unified @ Sets the instruction set to the new unified ARM + THUMBx
@ instructions. The default is divided (separate instruction sets)
.global bc_tilt @ Make the symbol name for the function visible to the linker
.code 16 @ 16bit THUMB code (BOTH .code and .thumb_func are required)
.thumb_func @ Specifies that the following symbol is the name of a THUMB
@ encoded function. Necessary for interlinking between ARM and THUMB code.
.type bc_tilt, %function @ Declares that the symbol is a function (not strictly required)

.equ TIME_MULTIPLIER, 0x3E8 @if someone sends in 30 it needs to be 30000
GAME_TIME: .word 0 @creating a game time variable
TARGET: .word 0 @creating a target variable
TARGET_TIME: .word 0 @creating a target time variable
.equ WIN_DELAY, 0x7A120 @500000 in hex for the blinking of the lights if the player wins
X_VAL: .word 0 @creating a variable for the X value
Y_VAL: .word 0 @creating a variable for the Y value
CURRENT_LED: .word 0 @creating a variable to hold the currently turned on light
PREVIOUS_LED: .word 0 @creating a varibale for the previous LED to be on
@this will be getting called from C but we want to call it from the system tick handler

@ Function Declaration : int bc_tilt()
@
@ Input: r0, r1, r2 (r0 is an int with a delay, r1 is the target light, r2 is how long the game is played for)
@ Returns: r0 - how long the user is supposed to hold the correct light on for
@
@
@
@Function: bc_tilt
@Description: This function changes the values of memory addresses to be used within the system tick handler
@Parameters: (int delay, int target, int game_time)
@Returns: r0 - the delay variable
@
bc_tilt:
@start of function
@r0 is the delay r1 is the target r2 is the game duration
    push {r4, lr}

    @going to use r4 for the address of stuff
    ldr r4, =TARGET_TIME
    str r0, [r4] @loading target time with the delay passed in by the user
    ldr r4, =TARGET
    str r1, [r4] @loading the target variable with the target LED
    mov r4, #TIME_MULTIPLIER @moving time multiplier into r4
    mul r4, r2, r4 @multiplying the game time to be in the 10 thousands of ticks
    ldr r2, =GAME_TIME
    str r4, [r2] @moving the now ready time into game time


    @mov r4, r0 @get the delay into a register that won't be touched by other functions
    @mov r5, r1 @move the target to a register 
    @mov r6, #TIME_MULTIPLIER @move the multipler into r6 to be used
    @mul r6, r2, r6 @multiply the game time to be the correct duration

    @r4 holds the time the user needs to keep the target light on for
    @r5 holds the target light
    @r6 holds the total game time

    pop {r4, lr}
    bx lr


.size bc_tile, .-bc_tilt @@ - symbol size (not strictly required, but makes the debugger happy)

@
@Function: bc_tick
@Description: This function is run within the system tick handler to play the accelerometer game
@Parameters: none
@Returns: nothing
@
bc_tick:

    push {lr}
    ldr r1, =GAME_TIME
    ldr r0, [r1] @loading r1 into r0
    subs r0, r0, 1 @subtracting 1 from r0 and if its 0 sent the negative flag

    @if ticks hit 0 stop doing stuff
    ble game_lose

    @if above 0 store the result back and do stuff or tick another value
    str r0, [r1]

    bgt do_nothing @do nothing if we have not hit 0

    @call the function to check values of X and Y for the board
    mov r0, #I2C_Address
    mov r1, #X_HI @getting the X value first
    bl COMPASSACCELERO_IO_Read @call to read accelerometer value for X
    sxtb r0, r0 @turn the 8 bit into a 32 bit for use

    ldr r2, =X_VAL @ getting X address
    str r0, [r2] @putting the value into X_VAL

    @now onto getting the Y value
    mov r0, #I2C_Address
    mov r1, #Y_HI @getting the Y value second
    bl COMPASSACCELERO_IO_Read
    sxtb r0, r0 @turning the 8 bit into 32 bit

    ldr r2, =Y_VAL @getting Y address 
    str r0, [r2] @storing the value

    @right about here we probably call the function to check the value of the accelerometer and return it as a workable

    bl accel_to_LED @the r0 value exiting this function should be between 0 and 7
    @value for an led between 0 and 7 and if its the same as the target then we would decrement the target led
    ldr r2, =CURRENT_LED
    ldr r1, [r2]
    

    @call function to decrement the winning time
    cmp r0, r1 @Compare the currently turned on LED to the LED returned from accel_to_LED
    beq CORRECT_LED @if the light is the correct one we go into this function to decrement how long the timer needs to be held for

    @if the led currently on is WRONG we go into a different function
    bl WRONG_LED
    @if by now we don't hit 0 then we do nothing
    

    


@function to convert the accel values into whatever light  on the board
@
@Function: accel_to_LED
@Description: This function converts the X and Y values recieved by the accelerometer into a number from 0-7 
@to be used with the lights on the board
@Parameters: none
@Returns: nothing
@
accel_to_LED:
 @inputs arrive in r0 and r1
 @if x is positive output will be 2, 4, or 6
 @if x is negative output will be 1, 3, or 5

 @if Y is positive output will be 0, 1, or 2
 @if Y is negative output will be 5, 6, or 7


@LEDS CURRENTLY USED 0 1 2 3 4 5 6 7
    push {lr}


    ldr r0, =X_VAL @load the X value into r0

    ldr r1, =Y_VAL @load the Y value into r1


    cmp r0, #0 @compare r0 to 0
    ble X_NEGATIVE @if X is less than or equal to 0 it goes into X_NEGATIVE    
    @if it gets past this line that means that X is positive

    cmp r1, #0 @compare Y to 0
    ble Y_NEGATIVE @ if Y is below 0 then we go to Y_NEGATIVE

    mov r0, #2 @return LED 2


    X_NEGATIVE:
        cmp r0, #0 @need to compare X to 0 again
        beq X_IS_ZERO @checking if X is 0 and if it is we go to X_IS_ZERO

        cmp r1, #0 @compare Y to 0
        ble X_NEGATIVE_Y_NEGATIVE @if X and Y are both negative but NOT 0 brach to X_NEGATIVE_Y_NEGATIVE

        mov r0, #1 @returning LED 1

        X_NEGATIVE_Y_NEGATIVE:
            cmp r1, #0 @checking if Y is 0
            beq X_NEGATIVE_Y_IS_ZERO @if X is negative and Y is 0 brahcn to X_NEGATIVE_Y_IS_ZERO

            mov r0, #5 @returning LED 5


        X_IS_ZERO:
        @if it gets to here we know X is 0
            cmp r1, #0 @comparing Y to 0
            ble X_IS_ZERO_Y_NEGATIVE

            mov r0, #0 @returning LED 0


        X_IS_ZERO_Y_NEGATIVE:
            mov r0, #7 @returning LED 7


        X_NEGATIVE_Y_IS_ZERO:
            mov r0, #3 @returning LED 3
            

    Y_NEGATIVE:
        cmp r1, #0 @compare Y to 0 again
        beq Y_IS_ZERO @if Y is 0 branch to Y_IS_ZERO

        mov r0, #6 @return LED 6


        Y_IS_ZERO:
            mov r0, #4 @return LED 4
    @start by checking if



    pop {lr}
    bx lr

.size accel_to_LED, .-accel_to_LED

@
@Function: CORRECT_LED
@Description: This function is used to decrement the total time the user has held the light on the winning number for
@Parameters: none
@Returns: nothing
@
CORRECT_LED:
    push {r4, lr}
    @turn off the old led first
    ldr r2, =PREVIOUS_LED
    ldr r0, [r2]
    bl BSP_LED_Off @turning off the old LED
    @then turn on the new one
    mov r4, r0
    bl BSP_LED_On @r0 should still be whatever it was returned from the accel_to_LED function
    ldr r1, =TARGET_TIME @loading r1 with the target
    ldr r0, [r1]
    subs r0, r0, #1 @subtracting 1 from the target timer
    ble game_win

    mov r0, r4
    @these lines deal with manipulating the most recent LED to be turned on
    ldr r1, =CURRENT_LED
    ldr r2, =PREVIOUS_LED
    ldr r0, [r1]
    str r0, [r2]


    pop {r4, lr}
    bx lr

    .size CORRECT_LED, .-CORRECT_LED


@
@Function: WRONG_LED
@Description: This function is used to change the LED that is currently on and NOT decrement the winning time 
@because this is the wrong light
@Parameters: none
@Returns: nothing
@
WRONG_LED:
    push {r4, lr}
    @old light must be turned off first
    ldr r2, =PREVIOUS_LED
    ldr r0, [r2]
    bl BSP_LED_Off @turning off the old LED

    mov r4, r0
    bl BSP_LED_On @r0 should still be whatever it was returned from the accel_to_LED function
    @these lines deal with manipulating the most recent LED to be turned on
    ldr r1, =CURRENT_LED
    ldr r2, =PREVIOUS_LED
    mov r0, r4
    ldr r0, [r1]
    str r0, [r2]
    pop {r4, lr}

@
@Function: game_lose
@Description: This function is used to tell the user that they have lost the game by toggling on the target light then just leaving it there
@Parameters: none
@Returns: nothing
@
game_lose:
@empty function currently
    ldr r1, =CURRENT_LED
    ldr r0, [r1]
    @turn off whatever light is still on
    bl BSP_LED_Off

    ldr r1, =TARGET
    ldr r0, [r1] @assigning r0 to be the target to stay on
    bl BSP_LED_On

    bx lr 


@
@Function: game_win
@Description: This function is used to blink on and off all the LEDs twice to indicate that the user has won the game
@Parameters: none
@Returns: nothing
@
game_win:
    push {r4, r5, lr}
    mov r4, #7 @7 for how many lights
    mov r5, #4 @runs through 4 times

    toggle_loop:
    @runs 4 times
    @ldr r1, TARGET_TIME @the delay variable passed in at the start of the game
    @ldr r0, [r1]
    @bl busy_delay @delaying the blinking
    mov r0, r4
    bl BSP_LED_Toggle
    subs r4, r4, #1 @take one away from r4
    ble win_loop

    win_loop: 
    ldr r1, TARGET_TIME @the delay variable passed in at the start of the game
    ldr r0, [r1]
    bl busy_delay @delaying the blinking
    subs r5, r5, #1
    ble toggle_loop @go back to toggle the lights if r5 isn't 0

    @if it is 0
    pop {r4, r5, lr}
    bx lr @return
@
@Function: do_nothing
@Description: This function does nothing
@Parameters: none
@Returns: nothing
@
do_nothing:
    pop {lr}
    bx lr


.code 16 @ This directive selects the instruction set being generated.
@ The value 16 selects Thumb, with the value 32 selecting ARM.
.text @ Tell the assembler that the upcoming section is to be considered
@ assembly language instructions - Code section (text -> ROM)
@@ Function Header Block
.align 2 @ Code alignment - 2^n alignment (n=2)
@ This causes the assembler to use 4 byte alignment
.syntax unified @ Sets the instruction set to the new unified ARM + THUMB
@ instructions. The default is divided (separate instruction sets)
.global lab8 @ Make the symbol name for the function visible to the linker
.code 16 @ 16bit THUMB code (BOTH .code and .thumb_func are required)
.thumb_func @ Specifies that the following symbol is the name of a THUMB
@ encoded function. Necessary for interlinking between ARM and THUMB code.
.type lab8, %function @ Declares that the symbol is a function (not strictly required)

lab8:
push {lr}
    @ This code turns on only one light – can you make it turn them all on at once?
    ldr r1, =LEDaddress @ Load the GPIO address we need
    ldr r1, [r1] @ Dereference r1 to get the value we want
    ldrh r0, [r1] @ Get the current state of that GPIO (half word only)
    orr r0, r0, #0x0100 @ Use bitwise OR (ORR) to set the bit at 0x0100
    strh r0, [r1] @ Write the half word back to the memory address for the GPIO
    pop {lr}
    bx lr
LEDaddress:
.word 0x48001014

.code 16 @ This directive selects the instruction set being generated.
@ The value 16 selects Thumb, with the value 32 selecting ARM.
.text @ Tell the assembler that the upcoming section is to be considered
@ assembly language instructions - Code section (text -> ROM)
@@ Function Header Block
.align 2 @ Code alignment - 2^n alignment (n=2)
@ This causes the assembler to use 4 byte alignment
.syntax unified @ Sets the instruction set to the new unified ARM + THUMB
@ instructions. The default is divided (separate instruction sets)
.global _bc_a5_tick_handler @ Make the symbol name for the function visible to the linker
.code 16 @ 16bit THUMB code (BOTH .code and .thumb_func are required)
.thumb_func @ Specifies that the following symbol is the name of a THUMB
@ encoded function. Necessary for interlinking between ARM and THUMB code.
.type _bc_a5_tick_handler, %function @ Declares that the symbol is a function (not strictly required)

.data
a5_delay: .word 0 @creating a variable for the timeout
a5_timeout: .word 0 @creating a variable for the delay
current_delay: .word 0 @adding a variable to hold the current delay
watchdog_refresh: .word 0 @making this for easy refreshing later
is_button_pressed: .word 0 @if this is not 0 it means that the button was pressed

.text
_bc_a5_tick_handler:
    push {lr}
    
    ldr r2, =a5_timeout
    str r0, [r2] @storing r0 into a5_timeout
   
    ldr r2, =watchdog_refresh
    str r0, [r2] @storing the timeout here for easy refreshing

    ldr r0, [r2]

    ldr r2, =a5_delay
    str r1, [r2] @storing r1 into a5_delay
    
    @initializing the watchdog
    bl mes_InitIWDG @the timeout value should still be in r0

    @starting the watchdog
    bl mes_IWDGStart @this starts the watchdog
    @it is ok to be started here because the function in the system tick handler
    @will be called as soon as this hits bxlr
    pop {lr}

bx lr 

.size _bc_a5_tick_handler, .-_bc_a5_tick_handler


.code 16 @ This directive selects the instruction set being generated.
@ The value 16 selects Thumb, with the value 32 selecting ARM.
.text @ Tell the assembler that the upcoming section is to be considered
@ assembly language instructions - Code section (text -> ROM)
@@ Function Header Block
.align 2 @ Code alignment - 2^n alignment (n=2)
@ This causes the assembler to use 4 byte alignment
.syntax unified @ Sets the instruction set to the new unified ARM + THUMB
@ instructions. The default is divided (separate instruction sets)
.global _bc_a5_tick_check @ Make the symbol name for the function visible to the linker
.code 16 @ 16bit THUMB code (BOTH .code and .thumb_func are required)
.thumb_func @ Specifies that the following symbol is the name of a THUMB
@ encoded function. Necessary for interlinking between ARM and THUMB code.
.type _bc_a5_tick_check, %function @ Declares that the symbol is a function (not strictly required)

_bc_a5_tick_check:
    push {lr}

    @checking values to see if anything has been loaded into them

    ldr r2, =a5_timeout
    ldr r3, [r2]
    subs r3, r3, #1 @#take 1 away from r0

    @if it's 0 or less than 0 we do nothing
    ble do_nothing

    str r3, [r2] @storing the value back

      @getting the current delay value
    ldr r2, =current_delay
    ldr r3, [r2]
    subs r3, r3, #1

    @store decremented amount
    str r3, [r2]
    @if we haven't hit 0 do nothing
    bgt do_nothing

    bl refresh_watchdog

    bl mes_IWDGRefresh @refreshing the watchdog

 
    @if we have do something 
    bl toggle_all
    bl refresh_delay

    bl do_nothing   


.size _bc_a5_tick_check, .-_bc_a5_tick_check


toggle_all:
push {lr}
    mov r0, #0
    bl BSP_LED_Toggle
    mov r0, #1 
    bl BSP_LED_Toggle
    mov r0, #2
    bl BSP_LED_Toggle
    mov r0, #3
    bl BSP_LED_Toggle
    mov r0, #4
    bl BSP_LED_Toggle
    mov r0, #5
    bl BSP_LED_Toggle
    mov r0, #6
    bl BSP_LED_Toggle
    mov r0, #7
    bl BSP_LED_Toggle
pop {lr}
bx lr
.size toggle_all, .-toggle_all


refresh_delay:
    push {lr}
    @resetting the delay
    ldr r2, =a5_delay @make r2 equal to the memory address
    ldr r3, [r2]
    @right here r4 holds the delay

    ldr r2, =current_delay
    str r3, [r2]

    pop {lr}
bx lr
.size refresh_delay, .-refresh_delay


refresh_watchdog:
    push {lr}
    @resetting the watchdog
    ldr r2, =watchdog_refresh @make r2 equal to the memory address
    ldr r3, [r2]
    @right here r4 holds the delay

    ldr r2, =a5_timeout
    str r3, [r2]

    pop {lr}
    bx lr
.size refresh_watchdog, .-refresh_watchdog


.end