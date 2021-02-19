
# Ryan Aponte
# Feb. 17, 2021
# Section 1002

#  CS 219, MIPS Assignment #4
#  MIPS assembly language main program and functions:

#  * MIPS assembly language function, randomNumbers(), to create
#    a series of random numbers, which are stored in an array.
#    The pseudo random number generator uses the linear
#    congruential generator method as follows:
#        R(n+1) = ( A * R(n) + B) mod 2^24

#  * MIPS void function, printNumbers(), to print a list of right
#    justified numbers including a passed header string.

#  * MIPS assembly language function, gnomeSort(), to
#    sort a list of numbers into ascending (small to large) order.
#    Uses the provided gnome sort algorithm.

#  * MIPS void function, stats(), that will find the minimum,
#    median, maximum, sum, and average of the numbers array. The
#    function is called after the list is sorted. The average should
#    be calculated and returned as a floating point value.

#  * MIPS void function, showStats(), to print the list and
#    the statistical information (minimum, maximum, median, estimated
#    median, sum, average) in the format shown in the example.
#    The numbers should be printed 10 per line (see example).


#####################################################################
#  data segment

.data

# -----
#  Data declarations for main.

lst1:		.space		60		# 15 * 4
len1:		.word		15
seed1:		.word		19
min1:		.word		0
med1:		.word		0
max1:		.word		0
fSum1:		.float		0.0
fAve1:		.float		0.0


lst2:		.space		340		# 85 * 4
len2:		.word		85
seed2:		.word		39
min2:		.word		0
med2:		.word		0
max2:		.word		0
fSum2:		.float		0.0
fAve2:		.float		0.0

lst3:		.space		2800		# 700 * 4
len3:		.word		700
seed3:		.word		239
min3:		.word		0
med3:		.word		0
max3:		.word		0
fSum3:		.float		0.0
fAve3:		.float		0.0

lst4:		.space		14160		# 3540 * 4
len4:		.word		3540
seed4:		.word		137
min4:		.word		0
med4:		.word		0
max4:		.word		0
fSum4:		.float		0.0
fAve4:		.float		0.0

lst5:		.space		16628		# 4157 * 4
len5:		.word		4157
seed5:		.word		731
min5:		.word		0
med5:		.word		0
max5:		.word		0
fSum5:		.float		0.0
fAve5:		.float		0.0


hdr:		.asciiz	"CS 219 MIPS Assignment #4\n"
hdrMain:		.ascii	"\n---------------------------"
		.asciiz	"\nData Set #"
hdrLength:	.asciiz	"\nLength: "
hdrUnsorted:	.asciiz	"\n\n Random Numbers: \n"
hdrSorted:	.asciiz	"\n Sorted Numbers: \n"

str1:		.asciiz	"         Sum = "
str2:		.asciiz	"     Average = "
str3:		.asciiz	"     Minimum = "
str4:		.asciiz	"      Median = "
str5:		.asciiz	"     Maximum = "
str6:		.asciiz	"  Est Median = "
str7:		.asciiz " Median Diff = "


# -----
#  Variables/constants for randomNumbers function.

A = 127691
B = 7
RAND_LIMIT = 100000

# -----
#  Variables/constants for gnome sort function.

TRUE = 1
FALSE = 0

# -----
#  Variables/constants for printNumbers function.

sp1:		.asciiz	" "
sp2:		.asciiz	"  "
sp3:		.asciiz	"   "
sp4:		.asciiz	"    "
sp5:		.asciiz	"     "
sp6:		.asciiz	"      "
sp7:		.asciiz	"       "

NUMS_PER_ROW = 10

# -----
#  Variables for showStats function.

newLine:	.asciiz	"\n"


#####################################################################
#  text/code segment

.text

.globl	main
.ent	main
main:

# -----
#  Display Program Header.

	la	$a0, hdr
	li	$v0, 4
	syscall					# print header

	li	$s0, 1				# counter, data set number

# -----
#  Call routines:
#	* Gnerate random numbers
#	* Display unsorted numbers
#	* Find estimated median
#	* Sort numbers
#	* Find stats (min, median, max, float sum, and float average)
#	* Display stats, show sorted numbers, find difference 
#            between estimate median and real median

