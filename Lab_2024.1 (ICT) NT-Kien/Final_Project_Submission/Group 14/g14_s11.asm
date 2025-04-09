.data
prompt_a:       .asciz "Enter coefficient a: "
prompt_b:       .asciz "Enter coefficient b: "
prompt_c:       .asciz "Enter coefficient c: "
prompt_color:   .asciz "Enter color code (RED: 16711680, GREEN: 65280, BLUE: 255, WHITE: 16777215, YELLOW: 16776960): "
prompt_option:  .asciz "\nPress 1 to draw a new graph, 0 to exit: "
.eqv bitmap_addr 0x10010000
.eqv RED 0x00FF0000
.eqv GREEN 0x0000FF00
.eqv BLUE 0x000000FF
.eqv WHITE 0x00FFFFFF
.eqv YELLOW 0x00FFFF00

.text
.globl main

main:
    # Display prompt and get coefficient a
    li a7, 4
    la a0, prompt_a
    ecall

    li a7, 5
    ecall
    mv s0, a0               # Store a in s0

    # Display prompt and get coefficient b
    li a7, 4
    la a0, prompt_b
    ecall

    li a7, 5
    ecall
    mv s1, a0               # Store b in s1

    # Display prompt and get coefficient c
    li a7, 4
    la a0, prompt_c
    ecall

    li a7, 5
    ecall
    mv s2, a0               # Store c in s2

    # Display prompt and get color code
    li a7, 4
    la a0, prompt_color
    ecall

    li a7, 5
    ecall
    mv s3, a0               # Store color code in s3

# ------------------------- Draw Coordinate Axes -------------------------
draw_axes:
    # Draw the vertical axis (x = 256)
    li t0, 0                # y = 0
    li t1, 512              # Height limit for the axis
    li t4, 2048             # Width of the bitmap in pixels
    li t2, 1024             # Vertical axis is at the center (x = 256 * 4 bytes = 1024)

draw_y_axis_loop:
    li t3, bitmap_addr
    mul t5, t0, t4          # t5 = y * 2048
    add t5, t5, t2          # t5 = y * 2048 + 1024
    add t3, t3, t5          # t3 = base bitmap address + (y * width + x)

    li s8, WHITE            # Set color to WHITE
    sw s8, 0(t3)            # Draw white pixel

    addi t0, t0, 1          # Increment y
    blt t0, t1, draw_y_axis_loop

    # Draw the horizontal axis (y = 1024)
    li t0, 0                # x = 0
    li t1, 512              # Width limit for the axis
    li t2, 256              # Horizontal axis is at the center (y = 256)
    li t4, 2048             # Width of the bitmap in pixels

draw_x_axis_loop:
    li t3, bitmap_addr
    mul t5, t2, t4          # t5 = 256 * 2048
    li s7, 4                # Each pixel is 4 bytes
    mul s7, t0, s7          # s7 = 4 * x
    add t5, t5, s7          # t5 = 256 * 2048 + 4 * x
    add t3, t3, t5          # t3 = base bitmap address + (y * width + x)

    li s8, WHITE            # Set color to WHITE
    sw s8, 0(t3)            # Draw white pixel

    addi t0, t0, 1          # Increment x
    blt t0, t1, draw_x_axis_loop

# ------------------------- Draw Quadratic Function Graph -------------------------
draw_graph:
    # Set initial x range from -256 to 256
    li t0, -256
    li t1, 256
    li a1, 2048             # Bitmap width in pixels
    li a6, 513              # Offset to detect out-of-bound pixels
    li a3, 4                # 4 bytes per pixel

    # Calculate the address of (0,0) on the bitmap
    mul s5, t1, a1          # s5 = 2048 * 256
    addi s5, s5, 1024       # s5 = 2048 * 256 + 1024
    li s4, bitmap_addr
    add s5, s5, s4          # s5 points to (0,0) on the bitmap

    mul a6, a1, a6          # a6 = 2048 * 513
    add a6, a6, s4          # a6 = bitmap address + 2048 * 513 (lowest point outside the bitmap)

draw_graph_loop:
    # Compute y = a*x^2 + b*x + c
    mul t2, t0, t0          # t2 = x^2
    mul t3, s0, t2          # t3 = a * x^2
    mul t4, s1, t0          # t4 = b * x
    add t5, t3, t4          # t5 = a * x^2 + b * x
    add t5, t5, s2          # t5 = a * x^2 + b * x + c = y

    # Calculate the bitmap address for (x, y)
    li t2, 2048             # Width in pixels
    li t3, 4                # 4 bytes per pixel
    mul t2, t2, t5          # t2 = 2048 * y
    sub t2, s5, t2          # t2 = (0,0) - 2048 * y
    mul t4, t3, t0          # t4 = 4 * x
    add t2, t2, t4          # t2 = (0,0) - 2048 * y + 4 * x

    # Check if the pixel is within the bitmap boundaries
    blt t2, s4, skip_point
    bge t2, a6, skip_point

    # Set the selected color
    mv s8, s3
    sw s8, 0(t2)            # Draw the pixel

skip_point:
    addi t0, t0, 1          # Increment x
    ble t0, t1, draw_graph_loop

# Prompt the user to continue or exit
    li a7, 4
    la a0, prompt_option
    ecall

    li a7, 5
    ecall
    beq a0, zero, exit      # If input is 0, exit
    j main                  # Otherwise, restart the program

# ------------------------- Exit Program -------------------------
exit:
    li a7, 10
    ecall