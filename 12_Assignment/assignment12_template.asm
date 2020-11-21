#;	Ryan Aponte
#;	Assignment #12
#;	Section 1004
#;	Date Last Modified: 11/20/2020
#;	This program will utilize the MIPS assembly
#;	language. It will entail writing a series of functions and
#;	include the use of floating point instructions.

.data
#;	System Service Codes
	SYSTEM_EXIT = 10
	SYSTEM_PRINT_INTEGER = 1
	SYSTEM_PRINT_FLOAT = 2
	SYSTEM_PRINT_STRING = 4
	
#;	Function Input Data
	squareRootValue1: .word 1742
	squareRootValue2: .word 4566
	floatSquareRootValue1: .float 15135.0
	floatSquareRootValue2: .float 911560.50
	floatTolerance1: .float 0.01
	floatTolerance2: .float 0.001
	
	printArray: .word 1, 1, 1, 1, 1, 1
				.word 1, 0, 0, 0, 0, 1
				.word 1, 0, 0, 0, 0, 1
				.word 1, 0, 0, 0, 0, 1
				.word 1, 0, 0, 0, 0, 1
				.word 1, 1, 1, 1, 1, 1
				.word 1, 1
	PRINT_ARRAY_LENGTH = 38
	
	arrayValues: .word	377, 148, 641, -486, 828, 456, 192, -742, -658, -139 
				 .word	801, -946, 325, 916, 982, 902, -809, 858, -510, -713
				 .word	-309, 515, 587, 320, 994, 528, -617, -515, -123, 294
				 .word	644, -339, 842, -441, -557, 58, 773, 694, 78, -744
				 .word	-350, -424, -514, -679, 402, -924, -178, 315, 509, 173
				 .word	44, -80, -340, 905, -840, -210, 671, -755, -809, 731
				 .word	-936, -414, 627, -565, -749, -804, -456, -236, 933, 961
				 .word	-675, -9, 653, 581, -567, 916, 738, 343, 684, -184
				 .word	-789, -400, -941, 145, 933, 230, -236, 880, 646, -926
				 .word	982, 221, -451, -783, 331, -157, 193, 940, -818, 270
	ARRAY_LENGTH = 100
	
#;	Labels
	endLabel: .asciiz ".\n"
	newLine: .asciiz "\n"
	space: .asciiz " "
	squareRootLabel1: .asciiz "The square root of 1742 is "
	squareRootLabel2: .asciiz "The square root of 4566 is "
	squareRootFloatLabel1: .asciiz "The square root of 15135.0 is "
	squareRootFloatLabel2: .asciiz "The square root of 911560.50 is "
	printArrayLabel: .asciiz "\nPrint Array Test:\n"
	unsortedLabel: .asciiz "\nUnsorted List:\n"
	sortedLabelAscending: .asciiz "\nSorted List (Ascending):\n"

.text
#;	Function 1: Integer Square Root Estimation
#;	Estimates the square root using Newton's Method
#;	Argument 1 ( $a0 ): Integer value to find the square root of
#;	Returns: The estimated square root as an integer
.globl estimateIntegerSquareRoot
.ent estimateIntegerSquareRoot
estimateIntegerSquareRoot:
#;	New Estimate = (Old + Value/Old)/2
	move $t0, $a0	#; Old Estimate

	estimateIntLoop:
		divu $t1, $a0, $t0	#; Old Value a0/t0
		add $t1, $t1, $t0	#; Old Value + Old
		div $t1, $t1, 2	#; (oldValue/Old+Old)/2

		sub $t2, $t0, $t1	#; difference
		move $t0, $t1	#; old = new
	blt $t2, -1, estimateIntLoop
	bgt $t2, 1, estimateIntLoop

	move $v0, $t0

	jr $ra
.end estimateIntegerSquareRoot

#; Function 2: Float Square Root Estimation
#;	Estimates the square root using Newton's Method
#;	Argument 1 ( $f12 ): Float value to find the square root of
#;	Argument 2 ( $f14 ): Float value representing the tolerance level to stop at
#;	Returns: The estimated square root as a float

#;	Floating Point Comparison
#;	Use c.lt.s FRsrc1, FRsrc2 to set the comparison flag
#;	Use bc1t label to branch if the comparison was true
#;	Example:
#;		c.lt.s $f0, $f1
#;		bc1t estimateLoop #; Branch if $f0 < $f1
#;	In this version of MIPS, there is no greater than comparisons
.globl estimateFloatSquareRoot
.ent estimateFloatSquareRoot
estimateFloatSquareRoot:
	mov.s $f20, $f12	#; Old Estimate
	li $t0, 2
	mtc1 $t0, $f16	#; f16 = 2
	cvt.s.w $f16, $f16
	mov.s $f18, $f14
	sub.s $f18, $f18, $f14	#; 0
	sub.s $f18, $f18, $f14	#; -f14 = f18
	estimateFloatLoop:
		div.s $f21, $f12, $f20
		add.s $f21, $f21, $f20
		div.s $f21, $f21, $f16
		sub.s $f22, $f20, $f21
		mov.s $f20, $f21
	c.le.s $f22, $f18
	bc1t estimateFloatLoop
	c.lt.s $f22, $f14
	bc1f estimateFloatLoop

	mov.s $f0, $f20