# ----------------------------
#  Data Set #1
#  Headers

	la	$a0, hdrMain
	li	$v0, 4
	syscall

	move	$a0, $s0
	li	$v0, 1
	syscall

	la	$a0, hdrLength
	li	$v0, 4
	syscall

	lw	$a0, len1
	li	$v0, 1
	syscall

	add	$s0, $s0, 1

# -----
#  Generate random numbers.
#	randomNumbers(lst, len, seed)

	la	$a0, lst1
	lw	$a1, len1
	lw	$a2, seed1
	jal	randomNumbers

# -----
#  Display unsorted numbers

	la	$a0, hdrUnsorted
	la	$a1, lst1
	lw	$a2, len1
	jal	printNumbers

# -----
#  Sort numbers.
#	gnomeSort(lst, len)

	la	$a0, lst1
	lw	$a1, len1
	jal	gnomeSort

# -----
#  Find lists stats.
#	stats(lst, len, min, med, max, fSum, fAve)

	la	$a0, lst1			# arg #1
	lw	$a1, len1			# arg #2
	la	$a2, min1			# arg #3
	la	$a3, med1			# arg #4
	la	$t0, max1			# arg #5
	la	$t1, fSum1			# arg #6
	la	$t2, fAve1			# arg #7
	sub	$sp, $sp, 12
	sw	$t0, ($sp)
	sw	$t1, 4($sp)
	sw	$t2, 8($sp)

	jal	stats
	add	$sp, $sp, 12

# -----
#  Display stats
#	showStats(lst, len, fSum, fAve, min, med, max, dhrStr)

	la	$a0, lst1
	lw	$a1, len1
	l.s	$f2, fSum1
	l.s	$f4, fAve1
	lw	$t0, min1
	lw	$t1, med1
	lw	$t2, max1
	la	$t3, hdrSorted
	sub	$sp, $sp, 24
	s.s	$f2, ($sp)
	s.s	$f4, 4($sp)
	sw	$t0, 8($sp)
	sw	$t1, 12($sp)
	sw	$t2, 16($sp)
	sw	$t3, 20($sp)

	jal	showStats
	add	$sp, $sp, 24

# ----------------------------
#  Data Set #2

	la	$a0, hdrMain
	li	$v0, 4
	syscall

	move	$a0, $s0
	li	$v0, 1
	syscall

	la	$a0, hdrLength
	li	$v0, 4
	syscall

	lw	$a0, len2
	li	$v0, 1
	syscall

	add	$s0, $s0, 1

# -----
#  Generate random numbers.
#	randomNumbers(lst, len, seed)

	la	$a0, lst2
	lw	$a1, len2
	lw	$a2, seed2
	jal	randomNumbers

# -----
#  Display unsorted numbers

	la	$a0, hdrUnsorted
	la	$a1, lst2
	lw	$a2, len2
	jal	printNumbers

# -----
#  Sort numbers.
#	gnomeSort(lst, len)

	la	$a0, lst2
	lw	$a1, len2
	jal	gnomeSort

# -----
#  Find lists stats.
#	stats(lst, len, min, med, max, fSum, fAve)

	la	$a0, lst2			# arg #1
	lw	$a1, len2			# arg #2
	la	$a2, min2			# arg #3
	la	$a3, med2			# arg #4
	la	$t0, max2			# arg #5
	la	$t1, fSum2			# arg #6
	la	$t2, fAve2			# arg #7
	sub	$sp, $sp, 12
	sw	$t0, ($sp)
	sw	$t1, 4($sp)
	sw	$t2, 8($sp)

	jal	stats
	add	$sp, $sp, 12

# -----
#  Display stats
#	showStats(lst, len, fSum, fAve, min, med, max, dhrStr)

	la	$a0, lst2
	lw	$a1, len2
	l.s	$f2, fSum2
	l.s	$f4, fAve2
	lw	$t0, min2
	lw	$t1, med2
	lw	$t2, max2
	la	$t3, hdrSorted
	sub	$sp, $sp, 24
	s.s	$f2, ($sp)
	s.s	$f4, 4($sp)
	sw	$t0, 8($sp)
	sw	$t1, 12($sp)
	sw	$t2, 16($sp)
	sw	$t3, 20($sp)

	jal	showStats
	add	$sp, $sp, 24

# ----------------------------
#  Data Set #3

	la	$a0, hdrMain
	li	$v0, 4
	syscall

	move	$a0, $s0
	li	$v0, 1
	syscall

	la	$a0, hdrLength
	li	$v0, 4
	syscall

	lw	$a0, len3
	li	$v0, 1
	syscall

	add	$s0, $s0, 1

