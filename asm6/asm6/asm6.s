.data
# Constants for ASCII characters
NEWLINE: .asciiz "\n"
SPACE: .asciiz " "
WALL: .asciiz "#"
SNAKE_BODY: .asciiz "S"
FOOD: .asciiz "F"
# Game variables
board: .space 400 # 20x20 game board
snakeX: .word 10 # initial snake x position
snakeY: .word 10 # initial snake y position
foodX: .word 5 # initial food x position
foodY: .word 5 # initial food y position
direction: .word 0 # initial direction (0: right, 1: down, 2: left, 3: up)
score: .word 0
game_over_msg: .asciiz "Game Over! Press any key to exit."
MAX_SCORE: .word 100
.text
.globl main
# Function to print a string
print_string:
    li $v0, 4
    syscall
    jr $ra
# Function to print an integer
print_int:
    li $v0, 1
    syscall
    jr $ra
# Function to read a character from input
read_char:
    li $v0, 12
    syscall
    jr $ra
# Function to draw the game board
draw_board:
    li $t0, 0 # Initialize row counter
draw_row_loop:
    bge $t0, 20, draw_end # If all rows drawn, exit loop
    li $t1, 0 # Initialize column counter
draw_col_loop:
    bge $t1, 20, draw_next_row # If all columns drawn, move to next row
    li $t2, 0 # Initialize cell content (empty)
    # Check if current cell is snake body
    lw $t3, snakeX
    lw $t4, snakeY
    beq $t0, $t4, check_snake_x
    b draw_col_loop_continue
check_snake_x:
    beq $t1, $t3, set_snake_body
    b draw_col_loop_continue
set_snake_body:
    li $t2, 1 # Set cell content to snake body
draw_col_loop_continue:
    # Check if current cell is food
    lw $t3, foodX
    lw $t4, foodY
    beq $t0, $t4, check_food_x
    b draw_col_loop_continue_food
check_food_x:
    beq $t1, $t3, set_food
    b draw_col_loop_continue_food
set_food:
    li $t2, 2 # Set cell content to food
draw_col_loop_continue_food:
    # Draw cell based on content
    li $v0, 4
    beq $t2, 0, draw_empty
    beq $t2, 1, draw_snake_body
    beq $t2, 2, draw_food
draw_empty:
    la $a0, SPACE
    syscall
    b draw_col_loop_increment
draw_snake_body:
    la $a0, SNAKE_BODY
    syscall
    b draw_col_loop_increment
draw_food:
    la $a0, FOOD
    syscall
draw_col_loop_increment:
    # Move to next column
    addi $t1, $t1, 1
    j draw_col_loop
draw_next_row:
    # Move to next row
    la $a0, NEWLINE
    li $v0, 4
    syscall
    addi $t0, $t0, 1
    j draw_row_loop
draw_end:
    jr $ra
# Function to update game state
update_game:
    # Move snake based on direction
    lw $t0, direction
    beq $t0, 0, move_right
    beq $t0, 1, move_down
    beq $t0, 2, move_left
    beq $t0, 3, move_up
move_right:
    lw $t0, snakeX
    addi $t0, $t0, 1
    sw $t0, snakeX
    j update_end
move_down:
    lw $t0, snakeY
    addi $t0, $t0, 1
    sw $t0, snakeY
    j update_end
move_left:
    lw $t0, snakeX
    addi $t0, $t0, -1
    sw $t0, snakeX
    j update_end
move_up:
    lw $t0, snakeY
    addi $t0, $t0, -1
    sw $t0, snakeY
update_end:
    jr $ra
    # Function to increase score
increase_score:
    lw $t0, score   # Load current score
    addi $t0, $t0, 1   # Increment score by 1
    sw $t0, score   # Store updated score
    jr $ra
# Function to check collision with food
check_food_collision:
    lw $t0, snakeX    # Load snake's x position
    lw $t1, snakeY    # Load snake's y position
    lw $t2, foodX     # Load food's x position
    lw $t3, foodY     # Load food's y position
    beq $t0, $t2, check_food_collision_y  # Check if snake's x position matches food's x position
    j check_food_collision_end
check_food_collision_y:
    beq $t1, $t3, collision_detected    # Check if snake's y position matches food's y position
check_food_collision_end:
    jr $ra
collision_detected:
    jal increase_score    # Increase the score
    # Generate new position for food
    # Add code to generate new position for food
    jr $ra
# Function to check collision with wall
check_wall_collision:
    # Add code to check collision with wall
    jr $ra
# Function to check collision with snake's own body
check_self_collision:
    # Add code to check collision with snake's own body
    jr $ra
# Function to handle game over
game_over:
    addi $v0, $zero, 4      # Print string syscall
    la $a0, game_over_msg   # Load game over message address
    syscall
    jal read_char           # Wait for any key press
    li $v0, 10              # Exit program
    syscall
game_loop:
    # Draw game board
    jal draw_board
    # Update game state
    jal update_game
    # Check for collisions
    jal check_collisions
    # Wait for user input
    jal read_char
    # Handle input
    li $t0, 'w' # up
    beq $v0, $t0, change_direction
    li $t0, 's' # down
    beq $v0, $t0, change_direction
    li $t0, 'a' # left
    beq $v0, $t0, change_direction
    li $t0, 'd' # right
    beq $v0, $t0, change_direction
    j game_loop
check_collisions:
    # Check collision with food
    jal check_food_collision
    # Check collision with wall
    jal check_wall_collision
    # Check collision with snake's own body
    jal check_self_collision
    jr $ra
continue_game:
    j game_loop
change_direction:
    # Change snake direction based on input
    li $t0, 'w' # up
    beq $v0, $t0, set_up
    li $t0, 's' # down
    beq $v0, $t0, set_down
    li $t0, 'a' # left
    beq $v0, $t0, set_left
    li $t0, 'd' # right
    beq $v0, $t0, set_right
    j game_loop
set_up:
    li $t0, 3
    sw $t0, direction
    j game_loop
set_down:
    li $t0, 1
    sw $t0, direction
    j game_loop
set_left:
    li $t0, 2
    sw $t0, direction
    j game_loop
set_right:
    li $t0, 0
    sw $t0, direction
    j game_loop
main:
    # Initialize game state
    li $t0, 10 # initial snake x position
    sw $t0, snakeX
    li $t0, 10 # initial snake y position
    sw $t0, snakeY
    li $t0, 5 # initial food x position
    sw $t0, foodX
    li $t0, 5 # initial food y position
    sw $t0, foodY
    li $t0, 0 # initial direction (0: right, 1: down, 2: left, 3: up)
    sw $t0, direction
    li $t0, 0 # initial score
    sw $t0, score
    li $t0, 0 # initial max score
    sw $t0, MAX_SCORE
    jal game_loop
