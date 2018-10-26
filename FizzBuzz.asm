.data

fizz: .asciiz "fizz"
buzz: .asciiz "buzz"
nl : .asciiz "\n"

#########################################
#for x in 100				#
#   if not (x % 3 == 0 && x%5 == 0):	#
#      print(x)				#
#   else:				#
#      if x % 3 == 0			#
#         print(fizz)			#
#      if x % 5 == 0			#
#         print(buzz)			#
#   print(\n)				#
#########################################
.text

li $s0, 100	#Range to be printed
li $s1, 1 	#counter

li $s3, 3
li $s5, 5

fizzbuzz_loop:
bgt $s1, $s0, done

# if i % 3 == 0
div $s1, $s3
mfhi $s2
beqz $s2, print_fizz

fizz_done:
#if i % 5 == 0
div $s1, $s5
mfhi $s4
beqz $s4, print_buzz

beqz $s2, print_nl
j print_int

increment:
addi $s1, $s1, 1
j fizzbuzz_loop


print_int:
move $a0, $s1
li $v0, 1
syscall
j print_nl

print_nl:
la $a0, nl
li $v0, 4
syscall
j increment

print_fizz:
la $a0, fizz
li $v0, 4
syscall
j fizz_done

print_buzz:
la $a0, buzz
li $v0, 4
syscall
j print_nl


done:
li $v0, 10
syscall