# -----
#  Generate random numbers.
#	randomNumbers(lst, len, seed)

	la	$a0, lst3
	lw	$a1, len3
	lw	$a2, seed3
	jal	randomNumbers

# -----
#  Display unsorted numbers

	la	$a0, hdrUnsorted
	la	$a1, lst3
	lw	$a2, len3
	jal	printNumbers

# -----
#  Sort numbers.
#	gnomeSort(lst, len)

	la	$a0, lst3
	lw	$a1, len3
	jal	gnomeSort

# -----
#  Find lists stats.
#	stats(lst, len, min, med, max, fSum, fAve)

	la	$a0, lst3			# arg #1
	lw	$a1, len3			# arg #2
	la	$a2, min3			# arg #3
	la	$a3, med3			# arg #4
	la	$t0, max3			# arg #5
	la	$t1, fSum3			# arg #6
	la	$t2, fAve3			# arg #7
	sub	$sp, $sp, 12
	sw	$t0, ($sp)
	sw	$t1, 4($sp)
	sw	$t2, 8($sp)

	jal	stats
	add	$sp, $sp, 12

# -----
#  Display stats
#	showStats(lst, len, fSum, fAve, min, med, max, dhrStr)

	la	$a0, lst3
	lw	$a1, len3
	l.s	$f2, fSum3
	l.s	$f4, fAve3
	lw	$t0, min3
	lw	$t1, med3
	lw	$t2, max3
	la	$t3, hdrSorted
	sub	$sp, $sp, 24
	s.s	$f2, ($sp)
	s.s	$f4, 4($sp)
	sw	$t0, 8($sp)
	sw	$t1, 12($sp)
	sw	$t2, 16($sp)
	sw	$t3, 20($sp)

	jal	showStats
	add	$sp, $sp, 24

# ----------------------------
#  Data Set #4

	la	$a0, hdrMain
	li	$v0, 4
	syscall

	move	$a0, $s0
	li	$v0, 1
	syscall

	la	$a0, hdrLength
	li	$v0, 4
	syscall

	lw	$a0, len4
	li	$v0, 1
	syscall

	add	$s0, $s0, 1

# -----
#  Generate random numbers.
#	randomNumbers(lst, len, seed)

	la	$a0, lst4
	lw	$a1, len4
	lw	$a2, seed4
	jal	randomNumbers

# -----
#  Display unsorted numbers

	la	$a0, hdrUnsorted
	la	$a1, lst4
	lw	$a2, len4
	jal	printNumbers

# -----
#  Sort numbers.
#	gnomeSort(lst, len)

	la	$a0, lst4
	lw	$a1, len4
	jal	gnomeSort

# -----
#  Find lists stats.
#	stats(lst, len, min, med, max, fSum, fAve)

	la	$a0, lst4			# arg #1
	lw	$a1, len4			# arg #2
	la	$a2, min4			# arg #3
	la	$a3, med4			# arg #4
	la	$t0, max4			# arg #5
	la	$t1, fSum4			# arg #6
	la	$t2, fAve4			# arg #7
	sub	$sp, $sp, 12
	sw	$t0, ($sp)
	sw	$t1, 4($sp)
	sw	$t2, 8($sp)

	jal	stats
	add	$sp, $sp, 12

# -----
#  Display stats
#	showStats(lst, len, fSum, fAve, min, med, max, dhrStr)

	la	$a0, lst4
	lw	$a1, len4
	l.s	$f2, fSum4
	l.s	$f4, fAve4
	lw	$t0, min4
	lw	$t1, med4
	lw	$t2, max4
	la	$t3, hdrSorted
	sub	$sp, $sp, 24
	s.s	$f2, ($sp)
	s.s	$f4, 4($sp)
	sw	$t0, 8($sp)
	sw	$t1, 12($sp)
	sw	$t2, 16($sp)
	sw	$t3, 20($sp)

	jal	showStats
	add	$sp, $sp, 24

# ----------------------------
#  Data Set #5

	la	$a0, hdrMain
	li	$v0, 4
	syscall

	move	$a0, $s0
	li	$v0, 1
	syscall

	la	$a0, hdrLength
	li	$v0, 4
	syscall

	lw	$a0, len5
	li	$v0, 1
	syscall

	add	$s0, $s0, 1

