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
init_game:
li $v0, -200
li $v1, -200
#a0 has filename
#a1 has map ptr 
#a2 has player ptr
move $t1, $a1	#t1 has map ptr
move $t2, $a2	#t2 has player ptr

addi $sp, $sp, -4
sw $ra, 0($sp)

#Open the file
li $v0, 13
li $a1, 0
li $a2, 0
syscall

bltz $v0, init_error
move $t0, $v0	#t0 has file descriptor

#read rows
move $a0, $t0	#a0 has fie descriptor
move $a1, $t1	#t1 has map ptr
li $a2, 3	#Read just bytes for dimensions
li $v0, 14
syscall
lb $a0, 0($t1)
lb $a1, 1($t1)
jal init_ASCII_to_num
sb $v0, 0($t1)
addi $t1, $t1, 1

#read columns
move $a0, $t0	#a0 has fie descriptor
move $a1, $t1	#t1 has map ptr
li $a2, 3	#Read just bytes for dimensions
li $v0, 14
syscall
lb $a0, 0($t1)
lb $a1, 1($t1)
jal init_ASCII_to_num
sb $v0, 0($t1)
addi $t1, $t1, 1

lb $t3, -2($t1)	#t3 has num rows
lb $t4, -1($t1)	#t4 has num cols
addi $t4, $t4, 1#t4 has num cols including nl
mul $t7, $t3, $t4	#t7 has # of map chars to read
li $t5, 0
init_read_loop:
beq $t5, $t7 init_loop_done
move $a0, $t0	#a0 has fie descriptor
move $a1, $t1	#t1 has map ptr
li $a2, 1		#Read just bytes for dimensions
li $v0, 14
syscall

lb $t6, ($t1)		
beq $t6, '@', init_handle_player
beq $t6, 10, init_handle_nl
ori $t6, $t6, 0x80	#set hidden tag
sb $t6, ($t1)
init_continue_loop:

addi $t5, $t5, 1	#increment counter
addi $t1, $t1, 1	#get correct addr
j init_read_loop
init_loop_done:

#Read player hp
move $a0, $t0	#a0 has fie descriptor
move $a1, $t2	#t2 has map ptr
li $a2, 2		#Read just bytes for dimensions
li $v0, 14
syscall
lb $a0, 0($t2)
lb $a1, 1($t2)
jal init_ASCII_to_num
sb $v0, 0($t2)
addi $t2, $t2, 1

#add # of coins collected
sb $0, 0($t2)

#close file
move $a0, $t0
li $v0, 16
syscall

j init_done

init_handle_player:
ori $t6, $t6, 0x80	#set hidden tag
sb $t6, ($t1)
addi $t4, $t4, -1
div $t5, $t4	#current place / num rows
mflo $t6
sb $t6, ($t2)	#store row # in player ptr
mfhi $t6
sb $t6, 1($t2)	#store column # in player ptr
addi $t2, $t2, 2
addi $t4, $t4, 1
j init_continue_loop

init_handle_nl:
addi $t1, $t1, -1
addi $t5, $t5, -1
addi $t7, $t7, -1
j init_continue_loop

init_error:
lw $ra, 0($sp)
addi $sp, $sp, 4
li $v0, -1
jr $ra

init_done:
lw $ra, 0($sp)
addi $sp, $sp, 4
li $v0, 0
jr $ra


init_ASCII_to_num:
addi $a0, $a0, -48
addi $a1, $a1, -48
li $v0, 10
mul $v0, $v0, $a0
add $v0, $v0, $a1
jr $ra


# Part II
is_valid_cell:
li $v0, -200
li $v1, -200

lbu $t1, 0($a0)
lbu $t2, 1($a0)

bltz $a1, is_valid_false
bltz $a2, is_valid_false
bge $a1, $t1, is_valid_false 
bge $a2, $t2, is_valid_false
#Is true
li $v0, 0
jr $ra

is_valid_false:
li $v0, -1
jr $ra


# Part III
get_cell:
li $v0, -200
li $v1, -200

addi $sp, $sp, -4
sw $ra, ($sp)

jal is_valid_cell
beq $v0, -1, get_cell_error

