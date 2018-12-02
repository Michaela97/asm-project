# ATARI BREAKOUT

## 1.	Problem Formulation
      
* How to create a game out of the components from Arduino Kit?
* How to connect LED matrix display to the Arduino ?
* How to control the program flow ?


## 2. Project Plan

### 2.1   Analysis 
               
### Rules of the game : 

Objective – hit with the ball all blocks on the screen

*Start the game - press left and right button in the same time

The player moves with a paddle to the left or the right side in order to bounce the ball. The paddle has 3
pixels width and 1 pixel height. The ball is moving diagonally. 
When the ball touches right or left wall, it continues movement in
Y axis and reversed X axis. If the ball hits the top wall it bounces down.
 When the ball hits the block (has the same
coordinates), the block is destroyed (LED turned off) and ball continues
movement like it with reversed Y axis movement. When the ball hits the paddle, it continous movement in X axis and reverse in Y axis.


End game conditions:

* Player hit all the blocks – player wins - happy face is displayed
* The ball is in the bottom row – player loses - sad face is displayed

Ball movement: 
* The ball movement is described as vector v = [x,y] where x belongs to {-1,1} and y belongs to {-1,1}
* To reverse the movement in Y or X axis mean to negate X or Y coordinate of vector.
              
Components:
      
* Arduino Mega 2560      
* 2 buttons (LEFT, RIGHT)
* 8x8 LED matrix
* 1 breadboard
* Resistors  
* Wires

### 2.2 Sketch

note: we are using just one bread board

![alt text](https://github.com/Michaela97/asm-project/blob/master/atari%20breakout%20sketch.jpg "atari breakout sketch")

### 2.3 Test plan
* Arduino is turned on -> Blocks, paddle and ball are in starting positions (see picture below)
![alt text](https://github.com/Michaela97/asm-project/blob/master/start_postition.PNG "start position")
* Left and Right buttons are pressed -> the ball is released, the game starts
* Left or right button pressed when the game is not started -> nothing happens
* Left button pressed during the game - >  the paddle moves to the left one pixel
* Left button pressed when the paddle is next to left wall -> nothing happens
* Right button pressed during the game - >  the paddle moves to the right one pixel
* Right button pressed when the paddle is next to right wall -> nothing happens
* The ball hits the paddle -> the ball is bounced and it continues its movement on X axis and reversed movement in Y axis.
* The ball hits the block (has the same coordinates) -> the block is destroyed (LED turned off) and ball continues its movement on X axis and reversed movement in Y axis.
* The ball hits the left of right wall -> it continues its movement on Y axis and reversed movement in X axis.
* The ball hits the top  wall -> it continues its movement on X axis and reversed movement in Y axis.
* The ball is in the bottom row -> the game is over, player loses – show sad face
* The ball didn’t hit anything -> ball continues the movement according to its current vector
* The ball hits the last block -> the game is over, player wins – show happy face

## 3. Test execution

The game was tested by manual execution of the each test case from the test plan described above. As all tests have passed successfully, the game is ready tu use.
