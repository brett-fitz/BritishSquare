# File:         build.asm
# Author:       Brett Fitzpatrick
#
# Course:       CS-250 (Concepts of Computer Systems)
# Section:	    01
#
# Description: 
#       This file implements the 2-player game British Square. 
#		The game entails two players alternating turns to drop 
# 		stones on the board. The overall objective is to have 
#		the most stones in the game. The game ends when neither
#		player can make a legal drop. A drop is only legal if 
#		there are no enemy stones orthogonally adjacent to the
#		desired empty cell. 
#

#
# CONSTANT DECLARATIONS
#
# Syscall Codes
PRINT_INT    = 1
PRINT_STRING = 4
READ_INT     = 5
EXIT         = 10


#
# DATA DECLARATIONS
#
	.data
	.align 0

# Basic Strings
SingleWhiteSpace:
	.asciiz " "
DoubleWhiteSpace:
	.asciiz "  "
NewLine:
	.asciiz "\n"

# Messages
WelcomeMessage:
	.ascii  "\n****************************\n"
	.ascii  "**     British Square     **\n"
	.asciiz "****************************\n"

# In Game Messages
OSkipMessage:
	.asciiz "\nPlayer O has no legal moves, turn skipped.\n\n"
XSkipMessage:
	.asciiz "\nPlayer X has no legal moves, turn skipped.\n\n"

OMoveMessage:
	.asciiz "\nPlayer O enter a move (-2 to quit, -1 to skip move): "
XMoveMessage:
	.asciiz "\nPlayer X enter a move (-2 to quit, -1 to skip move): "

# Error Messages
CenterSquareError:
	.asciiz "\nIllegal move, can't place first stone of game in middle square\n\n"
IllegalMoveLocationError:
	.asciiz "\nIllegal location, try again\n\n"
IllegalOccupiedLocationError:
	.asciiz "\nIllegal move, square is occupied\n\n"
IllegalBlockedLocationError:
	.asciiz "\nIllegal move, square is blocked\n\n"

# End Game Messages
GameTotals:
	.asciiz "\nGame Totals\n"
XTotal:
	.asciiz "X's total="
OTotal:
	.asciiz " O's total="

XQuitMessage:
	.asciiz "\nPlayer X quit the game.\n"
OQuitMessage:
	.asciiz "\nPlayer O quit the game.\n"

TieMessage:
	.ascii  "\n************************\n"
	.ascii  "**   Game is a tie    **\n"
	.asciiz "************************\n"
XWinsMessage:
	.ascii  "\n************************\n"
	.ascii  "**   Player X wins!   **\n"
	.asciiz "************************\n"
OWinsMessage:
	.ascii  "\n************************\n"
	.ascii  "**   Player O wins!   **\n"
	.asciiz "************************\n"

# Board Strings
Star:
	.asciiz "*"
Border:
	.asciiz "***********************\n"
CellSeparator:
	.asciiz "*+---+---+---+---+---+*\n"
CellBorder:
	.asciiz "|"
CellRowEnd:
	.asciiz "|*\n"
XCell:
	.asciiz "|XXX"
OCell:
	.asciiz "|OOO"
EmptyCell:
	.asciiz "|   "

# Board
Board:
	.space 100


##### Functions #####

	.text
	.align 	2
	.globl	main

#################################################
# main                                          #
# 	Description: Function that starts the game  #
#   	British Square.                         #
#	Parameters: None                            #
# 	Return: None                                #
# 	Registers:                                  #
# 		$s0	- Pointer to board                  #
# 		$s1 - Current Player                    #
# 		$t0 - Temp variable                     #
# 		$t1 - Temp variable                     #
# 		$t2 - Temp variable                     #
#################################################
main:
	addi $sp, $sp, -4
	sw 	$ra, 0($sp)

	la  $a0, WelcomeMessage		# Printing Welcome Message
	jal print_string
	jal print_board

	la  $s0, Board
	# Values for init_board
	addi $t0, $zero, 0          # i = 0
	addi $t1, $zero, 25			# len(board)
	addi $t2, $zero, 2 			# Value for Empty Cell

# init_board: Method that initializes the board with all empty cells
init_board:
	sw  $t2, 0($s0)             # Set cell to empty
	addi $t0, $t0, 1
	beq $t0, t1, run            # If loop is done, start the game
	addi $s0, $s0, 4            # Move pointer to next cell
	j 	init_board

