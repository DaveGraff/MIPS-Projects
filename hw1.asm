# David Graff
# dgraff
# 111079067

.data
# Command-line arguments
num_args: .word 0
addr_arg0: .word 0
addr_arg1: .word 0
addr_arg2: .word 0
addr_arg3: .word 0
no_args: .asciiz "You must provide at least one command-line argument.\n"

# Error messages
invalid_operation_error: .asciiz "INVALID_OPERATION\n"
invalid_args_error: .asciiz "INVALID_ARGS\n"

# Output strings
zero_str: .asciiz "Zero\n"
neg_infinity_str: .asciiz "-Inf\n"
pos_infinity_str: .asciiz "+Inf\n"
NaN_str: .asciiz "NaN\n"
floating_point_str: .asciiz "_2*2^"

# Miscellaneous strings
nl: .asciiz "\n"

# Put your additional .data declarations here, if any.
negative: .asciiz "-"
eight_zero: .asciiz "80000000"
normal_zero: .asciiz "00000000"
pos_inf_num: .asciiz "7F800000"
neg_inf_num: .asciiz "FF800000"
one_str: .asciiz "1."
# Main program starts here
.text
.globl main
main:
    # Do not modify any of the code before the label named "start_coding_here"
    # Begin: save command-line arguments to main memory
    sw $a0, num_args
    beq $a0, 0, zero_args
    beq $a0, 1, one_arg
    beq $a0, 2, two_args
    beq $a0, 3, three_args
four_args:
    lw $t0, 12($a1)
    sw $t0, addr_arg3
three_args:
    lw $t0, 8($a1)
    sw $t0, addr_arg2
two_args:
    lw $t0, 4($a1)
    sw $t0, addr_arg1
one_arg:
    lw $t0, 0($a1)
    sw $t0, addr_arg0
    j start_coding_here
zero_args:
    la $a0, no_args
    li $v0, 4
    syscall
    j exit
    # End: save command-line arguments to main memory
    
start_coding_here:
    # load arg0 into $t0
    lw $s0, addr_arg0
    lbu $t0, 0($s0)
    
    #Jump to appropriate branch for arg0
    beq $t0, 50, twos_complement #2
    beq $t0, 67, convert_base #C
    beq $t0, 70, hex_as_float #F
    
    #Quits if arg0 is invalid
    la $a0, invalid_operation_error
    li $v0, 4
    syscall
    j exit
    
twos_complement:
# Check if num args > 2
sw $a0, num_args
bge $a0, 3, print_invalid_args

#Check if args2 > 32 or contains !{0,1}
lw $t2, addr_arg1	# $t2 has the str
li $t1, 0		# t1 has count
two_check_loop:
lb $t0, ($t2)		# get byte from str
beqz $t0, two_done_checking
beq $t0, '0', two_valid_so_far
beq $t0, '1', two_valid_so_far
j print_invalid_args

two_valid_so_far:
addi $t1, $t1, 1
addi $t2, $t2, 1
j two_check_loop

# convert
two_done_checking:
bgt $t1, 32, print_invalid_args #exits if count > 32

# Start converting
lw $t2, addr_arg1	# Set t2 back to whole str
lb $t0, ($t2)		# Put the first byte of t2 into t0
li $t4, 0		# t4 is total num counter
beq $t0, '0', two_positive
j two_negative		#Sets on pos or negative execution path

two_positive:
addi $t2, $t2, 1
addi $t1, $t1, -2	#Remove sign bit
two_positive_loop:
lb $t0, ($t2)
beqz $t0, two_print_value
addi $t5, $t0, -48	#Get real, non-ASCII val & put it in t5
sllv $t5, $t5, $t1	#Multiply current val by 2^n
add $t4, $t4, $t5	#Add multiplied val to total

addi $t1, $t1, -1
addi $t2, $t2, 1
j two_positive_loop

two_negative:
li $v0, 4
la $a0, negative
syscall
addi $t1, $t1, -1  #Fix 2^n notation
addi $t4, $t4, 1   #Add 1 for two's complement bit flipping
two_negative_loop: #Flip all bits
lb $t0, ($t2)
beqz $t0, two_print_value
beq $t0, '0', zero_to_one
j one_to_zero
two_negative_loop_cont:
sllv $t5, $t5, $t1	#Multiply current val by 2^n
add $t4, $t4, $t5	#Add multiplied val to total

addi $t1, $t1, -1
addi $t2, $t2, 1
j two_negative_loop

zero_to_one:
li $t5, 1
j two_negative_loop_cont
one_to_zero:
sb $t5, ($s0)
j two_negative_loop_cont


