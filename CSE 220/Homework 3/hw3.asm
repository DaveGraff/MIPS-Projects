# David Graff
# dgraff
# 111079067

#####################################################################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
##### ANY LINES BEGINNING .data WILL BE DELETED DURING GRADING! #####
#####################################################################

.text

# Part I
get_adfgvx_coords:
li $v0, -200
li $v1, -200

addi $sp, $sp, -8
sw $ra, ($sp)
sw $t0, 4($sp)

move $t0, $a0
move $a0, $a1
jal get_coords_helper
move $v1, $v0

move $a0, $t0
jal get_coords_helper

lw $ra, ($sp)
lw $t0, 4($sp)
addi $sp, $sp, 8

bltz $v0, get_coords_error
bltz $v1, get_coords_error
j get_coords_exit

get_coords_error:
li $v0, -1
li $v1, -1
j get_coords_exit

get_coords_exit:
jr $ra

get_coords_helper:
beq $a0, 0, get_coords_A
beq $a0, 1, get_coords_D
beq $a0, 2, get_coords_F
beq $a0, 3, get_coords_G
beq $a0, 4, get_coords_V
beq $a0, 5, get_coords_X

li $v0, -1
j get_coords_helper_done

	get_coords_A:
	li $v0, 'A'
	j get_coords_helper_done
	
	get_coords_D:
	li $v0, 'D'
	j get_coords_helper_done
	
	get_coords_F:
	li $v0, 'F'
	j get_coords_helper_done
	
	get_coords_G:
	li $v0, 'G'
	j get_coords_helper_done
	
	get_coords_V:
	li $v0, 'V'
	j get_coords_helper_done
	
	get_coords_X:
	li $v0, 'X'
	j get_coords_helper_done
	
get_coords_helper_done:
jr $ra

# Part II
search_adfgvx_grid:
li $v0, -200
li $v1, -200


li $t5, 0	#t5 is counter
search_grid_loop:
	beq $t5, 36, search_grid_error
	lb $t6, ($a0)	#t6 is current char in arr
	beq $t6, $a1, search_grid_found
	
	addi $t5, $t5, 1
	addi $a0, $a0, 1
	j search_grid_loop

search_grid_error:
li $v0, -1
li $v1, -1
j search_grid_exit

search_grid_found:
# do things
li $t7, 6
div $t5, $t7
mflo $v0
mfhi $v1
j search_grid_exit

search_grid_exit:
jr $ra


# Part III
map_plaintext:
li $v0, -200
li $v1, -200

addi $sp, $sp, -4
sw $ra, ($sp)

move $t0, $a0	#t0 has grid
move $t1, $a1	#t1 has plaintext
	map_plaintext_loop:
	lb $t2, ($t1)
	beqz $t2, map_plaintext_done
	
	move $a1, $t2
	move $a0, $t0
	jal search_adfgvx_grid
	
	move $a0, $v0
	move $a1, $v1
	jal get_adfgvx_coords 
	
	sb $v0, ($a2)
	sb $v1, 1($a2)
	
	#increment
	addi $a2, $a2, 2
	addi $t1, $t1, 1
	j map_plaintext_loop

map_plaintext_done:
lw $ra, ($sp)
addi $sp, $sp, 4

jr $ra

# Part IV
# int swap matrix columns(char[][] matrix, int num rows, int num cols, int col1, int col2)
swap_matrix_columns:
li $v0, -200
li $v1, -200

lw $t7, 0($sp) #get col2 val into t7

#Error checking
blez $a1, swap_matrix_error
blez $a2, swap_matrix_error
bltz $a3, swap_matrix_error
bltz $t7, swap_matrix_error
ble $a2, $a3, swap_matrix_error
ble $a2, $t7, swap_matrix_error
li $v0, 0	#no more error cases

		#a3 has col1
		#t7 has col2
