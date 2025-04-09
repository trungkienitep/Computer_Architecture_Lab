# Define Key Codes
.eqv CODE_0           0x11    # Code for key '0'
.eqv CODE_1           0x21    # Code for key '1'
.eqv CODE_2           0x41    # Code for key '2'
.eqv CODE_3           0x81    # Code for key '3'
.eqv CODE_4           0x12    # Code for key '4'
.eqv CODE_5           0x22    # Code for key '5'
.eqv CODE_6           0x42    # Code for key '6'
.eqv CODE_7           0x82    # Code for key '7'
.eqv CODE_8           0x14    # Code for key '8'
.eqv CODE_9           0x24    # Code for key '9'
.eqv CODE_A           0x44    # Key 'A' - Add
.eqv CODE_B           0x84    # Key 'B' - Subtract
.eqv CODE_C           0x18    # Key 'C' - Multiply
.eqv CODE_D           0x28    # Key 'D' - Divide
.eqv CODE_E           0x48    # Key 'E' - Modulo
.eqv CODE_F           0x88    # Key 'F' - Equals

# Define Addresses for LED Display and Keyboard
.eqv SEVENSEG_LEFT    0xFFFF0011    # Address for left 7-segment LED
.eqv SEVENSEG_RIGHT   0xFFFF0010    # Address for right 7-segment LED
.eqv IN_ADDRESS_HEXA_KEYBOARD     0xFFFF0012    # Input address for keyboard
.eqv OUT_ADDRESS_HEXA_KEYBOARD    0xFFFF0014    # Output address for keyboard
.data
NUMS_OF_7SEG:    .word   0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F
str:             .asciiz "You have not entered a number! Please enter a number before performing calculations.\n"

.text
main:
    # Initialize Keyboard Addresses
    li      t1,     IN_ADDRESS_HEXA_KEYBOARD
    li      t2,     OUT_ADDRESS_HEXA_KEYBOARD

start:
    # Initialize Registers for Storage
    li      s0,     0    # s0: Store current key code
    li      s1,     0    # s1: Store current number or operator value
    li      s2,     0    # s2: Input type flag (1: number, 2: operator, 3: equals)
    li      s3,     0    # s3: Store the currently entered number
    li      s4,     0    # s4: Store the operator
    li      s5,     0    # s5: Store the calculation result
    li      s6,     0    # s6: Flag indicating if a number has been entered
    li      s7,     0    # s7: Flag indicating if an operator is pending

polling:
    # Scan Keyboard Rows
check_row_1:
    li      t3,     0x01
    sb      t3,     0(t1)                # Select row 1
    lbu     a0,     0(t2)                # Read key code
    beq     a0,     zero,    check_row_2  # If no key pressed, check next row
    bne     a0,     s0,      process_key   # If a different key is pressed, process it
    j       back_to_polling                 # Otherwise, continue polling

check_row_2:
    li      t3,     0x02
    sb      t3,     0(t1)                # Select row 2
    lbu     a0,     0(t2)                # Read key code
    beq     a0,     zero,    check_row_3  # If no key pressed, check next row
    bne     a0,     s0,      process_key   # If a different key is pressed, process it
    j       back_to_polling                 # Otherwise, continue polling

check_row_3:
    li      t3,     0x04
    sb      t3,     0(t1)                # Select row 3
    lbu     a0,     0(t2)                # Read key code
    beq     a0,     zero,    check_row_4  # If no key pressed, check next row
    bne     a0,     s0,      process_key   # If a different key is pressed, process it
    j       back_to_polling                 # Otherwise, continue polling

check_row_4:
    li      t3,     0x08
    sb      t3,     0(t1)                # Select row 4
    lbu     a0,     0(t2)                # Read key code
    beq     a0,     zero,    process_key   # If a key is pressed, process it
    bne     a0,     s0,      process_key   # If a different key is pressed, process it
    j       back_to_polling                 # Otherwise, continue polling

process_key:
    # Handle the received key
    add     s0,     zero,    a0              # Update current key code
    beq     s0,     zero,    back_to_polling  # If key code is zero, return to polling

    # Check for number keys
    li      s11,    CODE_0
    beq     s0,     s11,     process_number_0
    li      s11,    CODE_1
    beq     s0,     s11,     process_number_1
    li      s11,    CODE_2
    beq     s0,     s11,     process_number_2
    li      s11,    CODE_3
    beq     s0,     s11,     process_number_3
    li      s11,    CODE_4
    beq     s0,     s11,     process_number_4
    li      s11,    CODE_5
    beq     s0,     s11,     process_number_5
    li      s11,    CODE_6
    beq     s0,     s11,     process_number_6
    li      s11,    CODE_7
    beq     s0,     s11,     process_number_7
    li      s11,    CODE_8
    beq     s0,     s11,     process_number_8
    li      s11,    CODE_9
    beq     s0,     s11,     process_number_9

    # Check for operator keys
    li      s11,    CODE_A
    beq     s0,     s11,     process_add
    li      s11,    CODE_B
    beq     s0,     s11,     process_sub
    li      s11,    CODE_C
    beq     s0,     s11,     process_mul
    li      s11,    CODE_D
    beq     s0,     s11,     process_div
    li      s11,    CODE_E
    beq     s0,     s11,     process_mod
    li      s11,    CODE_F
    beq     s0,     s11,     process_equal