# run: Method that sets the starting player and proceeds to the game loop
run:
	# Might have to make room in sp for s vars
	addi $s1, $zero, 1 			# Start with player X

# game_loop: Method that loops until a player quits or there is no availability
game_loop:
	add $a0, $zero, $s1 		# Passing player
	jal check_availability      # Checking if player can make a move
	beq $v0, $zero, skip_player # If no availability, skip player
	j 	game_move               # Proceed to move

# skip_player: Method called when a player is to be skipped. Determines which
skip_player:
	beq $s1, $zero, skip_o_player # Determines which player to skip

# skip_x_player: Method that prints a message that player X has been skipped
skip_x_player:
	la 	XSkipMessage
	jal print_string
	j 	game_loop_end

# skip_x_player: Method that prints a message that player O has been skipped
skip_o_player:
	la 	OSkipMessage
	jal print_string
	j 	game_loop_end

# game_move: Method called when a move is to be made
game_move:
	beq $s1, $zero, prompt_o:   # Determining which player to prompt

# prompt_x: Method that prints a prompt message for player X to move
prompt_x:
	la 	$a0, XMoveMessage
	jal print_string
	j 	check_valid_move

# prompt_o: Method that prints a prompt message for player O to move
prompt_o:
	la 	$a0, OMoveMessage
	jal print_string

# check_valid_move: Reads user input and proceeds with validity check
check_valid_move:
	li $v0, READ_INT            # Getting user input
	syscall
	add $s2, $zero, $v0         # Setting input to $s2

# is_move_quit: Determines if user selected to quit the game (user input = -2)
is_move_quit:
	addi $t0, $zero, -2
	beq $s2, $t0, quit

# is_move_skip: Determines if user selected to skip move (user input = -1)
is_move_skip:
	addi $t0, $zero, -1
	beq $t2, $t0, game_move_done

# is_move_invalid: Determines if player selected a cell that is out of bounds
is_move_invalid:
	slt $t0, $s2, $zero
	bne $t0, $zero, invalid_move_location # If input < 0 (prior checks)
	addi $t1, $zero, 24
	slt $t0, $t1, $t2
	bne $t0, $zero, invalid_move_location # If 24 < input 

# is_center_error: If user chooses the center cell, check for center error
is_center_error:
	addi $t0, $zero, 12
	bne $s2, $t0, is_cell_available # If input is not center cell, move on
	addi $v0, $zero, 0
	jal check_center_error      # Checking for center square error
	bne $v0, $zero, center_error  # If there is an error, report it

# is_cell_available: Determines if desired cell is available
is_cell_available:
	add $a0, $zero, $s1         # Passing player
	add $a1, $zero, $s2         # Passing index (desired cell)
	jal check_cell_availability # Checking if legal move

# is_cell_occupied: Determines if desired cell is occupied based on return 
#                   value of check_cell_availability above. ($v0 == 2)
is_cell_occupied:
	addi $t0, $zero, 2
	beq $v0, $t0, invalid_occupied_loaction

# is_cell_blocked: Determines if desired cell is blocked based on return 
#                   value of check_cell_availability above. ($v0 == 3)
is_cell_blocked:
	addi $t0, $zero, 3
	beq $v0, $t0, invalid_blocked_loaction

# write_cell: If this method is reached, assuming cell is empty and move is
#             legal. This method will place the player's stone on the board.
write_cell:
	la 	$t0, board              # Loading pointer to board
	addi $t1, $zero, 4          # size(cell)
	mul $t2, $s2, $t1           # Getting byte offset
	addi $t0, $t0, $t2          # Moving pointer to cell location in board
	sw 	$s1, 0($t0)             # Placing player's stone in location
	j 	game_move_done          # Goto end of move method

# invalid_move_location: Prints the Illegal Move Location Error Message
invalid_move_location:
	la 	$a0, IllegalMoveLocationError
	jal print_string
	j 	re_prompt               # Go re-prompt player

# center_error: Prints the Center Square Error Message
center_error:
	la $a0, CenterSquareError
	jal print_string
	j re_prompt                 # Go re-prompt player

# invalid_occupied_location: Prints the Invalid Occupied Location Error Message
invalid_occupied_location:
	la 	$a0, IllegalOccupiedLocationError
	jal print_string
	j re_prompt                 # Go re-prompt player