#;	New Estimate = (Old + Value/Old)/2
	jr $ra
.end estimateFloatSquareRoot

#;	Function 3: Print Integer Array
#;	Prints the elements of the array to the terminal
#;	On each line, output a number of values equal to the square root of the total number of elements
#;	Use estimateIntegerSquareRoot to determine how many elements should be printed on each line
#;	Argument 1 ( $a0 ): Address of array to print
#;	Argument 2 ( $a1 ): Integer count of the number of elements in the array
.globl printIntegerArray
.ent printIntegerArray
printIntegerArray:
#;	Remember to push and pop $ra for non-leaf functions
	subu $sp, $sp, 4
	sw $ra, ($sp)
	#; find each line value
	#; t4 = arg 0 (address of array to print)
	#; t1 = sqrt(length)
	#; t2 = 0; counter
	#; t3 = remainder
	move $t4, $a0
	move $a0, $a1
	jal estimateIntegerSquareRoot
	move $t1, $v0
	li $t2, 0
	#; v0 holds sqrt(length)

	printLoop:
		li $v0, 1
		lw $a0, ($t4)
		syscall

		li $v0, 4
		la $a0, space
		syscall

		addu $t4, $t4, 4
		add $t2, $t2, 1

		rem $t3, $t2, $t1
		bnez $t3, skipNewLine

		li $v0, 4
		la $a0, newLine
		syscall

		skipNewLine:
			bne $t2, $a1, printLoop

	lw $ra, ($sp)
	addu $sp, $sp, 4
	jr $ra
.end printIntegerArray

#; Function 4: Integer Comb Sort (Ascending)
#;	Uses the comb sort algorithm to sort a list of integer values in ascending order
#; Argument 1: Address of array to sort
#;	Argument 2: Integer count of the number of elements in the array
#;	Returns: Nothing
.globl sortList
.ent sortList
sortList:


	jr $ra
.end sortList


#; ----------------------------------------------------------------------------------------
#;	------------------------------------DO NOT CHANGE MAIN----------------------------------
#; ----------------------------------------------------------------------------------------
.globl main
.ent main
main:
#;	Square Root Test 1
	li $v0, SYSTEM_PRINT_STRING
	la $a0, squareRootLabel1
	syscall

	lw $a0, squareRootValue1
	jal estimateIntegerSquareRoot

	move $a0, $v0
	li $v0, SYSTEM_PRINT_INTEGER
	syscall

	li $v0, SYSTEM_PRINT_STRING
	la $a0, endLabel
	syscall

#;	Square Root Test 2
	li $v0, SYSTEM_PRINT_STRING
	la $a0, squareRootLabel2
	syscall

	lw $a0, squareRootValue2
	jal estimateIntegerSquareRoot

	move $a0, $v0
	li $v0, SYSTEM_PRINT_INTEGER
	syscall

	li $v0, SYSTEM_PRINT_STRING
	la $a0, endLabel
	syscall
	
#;	Float Square Root Test 1
	li $v0, SYSTEM_PRINT_STRING
	la $a0, squareRootFloatLabel1
	syscall

	l.s $f12, floatSquareRootValue1
	l.s $f14, floatTolerance1
	jal estimateFloatSquareRoot

	li $v0, SYSTEM_PRINT_FLOAT
	mov.s $f12, $f0
	syscall

	li $v0, SYSTEM_PRINT_STRING
	la $a0, endLabel
	syscall

#;	Float Square Root Test 2
	li $v0, SYSTEM_PRINT_STRING
	la $a0, squareRootFloatLabel2
	syscall

	l.s $f12, floatSquareRootValue2
	l.s $f14, floatTolerance2
	jal estimateFloatSquareRoot

	li $v0, SYSTEM_PRINT_FLOAT
	mov.s $f12, $f0
	syscall

	li $v0, SYSTEM_PRINT_STRING
	la $a0, endLabel
	syscall
	
#;	Print Array Test
	li $v0, SYSTEM_PRINT_STRING
	la $a0, printArrayLabel
	syscall

	la $a0, printArray
	li $a1, PRINT_ARRAY_LENGTH
	jal printIntegerArray

#;	Print Unsorted Array
	li $v0, SYSTEM_PRINT_STRING
	la $a0, unsortedLabel
	syscall

	la $a0, arrayValues
	li $a1, ARRAY_LENGTH
	jal printIntegerArray
	
#;	Print Sorted Array (Ascending)
	li $v0, SYSTEM_PRINT_STRING
	la $a0, sortedLabelAscending
	syscall

	la $a0, arrayValues
	li $a1, ARRAY_LENGTH
	jal sortList

	la $a0, arrayValues
	li $a1, ARRAY_LENGTH
	jal printIntegerArray
	
#;	End Program
	li $v0, SYSTEM_EXIT
	syscall
.end main