lbu $t0, 1($a0)	#t0 has row size
mul $t0, $t0, $a1 #t0 has row offset
add $t0, $t0, $a2
addi $a0, $a0, 2
add $a0, $a0, $t0
lb $v0, ($a0)

lw $ra, ($sp)
addi $sp, $sp, 4
jr $ra

get_cell_error:
li $v0, -1
lw $ra, ($sp)
addi $sp, $sp, 4
jr $ra


# Part IV
set_cell:
li $v0, -200
li $v1, -200

addi $sp, $sp, -4
sw $ra, ($sp)

jal is_valid_cell
bltz $v0, set_cell_error

lbu $t0, 1($a0)
mul $t0, $t0, $a1
add $t0, $t0, $a2
add $a0, $a0, $t0
addi $a0, $a0, 2

sb $a3, ($a0)
li $v0, 0
lw $ra, ($sp)
addi $sp, $sp, 4
jr $ra

set_cell_error:
lw $ra, ($sp)
addi $sp, $sp, 4
jr $ra

# Part V
reveal_area:
li $v0, -200
li $v1, -200

addi $sp, $sp, -16
sw $ra, 12($sp)
sw $s0, 8($sp)
sw $s1, 4($sp)
sw $s2, 0($sp)

move $s0, $a0		#s0 has map ptr
addi $s1, $a1, 2	#s1 has row bound
addi $s2, $a2, 2	#s2 has column bound
addi $t6, $a1, -1	#t6 has starting row
addi $t7, $a2, -1	#t7 has starting column

reveal_area_row_loop:
beq $t6, $s1, reveal_area_done
	reveal_area_column_loop:
	beq $t7, $s2, reveal_column_done

	move $a0, $s0
	move $a1, $t6
	move $a2, $t7
	jal get_cell
	beq $v0, -1, reveal_area_column_loop_cont
	move $a0, $s0
	move $a1, $t6
	move $a2, $t7
	andi $a3, $v0, 0x7F 
	jal set_cell

	reveal_area_column_loop_cont:
	addi $t7, $t7, 1
	j reveal_area_column_loop
reveal_column_done:
addi $t7, $t7, -3
addi $t6, $t6, 1
j reveal_area_row_loop

reveal_area_done:
lw $ra, 12($sp)
lw $s0, 8($sp)
lw $s1, 4($sp)
lw $s2, 0($sp)
addi $sp, $sp, 16
jr $ra

# Part VI
get_attack_target:
li $v0, -200
li $v1, -200

addi $sp, $sp, -4
sw $ra, ($sp)

lbu $t6, 0($a1)	#t6 has player row
lbu $t7, 1($a1)	#t7 has player column

beq $a2, 'U', get_attack_U
beq $a2, 'D', get_attack_D
beq $a2, 'L', get_attack_L
beq $a2, 'R', get_attack_R
j get_attack_error
get_attack_check_index:

move $a1, $t6
move $a2, $t7
jal get_cell
beq $v0, -1, get_attack_error
andi $v0, $v0, 0x7F	#make bit visible

beq $v0, 'B', get_attack_done
beq $v0, 'm', get_attack_done
beq $v0, '/', get_attack_done
j get_attack_error

get_attack_done:
lw $ra, ($sp)
addi $sp, $sp, 4
jr $ra

get_attack_error:
li $v0, -1
lw $ra, ($sp)
addi $sp, $sp, 4
jr $ra

get_attack_U:
addi $t6, $t6, -1
j get_attack_check_index

get_attack_D:
addi $t6, $t6, 1
j get_attack_check_index

get_attack_L:
addi $t7, $t7, -1
j get_attack_check_index

get_attack_R:
addi $t7, $t7, 1
j get_attack_check_index


# Part VII
complete_attack:
li $v0, -200
li $v1, -200

addi $sp, $sp, 12
sw $ra, 0($sp)
sw $s0, 4($sp)
sw $s1, 8($sp)

move $s0, $a0	#s0 has map ptr
move $s1, $a1	#s1 has player ptr
move $t6, $a2	#t6 has target row
move $t7, $a3	#t7 has target column

move $a1, $t6
move $a2, $t7
jal get_cell
andi $v0, $v0, 0x7F	#make bit visible

lb $t0, 2($s1)	#t0 has current player health

