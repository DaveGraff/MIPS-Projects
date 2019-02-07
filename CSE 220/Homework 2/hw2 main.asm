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

### Part I ###
index_of_car:
	li $v0, -200
	li $v1, -200
	
	# Error checking
	blez $a1 index_of_car_error # length <= 0
	bltz $a2 index_of_car_error # start_index < 0
	bge $a2, $a1, index_of_car_error # start_index >= length
	blt $a3, 1885, index_of_car_error # year < 1885
	
	#Put used variables on the stack
	addi $sp, $sp, -12
	sw $t0, 8($sp)
	sw $t1, 4($sp)
	sw $t2, 0($sp)
	
	#Put the first element to the year byte & check
	move $t0, $a0		#t0 is index of arr
	addi $t0, $t0, 12	#Get val of year
	lh $t1, ($t0)		#t1 has the value of year
	beq $a3, $t1, index_of_car_valid
	addi $t2, $0, 1		#t2 is current length
	
	index_of_car_loop:
	beq $t2, $a1,index_of_car_error	#Print -1 if not found
	addi $t0, $t0, 16		#Jump to next year (I wish it were that simple..)
	lh $t1, ($t0)			#Put new year in t1
	beq $a3, $t1, index_of_car_valid
	addi $t2, $t2, 1		#Update length
	j index_of_car_loop
	
	index_of_car_valid:		
	move $v0, $t2
	j index_of_car_exit
	
	index_of_car_error:
	li $v0, -1
	index_of_car_exit:
	# Remove items from stack
	lw $t2, 0($sp)
	lw $t1, 4($sp)
	lw $t0, 8($sp)
	addi $sp, $sp, 12
	
	jr $ra
	

### Part II ###
strcmp:
	li $v0, -200
	li $v1, -200
	
	#Put used variables on the stack
	addi $sp, $sp, -16
	sw $t0, 12($sp)
	sw $t1, 8($sp)
	sw $t2, 4($sp)
	sw $t3, 0($sp)
	
	move $t0, $a0	#t0 has str1
	move $t1, $a1	#t1 has str2
	strcmp_loop:
	lb $t2, ($t0)	#t2 has str1 char to be checked
	lb $t3, ($t1)	#t3 has str2 char to be checked
	bne $t2, $t3, strcmp_find_difference
	beqz $t2, strcmp_first_empty
	beqz $t3, strcmp_second_empty
	
	#Get addr of next char
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	j strcmp_loop
	
	strcmp_first_empty:
	beq $t2, $t3, strcmp_both_empty
	li $v0, -1	#length counter
	addi $t1, $t1, 1#get next bit in address
	strcmp_first_empty_loop:
	lb $t3, ($t1)	#t3 has str2 char to be checked
	beqz $t3, strcmp_exit
	addi $v0, $v0, -1
	addi $t1, $t1, 1
	j strcmp_first_empty_loop
	
	
	strcmp_second_empty:
	li $v0, 1	#length counter
	addi $t0, $t0, 1
	strcmp_second_empty_loop:
	lb $t2, ($t0)	#t2 has str1 char to be checked
	beqz $t2, strcmp_exit
	addi $v0, $v0, 1
	addi $t0, $t0, 1
	j strcmp_second_empty_loop
	
	strcmp_both_empty:
	li $v0, 0
	j strcmp_exit
	
	strcmp_find_difference:
	sub $v0, $t2, $t3
	j strcmp_exit
	
	strcmp_exit:
	#Take used variables off the stack
	lw $t3, 0($sp)
	lw $t2, 4($sp)
	lw $t1, 8($sp)
	lw $t0, 12($sp)
	addi $sp, $sp, 16
	
	jr $ra


