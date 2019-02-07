.include "hw2.asm"

.data
nl: .asciiz "\n"
strcmp_output: .asciiz "strcmp output: "
str1: .asciiz "WOLF"
str2: .asciiz "WOLFIE"

.text
.globl main
main:
la $a0, strcmp_output
li $v0, 4
syscall
la $a0, str1
la $a1, str2
jal strcmp
move $a0, $v0
li $v0, 1
syscall
la $a0, nl
li $v0, 4
syscall
li $v0, 10
syscall
