.data
input_message1: .asciz "Enter Infix Expression: "
input_message2: .asciz "Loop "
postfix_message: .asciz "Postfix Expression with respect to: "
message1: .asciz "Invalid input. Please enter your expression again!\n"
message2: .asciz "Operand's value is out of range. Please enter your expression again!\n"
message3: .asciz "Mismatched parenthesis. Please enter your expression again!\n"
message4: .asciz "Missing operand to perform the operator. Please check your expression and enter again\n"
block: .asciz "-------------------------"
output_mes1: .asciz "The result is: "
space: .asciz " "
buffer: .space 100
postfix_expression: .space 100
all: .align 2
operator_stack: .space 40
operand_stack: .word 40 
.text
main:
	li t6, 0 		# Store round
	beqz t6, input		# First loop, no need to reset
reset: #reset all value to 0
	li a0, 0
	li a1, 0
	li a2, 0
	li a3, 0
	li s0, 0
	li s1, 0
	li s2, 0
	li s3, 0
	li t0, 0
	li t1, 0
	li t2, 0
	li t3, 0
	li t4, 0
input:	
        li a7, 4
        la a0, block #print -----------------------
        ecall
        li a7, 11 #print '\n'
        li a0, '\n'
        ecall
# Print the current loop
        li a7, 4
        la a0, input_message2
        ecall
        li a7, 1
        mv a0, t6	
        ecall
        li a7, 11
        li a0, '\n'
        ecall
	li a7, 4
	la a0, input_message1
	ecall
 	li a7, 8 
 	la a0, buffer
 	li a1, 100
 	ecall
 	
	li s11, 'e' 
	lb s10, 0(a0)
	beq s11,s10, exit
# -------------------------------------------------------------- 
# Infix to Postfix Procedure:
# 1.Scan the infix expression from left to right. 
# 2.If the scanned character is an operand, put it in the postfix expression. 
# 3.Otherwise, do the following:
#  -If the precedence of the current scanned operator is higher than the precedence of the operator on top of the stack, 
# 	or if the stack is empty, or if the stack contains a ‘(‘, then push the current operator onto the stack.
#  -Else, pop all operators from the stack that have precedence higher than or equal to that of the current operator. 
# 	After that push the current operator onto the stack.
# 4.If the scanned character is a ‘(‘, push it to the stack. 
# 5.If the scanned character is a ‘)’, pop the stack and output it until a ‘(‘ is encountered, and discard both the parenthesis. 
# 6.Repeat steps 2-5 until the infix expression is scanned. 
# 7.Once the scanning is over, Pop the stack and add the operators in the postfix expression until it is not empty.
# 8. Finally, print the postfix expression.
# --------------------------------------------------------------

# -------------------------------------------------------------- 
# Infix to Postfix:
# Register a1 : Postfix Expression
# Register a2 : Register to store Operators' value to check OR store some values in order to check operand 
# Register s0 : Infix Expression
# Register s1 : Temporary store the address of Operator Stack  to check whether if it's empty or not
# Register s3 :	Operator Stack
# Register t0 : Store the current value of operand 
# Register t1 : Current char
# Register t2 : Temporary hold the digit of operand to store into Postfix Expression
# Register t3 : Indicates the number of open brackets '(' is in the stack 
# Register t4 : Store the operator in the top of stack 
# --------------------------------------------------------------
ifx2pfx:
# Message:
	li a7, 4
	la a0, postfix_message
	ecall
# Infix to Prefix 
	la s0, buffer
	la a1, postfix_expression
	la s3, operator_stack
	li t0, -1
loop:
	lb t1, 0(s0)	#take each char of the string
	li a2, 58 	
	bge t1, a2, invalid #if ascii > 58 -> out range
	beqz t1, bf_eval 	# If encounter '\0' then move to Evaluation Phase
# Check Operand
	li a2, 48
	bge t1, a2, check_operand	#if ascii > 48, <58 -> is operand
	li a2, -1	       		
	beq t0, a2, find_operator 	 # If we don't encounter number then find  and the value of t0 is not equal -1 then find operator
	jal store_and_print		# Else encounter number (value of t0 is not equal -1) then store it to Postfix and print it.
					# before finding operator