two_print_value: #stored in t4
move $a0, $t4
li $v0, 1
syscall
j print_nl_str_done

j exit




convert_base:
# Check if num args == 4
sw $a0, num_args
bne $a0, 4, print_invalid_args

#Check if input is valid in given base
lw $t2, addr_arg1	# t2 has the str
lw $t3, addr_arg2	
lb $t3, ($t3)		# t3 has the base
base_check_loop:
lb $t0, ($t2)		# get byte from str
beqz $t0, base_check_done
bge $t0, $t3, print_invalid_args
addi $t2, $t2, 1 	# increment str pos
j base_check_loop

base_check_done:
lw $t2, addr_arg2		#t2 has real val of base
lb $t2, ($t2)
addi $t2, $t2, -48		
lw $t4, addr_arg3
lb $t4, ($t4)
addi, $t4, $t4, -48		#t4 has real val of base to be converted into

lw $t1, addr_arg1		#t1 has real val of str to be converted
add $t3, $0, $0			#t3 is the current count
#lb $t0, ($t1)
#addi $t0, $t0, -48		###############
#add $t3, $t3, $t0		# Get 1st bit #
#addi $t1, $t1, 1		###############
base_convert_loop:
lb $t0, ($t1)			#t0 is current char
beqz $t0, base_convert_loop_done
addi $t0, $t0, -48		#Get real val for char
mul $t3, $t3, $t2		#base * current val
add $t3, $t3, $t0		#current val + real val
addi $t1, $t1, 1		#increment count
j base_convert_loop
base_convert_loop_done:
addi, $s2, $0, 0		#s2 is offset for str address
				#t4 is the base
add $s3, $t3, $0		#s3 has quotient
base_finish_loop:
blt $s3, $t4, base_check_remainder
div $s3, $t4
mfhi $t0			#t0 has remainder
#addi $t0, $t0, 48		#Get ASCII representation
mflo $s3			#s3 has new quotient
addi $sp, $sp, -1
sb $t0, 0($sp)			#add byte to stack
addi $s2, $s2, 1		#update offset
j base_finish_loop

base_check_remainder:
beqz $s3, base_print_str_loop
addi $sp, $sp, -1
sb $s3, ($sp)			#add byte to stack
addi $s2, $s2, 1		#update offset
j base_print_str_loop

base_print_str_loop:
beqz $s2, base_print_nl
lb $t0, 0($sp)
move $a0, $t0			
addi $sp, $sp, 1		#Fix stack location
addi $s2, $s2, -1		#update offset
#move $a0, $s0
li $v0, 1
syscall
j base_print_str_loop

base_print_nl:
la $a0, nl
li $v0, 4
syscall
j exit

hex_as_float:   
# Check if num args > 2
sw $a0, num_args
bge $a0, 3, print_invalid_args

# Check if len == 8 and only hexadecimal
lw $t2, addr_arg1	# $t2 has the str
li $t1, 0		# t1 has count
hex_check: lb $t0, ($t2)# get byte from str
beqz $t0, hex_check_done
blt $t0, 48, print_invalid_args #t0 < 48 ?
bgt $t0, 70, print_invalid_args #t0 > 70 ?
bgt $t0, 57, hex_check_final #t0 > 57 ?
len_check:
addi $t1, $t1, 1
addi $t2, $t2, 1
j hex_check

hex_check_final:
blt $t0, 65, print_invalid_args #t0 < 65 ?
j len_check

hex_check_done:
bgt $t1, 8, print_invalid_args
blt $t1, 8, print_invalid_args

# Check for edge cases
lw $t2, addr_arg1	#Get full string back
la $t1, eight_zero
hex_edge_eight_zero_checker:
lb $t3, ($t2)	#t3 has input bit
lb $t4, ($t1)	#t4 has expected bit
beqz $t3, print_zero_str
bne $t3, $t4, hex_edge_norm_zero_checker_start
addi $t1, $t1, 1
addi $t2, $t2, 1
j hex_edge_eight_zero_checker

hex_edge_norm_zero_checker_start:
lw $t2, addr_arg1	#Get full string back
la $t1, normal_zero
hex_edge_norm_zero_checker:
lb $t3, ($t2)	#t3 has input bit
lb $t4, ($t1)	#t4 has expected bit
beqz $t3, print_zero_str
bne $t3, $t4, hex_edge_pos_inf_checker_start
addi $t1, $t1, 1
addi $t2, $t2, 1
j hex_edge_norm_zero_checker

