.eqv SEVENSEG_LEFT 0xFFFF0011  # Address of left 7-segment led
.eqv SEVENSEG_RIGHT 0xFFFF0010 # Address of right 7-segment led
.eqv KEY_CODE 0xFFFF0004       # Simulated keyboard input code
.eqv KEY_READY 0xFFFF0000      # Keyboard input ready flag

.data
num_arr: .byte 63, 6, 91, 79, 102, 109, 125, 7, 127, 111  # 7-segment values for digits from 0 to 9
string: .asciz "Computer Architecture Lab"				  # Char count: 25
msg_display_time: .asciz "\nElapsed time: "
msg_display_wpm: .asciz "(s) \nAverage typing speed: "
msg_wpm: .asciz " words/minute\n"
msg_continue: .asciz "Do you want to continue to test typing speed?"

.text
.globl main
main:
    li a7, 30          # Load syscall 30 to obtain current time in ms
    ecall              
    mv t5, a0          # Save the start time in t5

    li s0, 0           # Correct character count
    li s1, 0           # Word count
    li s2, 32          # Initialize previous character to space
    la a1, string      # Load string base address

# Main Loop
loop:
    li t0, KEY_READY    # KEY_READY address
    lb t1, 0(t0)        # Read KEY_READY
    bnez t1, keyboard_intr  # If key is ready, handle input
    j loop              # Repeat loop

# Keyboard Interrupt Handling
keyboard_intr:
    li t0, KEY_CODE     # KEY_CODE address
    lb t2, 0(t0)        # Load key pressed
    beqz t2, loop       # Skip if no key pressed

    # Check for backspace key
    li t4, 8            # ASCII for backspace
    beq t2, t4, handle_backspace # Handle backspace input

    # Check for enter key
    li s3, 10           # ASCII for newline/enter
    beq t2, s3, display_result	# If user press enter, display testing result	

    # Compare with current character of hardcoded string
    lb t3, 0(a1)        # Load current string character
    beq t2, t3, handle_correct_char # If match, count as correct
    j handle_space     # Handle space key input

# Input character match string character
handle_correct_char:
    addi s0, s0, 1       # Increment correct character count
    j handle_space

# Handle space input
handle_space:
    li t4, 32            # ASCII for space
    beq t2, t4, check_prev_space # If space is pressed, jump to check
    j check_new_word

# Check if previour character is also a space
# Preventing incorrect word count by ignoring consecutive spaces
check_prev_space:
	li t4, 32
    beq s2, t4, update	 
    j update

# Check if we reach a new word
check_new_word:
    li t4, 32             # ASCII for space
    beq s2, t4, increment_word_count # If previous char is space, new word starts
    j update

increment_word_count:
    addi s1, s1, 1        # Increment word count
    
# Update previous character and move to next character
update:
    mv s2, t2            # Update previous character
    addi a1, a1, 1       # Move to next character of the string
    j loop

# Correctly handle backspace key pressed
handle_backspace:
    la t6, string       # Base address of the string
    beq a1, t6, loop    # If at start of string, do nothing and comeback to loop
    addi a1, a1, -1     # Move string pointer back a character

# Check if the character being backspaced matches the current character in the string
# If it does, the correct character count is decremented to ensure correct char count
check_correct_count:
    lb t3, 0(a1)        # Reload the string character
    beq t3, s2, decrement_correct_count # Decrease correct char count

# Decrease the correct character count when a backspaced character was counted as correct
decrement_correct_count:
    addi s0, s0, -1     # Decrement correct character count
    j loop

# Display Testing Results
display_result:
    li a7, 30          # Load syscall 30 to obtain current time in ms
    ecall              
    mv t6, a0          # Save the end time in t6
	
    li a7, 4
    la a0, msg_display_time    
    ecall             	# Print "Elapsed time: "

    li a7, 1
    sub s4, t6, t5		# Test time = End time - Start time
    li s5, 1000
    div s4, s4, s5     # Divide milliseconds by 1000 to obtain seconds
    mv a0, s4
    ecall              # Print elapsed time

    li a7, 4
    la a0, msg_display_wpm   
    ecall             	# Print "Average typing speed: "

    li t0, 60          # Multiplier for words per minute
    mul t1, s1, t0
    div a0, t1, s4     # Calculate speed (words per minute)
    li a7, 1
    ecall              # Print average typing speed in wpm

    li a7, 4
    la a0, msg_wpm
    ecall              # Print "words/minute"
    
	jal ra, display_led   # Display correct character count on 7-segment LEDS
    j continue

# Display Correct Character Count on 7-Segment LEDS
display_led:
    li t0, 10
    div t1, s0, t0         # Divide correct char count by 10 to obtain tens digit
    rem t2, s0, t0         # Remainder of s0 / 10 is the units digit

    la a0, num_arr
    add a0, a0, t1
    lb a1, 0(a0)           # Load value of tens digit
    li t0, SEVENSEG_LEFT
    sb a1, 0(t0)           # Display on left 7-segment
    
    la a0, num_arr
    add a0, a0, t2
    lb a1, 0(a0)           # Load value of units digit
    li t0, SEVENSEG_RIGHT
    sb a1, 0(t0)           # Display on right 7-segment
    
    ret

# Show confirm dialog and continue or exit
continue:
	li a7, 50
	la a0, msg_continue
	ecall
	beq a0, zero, main # If Yes(a0=0), continue to test typing speed
	
	li a7, 10 # If No(a0 = 1), end the program
	ecall