# invalid_blocked_loaction: Prints the Invalid Blocked Location Error Message
invalid_blocked_loaction:
	la 	$a0, IllegalBlockedLocationError
	jal print_string

# re_prompt: Determines which player to re-prompt to move
re_prompt:
	beq $s1, $zero, prompt_o
	j 	prompt_x

# game_move_done: Method called after a player's move is finished. Prints board
game_move_done:
	jal print_board

# game_loop_end: Method that determines if there are anymore legal moves left.
#                If so, switches player and continues game. If not, ends game.
game_loop_end:
	addi $a0, $zero, 0
	jal check_availability
	addi $t0, $t0, $v0
	addi $a0, $zero, 1
	jal check_availability
	addi $t0, $t0, $v0
	beq $t0, $zero, end_game
	addi $t0, $zero, 1
	xor $s1, $s1, $t0
	j 	game_loop

# quit: Method called when user selected to quit. 
quit:
	jal print_score             # Printing Game totals
	beq $s1, $zero, print_o_quit # Determing which player quit

# print_x_quit: Method that prints a message indicating player X chose to quit
#               and proceeds to the method to exit the game.
print_x_quit:
	la 	XQuitMessage
	jal print_string
	j 	exit_game

# print_o_quit: Method that prints a message indicating player O chose to quit
#               and proceeds to the method to exit the game.
print_o_quit:
	la 	OQuitMessage
	jal print_string
	j 	exit_game

# end_game: Method called when there is no more legal moves available. Calls 
#           the method to print the score and depending on the return value,
#           determines who won or if the game ended up in a tie. 
end_game:
	jal print_score
	beq $v0, $zero, o_wins
	addi, $t0, $zero, 1
	beq $v0, $t0, x_wins

# tie: Method that prints the TieMessage and proceeds to exit the game.
tie: 
	la $a0, TieMessage
	jal print_string
	j 	exit_game

# tie: Method that prints the O wins message and proceeds to exit the game.
o_wins:
	la 	$a0, OWinsMessage
	jal print_string
	j 	exit_game

# tie: Method that prints the X wins message and proceeds to exit the game.
x_wins:
	la 	$a0, XWinsMessage
	jal print_string

# exit_game: Method that executes the syscall to exit the game.
exit_game:
	la 	$a0, EXIT
	syscall 


#################################################
# check_center_error                            #
# 	Description: Function that is called when a #
#   	         player attempts to place a     #
#                stone in the center cell. It   #
#                will determine if the board is #
#                empty, indicating a Center     #
#                Square Error.                  #
#	Parameters: None                            #
# 	Return: 0 --> No Error                      #
#           1 --> Center Square Error           #
#################################################
check_center_error:
	la 	$t0, board              # Loading board pointer
	addi $t6, $zero, 0          # index = 0 

# check_center_error_loop: Loops through board to see if it is empty
check_center_error_loop:
	lw 	$t5, 0($t0)             # Getting board[index]
	bne $t5, $zero, center_loop_done # Checking if the cell is not empty
	addi $t6, $t6, 1            # Incrementing index
	addi $t1, $zero, 25         # Checking if all values have been checked
	beq $t6, $t1, center_loop_done_error # If index = 25 then error
	addi $t0, $t0, 4            # Moving pointer to next value
	j 	check_center_error_loop # continue loop

# check_loop_done_error: End of loop method called when there is an error
check_loop_done_error:
	addi $v0, $zero, 1          # Setting return value
	jr 	$ra                     # returning

check_loop_done:
	addi $v0, $zero, 0          # Setting return value
	jr 	$ra                     # returning



#################################################
# check_availability                            #
# 	Description: Function that checks if there  #
#   	are any more legal moves available.     #
#	Parameters: $a0 --> player                  #
#   			$a1 --> index (cell location)   #
# 	Return: 0 --> No availability               #
#           1 --> Is Availbility                #
#################################################
check_availability:
	addi $sp, $sp, -4           # Allocating space for return addr
	sw 	$ra, 0($sp)             # Saving return addr
	addi $t1, $zero, 0 			# index = 0

