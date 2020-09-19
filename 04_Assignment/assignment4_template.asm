; 	Name: Ryan Aponte
; 	Section 1004
;	Date Last Modified: 09/19/2020
;	Program Description: This program will involve working with macros to
;	perform a variety of tasks related to text manipulation.

; Macro 1 - Returns the length of a given string in rax
; Argument 1: null terminated string
%macro stringLength 1
	; YOUR CODE HERE
	mov rcx, 0
	%%checkNull:
		mov bl, byte[%1+rcx]
		inc rcx	; placed here to include the +1 for NULL
		cmp bl, NULL
		je %%checkNullDone
		jmp %%checkNull
	%%checkNullDone:
	mov rax, rcx
%endmacro

; Macro 2 - Convert letters in a string to uppercase
; Argument 1: null terminated string
%macro toUppercase 1
	; YOUR CODE HERE
	mov rcx, 0
	%%stringLoop:
		mov bl, byte[%1+rcx]
		cmp bl, NULL
		je %%macro2Done
		cmp bl, 'a'
		jb %%nextChar; skip
		cmp bl, 'z'
		jae %%nextChar
	
		
		;converts to uppercase
		sub byte[%1+rcx], 32
		
		%%nextChar:
		inc rcx
		jmp %%stringLoop
		%%macro2Done:
%endmacro

; Macro 3 - Convert a Decimal String to Integer
; Argument 1: null terminated string (byte array)
; Argument 2: dword integer variable
%macro convertDecimalToInteger 2
	; YOUR CODE HERE
	; arg2 is assumed to be 0 starting value
	; bl stores byte string array value
	mov rcx, 0
	mov r9, 0			; stores sign
	%%intStringLoop:
		mov bl, byte[%1 + rcx]
		cmp bl, NULL		; if true, string has terminated; else continue
		je %%intStringLoopDone
		cmp bl, ' '		; if blank then move to next char
		je %%nextStringChar
		cmp bl, '+'
		je %%nextStringChar
		cmp bl, '-'
		je %%negativeInt		; negative value, change sign 'flag'
		; arg1 = string  (byte array)
		; arg2 - dword var
		; mul arg2 by 10, then add arg1 and store updated value. Repeat until NULL
		mov rax, 0
		mov rdx, 0
		mov r10, 0
		mov r10d, 10
		mov eax, dword[%2]
		mul r10d		; edx:eax
		mov dword[%2], eax
		; adds arg1
		mov rax, 0
		mov al, bl
		sub al, 48
		add dword[%2], eax
		
		jmp %%nextStringChar
		
	%%negativeInt:
		mov r9, -1
		
	%%nextStringChar:
		inc rcx
		jmp %%intStringLoop
		
	%%intStringLoopDone:
		cmp r9, 0
		je %%intStringDone
		mov rax, -1
		mul dword[%2]
		mov dword[%2], eax
		
	%%intStringDone:
		
%endmacro

; Macro 4 - Convert an Integer to a Hexadecimal String
; Argument 1: dword integer variable
; Argument 2: string (11 byte array)
%macro convertIntegerToHexadecimal 2
	; YOUR CODE HERE
	mov rcx, 0
	mov byte[%2], '0'
	mov byte[%2+1], 'x'
	mov byte[%2 + 10], NULL
	mov r9d, 16			; divisor
	mov r10, 9
	mov eax, dword[%1]
	%%toHexLoop:
		mov edx, 0
		div r9d
		cmp edx, 9
		ja %%addLetter
			add edx, 48
			jmp %%continueConversionLoop
		%%addLetter:
			add edx, 55
		%%continueConversionLoop:
			mov byte[%2+r10], dl
			dec r10
			cmp r10, 1
			jne %%toHexLoop
		
	
	
%endmacro

section .data
; System Service Call Constants
SYSTEM_WRITE equ 1
SYSTEM_EXIT equ 60
SUCCESS equ 0
STANDARD_OUT equ 1

; Special Characters
LINEFEED equ 10
NULL equ 0

; Macro 1 Variable
macro1Message db "This is the string that never ends, it goes on and on my friends.", LINEFEED, NULL

; Macro 1 Test Variables
macro1Label db "Macro 1: "
macro1Pass db "Pass", LINEFEED
macro1Fail db "Fail", LINEFEED
macro1Expected dq 67

; Macro 2 Variables
macro2Message db "Did you read Chapters 8, 9, and 11 yet?", LINEFEED, NULL

; Macro 2 Test Variable
macro2Label db "Macro 2: "

