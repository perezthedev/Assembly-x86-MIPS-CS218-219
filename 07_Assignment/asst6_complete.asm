
section .data
	SYSTEM_EXIT equ 60
	SYSTEM_WRITE equ 1
	SYSTEM_READ equ 0
	STANDARD_IN equ 0
	STANDARD_OUT equ 1
	SUCCESS equ 0
	FAILURE equ 0
		
;	Random Number Generator Constants
	MULTIPLIER equ 48271
	MODULUS equ 0x7FFFFFFF
		
;	Special Characters
	LINEFEED equ 10
	NULL equ 0
	
;	Program Constraints
	MINIMUM_ARRAY_SIZE equ 2
	MAXIMUM_ARRAY_SIZE equ 10000
	MINIMUM_RANGE equ 1
	MAXIMUM_RANGE equ 100000
	BUFFER_SIZE equ 1000
	VALUES_PER_LINE equ 5

;	Strings
	messageHeader db "Sorted Random Number Generator", LINEFEED, LINEFEED, NULL
	messagePromptArrayCount db "Number of values to generate (2-10,000): ", NULL
	messagePromptRange db "Maximum Value (1-100,000): ", NULL
	messageSortedLabel db "Sorted Random Numbers", LINEFEED, LINEFEED, NULL
	endOfLine db LINEFEED, NULL
	space db " "

	;	Error Messages
	;		Array Length
	errorArrayMinimum db LINEFEED, "Error - enter a value of at least 2.", LINEFEED, LINEFEED, NULL
	errorArrayMaximum db LINEFEED, "Error - enter a value of at most 10,000.", LINEFEED, LINEFEED, NULL
	errorRangeMinimum db LINEFEED, "Error - enter a value of at least 1.", LINEFEED, LINEFEED, NULL
	errorRangeMaximum db LINEFEED, "Error - enter a value of at most 100,000.", LINEFEED, LINEFEED, NULL
										 
	;		Decimal String Conversion
	errorStringUnexpected db LINEFEED,"Error - Unexpected character found in input." , LINEFEED, LINEFEED, NULL
	errorStringNoDigits db LINEFEED,"Error - Value must contain at least one numeric digit." , LINEFEED, LINEFEED, NULL
	
	;		Input Length
	errorStringTooLong db LINEFEED, "Error - Input can be at most 20 characters long." , LINEFEED, LINEFEED, NULL
	
	previousRandomValue dd 1
section .bss
	range resd 1
	arraySize resd 1
	array resd MAXIMUM_ARRAY_SIZE
	stringBuffer resb BUFFER_SIZE
	outputString resb 11

section .text
global _start
_start:

;	Print Header
	mov rdi, messageHeader
	call printString

;	Ask user for size of array
	mov rdi, messagePromptArrayCount
	call printString
	
	mov rdi, stringBuffer
	mov rsi, BUFFER_SIZE
	call readString
	
	mov rdi, stringBuffer
	mov rsi, arraySize
	call convertDecimalToInteger
	
;	Check that Array Length is Valid - output error message and end program if not
	cmp dword[arraySize], MINIMUM_ARRAY_SIZE
	jl arrayLengthErrorMinimum
	cmp dword[arraySize], MAXIMUM_ARRAY_SIZE
	jg arrayLengthErrorMaximum
	jmp arrayLengthVerified
	
	arrayLengthErrorMinimum:
		mov rdi, errorArrayMinimum
		call endOnError 
	arrayLengthErrorMaximum:
		mov rdi, errorArrayMaximum
		call endOnError 
	arrayLengthVerified:
	
;	Ask user for range
	mov rdi, messagePromptRange
	call printString
	
	mov rdi, stringBuffer
	mov rsi, BUFFER_SIZE
	call readString
	
	mov rdi, stringBuffer
	mov rsi, range
	call convertDecimalToInteger
	
;	Check that Array Length is Valid - output error message and end program if not
	cmp dword[range], MINIMUM_RANGE
	jl rangeErrorMinimum
	cmp dword[range], MAXIMUM_RANGE
	jg rangeErrorMaximum
	jmp rangeVerified
	
	rangeErrorMinimum:
		mov rdi, errorRangeMinimum
		call endOnError 
	rangeErrorMaximum:
		mov rdi, errorRangeMaximum
		call endOnError 
	rangeVerified:

