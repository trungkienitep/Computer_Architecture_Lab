.eqv RECEIVER_CONTROLLER   0xFFFF0000       # ASCII code from keyboard, 1 byte 
.eqv RECEIVER_DATA     0xFFFF0004    # =1 if has a new keycode ? 
				# Auto clear after lw 
.eqv TRANSMITTER_CONTROLLER   0xFFFF0008   # ASCII code to show, 1 byte 
.eqv TRANSMITTER_DATA    0xFFFF000C # =1 if the display has already to do 
				# Auto clear after sw
.eqv SPACE 32              # ASCII for space character
.eqv NEWLINE 10            # ASCII for newline character
.eqv BACKSPACE 8		 # ASCII for backspace character
.data
numbers:    .space 16          # Space to store the 4 random numbers (4 bytes each)
position:   .space 16		# Space to store the position of the random numbers in the matrix.
user_answer: .space 64          # Space to store user's answer 
answer_numbers_stack: .space 40	# Space to store the numbers extracted from answer 
countdown_msg: .asciz "Time remain: "
correct_msg: .asciz "Correct! Moving to next round."
wrong_msg:   .asciz "Wrong! Game Over."
error_msg1: .asciz "Wrong input syntax. Please enter your answers separated by spaces, and ending with the Enter key."
error_msg2: .asciz "Your input is out of range. Please enter your answers between 1 and 999."
error_msg3: .asciz "Enter 4 numbers only!"
.text
# -------------------------------------------------------------- 
# Main game loop
# Register used:
# Register a1: Store RECEIVER_CONTROLLER address
# Register a2: Store RECEIVER_DATA address
# Register s1: Store TRANSMITTER_CONTROLLER address
# Register s2: Store TRANSMITTER_DATA address
# Register t1: Address of Array to store numbers to remember
# Register t6: Store round counter
#--------------------------------------------------------
    li t6, 0                   
main:
    li  a1, RECEIVER_CONTROLLER
    li  a2, RECEIVER_DATA
    li  s1, TRANSMITTER_CONTROLLER
    li  s2, TRANSMITTER_DATA

    jal gen_and_disp_nums
    jal countdown_phase
    jal clear_display         
    jal gen_sixteen_nums
    jal receive_and_check
    beqz t6, exit 		# If detecting t6 equal 0 then end game
    j main			# Else, next round

# Step 1: Generate and display random numbers 
# -------------------------------------------------------------- 
# Generate and display random numbers function
# Register used:
# Register a0: Store generated number
# Register a1: Store RECEIVER_CONTROLLER address
# Register a2: Store RECEIVER_DATA address
# Register s1: Store TRANSMITTER_CONTROLLER address
# Register s2: Store TRANSMITTER_DATA address
# Register s3: Address of Array to store position numbers to remember in the matrix
# Register s6: Store the x position of the cursor
# Register s7: Store the y position of the cursor
# Register s8: Indicate that the generated number existed or not based on check_pos_dup function
# Register t1: Address of Array to store numbers to remember
# Register t2: Store the number needs to be generated
# Register t6: Store round counter
#--------------------------------------------------------   

gen_and_disp_nums:
# Store return address
    addi sp, sp, -16
    sw ra, 0(sp)
    sw s6, 4(sp)
    sw s7, 8(sp)
    sw a1, 12(sp)

    beqz t6, four_number_generation    # First loop, no need to clear
    jal clear_display         # Clear the display

four_number_generation:
    li s6, 0			# x = 0
    li s7, 0 			# y = 0
    jal move_cur_pos           # Set the start position at the point (0, 0)

    la t1, numbers             # Address to store numbers
    li t2, 4                   # Generate 4 numbers
    la s3, position	      # Address to store the position of 4 corrected numbers in the matrix
four_number_generation_loop:    
    li a1, 999                # Generate random numbers in range (0-999)
    li a7, 42                  
    ecall
    jal check_dup	 	# Check the duplication with the new generated number
    bnez s8, four_number_generation_loop # If s8 = 1 then generate again, else store the new one
    sw a0, 0(t1)               # Store random number in memory
    addi t1, t1, 4    
    jal print_number          # Display the number
    li a0, SPACE         	# Print space
    jal write_char