find_operator:	
	# Check Space
	li a2, 32 
	beq t1, a2, next # If encounter space then move to next character
	# Addition
	li a2, 43
	beq t1, a2, handle_first_precedence
	# Subtraction 
	li a2, 45
	beq t1, a2, handle_first_precedence
	#  Multiplication
	li a2, 42
	beq t1, a2, handle_second_precedence
	# Division
	li a2, 47
	beq t1, a2, handle_second_precedence
	# Division with remainder 
	li a2, 37
	beq t1, a2, handle_second_precedence
	# Open round brackets
	li a2, 40
	beq t1, a2, push_bracket
	# Closed round brackets
	li a2, 41
	beq t1, a2, handle_closed_bracket
	# Encounter newline then move to next char
	li a2, 10
	beq t1, a2, next
	# If cannot find any operator then invalid
	j invalid
next:
	addi s0, s0, 1	#next char
	j loop
invalid: #if invalid print error commet and run loop again
	li a7, 11
 	li a0, '\n'
 	ecall
	li a7, 4	
	la a0, message1
	ecall
	li a7, 4
        la a0, block
        ecall
        li a7, 11
        li a0, '\n'
        ecall
        addi t6, t6, 1
	j reset
	
# Check whether if operand is out of range or not
check_operand:
	li a2, -1
	bgt t0, a2, new_oper 	# If t0 = -1 then set t0 to 0
	li t0, 0
new_oper:
	li a2, 10
	mul t0, t0, a2	#if the number has 2 digit -> mul 10 
	li a2, 100 
	bge t0, a2, out_of_range # If value of t0 is greater than or equal 100 then print out the message.
	addi t1, t1, -48 # Transfer value of t1 to range from 0 to 9
	add t0, t0, t1  #t0 = current num (0-9)
	j next

out_of_range: #Print error commet and run loop again
 	li a7, 11
 	li a0, '\n'
 	ecall
	li a7, 4
	la a0, message2
	ecall
	li a7, 4
        la a0, block
        ecall
        li a7, 11
        li a0, '\n'
        ecall
        addi t6, t6, 1
	j reset

store_and_print:
	# Print operand
	li a7, 1
	mv a0, t0
	ecall
	li a7, 4
	la a0, space
	ecall

	# Store operand to Postfix
	li a2, 10
	div t2, t0, a2 # t2 = t0 / 10
	beqz t2, one_digit
	addi t2, t2, 48 # Change to value in Ascii
	sb t2, 0(a1)
	addi a1, a1, 1
	j one_digit
one_digit:
	rem t2, t0, a2 # t2 = t0 % 10
	addi t2, t2, 48 # Change to value in Ascii
	sb t2, 0(a1)
	addi a1, a1, 1
	
	li a2, 32
	sb a2, 0(a1) # Store space 
	addi a1, a1, 1
	li t0, -1 # Reset value of t0 to -1 after storing and printing
	jr ra 

# Handling operator
	# Handling first precedence
handle_first_precedence:	
	la s1, operator_stack
	beq s3, s1, push_operator # If stack is empty, then push operator
	lw t4, 0(s3)
	li a2, 40 
	beq t4, a2, push_operator # If the top of stack is '(', then push operator
#	bnez t3,  push_operator # If there is a '(',  then push operator
	
	# Else pop all operators in stack and then push new operator
pop_operator_loop:
	beq s3, s1, push_operator  # If stack is empty now then push new operator
	lw t4, 0(s3)
	li a2, 40
	beq t4, a2, push_operator # If the top of stack is '(', then push operator
	jal store_and_print_operator
	addi s3, s3, -4
	j pop_operator_loop
	
	# Handling second precedence
handle_second_precedence:	
	la s1, operator_stack
	beq s3, s1, push_operator # If stack is empty, then push operator
	lw t4, 0(s3)
	li a2, 40
	beq t4, a2, push_operator # If the top of stack is '(', then push operator
#	bnez t3,  push_operator # If there is a '(',  then push operator
	
	# Else pop all operators in stack and then push new operator
