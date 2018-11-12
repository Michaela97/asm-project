#ATARI BREAKOUT

##1.	Problem Formulation
      
*How to create a game out of the components from Arduino Kit…..?
*How to connect LED matrix display to the Arduino ?
*How to control the program flow ?


##2. Project Plan

###2.1   Analysis 
               
###Rules of the game : 

*Objective – hit with ball all the blocks on the screen

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

*Player hit all the blocks – player wins
*The ball is in the bottom row – player loses

Ball movement: 
*The ball movement is described as vector v = [x,y] where x belongs to {-1,0,1} and y belongs to {-1,1}
*To reverse the movement in Y or X axis mean to negate X or Y coordinate of vector.
              
Components:
      
*Arduino Mega 2560      
*3 buttons (LEFT, RIGHT, START)
*8x8 LED matrix
*1 breadboard
*Resistors  
*Wires
