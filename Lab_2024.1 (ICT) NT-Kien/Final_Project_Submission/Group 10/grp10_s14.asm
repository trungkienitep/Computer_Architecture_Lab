.eqv MONITOR_SCREEN 0x10010000  # Start address of the bitmap display 
.eqv RED           0x00FF0000   # Common color values 
.eqv GREEN         0x0000FF00
.eqv BLUE          0x000000FF
.eqv WHITE         0x00FFFFFF
.eqv YELLOW        0x00FFFF00
.eqv BLACK         0xFF000000
.eqv CYAN          0xFF00FFFF
.eqv MAGENTA       0xFFFF00FF
.eqv ORANGE 0xFFFFA500

.data
	space_distance: .space 8000
	colors: .word RED, RED, GREEN, GREEN, BLUE, BLUE, WHITE, WHITE, YELLOW, YELLOW, ORANGE, ORANGE, CYAN, CYAN, MAGENTA, MAGENTA

	enter_row: .asciz "Enter row (1->4): "
	enter_column: .asciz "Enter coloumn (1->4): "
	win: .asciz "You are win!\n" 
	wrong_inp: .asciz "Wrong input. Please, try again\n"
	opened: .asciz "Opened card, try another\n"
.text

setup_monitor:
	li s11, MONITOR_SCREEN
	li a1, 16
	li a2, 0
	li a3, BLACK
	
	loop1:
		beq a2, a1, end_loop1
		
		add a4, a2, a2
		add a4, a4, a4
		add a4, s11, a4
		
		sw a3, 0(a4) 
		
		addi a2, a2, 1
		j loop1
		
	end_loop1:

shuffle:
    la t0, colors           # Load base address of the grid_colors array
    li t1, 16            # Load size of the array (16)

    li t2, 0                     # Initialize loop counter (i = 0)

shuffle_loop:
    bge t2, t1, shuffle_end      # If i >= array_size, exit loop

    # Generate random value 0 or 1
    li a7, 42                    # System call for random number
    ecall                        # Random number generated in a0
    li t3, 2                     # Set divisor (2 for 0 or 1)
    rem a0, a0, t3               # a0 = a0 % 2 (0 or 1)

    beq a0, zero, no_swap        # If random value is 0, skip the swap

    # Generate random index j
    li a7, 42                    # System call to get the random index for swapping 
    ecall
    rem a1, a0, t1               # a1 = a0 % array_size (random index j)

    # Perform the swap: colors[i] <-> colors[j]
    slli t4, t2, 2               # t4 = i * 4 (byte offset for grid_colors[i])
    add t5, t0, t4               # t5 = &grid_colors[i]
    lw t6, 0(t5)                 # t6 = grid_colors[i]

    slli s7, a1, 2               # t7 = j * 4 (byte offset for grid_colors[j])
    add s8, t0, s7               # t8 = &grid_colors[j]
    lw s9, 0(s8)                 # t9 = grid_colors[j]

    sw s9, 0(t5)                 # grid_colors[i] = grid_colors[j]
    sw t6, 0(s8)                 # grid_colors[j] = grid_colors[i]

	no_swap:
	    addi t2, t2, 1               # i++
	    j shuffle_loop

shuffle_end:
    # Go to main
	
main:
	li s11, MONITOR_SCREEN # Address of monitor 
	la s1, colors  # Address of store_colors[0]
	li a2, 16 # Size
	li a3, 0 # Point value
	
	li s10, BLACK
	
	li s9, 0 # idx1
	li a4, 0 # cnt value
	
	# We will win went score upto 16
	loop:
		beq a3, a2, end_loop
		
		la a0, enter_row
		li a7, 4
		ecall 
		
		li a7, 5
		ecall 
		
		li a7, 4
		bgt a0, a7, wrong_input
		li a7, 1
		blt a0, a7, wrong_input # Check the row input
		
		addi a5, a0, -1
		
		la a0, enter_column
		li a7, 4
		ecall
		
		li a7, 5
		ecall
		
		li a7, 4
		bgt a0, a7, wrong_input
		li a7, 1
		blt a0, a7, wrong_input # Check the row input
		
		addi a6, a0, -1
		
		# Now we have row and coloumn => find idx
		add a5, a5, a5
		add a5, a5, a5 
		add a5, a5, a6 # a5 is idx 
		
		add a7, a5, a5
		add a7, a7, a7 
		add t1, s11, a7 # Find address
		lw t0, 0(t1) # Load current color
		
		bne t0, s10, print_not_black  # Not is black enter again
		
		addi a4, a4, 1
			print:
				add t1, s1, a7 # Address of colors[i]
				lw t0, 0(t1)
				
				addi t1, a5, 0 
				jal print_color_to_monitor 
			
			delay: 
			    li a0, 250000      # Load a large loop count (adjust for your clock speed)
			
			delay_loop:
			    addi a0, a0, -1      # Decrement the counter
			    bnez a0, delay_loop  # If counter != 0, keep looping
			
						
		# If else cnt == 1, cnt == 2
			li t2, 1
			bne a4, t2, else
			if:
				# case cnt == 1 => store idx to s9
				addi s9, a5, 0
				j end_if_else
			else:
				add a7, s9, s9
				add a7, a7, a7 # find address
				add t1, s11, a7
				lw t2, 0(t1) # Load pre-color
				
				bne t2, t0, else_2
				if_check_same_color:
					addi a3, a3, 2 # Increase points
					j end_if2	
				else_2:
					sw s10, 0(t1) # Print black again
					add a7, a5, a5 
					add a7, a7, a7
					add t1, s11, a7
					sw s10, 0(t1)
			
				end_if2:
					li a4, 0
					
			end_if_else:
		
		continue_loop:
			j loop
			
		print_not_black:
			li a7, 4
			la a0, opened
			ecall
			j continue_loop
		
	end_loop: 
		j end_main
		
	print_color_to_monitor: # Get two values t0_color and t1 idx
		add t2, t1, t1
		add t2, t2, t2 # Multiply 4 * t1
		add t2, s11, t2
		sw t0, 0(t2) # Print color
		jr ra
	
	wrong_input: 
		li a7, 4
		la a0, wrong_inp
		ecall # Print wrong_inp message 
		j loop

end_main:
	la a0, win
	li a7, 4
	ecall
	
	li a7, 10
	ecall # Exit()
	