pop_loop:
	beq s3, s1, push_operator  # If stack is empty now then push new operator
	lw t4, 0(s3)
	li a2, 40
	beq t4, a2, push_operator # If the top of stack is '(', then push operator
	# If the operator in the top of stack has predence less than current operator then push operator to the stack
	li a2, 43 
	beq t4, a2, push_operator # If the top of stack is '-', then push operator
	li a2, 45
	beq t4, a2, push_operator # If the top of stack is '+', then push operator

	# Else 
	jal store_and_print_operator
	addi s3, s3, -4
	j pop_loop

push_operator:
	sw t1, 4(s3)
	addi s3, s3, 4
	j next	
	
#push_sec_pred_operator:
	#sw t4, 0(s3)  # Push the less predence operator before push current operator.
	#addi s3, s3, 4
	#sw t1, 0(s3)
	#j next		
# Handling open bracket

push_bracket:
	sw t1, 4(s3)
	addi t3, t3, 1 # Increase number of open bracket in stack by 1
	addi s3, s3, 4
	j next
	
# Handling closed bracket
handle_closed_bracket:
	beqz t3, syntax_error

pop_bracket_loop:
	lw t4, 0(s3)
	li a2, 40
	beq t4, a2, free_bracket # If encounter open bracket then free
	jal store_and_print_operator
	addi s3, s3, -4
	j pop_bracket_loop
free_bracket:
	addi s3, s3, -4
	addi t3, t3, -1 # Decerement number of open bracket in stack by 1
	j next
	

store_and_print_operator:
	# Print operator
	li a7, 11
	mv a0, t4
	ecall
	li a7, 4
	la a0, space
	ecall

	# Store operator to Postfix
	sb t4, 0(a1) 
	addi a1, a1, 1
	li a2, 32
	sb a2, 0(a1) # Store space 
	addi a1, a1, 1
	jr ra
# Before Evaluating	
bf_eval: 
# First check if there exist mismatch open bracket or not
	bnez t3, syntax_error
# Store and print operand if remain 
	li a2, -1
	beq t0, a2, pop_all # If there is no operand that hasn't been stored and printed then move to store and print operators remain phase
	# Print operand
	li a7, 11
	mv a0, t0
	ecall
	li a7, 4
	la a0, space
	ecall

	# Store operand to Postfix
	li a2, 10
	div t2, t0, a2 # t2 = t0 / 10
	beqz t2, one_digit_case
	addi t2, t2, 48 # Change to value in Ascii
	sb t2, 0(a1)
	addi a1, a1, 1

one_digit_case:
	rem t2, t0, a2 # t2 = t0 % 10
	addi t2, t2, 48 # Change to value in Ascii
	sb t2, 0(a1)
	addi a1, a1, 1

	li a2, 32
	sb a2, 0(a1) # Store space 
	addi a1, a1, 1
	li t0, -1 # Reset value of t0 to 0 after storing and printing
# Store and print operators remain 
pop_all:
	la s1, operator_stack
	beq s3, s1, eval  # If stack is empty now then move to evaluation
	lw t4, 0(s3)
	li a2, 40
	beq t4, a2, pop_next
	jal store_and_print_operator
pop_next:
	addi s3, s3, -4
	j pop_all
	
# Evaluation Phase
# Algorithm:
# Iterate the expression from left to right and keep on storing the operands into a stack. 
# Once an operator is received, pop the two topmost elements and evaluate them and push the result in the stack again.

# -------------------------------------------------------------- 
# Evaluation Procedure:
# Input: a1 - Postfix Expression
# Register using:
# Register a1 : Postfix Expression
# Register a2 : Register to store Operators' value to check OR store some values in order to check operand 
# Register s0 : Iterator through Postfix Expression 
# Register s1 : Temporary store the address of Operator Stack  to check whether if it's empty or not
# Register s2 :	Operand Stack
# Register s3 : Store the begining address of Operand Stack
# Register t0 : Store the current value of operand 
# Register t1 : Current char
# Register t2 : Holds value to perform operator
# Register t3 : Holds value to perform operator
# Register t4 : Holds the result of expression
# --------------------------------------------------------------
	eval:
		la s0, postfix_expression
		la s2, operand_stack
		la s3, operand_stack
	eval_loop:
		beq s0, a1, print_result  	# Finish 
		lb t1, 0(s0)
		# Check Operand
		li a2, 48
		bge t1, a2, handle_operand	 # If encounter number then ...
		li a2, -1
		bgt t0, a2, add_operand 	 # Else if value of t0 is not equal -1 which means value of t1 now is value of operand 
						# then add it to stack
						# Else t0 = 0 
	# Addition
	li a2, 43
	beq t1, a2, addition
	# Subtraction 
	li a2, 45
	beq t1, a2, subtraction
	#  Multiplication
	li a2, 42
	beq t1, a2, multiplication
	# Division
	li a2, 47
	beq t1, a2, division
	# Division with remainder 
	li a2, 37
	beq t1, a2, div_rem
	# If encounter space then move to next char
