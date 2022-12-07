/*
* FILE : bc_hook.c
* PROJECT : A2 Calling Functions
* PROGRAMMER : Brayden Chapple
* FIRST VERSION : 2022-10-12
* DESCRIPTION : This program was created to turn on and off all the lights on the board as many times as the user wants at the speed the user wants
*/
#include <stdio.h>
#include <stdint.h>
#include <ctype.h>
#include "common.h"

void mes_InitIWDG(int refresh);
void mes_IWDGStart(void);
void mes_IWDGRefresh(void);
int _bc_a5_tick_handler(int timeout, int delay);








int add_test(int x, int y, uint32_t delay, int count);
void AddTest(int action)
{
if(action==CMD_SHORT_HELP) return;
if(action==CMD_LONG_HELP) {
printf("Addition Test\n\n"
"This command tests new addition function\n"
);
return;
}
//creating a variable of type uint32_t called delay and a regular int called fetch_status
uint32_t delay;
int fetch_status;
fetch_status = fetch_uint32_arg(&delay);
if(fetch_status) {
// Use a default delay value
delay = 0xFFFFFF;
}
// When we call our function, pass the delay value.
// printf(“<<< here is where we call add_test – can you add a third parameter? >>>”);
//r0 = 98
//r1 = 87
//r2 = 0xFFFFFF
//r3 = 20
//r3 needs to be 20 because to toggle on the LED is one and to turn it off is also 1 so each on / off counts for 2
printf("add_test returned: %d\n", add_test(98, 87, delay, 20));
}
ADD_CMD("add", AddTest,"Test the new add function");




int bc_led_demo_a2(int count, int delay);
/*
* Function: _bc_A2
* Description: This function is used to call the function from within my assembly code
* It also will
* Parameters: none
* Returns: nothing
*/
void _bc_A2(int action)
{
if(action==CMD_SHORT_HELP) return;
if(action==CMD_LONG_HELP) {
printf("LED DEMO\n\n"
"This command tests that I know hwo to turn on all the LEDS\n"
);
return;
}

uint32_t count;
int fetch_status2;
fetch_status2 = fetch_uint32_arg(&count);
if(fetch_status2) {
// Use a default value
count = 1;
}

uint32_t led_delay;
int fetch_status1;
fetch_status1 = fetch_uint32_arg(&led_delay);
if(fetch_status1) {
// Use a default value
led_delay = 0xFFFFFF;
}



printf("bc_led_demo_a2 has finished. Here is register 0:%d \n", bc_led_demo_a2(count, led_delay)); //0 is the counter and delay is the delay from the user
}
ADD_CMD("demo", _bc_A2, "Test the _bc_A2 function");

char * get_string(char *destptr);

void getString(int action)
{
    int fetch_status;
    char *destptr;
    fetch_status = fetch_string_arg(&destptr);

    if(fetch_status) {
        //default logic here
    }
    printf("get_string has been called and it has returned this: %s\n", get_string(destptr));
}
ADD_CMD("gets", getString, "This function should get a string and pass it into ARM assembly");


char * bc_Game(int delay, char * pattern, int target);

void bcGame(int action)
{

    uint32_t led_delay;
    int fetch_status1;
    fetch_status1 = fetch_uint32_arg(&led_delay);
    if(fetch_status1) {
    // Use a default value
    led_delay = 500;
    }   


    int fetch_status;
    char *destptr;
    fetch_status = fetch_string_arg(&destptr);

    if(fetch_status) {
        destptr = "01357642";
    }

    uint32_t target;
    int fetch_status2;
    fetch_status2 = fetch_uint32_arg(&target);
    if(fetch_status2) {
    target = 0;
    }
    printf("function has been called and it has returned this: %s\n", bc_Game(led_delay, destptr, target));
}
ADD_CMD("bcGame", bcGame, "This function should get a string and pass it into ARM assembly");


// int accel_test(int choice);