beq $v0, 'm', attack_handle_mob
beq $v0, 'B', attack_handle_boss
beq $v0, '/', attack_handle_door
j complete_attack_error
complete_attack_change_target:
move $a0, $s0
move $a1, $t6
move $a2, $t7
jal set_cell

lb $t0, 2($s1)	#t0 has current player health
blez $t0, complete_attack_dead

complete_attack_done:
lw $ra, 0($sp)
lw $s0, 4($sp)
lw $s1, 8($sp)
addi $sp, $sp, -12
jr $ra

attack_handle_mob:
addi $t0, $t0, -1
sb $t0, 2($s1)
li $a3, '$' 
j complete_attack_change_target

attack_handle_boss:
addi $t0, $t0, -2
sb $t0, 2($s1)
li $a3, '*'
j complete_attack_change_target

attack_handle_door:
li $a3, '.'
j complete_attack_change_target

complete_attack_error:
lw $ra, 0($sp)
lw $s0, 4($sp)
lw $s1, 8($sp)
addi $sp, $sp, -12
jr $ra

complete_attack_dead:
move $a0, $s0
lbu $a1, 0($s1)
lbu $a2, 1($s1)
li $a3, 'X'
jal set_cell
j complete_attack_done

# Part VIII
monster_attacks:
li $v0, -200
li $v1, -200

addi $sp, $sp, -20
sw $ra, ($sp)
sw $s0, 4($sp)
sw $s1, 8($sp)
sw $s2, 12($sp)
sw $s3, 16($sp)

move $s0, $a0	#s0 has map ptr
lbu $s1, 0($a1)	#s1 has player row
lbu $s2, 1($a1)	#s2 has player col
li $s3, 0

#(-, 0)
move $a0, $s0
addi $a1, $s1, -1
move $a2, $s2
jal get_cell
move $a0, $v0
jal get_monster_damage
add $s3, $s3, $v0

#(+, 0)
move $a0, $s0
addi $a1, $s1, 1
move $a2, $s2
jal get_cell
move $a0, $v0
jal get_monster_damage
add $s3, $s3, $v0

#(0, -)
move $a0, $s0
move $a1, $s1
addi $a2, $s2, -1
jal get_cell
move $a0, $v0
jal get_monster_damage
add $s3, $s3, $v0

#(0, -)
move $a0, $s0
move $a1, $s1
addi $a2, $s2, 1
jal get_cell
move $a0, $v0
jal get_monster_damage
add $s3, $s3, $v0

move $v0, $s3
lw $ra, ($sp)
lw $s0, 4($sp)
lw $s1, 8($sp)
lw $s2, 12($sp)
lw $s3, 16($sp)
addi $sp, $sp, 20
jr $ra

get_monster_damage:
andi $a0, $a0, 0x7F	#make bit visible
beq $a0, 'm', monster_dmg_one
beq $a0, 'B', monster_dmg_two
li $v0, 0
jr $ra

monster_dmg_one:
li $v0, 1
jr $ra

monster_dmg_two:
li $v0, 2
jr $ra

# Part IX
player_move:
li $v0, -200
li $v1, -200

addi $sp, $sp, -20
sw $ra, ($sp)
sw $s0, 4($sp)
sw $s1, 8($sp)
sw $s2, 12($sp)
sw $s3, 16($sp)

move $s0, $a0	#s0 has map
move $s1, $a1	#s1 has player
move $s2, $a2	#s2 has target row
move $s3, $a3	#s3 has target col

jal monster_attacks
lbu $t0, 2($s1)	#t0 has current health
sub $t0, $t0, $v0
sb $t0, 2($s1)	#update player health
blez $t0, player_move_dead

#start to move player
move $a0, $s0
lbu $a1, 0($s1)
lbu $a2, 1($s1)
li $a3, '.'
jal set_cell

#mark player's new location
sb $s2, 0($s1)
sb $s3, 1($s1)

#get target cell input
move $a0, $s0
move $a1, $s2
move $a2, $s3
jal get_cell 	
andi $v0, $v0, 0x7F	#make bit visible

#prepare to replace target cell
move $a0, $s0
move $a1, $s2
move $a2, $s3
li $a3, '@'