# -----
#  Generate random numbers.
#	randomNumbers(lst, len, seed)

	la	$a0, lst5
	lw	$a1, len5
	lw	$a2, seed5
	jal	randomNumbers

# -----
#  Display unsorted numbers

	la	$a0, hdrUnsorted
	la	$a1, lst5
	lw	$a2, len5
	jal	printNumbers

# -----
#  Sort numbers.
#	gnomeSort(lst, len)

	la	$a0, lst5
	lw	$a1, len5
	jal	gnomeSort

# -----
#  Find lists stats.
#	stats(lst, len, min, med, max, fSum, fAve)

	la	$a0, lst5			# arg #1
	lw	$a1, len5			# arg #2
	la	$a2, min5			# arg #3
	la	$a3, med5			# arg #4
	la	$t0, max5			# arg #5
	la	$t1, fSum5			# arg #6
	la	$t2, fAve5			# arg #7
	sub	$sp, $sp, 12
	sw	$t0, ($sp)
	sw	$t1, 4($sp)
	sw	$t2, 8($sp)

	jal	stats
	add	$sp, $sp, 12

# -----
#  Display stats
#	showStats(lst, len, fSum, fAve, min, med, max, dhrStr)

	la	$a0, lst5
	lw	$a1, len5
	l.s	$f2, fSum5
	l.s	$f4, fAve5
	lw	$t0, min5
	lw	$t1, med5
	lw	$t2, max5
	la	$t3, hdrSorted
	sub	$sp, $sp, 24
	s.s	$f2, ($sp)
	s.s	$f4, 4($sp)
	sw	$t0, 8($sp)
	sw	$t1, 12($sp)
	sw	$t2, 16($sp)
	sw	$t3, 20($sp)

	jal	showStats
	add	$sp, $sp, 24

# -----
#  Done, terminate program.

	li	$v0, 10
	syscall					# au revoir...

.end main

#####################################################################
#  Generate pseudo random numbers using the linear
#  congruential generator method.
#    R(n+1) = (A × Rn + B) mod 2^24
#		($t0 * $a2 + $t1) % $t2

# -----
#    Arguments:
#	$a0 - starting address of the list
#	$a1 - count of random numbers to generate
#	$a2 - seed

#    Returns:
#	N/A
.globl randomNumbers
randomNumbers:
	li $t1, B
	li $t2, 16777216
	move $t4, $a2
	li $t5, RAND_LIMIT
	move $t6, $a0	# array starting address
	li $t7, 0		# loop index,

	randNumbersLoop:
		mul $t3, $t4, A	# $t3 = A * Rn
		addu $t3, $t3, B	# $t3 = (A*Rn + B)
		remu $t3, $t3, $t2	# $t3 = (A*Rn + B) % 2^24

		move $t4, $t3	# update Rn
		remu $t3, $t3, $t5	# $t3 = [(A*Rn + B) % 2^24] % RAND_LIMIT

		sw $t3, ($t6)	# store value into array[i]
		

		addu $t7, $t7, 1	# increment i
		addu $t6, $t6, 4	# update array address

		bltu $t7, $a1, randNumbersLoop
	jr $ra

.end randomNumbers





#####################################################################
#  Sort a list of numbers using gnome sort.

# gnomeSort(a[0..size-1]) {
#	i := 1
#	j := 2
#	while (i < size)
#		if (a[i-1] >= a[i])
#			i := j
#			j := j + 1 
#		else
#			swap a[i-1] and a[i]
#			i := i - 1
#			if (i = 0) i := 1
# }

# -----
#  Function must:
#	sort list

# -----
#	HLL call:	gnomeSort(array, len);

#    Arguments:
#	$a0 - starting address of the list
#	$a1 - list length

#    Returns:
#	n/a

.globl gnomeSort
gnomeSort:
	move $t0, $a0
	li $t1, 1	# i
	li $t2, 2	# j
	# $t4 = &a[i-1]
	# $t5 = &a[i]
	# $t6 = a[i-1]
	# $t7 = a[i]
	
	gnomeSortLoop:

		subu $t3, $t1, 1 # i-1 = $t3
		mul $t3, $t3, 4
		addu $t4, $a0, $t3	# $t4 = &a[i-1]
		lw $t6, ($t4)	# $t6 = a[i-1]

		move $t3, $t1 # i-1 = $t3
		mul $t3, $t3, 4
		addu $t5, $a0, $t3	# $t5 = &a[i]
		lw $t7, ($t5)	# $t6 = a[i]

		bleu $t6, $t7, ijIncrement
			# el swap
			lw $t3, ($t4)
			move $t0, $t7
			sw $t0, ($t4)
			sw $t3, ($t5)

			# i := i -1
			subu $t1, $t1, 1
			bne $t1, 0, iterationDone
				li $t1, 1
				j iterationDone

		ijIncrement:
			move $t1, $t2
			addu $t2, $t2, 1

		iterationDone:

	bltu $t1, $a1, gnomeSortLoop

	jr $ra