### Part III ###
memcpy:
	li $v0, -200
	li $v1, -200
	
	#Put used variables on the stack
	addi $sp, $sp, -12
	sw $t0, 8($sp)
	sw $t1, 4($sp)
	sw $t2, 0($sp)
	
	blez $a2, memcpy_error
	move $t0, $a0	#t0 has src
	move $t1, $a1	#t1 has dest
	move $t2, $a2	#t2 has n
	memcpy_loop:
	beqz $t2, memcpy_no_error
	lb $t3, ($t0)	#load byte to be stored
	sb $t3, ($t1)	#store byte in correct address
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	addi $t2, $t2, -1
	j memcpy_loop
	
	memcpy_error:
	li $v0, -1
	j memcpy_exit
	
	memcpy_no_error:
	li $v0, 0
	j memcpy_exit
	
	memcpy_exit:
	# Remove items from stack
	lw $t2, 0($sp)
	lw $t1, 4($sp)
	lw $t0, 8($sp)
	addi $sp, $sp, 12
	
	jr $ra

### Part IV ###
insert_car:
	li $v0, -200
	li $v1, -200
	
	#Error checking
	bltz $a1, insert_car_error	#length < 0
	bltz $a3, insert_car_error	#index < 0
	bgt $a3, $a1, insert_car_error	#index > length
	
	#Move registers onto stack
	addi $sp, $sp, -24
	sw $t0, 20($sp)
	sw $t1, 16($sp)
	sw $t2, 12($sp)
	sw $t3, 8($sp)
	sw $t4, 4($sp)
	sw $t5, 0($sp)
	
	move $t0, $a0	#t0 has addr of cars arr start
	move $t1, $a1	#t1 has length cars length
	move $t2, $a2	#t2 has the new car to insert
	move $t3, $a3	#t3 has the index to insert at
	
	addi $t4, $t1, 1	#t4 = length + 1
	li $t5, 16
	mult $t4, $t5
	mflo $t4		#t4 = (length + 1) * 16
	add $t4, $t4, $t0	#t4 has start of last index
	insert_car_mover_loop:
	#move everything at & after index right 1
	beq $t3, $t1, insert_car_loop_end
	li $a2, 16
	move $a0, $t4
	addi $a1, $t4, -16
	
	#put ra on sp
	addi $sp, $sp, -4	
	sw $ra, ($sp)
	
	jal memcpy	#Move car 1 place to the right
	#take ra off sp
	lw $ra, ($sp)
	addi $sp, $sp, 4
	
	addi $t1, $t1, -1
	addi $t4, $t4, -16
	j insert_car_mover_loop
	
	insert_car_loop_end:
	#insert car at index
	li $t4, 16
	mult $t4, $t3		#Get byte addr offset
	mflo $t4		#retrieve product
	add $t4, $t4, $t0	#Get byte addr to insert at
	li $a2, 16	
	move $a1, $t4	
	move $a0, $t2	
	#put ra on sp
	addi $sp, $sp, -4	
	sw $ra, ($sp)
	jal memcpy	#move car into index
	#take ra off sp
	lw $ra, ($sp)
	addi $sp, $sp, 4
	j insert_car_no_error
	
	insert_car_error:
	li $v0, -1
	j insert_car_exit
	
	insert_car_no_error:
	li $v0, 0
	j insert_car_exit
	
	insert_car_exit:
	#Take registers off the stack
	lw $t0, 20($sp)
	lw $t1, 16($sp)
	lw $t2, 12($sp)
	lw $t3, 8($sp)
	lw $t4, 4($sp)
	lw $t5, 0($sp)
	addi $sp, $sp, 24
	
	jr $ra
	