# Generate the position of new generated number in the matrix
pos_rand:    
    li a1, 15
    li a7, 42
    ecall
    jal check_pos_dup
    bnez s8, pos_rand	        # Check the duplication with the positon of new generated number in the matrix
    sw a0, 0(s3)
    addi s3, s3, 4
    addi t2, t2, -1            # Decrement the total numbers remained to generate
    bnez t2, four_number_generation_loop
 
# Load return address     

    lw a1, 12(sp)
    lw s7, 8(sp)
    lw s6, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 16    
    jr ra			    # Finish generating numbers step
    
# Description: Checking whether the number generated duplicated or not
# -------------------------------------------------------------- 
# check_dup function:
# Register used:
# Register a0: Store number to be checked (No need to save register a0 to stack because we don't modify it)
# Register s0: Store begining of the Arrray
# Register t1: Address of Array to store numbers to remember
# Register t2: The number stored in the Array
# Return: register s8 indicating that there is a duplication (s8 = 1) or not (s8 = 0) 
#--------------------------------------------------------
check_dup:
# Load return address
    addi sp, sp, -16
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw t1, 8(sp)
    sw t2, 12(sp)
    
    li s8, 0		# Initialize s8 = 0
    la s0, numbers
    beq s0, t1, out_dup_loop	# If there aren't any numbers stored then store it
check_dup_loop:
    addi t1, t1, -4
    lw t2, 0(t1)			# Load each number stored in the Array
    beq t2, a0,	exist_dup		# If duplicate then set s8 = 1
    beq s0, t1, out_dup_loop	# If there is no duplication then s8 remains 0
    j check_dup_loop
exist_dup:
    li s8, 1  
out_dup_loop:
    lw t2, 12(sp)
    lw t1, 8(sp)  
    lw s0, 4(sp)
    lw ra, 0(sp)  
    addi sp, sp, 16
    jr ra 			

# Description: Checking whether the positon of number generated in the matrix duplicated or not
# -------------------------------------------------------------- 
# check_pos_dup function:
# Register used:
# Register a0: Store number to be checked (No need to save register a0 to stack because we don't modify it)
# Register s0: Store begining of the Arrray of position
# Register s3: Address of Array to store the position of numbers to remember
# Register t2: The position of the number stored in the Array
# Return: register s8 indicating that there is a duplication (s8 = 1) or not (s8 = 0) 
#--------------------------------------------------------    
check_pos_dup:   
# Load return address
    addi sp, sp, -16
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw t2, 8(sp)
    sw s3, 12(sp)
    
    li s8, 0		# Initialize s8 = 0
    la s0, position
    beq s0, s3, out_pos_dup_loop	# If there aren't any numbers stored then store it
check_pos_dup_loop:
    addi s3, s3, -4
    lw t2, 0(s3)			# Load positon of each number stored in the Array
    beq t2, a0,	exist_pos_dup		# If duplicate then set s8 = 1
    beq s0, s3, out_pos_dup_loop	# If there is no duplication then s8 remains 0
    j check_pos_dup_loop
exist_pos_dup:
    li s8, 1  
out_pos_dup_loop:
    lw s3, 12(sp)
    lw t2, 8(sp)  
    lw s0, 4(sp)
    lw ra, 0(sp)  
    addi sp, sp, 16
    jr ra 
     
# Step 2: Countdown timer (fix 5 seconds)
# -------------------------------------------------------------- 
# Print countdown function
# Register used:
# Register a0: Store the countdown message
# Register a1: Store RECEIVER_CONTROLLER address
# Register a2: Store RECEIVER_DATA address
# Register s1: Store TRANSMITTER_CONTROLLER address
# Register s2: Store TRANSMITTER_DATA address
# Register t4: Store the number seconds to countdown
# Register t5: Store each character in countdown message
# Register t6: Store round counter
# Register s6: Store the x position of the cursor
# Register s7: Store the y position of the cursor
#--------------------------------------------------------        
   
