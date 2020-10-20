section .data

	SYSTEM_EXIT equ 60
	SYS_WRITE equ 1
	SUCCESS equ 0
	STANDARD_OUT equ 1
	
	LINEFEED equ 10
	NULL equ 0
	
	message db "Enter -d <number> after the program name.", LINEFEED, NULL
	invalidTag db "Invalid diameter tag.", LINEFEED, NULL
	dFlag db "-d", NULL
	
extern atof, printf

section .bss
	argc resq 0
	argv resq 0

extern atof, printf

section .text
global main
main:
	sub rsp, 8

	mov r12, rdi	;	count / argc
	mov r13, rsi	;	address of table of arguments / argv
	
	; check for 3 arguments total, else print error and end
	cmp r12, 3
	je correctArgs
		mov rax, 1
		mov rdi, 1
		mov rsi, message
		mov rdx, 43
		syscall
		jmp done
	; correct # of arguments
	correctArgs:
	
	; check for correct "-d" flag
	mov rax, qword[r13+8]
	cmp word[rax], "-d"
	je correctFlag
		; if wrong print error and end
		mov rax, SYS_WRITE
		mov rdi, STANDARD_OUT
		;mov rbx, qword[r13]
		mov rsi, invalidTag
		mov rdx, 23
		syscall
		jmp done
	
	correctFlag:
	
	
	done:
	add rsp, 8
	mov rax, SYSTEM_EXIT
	mov rdi, SUCCESS
	syscall