### Part V ###
most_damaged:
	li $v0, -200
	li $v1, -200
	
	#Error checking
	blez $a2, most_damaged_error
	blez $a3, most_damaged_error
	
	#Put used variables on the stack
	addi $sp, $sp, -36
	sw $s0, 32($sp)
	sw $t0, 28($sp)
	sw $t1, 24($sp)
	sw $t2, 20($sp)
	sw $t3, 16($sp)
	sw $t4, 12($sp)
	sw $t5, 8($sp)
	sw $t6, 4($sp)
	sw $t7, 0($sp)
	
	move $s0, $a0 	#s0 is cars arr
	#a1 is repair arr
	#a2 is cars length
	#a3 is repairs length
	li $t0, 0	#t0 is most damaged car cost
	li $t1, -1	#t1 is most damaged car index (in car arr)
	li $t4, 0	#t4 has current index of car
	most_damaged_car_loop:
	beq $t4, $a2, most_damaged_done #index == length
	li $t3, 0	#t3 has current repair cost
	li $t5, 0	#t5 is repair loop counter
	move $t6, $a1	#t6 is current index of repair arr
		most_damaged_repair_loop:
		beq $t5, $a3, most_damaged_car_loop_check #index == length
		lw $t7, ($t6)	#t7 has ptr to the car
		bne $t7, $s0, most_damaged_repair_no_match #compares addresses of cars
		lhu $t2, 8($t6)		#put cost of repair into t2
		add $t3, $t3, $t2	#Add repair cost to total
		most_damaged_repair_no_match:
		addi $t6, $t6, 12	#get next element in repair loop
		addi $t5, $t5, 1	#increment counter
		j most_damaged_repair_loop
	most_damaged_car_loop_check:
	#check if latest car has a higher repair cost
	bgt $t3, $t0, most_damaged_exceeds_current
	
	most_damaged_car_loop_cont:
	addi $s0, $s0, 16	#get next element in cars arr
	addi $t4, $t4, 1	#move to next index
	j most_damaged_car_loop
	
	
	most_damaged_exceeds_current:
	move $t1, $t4
	move $t0, $t3
	j most_damaged_car_loop_cont
	
	most_damaged_error:
	li $v0, -1
	li $v1, -1
	j most_damaged_exit
	
	most_damaged_done:
	move $v0, $t1
	move $v1, $t0
	j most_damaged_exit
	
	most_damaged_exit:
	#Take used variables off the stack
	lw $s0, 32($sp)
	lw $t0, 28($sp)
	lw $t1, 24($sp)
	lw $t2, 20($sp)
	lw $t3, 16($sp)
	lw $t4, 12($sp)
	lw $t5, 8($sp)
	lw $t6, 4($sp)
	lw $t7, 0($sp)
	addi $sp, $sp, -36
	jr $ra


### Part VI ###
sort:
	li $v0, -200
	li $v1, -200
	
	#Error checking
	blez $a1, sort_error	#length <= 0
	
	#Save ra for returning
	addi $sp, $sp, -4
	sw $ra, ($sp)	
	
	move $t1, $a0	#t1 is addr of arr
	li $t0, 0	#t0 is sorted var
	addi $t2, $a1, -1	#t2 is length -1
	sort_loop:
	bnez $t0, sort_success
	addi $t0, $t0, 1
	li $t3, 1	#t3 is counter
	addi $t4, $t1, 16 	#t4 is addr of arr to be modified
		sort_odd:
		bgt $t3, $t2, sort_odd_done
		lh $t5, 12($t4) #cars[i].year
		lh $t6, 28($t4) #cars[i+1].year
		bgt $t5, $t6, sort_swap_odd
		sort_odd_cont:
		addi $t4, $t4, 32
		addi $t3, $t3, 2
		j sort_odd
	sort_swap_odd:
	jal sort_swap
	j sort_odd_cont
	
	sort_odd_done:	
	li $t3, 0	#setup counter for even swap
	move $t4, $t1	#reset addr
		sort_even:
		bgt $t3, $t2, sort_loop
		lh $t5, 12($t4) #cars[i].year
		lh $t6, 28($t4) #cars[i+1].year
		bgt $t5, $t6, sort_swap_even
		sort_even_cont:
		addi $t4, $t4, 32
		addi $t3, $t3, 2
		j sort_even
	
	sort_swap_even:
	jal sort_swap
	j sort_even_cont
	
	j sort_loop
	
	sort_error:
	li $v0, -1
	j sort_exit
	
	#swap given variables
	sort_swap:
	addi $sp, $sp, -4
	sw $ra, ($sp)	#Save ra for returning
	addi $sp, $sp, -16
	#memcpy(cars[i], $sp, 16)
	move $a0, $t4
	move $a1, $sp
	li $a2, 16
	jal memcpy
	
	#memcpy(cars[j], cars[i], 16)
	addi $a0, $t4, 16
	move $a1, $t4
	li $a2, 16
	jal memcpy
	
	#memcpy($sp, cars[j], 16)
	move $a0, $sp
	addi $a1, $t4, 16
	li $a2, 16
	jal memcpy
	
	addi $sp, $sp, 16
	lw $ra, ($sp)	#Retrieve ra
	addi $sp, $sp, 4
	li $t0, 0
	jr $ra
	
	sort_success:
	li $v0, 1
	j sort_exit
	
	sort_exit:
	#Retrieve ra
	lw $ra, ($sp)	
	addi $sp, $sp, 4
	
	jr $ra


