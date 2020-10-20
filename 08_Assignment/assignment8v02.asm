; 	Ryan Aponte
;	Section 1004
;	Date Last Modified: 10/19/2020
;	Program Description: This assignment will explore 
;	the use of accessing functions from a library and 
;	processing command line arguments.
;	WITH EXTRA CREDIT

section .data

	SYSTEM_EXIT equ 60
	SYS_WRITE equ 1
	SUCCESS equ 0
	STANDARD_OUT equ 1
	
	LINEFEED equ 10
	NULL equ 0
	
	message db "Enter -d <number>, or -r <number> after the program name.", LINEFEED, NULL	; 59
	invalidTag db "Invalid diameter tag.", LINEFEED, NULL	; 23
	halfVolumeMessage db "Halfsphere Volume: %f", LINEFEED, NULL
	volumeMessage db "Fullsphere Volume: %f", LINEFEED, NULL
	invalidDiameter db "Invalid numeric format for diameter.", LINEFEED, NULL	; 38
	invalidRadius db "Invalid numeric format for radius.", LINEFEED, NULL
	
	PI dq 3.14159
	divisor dq 2.0
	three dq 3.0
	zero dq 0.0

section .bss
	

extern atof, printf

section .text
global main
main:
	sub rsp, 8

	mov r12, rdi	;	count / argc
	mov r13, rsi	;	address of table of arguments / argv
	movsd xmm4, qword[zero]
	; check for 3 arguments total, else print error and end
	cmp r12, 3
	je correctArgs
		mov rax, SYS_WRITE
		mov rdi, STANDARD_OUT
		mov rsi, message
		mov rdx, 59
		syscall
		jmp done
	; correct # of arguments
	correctArgs:
	
	; check for correct "-d" flag
	mov rax, qword[r13+8]
	cmp word[rax], "-d"
	je dFlag
		cmp word[rax], "-r"
		je rFlag
		; if wrong, print error and end
		mov rax, SYS_WRITE
		mov rdi, STANDARD_OUT
		mov rsi, invalidTag
		mov rdx, 23
		syscall
		jmp done
	
	dFlag:
	;mov rbx, qword[r13+16]
	; now rbx is at [2], or position 3 of array of arguments
	mov rdi, qword[r13+16]
	call atof

	; calculate diameter
	; xmm0 is result
	; xmm1 is 2
	; xmm2 is radius
	; xmm3 is 3
	; xmm3 is PI
	movsd xmm1, qword[divisor]
	divsd xmm0, xmm1	; radius = diameter / 2
	movsd xmm2, xmm0
	mulsd xmm0, xmm2	;	 r * r
	mulsd xmm0, xmm2	;	r^2 * r
	movsd xmm3, qword[PI]
	mulsd xmm0, xmm3	;	r^3 * PI
	mulsd xmm0, xmm1	;	r^3 * PI * 2
	movsd xmm3, qword[three]
	divsd xmm0, xmm3
	; check if valid number
	ucomisd xmm0, xmm4
	je invalidDiameterFormat
	
	; setup print variables
	mov rax, 1
	mov rdi, halfVolumeMessage
	mov rsi, 1
	call printf
	jmp done
	
	rFlag:
	; now rbx is at [2], or position 3 of array of arguments
	mov rdi, qword[r13+16]
	call atof

	; calculate diameter
	; xmm0 is result
	; xmm1 is 2
	; xmm2 is radius
	; xmm3 is 3
	; xmm3 is PI
	movsd xmm1, qword[divisor]
	movsd xmm2, xmm0
	mulsd xmm0, xmm2	;	 r * r
	mulsd xmm0, xmm2	;	r^2 * r
	movsd xmm3, qword[PI]
	mulsd xmm0, xmm3	;	r^3 * PI
	mulsd xmm0, xmm1	;	r^3 * PI * 2
	movsd xmm3, qword[three]
	divsd xmm0, xmm3
	; check if valid number
	ucomisd xmm0, xmm4
	je invalidRadiusFormat
	
	; setup print variables
	mov rax, 1
	mov rdi, volumeMessage
	mov rsi, 1
	call printf
	jmp done
	
	invalidDiameterFormat:
	mov rax, SYS_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, invalidDiameter
	mov rdx, 38
	syscall
	jmp done
	
	invalidRadiusFormat:
	mov rax, SYS_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, invalidRadius
	mov rdx, 36
	syscall
	
	done:
	add rsp, 8
	mov rax, SYSTEM_EXIT
	mov rdi, SUCCESS
	syscall