#branch for cases
beq $v0, '$', player_move_coin
beq $v0, '*', player_move_treasure
beq $v0, '.', player_move_nothing
jal set_cell
li $v0, -1	#towards door is default behavior

player_move_exit:
lw $ra, ($sp)
lw $s0, 4($sp)
lw $s1, 8($sp)
lw $s2, 12($sp)
lw $s3, 16($sp)
addi $sp, $sp, 20
jr $ra

player_move_dead:
move $a0, $s0
lbu $a1, 0($s1)
lbu $a2, 1($s1)
li $a3, 'X'
jal set_cell
li $v0, 0
j player_move_exit

player_move_coin:
jal set_cell
lbu $t0, 3($s1)
addi $t0, $t0, 1
sb $t0, 3($s1)
li $v0, 0
j player_move_exit

player_move_treasure:
jal set_cell
lbu $t0, 3($s1)
addi $t0, $t0, 5
sb $t0, 3($s1)
li $v0, 0
j player_move_exit

player_move_nothing:
jal set_cell
li $v0, 0
j player_move_exit

# Part X
player_turn:
li $v0, -200
li $v1, -200

addi $sp, $sp, -24
sw $ra, ($sp)
sw $s0, 4($sp)
sw $s1, 8($sp)
sw $s2, 12($sp)
sw $s3, 16($sp)
sw $s4, 20($sp)

move $s0, $a0	#s0 has map
move $s1, $a1	#s1 has player
move $s4, $a2	#s4 has direction for get_attack_target later

lbu $t0, 0($a1)	#t0 has player row
lbu $t1, 1($a1)	#t1 has player col

beq $a2, 'U', player_turn_U
beq $a2, 'D', player_turn_D
beq $a2, 'L', player_turn_L
beq $a2, 'R', player_turn_R
j player_turn_error
player_turn_set_target:
move $s2, $t0	#s2 has target row
move $s3, $t1	#s3 has target col

move $a0, $s0
move $a1, $s2
move $a2, $s3
jal get_cell
beq $v0, -1, player_turn_return_zero	#cell is not a valid index
andi $v0, $v0, 0x7F	#make bit visible
beq $v0, 35, player_turn_return_zero	#cell is a wall (# character)

move $a0, $s0
move $a1, $s1
move $a2, $s4
jal get_attack_target
#prepare for either complete_attack or player_move
move $a0, $s0
move $a1, $s1
move $a2, $s2
move $a3, $s3
beq $v0, -1, player_turn_player_move
jal complete_attack
j player_turn_return_zero

player_turn_exit:
lw $ra, ($sp)
lw $s0, 4($sp)
lw $s1, 8($sp)
lw $s2, 12($sp)
lw $s3, 16($sp)
lw $s4, 20($sp)
addi $sp, $sp, -24
jr $ra

player_turn_error:
li $v0, -1
j player_turn_exit

player_turn_return_zero:
li $v0, 0
j player_turn_exit

player_turn_player_move:
jal player_move
j player_turn_exit

player_turn_U:
addi $t0, $t0, -1
j player_turn_set_target

player_turn_D:
addi $t0, $t0, 1
j player_turn_set_target

player_turn_L:
addi $t1, $t1, -1
j player_turn_set_target

player_turn_R:
addi $t1, $t1, 1
j player_turn_set_target

# Part XI
flood_fill_reveal:
li $v0, -200
li $v1, -200

addi $sp, $sp, -24
sw $ra, 0($sp)
sw $fp, 4($sp)
sw $s0, 8($sp)
sw $s1, 12($sp)
sw $s2, 16($sp)	#s2 is current row
sw $s3, 20($sp)	#s3 is current col

move $s0, $a0	#s0 has map
jal is_valid_cell 	#check for proper flood_fill coords
bltz $v0, flood_fill_error

move $s1, $a3	#s1 has visited map
move $fp, $sp
addi $sp, $sp, -1	#push row
sb $a1, 0($sp)
addi $sp, $sp, -1	#push col
sb $a2, 0($sp)
flood_fill_main_loop:
beq $fp, $sp, flood_fill_success