countdown_phase:  
# Store return address
    addi sp, sp, -12
    sw ra, 0(sp)
    sw s6, 4(sp)
    sw s7, 8(sp)
    
    li t4, 5		# Set up the numbers of seconds to remember fixed at 5 seconds
    li s6, 0 		# x = 0
    li s7, 1		# y = 1
    
    jal move_cur_pos
# Reset the coordination after modifying in the move_cur_pos function
    li s6, 0 		# x = 0
    li s7, 1		# y = 1
    la a0, countdown_msg
print_cd_msg:
    lb t5, 0(a0)
    beqz t5, countdown_loop
    jal write_char
    addi a0, a0, 1
    addi s6, s6, 1	# Move cursor to the next position to write character
    j print_cd_msg
    
countdown_loop:
    mv a0, t4
    jal print_number          # Display countdown number
    jal delay_one_second
    jal move_cur_pos
    addi t4, t4, -1
    bgez t4, countdown_loop
    
# Load return address  
    lw s7, 8(sp)
    lw s6, 4(sp)
    lw ra, 0(sp)  
    addi sp, sp, 12
    jr ra
    
# Description: Prints the number in a0 to the display
# -------------------------------------------------------------- 
# Print_number function:
# Register used:
# Register a0: Store number to be printed out
# Register a1: Store RECEIVER_CONTROLLER address
# Register a2: Store RECEIVER_DATA address
# Register s1: Store TRANSMITTER_CONTROLLER address
# Register s2: Store TRANSMITTER_DATA address
# Register t3: Copy the value of generated number to print
# Register t4: Holds digit 10
# Register t5: Store the character to write out 
#--------------------------------------------------------    

print_number:
# Store return address
    addi sp, sp, -16
    sw ra, 0(sp)
    sw s6, 4(sp)
    sw s7, 8(sp)
    sw t4, 12(sp)
    

    mv t3, a0                  # Copy the number to t3
    li t4, 100
    div t5, t3, t4		# Extract hundred digit
    beqz t5, just_two_digit	        # If t5 = 0 move to print 2-digit number
    addi t5, t5, 48
    jal write_char		# Else write 

two_digit:
    rem t3, t3, t4		# t3 = t3 % 100
    li t4, 10
    div t5, t3, t4		# Extract tenth digit
    addi t5, t5, 48
    jal write_char 
    j one_digit
    
just_two_digit:
    rem t3, t3, t4		# t3 = t3 % 100
    li t4, 10
    div t5, t3, t4		# Extract tenth digit
    beqz t5, one_digit         # If t5 = 0 move to print 1-digit number  
    addi t5, t5, 48
    jal write_char   

one_digit:
    rem t3, t3, t4		# t3 = t3 % 10
    mv t5, t3
    addi t5, t5, 48
    jal write_char
    
print_done:
    li t5, SPACE 
    jal write_char		# Print
    addi s6, s6, 1
    
# Load return address 
    lw t4, 12(sp) 
    lw s7, 8(sp)
    lw s6, 4(sp)
    lw ra, 0(sp)  
    addi sp, sp, 16
    jr ra

# Description: Writes the character in t5 to the display
# -------------------------------------------------------------- 
# write_char function:
# Register used:
# Register s1: Store TRANSMITTER_CONTROLLER address
# Register s2: Store TRANSMITTER_DATA address
# Register t0: Store the status of Ready Bit 
# Register t5: Store the character to write out 
#--------------------------------------------------------    

write_char:
# Store return address
    addi sp, sp, -12
    sw ra, 0(sp)
    sw s6, 4(sp)
    sw s7, 8(sp)
    
    li s1, TRANSMITTER_CONTROLLER
    lw t0, 0(s1)              # Load the control register
    beqz t0, write_char       # Wait until Ready bit is 1
    li s2, TRANSMITTER_DATA            # Transmitter Data Register address
    sw t5, 0(s2)             # Write the character to the display
    
# Load return address  
    lw s7, 8(sp)
    lw s6, 4(sp)
    lw ra, 0(sp)  
    addi sp, sp, 12
    jr ra
    
