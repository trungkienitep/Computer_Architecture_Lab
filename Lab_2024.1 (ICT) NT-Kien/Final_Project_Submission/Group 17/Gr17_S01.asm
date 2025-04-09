.eqv KEY_CODE 0xFFFF0004
.eqv KEY_READY 0xFFFF0000

.eqv SCREEN_MONITOR 0x10010000
.data

circle_end: .word 1
circle: .word

.text
setup:
addi s0, zero, 255 # x = 255
addi s1, zero, 255 # y = 255
add s2, zero, zero   # dx = 1
addi s3, zero, -1 # dy = 0
addi s4, zero, 20  # r = 20
addi a0, zero, 50  # t = 50ms/frame
jal circle_data
main_loop:
    jal input            # Check for key presses
    jal move_circle      # Update position based on direction
    jal draw_circle      # Draw the circle at the new position

    # Add delay (50ms per frame for smooth movement)
    li a7, 32            # ecall for sleep
    
    ecall

    j main_loop          # Repeat the loop
input:
    # Check if a key is pressed (KEY_READY == 1)
    li t0, KEY_READY   # Load the address of KEY_READY
    lw t1, 0(t0)       # Read KEY_READY value
    bne t1, zero, process_key  # If KEY_READY == 1, process the key press

    # Continue with movement and drawing if no key is pressed
    j edge_check        # Go to edge check and movement logic

process_key:
    # Read the pressed key code
    li t0, KEY_CODE     # Load the address of KEY_CODE
    lw t1, 0(t0)        # Load the ASCII key code

    # Change direction based on key press
    jal direction_change

    # Clear the key press (wait for KEY_READY to reset to 0)
    jal wait_for_key_clear

    j edge_check        # Continue with movement and edge checking

wait_for_key_clear:
    # Wait until KEY_READY becomes 0 to avoid reading the same key twice
    li t0, KEY_READY
clear_loop:
    lw t1, 0(t0)
    bne t1, zero, clear_loop  # Stay in the loop until KEY_READY == 0
    jr ra





edge_check:
li t2, 1
li t3, -1
right:
bne s2, t2, left_check
j check_right
left_check:
bne s2, t3, down_check
j check_left
down_check:
bne s3, t2, up_check
j check_down
up_check:
bne s3, t3, move_circle
j check_up

move_circle:
add s5, zero, zero
jal draw_circle
add s0, s0, s2
add s1, s1, s3
li s5, 0x00FFFF00
jal draw_circle

loop:
li a7, 32

ecall
j input

circle_data:
addi sp, sp, -4
sw ra, 0(sp)
la s5, circle
mul a3, s4, s4
add s7, zero, zero
pixel_data_loop:
bgt s7, s4, data_end
mul t0, s7, s7
sub a2, a3, t0
jal root
add a1, zero, s7
add s6, zero, zero
symmetric:
li t3, 2
beq s6, t3, finish
jal pixel_save
sub a1, zero, a1
jal pixel_save
sub a2, zero, a2 
jal pixel_save
sub a1, zero, a1
jal pixel_save
add t0, zero, a1
add a1, zero, a2
add a2, zero, t0
addi s6, s6, 1
j symmetric

finish:
addi s7, s7, 1
j pixel_data_loop
data_end:
la t0, circle_end
sw s5, 0(t0)
lw ra, 0(sp)
addi sp, sp, 4
jr ra

root:
add t0, zero, zero
add t1, zero, zero
root_loop:
li t2, 20
beq t0, t2, root_end
addi t3, t0, 1
mul t3, t3, t3
sub t4, a2, t1
bgez t4, continue
sub t4, zero, t4
continue:
sub t5, a2, t3
bgez t5, compare
sub t5, zero, t5
compare:
blt t5, t4, root_continue
add a2, zero, t0
jr ra
root_continue:
addi t0, t0, 1
add t1, zero, t3
j root_loop
root_end:
add a2, zero, t0
jr ra

pixel_save:
sw a1, 0(s5)
sw a2, 4(s5)
addi s5, s5, 8
jr ra

direction_change:
li t0, KEY_CODE
lw t1, 0(t0)
li t2, 'd'
li t3, 'a'
li t4, 's'
li t5, 'w'
li t6, 'x'   # Using t6 here
li t0, 'z'   # Fixed

case_d:
    bne t1, t2, case_a  # If not 'd', check 'a'
    li s2, 1            # dx = 1 (move right)
    li s3, 0            # dy = 0
    jr ra

case_a:
    bne t1, t3, case_s  # If not 'a', check 's'
    li s2, -1           # dx = -1 (move left)
    li s3, 0            # dy = 0
    jr ra

case_s:
    bne t1, t4, case_w  # If not 's', check 'w'
    li s2, 0            # dx = 0
    li s3, 1            # dy = 1 (move down)
    jr ra

case_w:
    bne t1, t5, case_x  # If not 'w', go to default
    li s2, 0             # dx = 0
    li s3, -1            # dy = -1 (move up)
    jr ra
case_x:
bne t1, t6, case_z
addi a0, a0, 10
jr ra
case_z:

bne t1, t0, default
beq a0, zero, default
addi a0, a0, -10
default:
jr ra



check_right:
add t0, s0, s4
li t1, 511
beq t0, t1, reverse_direction
j move_circle
check_left:
sub t0, s0, s4
beq t0, zero, reverse_direction
j move_circle
check_down:
add t0, s1, s4
li t1, 511
beq t0, t1, reverse_direction
j move_circle
check_up:
sub t0, s1, s4
blez t0, reverse_direction
j move_circle

reverse_direction:
sub s2, zero, s2
sub s3, zero, s3
j move_circle



draw_circle:
addi sp, sp, -4
sw ra, 0(sp)
la s6, circle_end
lw s7, 0(s6)
la s6, circle
draw_loop:
    beq s6, s7, draw_end    # End of circle data
    lw a1, 0(s6)            # Load x offset (a1)
    lw a2, 4(s6)            # Load y offset (a2)
    
    # Check if coordinates are within bounds
    add t1, s0, a1          # t1 = x-coordinate
    blt t1, zero, skip_pixel  # If x < 0, skip drawing
    li t2, 511
    bgt t1, t2, skip_pixel   # If x > 511, skip drawing

    add t3, s1, a2          # t3 = y-coordinate
    blt t3, zero, skip_pixel  # If y < 0, skip drawing
    li t4, 511
    bgt t3, t4, skip_pixel   # If y > 511, skip drawing

    jal pixel_draw          # Draw pixel if within bounds
skip_pixel:
    addi s6, s6, 8          # Move to next pixel data
    j draw_loop

draw_end:
lw ra, 0(sp)
addi sp, sp, 4
jr ra


pixel_draw:
li t0, SCREEN_MONITOR
add t1, s0, a1
add t2, s1, a2
slli t2, t2, 9
add t2, t2, t1
slli t2, t2, 2
add t0, t0, t2
sw s5, 0(t0)
jr ra
