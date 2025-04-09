# 1. Connect the program
# 2. Assemble
# 3. Reset 
# 4. Set delay length to 1 instruction execution, this will synchronize read and write action of Transmitter Data Register
	.eqv KEY_CODE 0xFFFF0004 # ASCII code from keyboard, 1 byte
	.eqv KEY_READY 0xFFFF0000 # =1 if has a new keycode ?
	# Auto clear after lw
	.eqv DISPLAY_CODE 0xFFFF000C # ASCII code to show, 1 byte
	.eqv DISPLAY_READY 0xFFFF0008 # =1 if the display has already to do
	# Auto clear after sw
.data:
	A: .word 1,2,3,4
	mes: .asciz "Timer: "
	# used register val: t0, a0, a1, s0, s1, s8, s9, s10, s11
.text
set_up_program:
	li a0, KEY_CODE
	li a1, KEY_READY
	li s0, DISPLAY_CODE
	li s1, DISPLAY_READY
	li s9, 12
	jal clear_display
	li s10, 0
	li s11, 0
	jal move_cursor # clear screen first
	addi t0, sp, 0 # pointer to saved correct number
	li t1, 0 # number of gened int counted
	li t2, 4
	la s2, A
###------------------###
# generate four random number, save each number by each digit in stack, separate by ascii char " "
gen_random_num:
	beq t1, t2, print_to_display # if generate all 4 numbers, print them to display
	li a7, 42
	li a0, 0
	li a1, 1000 # bound of gened number
	ecall
	li a7, 1 
	sw a0, 0(s2)
	addi s2, s2, 4
	# ecall # print to screen, s? xoá sau
	addi t4, t0, 0 # t4 is parameter pointer to save number to stakc
	addi a0, a0, 0 # a0 hold number to save
	jal save_num # save number to stack
	addi t0, t4, 0 # return value of new pointer in stack, set value to t0
	addi t1, t1, 1
	li a7, 11
	li a0, 32
	ecall
	j gen_random_num # generate new number
	# end function to generate number
###------------------###
# ------ #
# function to save number to stack
save_num:
	li t5, 10 # mod number
save_delimiter:
	li t6, -16 # delimiter value, is space in ascii value
	addi t4, t4, -4
	sw t6, 0(t4)
save_loop:
	beq a0, zero, end_save_num
	rem t6, a0, t5
	div a0, a0, t5
	addi t4, t4, -4
	sw t6, 0(t4)
	j save_loop
end_save_num:
	jr ra
# end function to save number
# ------ #
# # --- --- --- # #
# function to print 4 gened number to display
print_to_display:
	# t0 is pointer to a position in stack where t0 + 1 -> sp hold int to guess
	li a0, KEY_CODE
	li a1, KEY_READY
	li s0, DISPLAY_CODE
	li s1, DISPLAY_READY
	addi t1, t0, 0
	li s10, 0 	# set start column
	li s11, 0	# set start row
	jal move_cursor
loop_through_stack:
	beq t1, sp, end_display
	lw t2, 0(t1) # get int char from stack
wait_for_dis:
	lw t3, 0(s1) # t2 = [s1] = DISPLAY_READY
	beq t3, zero, wait_for_dis # if t2 == 0 then polling
show_key:
	addi t2, t2, 48 # since t2 is int value, we set t2 += 48 <=> t2 += '0'
	sw t2, 0(s0)
	addi t1, t1, 4
	j loop_through_stack
end_display:
# # --- --- --- # #
## ### ------------- ### ##
print_timer:
	li s10, 0 # set columns start value for timer
	li s11, 1 # set row start value for timer
	jal move_cursor  	
set_up_timer_para:
	la t5, mes
print_mes:
	lb t4, 0(t5)
	beq t4, zero, end_print_mes
wait_print_mes:
	lw t6, 0(s1)
	beq t6, zero, wait_print_mes
	sw t4, 0(s0)
	addi t5, t5, 1
	j print_mes
end_print_mes:
## ### ------------- ### ##
## ========= ========= ========= ##
count_down:
	li t5, 0	# second to countdown, in tenth
	li t6, 5	# second to countdown, in digit
set_cursor_print_time:
	li s10, 7 	# set column value to print time
	li s11, 1	# set row value to print time
	jal move_cursor
print_second_cd:
print_tenth:
	lw t1, 0(s1)         # Check if display is ready
    	beq t1, zero, print_tenth # Wait until the display is ready
    	addi t5, t5, 48
    	sw t5, 0(s0)
    	addi t5, t5, -48
print_digit:
	lw t1, 0(s1)         # Check if display is ready
    	beq t1, zero, print_digit # Wait until the display is ready
	addi t6, t6, 48
	sw t6, 0(s0)
	addi t6, t6, -48
	li a7, 32
	li a0, 1000
	ecall
decrement_both:
	blt zero, t6, decrement_and_repeat
	addi t6, t6, 9
	addi t5, t5, -1
	blt t5, zero, end_timer
	li s10, 7
	li s11, 1
	jal move_cursor
	j print_tenth
decrement_and_repeat:
	addi t6, t6, -1
	li s10, 8
	li s11, 1
	jal move_cursor
	j print_digit
end_timer:
	
## ========= ========= ========= ##
clear_screen:
	li s9, 12
	jal clear_display
	li s10, 0
	li s11, 0
	jal move_cursor