# Description: Move cursor to position (x, y) 
# -------------------------------------------------------------- 
# Moving cursor function:
# Register used:
# Register a5: Store the ASCII form feed 
# Register s6: Store the x position of the cursor
# Register s7: Store the y position of the cursor
# Register s1: Store TRANSMITTER_CONTROLLER address
# Register s2: Store TRANSMITTER_DATA address
# Register t0: Store the status of Ready Bit 
# Register t5: Store the character to write out 
#--------------------------------------------------------  
  
move_cur_pos:
# Store return address
    addi sp, sp, -12
    sw ra, 0(sp)
    sw s6, 4(sp)
    sw s7, 8(sp)
    
    li a5, 7
    slli s6, s6, 20
    slli s7, s7, 8
# Modify the value to load to the right position
    or a5, a5, s6
    or a5, a5, s7
cur_wait:
    lw t0, 0(s1) # Wait until Ready bit is 1
    beq t0, zero, cur_wait
    sw a5, 0(s2)  # write the form to the ASCII code(Bell or FF)

# Load return address  
    lw s7, 8(sp)
    lw s6, 4(sp)
    lw ra, 0(sp)  
    addi sp, sp, 12

    jr ra
   
# Description: Clears the display window
# -------------------------------------------------------------- 
# clear_display function:
# Register used:
# Register a5: Store the ASCII form feed 
# Register s1: Store TRANSMITTER_CONTROLLER address
# Register s2: Store TRANSMITTER_DATA address
# Register t0: Store the status of Ready Bit 
#--------------------------------------------------------   

clear_display:
    addi sp, sp, -4
    sw ra, 0(sp)
    
    li a5, 12          # ASCII form feed
wait_clear:
    li s1, TRANSMITTER_CONTROLLER
    lw t0, 0(s1)      # Wait until Ready bit is 1
    beq t0, zero, wait_clear
    li s2, TRANSMITTER_DATA
    sw a5, 0(s2)  # write the form to the ASCII code(Bell or FF)
    
    lw ra, 0(sp)
    addi sp, sp, 4

    jr ra
    

# -------------------------------------------------------------- 
# Delay_one_second function:
#---------------------------------------------------------------   
delay_one_second:
    addi sp, sp, -16
    sw ra, 0(sp)
    sw a0, 4(sp)
    sw s6, 8(sp)
    sw s7, 12(sp)

    li a7, 32
    li a0, 1000
    ecall
    
    # Load return address  
    lw s7, 12(sp)
    lw s6, 8(sp)
    lw a0, 4(sp)
    lw ra, 0(sp)  
    addi sp, sp, 16
    jr ra
    
# Step 3: Generate 16 nunmbers
# -------------------------------------------------------------- 
# Generate and display noise numbers function
# Register used:
# Register a0: Store generated number
# Register a1: Store RECEIVER_CONTROLLER address
# Register a2: Store RECEIVER_DATA address
# Register s1: Store TRANSMITTER_CONTROLLER address
# Register s2: Store TRANSMITTER_DATA address
# Register t1: Store the rows needs to be generated
# Register t2: Store the columns needs to be generated
# Register t6: Store round counter
# Register s6: Store the x position of the cursor
# Register s7: Store the y position of the cursor
# Register s8: Store the current position in the matrix (convert to 0-15) s8 = 16 - t1 * 4 - t2
# Register s9: Indicate whether the current position is the position of generated number in the matrix or not
#---------------------------------------------------------------   

gen_sixteen_nums:
sixteen_number_generation:
# Store return address
    addi sp, sp, -8
    sw ra, 0(sp)
    sw a1, 4(sp)
    
    li s6, 0			# x = 0
    li s7, 0 			# y = 0
    jal move_cur_pos           # Set the start position at the point (0, 0)

    li t1, 4                   # Initialize 4 rows
sixteen_number_generation_loop1: 
    beqz t1,  end_gen_loop 
    li t2, 4
sixteen_number_generation_loop2:
    jal check_stored_pos		# Check whether current position is the position of stored number or not
    bnez s9, print_stored_number
    li a1, 999                 # If the current position is not 
    li a7, 42                  # Then generate random numbers in range (0-999)
    ecall