# Get cell from index and set it to be visible
lb $s3, ($sp)	#a2 has col
lb $s2, 1($sp)	#a1 has row
addi $sp, $sp, 2
move $a0, $s0
jal get_cell
andi $v0, $v0, 0x7F	#make bit visible
move $a3, $v0
move $a1, $s2	#a1 has row
move $a2, $s3	#a2 has col
move $a0, $s0
jal set_cell

#(0,1)
#check if cell is a floor tile
move $a0, $s0	#a0 has map
move $a1, $s2	#a1 has row
move $a2, $s3	#a2 has col
addi $a1, $a1, 1
jal get_cell
andi $v0, $v0, 0x7F	#make bit visible
bne $v0, '*', flood_fill_next_one
#check if cell is visited
move $a0, $s1	#a0 has visited map
move $a1, $s2	#a1 has row
move $a2, $s3	#a2 has col
addi $a1, $a1, 1
jal get_cell
bne $v0, 1, flood_fill_next_one
move $a1, $s2	#a1 has row
move $a2, $s3	#a2 has col
addi $a1, $a1, 1
jal flood_fill_push
flood_fill_next_one:

#(0,-1)
#check if cell is a floor tile
move $a0, $s0	#a0 has map
move $a1, $s2	#a1 has row
move $a2, $s3	#a2 has col
addi $a1, $a1, -1
jal get_cell
andi $v0, $v0, 0x7F	#make bit visible
bne $v0, '*', flood_fill_next_two
#check if cell is visited
move $a0, $s1	#a0 has visited map
move $a1, $s2	#a1 has row
move $a2, $s3	#a2 has col
addi $a1, $a1, -1
jal get_cell
bne $v0, 1, flood_fill_next_two
move $a1, $s2	#a1 has row
move $a2, $s3	#a2 has col
addi $a1, $a1, -1
jal flood_fill_push
flood_fill_next_two:

#(1,0)
#check if cell is a floor tile
move $a0, $s0	#a0 has map
move $a1, $s2	#a1 has row
move $a2, $s3	#a2 has col
addi $a2, $a2, 1
jal get_cell
andi $v0, $v0, 0x7F	#make bit visible
bne $v0, '*', flood_fill_next_three
#check if cell is visited
move $a0, $s1	#a0 has visited map
move $a1, $s2	#a1 has row
move $a2, $s3	#a2 has col
addi $a2, $a2, 1
jal get_cell
bne $v0, 1, flood_fill_next_three
move $a1, $s2	#a1 has row
move $a2, $s3	#a2 has col
addi $a2, $a2, 1
jal flood_fill_push
flood_fill_next_three:

#(-1,0)
#check if cell is a floor tile
move $a0, $s0	#a0 has map
move $a1, $s2	#a1 has row
move $a2, $s3	#a2 has col
addi $a2, $a2, -1
jal get_cell
andi $v0, $v0, 0x7F	#make bit visible
bne $v0, '*', flood_fill_next_done
#check if cell is visited
move $a0, $s1	#a0 has visited map
move $a1, $s2	#a1 has row
move $a2, $s3	#a2 has col
addi $a2, $a2, -1
jal get_cell
bne $v0, 1, flood_fill_next_done
move $a1, $s2	#a1 has row
move $a2, $s3	#a2 has col
addi $a2, $a2, -1
jal flood_fill_push
flood_fill_next_done:

j flood_fill_main_loop

flood_fill_push:
addi $sp, $sp, -1
sb $a0, 0($sp)	#store next row in sp
addi $sp, $sp, -1
sb $a1, 0($sp)	#store next col in sp
move $a2, $a1
move $a1, $a0
move $a0, $s1	#a0 has visited map
li $a3, 1
jal set_cell
jr $ra

flood_fill_exit:
lw $ra, 0($sp)
lw $fp, 4($sp)
lw $s0, 8($sp)
lw $s1, 12($sp)
lw $s2, 16($sp)
lw $s3, 20($sp)
addi $sp, $sp, 24
jr $ra

flood_fill_success:
li $v0, 0
j flood_fill_exit

flood_fill_error:
li $v0, -1
j flood_fill_exit




#####################################################################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
############### DO NOT CREATE A .data SECTION! ######################
##### ANY LINES BEGINNING .data WILL BE DELETED DURING GRADING! #####
#####################################################################