print_number_fct:
	# t0 hold pointer to stack where correct value are held
	li t1, 16 # max number of int to print
	addi t3, t0, 0 # pointer in stack that hold true number
	li t2, 4 # number of true value left needed to print to screen
	li t4, 0 # number of fake value printed to screen
	li a6, 0 # total number of int printed to screen
print_num:
	li a7, 41
	li a0, 0
	ecall # get random integer
	beq t3, sp, print_mock_int # if print all true int, only print mock int
	li a6, 0
	add a6, t2, t4 
	bge a6, t1, print_true_int # if still has true value left, print true value
	blt a0, zero, print_mock_int # if random int < 0, print fake int
	j print_true_int
# >>>>>>>><<<<<<<<<< #
print_true_int:
	lw s7, 0(s1)
	beq s7, zero, print_true_int
	lw a4, 0(t3) # get int value in stack
	addi t3, t3, 4
	addi a4, a4, 48
	sw a4, 0(s0)
	addi a4, a4, -32 # if a4 is ascii code for space char, then a4 - 32 = 0
	beq a4, zero, post_print_true
	j print_true_int
print_mock_int:
	li a7, 42
	li a0, 0
	li a1, 1000
	ecall # get random int in [0, 1000]
	li t5, 10
print_digit_loop:
	rem t6, a0, t5 # get last digit
another_wait:
	lw s7, 0(s1)         # Check if display is ready
    	beq s7, zero, another_wait # Wait until the display is ready
	addi t6, t6, 48
	sw t6, 0(s0)
	addi t6, t6, -48
	div a0, a0, t5 # divide by 10
	beq a0, zero, post_print_mock # if finish printing fake int, go to post print
	j print_digit_loop
# >>>>>>>><<<<<<<<<< #
#	|	|	#
post_print_mock:
print_space:
	lw s7, 0(s1)
	beq s7, zero, print_space
	li t6, 32
	sw t6, 0(s0) # print space to screen
	addi t4, t4, 1 # increase fake number print to screen
	j newline_decider
post_print_true:
	addi t2, t2, -1 # increase true number print to screen
newline_decider:
	# after each four number, move cursor down one row, set column to 0
	li t5, 4
	li a6, 0
	sub a6, a6, t2
	addi a6, a6, 4
	add a6, a6, t4 
	beq a6, t1, end_print_num
	rem t5, a6, t5 # remainder of num_of_int_print % 4
	beq t5, zero, new_line
	j old_line
new_line:
	li s10, 0
	srli s11, s11, 8 # since in move_cursor, s11 *= 2^8, we have to divide by 2^8 first
	addi s11, s11, 1 # since above we set initial s11 = 0, we increment them after each four num
	jal move_cursor
old_line:
	j print_num
end_print_num:
#	|	|	#
###/////////////////////###
get_user_ans:
	li s10, 0 # number of int that user has entered
	li s11, 3 # number of int that user supposed to enter by the time 'entered'
set_up:
	li a0, KEY_CODE
	li a1, KEY_READY
	li s0, DISPLAY_CODE
	li s1, DISPLAY_READY
	li t1, 0 # number getted
	li t2, 10 # multiplication value
	li t5, 48 # 0 in ascii
	li t6, 57 # 9 in ascii
	li s3, 32 # space in ascii
	li s4, 10 # newline in ascii
loop:
wait_for_key:
	lw t3, 0(a1)
	beq t3, zero, wait_for_key
read_key:
	lw t4, 0(a0)
	beq t4, s3, space
	beq t4, s4, newline
	blt t4, t5, end_program
	blt t6, t4, end_program
	addi t4, t4, -48
	mul t1, t1, t2
	add t1, t1, t4
	j wait_for_key
space:
	addi s10, s10, 1
	blt s11, s10, end_program
	la s2, A
	li s5, 0 # number checked in A
	li s7, 4 # max number in A
check_int:
	lw s6, 0(s2)
	beq s5, s7, end_program # if we go through all number in A and get no match, end program
	beq t1, s6, mark_int_in_A # if we find a match, mark them with -1
	addi s5, s5, 1 # increase number of A we go through
	addi s2, s2, 4 # increase address pointer
	j check_int
mark_int_in_A:
	li s6, -1
	sw s6, 0(s2)
	j set_up # after verify number in A, return to getting user input
newline:
	blt s10, s11, end_program
	j next_round
	
###/////////////////////###
#-------------------------
# function to movie cursor to a (x,y) position
# s10 hold value of new cursor column
# s11 hold value of new cursor row
# s9 = 7 signal transmission register to movie cursor 
# s9 = 12 signal clear screen
move_cursor:
    	li s9, 7          # ASCII for form feed
clear_display:
    	slli s10, s10, 20 # move column value to start bit of x, 20
    	slli s11, s11, 8  # move row value to start bit of y, 8
    	or s9, s9, s10
    	or s9, s9, s11
wait_cursor:
    	lw s8, 0(s1)         # Check if display is ready
    	beq s8, zero, wait_cursor # Wait until the display is ready
    	sw s9, 0(s0)         # write the form to move cursor
    	jr ra
#------------------------
end_program:
	li a7, 10
	ecall
next_round:
	j set_up_program