### Part VII ###
most_popular_feature:
	li $v0, -200
	li $v1, -200
	
	#Error checking
	blez $a1, most_popular_feature_error
	bgt $a2, 15, most_popular_feature_error
	blt $a2, 1, most_popular_feature_error
	
	move $t0, $a0	#t0 is arr
	li $t1, -1	#t1 is convertible num
	li $t2, -1	#t2 is hybrids
	li $t3, -1	#t3 is tinted
	li $t4, -1	#t4 is GPS
	
	#Set t1 to 0 if it should be counted
	sll $t5, $a2, 31
	srl $t5, $t5, 31
	add $t1, $t1, $t5 
	
	#Set t2 to 0 if it should be counted
	sll $t5, $a2, 30
	srl $t5, $t5, 31
	add $t2, $t2, $t5 
	
	#Set t3 to 0 if it should be counted
	sll $t5, $a2, 29
	srl $t5, $t5, 31
	add $t3, $t3, $t5 
	
	#Set t4 to 0 if it should be counted
	sll $t5, $a2, 28
	srl $t5, $t5, 31
	add $t4, $t4, $t5 
	
	addi $t0, $t0, 14 #get arr addr to features
	li $t6, 0	#t6 is counter
	most_popular_loop:
	beq $a1, $t6, most_popular_determinate
	lb $t7, ($t0) #Get features byte
		convertible_loop:#add 1 to convertible if it should be counted
		beq $t1, -1, hybrid_loop
		sll $t5, $t7, 31
		srl $t5, $t5, 31
		add $t1, $t1, $t5 
		
		hybrid_loop:
		beq $t2, -1, tinted_loop
		sll $t5, $t7, 30
		srl $t5, $t5, 31
		add $t2, $t2, $t5 
		
		tinted_loop:
		beq $t3, -1, gps_loop
		sll $t5, $t7, 29
		srl $t5, $t5, 31
		add $t3, $t3, $t5 
		
		gps_loop:
		beq $t4, -1, append_loop
		sll $t5, $t7, 28
		srl $t5, $t5, 31
		add $t4, $t4, $t5 
		
	append_loop:
	addi $t6, $t6, 1
	addi $t0, $t0, 16
	j most_popular_loop
	
	most_popular_determinate:
	bgt $t3, $t4, tinted_most_popular
	bgt $t2, $t4, tinted_most_popular
	bgt $t1, $t4, tinted_most_popular
	beqz $t4, most_popular_feature_error
	beq $t4, -1, most_popular_feature_error
	li $v0, 8
	j most_popular_exit
	
	tinted_most_popular:
	bgt $t2, $t3, hybrid_most_popular
	bgt $t1, $t3, hybrid_most_popular
	beqz $t3, most_popular_feature_error
	beq $t3, -1, most_popular_feature_error
	li $v0, 4
	j most_popular_exit
	
	hybrid_most_popular:
	bgt $t1, $t2, convertible_most_popular
	beqz $t2, most_popular_feature_error
	beq $t2, -1, most_popular_feature_error
	li $v0, 2
	j most_popular_exit
	
	convertible_most_popular:
	beqz $t1, most_popular_feature_error
	beq $t1, 0 , most_popular_feature_error
	li $v0, 1
	j most_popular_exit
	
	most_popular_feature_error:
	li $v0, -1
	j most_popular_exit
	
	most_popular_exit:
	jr $ra
	

