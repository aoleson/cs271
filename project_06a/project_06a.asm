TITLE  Macros, Values, and Strings    (project_06a.asm)

; Author: Alannah Oleson
; Email: olesona@oregonstate.edu
; Class number/section: CS271-001
; Project #6a
; Due date: 3/13/16
;
; Description:
;   1) Implement and test your own ReadVal and WriteVal procedures for unsigned integers.
;   2) Implement macros getString and displayString. The macros may use Irvine’s ReadString to get input from
;      the user, and WriteString to display output.
;        -getString should display a prompt, then get the user’s keyboard input into a memory location
;        -displayString should the string stored in a specified memory location.
;        -readVal should invoke the getString macro to get the user’s string of digits. It should then convert the
;             digit string to numeric, while validating the user’s input.
;        -writeVal should convert a numeric value to a string of digits, and invoke the displayString macro to
;             produce the output.
;   3) Write a small test program that gets 10 valid integers from the user and stores the numeric values in an
;       array. The program then displays the integers, their sum, and their average.
;
; Collaborators: I used http://programming.msjc.edu/asm/help/source/irvinelib/readstring.htm to understand the Irvine 
;   readString procedure. I used http://stackoverflow.com/questions/13664778/converting-string-to-integer-in-masm-esi-difficulty 
;   to help figure out the algorithm to turn strings into numbers. And I used chapter 9 of the text to understand
;   how to loop through strings.

INCLUDE Irvine32.inc


;---------------------------------------------------------
; Macro: displayString
;
; Displays the string it is passed using writeString.
; Receives: the **OFFSET** of the string it's supposed to print
; Returns: none
; Requires: OFFSET is passed
;---------------------------------------------------------
displayString	MACRO	string_to_print
	push	edx
	mov		edx, string_to_print
	call	writeString
	pop		edx
ENDM


