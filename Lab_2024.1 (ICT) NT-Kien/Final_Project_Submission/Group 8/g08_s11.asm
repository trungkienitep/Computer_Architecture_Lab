.data
prompt_a:       .asciz "Enter coefficient a: "   # Prompt message for coefficient a
prompt_b:       .asciz "Enter coefficient b: "   # Prompt message for coefficient b
prompt_c:       .asciz "Enter coefficient c: "   # Prompt message for coefficient c
prompt_color:   .asciz "Enter color code (hex format, e.g., 0xFF0000 for RED): "  # Prompt for color code
continue_msg:   .asciz "Do you want to draw another graph?"   # Ask if the user wants to continue
error_int:      .asciz "Invalid input! Please enter an integer.\n"   # Error message for invalid integer input
error_hex:      .asciz "Invalid color code! Please enter a valid hex color (e.g., 0x00FF0000).\n"  # Error message for invalid hex color input
buffer:         .space 10    # Buffer to store string input from user

.eqv MONITOR_SCREEN 0x10010000  # Screen base address
.eqv SCREEN_WIDTH 512           # Screen width in pixels
.eqv SCREEN_HEIGHT 512          # Screen height in pixels

# Predefined colors
.eqv RED 0xFF0000
.eqv GREEN 0x00FF00
.eqv BLUE 0x0000FF
.eqv WHITE 0xFFFFFF
.eqv YELLOW 0xFFFF00
.eqv BLACK 0x000000

.text

main:
input_a:
    # Prompt for coefficient a
    li a7, 4
    la a0, prompt_a
    ecall

    # Read input as string
    li a7, 8
    la a0, buffer
    li a1, 20
    ecall

    # Validate and convert string to integer
    jal validate_integer
    beqz a0, invalid_int_a  # If input is invalid, go to error handling
    mv s0, a1               # Store valid integer in s0
    j input_b                # Move to next coefficient input

invalid_int_a:
    # Display error for invalid integer input
    li a7, 4
    la a0, error_int
    ecall
    j input_a  # Retry input for coefficient a

input_b:
    # Prompt for coefficient b
    li a7, 4
    la a0, prompt_b
    ecall

    li a7, 8
    la a0, buffer
    li a1, 20
    ecall

    # Validate and convert string to integer
    jal validate_integer
    beqz a0, invalid_int_b
    mv s1, a1               # Store valid integer in s1
    j input_c                # Move to next coefficient input

invalid_int_b:
    # Display error for invalid integer input
    li a7, 4
    la a0, error_int
    ecall
    j input_b  # Retry input for coefficient b

input_c:
    # Prompt for coefficient c
    li a7, 4
    la a0, prompt_c
    ecall

    li a7, 8
    la a0, buffer
    li a1, 20
    ecall

    # Validate and convert string to integer
    jal validate_integer
    beqz a0, invalid_int_c
    mv s2, a1               # Store valid integer in s2
    j input_color            # Move to color input

invalid_int_c:
    # Display error for invalid integer input
    li a7, 4
    la a0, error_int
    ecall
    j input_c  # Retry input for coefficient c

input_color:
    # Prompt for color code input
    li a7, 4
    la a0, prompt_color
    ecall

    li a7, 8
    la a0, buffer
    li a1, 20
    ecall

    # Validate and convert hex color code
    jal validate_hex_color
    beqz a0, invalid_color
    mv s3, a1               # Store valid color code in s3
    j draw_axes             # Proceed to draw the graph

invalid_color:
    # Display error for invalid hex color code
    li a7, 4
    la a0, error_hex
    ecall
    j input_color           # Retry color input

# ---------------------- Validation Functions ---------------------- #

# Function to validate integer input
# Returns: a0 = 1 if valid, 0 if invalid
#          a1 = converted integer value
validate_integer:
    # Save registers
    addi sp, sp, -12
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)

    la t0, buffer
    li t1, 0       # Initialize result to 0
    li t2, 0       # Initialize sign (0 = positive, 1 = negative)
    lb t3, 0(t0)   # Load first character

    # Check if input has a negative sign
    li t4, '-'
    bne t3, t4, not_negative
    li t2, 1
    addi t0, t0, 1
    lb t3, 0(t0)

not_negative:
    # Process the digits in the string
process_digit:
    lb t3, 0(t0)
    beqz t3, end_validate_int    # End of string
    li t4, '\n'
    beq t3, t4, end_validate_int # Handle newline character

    # Check if character is a digit (0-9)
    li t4, '0'
    blt t3, t4, invalid_integer
    li t4, '9'
    bgt t3, t4, invalid_integer

    # Convert character to digit
    addi t3, t3, -48
    li t4, 10
    mul t1, t1, t4
    add t1, t1, t3
    
    addi t0, t0, 1
    j process_digit

invalid_integer:
    li a0, 0   # Invalid input, return 0
    j validate_int_exit

end_validate_int:
    # Apply sign (negative if needed)
    beqz t2, skip_negate
    neg t1, t1  # Negate if negative sign was found
skip_negate:
    li a0, 1    # Valid input
    mv a1, t1   # Store the result

validate_int_exit:
    # Restore registers
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    addi sp, sp, 12
    ret

# Function to validate hex color code
# Returns: a0 = 1 if valid, 0 if invalid
#          a1 = converted hex value
validate_hex_color:
    # Save registers
    addi sp, sp, -12
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)

    la t0, buffer
    li t1, 0       # Initialize result to 0

    # Check for "0x" prefix
    lb t2, 0(t0)
    li t3, '0'
    bne t2, t3, invalid_hex
    lb t2, 1(t0)
    li t3, 'x'
    bne t2, t3, invalid_hex
    addi t0, t0, 2

    # Process hex digits (0-9, A-F, a-f)
    li t6, 6       # Limit to 6 hex digits
