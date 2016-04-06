TITLE Program Template     (template.asm)

; Author: Alannah Oleson
; Email: olesona@oregonstate.edu
; Class number/section: CS271-001
; Project #????
; Due date: ???
;
; Description: ???
;
; Collaborators: ???

INCLUDE Irvine32.inc

; (insert constant definitions here)

.data
tracker		DWORD	1
print_to	DWORD	1
star		BYTE	"*", 0

.code
main PROC

mov		ecx, 5

start_loop:
	mov		eax, print_to
	cmp		eax, tracker
	jl		print_star

	mov		eax, tracker
	call	writeDec
	inc		tracker
	jmp		loop_cmd


print_star:

	mov		edx, OFFSET star
	call	writeString

loop_cmd:
	mov		tracker, 1
	inc		print_to
	call	CrLf
	loop	start_loop
	

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
