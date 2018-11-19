# ATARI BREAKOUT

## 1.	Problem Formulation
      
* How to create a game out of the components from Arduino Kit?
* How to connect LED matrix display to the Arduino ?
* How to control the program flow ?


## 2. Project Plan

### 2.1   Analysis 
               
### Rules of the game : 

Objective – hit with ball all the blocks on the screen

The player moves with a
paddle to the left or right in order to bounce the ball. The paddle has 3
pixels width and 1 pixel height. When the ball bounces on the middle of the
paddle, the ball continues its movement perpendicularly to the paddle. If the
ball bounces of the edges of the paddle, it continues its movement on X axis
and reversed movement in Y axis. The ball is moving horizontally and
diagonally. When the ball touches right or left wall, it continues movement in
Y axis and reversed X axis. If the ball hit the top wall it behaves like it
would hit the edge of the paddle. When the ball hits the block (has the same
coordinates), the block is destroyed (LED turned off) and ball continues
movement like it would hit the edge of the paddle.


End game conditions:

* Player hit all the blocks – player wins
* The ball is in the bottom row – player loses

Ball movement: 
* The ball movement is described as vector v = [x,y] where x belongs to {-1,0,1} and y belongs to {-1,1}
* To reverse the movement in Y or X axis mean to negate X or Y coordinate of vector.
              
Components:
      
* Arduino Mega 2560      
* 3 buttons (LEFT, RIGHT, START)
* 8x8 LED matrix
* 1 breadboard
* Resistors  
* Wires

### 2.2 Test plan
* Arduino is turned on -> Blocks, paddle and ball are in starting positions {image here}
* Start button is pressed -> the ball is released in random direction, the game starts
* Start button pressed during game -> nothing happens 
* Left or right button pressed when the game is not started -> nothing happens
* Left button pressed during the game - >  the paddle moves to the left one pixel
* Left button pressed when the paddle is next to left wall -> nothing happens
* Right button pressed during the game - >  the paddle moves to the right one pixel
* Right button pressed when the paddle is next to right wall -> nothing happens
* When the right and the left button are pressed -> paddle is not moving 
* The ball hits the middle of the paddle -> the ball is bounced perpendicularly to the paddle
* The paddle hits the edge of the paddle -> the ball is bounced and it continues its movement on X axis and reversed movement in Y axis.
* The ball hits the block (has the same coordinates) -> the block is destroyed (LED turned off) and ball continues its movement on X axis and reversed movement in Y axis.
* The ball hits the left of right wall -> it continues its movement on Y axis and reversed movement in X axis.
* The ball hits the top  wall -> it continues its movement on X axis and reversed movement in Y axis.
* The ball is in the bottom row -> the game is over, player loses – show sad face
* The ball didn’t hit anything -> ball continues the movement according to its current vector
* The ball hits the last block -> the game is over, player wins – show happy face
