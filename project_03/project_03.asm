TITLE Project 3: Integer Accumulator     (project_03.asm)

; Author: Alannah Oleson
; Email: olesona@oregonstate.edu
; Class number/section: CS271-001
; Project #3
; Due date: 2/7/16
;
; Description: This program greets the user and displays how to use the program.
;   Then, it prompts the user to enter a negative number in the range [-100, -1].
;   It will reprompt the user to enter a number until they enter a positive number, 
;   which would then terminate the loop. As the user enters numbers, it adds them up.
;   (Note: In case the user doesn't enter any negative numbers, the program will
;   display a message and say goodbye.)
;   When the user is done entering numbers, it displays the sum and the integer
;   average of the numbers. It then displays a personalized goodbye.
;
; Collaborators: I used the code on p264 of the textbook to figure out signed division.

INCLUDE Irvine32.inc

UPPER_LIMIT = -1     ;Define the constant for the upper limit
LOWER_LIMIT = -100   ;Define the constant for the upper limit
NAME_LENGTH = 25     ;The constant for the max name length

.data

intro         BYTE    "    Project #3 - Integer Accumulator   by Alannah Oleson    CS 271", 0   ;The programmer introduction

name_prompt   BYTE    "What's your name? (25 char or less) : ", 0		;Prompt for user's name
user_name     BYTE    (NAME_LENGTH + 1) DUP(0)							;Init an array that can hold a 25-char name (plus null terminator)
user_hello    BYTE    "Good morning/afternoon/evening, ", 0				;The first part of the personalized greeting

how_to        BYTE    "Enter negative numbers in the range [-100, -1], and this program will add them up for you as it goes. When you want to stop entering numbers, enter a positive number. The program will display the total and the integer average. ", 0   ;Instructions to use the program
num_prompt    BYTE    "Enter a number: ", 0													 ;Prompt for user input number
out_of_range  BYTE    "Out of range! Please enter a number in the range [-100, -1]", 0		 ;Error message when user gives invalid number
user_num      SDWORD  ?																	     ;Amount of terms to display, entered by user

num_of_nums   SDWORD  0			;The number of valid integers the user has entered
total		  SDWORD  0			;The total sum of all valid numbers the user has entered
avg			  SDWORD  0			;The integer average of all valid numbers the user has entered

no_nums_msg   BYTE    "You didn't enter any valid numbers!!", 0			;Message to tell the user when there are no valid numbers

num_msg_1	  BYTE	  "You entered ", 0									;Message for telling user how many numbers they entered
num_msg_2     BYTE	  " valid numbers.", 0								;   (above)
total_msg	  BYTE    "Total sum of valid numbers entered: ", 0			;Message to display for sum
avg_msg		  BYTE	  "Average of valid numbers entered: ", 0			;Message to display for average

goodbye       BYTE    "Goodbye! Have a good day, ", 0    ;The personalized farewell



.code
main PROC

;---INTRODUCTION---

COMMENT @
	This section just displays the information about the programmer. Name, class, and program title.
@

;Display the program title and the programmer's name
	mov		edx, OFFSET intro
	call	WriteString
	call	CrLf
	call	CrLf


;---USER_INSTRUCTIONS---

COMMENT @
	This section prompts the user for their name (less than 25 characters) so it can give them a personalized greeting.
	It also displays instructions that tell the user what the program does.
@

;Ask for the user's name
	mov		edx, OFFSET name_prompt
	call	WriteString

;Get the user's name and store in a variable
	mov     edx, OFFSET user_name
	mov     ecx, NAME_LENGTH
	call    readString

;Greet the user
	mov     edx, OFFSET user_hello
	call	WriteString
	mov     edx, OFFSET user_name
	call	WriteString
	call    CrLf
	call    CrLf


;Tell the user how to use the program
	mov		edx, OFFSET how_to
	call	WriteString
	call    CrLf
	call    CrLf



;---GET__AND _SUM_NUMBERS---

COMMENT @
	This section includes the loop that prompts the user for a negative number. If the user does enter
	a negative number, it reprompts them for another, until they enter a positive number. If the user
	enters a positive number, it breaks out of the loop and continues. If the number is less than -100, it
	displays an error message and reprompts for another number. As the user enters valid numbers, the program
	summs them in a running total and keeps track of how many numbers have been entered.
@

;Start the loop to get input and validate it
validation_loop:

	;Prompt for the number (range (-100) - (-1), inclusive)
		mov		edx, OFFSET num_prompt
		call	WriteString
		call	ReadInt
		mov		user_num, eax

	;If input is less than -100, it's invalid: jump to error message
		mov     eax, user_num
		cmp     eax, LOWER_LIMIT
		jl		invalid_message

	;If input is greater than -1 it's a signal to end the loop: break out of the loop
		mov     eax, user_num
		cmp     eax, UPPER_LIMIT
		jg		end_val_loop

	;If none of the above jumps triggered, input is valid: add it to the total, increment the number of valid inputs, and repeat the loop
		
		;Add it to the total
		mov		ebx, total
		add		eax, ebx
		mov		total, eax

		;Increment valid inputs
		inc		num_of_nums

		;End loop
		jmp     validation_loop

;Jump here if you need to print an "invalid input" message
invalid_message:
	
	;Print the error message and jump to the beginning of the loop
		mov		edx, OFFSET out_of_range
		call	WriteString
		call	CrLf
		call	CrLf
		jmp		validation_loop


;End of the number getting loop
end_val_loop:


;---CHECK_IF_NO_NUMS---

COMMENT @
	This section checks to see if there were no valid numbers entered and, if so, displays a special message and jumpes to the end of the program.
	@

;Check if number of valid entered is 0
	mov		eax, num_of_nums
	cmp		eax, 0
	jne		calc		;If valid terms have been entered, do all the fancy math

	;Display a message and skip to end of program
	call	CrLf
	mov		edx, OFFSET no_nums_msg
	call	WriteString
	jmp		end_of_prog



;---CALCULATE_AVERAGE---
calc:

COMMENT @
	This section calculates the integer average of the numbers that were entered and stores it in a variable.
@

;Divide the total by the number of valid numbers and store the (integer) result
	mov		eax, 0
	mov		eax, total
	cdq
	mov		ebx, num_of_nums
	idiv	ebx
	mov		avg, eax



;---DISPLAY_SOLUTIONS---

COMMENT @
	This section displays the number of valid numbers the user entered, and the total and 
	the average of the numbers the user entered.
@

;Display the number of valid numbers
	call	CrLf
	mov		edx, OFFSET num_msg_1
	call	WriteString
	mov		eax, num_of_nums
	call	WriteDec
	mov		edx, OFFSET num_msg_2
	call	WriteString
	call	CrLf
	call	CrLf

;Display the total
	mov		edx, OFFSET total_msg
	call	WriteString
	mov		eax, total
	call	WriteInt
	call	CrLf
	call	CrLf

;Display the average
	mov		edx, OFFSET avg_msg
	call	WriteString
	mov		eax, avg
	call	WriteInt
	call	CrLf
	call	CrLf



;---FAREWELL---
end_of_prog:

COMMENT @
	This section displays the customized parting message to the user.
@

;Say goodbye to the user (using their name)
	call	CrLf
	call	CrLf
	mov     edx, OFFSET goodbye
	call	WriteString
	mov     edx, OFFSET user_name
	call	WriteString
	call    CrLf
	call    CrLf


	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