print_stored_number: 
    jal print_number          # Display the number
    li a0, SPACE         	# Print space
    jal write_char
    addi t2, t2, -1            # Decrement the total columns remained to generate
    addi s6, s6, 1
    bnez t2, sixteen_number_generation_loop2
    addi t1, t1, -1 		# Decrement the total rows remained to generate 
    li s6, 0			# Reset s6 to 0
    addi s7, s7, 1		# And move to next rows
    jal move_cur_pos
    j sixteen_number_generation_loop1
    
end_gen_loop:   
# Load return address 
    lw a1, 4(sp) 
    lw ra, 0(sp)  
    addi sp, sp, 8
    jr ra 			# Finish number generation step

# Description: Checking whether the current positon is the position of number generated in the matrix or not
# -------------------------------------------------------------- 
# check_stored_pos function:
# Register used:
# Register s0: Store begining of the Arrray of position
# Register s1: Store begining of the Arrray of stored number
# Register s3: Address of Array to store the position of numbers to remember
# Register s6: Store the x position of the cursor
# Register s7: Store the y position of the cursor
# Register s8: Store the current position in the matrix (convert to 0-15) s8 = s7 * 4 + s6
# Register t1: Address of Array to store numbers to remember
# Register t2: The position of the number stored in the Array
# Register t3: The numbers of number need to check
# Return: register a0 : Stored number to print out if s9 = 1
#	register s9 : Indicate whether the current position is the position of generated number in the matrix or not
#--------------------------------------------------------    
check_stored_pos:
# Store return address
    addi sp, sp, -36
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s3, 12(sp)
    sw s8, 16(sp)
    sw t1, 20(sp)
    sw t2, 24(sp)
    sw t3, 28(sp)
    sw a1, 32(sp)
    
    
    slli s8, s7, 2	# s8 = 4 * s7
    add s8, s8, s6	# s8 = 4 * s7 + s6
    la s0, position
    la a1, numbers
    li s9, 0
    addi a1, a1, 16
check_stored_pos_loop:
    addi s3, s3, -4
    addi a1, a1, -4
    lw t2, 0(s3)			# Load positon of each number stored in the Array
    beq t2, s8,	exist_stored_number_pos		# If match then set s9 = 1
    beq s0, s3, out_stored_pos_loop	# If there is no duplication then s8 remains 0
    j check_stored_pos_loop
exist_stored_number_pos:
    li s9, 1 
    lw a0, 0(a1)
out_stored_pos_loop:
# Load return address
    lw a1, 32(sp)
    lw t3, 28(sp)
    lw t2, 24(sp)
    lw t1, 20(sp)
    lw s8, 16(sp)
    lw s3, 12(sp)
    lw s1, 8(sp)  
    lw s0, 4(sp)
    lw ra, 0(sp)  
    addi sp, sp, 36
    jr ra 

 # Step 4: Receive and check the answer
# -------------------------------------------------------------- 
# Receiving answer function
# Register used:
# Register a0: Store the user's answer
# Register a1: Store RECEIVER_CONTROLLER address
# Register a2: Store RECEIVER_DATA address
# Register s1: Store TRANSMITTER_CONTROLLER address
# Register s2: Store TRANSMITTER_DATA address
# Register s0: Store the ASCII code of NEWLINE and BACKSPACE
# Register t0: Store the status of Ready Bit 
# Register t1: Store the character read from Receiver Data
# Register t2: Store the begining Address of user_answer
#---------------------------------------------------------------   
receive_and_check:
    addi sp, sp, -8
    sw ra, 0(sp)
    sw t2, 4(sp)
    
    la a0, user_answer
    la t2, user_answer
wait_ans:
    lw t0, 0(a1)
    beq t0, zero, wait_ans
receive_ans:
    lw t1, 0(a2)
    li s0, BACKSPACE	
    beq s0, t1, handle_backspace		# If encounter Backspace then...
    li s0, NEWLINE
    sb t1, 0(a0)		# Store to the string
    addi a0, a0, 1 		
    beq t1, s0, extract_ans	# If character read is NEWLINE then move to checking function
    j wait_ans			# Else continue to receive the answer

handle_backspace:
    beq a0, t2, wait_ans		# If user answer is empty and encounter backspace then do nothing
    addi a0, a0, -1		# Else, move back 
    j  wait_ans