# check_availability_loop: Function that loops through board values until
#                          either a legal free cell is found or all values
#                          have been checked.                          
check_availability_loop:
	addi $t3, $zero, 25         # Checking if all values have been checked
	beq $t1, $t3, check_no_availability

	addi $a1, $t1, $zero 		# passing index
	jal check_cell_availability # Check if board[index] is available
	beq $v0, $zero, is_availability # If enum == 0 then cell is free 
	addi $t1, $t1, 1            # Increment index
	j 	check_availability_loop # continue loop

#################################################
# check_cell_availability                       #
# 	Description: Function that checks a given   #
#   	cell to see if a potential move is      #
#       legal.                                  #
#	Parameters: $a0 --> player                  #
#   			$a1 --> index (cell location)   #
# 	Return: enum                                #
#				values: 0 --> Free              #
# 						2 --> Occupied          #
#                       3 --> Blocked           #
#################################################
check_cell_availability:
	la 	$t0, board              # Loading Board pointer
	add $t0, $t0, $a1           # Moving to index location
	lw 	$t4, 0($t0)             # $t4 = board[index]
	addi $t5, $zero, 1          # Temp val for xor instruction
	xor $t6, $a0, $t5           # Getting enemy player
	beq $t4, $a0, cell_occupied # Check if player has stone in cell already
	beq $t4, $t6, cell_occupied # Check if enemy has stone in cell already

# check_north_availability: Method that determines if there is a cell north 
#                           of the index. If so, is it an enemy stone.
check_north_availability:
	addi $s4, $zero, 5 			# No north cell if index < 5
	slt $s5, $a1, $s4           # Checking if there is a cell north
	bne $s5, $zero, check_south_availability # Go check south if no north cell
	addi $s4, $zero, -5         # North index offset
	add $t0, $t0, $s4           # Moving pointer to north cell
	lw 	$t4, 0($t0)             # Getting north cell value
	addi $s4, $zero, 5          # Index offset
	add $t0, $t0, $s4           # Moving pointer back to index
	beq $t4, $a0, check_south_availability # Checking if player stone in cell
	beq $t4, $t6, cell_blocked  # Checking if enemy stone is in cell

# check_south_availability: Method that determines if there is a cell south 
#                           of the index. If so, is it an enemy stone.
check_south_availability:
	addi $s4, $zero, 20         # No south cell if index < 20
	slt $s5, $a1, $s4           # Checking if there is a cell south
	beq $s5, $zero, check_west_availability # Go check west if no south cell
	addi $s4, $zero, 5          # Soutth index offset
	add $t0, $t0, $s4           # Moving pointer to south cell
	lw 	$t4, 0($t0)             # Getting south cell value
	addi $s4, $zero, -5         # Index offset
	add $t0, $t0, $s4           # Moving pointer back to index
	beq $t4, $a0, check_west_availability # Checking if player stone in cell
	beq $t4, $t6, cell_blocked  # Checking if enemy stone is in cell


# check_west_availability: Method that determines if there is a cell west 
#                           of the index. If so, is it an enemy stone.
check_west_availability:
	addi $s4, $zero, 5          # No west cell if index % 5 == 0
	rem $s5, $a1, $s4           # index % 5
	beq $s5, $zero, check_east_availability # Skip check if no west cell
	addi $s4, $zero, -1         # West Cell offset
	add $t0, $t0, $s4           # Moving pointer to west cell
	lw 	$t4, 0($t0)             # Getting west cell value
	addi $s4, $zero, 1          # Index offset
	add $t0, $t0, $s4           # Moving pointer back to index
	beq $t4, $a0, check_east_availability # Checking if player stone in cell
	beq $t4, $t6, cell_blocked  # Checking if enemy stone is in cell
	

# check_east_availability: Method that determines if there is a cell east 
#                           of the index. If so, is it an enemy stone.
check_east_availability:
	addi $s4, $a1, 1            # No east cell if (index + 1) % 5 == 0
	addi $t5, $zero, 5
	rem $s5, $s4, $t5           # (index + 1) % 5 == 0
	beq $s5, $zero, check_done  # No east cell so check is done
	addi $s4, $zero, 1          # East cell offset
	add $t0, $t0, $s4           # Moving pointer to east cell
	lw 	$t4, 0($t0)             # Getting east cell value
	beq $t4, $a0, check_done    # Checking if player stone in cell
	beq $t4, $t6, cell_blocked  # Checking if enemy stone is in cell
	j 	check_done         

