# Define LED and Keyboard Addresses
.eqv SEVENSEG_LEFT    0xFFFF0011    # Left 7-segment LED address
.eqv SEVENSEG_RIGHT   0xFFFF0010    # Right 7-segment LED address
.eqv IN_ADDRESS_HEXA_KEYBOARD     0xFFFF0012    # Keyboard input address
.eqv OUT_ADDRESS_HEXA_KEYBOARD    0xFFFF0014    # Keyboard output address

# Key Code Definitions
.eqv CODE_0           0x11    # Code for number 0
.eqv CODE_1           0x21    # Code for number 1
.eqv CODE_2           0x41    # Code for number 2
.eqv CODE_3           0x81    # Code for number 3
.eqv CODE_4           0x12    # Code for number 4
.eqv CODE_5           0x22    # Code for number 5
.eqv CODE_6           0x42    # Code for number 6
.eqv CODE_7           0x82    # Code for number 7
.eqv CODE_8           0x14    # Code for number 8
.eqv CODE_9           0x24    # Code for number 9
.eqv CODE_ADD          0x44    # Key 'a' - Addition
.eqv CODE_SUB           0x84    # Key 'b' - Subtraction
.eqv CODE_MUL           0x18    # Key 'c' - Multiplication
.eqv CODE_DIV           0x28    # Key 'd' - Division
.eqv CODE_MOD           0x48    # Key 'e' - Modulo
.eqv CODE_EQUAL           0x88    # Key 'f' - Equals

.data
VALUE_7SEGMENT:    .word   0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F
message1:             .asciz "You haven't entered a number! Please enter a number before performing calculation.\n"
message2:             .asciz "ERROR FOR DIVISION ZERO\n"


.text
main:
    # Initialize keyboard address
    li      t1,     IN_ADDRESS_HEXA_KEYBOARD
    li      t2,     OUT_ADDRESS_HEXA_KEYBOARD

start:
    # Initialize storage registers
    li      s0,     0    # s0: Store current key code
    li      s1,     0    # s1: Store number or operator
    li      s2,     0    # s2: Input type flag (1: number, 2: operator, 3: equals)
    li      s3,     0    # s3: Current number being entered
    li      s4,     0    # s4: Store operator
    li      s5,     0    # s5: Store temporary result
    li      s6,     0    # s6: Flag to mark number input
    li      s7,     0    # s7: Flag to mark pending operation

polling:
    # Scan keyboard rows
check_row_1:
    li      t3,     0x01
    sb      t3,     0(t1)
    lbu     a0,     0(t2)
    beq     a0,     zero,    check_row_2
    bne     a0,     s0,      process_key
    j       back_to_polling

check_row_2:
    li      t3,     0x02
    sb      t3,     0(t1)
    lbu     a0,     0(t2)
    beq     a0,     zero,    check_row_3
    bne     a0,     s0,      process_key
    j       back_to_polling

check_row_3:
    li      t3,     0x04
    sb      t3,     0(t1)
    lbu     a0,     0(t2)
    beq     a0,     zero,    check_row_4
    bne     a0,     s0,      process_key
    j       back_to_polling

check_row_4:
    li      t3,     0x08
    sb      t3,     0(t1)
    lbu     a0,     0(t2)
    beq     a0,     zero,    process_key
    bne     a0,     s0,      process_key
    j       back_to_polling

# Number process functions
process_key:
    add     s0,     zero,    a0
    beq     s0,     zero,    back_to_polling
    
  
    li      s11,    CODE_0
    beq     s0,     s11,     process_0
    li      s11,    CODE_1
    beq     s0,     s11,     process_1
    li      s11,    CODE_2
    beq     s0,     s11,     process_2
    li      s11,    CODE_3
    beq     s0,     s11,     process_3
    li      s11,    CODE_4
    beq     s0,     s11,     process_4
    li      s11,    CODE_5
    beq     s0,     s11,     process_5
    li      s11,    CODE_6
    beq     s0,     s11,     process_6
    li      s11,    CODE_7
    beq     s0,     s11,     process_7
    li      s11,    CODE_8
    beq     s0,     s11,     process_8
    li      s11,    CODE_9
    beq     s0,     s11,     process_9
    
    # Operator process functions
    li      s11,    CODE_ADD
    beq     s0,     s11,     process_add
    li      s11,    CODE_SUB
    beq     s0,     s11,     process_sub
    li      s11,    CODE_MUL
    beq     s0,     s11,     process_mul
    li      s11,    CODE_DIV
    beq     s0,     s11,     process_div
    li      s11,    CODE_MOD
    beq     s0,     s11,     process_mod
    li      s11,    CODE_EQUAL
    beq     s0,     s11,     process_equal


