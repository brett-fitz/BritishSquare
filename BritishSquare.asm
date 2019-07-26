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
EXIT.        = 10


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
	.asciiz "Player O has no legal moves, turn skipped.\n\n"
XSkipMessage:
	.asciiz "Player X has no legal moves, turn skipped.\n\n"

OMoveMessage:
	.asciiz "Player O enter a move (-2 to quit, -1 to skip move): "
XMoveMessage:
	.asciiz "Player X enter a move (-2 to quit, -1 to skip move): "

# Error Messages
CenterSquareError:
	.asciiz "Illegal move, can't place first stone of game in middle square\n\n"
IllegalMoveLocationError:
	.asciiz "Illegal location, try again\n\n"
IllegalOccupiedLocationError:
	.asciiz "Illegal move, square is occupied\n\n"
IllegalBlockedLocationError:
	.asciiz "Illegal move, square is blocked\n\n"

# End Game Messages
GameTotals:
	.asciiz "Game Totals\n"
XTotal:
	.asciiz "X's total="
OTotal:
	.asciiz " O's total="

XQuitMessage:
	.asciiz "Player X quit the game.\n"
OQuitMessage:
	.asciiz "Player O quit the game.\n"

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


##### CODE STARTS HERE #####

	.text
	.align 	2
	.globl	main

# main: Main Function that executes the program
# 
#
#
#
main:
	addi $sp, $sp, -12
	la $a0, WelcomeMessage		# Printing Welcome Message
	jal print_string
	jal print_board


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


print_board:
	addi $sp, $sp, -4 			# Making room to save return addr
	sw 	$ra, 0($sp)				# Storing return location
	move $t1, $a0				# Pointer to Array
	
	la 	$a0, NewLine
	jal print_string
	la 	$a0, Border
	jal print_string
	la 	$a0, CellSeparator
	jal print_string

	li 	$t0, 0					# Row Num

print_loop:
	li 	$t2, 10
	beq $t0, $t2, print_done
	li 	$t3, 0 					# Cell Num 
	la 	$a0, Star
	jal print_string

print_row_loop:
	li 	$t2, 5
	beq $t3, $t2, print_row_done
	lw 	$a0, 0($t1)
	li 	$t2, 2
	rem $t4, $t0, $t2
	beq $t4, $zero, print_top_cell
	j 	print_bottom_cell

print_top_cell:
	beq $a0, $zero, print_o_cell
	li 	$t2, 1
	beq $a0, $t2, print_x_cell
	la 	$a0, EmptyCell
	jal print_string
	j 	update_row_loop

print_bottom_cell:
	beq $a0, $zero, print_o_cell
	li 	$t2, 1
	beq $a0, $t2, print_x_cell
	li 	$t2, -1
	li 	$t4, 2
	addi $t2, $t2, $t0
	div $t5, $t2, $t4
	addi $t5, $t5, $t3
	la 	$a0, $t5
	jal print_int
	li 	$t2, 10
	slt $t4, $t5, $t2
	beq $t4, $zero, print_one_space
	la  $a0, DoubleWhiteSpace
	jal print_string
	j 	update_row_loop

print_o_cell:
	la  $a0, OCell
	jal print_string
	j 	update_row_loop

print_x_cell:
	la  $a0, XCell
	jal print_string
	j 	update_row_loop

print_one_space:
	la  $a0, SingleWhiteSpace
	jal print_string
	j 	update_row_loop

update_row_loop:
	addi $t3, $t3, 1
	addi $t1, $t1, 4
	j 	print_row_loop

print_row_done:
	la 	$a0, CellSeparator
	jal print_string
	addi $t0, $t0, 1
	j 	print_loop

print_done:
	la $a0, Border
	jal print_string

	lw 	$ra, 0($sp)				# Restoring return addr
	addi $sp, $sp, 4
	jr 	$ra







