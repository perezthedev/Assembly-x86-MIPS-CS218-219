; Ryan Aponte
; Section 1004
; Date Last Modified: September 27, 2020
; Program Description: The program will read in a list of decimal values and
; output their hexadecimal equivalents.

; Purpose: In this assignment we will be using system service
; calls to interact with the terminal window and input
; redirection. Error checking will be performed on the input
 ;to ensure proper program execution.

;	Determines the number of characters (including null) of the provided string
;	Argument 1: Address of string
;	Returns length in rdx
%macro findLength 1
	push rcx
	
	mov rdx, 1
	%%countLettersLoop:
		mov cl, byte[%1 + rdx - 1]
		cmp cl, NULL
		je %%countLettersDone
		
		inc rdx
	loop %%countLettersLoop
	%%countLettersDone:
	
	pop rcx
%endmacro

;	Outputs error message and stops program execution
;	Argument 1: Address of error message
%macro endOnError 1
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, %1
	findLength %1	; rdx set by macro findLength
	syscall
	
	jmp endProgram
%endMacro

; Argument 1: null terminated string (byte array)
; Argument 2: dword integer variable
%macro convertDecimalToInteger 2
	; YOUR CODE HERE
	; arg2 is assumed to be 0 starting value
	; bl stores byte string array value
	mov rcx, 0
	mov r9, 0			; stores sign
	mov qword[%2], 0
	%%intStringLoop:
		mov bl, byte[%1 + rcx]
		cmp bl, LINEFEED		; if true, string has terminated; else continue
		je %%intStringLoopDone
		cmp bl, NULL		; if true, string has terminated; else continue
		je %%intStringLoopDone
		cmp bl, ' '		; if blank then move to next char
		je %%nextStringChar
		cmp bl, '+'
		je %%nextStringChar
		cmp bl, '-'
		je %%negativeInt		; negative value, change sign 'flag'
		; check if NOT A-Z's or a-z's (check if not in alphabet)
		cmp bl, ':'			
		jge %%stringContainsLetter
		cmp bl, '/'
		jle %%stringContainsLetter
		
		; string has been checked, all clear
		
		; arg1 = string  (byte array)
		; arg2 - dword var
		; mul arg2 by 10, then add arg1 and store updated value. Repeat until NULL
		mov rax, 0
		mov rdx, 0
		mov r10, 0
		mov r10d, 10
		mov eax, dword[%2]
		imul r10d		; edx:eax
		mov dword[%2], eax
		; adds arg1
		mov rax, 0
		mov al, bl
		sub al, 48
		add dword[%2], eax
		
		jmp %%nextStringChar
	
	%%stringContainsLetter:
		endOnError errorStringUnexpected
	
	%%negativeInt:
		mov r9, -1
		
	%%nextStringChar:
		inc rcx
		jmp %%intStringLoop
		
	%%intStringLoopDone:
		cmp r9, 0
		je %%intStringDone
		mov rax, -1
		imul dword[%2]
		mov dword[%2], eax
		
	%%intStringDone:
		
%endmacro

; reads in from input one character at a time into arg1
; arg1  string buffer
; arg2  string buffer size
%macro readInCharacterAtTime 2
	mov rbx, 0
	mov rsi, %1
	%%inputLoop:
		mov rax, SYSTEM_READ
		mov rdi, STANDARD_IN
		mov rdx, 1		; reads in one char at a time
		syscall
		
		inc rsi			;inc until LINEFEED hit
		cmp byte[rsi-1], LINEFEED
		je %%inputDone
		
		inc rbx
		cmp rbx, %2
		jb %%inputLoop
		
		; error string too long
		endOnError errorStringTooLong
		
		jmp endProgram
		
	%%inputDone:
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
	; 	System Service Call Constants
	SYSTEM_EXIT equ 60
	SUCCESS equ 0
	SYSTEM_WRITE equ 1
	SYSTEM_READ equ 0
	STANDARD_OUT equ 1
	STANDARD_IN equ 0

	;	ASCII Values
	NULL equ 0
	LINEFEED equ 10
	
	;	Program Constraints
	MINIMUM_ARRAY_SIZE equ 1
	MAXIMUM_ARRAY_SIZE equ 1000
	INPUT_LENGTH equ 20
	OUTPUT_LENGTH equ 11
	VALUES_PER_LINE equ 5
	
	;	Labels / Useful Strings
	labelHeader db "Number Converter (Decimal to Hexadecimal)", LINEFEED, LINEFEED, NULL
	labelConverted db "Converted Values", LINEFEED, NULL
	endOfLine db LINEFEED, NULL
	space db " "
	
	;	Prompts
	promptCount db "Enter number of values to convert (1-1000):", LINEFEED, NULL
	promptDataEntry db "Enter decimal value:", LINEFEED, NULL

	;	Error Messages
	;		Array Length
	errorArrayMinimum db LINEFEED, "Error - Program can only convert at least 1 value.", LINEFEED, LINEFEED, NULL
	errorArrayMaximum db LINEFEED, "Error - Program can only convert at most 1,000 values.", LINEFEED, LINEFEED, NULL
							 
	;		Decimal String Conversion
	errorStringUnexpected db LINEFEED,"Error - Unexpected character found in input." , LINEFEED, LINEFEED, NULL
	errorStringNoDigits db LINEFEED,"Error - Value must contain at least one numeric digit." , LINEFEED, LINEFEED, NULL
	
	;		Input Length
	errorStringTooLong db LINEFEED, "Error - Input can be at most 20 characters long." , LINEFEED, LINEFEED, NULL
	
	;	Other
	arrayLength dd 0
	
	; Ryan Variables
	
	LABEL_HEADER_LENGTH equ 44
	PROMPT_COUNT_LENGTH equ 45
	BUFFER_SIZE equ 20
	ERROR_STRING_TOO_LONG_LENGTH equ 53
	PROMPT_DATA_ENTRY_LENGTH equ 22
	inputValue dd 0

