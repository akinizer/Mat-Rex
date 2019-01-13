##
## interchange.asm
##
##

#################################################
#					 	#
#		text segment			#
#						#
#################################################

	.text		
       	.globl main
       	
#
# t0 - # of chars to read
# s0 - address of the matrix A located heap
#
main:		
				# total no of chars to read	
	lw $t0, size		# (2*size + 1)*size
	sll $t8, $t0, 1
	addi $t8, $t8, 1
	mul $t0, $t8, $t0
	
	# --- timer 1 -----
	li $v0, 30
	syscall
	move $s3, $a0
	
	# -- file read --
	li $v0, 13		# open file
	la $a0, mat8
	li $a1, 0		# flag=0, reading
	li $a2, 0		# ignore mode  
	syscall
	move $t8, $v0		# save file descriptor
	
	li $v0, 14 		# read matrix B
	move $a0, $t8		# from the file
	la $a1, bufferMat8
	move $a2, $t0
	syscall
	
	li $v0, 16		# close the file
	move $a0, $t8
	syscall
				
	# -- file read --
	li $v0, 13		# open file
	la $a0, mat2
	li $a1, 0		# flag=0, reading
	li $a2, 0		# ignore mode  
	syscall
	move $t8, $v0		# save file descriptor
	
	li $v0, 14 		# read matrix C
	move $a0, $t8		# from the file
	la $a1, bufferMat2
	move $a2, $t0
	syscall
	
	li $v0, 16		# close the file
	move $a0, $t8
	syscall
	
	# --- timer 2 -----
	li $v0, 30
	syscall
	move $s4, $a0
	
	#-----------
	
	la $a0, printStart	# print start message
	li $v0, 4
	syscall

	#-----------
				# total no of bytes needed	
	lw $t0, size		# size*size*4
	mul $t0, $t0, $t0
	sll $t0, $t0, 2
	
				# heap allocation
	li $v0, 9
	move $a0, $t0
	syscall
	move $s0, $v0

# Matrix subtraction
#
# s0 -> address of A
# s1 -> address of B
# s2 -> address of C
# t0 -> size
# t8 -> i, counter1
# t2 -> j, counter2
#
# t3 -> size*i+j
# t7 - 
#	

matrixSubtraction:
				# bottom testing for loop
				# loop initialization
	lw $t0, size
	la $s1, bufferMat8
	la $s2, bufferMat2
	move $t8, $0		# i = 0
		
	j test8			# jump to loop testing
	
body1:	
				# second bottom testing for loop
				# second loop initialization	
	move $t2, $0		# j = 0
	
	j test2
	

body2:
	mul $t3, $t0, $t8	# size*i
	add $t3, $t3, $t2	# size*i+j 
	sll $t4, $t3, 1		# 2(size*i+j)
	div $t5, $t3, $t0	# size*i+j / size (integer div)
	add $t5, $t5, $t4	# 2(size*i+j) + (size*i+j / size) - memory increment
	add $t4, $s1, $t5	# address of B[i][j]
	add $t5, $s2, $t5	# address of C[i][j]
	sll $t3, $t3, 2
	add $t6, $s0, $t3	# address of A[i][j]
	lb $t4, ($t4)		# B[i][j]
	lb $t5, ($t5)		# C[i][j]
	addi $t4, $t4, -48	# ascii char -> number
	addi $t5, $t5, -48	# 
	sub $t4, $t4, $t5	# B[i][j] - C[i][j]
	sw $t4, ($t6)		# A[i][j] = B[i][j] - C[i][j]
	
operation2:
	addi $t2, $t2, 1 	# j++
	
test2: 
	slt $t7, $t2, $t0	# check for j < size
	bnez $t7, body2 
	
operation1:	
	addi $t8, $t8, 1	# i++

test8:	slt $t7, $t8, $t0	# check for i < size
	bnez $t7, body1
	
	# --- timer 3 -----
	li $v0, 30
	syscall
	move $s5, $a0

	# -----------
	
	la $a0, printEnd	# print the end message
	li $v0, 4		
	syscall 
	
	# -----------
				# print the timing results
	addi $t0, $0, 1000	# to convert milisec to sec
	mtc1 $t0, $f0
	cvt.s.w $f0, $f0
	
	sub $t8, $s4, $s3	# timer2 - timer1
	mtc1 $t8, $f1
	cvt.s.w $f1, $f1
	div.s $f1, $f1, $f0	# %1000 (2^10)	
	
	sub $t2, $s5, $s4	# timer3 - timer2
	mtc1 $t2, $f2	
	cvt.s.w $f2, $f2
	div.s $f2, $f2, $f0	# %1000 (2^10)
	
	la $a0, fillTime	# print fill time result
	li $v0, 4		# "Fill time: "
	syscall
	mov.s $f12, $f1		# 
	li $v0, 2
	syscall
	la $a0, endl		# print end line char
	li $v0, 4		
	syscall
	
	la $a0, sortTime	# print fill time result
	li $v0, 4		# "Sort time: "
	syscall
	mov.s $f12, $f2		# 
	li $v0, 2	
	syscall
	la $a0, endl		# print end line char
	li $v0, 4		
	syscall
	
	# ------------
quit:
	li $v0, 10
	syscall
	

#################################################
#					 	#
#     	 	data segment			#
#						#
#################################################

	.data
size: 100
bufferMat8: .space 21		# (2*size + 1)*size
bufferMat2: .space 21		# (50,5050) (100,20100) (200,80200) (400,320400)
mat8: .asciiz "matrix1.dat"      # filename for matrix B
mat2: .asciiz "matrix2.dat"      # filename for matrix C
endl: .asciiz "\n"
wspace: .asciiz " "
printStart: .asciiz "Starting the matrix subtraction\n"
printEnd: .asciiz "End of the matrix subtraction\n"
fillTime: .asciiz "Fill time: "
sortTime: .asciiz "Sort time: "


##
## end of file lab06.asm
