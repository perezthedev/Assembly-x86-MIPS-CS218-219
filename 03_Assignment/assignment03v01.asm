; Author: Ryan Aponte
; Section: 1004
; Date Last Modified: 09/07/2020
; Program Description: This assignment will cover the use of loops and
; conditional code created from jump instructions to work
; with arrays.

section .data
; System service call values
SERVICE_EXIT equ 60
SERVICE_WRITE equ 1
EXIT_SUCCESS equ 0
STANDARD_OUT equ 1
NEWLINE equ 10

programDone db "Program Done.", NEWLINE 
stringLength dq 14

; declare variables here

; double word lists
list1 dd 2078, 3854, 6593, 947, 5252, 1190, 716, 3587, 8014, 9563

	dd 9821, 3195, 1051, 6454, 5752, 980, 9015, 2478, 5624, 7251

	dd 2936, 1073, 1731, 5376, 4452, 792, 2375, 2542, 5666, 2228

	dd 454, 2379, 6066, 3340, 2631, 9138, 3530, 7528, 7152, 1551

	dd 9537, 9590, 2168, 9647, 5362, 2728, 5939, 4620, 1828, 5736
	
	
list2 dd 5087, 6614, 6035, 6573, 6287, 5624, 4240, 3198, 5162, 6972

	dd 6219, 1331, 1039, 23, 4540, 2950, 2758, 3243, 1229, 8402

	dd 8522, 4559, 1704, 4160, 6746, 5289, 2430, 9660, 702, 9609

	dd 8673, 5012, 2340, 1477, 2878, 2331, 3652, 2623, 4679, 6041

	dd 4160, 2310, 5232, 4158, 5419, 2158, 380, 5383, 4140, 1874
	
oddCount db 0	; byte
evenCount db 0
minimum dd 9999	; double, will decrease when it gets compared
maximum dd 0
average dd 0
sum dq 0			; quadword

LIST_LENGTH equ 50

section .bss

; double word list3
list3 resd 50

section .text
global _start
_start:

	mov rcx, LIST_LENGTH
	mov rdx, 0
	mov rbx, 0	; index counter
	mov r8d, 2
	list3Loop:
		mov eax, dword[list1+rbx*4]
		add eax, dword[list2+rbx*4]	; adds list1 + list2 in rbx position
		div r8d			; list3[rbx] inside eax, rem in edx
		mov dword[list3+rbx*4], eax	; saved in list3
		div r8d	; to test if list3 value even/odd; don't save, just check!
		
		; check even/odd and set next iteration
		cmp edx, 0
		jne isOdd
			inc byte[evenCount]
			jmp evenOddDone
		isOdd:
			inc byte[oddCount]
			
		evenOddDone:
			inc rbx
			mov rdx, 0
	loop list3Loop
	
	;	loop used to get the rest of list 3 stats
	;	list 3 is double
	;	sum is quadword
	;	min, max, avg are double
	
	mov rcx, LIST_LENGTH
	mov rbx, 0	; index counter
	
	otherStatsLoop:
		mov r8d, dword[list3+rbx*4]	; zeros out upper bits
		add qword[sum], r8
		cmp r8d, dword[maximum]
		jbe notMax						; if r8d <= max true, not the max number
			mov dword[maximum], r8d
			jmp checkedMaxMin
		notMax:
			cmp r8d, dword[minimum]
			jae checkedMaxMin		; if r8d >= min is true, then not min
				mov dword[minimum], r8d
		checkedMaxMin:
		inc rbx
	loop otherStatsLoop
	
	; avg
	mov rdx, 0
	mov rax, qword[sum]
	mov rbx, LIST_LENGTH
	div rbx
	mov dword[average], eax

; Outputs "Program Done." to the console
	mov rax, SERVICE_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, programDone
	mov rdx, qword[stringLength]
	syscall

; Ends program with success return value
last:
	mov rax, SERVICE_EXIT
	mov rdi, EXIT_SUCCESS
	syscall