// void AccelerometerTest(int action)
// {
// if(action==CMD_SHORT_HELP) return;
// if(action==CMD_LONG_HELP) {
// printf("accelerometer test\n\n"
// "This command tests the accelerometer\n"
// );
// return;
// }
// //creating a variable of type uint32_t called delay and a regular int called fetch_status
// uint32_t user_input;
// int fetch_status;

// fetch_status = fetch_uint32_arg(&user_input);

// if(fetch_status) {
// // Use a default delay value
// user_input = 6;
// }

//     for(int i = 0; i < 100; i++)
//     {
//         printf("accel_test returned: %d\n", accel_test(user_input));
//     }
// }
// ADD_CMD("acceltest", AccelerometerTest,"Test the accelerometer");

int bc_tilt(int delay, int target, int game_time);

void TiltGame(int action)
{
if(action==CMD_SHORT_HELP) return;
if(action==CMD_LONG_HELP) {
printf("Tilt Game\n\n"
"This command plays the tilt game\n"
);
return;
}
//creating a variable of type uint32_t called delay and a regular int called fetch_status
    uint32_t delay;
    int fetch_status1;
    fetch_status1 = fetch_uint32_arg(&delay);

    if(fetch_status1) {
    // Use a default value
        delay = 1000;
    }   

    uint32_t target;
    int fetch_status;
    fetch_status = fetch_uint32_arg(&target);

    if(fetch_status) {
        target = 2;
    }

    uint32_t game_time;
    int fetch_status2;
    fetch_status2 = fetch_uint32_arg(&game_time);

    if(fetch_status2) {
        game_time = 10;
    }

    printf("bc_tilt returned: %d\n", bc_tilt(delay, target, game_time));
    
}
ADD_CMD("bcTilt", TiltGame,"Test the accelerometer");

int lab8();

void lab_eight(int action)
{
if(action==CMD_SHORT_HELP) return;
if(action==CMD_LONG_HELP) {
printf("Lab8\n\n"
"This command runs the sample code given in lab 8\n");
return;
}
//creating a variable of type uint32_t called delay and a regular int called fetch_status
    
    printf("lab8 is finished: %d\n", lab8());   
}
ADD_CMD("bclab8", lab_eight,"Run the code provided");


void wdogTest(int action)
{
    if(action==CMD_SHORT_HELP) return;
    if(action==CMD_LONG_HELP)
    {
        printf("Used to test the watchdog\n\n"
        "used to test the watchdog functionality\n"
        );
        return;
    }

    uint32_t refresh;
    int fetch_status1;
    fetch_status1 = fetch_uint32_arg(&refresh);

    if(fetch_status1) {
    // Use a default value
        refresh = 1000;
    }
    mes_InitIWDG(refresh);
    mes_IWDGStart();
    mes_IWDGRefresh();
}
ADD_CMD("watch", wdogTest, "created to test the watchdog functions");

int _bc_a5_tick_handler(int timeout, int delay);

void tickHandler(int action)
{
if(action==CMD_SHORT_HELP) return;
if(action==CMD_LONG_HELP) {
printf("Tick Handler\n\n"
"This command handles how the tick handler works with A5\n"
);
return;
}
//creating a variable of type uint32_t called delay and a regular int called fetch_status
    uint32_t timeoutTimer;
    int fetch_status1;
    fetch_status1 = fetch_uint32_arg(&timeoutTimer);

    if(fetch_status1) {
    // Use a default value
        timeoutTimer = 1000;
    }   

    uint32_t blinkDelay;
    int fetch_status;
    fetch_status = fetch_uint32_arg(&blinkDelay);

    if(fetch_status) {
        blinkDelay = 2;
    }

    printf("_bc_a5_tick_handler: %d\n", _bc_a5_tick_handler(timeoutTimer, blinkDelay));
    
}
ADD_CMD("_bcWatch", tickHandler,"run the function to start the watchdog function");