# Handle Number Keys
process_number_0:
    li      s1,     0
    li      s2,     1    # Flag indicating number input
    li      s6,     1    # Flag indicating a number has been entered
    j       after_processing

process_number_1:
    li      s1,     1
    li      s2,     1
    li      s6,     1
    j       after_processing

process_number_2:
    li      s1,     2
    li      s2,     1
    li      s6,     1
    j       after_processing

process_number_3:
    li      s1,     3
    li      s2,     1
    li      s6,     1
    j       after_processing

process_number_4:
    li      s1,     4
    li      s2,     1
    li      s6,     1
    j       after_processing

process_number_5:
    li      s1,     5
    li      s2,     1
    li      s6,     1
    j       after_processing

process_number_6:
    li      s1,     6
    li      s2,     1
    li      s6,     1
    j       after_processing

process_number_7:
    li      s1,     7
    li      s2,     1
    li      s6,     1
    j       after_processing

process_number_8:
    li      s1,     8
    li      s2,     1
    li      s6,     1
    j       after_processing

process_number_9:
    li      s1,     9
    li      s2,     1
    li      s6,     1
    j       after_processing

# Handle Operator Keys
process_add:
    li      s1,     10    # Code for addition operator
    li      s2,     2     # Flag indicating operator input
    j       after_processing

process_sub:
    li      s1,     11    # Code for subtraction operator
    li      s2,     2
    j       after_processing

process_mul:
    li      s1,     12    # Code for multiplication operator
    li      s2,     2
    j       after_processing

process_div:
    li      s1,     13    # Code for division operator
    li      s2,     2
    j       after_processing

process_mod:
    li      s1,     14    # Code for modulo operator
    li      s2,     2
    j       after_processing

process_equal:
    # Check if there is a pending operator
    beq     s7,     zero,   display_current

    # Print equal sign
    li      a0,     '='
    li      a7,     11
    ecall

    # Print space after equal sign
    li      a0,     ' '
    li      a7,     11
    ecall

    # Perform the final calculation based on the stored operator
    li      s11,    10
    beq     s4,     s11,    do_final_add
    li      s11,    11
    beq     s4,     s11,    do_final_sub
    li      s11,    12
    beq     s4,     s11,    do_final_mul
    li      s11,    13
    beq     s4,     s11,    do_final_div
    li      s11,    14
    beq     s4,     s11,    do_final_mod
    j       display_result

do_final_add:
    add     s5,     s5,     s3
    j       after_final_calc

do_final_sub:
    sub     s5,     s5,     s3
    j       after_final_calc

do_final_mul:
    mul     s5,     s5,     s3
    j       after_final_calc

do_final_div:
    beq     s3,     zero,   error_div_zero
    div     s5,     s5,     s3
    j       after_final_calc

do_final_mod:
    beq     s3,     zero,   error_div_zero
    rem     s5,     s5,     s3
    j       after_final_calc

after_final_calc:
    # Print the result
    add     a0,     zero,   s5
    li      a7,     1
    ecall

    # Print newline
    li      a0,     '\n'
    li      a7,     11
    ecall

    # Display the result on the LED
    add     a0,     zero,   s5
    jal     render

    # Reset flags
    li      s7,     0       # Clear pending operator flag
    li      s4,     15      # Indicate calculation is complete
    add     s3,     zero,   s5  # Store the result for the next calculation
    j       sleep

after_processing:
    li      s11,    1
    beq     s2,     s11,     handle_number
    li      s11,    2
    beq     s2,     s11,     handle_operator

handle_number:
    # Handle number input
    li      s11,    15
    beq     s4,     s11,     reset_calculator
    j       continue_number

reset_calculator:
    # Reset calculator for a new operation
    li      s3,     0
    li      s4,     0
    li      s5,     0

continue_number:
    # Update current number (current_number * 10 + new_number)
    li      s11,    10
    mul     s3,     s3,     s11
    add     s3,     s3,     s1

    # Get the last two digits of s3
    li      t0,     100
    rem     a3,     s3,     t0   # a3 = s3 % 100

    j       display_number

display_number:
    # Display the number
    add     a0,     zero,   s1
    li      a7,     1
    ecall
    add     a0,     zero,   a3
    jal     render
    j       sleep

handle_operator:
    # Check if a number has been entered
    beq     s6,     zero,   error_no_operand

    # If there is a pending operator, perform it first
    beq     s7,     zero,   store_for_next

    # Perform the pending operation with the previous number
    li      s11,    10
    beq     s4,     s11,    do_pending_add
    li      s11,    11
    beq     s4,     s11,    do_pending_sub
    li      s11,    12
    beq     s4,     s11,    do_pending_mul
    li      s11,    13
    beq     s4,     s11,    do_pending_div
    li      s11,    14
    beq     s4,     s11,    do_pending_mod
    j       store_for_next

