.data
line1:  .asciz "                                            ************* \n" 
line2:  .asciz "**************                             *3333333333333*\n"
line3:  .asciz "*222222222222222*                          *33333******** \n"
line4:  .asciz "*22222******222222*                        *33333*        \n"
line5:  .asciz "*22222*      *22222*                       *33333******** \n"
line6:  .asciz "*22222*        *22222*     *************   *3333333333333*\n"
line7:  .asciz "*22222*        *22222*   **11111*****111*  *33333******** \n"
line8:  .asciz "*22222*        *22222*  **1111**      **   *33333*        \n"
line9:  .asciz "*22222*       *222222*  *1111*             *33333******** \n"
line10: .asciz "*22222*******222222*   *11111*             *3333333333333*\n"
line11: .asciz "*2222222222222222*     *11111*              ************* \n"
line12: .asciz "***************        *11111*                            \n"
line13: .asciz "      ---               *1111**                           \n"
line14: .asciz "    / o o \\              *1111****   *****                \n"
line15: .asciz "    \\   > /               **111111***111*                 \n"
line16: .asciz "     -----                  ***********    dce.hust.edu.vn\n"
menu_message: .asciz "\n\n ----MENU----\n 1. Show picture.\n 2. Show picture with only border.\n 3. Change the order.\n 4. Enter new color number and update.\n 5. Exit.\n Enter your choice: "
error_message: .asciz "Input must be a integer from 1 to 5"

input_d_color: .asciz "Enter color for D (integer from 0-9):"
input_c_color: .asciz "Enter color for C (integer from 0-9):"
input_e_color: .asciz "Enter color for E (integer from 0-9):"

.text 
menu:
	# show the menu:
	li a7, 4
	la a0, menu_message
	ecall
	# get input:
	li a7, 5
	ecall
	# check for performing as input requirement
	add t0, a0, zero # t0 to store the input of user.
	li t1, 1 # user choose show picture
	beq t0, t1, printPicture
	li t1, 2 # user choose show picture withoutcolor.
	beq t0, t1, printNotColor
	li t1, 3 # user choose change order
	beq t0, t1, changeOrder
	li t1, 4
	beq t0, t1, changeColor
	li t1, 5
	beq t0, t1, exit
catch_error:
	li a7, 4
	la a0, error_message
	ecall
	j menu
printPicture:
	li t0, 0 # current row index
	li t1, 16 #  number of row
	# max_num_in_col = 60
	la a0, line1
loop_for_print_picture:
	beq t0, t1, menu # when t0 = 16, jump back to menu
	li a7, 4
	ecall
	addi a0, a0, 60 #update to the base address of next row
	addi t0, t0, 1 # increment row index to 1 (t0 = t0 + 1) 
	j loop_for_print_picture
printNotColor:
	li t0, 0 # current row index
	li t1, 16 # the last row
	li t2, '0' # the first value of color
	li t3, '9' # last value of color
	li t4, 60 # last column
	# max_num_in_col = 60
	la a1, line1 # the base address
loop_for_print_not_color: # the outer loop for row
	beq t0, t1, menu # t0 = 16, back to menu branch
	li t5, 0  # set the column index start by 0
inner_loop_not_color: # inner loop for column
	beq t5, t4, cont_loop_not_color  # traverse all column, go to next row
	lb t6, 0(a1) #  load current character from address a1 to register t6
	blt t6, t2, printChar # t6 < '0' => not color, print
	bgt t6, t3, printChar # t6 > '9' => not color, print
	li t6, ' ' # change t6 = ' ' and print replaced for color
printChar:
	li a7, 11
	mv a0, t6
	ecall
	addi t5, t5, 1 # increment column index by 1
	addi a1, a1, 1 # increment address by 1
	j inner_loop_not_color	
cont_loop_not_color:
	addi t0, t0, 1 # increment row index by 1
	j loop_for_print_not_color
changeOrder: # DCE to ECD
# E: 43
# C: 23
# D: 0
	li t0, 0
	li t1, 16
	la a1, line1
loop_for_changeOrder:
	beq t0, t1, menu
	sb zero 22(a1) # replace space between D and C by \0 
	sb zero 42(a1) # replace Space between C and E by \0
	sb zero 58(a1) # replace '\n' by \0
	# print E
	li a7, 4
	addi a0, a1, 43 # E start from base address + 43
	ecall
	#print space
	li a7, 11
	li a0, ' '
	ecall
	# print C
	li a7, 4
	addi a0, a1, 23 # E start from base address + 23
	ecall
	#print space
	li a7, 11
	li a0, ' '
	ecall
	# print D
	li a7, 4
	addi a0, a1, 0 # D start from base address
	ecall
	li a7, 11
	li a0, '\n' # change to next line after print D
	ecall
	
	li t3, ' '
	sb t3, 22(a1) # change back to ' '
	sb t3, 42(a1) # change back to ' '
	li t3, '\n'
	sb t3, 58(a1)
	addi t0, t0, 1
	addi a1, a1, 60 # update to base address of next line
	j loop_for_changeOrder
	
changeColor:
	li a5, 9 # upper bound for input
input_d:
	li a7, 4
	la a0, input_d_color
	ecall
	li a7, 5 # syscall to input a number
	ecall
	bltz a0, input_d # input < 0, back to input again
	bgt a0, a5, input_d # input > 9, back to input again
	addi t0, a0, '0' # get the char of value # char = num + '0' new color for d
input_c:
	li a7, 4
	la a0, input_c_color
	ecall
	li a7, 5
	ecall
	bltz a0, input_c
	bgt a0, a5, input_c
	addi t1, a0, '0' # get the char of value, new color for c
input_e:
	li a7, 4
	la a0, input_e_color
	ecall
	li a7, 5
	ecall
	bltz a0, input_e
	bgt a0, a5, input_e
	addi t2, a0, '0' # get the char of value, new color for e
solve_change_color:
	li t3, 0 # index i
	li t4, 16
	la a1, line1 # base address of the image
	li t6, 60
	li a2, 23 # start of C
	li a3, 43 # start of E
	li a4, '1'
	li a5, '9'
loop_for_change_color: # outer loop for row traversal
	beq t3, t4, printPicture
	li t5, 0 # j index
inner_loop_to_change_color: # inner loop for column traversal
	beq t5, t6, cont_loop_change_color # if traverse all column, go to next row
	blt t5, a2, update_D # from 0- 22, belong to 'D'
	blt t5, a3, update_C # from 23 - 42, belong to 'C'
	j update_E
update_D:
	lb s1, 0(a1) # load character at a1 to s1
	blt s1, a4, cont_inner_loop_change_color # s1 < '1', not color, traverse next column
	bgt s1, a5, cont_inner_loop_change_color # s1 > '9', not color, traverse next column 
	sb t0, 0(a1) # else, update the color by new color 
	j cont_inner_loop_change_color
update_C:
	lb s1, 0(a1)
	blt s1, a4, cont_inner_loop_change_color
	bgt s1, a5, cont_inner_loop_change_color
	sb t1, 0(a1)
	j cont_inner_loop_change_color
update_E:
	lb s1, 0(a1)
	blt s1, a4, cont_inner_loop_change_color
	bgt s1, a5, cont_inner_loop_change_color
	sb t2, 0(a1)
cont_inner_loop_change_color:
	addi t5, t5, 1 #update col index by 1
	addi a1, a1, 1 # update address
	j inner_loop_to_change_color # inner loop
cont_loop_change_color:
	addi t3, t3, 1 # update row column
	j loop_for_change_color
	
		
exit:
	li a7, 10
	ecall
	
	