# Number process functions
process_0:
    li      s1,     0
    li      s2,     1    # Mark as number input
    li      s6,     1    # Mark number input flag
    j       after_process

process_1:
    li      s1,     1
    li      s2,     1
    li      s6,     1
    j       after_process

process_2:
    li      s1,     2
    li      s2,     1
    li      s6,     1
    j       after_process

process_3:
    li      s1,     3
    li      s2,     1
    li      s6,     1
    j       after_process

process_4:
    li      s1,     4
    li      s2,     1
    li      s6,     1
    j       after_process

process_5:
    li      s1,     5
    li      s2,     1
    li      s6,     1
    j       after_process

process_6:
    li      s1,     6
    li      s2,     1
    li      s6,     1
    j       after_process

process_7:
    li      s1,     7
    li      s2,     1
    li      s6,     1
    j       after_process

process_8:
    li      s1,     8
    li      s2,     1
    li      s6,     1
    j       after_process

process_9:
    li      s1,     9
    li      s2,     1
    li      s6,     1
    j       after_process

# Operator process functions
process_add:
    li      s1,     10    # Code for addition
    li      s2,     2     # Mark as operator input
    j       after_process
    
process_sub:
    li      s1,     11    # Code for sub
    li      s2,     2
    j       after_process

process_mul:
    li      s1,     12    # Code for mul
    li      s2,     2
    j       after_process

process_div:
    li      s1,     13    # Code for div
    li      s2,     2
    j       after_process

process_mod:
    li      s1,     14    # Code for mod
    li      s2,     2
    j       after_process

process_equal:
    # Check if there's a pending operation
    beq     s7,     zero,   display_current
    
    # Print equals sign
    li      a0,     '='
    li      a7,     11
    ecall
    
    # Print space
    li      a0,     ' '
    li      a7,     11
    ecall
    
    # Perform final calculation based on stored operator
    li      s11,    10
    beq     s4,     s11,    final_add
    li      s11,    11
    beq     s4,     s11,    final_sub
    li      s11,    12
    beq     s4,     s11,    final_mul
    li      s11,    13
    beq     s4,     s11,    final_div
    li      s11,    14
    beq     s4,     s11,    final_mod
    j       display_result
final_add:
    add     s5,     s5,     s3
    j       after_final_calc

final_sub:
    sub     s5,     s5,     s3
    j       after_final_calc

final_mul:
    mul     s5,     s5,     s3
    j       after_final_calc

final_div:
    beq     s3,     zero,   error_div_zero
    div     s5,     s5,     s3
    j       after_final_calc

final_mod:
    beq     s3,     zero,   error_div_zero
    rem     s5,     s5,     s3
    j       after_final_calc

after_final_calc:
    # Print result
    add     a0,     zero,   s5
    li      a7,     1
    ecall
    
    # Newline
    li      a0,     '\n'
    li      a7,     11
    ecall
    
    # Display result on LED
    add     a0,     zero,   s5
    jal     display7Seg
    
    # Reset flags
    li      s7,     0       # Clear pending operation flag
    li      s4,     15      # Mark calculation complete
    add     s3,     zero,   s5  # Save result for next calculation
    j       sleep
    
   
after_process:
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
    # Reset calculator for new computation
    li      s3,     0
    li      s4,     0
    li      s5,     0

continue_number:
    # Compute new number (previous * 10 + new digit)
    li      s11,    10
    mul     s3,     s3,     s11
    add     s3,     s3,     s1
    
    # Take two last digit
    li      t0,     100
    rem     a3,     s3,     t0   # a3 = s3 % 100

    j       display_number


display_number:
    # Display number
    add     a0,     zero,   s1
    li      a7,     1
    ecall
    add     a0,     zero,   s3
    jal     display7Seg
    j       sleep