move $t4, $a0	#t4 has base addr
li $t6, 0	#t6 is counter
swap_matrix_loop:
bge $t6, $a1, swap_matrix_exit	#check if count > num rows
add $t4, $t4, $a3	#get addr offset for col1 element
lb $t2, ($t4)		#load col1 element
sub $t4, $t4, $a3	#reset addr tobase
add $t4, $t4, $t7	#get addr offset for col2 element
lb $t3, ($t4)		#load col2 element
sb $t2, ($t4)		#put col1 element in col2 element spot
sub $t4, $t4, $t7	#reset addr to base
add $t4, $t4, $a3	#get addr offset for col1 element
sb $t3, ($t4)		#put col2 element in col1 element spot
sub $t4, $t4, $a3	#reset addr to base

addi $t6, $t6, 1	#increment counter
add $t4, $t4, $a2	#get next set of columns
j swap_matrix_loop

swap_matrix_error:
li $v0, -1
j swap_matrix_exit

swap_matrix_exit:
jr $ra

# Part V
key_sort_matrix:
li $v0, -200
li $v1, -200

addi $sp, $sp, -8
sw $s0, ($sp)
sw $ra, 4($sp)

move $t2, $a3	#t2 is key arr
li $t0, 0 	#t0 is outer counter
key_sort_outer: #for(int i = 0; i < n; i++)
beq $t0, $a2, key_sort_exit
li $t1, 0 	#t1 is inner counter

	key_sort_inner: #for (int j = 0; j < n - i - 1; j++)
	move $t5, $a2
	sub $t5, $t5, $t0
	addi $t5, $t5, -1	#j < n - i - 1
	beq $t1, $t5, key_sort_outer_cont 
	lw $t3, 8($sp)	#get elem size
	beq $t3, 4, key_sort_load_long
	lb $t3, ($t2)	#A[j]
	lb $t4, 1($t2)	#A[j+1]
	addi $t2, $t2, 1#increment key addr
	key_sort_return:
	bgt $t3, $t4, key_sort_swap
	key_sort_swap_done:
	addi $t1, $t1, 1
	j key_sort_inner
key_sort_outer_cont:
addi $t0, $t0, 1
lw $t3, 8($sp)		#get elem size
mul $t1, $t1, $t3	#get addr offset
sub $t2, $t2, $t1	#reset arr addr
j key_sort_outer

key_sort_load_long:
lw $t3, ($t2)	#A[j]
lw $t4, 4($t2)	#A[j+1]
addi $t2, $t2, 4	#increment key addr
j key_sort_return

key_sort_swap:
#swap elements
lw $t6, 8($sp)	#get elem size
move $t5, $t3	#temp var
beq $t6, 4, key_sort_swap_long
sb $t4, -1($t2)
sb $t5, ($t2)
key_sort_swap_cont:
#swap columns
div $t1, $a2
mfhi $a3	#counter % num_cols = col1
addi $t1, $t1, 1
div $t1, $a2	
addi $t1, $t1, -1
mfhi $t7	#temp
addi $sp, $sp, -4
sw $t7, ($sp)	#counter + 1 % num_cols = col2
move $s0, $t2	#save t2 register
jal swap_matrix_columns
move $t2, $s0
addi $sp, $sp, 4
j key_sort_swap_done

key_sort_swap_long:
sw $t4, -4($t2)
sw $t5, ($t2)
j key_sort_swap_cont

key_sort_exit:
lw $s0, ($sp)
lw $ra, 4($sp)
addi $sp, $sp, 8
jr $ra


# Part VI
transpose:
li $v0, -200
li $v1, -200

blez $a2, transpose_error	#num_rows
blez $a3, transpose_error	#num_cols

li $t0, 0	#t0 is outer counter
transpose_outer:
beq $t0, $a3, transpose_success
li $t1, 0	#t1 is inner counter
	transpose_inner:
	beq $t1, $a2, transpose_cont
	mul $t2, $a3, $t1
	add $t2, $t2, $t0	#t2 = j * num_cols + i
	add $a0, $a0, $t2	#get addr offset
	lb $t3, ($a0)
	sub $a0, $a0, $t2
	sb $t3, ($a1)
	
	addi $a1, $a1, 1	#increment dest addr
	addi $t1, $t1, 1	#increment inner counter
	j transpose_inner