# cell_occupied: Method called when cell is occupied by another cell
cell_occupied:
	addi $v0, $zero, 2          # ENUM: 2 --> Occupied Cell
	jr 	$ra

# cell_blocked: Method called when cell is blocked by an enemy stone
cell_blocked:
	addi $v0, $zero, 3          # ENUM: 3 --> Blocked Cell
	jr 	$ra

# cell_done: Method called when cell passes availbility check 
cell_done:
	addi $v0, $zero, 0          # ENUM: 0 --> Free Cell
	jr 	$ra

# no_availability: End of loop method called when there is no availability
no_availability:
	addi $v0, $zero, 0
	lw 	$ra, 0($sp)
	addi $sp, $sp, 4
	jr 	$ra

# is_availability: End of loop method called when there is availability
is_availability:
	addi $v0, $zero, 1
	lw 	$ra, 0($sp)
	addi $sp, $sp, 4
	jr 	$ra


# print_string: Prints the string passed to it
# @param: $a0 - String to be printed
print_string:
	li 	$v0, PRINT_STRING
	syscall
	jr 	$ra

# print_int: Prints the integer passed to it
# @param: $a0 - Integer to be printed
print_int:
	li 	$v0, PRINT_INT
	syscall
	jr	$ra 


#################################################
# print_board                                   #
# 	Description: Function that prints the       #
#   	current state of the board by looping   #
#       through all the cell values.            #
#   Board Values:                               #
# 		board[index] == 0    O-Stone            #
#		board[index] == 1    X-Stone            #
#		board[index] == 2	 Empty Cell         #
#	Parameters: None                            #
# 	Return: None                                #
# 	Registers:                                  #
# 		$t0	- Pointer to board                  #
# 		$t1 - Row Num                           #
# 		$t2 - Temp variable used EOL checking   #
# 		$t3 - Cell Num                          #
# 		$t4 - Temp variable                     #
# 		$t5 - Temp variable                     #
# 		$t6 - Temp variable for getting index   #
#################################################
print_board:
	addi $sp, $sp, -4 			# Making room to save return addr
	sw 	$ra, 0($sp)				# Storing return location
	la $t0, board				# Pointer to Array

# print_board_header: Prints the board header and init row number
print_board_header:
	la 	$a0, NewLine
	jal print_string 			# Printing board header
	la 	$a0, Border
	jal print_string
	la 	$a0, CellSeparator 		# Printing CellSeparator
	jal print_string

	addi $t0, $zero, 0			# Row Num

# print_board_loop: Iterates by row in the board until i = 10 (5 rows * 2)
print_board_loop:
	addi $t2, $zero, 10         # Check if loop is done (Row Num = 10)
	beq $t1, $t2, print_board_done  
	
	la 	$a0, Star
	jal print_string 			# Printing row prefix 

	addi $t3, $zero, 0 			# Init Cell Num

# print_row_loop: Iterates by cell in the respective row until y = 5
print_row_loop:
	addi $t2, $zero, 5 
	beq $t3, $t2, print_row_done 	# Checking if loop is done (cell = 5)

	lw 	$t6, 0($t0) 				# Getting board[index]

	addi $t2, $zero, 2 				# Determining if row is top or bottom of cells
	rem $t4, $t0, $t2 				# Remainder == 0 (top) 1 (bottom)
	beq $t4, $zero, print_top_cell

# print_bottom_cell: Prints the bottom portion of the cell
print_bottom_cell:
	beq $t6, $zero, print_o_cell    # board[index] == 0    O-Stone
	addi $t2, $zero, 1
	beq $t6, $t2, print_x_cell      # board[index] == 1    X-Stone
	addi $t2, $zero, -1             # Getting index number = (rowNum - 1)/2 + y
	addi $t4, $zero, 2              # 
	addi $t2, $t2, $t1              # $t2 = (rowNum - 1)
	div $t5, $t2, $t4               # $t5 = $t2 / 2
	addi $t5, $t5, $t3              # $t5 = $t5 + y
	addi $a0, $zero, $t5            # Passing index number to print
	jal print_int                   # Printing index number
	addi $t2, $zero, 10             # Determing to print one or two white spaces
	slt $t4, $t5, $t2               # if index number < 10 (print two) else (print one)
	beq $t4, $zero, print_one_space
	la  $a0, DoubleWhiteSpace
	jal print_string
	j 	update_row_loop

