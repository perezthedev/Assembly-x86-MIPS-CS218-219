#;	Ryan Aponte
#;	Section 1004
#;	Assignment #11
#;	This program determines which widgets are within acceptable tolerances and outputs the results
.data
	widgetMeasurements: .word	706, 672, 658, 548, 570, 439, 648, 563, 790, 442
						.word	982, 904, 615, 718, 841, 827, 594, 673, 839, 762
						.word	547, 611, 620, 747, 858, 915, 509, 968, 774, 778
						.word	526, 934, 453, 910, 921, 766, 753, 849, 718, 479
						.word	910, 914, 481, 639, 614, 1049, 517, 501, 777, 860

	widgetTargetSizes:	.word	717, 662, 742, 502, 622, 511, 651, 645, 868, 517
						.word	895, 881, 539, 701, 779, 857, 653, 724, 907, 830
						.word	585, 574, 649, 750, 986, 930, 543, 932, 891, 760
						.word	603, 836, 509, 942, 864, 879, 668, 790, 806, 516
						.word	820, 834, 555, 588, 620, 926, 524, 517, 802, 988

	widgetStatus: .space 200

	WIDGET_COUNT = 50

	messageWidgetHeader: 	.asciiz "Widget #"
	messageWidgetAccepted:	.asciiz ": Accepted\n"
	messageWidgetRejected:	.asciiz ": Rejected\n"
	messageWidgetRework:	.asciiz ": Rework\n"

	SYSTEM_EXIT = 10
	SYSTEM_PRINT_INTEGER = 1
	SYSTEM_PRINT_STRING = 4
	
.text
.globl main
.ent main
main:
	#; Your Code Here
	la $t0, widgetMeasurements
	la $t1, widgetTargetSizes
	la $t2, widgetStatus
	li $t8, 50
	#; Check Each Widget
	checkWidget:
		lw $t3, ($t0)
		lw $t4, ($t1)
		#; Find Difference
		li $t9, 1000
		mul $t3, $t3, $t9	#; widgetMeasurements * 1000
		#; Find 8% Thresholds
		div $t5, $t3, $t4	#; t5 = num/den

		li $t6, 920
		li $t7, 1080
		#; Determine Widget Status
		blt $t5, $t6, rejectLbl
		bgt $t5, $t7, reworkLbl
		j acceptLbl
			rejectLbl:
			#; Reject (< 92%)
				li $t9, -1
				sw $t9, ($t2)
				j statusComplete
			reworkLbl:
			#; Rework (> 108%)
				li $t9, 1
				sw $t9, ($t2)
				j statusComplete
			acceptLbl:
			#; Accept (92% <= Difference <= 108%)
				li $t9, 0
				sw $t9, ($t2)
				j statusComplete
		statusComplete:
			addu $t2, $t2, 4
			addu $t0, $t0, 4
			addu $t1, $t1, 4
			sub $t8, $t8, 1
			bnez $t8, checkWidget

	#; Output Widget Statuses
	li $t8, 50
	li $t9, 1
	la $t2, widgetStatus
	printLoop:
		la $a0, messageWidgetHeader
		li $v0, 4
		syscall
		li $v0, 1
		move $a0, $t9
		syscall

		lw $t3, ($t2)
		li $t4, -1
		beq $t3, $t4, rejectedLbl
		li $t4, 0
		beq $t3, $t4, acceptedLbl
		li $t4, 1
		beq $t3, $t4, reworkedLbl

		rejectedLbl:
			la $a0, messageWidgetRejected
			li $v0, 4
			syscall
			j printIterationDone
		acceptedLbl:
			la $a0, messageWidgetAccepted
			li $v0, 4
			syscall
			j printIterationDone
		reworkedLbl:
			la $a0, messageWidgetRework
			li $v0, 4
			syscall
			j printIterationDone
		printIterationDone:
		addu $t2, $t2, 4	
		sub $t8, $t8, 1
		add $t9, $t9, 1
		bnez $t8, printLoop

	#; Ends Program
	li $v0, SYSTEM_EXIT
	syscall
.end main