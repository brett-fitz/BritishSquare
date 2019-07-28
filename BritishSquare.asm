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
	.ascii  "************************\n"
	.ascii  "**   Game is a tie    **\n"
	.asciiz "************************\n"
XWinsMessage:
	.ascii  "************************\n"
	.ascii  "**   Player X wins!   **\n"
	.asciiz "************************\n"
OWinsMessage:
	.ascii  "************************\n"
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

# main: Main Function that executes the program
# 
#
#
#
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


init_board:
	beq $t0, t1, run 
	sw  $t2, 0($s0)
	addi $s0, $s0, 4
	addi $t0, $t0, 1
	j 	init_board

run:
	addi $sp, $sp, -4
	sw  $ra, 0($sp)
	# Might have to make room in sp for s vars
	addi $s1, $zero, 1 			# Start with player X

game_loop:
	add $a0, $zero, $s1 		# Passing player
	jal check_availability
	beq $v0, $zero, skip_player
	j 	game_move

skip_player:
	beq $s1, $zero, skip_o_player

skip_x_player:
	la 	XSkipMessage
	jal print_string
	j 	game_loop_end

skip_o_player:
	la 	OSkipMessage
	jal print_string
	j 	game_loop_end

game_move:
	beq $s1, $zero, prompt_o:

prompt_x:
	la 	$a0, XMoveMessage
	jal print_string
	j 	check_valid_move

prompt_o:
	la 	$a0, OMoveMessage
	jal print_string

check_valid_move:
	li $v0, READ_INT
	syscall
	add $s2, $zero, $v0

is_move_quit:
	addi $t0, $zero, -2
	beq $s2, $t0, quit

is_move_skip:
	addi $t0, $zero, -1
	beq $t2, $t0, game_move_done

is_move_invalid:
	slt $t0, $s2, $zero
	bne $t0, $zero, invalid_move_location
	addi $t1, $zero, 24
	slt $t0, $t1, $t2
	bne $t0, $zero, invalid_move_location

is_center_error:
	addi $t0, $zero, 12
	bne $s2, $t0, is_cell_available
	addi $v0, $zero, 0
	jal check_centter_error
	bne $v0, $zero, center_error

is_cell_available:
	add $a0, $zero, $s1
	add $a1, $zero, $s2
	jal check_cell_availability

is_cell_occupied:
	addi $t0, $zero, 2
	beq $v0, $t0, invalid_occupied_loaction

is_cell_blocked:
	addi $t0, $zero, 3
	beq $v0, $t0, invalid_blocked_loaction

write_cell:
	la 	$t0, board
	addi $t1, $zero, 4
	mul $t2, $s2, $t1
	addi $t0, $t0, $t2
	sw 	$s1, 0($t0)
	j 	game_move_done

invalid_move_location:
	la 	$a0, IllegalMoveLocationError
	jal print_string
	j 	re_prompt

center_error:
	la $a0, CenterSquareError
	jal print_string
	j re_prompt

invalid_occupied_location:
	la 	$a0, IllegalOccupiedLocationError
	jal print_string
	j re_prompt

invalid_blocked_loaction:
	la 	$a0, IllegalBlockedLocationError
	jal print_string

re_prompt:
	beq $s1, $zero, prompt_o
	j 	prompt_x

game_move_done:
	jal print_string

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

quit:
	jal print_score
	beq $s1, $zero, print_o_quit 

print_x_quit:
	la 	XQuitMessage
	jal print_string
	j 	exit_game

print_o_quit:
	la 	OQuitMessage
	jal print_string
	j 	exit_game

end_game:
	jal print_score
	beq $v0, $zero, 1
	addi, $t0, $zero, 1
	beq $v0, $zero, o_wins

tie: 
	la $a0, TieMessage
	jal print_string
	j 	exit_game

o_wins:
	la 	$a0, OWinsMessage
	jal print_string
	j 	exit_game

x_wins:
	la 	$a0, XWinsMessage
	jal print_string

exit_game:
	la 	$a0, EXIT
	syscall 


#############################
# check_centter_error       #
#############################
check_centter_error:
	la 	$t0, board
	addi $t6, $zero, 0

check_center_error_loop:
	lw 	$t5, 0($t0)
	bne $t5, $zero, center_loop_done
	addi $t6, $t6, 1
	addi $t1, $zero, 25
	beq $t6, $t1, center_loop_done_error
	j 	check_center_error_loop

check_loop_done_error:
	addi $v0, $zero, 1
	jr 	$ra

check_loop_done:
	addi $v0, $zero, 0
	jr 	$ra 



###############################
# check_availability          #
###############################
check_availability:
	addi $sp, $sp, -4
	sw 	$ra, 0($sp)
	addi $t1, $zero, 0 			# index = 0

check_availability_loop:
	addi $t3, $zero, 25
	beq $t1, $t3, check_no_availability

	addi $a1, $t1, $zero 		# passing index
	jal check_cell_availability
	beq $v0, $zero, is_availability
	addi $t1, $t1, 1
	j 	check_availability_loop

check_cell_availability:
	la 	$t0, board 
	add $t0, $t0, $a1
	lw 	$t4, 0($t0)
	addi $t5, $zero, 1
	xor $t6, $a0, $t5
	beq $t4, $a0, cell_occupied 
	beq $t4, $t6, cell_occupied

check_north_availability:
	addi $s4, $zero, 5 			# North index offset
	slt $s5, $a1, $s4
	bne $s5, $zero, check_south_availability
	addi $s4, $zero, -5
	add $t0, $t0, $s4
	lw 	$t4, 0($t0)
	beq $t4, $a0, check_west_availability
	beq $t4, $t6, cell_blocked 
	addi $s4, $zero, 5
	add $t0, $t0, $s4

check_south_availability:
	addi $s4, $zero, 20
	slt $s5, $a1, $s4
	beq $s5, $zero, check_west_availability
	addi $s4, $zero, 5
	add $t0, $t0, $s4
	lw 	$t4, 0($t0)
	beq $t4, $a0, check_west_availability
	beq $t4, $t6, cell_blocked
	addi $s4, $zero, -5
	add $t0, $t0, $s4


check_west_availability:
	addi $s4, $zero, 5
	rem $s5, $a1, $s4
	beq $s5, $zero, check_east_availability
	addi $s4, $zero, -1
	add $t0, $t0, $s4
	lw 	$t4, 0($t0)
	beq $t4, $a0, check_east_availability
	beq $t4, $t6, cell_blocked
	addi $s4, $zero, 1
	add $t0, $t0, $s4

check_east_availability:
	addi $s4, $a1, 1
	addi $t5, $zero, 5
	rem $s5, $s4, $t5
	beq $s5, $zero, check_done
	addi $s4, $zero, 1
	add $t0, $t0, $s4
	lw 	$t4, 0($t0)

cell_occupied:
	addi $v0, $zero, 2
	jr 	$ra

cell_blocked:
	addi $v0, $zero, 3
	jr 	$ra

cell_done:
	addi $v0, $zero, 0
	jr 	$ra

no_availability:
	addi $v0, $zero, 0
	lw 	$ra, 0($sp)
	addi $sp, $sp, 4
	jr 	$ra

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