process_hex:
    beqz t6, end_validate_hex  # Stop after 6 digits
    lb t2, 0(t0)
    beqz t2, invalid_hex    # String too short
    
    # Convert hex digit
    li t3, '0'
    blt t2, t3, invalid_hex
    li t3, '9'
    ble t2, t3, hex_digit_number
    
    # Check for A-F characters
    li t3, 'A'
    blt t2, t3, check_lowercase
    li t3, 'F'
    bgt t2, t3, check_lowercase
    addi t2, t2, -55        # Convert A-F to 10-15
    j hex_digit_ok

check_lowercase:
    li t3, 'a'
    blt t2, t3, invalid_hex
    li t3, 'f'
    bgt t2, t3, invalid_hex
    addi t2, t2, -87        # Convert a-f to 10-15
    j hex_digit_ok

hex_digit_number:
    addi t2, t2, -48        # Convert '0'-'9' to 0-9

hex_digit_ok:
    slli t1, t1, 4          # Shift result left by 4 bits
    or t1, t1, t2           # Combine hex digit
    addi t0, t0, 1           # Move to next character
    addi t6, t6, -1          # Decrease remaining digits count
    j process_hex

invalid_hex:
    li a0, 0   # Invalid hex, return 0
    j validate_hex_exit

end_validate_hex:
    li a0, 1    # Valid hex
    mv a1, t1   # Store hex value

validate_hex_exit:
    # Restore registers
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    addi sp, sp, 12
    ret

# ------------------------- Draw Coordinate Axes ------------------------- #
# Function to draw coordinate axes (X and Y axes on the screen)
draw_axes:
    # Draw X-axis (horizontal line at center)
    li t0, MONITOR_SCREEN     # Base address for screen memory
    li t1, SCREEN_WIDTH       # Screen width in pixels
    li t2, SCREEN_HEIGHT      # Screen height in pixels
    li t3, WHITE              # Axis color (white)

    # Calculate middle row for Y-axis
    srli t4, t2, 1           # t4 = height/2 (y=height/2 for X-axis)
    mul t4, t4, t1           # Multiply by screen width
    slli t4, t4, 2           # Multiply by 4 (bytes per pixel)
    add t4, t4, t0           # Add base address for X-axis
    
    # Draw horizontal line for X-axis
    li t5, 0                 # Initialize counter
draw_x_axis:
    sw t3, 0(t4)            # Draw pixel
    addi t4, t4, 4          # Next pixel
    addi t5, t5, 1          # Increment counter
    blt t5, t1, draw_x_axis # Continue until width is reached

    # Draw Y-axis (vertical line at center)
    li t0, MONITOR_SCREEN    # Reset base address
    srli t4, t1, 1           # t4 = width/2 for Y-axis
    slli t4, t4, 2           # Multiply by 4 (bytes per pixel)
    add t4, t4, t0           # Add to base address for Y-axis
    
    # Draw vertical line for Y-axis
    li t5, 0                # Initialize counter
    li t6, SCREEN_WIDTH     # Screen width for offset calculation
    slli t6, t6, 2          # Multiply by 4 (bytes per pixel)
draw_y_axis:
    sw t3, 0(t4)           # Draw pixel
    add t4, t4, t6         # Move down one row (screen width * 4)
    addi t5, t5, 1         # Increment counter
    blt t5, t2, draw_y_axis # Continue until height is reached

# -------------------------- Draw the Quadratic Function -------------------------- #
# Function to plot the quadratic equation y = ax² + bx + c
draw_function:
    # Parameters: s0 = a (coefficient of x²), s1 = b (coefficient of x), s2 = c (constant), s3 = color
    li t0, MONITOR_SCREEN    # Base address for screen memory
    li t1, -256             # Start x-coordinate at -256 (left side)
    li t2, 256              # End x-coordinate at 256 (right side)
    
plot_loop:
    # Calculate y = ax² + bx + c
    mul t3, t1, t1          # t3 = x²
    mul t3, t3, s0          # t3 = ax²
    mul t4, s1, t1          # t4 = bx
    add t3, t3, t4          # t3 = ax² + bx
    add t3, t3, s2          # t3 = ax² + bx + c
    
    # Convert to screen coordinates (invert Y-axis)
    neg t3, t3              # Negate y value (since screen coordinates are inverted)
    addi t3, t3, 256        # Center Y-coordinate on screen (height/2)
    
    # Ensure y is within screen bounds
    li t4, 0
    blt t3, t4, skip_point  # Skip if y < 0
    li t4, 512
    bge t3, t4, skip_point  # Skip if y >= screen height
    
    # Calculate pixel address for (x, y)
    li t4, SCREEN_WIDTH
    mul t4, t4, t3          # t4 = y * screen width
    add t4, t4, t1          # Add x to get the correct pixel position
    addi t4, t4, 256        # Center x-coordinate on screen
    slli t4, t4, 2          # Multiply by 4 (bytes per pixel)
    add t4, t4, t0          # Add base address
    
    # Draw pixel at calculated address
    sw s3, 0(t4)            # Store color at the pixel location

skip_point:
    addi t1, t1, 1          # Increment x-coordinate
    ble t1, t2, plot_loop   # Continue until all points are plotted
    
    # Prompt to ask user if they want to draw another graph
continue_prompt:
    li a7, 50
    la a0, continue_msg
    ecall
    
    beqz a0, main           # If user chooses 'yes', restart program

    # Exit program if user chooses 'no'
    li a7, 10
    ecall