; Macro 3 Variables
macro3Number1 db "12345", NULL
macro3Number2 db "      +19", NULL
macro3Number3 db " -    1468     ", NULL
macro3Integer1 dd 0
macro3Integer2 dd 0
macro3Integer3 dd 0

; Macro 3 Test Variables
macro3Label1 db "Macro 3-1: "
macro3Label2 db "Macro 3-2: "
macro3Label3 db "Macro 3-3: "
macro3Pass db "Pass", LINEFEED
macro3Fail db "Fail", LINEFEED
macro3Expected1 dd 12345
macro3Expected2 dd 19
macro3Expected3 dd -1468

; Macro 4 Variables
macro4Integer1 dd 255
macro4Integer2 dd 1988650
macro4Integer3 dd -7

; Macro 4 Test Variables
macro4Label1 db "Macro 4-1: "
macro4Label2 db "Macro 4-2: "
macro4Label3 db "Macro 4-3: "
macro4NewLine db LINEFEED

section .bss
; Macro 4 Strings
macro4String1 resb 11
macro4String2 resb 11
macro4String3 resb 11

section .text
global _start
_start:

	; DO NOT ALTER _start in any way.

	mov rax, 0
	
	; Macro 1 - Do not alter
	; Invokes the macro using macro1Message as the argument
	stringLength macro1Message

	; Macro 1 Test - Do not alter
	push rax
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro1Label
	mov rdx, 9
	syscall
	
	mov rdi, STANDARD_OUT
	mov rsi, macro1Fail
	mov rdx, 5
	pop rax
	cmp rax, qword[macro1Expected]
	jne macro1_Fail
		mov rsi, macro1Pass
	macro1_Fail:
	mov rax, SYSTEM_WRITE
	syscall
	
	; Macro 2 - Do not alter
	; Invokes the macro using macro2message as the argument
	toUppercase macro2Message
	
	; Macro 2 Test - Do not alter
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro2Label
	mov rdx, 9
	syscall
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro2Message
	mov rdx, 41
	syscall
	
	; Macro 3 - 1 - Do not alter
	; Invokes the macro with macro3Number1 and macro3Integer1
	convertDecimalToInteger macro3Number1, macro3Integer1

	; Macro 3 - 2 - Do not alter
	; Invokes the macro with macro3Number2 and macro3Integer2
	convertDecimalToInteger macro3Number2, macro3Integer2
	
	; Macro 3 - 3 - Do not alter
	; Invokes the macro with macro3Number3 and macro3Integer3
	convertDecimalToInteger macro3Number3, macro3Integer3

	; Macro 3 Test - Do not alter
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro3Label1
	mov rdx, 11
	syscall
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro3Fail
	mov rdx, 5
	mov ebx, dword[macro3Integer1]
	cmp ebx, dword[macro3Expected1]
	jne macro3_1_Fail
		mov rsi, macro3Pass
	macro3_1_Fail:
	syscall
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro3Label2
	mov rdx, 11
	syscall
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro3Fail
	mov rdx, 5
	mov ebx, dword[macro3Integer2]
	cmp ebx, dword[macro3Expected2]
	jne macro3_2_Fail
		mov rsi, macro3Pass
	macro3_2_Fail:
	syscall
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro3Label3
	mov rdx, 11
	syscall
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro3Fail
	mov rdx, 5
	mov ebx, dword[macro3Integer3]
	cmp ebx, dword[macro3Expected3]
	jne macro3_3_Fail
		mov rsi, macro3Pass
	macro3_3_Fail:
	syscall
	
	; Macro 4 - 1 - Do not alter
	convertIntegerToHexadecimal macro4Integer1, macro4String1
	
	; Macro 4 - 2 - Do not alter
	convertIntegerToHexadecimal macro4Integer2, macro4String2
	
	; Macro 4 - 3 - Do not alter
	convertIntegerToHexadecimal macro4Integer3, macro4String3

	; Macro 4 Test - Do not alter	
	; Test 1
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro4Label1
	mov rdx, 11
	syscall
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro4String1
	mov rdx, 11
	syscall	
		
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro4NewLine
	mov rdx, 1
	syscall	
	
	; Test 2
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro4Label2
	mov rdx, 11
	syscall
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro4String2
	mov rdx, 11
	syscall	
		
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro4NewLine
	mov rdx, 1
	syscall	
	
	; Test 3
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro4Label3
	mov rdx, 11
	syscall
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro4String3
	mov rdx, 11
	syscall	
		
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro4NewLine
	mov rdx, 1
	syscall	
	
endProgram:
	mov rax, SYSTEM_EXIT
	mov rdi, SUCCESS
	syscall