handle_operator:
    # Check if an operand is entered
    beq     s6,     zero,   error_no_operand
    
    # If pending operation exists, compute it first
    beq     s7,     zero,   store_for_next
    
    # Perform pending operation
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
    # Display temporary result
    add     a0,     zero,   s5
    jal     display7Seg
    j       store_current_op

store_for_next:
    # Store first operand for next operation
    add     s5,     zero,   s3

store_current_op:
    # Store current operator and mark as pending
    add     s4,     zero,   s1
    li      s7,     1
    li      s3,     0  # Reset current number
    
    # Display operator
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
    li      s3,     0    # Reset current number
    j       sleep

display_current:
    # If there is no pending operation, display the current number
    add     s5,     zero,   s3
    j       after_final_calc

display_result:
    # Display the final result
    add     a0,     zero,   s5
    li      a7,     1
    ecall
    j       sleep


after_calc:
    # Display the result
    li      s4,     15           # Mark as calculation complete
    add     s3,     zero,   s5   # Update current number to result
    
    # Print equal sign and result
    li      a0,     '='
    li      a7,     11
    ecall
    add     a0,     zero,   s5
    li      a7,     1
    ecall
    
    # Display the result on the LED
    add     a0,     zero,   s5
    jal     display7Seg
    j       sleep

# Display function - display number on 7-segment LED
display7Seg:
display7Seg_store:
    addi    sp, sp, -24              # Expand the stack
    sw      ra, 20(sp)               # Save the return address
    sw      s0, 16(sp)               # Save the value of register s0
    sw      a0, 12(sp)               # Save the value of parameter a0 (integer to display)
    sw      a1, 8(sp)                # Save the value of parameter a1 (7-segment LED address)
    sw      t0, 4(sp)                # Save the value of register t0
    sw      t1, 0(sp)                # Save the value of register t1

display7Seg_do:
    li      t0, 10                   # Load the value 10 into register t0
    mv      t1, a0                   # Copy the value of parameter a0 into register t1
    rem     a0, a0, t0               # Get the remainder of a0 divided by 10 (units digit)
    li      a1, SEVENSEG_RIGHT       # Set the address of the right 7-segment LED into a1
    jal     ra, show_digit           # Call the function show_digit to display the digit

    div     t1, t1, t0               # Get the integer division of t1 by 10
    rem     a0, t1, t0               # Get the remainder of t1 divided by 10 (tens digit)
    li      a1, SEVENSEG_LEFT        # Set the address of the left 7-segment LED into a1
    jal     ra, show_digit           # Call the function show_digit to display the digit

display7Seg_load:
    lw      t1, 0(sp)                # Load the value of register t1 from the stack
    lw      t0, 4(sp)                # Load the value of register t0 from the stack
    lw      a1, 8(sp)                # Load the value of parameter a1 from the stack
    lw      a0, 12(sp)               # Load the value of parameter a0 from the stack
    lw      s0, 16(sp)               # Load the value of register s0 from the stack
    lw      ra, 20(sp)               # Load the return address from the stack
    addi    sp, sp, 24               # Shrink the stack
    jr      ra                       # Return to the caller

# Show_digit function - display a single digit on the 7-segment LED
show_digit:
    # Save registers
    addi    sp,     sp,     -12
    sw      ra,     8(sp)
    sw      t0,     4(sp)
    sw      t1,     0(sp)

    # Fetch corresponding LED code and display
    la      t0,     VALUE_7SEGMENT
    slli    t1,     a0,     2       # Multiply by 4 for offset
    add     t0,     t0,     t1
    lw      t0,     0(t0)
    sb      t0,     0(a1)

    # Restore registers
    lw      t1,     0(sp)
    lw      t0,     4(sp)
    lw      ra,     8(sp)
    addi    sp,     sp,     12
    jr      ra

# Error handling
error_no_operand:
    # Display error for missing number input
    la      a0,     message1
    li      a7,     4
    ecall
    j       sleep

error_div_zero:
    # Display error for division by zero
    la      a0,     message2 # Display for error
    li      a7,     4
    ecall
    j       sleep

sleep:
    # Pause for 100ms to avoid key bounce
    li      a0,     500
    li      a7,     32
    ecall

back_to_polling:
    j       polling
