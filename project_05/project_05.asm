TITLE Array Sorting and Random Numbers     (project_05.asm)

; Author: Alannah Oleson
; Email: olesona@oregonstate.edu
; Class number/section: CS271-001
; Project #5
; Due date: 2/28/16
;
; Description: Write and test a MASM program to perform the following tasks:
;   1. Introduce the program.
;   2. Get a user request in the range [min = 10 .. max = 200].
;   3. Generate request random integers in the range [lo = 100 .. hi = 999], storing them in consecutive elements
;   of an array.
;   4. Display the list of integers before sorting, 10 numbers per line.
;   5. Sort the list in descending order (i.e., largest first).
;   6. Calculate and display the median value, rounded to the nearest integer.
;   7. Display the sorted list, 10 numbers per line.
;
; Collaborators: I used the week 7 lectures (code and concepts) for stack manipulation, parameter passing, and 
;   random array generation and sorting.

INCLUDE Irvine32.inc

MIN = 10		;Constant for low user input
MAX = 200		;Constant for high user input
LO = 100		;Constant for lowest random number
HI = 999		;Constant for highest random number
MAX_SIZE = 200	;Constant for largest array can be


.data

intro         BYTE    "    Project #5 - Filling and Sorting Arrays   by Alannah Oleson    CS 271", 0   ;The programmer introduction
how_to        BYTE    "This program generates pseudorandom numbers in [100, 999]. Enter a number in [10, 200] and I will generate that many random numbers, print the list, sort it, then print the sorted list and its median. ", 0   ;Instructions to use the program

num_prompt    BYTE    "How many numbers shall I generate?: ", 0								 ;Prompt for user input number
out_of_range  BYTE    "Out of range! Please enter a number in the range [10, 200]", 0		 ;Error message when user gives invalid number
request		  DWORD   ?																		 ;Amount of terms to display, entered by user

list		  DWORD	  MAX_SIZE DUP(?)				;The array to fill

title1		  BYTE   "The unsorted random numbers: ", 0		;To display before sorting
title2		  BYTE	 "The sorted array: ", 0				;To display after sorting
spaces		  BYTE   "    ", 0								;Formatting
how_many	  DWORD   0										;Keep track of how many numbers you've printed, for line breaks
med_line	  BYTE   "The median of the list is ", 0		;To display the median

goodbye       BYTE    "Wow, that was some exciting sorting!! :D Bye", 0   ;Goodbye string


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
	
	call	Randomize		;seed the RNG
	
	push	OFFSET how_to
	push	OFFSET intro
	call	introduction

	push	OFFSET request
	call	getData

	push	OFFSET list
	push	request
	call	fillArray

	push	OFFSET title1
	push	request
	push	OFFSET list
	call	displayList

	push	OFFSET list
	push	request
	call	sortList

	push	OFFSET list
	push	request
	call	displayMedian

	push	OFFSET title2
	push	request
	push	OFFSET list
	call	displayList

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

	;Display the program title and the programmer's name
	mov		edx, [ebp + 8]		;intro
	call	WriteString
	call	CrLf
	call	CrLf

	;Tell the user how to use the program
	mov		edx, [ebp + 12]		;how_to
	call	WriteString
	call    CrLf
	call    CrLf

	pop		ebp			;Clean up the stack
	ret		8

introduction ENDP


;---------------------------------------------------------
; getData
;
; Gets input from the user and makes sure it is valid.
; Receives: @request on the stack; num_prompt and out_of_range are globals
; Returns: request contains a valid integer in [MIN, MAX]
; Requires: request is a DWORD
;---------------------------------------------------------
getData	PROC
	
	;Set up for the loop: do normal proc setup and move the address of request into ebx
	push	ebp
	mov		ebp, esp
	mov		ebx, [ebp + 8]

	begin_loop:

		;Prompt for the number of terms to be displayed
		mov		edx, OFFSET num_prompt
		call	WriteString
		call	ReadInt

		;Check if it's too big
		cmp		eax, MAX
		jg		invalid_message

		;Check if it's too small
		cmp		eax, MIN
		jl		invalid_message

		;If none of the jumps triggered, it's valid, so set assign the value in eax to the request var
		mov		[ebx], eax
		jmp		end_loop

		;Else, display a message and ask again
		invalid_message:
			mov		edx, OFFSET out_of_range
			call	WriteString
			call	CrLf
			call	CrLf
			jmp		begin_loop

	end_loop:

	pop		ebp			;Clean up the stack
	ret		4			;Only pushed on one address

getData ENDP


;---------------------------------------------------------
; fillArray
;
; Fills a passed array with random numbers in [100, 999]
; Receives: request (val) on the stack; @list on the stack
; Returns: list contains (request) random numbers
; Requires: list is an array of 200 DWORDs; request is valid
;---------------------------------------------------------
fillArray PROC
	
	;Set up for proc and loop
	push	ebp
	mov		ebp, esp
	mov		ecx, [ebp + 8]		;Request
	mov		esi, [ebp + 12]		;list

	fill_loop:
		
		;Generate the random number (code from slides)
		mov		eax, HI
		sub		eax, LO
		inc		eax
		call	RandomRange
		add		eax, LO

		;Stick the number in the array
		mov		[esi], eax
		add		esi, 4			;Move esi to point to the next open slot
		loop	fill_loop

	pop		ebp			;Clean up the stack
	ret		8