;---------------------------------------------------------
; Macro: getString
;
; Gets a string from the user and stores it in a memory location.
; Receives: address (to store the string in); length (to ensure the string isn't too long)
; Returns: none
; Requires: none
;---------------------------------------------------------
getString	MACRO	address, length
	push	edx				;Save the registers that readString overwrites (from collab website)
	push	ecx
	mov		edx, address
	mov		ecx, length
	call	readString
	pop		ecx
	pop		edx
ENDM



;----------CONSTANTS-------------------------

MIN = 0					;Constant for low user input
MAX = 4294967295		;Constant for high user input (equal to 2^32 -1)



.data

intro			BYTE	"    Project #6 - Macros, Values, and Strings   by Alannah Oleson    CS 271", 0		;The programmer introduction
how_to			BYTE	"This program tests the macros getString and displayString. It takes in 10 unsigned integers from the user, then converts them to numeric and stores them. It displays the integers as strings and calculates their sum and the average.  ", 0	  ;Instructions to use the program

num_list		DWORD	10 DUP (0)		;The array to hold the user's numbers
test_list		DWORD	1, 2, 3, 4, 5, 6, 7, 8, 9, 10		;For debugging

total_msg		BYTE	"Total sum of valid numbers entered: ", 0				;Message to display for sum
avg_msg			BYTE	"Average of valid numbers entered: ", 0					;Message to display for average
prompt_msg		BYTE	"Enter an unsigned integer (32 bits): ", 0				;Message to display for prompt
error_msg		BYTE	"That isn't a valid number! Please try again.", 0		;Message to display for error
nums_msg		BYTE	"You entered these numbers: ", 0						;Message to display for nums
spaces			BYTE	"   ", 0												;Formatting

num_sum			DWORD	0				;Holder var for the sum of the numbers
out_string		BYTE	32 DUP (?)		;Holder string for the writeVal proc
in_string		BYTE	255 DUP (0)		;Holder string for the readVal proc



goodbye       BYTE    "Wow, that was some exciting math!! :D Bye", 0   ;Goodbye string



.code
main PROC
	
	push	OFFSET how_to
	push	OFFSET intro
	call	introduction

	;------------Fill the array with valid input by using readVal--------------------
	mov		ecx, 10					;Want to get 10 valid numbers
	mov		edi, OFFSET num_list

	begin_input_loop:
		
		displayString	OFFSET prompt_msg		;prompt for input

		;Read in the string
		push	OFFSET in_string
		push	SIZEOF in_String
		call	readVal
		
		;Stick in the valid integer and move to the next array spot
		mov		eax, DWORD PTR in_string
		mov		[edi], eax
		add		edi, 4

		loop	begin_input_loop		;Until you get 10 valid values


	;-------At this point, we've got an array with 10 valid integers, so show them to the user one by one------

	mov		ecx, 10
	mov		esi, OFFSET num_list

	;Talk to the user
	call	CrLf
	displayString	OFFSET nums_msg
	
	begin_display_loop:			;Show the 10 numbers by calling writeVal
		
		mov		eax, [esi]
		push	eax
		push	OFFSET out_string
		call	writeVal
		add		esi, 4
		loop	begin_display_loop
		call	CrLf

	;--------Calculate the sum and the average-------------
	push	OFFSET num_sum
	push	OFFSET total_msg
	push	OFFSET num_list
	call	calcSum

	push	num_sum
	push	OFFSET avg_msg
	call	calcAvg

	;--------------Say goodbye------------------------
	push	OFFSET goodbye
	call	farewell

	exit	; exit to operating system
main ENDP


;---------------------------------------------------------
; introduction
;
; Introduces the programmer and how to use the program.
; Receives: @intro and @how_to on the stack
; Returns: none
; Requires: none
;---------------------------------------------------------
introduction PROC
	
	push	ebp
	mov		ebp, esp

	displayString	[ebp + 8]		;The programmer introduction
	call	CrLf
	call	CrLf
	displayString	[ebp + 12]		;The instructions
	call	CrLf
	call	CrLf

	pop		ebp			;Clean up the stack
	ret		8

introduction ENDP


;---------------------------------------------------------
; readVal
;
; Gets the user's string of digits and converts the string to numeric, while validating the input.
; Receives: OFFSET in_String; SIZEOF in_string (both to be used in the getString macro)
; Returns: none
; Requires: none
;---------------------------------------------------------
readVal PROC
	
	push	ebp
	mov		ebp, esp
	pushad

	top_of_readVal:
		
		mov		edx, [ebp + 12]		;OFFSET in_String (the address)
		mov		ecx, [ebp + 8]		;SIZEOF in_string (the length)

		getString	edx, ecx		;Use getString macro (string ends up in OFFSET edx)

		;Get set up for the loop
		mov		esi, edx
		mov		eax, 0
		mov		ecx, 0
		mov		ebx, 10

		;Start looping through the string, validating as you go
		begin_val_loop:
			
			lodsb						;From chapter 9
			cmp		ax, 0				;If equal, we'vereached the null terminator: we're done
			je		end_of_readVal

			;Figure out if the byte is valid (i.e. in ASCII int range)
			cmp		ax, 48
			jb		not_valid		;Less than ASCII 0
			cmp		ax, 57
			ja		not_valid		;More than ASCII 9

			;If you got to here, the input is valid: convert to digit
			sub		ax, 48
			xchg	eax, ecx		;Stick char value in ecx
			mul		ebx				;Adjust for placement
			jc		not_valid		;Num too big - it overflowed
			jmp		is_valid		;Didn't overflow - keep going


	not_valid:
		
		displayString	OFFSET error_msg		;The error message
		call	CrLf
		displayString	OFFSET prompt_msg		;The prompt for input
		jmp		top_of_readVal					;Bad input, start over


	is_valid:
		
		add		eax, ecx			;Add the valid digit to the total
		xchg	eax, ecx			;Set up for next loop iteration
		jmp		begin_val_loop


	end_of_readVal:

		xchg	ecx, eax
		mov		DWORD PTR in_string, eax	;Stick the integer in the address we got passed

	;Clean up the stack
	popad
	pop		ebp
	ret		12

readVal ENDP


;---------------------------------------------------------
; writeVal
;
; Takes in an integer and writes it to the screen as a string.
; Receives: num	(one index of num_list); out_string (to use in displayString)
; Returns: none
; Requires: none
;---------------------------------------------------------
writeVal PROC

	push	ebp
	mov		ebp, esp
	pushad

	;Set up to loop through the integer by digit
	mov		eax, [ebp + 12]		;the integer in [esi]
	mov		edi, [ebp + 8]		;@out_string
	mov		ebx, 10
	push	0					;To act as a marker on the stack

	convert_to_string:
		
		mov		edx, 0
		div		ebx				;Get to the next digit
		add		edx, 48			;Adjust for the ASCII val of the actual character
		push	edx

		;Check if you're at the end of the number; else continue converting
		cmp		eax, 0
		jne		convert_to_string

	;Put the chars into the output string
	stick_in_string:
		pop		[edi]
		mov		eax, [edi]
		inc		edi
		cmp		eax, 0		;Make sure you're not at the end of the num before you continue popping
		jne		stick_in_string

	;Finally, print the dang string
	mov		edx, [ebp + 8]
	displayString	OFFSET out_string
	displayString	OFFSET spaces


	popad
	pop		ebp
	ret		8

writeVal ENDP




;---------------------------------------------------------
; calcSum
;
; Calculates and displays the sum of the user's entered numbers.
; Receives: @num_list; @total_msg; @num_sum
; Returns: none
; Requires: num_list must contain 10 numbers exactly
;---------------------------------------------------------
calcSum PROC
	
	;Set up for proc and init variables
	push	ebp
	mov		ebp, esp
	pushad
	mov		esi, [ebp + 8]		;num_list
	mov		ecx, 10				;10 numbers to sum
	mov		edx, [ebp + 12]		;total_msg
	mov		eax, 0
	mov		ebx, [ebp+16]

	;Add the 10 numbers together
	begin_sum_loop:

		add		eax, [esi]
		add		esi, 4
		loop	begin_sum_loop
		mov		[ebx], eax		;Store the total in num_sum

	;Display the total
	displayString	[ebp + 12]
	push	eax
	push	OFFSET out_string
	call	writeVal
	call	CrLf

	popad
	pop		ebp
	ret		12

calcSum ENDP


;---------------------------------------------------------
; calcAvg
;
; Calculates and displays the average of the user's entered numbers.
; Receives: @avg_msg; @num_sum
; Returns: none
; Requires: num_list must contain 10 numbers exactly
;---------------------------------------------------------
calcAvg PROC
	;Set up for proc and init variables
	push	ebp
	mov		ebp, esp
	pushad
	mov		eax, [ebp + 12]		;num_sum
	mov		ebx, 10				;Should have 10 numbers
	mov		edx, [ebp + 8]		;avg_msg

	;Display the info
	displayString	[ebp + 8]
	
	;Do the division
	mov		edx, 0
	div		ebx

	;Display with writeVal
	push	eax
	push	OFFSET out_string
	call	writeVal
	call	CrLf


	popad
	pop		ebp
	ret		8

calcAvg ENDP





;---------------------------------------------------------
; farewell
;
; Says goodbye to the user.
; Receives: @goodbye on the stack
; Returns: none
; Requires: none
;---------------------------------------------------------
farewell PROC
	
	push	ebp
	mov		ebp, esp
	
	call	CrLf
	displayString OFFSET goodbye
	call	CrLf
	call	CrLf

	pop		ebp
	ret		4

farewell ENDP







END main