# print_top_cell: Prints the top of the respective cell
print_top_cell:
	beq $t6, $zero, print_o_cell   # board[index] == 0 --> print_o_cell
	addi $t2, $zero, 1
	beq $t6, $t2, print_x_cell     
	la 	$a0, EmptyCell
	jal print_string
	j 	update_row_loop

# print_o_cell: Prints the O Cell
print_o_cell:
	la  $a0, OCell
	jal print_string
	j 	update_row_loop

# print_x_cell: Prints the X Cell
print_x_cell:
	la  $a0, XCell
	jal print_string
	j 	update_row_loop

# print_one_space: Prints the one white space
print_one_space:
	la  $a0, SingleWhiteSpace
	jal print_string

# update_row_loop: Increments cell number and pointer and continues loop
update_row_loop:
	addi $t3, $t3, 1            # Incrementing cell number
	addi $t0, $t0, 4            # Moving board pointer to next index
	j 	print_row_loop          # Continuing loop

# print_row_done: Prints row end & determines if last row was top or bottom
print_row_done:
	la 	$a0, CellRowEnd         # Printing row end
	jal print_string
	addi $t2, $zero, 2          # Determing if printed row was top or bottom
	rem $t4, $t1, $t2
	beq $t4, $zero, print_top_row_done

# print_bottom_row_done: Prints a row separator and continues loop 
print_bottom_row_done:
	la 	$a0, CellSeparator      # Printing row separator
	jal print_string
	addi $t1, $t1, 1            # Incrementing row number
	j 	print_board_loop        # Continuing loop

# print_bottom_row_done: Moves pointer back to start of row and continues loop
print_top_row_done:
	addi $t2, $zero, -5         # Moving pointer back to start of row
	add $t0, $t0, $t2
	addi $t0, $t1, 1            # Incrementing row number
	j 	print_board_loop        # Continuing loop

# print_board_done: Finishes printing board and returns to return addr
print_board_done:
	la $a0, Border              # Printing footer
	jal print_string

	lw 	$ra, 0($sp)				# Restoring return addr
	addi $sp, $sp, 4 			# Deallocating space
	jr 	$ra                     # returning


#################################################
# print_score                                   #
# 	Description: Function that prints the game  #
#   	totals and determines if there is a     #
#       winner or a tie.                        #
#	Parameters: None                            #
# 	Return:  0 --> Player O Wins!               #
#            1 --> Player X Wins!               #
#            2 --> Game is a Tie!               #
#################################################
print_score:
	addi $sp, $sp, -4           # Making room for return addr
	sw 	$ra, 0($sp)             # Storing return addr

	la 	$a0, GameTotals         # Printing Stats header
	jal print_string
	la 	$a0, XTotal
	jal print_string
	addi $t0, $zero, 0          # Player O score
	addi $t1, $zero, 0          # Player X score
	addi $t2, $zero, 0          # index = 0
	addi $t3, $zero, 25         # End of loop
	la 	 $t4, board

# score_loop: Method that loops through the board, counting respective player
#             stones.
score_loop:
	lw 	$t5, 0($t4) 
	beq $t5, $zero, player_o_point
	addi $t6, $zero, 1
	beq $t5, $t6, player_x_point
	j 	score_loop_end

# player_o_point: Increments Player O's score by 1
player_o_point:
	addi $t0, $t0, 1
	j 	score_loop_end

# player_x_point: Increments Player X's score by 1
player_x_point:
	addi $t1, $t1, 1

# score_loop_end: Checks if end of loop, otherwise continues. 
score_loop_end:
	addi $t2, $t2, 1
	beq $t2, $t3, score_loop_done
	addi $t4, $t4, 4
	j 	score_loop

# score_loop_done: Method called when score_loop is done looping through board.
#                  Prints the remaining stats and determines if there is a
#                  winner or the game is a tie.
score_loop_done:
	add $a0, $zero, $t1
	jal print_int
	la 	$a0, OTotal
	jal print_string
	add $a0, $zero, $t0
	jal print_int
	beq $t0, $t1, score_tie
	slt $v0, $t0, $t1
	j 	score_return

# score_tie: Sets return value to 2, indicating game ended in a tie. 
score_tie:
	addi $v0, $zero, 2

# score_return: Cleans up stack and returns
score_return:
	lw 	$ra, 0($sp)
	addi $sp, $sp, 4
	jr 	$ra

