.data
matrix_src: .asciiz "ABCDE"
matrix_dest: .asciiz "********************"

.text
.globl main
main:
la $a0, matrix_src
la $a1, matrix_dest
li $a2, 5
li $a3, 1
jal transpose
la $a0, matrix_dest
li $v0, 4
syscall
li $a0, '\n'
li $v0, 11
syscall

li $v0, 10
syscall

.include "hw3.asm"