do_pending_add:
    add     s5,     s5,     s3
    j       after_pending_calc

do_pending_sub:
    sub     s5,     s5,     s3
    j       after_pending_calc

do_pending_mul:
    mul     s5,     s5,     s3
    j       after_pending_calc

do_pending_div:
    beq     s3,     zero,   error_div_zero
    div     s5,     s5,     s3
    j       after_pending_calc

do_pending_mod:
    beq     s3,     zero,   error_div_zero
    rem     s5,     s5,     s3
    j       after_pending_calc

after_pending_calc:
    # Display the calculation result
    add     a0,     zero,   s5
    jal     render
    j       store_current_op

store_for_next:
    # Store the current number as the primary operand for the next operation
    add     s5,     zero,   s3

store_current_op:
    # Store the current operator and set the pending operator flag
    add     s4,     zero,   s1
    li      s7,     1
    li      s3,     0    # Reset the current number

    # Display the operator
    li      s11,    10
    beq     s1,     s11,    print_add_op
    li      s11,    11
    beq     s1,     s11,    print_sub_op
    li      s11,    12
    beq     s1,     s11,    print_mul_op
    li      s11,    13
    beq     s1,     s11,    print_div_op
    li      s11,    14
    beq     s1,     s11,    print_mod_op
    j       sleep

print_add_op:
    li      a0,     '+'
    li      a7,     11
    ecall
    j       handle_operator_end

print_sub_op:
    li      a0,     '-'
    li      a7,     11
    ecall
    j       handle_operator_end

print_mul_op:
    li      a0,     '*'
    li      a7,     11
    ecall
    j       handle_operator_end

print_div_op:
    li      a0,     '/'
    li      a7,     11
    ecall
    j       handle_operator_end

print_mod_op:
    li      a0,     '%'
    li      a7,     11
    ecall
    j       handle_operator_end

handle_operator_end:
    li      s3,     0    # Reset the current number
    j       sleep

display_current:
    # If no operator is pending, display the current number
    add     s5,     zero,   s3
    j       after_final_calc

display_result:
    # Display the final result
    add     a0,     zero,   s5
    li      a7,     1
    ecall
    j       sleep


after_calc:
    # Display the calculation result
    li      s4,     15           # Flag indicating calculation is complete
    add     s3,     zero,   s5   # Update current number with the result

    # Print equal sign and result
    li      a0,     '='
    li      a7,     11
    ecall
    add     a0,     zero,   s5
    li      a7,     1
    ecall

    # Display the result on the LED
    add     a0,     zero,   s5
    jal     render
    j       sleep

# Function: Render - Display number on 7-segment LEDs
render:
    # Save necessary registers
    addi    sp,     sp,     -24
    sw      ra,     20(sp)
    sw      s0,     16(sp)
    sw      a0,     12(sp)
    sw      a1,     8(sp)
    sw      t0,     4(sp)
    sw      t1,     0(sp)

    # Split the number into tens and units
    li      t0,     10
    mv      t1,     a0
    div     t1,     t1,     t0      # Get the tens place
    rem     a0,     a0,     t0      # Get the units place

    # Display the units place on the right LED
    li      a1,     SEVENSEG_RIGHT
    jal     ra,     show_digit

    # Display the tens place on the left LED
    rem     a0,     t1,     t0
    li      a1,     SEVENSEG_LEFT
    jal     ra,     show_digit

    # Restore saved registers
    lw      t1,     0(sp)
    lw      t0,     4(sp)
    lw      a1,     8(sp)
    lw      a0,     12(sp)
    lw      s0,     16(sp)
    lw      ra,     20(sp)
    addi    sp,     sp,     24
    jr      ra

# Function: show_digit - Display a single digit on a 7-segment LED
show_digit:
    # Save registers
    addi    sp,     sp,     -12
    sw      ra,     8(sp)
    sw      t0,     4(sp)
    sw      t1,     0(sp)

    # Get the LED segment code and display it
    la      t0,     NUMS_OF_7SEG
    slli    t1,     a0,     2       # Multiply by 4 to get the array offset
    add     t0,     t0,     t1
    lw      t0,     0(t0)
    sb      t0,     0(a1)               # Write the segment code to the LED

    # Restore registers
    lw      t1,     0(sp)
    lw      t0,     4(sp)
    lw      ra,     8(sp)
    addi    sp,     sp,     12
    jr      ra

# Error Handling
error_no_operand:
    # Display error message for missing operand
    la      a0,     str
    li      a7,     4
    ecall
    j       sleep

error_div_zero:
    # Display error message for division by zero
    li      a0,     'E'     # Display 'E' for error
    li      a7,     11
    ecall
    j       sleep

sleep:
    # Wait for 100ms to prevent continuous key presses
    li      a0,     100
    li      a7,     32
    ecall

back_to_polling:
    j       polling
