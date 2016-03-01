TITLE  Macros, Values, and Strings    (project_06a.asm)

; Author: Alannah Oleson
; Email: olesona@oregonstate.edu
; Class number/section: CS271-001
; Project #6a
; Due date: 3/12/16
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
; Collaborators: ???

INCLUDE Irvine32.inc

; (insert constant definitions here)

.data

; (insert variable definitions here)

.code
main PROC

; (insert executable instructions here)

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
