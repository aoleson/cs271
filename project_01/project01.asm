TITLE A Simple Calculator     (project01.asm)

; Author: Alannah Oleson
; Email: olesona@oregonstate.edu
; Class number/section: CS271-001
; Project #1
; Due date: 1/17/2016
;
; Description: This program introduces the programmer, tells the user how
;	to use the calculator, prompts the user to enter two numbers, and
;	calculates and displays the sum, difference, product, and quotient,
;	then finally says goodbye. 
;   Also, if the first number is not larger than the second number, the program
;   displays a message and exits.
;
; Collaborators: I got help from Chris Mendez (not in this class--he took it last year) 
;   regarding why my numbers were printing out instead of my strings. He told me that 
;   while writeDec reads from eax, writeString reads from edx, which allowed me to fix
;   my problem.
;   Also, I used the code example given on canvas in project00.asm (dog years calculator)
;   as a reference for how to output strings and how to multiply.

INCLUDE Irvine32.inc

.data

intro        BYTE    "    Simple Calculator--Program #1    by Alannah Oleson    CS 271", 0   ;The programmer introduction
ex_cred		 BYTE	"**EC: Program verifies that the second number is less than the first.", 0   ;EC explanation
how_to       BYTE    "Hello! Welcome to the assembly language calculator. Enter two numbers and I'll display the sum, difference, product, and quotient.", 0   ;How to use the program

prompt_1     BYTE    "Enter 1st number: ", 0   ;First prompt
first_num    DWORD   ?   ;First num to be entered by user
prompt_2     BYTE    "Enter 2nd number: ", 0   ;Second prompt
second_num   DWORD   ?   ;Second num to be entered by user

sorry		 BYTE	 "Sorry, the second number must be less than the first! Bye ", 0   ;To display if numbers fail validation (**EC)

my_sum       DWORD   ?   ;Sum of the two nums
my_dif       DWORD   ?   ;Difference of the two nums
my_prod      DWORD   ?   ;Product of the two nums
my_quo       DWORD   ?   ;Quotient of the two nums
my_rem		 DWORD	 ?	 ;Remainder after division

plus_sign    BYTE    " + ", 0           ;Plus sign for formatting
minus_sign   BYTE    " - ", 0           ;Minus sign for formatting
mult_sign    BYTE    " x ", 0           ;Multiplication sign for formatting
div_sign     BYTE    " / ", 0           ;Division sign for formatting
eq_sign      BYTE    " = ", 0           ;Equals sign for formatting
rem_word	 BYTE	 " remainder ", 0   ;Word for formatting

goodbye      BYTE    "Wow, that was some exciting math!! :D Bye", 0   ;Goodbye string


.code
main PROC
	
;Introduce yourself and the course
	mov		edx, OFFSET intro
	call	WriteString
	call	CrLf
	call	CrLf
	
;Explain extra credit
	mov		edx, OFFSET ex_cred
	call	WriteString
	call	CrLf
	call	CrLf

;Explain how to use the program
	mov		edx, OFFSET how_to
	call	WriteString
	call	CrLf
	call	CrLf



;Prompt for the first number/store in variable
	mov		edx, OFFSET prompt_1
	call	WriteString
	call	ReadInt
	mov		first_num, eax

;Prompt for the second number/store in variable
	mov		edx, OFFSET prompt_2
	call	WriteString
	call	ReadInt
	mov		second_num, eax



;Check if second number is smaller than first. If it is larger than the first (invalid), print a message and jump over the calculations.
	mov		eax, second_num
	cmp		eax, first_num
	jl		nums_okay			;If valid, do calculations

	;If second number is greater than first, give alternate goodbye and skip calculations
	call	CrLf
	mov		edx, OFFSET sorry
	call	WriteString
	call	CrLf
	call	CrLf
	jmp		the_end



;Jump here if second number is smaller than first (and do the calculations)
nums_okay:

;Calculate sum and store in variable
	mov		eax, first_num
	mov		ebx, second_num
	add		eax, ebx		
	mov		my_sum, eax

;Calculate difference and store in variable
	mov		eax, first_num
	mov		ebx, second_num
	sub		eax, ebx		
	mov		my_dif, eax

;Calculate product and store in variable
	mov		eax, first_num
	mov		ebx, second_num
	mul		ebx		
	mov		my_prod, eax

;Calculate quotient (and remainder) and store in variable
	mov		edx, 0
	mov		eax, first_num
	mov		ebx, second_num
	div		ebx		
	mov		my_quo, eax
	mov		my_rem, edx



;Display the results

	call	CrLf

	;Display the sum
	mov		eax, first_num
	call	WriteDec
	mov		edx, OFFSET plus_sign
	call	WriteString
	mov		eax, second_num
	call	WriteDec
	mov		edx, OFFSET eq_sign
	call	WriteString
	mov		eax, my_sum
	call	WriteDec
	call	CrLf

	;Display the difference
	mov		eax, first_num
	call	WriteDec
	mov		edx, OFFSET minus_sign
	call	WriteString
	mov		eax, second_num
	call	WriteDec
	mov		edx, OFFSET eq_sign
	call	WriteString
	mov		eax, my_dif
	call	WriteDec
	call	CrLf

	;Display the product
	mov		eax, first_num
	call	WriteDec
	mov		edx, OFFSET mult_sign
	call	WriteString
	mov		eax, second_num
	call	WriteDec
	mov		edx, OFFSET eq_sign
	call	WriteString
	mov		eax, my_prod
	call	WriteDec
	call	CrLf

	;Display the difference with remainder
	mov		eax, first_num
	call	WriteDec
	mov		edx, OFFSET div_sign
	call	WriteString
	mov		eax, second_num
	call	WriteDec
	mov		edx, OFFSET eq_sign
	call	WriteString
	mov		eax, my_quo
	call	WriteDec
	mov		edx, OFFSET rem_word
	call	WriteString
	mov		eax, my_rem
	call	WriteDec
	call	CrLf
	call	CrLf

	

;Say goodbye
	mov		edx, OFFSET goodbye
	call	WriteString
	call	CrLf
	call	CrLf

;Jump here if 2nd number was not smaller than 1st (and thus invalid), skipping calculations
the_end:

	exit	; exit to operating system

main ENDP

; (insert additional procedures here)

END main