.end gnomeSort




#####################################################################
#  MIPS assembly language function, stats(), that will
#    find the sum, average, minimum, maximum, and median of the list.
#    The average is returned as floating point value.

#  HLL Call:
#	call stats(lst, len, min, med, max, fSum, fAve)

# -----
#    Arguments:
#	$a0 - starting address of the list
#	$a1 - list length
#	$a2 - addr of min
#	$a3 - addr of med
#	($fp) - addr of max
#	4($fp) - addr of fSum
#	8($fp) - addr of fAve

#    Returns (via reference):
#	min
#	med
#	max
#	fSum
#	fAve

# Can make more efficient by just grabbing a[0] and a[size-1] directly since the sorted array is what is passed
.globl stats
stats:

	move $fp, $sp

	move $t0, $a0
	li $t1, 0	# index
	li $t2, 0	# 
	li $t6, 0	# MAX
	li $t7, 99999	# MIN
	# $f8 = 0 = SUM
	mtc1 $t2, $f8
	cvt.s.w $f8, $f8
	move $t5, $a1
	mtc1 $t5, $f10
	cvt.s.w $f10, $f10

	# $f2 = 0 = MAX = $t6
	# mtc1 $t2, $f2
	# cvt.s.w $f2, $f2
	# $f4 = 99999 = MIN = $t7
	# mtc1 $t7, $f4
	# cvt.s.w $f4, $f4


	statsLoop:
		# SUM
		lw $t2, ($t0)
		mtc1 $t2, $f6
		cvt.s.w $f6, $f6
		add.s $f8, $f6, $f8

		# MAX
		bltu $t2, $t6, minCheck
			move $t6, $t2
			# j maxMinDone
		
		minCheck:
			# min
			bgtu $t2, $t7, maxMinDone
				move $t7, $t2

		maxMinDone:
		addu $t1, $t1, 1
		addu $t0, $t0, 4
	bltu $t1, $a1, statsLoop
	# SUM
	lw $t3, 4($fp)
	s.s $f8, ($t3)
	# MAX
	lw $t3, ($fp)
	sw $t6, ($t3)
	# MIN
	sw $t7, ($a2)
	# AVG
	div.s $f10, $f8, $f10
	lw $t3, 8($fp)
	s.s $f10, ($t3)
	jr $ra

.end stats




#####################################################################
#  MIPS assembly language function, printNumbers(), to display
#    the right justified numbers in the passed array.
#    The numbers should be printed 10 per line (see example).

# -----
#    Arguments:
#	$a0 - address of header string
#	$a1 - starting address of the list
#	$a2 - list length

#    Returns:
#	N/A

.globl	printNumbers
printNumbers:

# -----
#  Save registers.

	subu	$sp, $sp, 28
	sw	$s0, ($sp)
	sw	$s1, 4($sp)
	sw	$s2, 8($sp)
	sw	$s3, 12($sp)
	sw	$s4, 16($sp)
	sw	$s5, 20($sp)
	sw	$ra, 24($sp)

# -----
#  Initializations...

	move	$s0, $a0			# set $s0 addr header string
	move	$s1, $a1			# set $s1 to addr of list
	move	$s2, $a2			# set $s2 to length
	li	$s4, NUMS_PER_ROW

# -----
#  display header string

	move	$a0, $s0
	li	$v0, 4
	syscall

# -----
#  Loop to display numbers in list...

prtLp:
#	la	$a0, spc
#	li	$v0, 4
#	syscall

	lw	$t0, ($s1)			# get list[n]
	la	$a0, sp6
	ble	$t0, 10, doPrt
	la	$a0, sp5
	ble	$t0, 100, doPrt
	la	$a0, sp4
	ble	$t0, 1000, doPrt
	la	$a0, sp3
	ble	$t0, 10000, doPrt
	la	$a0, sp2
	ble	$t0, 100000, doPrt