### Optional function: not required for the assignment ###
##transliterate(str, ch)
transliterate:
	li $v0, -200
	li $v1, -200
	
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $t0, ($sp)
	
	jal index_of
	
	li $t0, 10
	div $v0, $t0	# index of(ch) % 10
	mfhi $v0
	
	lw $t0, ($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 8
	
	jr $ra


### Optional function: not required for the assignment ###
##char_at(str, index) 
char_at:
	li $v0, -200
	li $v1, -200
	
	addi $sp, $sp, -4
	sw $t0, ($sp)
	
	char_at_loop:
	beqz $a1, char_at_success
	lb $t0, ($a0)
	addi $a1, $a1, -1
	j char_at_loop
	
	char_at_success:
	lb $v0, ($a0)
	j char_at_exit
	
	char_at_exit:
	lw $t0, ($sp)
	addi $sp, $sp, 4
	jr $ra


### Optional function: not required for the assignment ###
##index_of(str, ch)
index_of:
	li $v0, -200
	li $v1, -200
	
	#Save used registers on stack
	addi $sp, $sp, -8
	sw $t0, 4($sp)
	sw $t1, ($sp)
	
	li $t1, 0	#t1 is counter
	index_of_loop:
	lb $t0, ($a0) 	#t0 is val to be compared
	beq $a1, $t0, index_of_found
	addi $t1, $t1, 1
	addi $a0, $a0, 1
	j index_of_loop
	
	index_of_found:
	move $v0, $t1
	j index_of_exit
	
	index_of_exit:
	#Take items off the stack
	lw $t1, ($sp)
	lw $t0, 4($sp)
	addi $sp, $sp, 8
	jr $ra


### Part VIII ###
compute_check_digit:
	li $v0, -200
	li $v1, -200
	
	#save registers & ra in sp
	addi $sp, $sp, -32
	sw $ra, 28($sp)
	sw $t0, 24($sp)
	sw $t1, 20($sp)
	sw $t2, 16($sp)
	sw $t3, 12($sp)
	sw $t4, 8($sp)
	sw $t5, 4($sp)
	sw $t6, ($sp)
	
	li $t0, 0	#t0 is sum
	li $t1, 0	#t1 is i
	move $t2, $a0	#t2 is vin
	move $t3, $a1	#t3 is map
	li $t6, 0	#t6 is map offset
	compute_check_loop:
	beq $t1, 17, compute_check_done
	#t4 = transliterate(vin.charAt(i), transliterate_str)
	move $a0, $a3	#a0 is transliterate str
	lb $a1, ($t2)	#a1 is char of vin
	jal transliterate
	move $t4, $v0	#t4 is intermediate result
	
	#weights.char_at(i)
	move $a0, $a2	#move weights to a0
	move $a1, $t1	#move i into a1
	jal char_at
	
	#map.index_of(weights.char_at(i))
	move $a0, $t3	#move map to a0
	move $a1, $v0
	jal index_of
	
	mul $t5, $v0, $t4	#t5 is to be added to sum
	add $t0, $t0, $t5	
	
	#iterate
	#addi $t3, $t3, 1
	addi $t1, $t1, 1
	#addi $t6, $t6, -1
	addi $t2, $t2, 1
	j compute_check_loop
	
	compute_check_done:
	#add $t3, $t3, $t6
	li $t1, 11 #old t1 is no longer needed
	div $t0, $t1 #sum % 11
	move $a0, $t3 #a0 is map
	mfhi $a1
	jal char_at
	
	#take things off sp
	lw $t6, ($sp)
	lw $t5, 4($sp)
	lw $t4, 8($sp)
	lw $t3, 12($sp)
	lw $t2, 16($sp)
	lw $t1, 20($sp)
	lw $t0, 24($sp)
	lw $ra, 28($sp)
	addi $sp, $sp, 32
	
	jr $ra	

#####################################################################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
##### ANY LINES BEGINNING .data WILL BE DELETED DURING GRADING! #####
#####################################################################