next_char:
	addi s0, s0, 1
	j eval_loop
	
# Handling operand when evaluating
handle_operand:
	li a2, -1
	bgt t0, a2, new_operand 	# If t0 = -1 then set t0 to 0
	li t0, 0
new_operand:
	li a2, 10
	mul t0, t0, a2
	addi t1, t1, -48 # Transfer value of t1 to range from 0 to 9
	add t0, t0, t1 
	j next_char
add_operand:
	sw t0, 4(s2) 
	addi s2, s2, 4
	li t0, -1 	# Reset value of t0
	j next_char
	
# Handling operator when evaluating
addition:
	lw t2, 0(s2)
	addi s2, s2, -4
	beq s2, s3, miss_operand_error	# If there is only one operand in the stack the issue an error
	lw t3, 0(s2)
	addi s2, s2, -4
	add t2, t2, t3 # Perform additon
	sw t2, 4(s2) # Store result back into stack
	addi s2, s2, 4
	j next_char
subtraction:
	lw t2, 0(s2)
	addi s2, s2, -4
	beq s2, s3, miss_operand_error		# If there is only one operand in the stack the issue an error
	lw t3, 0(s2)
	addi s2, s2, -4
	sub t2, t3, t2 # Perform subtraction
	sw t2, 4(s2) # Store result back into stack
	addi s2, s2, 4
	j next_char
multiplication:
	lw t2, 0(s2)
	addi s2, s2, -4
	beq s2, s3, miss_operand_error		# If there is only one operand in the stack the issue an error
	lw t3, 0(s2)
	addi s2, s2, -4
	mul t2, t2, t3 # Perform multiplication
	sw t2, 4(s2) # Store result back into stac
	addi s2, s2, 4
	j next_char
division:
	lw t2, 0(s2)
	addi s2, s2, -4
	beq s2, s3, miss_operand_error		# If there is only one operand in the stack the issue an error
	lw t3, 0(s2)
	addi s2, s2, -4
	div t2, t3, t2 # Perform division
	sw t2, 4(s2) # Store result back into stack
	addi s2, s2, 4
	j next_char
div_rem:
	lw t2, 0(s2)
	addi s2, s2, -4
	beq s2, s3, miss_operand_error		# If there is only one operand in the stack the issue an error
	lw t3, 0(s2)
	addi s2, s2, -4
	rem t2, t3, t2 # Perform division with remainder:
	sw t2, 4(s2) # Store result back into stack
	addi s2, s2, 4
	j next_char
	
# Print result
print_result:
	lw t4, 0(s2) # Take result
	li a7, 11
	li a0, '\n'
	ecall
	li a7, 4
	la a0, output_mes1
	ecall
	li a7, 1
	mv a0, t4
	ecall
	li a7, 11
        li a0, '\n'
        ecall
        li a7, 4
        la a0, block
        ecall
        li a7, 11
        li a0, '\n'
        ecall
        addi t6, t6, 1 		# Increment round
	j reset
	
syntax_error:
	li a7, 11
        li a0, '\n'
        ecall
	li a7, 4
	la a0, message3
	ecall
        li a7, 4
        la a0, block
        ecall
        li a7, 11
        li a0, '\n'
        ecall
        addi t6, t6, 1
	j reset

miss_operand_error:
	li a7, 11
        li a0, '\n'
        ecall
	li a7, 4
	la a0, message4
	ecall
        li a7, 4
        la a0, block
        ecall
        li a7, 11
        li a0, '\n'
        ecall
        addi t6, t6, 1
	j reset	
exit:
	li a7, 10
	ecall 
	