doPrt:
#	la	$a0, sp2			# temp
	li	$v0, 4
	syscall

	lw	$a0, ($s1)			# get list[n]
	li	$v0, 1
	syscall

# -----
#  Check to see if a CR/LF is needed.

	sub	$s4, $s4, 1
	bgtz	$s4, nxtLp

	la	$a0, newLine
	li	$v0, 4
	syscall
	li	$s4, NUMS_PER_ROW

# -----
#   Loop as needed.

nxtLp:
	sub	$s2, $s2, 1			# decrement counter
	addu	$s1, $s1, 4			# increment addr by word
	bnez	$s2, prtLp

# -----
#  Display CR/LF for formatting.

	la	$a0, newLine
	li	$v0, 4
	syscall

# -----
#  Done, return

	lw	$s0, ($sp)
	lw	$s1, 4($sp)
	lw	$s2, 8($sp)
	lw	$s3, 12($sp)
	lw	$s4, 16($sp)
	lw	$s5, 20($sp)
	lw	$ra, 24($sp)
	addu	$sp, $sp, 28

	jr	$ra
.end	printNumbers

#####################################################################
#  MIPS assembly language function, showStats(), to display
#    the tAreas and the statistical information:
#	sum (float), average (float), minimum, median, maximum,
#	estimated median in the presribed format.
#    The numbers should be printed four (4) per line (see example).

#  Note, due to the system calls, the saved registers must
#        be used.  As such, push/pop saved registers altered.

#  HLL Call:
#	call showStats(lst, len, fSum, fAve, min, med, max, hdrStr)

# -----
#    Arguments:
#	$a0 - starting address of the list
#	$a1 - list length
#	($fp) - sum (float)
#	4($fp) - average (float)
#	8($fp) - min
#	12($fp) - med
#	16($fp) - max
#	20($fp) - header string addr

#    Returns:
#	N/A

.globl	showStats
showStats:

# -----
#  Save registers.

	subu	$sp, $sp, 16
	sw	$s0, ($sp)
	sw	$s1, 4($sp)
	sw	$fp, 8($sp)
	sw	$ra, 12($sp)
	addu	$fp, $sp, 16

	move	$s0, $a0
	move	$s1, $a1

# -----
#  Call printNumbers() routine.

	lw	$a0, 20($fp)
	move	$a1, $s0
	move	$a2, $s1
	jal	printNumbers

# -----
#  Display CR/LF for formatting.

	la	$a0, newLine
	li	$v0, 4
	syscall

# -----
#  Print message followed by result.

	la	$a0, str1
	li	$v0, 4
	syscall					# print "sum = "

	l.s	$f12, ($fp)
	li	$v0, 2
	syscall					# print sum

	la	$a0, newLine
	li	$v0, 4
	syscall

# -----
#  Print message followed by result.

	la	$a0, str2
	li	$v0, 4
	syscall					# print "ave = "

	l.s	$f12, 4($fp)
	li	$v0, 2
	syscall					# print average

	la	$a0, newLine
	li	$v0, 4
	syscall

# -----
#  Print message followed by result.

	la	$a0, str3
	li	$v0, 4
	syscall					# print "min = "

	lw	$a0, 8($fp)
	li	$v0, 1
	syscall					# print min

	la	$a0, newLine
	li	$v0, 4
	syscall

# -----
#  Print message followed by result.

	la	$a0, str4
	li	$v0, 4
	syscall					# print "med = "

	lw	$a0, 12($fp)
	li	$v0, 1
	syscall					# print med

	la	$a0, newLine
	li	$v0, 4
	syscall

# -----
#  Print message followed by result.

	la	$a0, str5
	li	$v0, 4
	syscall					# print "max = "

	lw	$a0, 16($fp)
	li	$v0, 1
	syscall					# print max

	la	$a0, newLine
	li	$v0, 4
	syscall

# -----
#  formatting...

	la	$a0, newLine			# print a newline
	li	$v0, 4
	syscall

	la	$a0, newLine			# print a newline
	li	$v0, 4
	syscall

# -----
#  Restore registers.

	lw	$s0, ($sp)
	lw	$s1, 4($sp)
	lw	$fp, 8($sp)
	lw	$ra, 12($sp)
	addu	$sp, $sp, 16

# -----
#  Done, return to main.

	jr	$ra
.end showStats

