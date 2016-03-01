TITLE Composite Number Printer     (projecct_04.asm)

; Author: Alannah Oleson
; Email: olesona@oregonstate.edu
; Class number/section: CS271-001
; Project #4
; Due date: 2/14/16
;
; Description: This program calculates and displays composite numbers -- as many as the user wants, 
;   between 1-400. It introduces the programmer and the program, then takes (and validates) a number
;   of terms to display from the user. The program displays all numbers up to and including that 
;   number of composites. Results are 10 per line.
;
; Collaborators: I used http://sample-c-codes.blogspot.com/2012/10/composite-numbers.html to help
;   figure out the algorithm to determine if a number was composite.

INCLUDE Irvine32.inc

UPPER_LIMIT = 400   ;Define the constant for the upper limit
LOWER_LIMIT = 1     ;Define the constant for the lower limit


.data

intro         BYTE    "    Project #4 - Composite Number Printer   by Alannah Oleson    CS 271", 0   ;The programmer introduction
how_to        BYTE    "Enter a number between 1 and 400 and I will display that many composite numbers. ", 0   ;Instructions to use the program

num_prompt    BYTE    "How many composite numbers do you want?: ", 0						 ;Prompt for user input number
out_of_range  BYTE    "Out of range! Please enter a number in the range [1, 400]", 0		 ;Error message when user gives invalid number
user_num      DWORD   ?																		 ;Amount of terms to display, entered by user


factor		  DWORD   0			;The largest factor that goes into the number being tested
num_is_comp	  DWORD   0			;Status variable to check whether the number is composite
curr		  DWORD   0			;Keep track of the current number being tested

spaces        BYTE    "     ", 0		;Spaces for formatting
how_many	  DWORD   0					;Keep track of how many numbers you've printed, for line breaks

goodbye       BYTE    "Wow, that was some exciting math!! :D Bye", 0   ;Goodbye string


.code

;---------------------------------------------------------
; main
;
; Main procedure of the program. Calls other procedures.
; Receives: none
; Returns: none
; Requires: none
;---------------------------------------------------------
main PROC

	call	introduction
	call	getUserData
	call	showComposites
	call	farewell

	exit	; exit to operating system
main ENDP


;---------------------------------------------------------
; introduction
;
; Introduces the programmer and how to use the program.
; Receives: none
; Returns: none
; Requires: none
;---------------------------------------------------------
introduction PROC

	;Display the program title and the programmer's name
	mov		edx, OFFSET intro
	call	WriteString
	call	CrLf
	call	CrLf

	;Tell the user how to use the program
	mov		edx, OFFSET how_to
	call	WriteString
	call    CrLf
	call    CrLf

	ret

introduction ENDP



;---------------------------------------------------------
; getUserData
;
; Prompts the user for a number between 1 and 400 and checks that
;   the answer is valid.
; Receives: none
; Returns: If input is valid, user_num=an integer in [1, 400]
; Requires: none
;---------------------------------------------------------
getUserData PROC
	
	begin_loop:

		;Prompt for the number of terms to be displayed (range 1-400, inclusive)
		mov		edx, OFFSET num_prompt
		call	WriteString
		call	ReadInt

		;Validate the data
		mov		ebx, 0
		call	validate

		;If input is valid, assign it to user_num
		cmp		ebx, 0								;If ebx=1, it is valid. If ebx=0, it is not valid.
		je		invalid_message
		mov		user_num, eax
		jmp		end_loop

		;Else, display a message and ask again
		invalid_message:
			mov		edx, OFFSET out_of_range
			call	WriteString
			call	CrLf
			call	CrLf
			jmp		begin_loop

	end_loop:
	ret

getUSerData ENDP


;---------------------------------------------------------
; validate
;
; Checks that the user's input is valid.
; Receives: EAX (the user's input)
; Returns: EBX = 1 if valid, 0 if not valid
; Requires: none
;---------------------------------------------------------
validate PROC
	
	;Check if it's too big
	cmp		eax, UPPER_LIMIT
	jg		is_not_valid

	;Check if it's too small
	cmp		eax, LOWER_LIMIT
	jl		is_not_valid

	;If none of the jumps triggered, it's valid, so set EBX=1 and jump over is_not_valid
	mov		ebx, 1
	jmp		end_validate_proc

	;If it was invalid, set EBX=0
	is_not_valid:
	mov		ebx, 0

	end_validate_proc:
	ret

validate ENDP


;---------------------------------------------------------
; showComposites
;
; Displays the composite numbers up to the number of terms the user input.
; Receives: none
; Returns: none
; Requires: User's number of terms must be between 1-400
;---------------------------------------------------------
showComposites PROC
	
	;Set up
	mov		how_many, 0
	mov		curr, 4
	mov		factor, 0

	;Start looping
	begin_outer_loop:
		
		;Check if the number is composite
		mov		num_is_comp, 0
		call	isComposite
		cmp		num_is_comp, 1
		jne		end_of_showComposites

		;If the above jump didn't trigger, the number is composite, so print it
		mov		eax, curr
		call	writeDec
		mov		edx, OFFSET spaces
		call	writeString
		inc		how_many

		;Check whether you need to print a line break
		mov		edx, 0
		mov		eax, how_many
		mov		ebx, 10
		div		ebx
		cmp		edx, 0
		
		;If the remainder isn't 0, then skip printing the line break
		jne		end_of_showComposites

		;Else, print the line break and fall through to loop_cmd
		call	CrLf


	end_of_showComposites:
		;Check whether you've printed enough or if you need to keep looping
		inc		curr
		mov		eax, user_num
		cmp		how_many, eax
		jne		begin_outer_loop

		;Else, you're done printing, so return
		ret
		

showComposites ENDP


;---------------------------------------------------------
; isComposite
;
; Determines whether the number is composite.
; Receives: none
; Returns: num_is_comp = 1 if composite, 0 if not composite
; Requires: none
;---------------------------------------------------------
isComposite PROC
	
	;Set up
	mov		ecx, curr
	dec		ecx			;B/c you don't want to test if the num is a factor of itself

	begin_inner_loop:
		
		;Check if the counter is a factor of the number you're testing
		mov		edx, 0
		mov		eax, curr
		mov		ebx, ecx
		div		ebx
		
		;If it's a factor, store the value and break out of the loop
		cmp		edx, 0
		jne		inner_loop_cmd
		mov		factor, ebx
		jmp		end_inner_loop

		;Jump here if the number wasn't a factor and you need to look for another
		inner_loop_cmd:
			loop	begin_inner_loop

	end_inner_loop:
	
	;Check if factor > 1. If it is, the number is composite, so set the status var accordingly
	cmp		factor, 1
	jle		end_of_isComposite
	mov		num_is_comp, 1


	end_of_isComposite:
		ret

isComposite ENDP


;---------------------------------------------------------
; farewell
;
; Says goodbye to the user.
; Receives: none
; Returns: none
; Requires: none
;---------------------------------------------------------
farewell PROC
	
	call	CrLf
	call	CrLf
	mov		edx, OFFSET goodbye
	call	WriteString
	call	CrLf
	call	CrLf

	ret

farewell ENDP



END main