back_exit: 
    mv t6, zero 
    lw t2, 4(sp) 
    lw ra, 0(sp)
    addi sp, sp, 8
    jr ra 
back_next:
    li a7, 32
    li a0, 1000
    ecall
    addi t6, t6, 1
    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra
# -------------------------------------------------------------- 
# Extracting answer function
# Register used:
# Register a0: Store the user's answer
# Register a1: Store RECEIVER_CONTROLLER address
# Register a2: Store RECEIVER_DATA address
# Register s1: Store TRANSMITTER_CONTROLLER address
# Register s2: Store TRANSMITTER_DATA address
# Register t0: Store the number taken from answer
# Register t1: Stack to store numbers taken from answer for furthur checking
# Register t3: Store the character read from answer
# Register t4: Holds some extra values to check
# Register s11: Indicates the number of answers can be input
#---------------------------------------------------------------      
extract_ans:    
    la a0, user_answer
    la t1, answer_numbers_stack
    li t0, -1 			# Initialize the number extracted from answer to -1
    li s11, -4			# Can just input 4 numbers
extract_loop:
    lb t3, 0(a0)
    li t4, 57 
    bgt t3, t4, invalid		# Invalid 
    li t4, NEWLINE
    bgtz s11, more_input_issue
    beq t3, t4, check_numbers	# If reach the newline then move to checking phase
    li t4, 48
    bge t3, t4, extract_number # If encouter the digit then move to extract number function
    li t4, SPACE 
    bne t3, t4, invalid  	# If not digit nor Newline or Space then it's invalid
    li t4, -1
    beq t0, t4, extract_next	# If encounter Space and extract a number then store it
    sw t0, 0(t1)		# Else move to next char
    addi s11, s11, 1		# Decrement the numbers remain need to be input
    li t0, -1 			# Reset t0 to -1 
    addi t1, t1, 4    	
extract_next:
    addi a0, a0, 1
    j extract_loop 

# -------------------------------------------------------------- 
# Extracting number function
# Register used:
# Register t0: Store the number taken from answer
# Register t3: Store the character read from answer
# Register t4: Holds some extra values (changing frequently)
#---------------------------------------------------------------     
extract_number:  
    li t4, -1
    bgt t0, t4, next_nb 		# If t0 = -1 then we found a new number then set t0 = 0
    mv t0, zero			
next_nb:
    li t4, 10
    mul t0, t0, t4
    li t4, 1000
    bge t0, t4, out_of_range		# If exceed 1000 then signal an issue
    addi t3, t3, -48
    add t0, t0, t3		
    j extract_next
    
# -------------------------------------------------------------- 
# Checking number function
# Register used:

# Register s0: Store the Address of Array to store numbers to remember   
# Register t0: Store the number to be checked
# Register t1: Stack to store numbers taken from answer for checking
# Register t2: Store the begining Address of the stack
# Register t3: Store the correct numbers in the Array
# Register t4: Holds some extra values (changing frequently)
# Register t5: Iterators through Array of corrected numbers
# Register s11: Indicates the number of answers can be input
#---------------------------------------------------------------   
check_numbers:
    li t4, -1
    beq t0, t4, check_each_number		# If there is no numbers left to push into stack then start to check
    sw t0, 0(t1)			# Else, store it
    addi s11, s11, 1		# Increment the numbers of answer by 1
    bnez s11,  less_input_issue
check_each_number:
    la s0, numbers
    la t2, answer_numbers_stack
    addi t2, t2, -4
    beq t1, t2, finish_check		# Finish checking all the extracted numbers
check_phase:
    li t5, 0
check_loop:
    li t4, 4
    beq t5, t4, check_next		# If the answer doesn't match then check the next number
    lw t0, 0(t1)
    lw t3, 0(s0)
    beq t0, t3, mdf_arr			# If the answer match then modify the array and move to the next answer
    add s0, s0, t4
    addi t5, t5, 1			# Else continue
    j check_loop
check_next:
    addi t1, t1, -4			# Next one
    j check_each_number

mdf_arr:
    li t4, -1	
    sw t4, 0(s0)			# Replace the matched numbers in the Array by -1 to avoid the duplicated answer.
    j check_next 		    
    
