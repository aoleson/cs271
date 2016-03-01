TITLE Project 2: Fibonacci Numbers with Input Validation     (project_02.asm)

; Author: Alannah Oleson
; Email: olesona@oregonstate.edu
; Class number/section: CS271-001
; Project #2
; Due date: 1/24/2016
;
; Description: This program greets the user and gets their name, then displays a
;   personalized greeting. It then prompts the user for an integer between 1 and 46
;   (inclusive), and performs data validation on the input using a post test loop. 
;   If the input is valid it calculates and displays the Fibonnaci sequence numbers
;   up to the user's input number of terms using a counted loop. It then gives a 
;   personalized goodbye and exits the program.
;
; Collaborators: I used http://www.experts-exchange.com/questions/24594784/what-register-does-readstring-goto.html
;   to figure out how to read in a string.

INCLUDE Irvine32.inc

UPPER_LIMIT = 46   ;Define the constant for the upper limit
NAME_LENGTH = 25   ;The constant for the max name length


.data

intro         BYTE    "    Project #2 - The Fibonacci Numbers   by Alannah Oleson    CS 271", 0   ;The programmer introduction

name_prompt   BYTE    "What's your name? (25 char or less) : ", 0		;Prompt for user's name
user_name     BYTE    (NAME_LENGTH + 1) DUP(0)							;Init an array that can hold a 25-char name (plus null terminator)
user_hello    BYTE    "Good morning/afternoon/evening, ", 0				;The first part of the personalized greeting

how_to        BYTE    "Enter the number of Fibonacci terms you want displayed as an integer in the range [1, 46]. ", 0   ;Instructions to use the program
num_prompt    BYTE    "How many Fibonacci terms do you want?: ", 0						 ;Prompt for user input number
out_of_range  BYTE    "Out of range! Please enter a number in the range [1, 46]", 0		 ;Error message when user gives invalid number
user_num      DWORD   ?																	 ;Amount of terms to display, entered by user

msg_1         BYTE    "Displaying the first ", 0   ;Usability: let the user know you got their number correctly
msg_2         BYTE    " Fibonacci numbers...", 0   ;    by displaying a message

fib_sum       DWORD   ?					;Running total sum of sequence
spaces        BYTE    "     ", 0		;Spaces for formatting
curr		  DWORD   ?					;The current term (not the running total)
holder		  DWORD   ?					;Intermediate variable to hold numbers during addition
how_many	  DWORD   ?					;Keep track of how many numbers you've printed, for line breaks

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



;---GET_USER_DATA---

COMMENT @
	This section gets and validates the user input for the number of terms to display. It uses a post-test
	loop to first prompt the user to enter a number, then check if the number is in [1, 46]. If the
	input is invalid, it prints an error message and jumps to the top of the loop. Otherwise, it breaks
	out of the loop and displays a message "Printing the first XX Fibonacci numbers..."
@

;Start the post-test loop
validation_loop:

	;Prompt for the number of terms to be displayed (range 1-46, inclusive)
		mov		edx, OFFSET num_prompt
		call	WriteString
		call	ReadInt
		mov		user_num, eax

	;If input is less than 1, it's invalid: jump to error message
		mov     eax, user_num
		cmp     eax, 1
		jl		invalid_message

	;If input is greater than 46, it's invalid: jump to error message
		mov     eax, user_num
		cmp     eax, UPPER_LIMIT
		jg		invalid_message

	;If none of the above jumps triggered, input is valid: break out of loop
		jmp     end_val_loop

;Jump here if you need to print an "invalid input" message
invalid_message:
	
	;Print the error message and jump to the beginning of the loop
		mov		edx, OFFSET out_of_range
		call	WriteString
		call	CrLf
		call	CrLf
		jmp		validation_loop


;End of the post test loop
end_val_loop:

;Display a message that lets the user know you got their input correctly
	mov		edx, OFFSET msg_1
	call	WriteString
	mov		eax, user_num
	call	WriteDec
	mov		edx, OFFSET msg_2
	call	WriteString
	call	CrLf
	call	CrLf
	


;---DISPLAY_FIBS---

COMMENT @
	This section is where the magic happens. After initializing the variables that will be used, it starts iteratively
	calculating the Fibonacci sequence, displaying each term as it is calculated. This is done with some creative jumping.
	Each time a number is printed, it increments the how_many variable that is used to keep track of when to insert
	line breaks (after every fifth term). If how_many is less than 2, it just prints out a 1. If how_many is more than/equal
	to 2, it jumps to the math block. Within the fib_summing block, it adds the current number to the running total, then
	displays the running total. The counted loop runs as many times as the number that the user entered, showing the 
	user's desired number of Fibonacci terms.
@

;Setup the variables to their initial states

	mov		ecx, user_num		;Set loop counter to user_num
	mov		how_many, 0			;Set how many terms printed to 0
	mov		curr, 1				;Set up for fib_summing block
	mov		fib_sum, 1			;Set up for fib_summing block



;Begin the loop
start_loop:

	;If you've printed more than 2 terms, jump to the fib_summing block with all the fancy math
		mov		eax, how_many
		cmp		eax, 2
		jge		fib_summing

	;If you didn't jump, you're in the first two terms, so just print 1's and skip fib_summing
		mov		eax, 1
		call	writeDec
		mov		edx, OFFSET spaces
		call	writeString
		inc		how_many
		jmp		loop_cmd


;Jump here if you want to do all the fancy Fibonacci calculations
	fib_summing:
		
		;Move the current running total to eax and add the next number to be added
		mov		eax, fib_sum
		mov		holder, eax		;Store the current running total for safekeeping
		add		eax, curr


		;Print the next term plus some spaces
		call	writeDec
		mov		edx, OFFSET spaces
		call	writeString


		;Store the new running total, then update the variables to keep track of what you need to add next
		mov		fib_sum, eax
		mov		eax, holder
		mov		curr, eax
		inc		how_many

		
		;Modulus divide the number of terms printed by 5 to see if you have to print a line break
		mov		eax, how_many
		mov		edx, 0
		mov		ebx, 5
		div		ebx
		cmp		edx, 0


		;If the remainder isn't 0, then skip printing the line break
		jne		loop_cmd

		;Else, print the line break and fall through to loop_cmd
		call	CrLf
		

;Jump here if you just printed something and want to restart the loop
	loop_cmd:
		loop	start_loop



;---FAREWELL---

COMMENT @
	This section comes at the end of the program's execution. It prints a personalized goodbye to the user, 
	making use of the name they entered at the beginning of the program.
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