;	Generate Random Values
	mov ecx, dword[arraySize]
	mov rbx, 0
	randomLoop:
		mov rdi, previousRandomValue
		mov esi, dword[range]
		push rcx
		call getRandomNumber
		pop rcx
		
		mov dword[array + rbx * 4], eax
		inc rbx
	loop randomLoop

;	Sort Values (Ascending)
	mov rdi, array
	mov esi, dword[arraySize]
	call combSort
	
;	Print Values
	mov rdi, messageSortedLabel
	call printString
	
	mov ecx, dword[arraySize]
	mov r8, VALUES_PER_LINE
	mov r9, array
	outputLoop:
		push rcx
		push r9
		push r8
		
		mov rdi, r9
		mov rsi, outputString
		
		call convertIntegerToHexString 
		
		mov rdi, outputString
		call printString
		
		pop r8	
		cmp r8, 1
		je printNewLine
			mov rsi, space
			dec r8
			jmp printDelimiter
		printNewLine:
			mov rsi, endOfLine
			mov r8, VALUES_PER_LINE
		printDelimiter:
		
		mov rax, SYSTEM_WRITE
		mov rdi, STANDARD_OUT
		mov rdx, 1
		syscall
		
		pop r9
		add r9, 4
		pop rcx
		dec rcx
	cmp rcx, 0
	jne outputLoop

	cmp r8, VALUES_PER_LINE
	je endProgram

	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, endOfLine
	mov rdx, 1
	syscall

endProgram:
	mov rax, SYSTEM_EXIT
	mov rdi, SUCCESS
	syscall

;	Function 1 - Random Number Generator
;	rdi - Previous LCG # by Reference (dword)
;	rsi - Upper Range by Value (dword)
;	return in eax - random number
global getRandomNumber
getRandomNumber:

;	Calculate next random number
; 	lcg(n) = lcg(n-1) * a mod m
	mov eax, dword[rdi]
	mov edx, MULTIPLIER
	mov ecx, MODULUS
	mul edx
	div ecx
	
;	Update previous random value to new value
	mov dword[rdi], edx
	
;	Limit to provided range
;	random value = lcg(n) mod (range + 1)
	mov eax, edx
	inc esi
	mov edx, 0
	div esi
	
;	Sets return value to the modulus
	mov eax, edx
ret

;	Function 2 - Combsort
;	rdi - array reference (dwords)
;	rsi - array length by value (dword)
global combSort
combSort:
	push rbx
	
	mov eax, esi	; Gap Size = Length
	mov r10d, 10
	mov r11d, 13
	gapLoop:
;		Adjust Gap Size:  gap * 10 / 13
		mul r10d
		div r11d
		
;		Ensure gap size does not go below 1
		cmp eax, 0
		ja skipFloor
			mov eax, 1
		skipFloor:
		
		mov ecx, esi	; n
		sub ecx, eax	; n - gapsize
		mov rdx, 0	; i
		mov r8, 0	; Swaps Done
		combSortLoop:	; while i < n - gapsize
			mov r9d, dword[rdi + rdx * 4]
			add edx, eax	; i + gapsize
			cmp r9d, dword[rdi + rdx * 4]
			ja swap
				sub edx, eax	; i
			jmp swapDone
			swap:
				mov ebx,  dword[rdi + rdx * 4]
				mov dword[rdi + rdx * 4], r9d
				sub edx, eax	; i
				mov dword[rdi + rdx * 4], ebx
				inc r8	; add to swap count
			swapDone:
			inc edx	; i++
		dec rcx
		cmp rcx, 0
		jne combSortLoop
		
;		Only check for swaps done when gap size is 1
		cmp eax, 1
		jne gapLoop
		
		cmp r8, 0
		je combSortDone
	jmp gapLoop
	combSortDone:
	
	pop rbx
ret