# -------------------------------------------------------------- 
# Description: Handle out of range issue
#---------------------------------------------------------------   
out_of_range:
    jal clear_display 
    li s6, 0 		# x = 0
    li s7, 0		# y = 1
    
    jal move_cur_pos
    la a0, error_msg2
    li t4, NEWLINE
print_oor_msg:
    lb t5, 0(a0)
    beqz t5, back_exit	# Finsh the game
    jal write_char
    addi a0, a0, 1
    addi s6, s6, 1	# Move cursor to the next position to write character
    j print_oor_msg
    
# -------------------------------------------------------------- 
# Description: Handle invalid issue
#---------------------------------------------------------------       
invalid: 
    jal clear_display 
    li s6, 0 		# x = 0
    li s7, 0		# y = 1
    
    jal move_cur_pos
    la a0, error_msg1
    li t4, NEWLINE
print_invalid_msg:
    lb t5, 0(a0)
    beqz t5, back_exit	# Finsh the game
    jal write_char
    addi a0, a0, 1
    addi s6, s6, 1	# Move cursor to the next position to write character
    j print_invalid_msg

# -------------------------------------------------------------- 
# Description: Conclude the result based on the Array
# Register used:
# Register s0: Store the Address of Array to store numbers to remember   
# Register t0: Store the correct numbers in the Array
# Register t1: Iterators through Array of corrected numbers
# Register t4: Holds some extra values (changing frequently)
#---------------------------------------------------------------       
finish_check:
    la s0, numbers
    li t1, 0
final_check:
    li t4, 4
    beq t1, t4, corrected_result 	# If all the numbers in the Array are negative then it's corrected answer

    lw t0, 0(s0)
    bge t0, zero, wrong_result 		# If there is a number that is greater or equal 0 
    					# which means unmatched number then the answer is wrong
    add s0, s0, t4
    addi t1, t1, 1
    j final_check
    
# -------------------------------------------------------------- 
# Description: Show out the corrected message
#---------------------------------------------------------------     
corrected_result:
    jal clear_display 
    li s6, 0 		# x = 0
    li s7, 0		# y = 1
    
    jal move_cur_pos
    la a0, correct_msg
    li t4, NEWLINE
print_corrected_msg:
    lb t5, 0(a0)
    beqz t5, back_next	# Finsh the game
    jal write_char
    addi a0, a0, 1
    addi s6, s6, 1	# Move cursor to the next position to write character
    j print_corrected_msg
    

# -------------------------------------------------------------- 
# Description: Show out the too many input issue message
#------------------------------------------------------------- 
more_input_issue:
    jal clear_display 
    li s6, 0 		# x = 0
    li s7, 0		# y = 1
    
    jal move_cur_pos
    la a0, error_msg3
print_more_input_issue:
    lb t5, 0(a0)
    beqz t5, back_exit	# Finsh the game
    jal write_char
    addi a0, a0, 1
    addi s6, s6, 1	# Move cursor to the next position to write character
    j print_more_input_issue

# -------------------------------------------------------------- 
# Description: Show out the less input issue message
#------------------------------------------------------------- 
less_input_issue:
    jal clear_display 
    li s6, 0 		# x = 0
    li s7, 0		# y = 1
    
    jal move_cur_pos
    la a0, error_msg3
print_less_input_issue:
    lb t5, 0(a0)
    beqz t5, back_exit	# Finsh the game
    jal write_char
    addi a0, a0, 1
    addi s6, s6, 1	# Move cursor to the next position to write character
    j print_less_input_issue
    
# -------------------------------------------------------------- 
# Description: Show out the wrong message
#---------------------------------------------------------------     
wrong_result:
    jal clear_display 
    li s6, 0 		# x = 0
    li s7, 0		# y = 1
    
    jal move_cur_pos
    la a0, wrong_msg
    li t4, NEWLINE
print_wrong_msg:
    lb t5, 0(a0)
    beqz t5, back_exit	# Finsh the game
    jal write_char
    addi a0, a0, 1
    addi s6, s6, 1	# Move cursor to the next position to write character
    j print_wrong_msg
    
 
exit:
    li a7, 10
    ecall
