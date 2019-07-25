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

#`
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
	.align 4

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