;	Function 3 - Decimal String to Integer
;	rdi: null terminated string (byte array)
;	rsi: dword integer variable by reference
global convertDecimalToInteger
convertDecimalToInteger:
	push rbx
	
	mov eax, 0
	mov rbx, rdi
	mov r9d, 1	; sign
	mov r8d, 10 ; base
	mov r10, 0 ; digits processed
	
	checkForSpaces1:
		mov cl, byte[rbx]
		cmp cl, " "
		jne nextCheck1
		
		inc rbx
	jmp checkForSpaces1
	nextCheck1:

	cmp cl, "+"
	je checkForSpaces2Adjust
	cmp cl, "-"
	jne checkNumerals
	mov r9d, -1
	
	checkForSpaces2Adjust:
		inc rbx
	checkForSpaces2:
		mov cl, byte[rbx]
		cmp cl, " "
		jne nextCheck2
		
		inc rbx
	jmp checkForSpaces2
	nextCheck2:

	checkNumerals:
		movzx ecx, byte[rbx]
		cmp cl, NULL
		je finishConversion

		cmp cl, " "
		je checkForSpaces3
		
		cmp cl, "0"
		jb errorUnexpectedCharacter
		cmp cl, "9"
		ja errorUnexpectedCharacter
		jmp convertCharacter
		errorUnexpectedCharacter:
			mov rdi, errorStringUnexpected
			call endOnError 
			
		convertCharacter:
		sub cl, "0"
		mul r8d
		add eax, ecx
		inc r10

		inc rbx
	jmp checkNumerals
	
	checkForSpaces3:
		mov cl, byte[rbx]
		cmp cl, " "
		jne checkNull
		
		inc rbx
	jmp checkForSpaces3
	
	checkNull:
		cmp cl, NULL
		je finishConversion
			mov rdi, errorStringUnexpected
			call endOnError
	
	finishConversion:
		cmp r10, 0
		jne applySign
			mov rdi, errorStringNoDigits
			call endOnError
	applySign:
		mul r9d
		mov dword[rsi], eax
		
	pop rbx
ret

;	Convert integer to hexadecimal string
;	rdi: dword integer variable by reference
;	rsi: string (11 byte array) by reference
global convertIntegerToHexString
convertIntegerToHexString:
	push rbx

	mov byte[rsi], "0"
	mov byte[rsi+1], "x"
	mov byte[rsi+10], NULL
	
	mov rbx, rsi
	add rbx, 9
	
	mov r8d, 16 ;base
	mov rcx, 8
	mov eax, dword[rdi]
	convertHexLoop:
		mov edx, 0
		div r8d
		
		cmp dl, 10
		jae addA
			add dl, "0" ; Convert 0-9 to "0"-"9"
		jmp nextDigit
		
		addA:
			add dl, 55 ; 65 - 10 = 55 to convert 10 to "A"
			
		nextDigit:
			mov byte[rbx], dl
			dec rbx
			dec rcx
	cmp eax, 0
	jne convertHexLoop

	addZeroes:
		cmp rcx, 0
		je endHexConversion
		mov byte[rbx], "0"
		dec rbx
		dec rcx
	jmp addZeroes
	endHexConversion:

	pop rbx
ret

;	Counts the number of characters in the null terminated string
;	rdi - string address
;	rax - return # of characters in string (including null)
global stringLength
stringLength:
	mov rax, 1
	
	countCharacterLoop:
		mov cl, byte[rdi + rax - 1]
		cmp cl, NULL
		je countCharacterDone
		
		inc rax
	jmp countCharacterLoop
	countCharacterDone:
ret

;	Prints the provided null terminated string
;	rdi - string address
global printString
printString:
	push rdi
	call stringLength
	pop rdi
	
	mov rdx, rax	; string length
	mov rax, SYSTEM_WRITE
	mov rsi, rdi
	mov rdi, STANDARD_OUT
	syscall
ret

;	Prints an error message and ends the program
;	rdi - string address of error message
global endOnError
endOnError:
	call printString

	mov rax, SYSTEM_EXIT
	mov rdi, FAILURE
	syscall
ret

;	Reads a string in from standard in
;	rdi: Address of location to place string
;	esi: Integer max length of string
global readString
readString:
	push rbx
	mov rbx, 0
	mov r8d, esi
	mov r9, rdi
	inc r8
	
	readLengthLoop:
		mov rax, SYSTEM_READ
		mov rdi, STANDARD_IN
		lea rsi, byte[r9 + rbx]
		mov rdx, 1
		syscall
				
		inc rbx
		cmp byte[r9 + rbx - 1], LINEFEED
		je readLengthDone
		
	cmp rbx, r8
	jb readLengthLoop
	
	mov rdi, errorStringTooLong
	call	endOnError 
	
	readLengthDone:
	mov byte[r9 + rbx - 1], NULL
	
	pop rbx
ret