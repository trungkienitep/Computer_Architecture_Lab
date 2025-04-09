.eqv MONITOR_SCREEN 0x10040000
.eqv RED 0x00FF0000
.eqv GREEN 0x0000FF00
.eqv BLUE 0x000000FF
.eqv YELLOW 0x00FFFF00
.eqv CYAN 0x0000FFFF
.eqv MAGENTA 0x00FF00FF
.eqv WHITE 0x00FFFFFF
.eqv GRAY 0x00808080
.data
	info: .asciz "Please enter integer from 0-15 to flip the card: "
	error: .asciz "Color selected, try another number"
	finish: .asciz "Congratualation!!!, you has done the game successfully"
	Colors: .word RED, GREEN, BLUE, YELLOW, CYAN, MAGENTA, WHITE, GRAY
	Mark: .word 2, 2, 2, 2, 2, 2, 2, 2
	Temp: .word 0, 0, 0, 0, 0, 0, 0, 0
.text
	addi s0, zero, 0 # Store current assigned number
	addi s1, zero, 16 # Store the maximum number of color
	la t3, Temp # Load address of Temp
	addi s8, zero, 8
loop:
	beq s0, s1, exit
generate_random:
	li a7, 42 # System call to generate random integer
	li a1, 8  # It should be in the range 0 ~ 7
	ecall
load_color:
 	la t1, Colors # Load address of Color
 	la t2, Mark   # Load address of counter for each color
 	addi a2, zero, 4 # Value of each word in array
 	mul a2, a2, a0 # Calculate address of element from random number by a0 * 4
 	add t2, t2, a2 # Add its address to base Mark's address
 	lw a3, 0(t2) # Load the counter of this color
 	jal check_slot # Check if we have enough pair?
 	add t1, t1, a2 # Add its address to base Colors' address
 	lw a4, 0(t1) # Load color
 	sw a4, 0(t3) # Store color to Temp
 	addi t3,t3, 4 # Point Temp to the next address
 	addi a3, a3, -1 # Minus counter of this color by 1
 	sw a3, 0(t2) # Store again counter to Mark
 	addi s0, s0, 1
 	j loop
check_slot:
	beq a3, zero, generate_random # If a color have enough pair, continue random
	jr ra # If not, continue to assign color
exit:
	add s0, zero, zero # Number of pair
	addi s1, zero, 8 # Maximum pair
	addi s2, zero, 2 # Maximum try
input_loop:
	beq s3, s2, is_match # If user click 2 times, then check if match
	beq s0, s1, done # If couple = 8, done
	li t0, MONITOR_SCREEN # Load address of MONITOR
	la t3, Temp # Load random array color
	add s4, zero, a3 # Save first color
	li a7, 51
	la a0, info
	ecall
	add a5, zero, a4  # Save number of first color in Random Array
	jal retrieve # Display color to bitsmap
	j input_loop # Print message and try again
retrieve:
	add a4, zero, a0       # Save current color number in Random Array
	addi a2, zero, 4       # Store the size of each word
	mul a2, a2, a0         # Multiply to find the corresponding index
	add t0, t0, a2         # Add to the MONITOR base's address
	add t3, t3, a2         # Add to the Random Array Color base Address
	lw a6, 0(t0)           # Load current color of this address
	bnez a6, notify        # If this address already have color, next
	lw a3, 0(t3)           # Load color
	sw a3, 0(t0)           # Save to Minitor to display
	addi s3, s3, 1
	jr ra
is_match:
	xor s5, s4, a3 # Compare two color
	add s3, zero, zero # Reset s3
	beqz s5, match # If they color have the same color, then result is 0 and match
	j not_match
match:
	addi s0, s0, 1 # Increase pair by 1
	j input_loop # Continue to find and check if done
not_match:
	sw zero, 0(t0) # Because when we are in this function, MONITOR SCREEN current point to second color, so we reset
	addi a2, zero, 4
	mul a2, a2, a5 # Address of first number
	li t0, MONITOR_SCREEN # Load base address again
	add t0, t0, a2 # Index of first color
	sw zero, 0(t0) # Reset
	j input_loop
notify:
	li a7, 55
	la a0, error
	li a1, 0
	ecall
	bgt s3, zero, reset_color_for_first_input
	j input_loop
reset_color_for_first_input:
	addi a2, zero, 4
	mul a2, a2, a5
	li t0, MONITOR_SCREEN # Load Monitor address to reset color of first color
	add t0, t0, a2
	sw zero, 0(t0) # Reset color
	add s3, zero, zero # Reset s3
	j input_loop
done:
	li a7, 55
	la a0, finish
	li a1, 1
	ecall
	li a7, 10
	ecall