transpose_cont:
addi $t0, $t0, 1	#increment outer counter
j transpose_outer

transpose_error:
li $v0, -1
j transpose_exit

transpose_success:
li $v0, 0
j transpose_exit

transpose_exit:
jr $ra

# Part VII
encrypt:
li $v0, -200
li $v1, -200

addi $sp, $sp, -4
sw $ra, ($sp)

move $t5, $a0
move $a0, $a1	#temp
jal length
li $t1, 2
mul $t1, $t1, $v0	#t1 = 2*len(plaintext)

move $a0, $a2
jal length
move $a0, $t0	#a0 has original value

move $t0, $v0	#t0 has len(keyword), or num_cols

div $t1, $t0
mfhi $t4	#t4 is # of empty elems TEMP
mflo $t1
beqz $t4, encrypt_no_mod
addi $t1, $t1, 1	#t1 now has num_rows
encrypt_no_mod:
mul $t2, $t0, $t1	#t2 has length of heap_ciphertext_arr
move $a0, $t2
li $v0, 9
syscall

sub $t4, $t0, $t4
move $t3, $v0	#t3 has addr of newly created heap_ciphertext_arr
#SET UNUSED BYTES OF heap_ciphertext_arr TO *
beqz $t4, encrypt_fill_space_done
sub $t4, $t2, $t4	#t4 = len(heap) - num of empty elems
add $t4, $t3, $t4	#t4 has starting addr of empty elems TEMP
add $t7, $t2, $t3	#t7 has max val of heap addr TEMP
li $t6, '*'			#TEMP
encrypt_fill_space:
beq $t4, $t7, encrypt_fill_space_done
sb $t6, ($t4)
addi $t4, $t4, 1
j encrypt_fill_space
encrypt_fill_space_done:

move $a0, $t5	#return stored value to a0
add $t3, $t3, $t2	
add $a3, $a3, $t2
li $t4, 0	#temp
sb $t4, ($t3)	#null terminate heap_ciphertext_arr
sb $t4, ($a3)	#null terminate ciphertext
sub $t3, $t3, $t2
sub $a3, $a3, $t2

#a0 = adfgvx_grid
#a1 = plaintext
#a2 = keyword
#a3 = ciphertext
#t0 = num_cols
#t1 = num_rows
#t3 = heap_ciphertext_arr

addi $sp, $sp, -20
sw $s0, ($sp)
sw $s1, 4($sp)
sw $s2, 8($sp)
sw $s3, 12($sp)
sw $s4, 16($sp)

#save variables
move $s0, $a2	#save keyword in s0
move $s1, $t0	#save num_cols in s1
move $s2, $t1	#save num_rows in s2
move $s3, $t3	#save heap_ciphertext_arr in s3
move $s4, $a3	#save ciphertext in s4
move $a2, $t3	#load args for map_plaintext
#map_plaintext(adfgvx grid, plaintext, heap_ciphertext_arr)
jal map_plaintext
move $a0, $s3	#load heap_ciphertext_arr arg
move $a1, $s2	#load num_rows arg
move $a2, $s1	#load num_cols arg
move $a3, $s0	#load keyword arg
li $t5, 1
addi $sp, $sp, -4
sw $t5, ($sp)	#load elem_size arg
jal key_sort_matrix
#key_sort(heap_ciphertext_arr, num_rows, num_cols, keyword, 1)
addi $sp, $sp, 4	#elem_size is no longer needed
move $a0, $s3	#load heap_ciphertext_arr arg
move $a1, $s4	#load ciphertext
move $a2, $s2	#load num_rows arg
move $a3, $s1	#load num_cols arg
jal transpose
#transpose(heap_ciphertext_arr, ciphertext, num_rows, num_cols)