fillArray ENDP


;---------------------------------------------------------
; displayList
;
; Displays the contents of an array.
; Receives: @title on the stack; request on the stack; @list on the stack; spaces and how_many are globals
; Returns: none
; Requires: request is valid and the array is filled with random numbers
;---------------------------------------------------------

displayList PROC
	
	;Set up for proc and init variables
	push	ebp
	mov		ebp, esp
	mov		esi, [ebp + 8]		;list
	mov		ecx, [ebp + 12]		;request
	mov		edx, [ebp + 16]		;title1
	mov		how_many, 0

	;Display the title
	call	CrLf
	call	WriteString
	call	CrLf

	display_loop:
		
		;Display the current number and spaces
		mov		eax, [esi]
		call	WriteDec
		mov		edx, OFFSET spaces
		call	WriteString
		inc		how_many

		;Check whether you need to print a line break
		mov		edx, 0
		mov		eax, how_many
		mov		ebx, 10
		div		ebx
		cmp		edx, 0

		;If the remainder isn't 0, then skip printing the line break
		jne		end_display_loop

		;Else, print the line break and fall through to loop_cmd
		call	CrLf

	end_display_loop:

		;Keep track of how many you've printed and move esi to the next element
		add		esi, 4
		loop	display_loop

	call	CrLf
	call	CrLf

	pop		ebp			;Clean up the stack
	ret		12

displayList ENDP


;---------------------------------------------------------
; sortList
;
; Sorts the integer array in descending order.
; Receives: @list on the stack; request on the stack
; Returns: the array list is sorted in descending order
; Requires: request is valid and the array is filled with random numbers
;---------------------------------------------------------
sortList PROC
	
	;Set up for proc and init variables
	push	ebp
	mov		ebp, esp
	mov		ecx, [ebp + 8]		;request
	mov		esi, [ebp + 12]		;list
	dec		ecx					;To set up outer loop

	;Start the outer loop
	outer_loop:
		
		;Get current element and init/save variables
		mov		eax, [esi]
		mov		edx, esi		; i=k
		push	ecx

		;Start the inner loop
		inner_loop:
			
			;Compare list[j] to list[i]
			mov		ebx, [esi + 4]			;list[j]
			mov		eax, [edx]				;list[i]
			cmp		eax, ebx

			;If eax >= ebx, you don't need to swap: jump over it
			jge		do_not_swap

			;Else, push parameters and swap
			add		esi, 4
			push	esi
			push	edx
			push	ecx
			call	exchange
			sub		esi, 4

			do_not_swap:
			add		esi, 4
			loop	inner_loop

		;End the inner loop and restore outer loop stuff
		pop		ecx
		mov		esi, edx
		add		esi, 4
		loop	outer_loop


	pop		ebp			;Clean up the stack
	ret		8

sortList ENDP


;---------------------------------------------------------
; exchange
;
; Swaps the two passed parameters' locations in the array.
; Receives: list[i] and list[j] on the stack
; Returns: the two numbers are swapped
; Requires: none
;---------------------------------------------------------
exchange PROC
	
	;Save registers and init variables
	push	ebp
	mov		ebp, esp
	pushad
	mov		eax, [ebp + 16]		;list[j]
	mov		ebx, [ebp + 12]		;list[i]
	mov		edx, eax
	sub		edx, ebx

	;Swap the two numbers and stick them back in the array
	mov		esi, ebx
	mov		ecx, [ebx]
	mov		eax, [eax]
	mov		[esi], eax
	add		esi, edx
	mov		[esi], ecx

	;Restore vars and clean up the stack
	popad
	pop		ebp
	ret		12

exchange ENDP


;---------------------------------------------------------
; displayMedian
;
; Calculates and displays the median of the list
; Receives: @list and request, on the stack; med_line is a global
; Returns: none
; Requires: none
;---------------------------------------------------------
displayMedian PROC
	
	;Set up for proc and init variables
	push	ebp
	mov		ebp, esp
	mov		eax, [ebp + 8]		;Request
	mov		esi, [ebp + 12]		;list 

	;Check if the number of elements is even
	mov		edx, 0
	mov		ebx, 2
	div		ebx
	cmp		edx, 0
	je		is_even

	;Else, it's odd, so just count to the middle and display
	mov		ebx, 4
	mul		ebx
	add		esi, eax
	mov		eax, [esi]
	jmp		display_the_num

	;If it's even, average the two middle elements
	is_even:
	mov		ebx, 4
	mul		ebx
	add		esi, eax
	mov		eax, [esi]
	add		eax, [esi - 4]
	mov		edx, 0
	mov		ebx, 2
	div		ebx

	display_the_num:				;At this point eax should contain the median
	mov		edx, OFFSET med_line
	call	writeString
	call	writeDec
	call	CrLf
	call	CrLf

	
	pop		ebp			;Clean up the stack
	ret		8

displayMedian ENDP


;---------------------------------------------------------
; farewell
;
; Says goodbye to the user.
; Receives: none
; Returns: none
; Requires: none
;---------------------------------------------------------
farewell PROC
	
	mov		edx, OFFSET goodbye
	call	WriteString
	call	CrLf
	call	CrLf

	ret

farewell ENDP






END main