section .bss
	;	Array of integer values, not all will necessarily be used
	array resd 1000
	inputString resb 21
	outputString resb 11
	stringBuffer resb BUFFER_SIZE

section .text
global _start
_start:

	;	Output Header
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, labelHeader
	mov rdx, LABEL_HEADER_LENGTH
	syscall
	
	;	Output Array Length Prompt
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, promptCount
	mov rdx, PROMPT_COUNT_LENGTH
	syscall
	
	;	Read in Array Length - one character at a time
	; (cin numbers) works but not optimized for error
	;mov rax, SYSTEM_READ
	;mov rdi, STANDARD_IN
	;mov rsi, stringBuffer
	;mov rdx, BUFFER_SIZE
	;syscall
	
	readInCharacterAtTime stringBuffer, BUFFER_SIZE
		; stringBuffer size in rbx
		; stringBuffer holds user input
	
	;	Convert Array Length	
	
	
	; stringBuffer -> arrayLength
	convertDecimalToInteger stringBuffer, arrayLength
	mov r15, 0
	mov r15d, dword[arrayLength]		; r15d holds array length
	
	cmp r15d, 0
	jle arrayMinError
	cmp r15d, 1000
	jg arrayMaxError
	
	jmp arrayLengthDone
	
	arrayMinError:
		endOnError errorArrayMinimum
		
	arrayMaxError:
		endOnError errorArrayMaximum
		
	arrayLengthDone:
	
	;	Check that Array Length is Valid - output error message and end program if not
	
	;	Read in Array Values
		; Prompt For New Value
		;	Read in Value - one character at a time
		;	Convert Value
	;	Output Array Values in Hex - (5 Per Line)
	; 		Print Header

	mov r12, 0		; index
	mov r13, 0		; holds inputed number
	
	readInArrayValuesLoop:
	; prompt user for data
		mov rax, SYSTEM_WRITE
		mov rdi, STANDARD_OUT
		mov rsi, promptDataEntry
		mov rdx, PROMPT_DATA_ENTRY_LENGTH
		syscall

		; read in decimal value
		; rbx, rsi, rdx
		readInCharacterAtTime stringBuffer, BUFFER_SIZE
		
		; rax, rbx, rcx, rdx, r9, r10, 
		; mov dword[array+r12*4], stringBuffer
		;lea r13, dword[array+r12*4]
		convertDecimalToInteger stringBuffer, inputValue
		
		; store inputValue (decimal) into array position
		mov r13d, dword[inputValue]
		mov dword[array+r12*4], r13d
		inc r12
		cmp r15d, r12d
		jne readInArrayValuesLoop
	
	; values in r13 are correct, but not sure of storing properly
	; attempted outputing r13 here to check saved value, but nothing prints
	
	mov r13, 0
	mov r12, 1
	mov rdx, 0
	;mov dword[inputValue], r13d
	mov r13, array
	strCountLoop:
		cmp byte[r13], NULL
		je strCountDone
		inc r13
		inc rdx
		jmp strCountLoop
		
	
	strCountDone:
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	lea rsi, dword[array+r12*4]
	syscall

	; here would pass to macro4 " "











































































endProgram:
	mov rax, SYSTEM_EXIT
	mov rdi, SUCCESS
	syscall