#load variables
lw $s0, ($sp)
lw $s1, 4($sp)
lw $s2, 8($sp)
lw $s3, 12($sp)
lw $s4, 16($sp)
addi $sp, $sp, 20

encrypt_exit:
lw $ra, ($sp)
addi $sp, $sp, 4
jr $ra

#encrypt helper method
length:
li $v0, 0
length_loop:
lb $t7, ($a0)
beqz $t7, length_loop_done
addi $a0, $a0, 1
addi $v0, $v0, 1
j length_loop
length_loop_done:
jr $ra

# Part VIII
lookup_char:
li $v0, -200
li $v1, -200

addi $sp, $sp, -4
sw $ra, ($sp)

move $t0, $a0	#t0 has adfgvx_grid
move $a0, $a1
jal lookup_char_index
move $t1, $v0	#t1 has row index
move $a0, $a2
jal lookup_char_index
move $t2, $v0	#t2 has col index

li $t3 6
mul $t3, $t3, $t1
add $t3, $t3, $t2
add $t3, $t3, $t0
lb $v1, ($t3)
li $v0, 0
j lookup_char_exit 

lookup_char_error:
li $v0, -1
j lookup_char_exit

lookup_char_exit:
lw $ra, ($sp)
addi $sp, $sp, 4
jr $ra

lookup_char_index:
beq $a0, 'A', lookup_char_A
beq $a0, 'D', lookup_char_D
beq $a0, 'F', lookup_char_F
beq $a0, 'G', lookup_char_G
beq $a0, 'V', lookup_char_V
beq $a0, 'X', lookup_char_X
j lookup_char_error
lookup_char_A:
li $v0, 0
jr $ra
lookup_char_D:
li $v0, 1
jr $ra
lookup_char_F:
li $v0, 2
jr $ra
lookup_char_G:
li $v0, 3
jr $ra
lookup_char_V:
li $v0, 4
jr $ra
lookup_char_X:
li $v0, 5
jr $ra


# Part IX
string_sort:
li $v0, -200
li $v1, -200

li $t0, 0	#t0 is counter
move $t4, $a0
	string_sort_outer_loop:
	#Exit condition
	move $a0, $t4
	add $a0, $a0, $t0
	lb $t2, ($a0)
	sub $a0, $a0, $t0
	beqz $t2, string_sort_exit
	
	li $t1, 0	#t1 is inner counter
	#sub $a0, $a0, $t0	#reset a0 to required counter val
		string_sort_inner_loop:
		lb $t3, 1($a0)	#A[j+1]
		beqz $t3, string_sort_cont
		lb $t2, ($a0)	#A[j]
		bgt $t2, $t3, string_sort_swap
		string_sort_cont_inner:
		addi $a0, $a0, 1
		addi $t1, $t1, 1
		j string_sort_inner_loop
	string_sort_cont:
	addi $t0, $t0, 1
	j string_sort_outer_loop

string_sort_swap:
move $t5, $t3
sb $t2, 1($a0)
sb $t5, ($a0)
j string_sort_cont_inner

string_sort_exit:
move $v0, $t4
jr $ra

# Part X
decrypt:
li $v0, -200
li $v1, -200

addi $sp, $sp, -24
sw $ra, ($sp)
sw $s0, 4($sp)
sw $s1, 8($sp)
sw $s2, 12($sp)
sw $s3, 16($sp)
sw $s4, 20($sp)

move $s2, $a0	#save adfgvx_grid in t0
move $t6, $a1	#save ciphertext in t6
move $a0, $a2	#put keyword in a0
move $s3, $a3	#save plaintext addr to s3
jal length 		#get length of keyword
move $a0, $v0
li $v0, 9
syscall
move $t2, $v0	#t2 has addr of heap_keyword