hex_edge_pos_inf_checker_start:
lw $t2, addr_arg1	#Get full string back
la $t1, pos_inf_num
# beq $t1, $t2, print_pos_inf_str
hex_edge_pos_inf_checker:
lb $t3, ($t2)	#t3 has input bit
lb $t4, ($t1)	#t4 has expected bit
beqz $t3, print_pos_inf_str
bne $t3, $t4, hex_edge_neg_inf_checker_start
addi $t1, $t1, 1
addi $t2, $t2, 1
j hex_edge_pos_inf_checker

hex_edge_neg_inf_checker_start:
lw $t2, addr_arg1	#Get full string back
la $t1, neg_inf_num
hex_edge_neg_inf_checker:
lb $t3, ($t2)	#t3 has input bit
lb $t4, ($t1)	#t4 has expected bit
beqz $t3, print_neg_inf_str
bne $t3, $t4, hex_edge_check_done
addi $t1, $t1, 1
addi $t2, $t2, 1
j hex_edge_neg_inf_checker

hex_edge_check_done:
lw $t2, addr_arg1 	#Get full string once again...
add $s0, $0, $0		#Puts 0 in s0
hex_binary_convert_loop:
lb $t1, ($t2)		#t1 has most recent bit
beqz $t1, hex_binary_convert_done
sll $s0, $s0, 4		#Prepares s0 to receive real val
addi $t1, $t1, -48	#Gets real val of 0-9
bgt $t1, 9, hex_make_real
hex_binary_convert_loop_cont:
add $s0, $s0, $t1	#Adds real val to prepped s0
addi $t2, $t2, 1	#Iterates str pointer
j hex_binary_convert_loop

hex_make_real:
addi $t1, $t1, -7	#Gets real val of A-F
j hex_binary_convert_loop_cont

hex_binary_convert_done:
li $t7, 0x7F800001
bge $s0, $t7, hex_valid_checker #Looks for NaN occurences
hex_valid_partly_done:
li $t7, 0xFF800001
bge $s0, $t7, hex_valid_checker_2

hex_all_checking_done:
move $s1, $s0		#s1 has real val of input
srl $s1, $s1, 31	#Get only the MSB of input
bne $s1, 1, hex_positive#s1 either 0 or 1
li $a0, 45		#print - if 1
li $v0, 4
syscall
hex_positive:
la $a0, one_str		#all str should have '1.0'
li $v0, 4
syscall

move $s1, $s0		#Put real val back in s1
sll $s1, $s1, 9		#Remove exponent & sign
srl $s1, $s1, 9		#Get binary val of fraction
####print binary val####
addi $t0, $zero, 22	#stores the index to remove right
addi $t1, $zero, 9	#stores index to remove left
hex_print_fraction_loop:
move $s2, $s1		#s2 has val to be moved
sllv $s2, $s2, $t1	#
srlv $s2, $s2, $t1	#Remove digits before & after
srlv $s2, $s2, $t0	#

move $a0, $s2
li $v0, 1
syscall

addi $t1, $t1, 1
addi $t0, $t0, -1
beq $t0, -1,hex_print_fraction_done
j hex_print_fraction_loop

hex_print_fraction_done:

move $s1, $s0		#put real val back in s1
sll $s1, $s1, 1
srl $s1, $s1, 24	#now holds exponent in excess 127
addi $s1, $s1, -127	#now holds real exponent

la $a0, floating_point_str		#all exponents should have '_2*2^'
li $v0, 4
syscall

move $a0, $s1		#prints exponent
li $v0, 1
syscall

la $a0, nl
li $v0, 4
syscall
j exit

hex_valid_checker:
li $t7, 0x7FFFFFFF
bgt $s0, $t7, hex_valid_partly_done
j print_nan_str

hex_valid_checker_2:
li $t7, 0xFFFFFFFF
bgt $s0, $t7, hex_all_checking_done
j print_nan_str

print_nan_str:
la $a0, NaN_str
li $v0, 4
syscall
j exit

print_neg_inf_str:
la $a0, neg_infinity_str
li $v0, 4
syscall
j exit

print_pos_inf_str:
la $a0, pos_infinity_str
li $v0, 4
syscall
j exit

print_nl_str_done:
la $a0, nl
li $v0, 4
syscall
j exit

print_zero_str:
la $a0, zero_str
li $v0, 4
syscall
j exit   
    
print_invalid_args:
	la $a0, invalid_args_error
	li $v0, 4
	syscall
	j exit
	#performs all invalid args calls

exit:
    li $v0, 10   # terminate program
    syscall