move $t7, $a2	#t7 has keyword TEMP
#heap_keyword = keyword
decrypt_copy_keyword:
lb $t3, ($t7)
beqz $t3, decrypt_copy_keyword_done
sb $t3, ($t2)
addi $t7, $t7, 1
addi $t2, $t2, 1
j decrypt_copy_keyword
decrypt_copy_keyword_done:
move $a0, $a2
jal length 			#get length of keyword
sub $t2, $t2, $v0	#reset addr of heap_keyword

move $a0, $t2
jal string_sort 	#sort heap_keyword
move $t2, $v0		#t2 has sorted heap_keyword

move $a0, $a2
jal length
move $a0, $v0
li $t7, 4
mul $a0, $a0, $t7
li $v0, 9
syscall
move $s1, $v0		#t3 has heap_keyword_indices

move $t3, $s1		#put heap_keyword_indices in t3
decrypt_fill_keyword_indices:
lb $t4, ($t2)
beqz $t4, decrypt_fill_keyword_indices_done
move $a0, $a2
move $a1, $t4
jal index_of
sw $v0, ($t3)
addi $t2, $t2, 1
addi $t3, $t3, 4
j decrypt_fill_keyword_indices	
decrypt_fill_keyword_indices_done:
move $a0, $a2
jal length
sub $t2, $t2, $v0	#reset addr of heap_keyword

move $a0, $t6
jal length
move $a0, $v0
move $t5, $v0		#t5 has len(ciphertext) TEMP
li $v0, 9
syscall
move $s0, $v0		#s0 has heap_ciphertext_arr

#transpose
move $a0, $t2	
jal length
move $a2, $v0	#a2 has num_rows
div $t5, $a2		
mflo $a3		#a3 has num_cols
move $s4, $a3	#save num_cols in s4
move $a0, $t6	#a0 has matrix_src (ciphertext)
move $a1, $s0	#a1 has matrix_dest (heap_ciphertext_arr)
#NEEDED VALUES
				#s0 is heap_ciphertext_arr
				#s1 is heap_keyword_indices
				#s2 is adfgvx_grid
				#s3 is plaintext addr
				#s4 has num_cols
jal transpose

#TRANSPOSE: NUM_COLS -> NUM_ROWS
#key_sort
move $a0, $s0
jal length
move $a0, $s0		#put heap_ciphertext_arr in a0
div $v0, $s4	#put num_cols in a2
move $a1, $s4		#a1 is num_rows
mflo $a2			#a2 is num_cols
move $a3, $s1		#a3 is heap_keyword_indices (key)
li $t0, 4
addi $sp, $sp, -4
sw $t0, ($sp)		#0($sp) has arg4 : elem size = 4
jal key_sort_matrix
addi $sp, $sp, 4

#lookup_char
#s0 is addr of heap_ciphertext_arr (sorted)
#s2 is adfgvx_grid
#s3 is plaintext addr
decrypt_lookup_char_loop:
lb $t0, ($s0)
lb $t1, 1($s0)
beqz $t0, decrypt_exit
beq $t0, '*', decrypt_exit	#no reason to read empty space
move $a0, $s2
move $a1, $t0
move $a2, $t1
jal lookup_char
sb $v1, ($s3)	#put decrypted char in plaintext

addi $s3, $s3, 1
addi $s0, $s0, 2
j decrypt_lookup_char_loop

decrypt_exit:
sb $0, ($s3)	#null terminate plaintext

lw $ra, ($sp)
lw $s0, 4($sp)
lw $s1, 8($sp)
lw $s2, 12($sp)
lw $s3, 16($sp)
lw $s4, 20($sp)
addi $sp, $sp, 24
jr $ra


index_of:
#a0 has null terminated str 
#a1 has char to look for
li $v0, 0
index_of_loop:
lb $t7 ($a0)
beq $t7, $a1, index_of_return
beqz $t7, index_of_error
addi $v0, $v0, 1
addi $a0, $a0, 1
j index_of_loop
index_of_error:
li $v0, -1
index_of_return:
jr $ra

#####################################################################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
##### ANY LINES BEGINNING .data WILL BE DELETED DURING GRADING! #####
#####################################################################
