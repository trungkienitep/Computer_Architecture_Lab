.eqv SEVENSEG_LEFT 0xFFFF0011 # Address of the LED on the left
.eqv SEVENSEG_RIGHT 0xFFFF0010 # Address of the LED on the right
.eqv IN_ADDRESS_HEXA_KEYBOARD 0xFFFF0012
.eqv OUT_ADDRESS_HEXA_KEYBOARD 0xFFFF0014
.eqv TIMER_NOW 0xFFFF0018   # Memory-mapped register for the current timer value

.data
	newline: .asciz "\n"   
.text
    # Get the current time in milliseconds
	li a7, 30              # System call number for getting the time (milliseconds)
	ecall                  # Make the system call
	mv t0, a0              # Lower 32 bits of the time
	mv t1, a1              # Higher 32 bits of the time
	

      # Combine lower and higher parts into a single 64-bit value
	slli t1, t1, 32        # Shift the higher 32 bits left by 32 positions
	slli t0, t0, 32
	srli t0, t0, 32
	or t1, t1, t0          # Combine with the lower 32 bits (bitwise OR)
	
	li a7, 36
	mv a0, t0
	ecall

	# t1 will store the value of the miliseconds from 1970 till this current year 
	li s11, 31536000000	# number of miliseconds of 365 days
	li s10, 86400000		# number of miliseconds in 1 day
	li s9, 3600000		# solve for GMT + 7
	li s8, 7
	li t2, 1970			# this have to store the current year
	li t3, 0			# this store the number of seconds in this current year
	li t4, 4			# temp to get the leap year
	
	mul s9, s8, s9
	add t1, t1, s9
	
	calculate_year_loop:
		rem s9, t2, t4
		bne s9, zero, next_year_loop	# if this is not leap go to next_year_loop
		add t3, t3, s10			# else add one day
		
		next_year_loop:
			add t3, t3, s11
			bgt t3, t1, end_year_loop
			addi t2, t2, 1
			j calculate_year_loop
	end_year_loop:
	
	# After running the loop, t2 will get the current year
	sub t3, t3, s11
	sub t3, t3, s10
	
	sub t1, t1, t3
	
	li s9, 2678400000		# number of miliseconds in 31 days
	li s8, 2592000000		# number of miliseconds in 30 days
	li s7, 2505600000		# number of miliseconds in 29 days
	li s6, 2419200000		# number of miliseconds in 28 days
	rem a2, t2, t4		# a2 = 0 means leap year, normal year otherwise 
	li a4, 1			# let's chosse t4 as the current month
	
	calculate_month_loop:
		# month 1	31 days
		ble t1, s9, end_month_loop
		sub t1, t1, s9
		addi a4, a4, 1
		
		# month 2 28 - 29 days
		beq a4, zero, next_calculate_month
		ble t1, s7, end_month_loop
		sub t1, t1, s7
		addi a4, a4, 1
		j next_month_1
		
		next_calculate_month:
			ble t1, s6, end_month_loop
			sub t1, t1, s6
			addi a4, a4, 1
		next_month_1:
		
		# month 3 - 31 days
		ble t1, s9, end_month_loop
		sub t1, t1, s9
		addi a4, a4, 1
		
		# month 4 - 30 days
		ble t1, s8, end_month_loop
		sub t1, t1, s8
		addi a4, a4, 1
		
		# month 5 - 31 days
		ble t1, s9, end_month_loop
		sub t1, t1, s9
		addi a4, a4, 1
		
		# month 6 - 30 days
		ble t1, s8, end_month_loop
		sub t1, t1, s8
		addi a4, a4, 1
		
		# month 7 - 31 days
		ble t1, s9, end_month_loop
		sub t1, t1, s9
		addi a4, a4, 1
		
		# month 8 - 31 days
		ble t1, s9, end_month_loop
		sub t1, t1, s9
		addi a4, a4, 1
		
		# month 9 - 30 days
		ble t1, s8, end_month_loop
		sub t1, t1, s8
		addi a4, a4, 1
		
		# month 10 - 31 days
		ble t1, s9, end_month_loop
		sub t1, t1, s9
		addi a4, a4, 1
		
		# month 11 - 30 days
		ble t1, s8, end_month_loop
		sub t1, t1, s8
		addi a4, a4, 1
		
		# month 12 - 31 days
		ble t1, s9, end_month_loop
		sub t1, t1, s9
		addi a4, a4, 1
		
	end_month_loop:
	
	# after this, a4 will store the current month
	li a3, 1	# a3 will store the current date
	mv a2, t2	# a2 will store the current year
	
	div a3, t1, s10
	
	mul s11, a3, s10	# update t1
	sub t1, t1, s11
	
	
	addi a3, a3, 1
	mv s9, t1
	mv s8, t1
	li t6, 0
	
	############################################################
	############This will be the start for the new loop#########	
	############################################################
	
	new_loop:
		mv t1, s9		# now let's make s9 is the new value to be updated
		
		li s10, 3600000	# s10 now store the number of seconds in 1 hour
		div a5, t1, s10	# a5 stores the current hour
		
		mul s11, a5, s10
		sub t1, t1, s11	# update t1
		
		li s10, 60000
		div a6, t1, s10	# a6 stores the current minute
		
		mul s11, a6, s10
		sub t1, t1, s11
		
		li s10, 1000
		div a1, t1, s10
		
		# Afer running all that we got
		# a1: current second
		# a2: current year
		# a3: current date
		# a4: current month
		# a5: current hour
		# a6: current minute
	
		li t1, IN_ADDRESS_HEXA_KEYBOARD
		li t2, OUT_ADDRESS_HEXA_KEYBOARD
		li t3, 0x01
		li t4, 0x02
		
		sb t3, 0(t1)
		lb a0, 0(t2)
		bne a0, zero, print
	
		sb t4, 0(t1) 
		lb a0, 0(t2) 
		
		print:     
			
			li s7, 0x00000021
			bne a0, s7, cont1
			
			#########################################################
			####### this will solve the key 1 (current hour)#########
			#########################################################
			
			li s0, 10
			rem s1, a5, s0	# the first number of hour
			div s2, a5, s0	# the second number of hour
			
			# after this operations, the form we can get is s2 : s1	(s2 left LED and s1 RIGHT LED)
			
			jal display_LED
			
			j loop
			
			cont1:
			
			#########################################################
			####### this will solve the key 2 (current minute)#######
			#########################################################
			
			li s7, 0x00000041
			bne a0, s7, cont2
			
			li s0, 10
			rem s1, a6, s0
			div s2, a6, s0
			
			jal display_LED
			j loop
			
			cont2:
			
			#########################################################
			####### this will solve the key 3 (current second)#######
			#########################################################
			
			li s7, 0xffffff81
			bne a0, s7, cont3
			
			li s0, 10
			rem s1, a1, s0
			div s2, a1, s0
			
			bge s2, t6, next_ops
			
			li a7, 31
			li a0, 65
			li a1, 2000
			li a2, 6 
			li a3, 126
			ecall
				
			next_ops:
				mv t6, s2
			jal display_LED
			j loop
			
			cont3:
			
			#########################################################
			####### this will solve the key 4 (current date)#########
			#########################################################
			
			li s7, 0x00000012
			bne a0, s7, cont4
			
			li s0, 10
			rem s1, a3, s0
			div s2, a3, s0
			
			jal display_LED
			j loop
			
			cont4:
			
			#########################################################
			####### this will solve the key 5 (current month)########
			#########################################################
			
			li s7, 0x00000022
			bne a0, s7, cont5
			
			li s0, 10
			rem s1, a4, s0
			div s2, a4, s0
			
			jal display_LED
			j loop
			
			cont5:
			
			#########################################################
			####### this will solve the key 6 (current year)#########
			#########################################################
			
			li s7, 0x00000042
			bne a0, s7, loop
			
			li s0, 10
			rem s1, a2, s0
			
			div s2, a2, s0
			rem s2, s2, s0
			
			jal display_LED
			
		loop:		# this loop will update the time using timer tool
			
			li t1, 0
			li t2, 0
			
			li t0, TIMER_NOW
			lw t3, 0(t0)
			
			
			add s9, s8, t3
			
			
    		j new_loop
    		
    	end_loop:
    	# Exit the program
	li a7, 10              # Exit syscall
	ecall
	
	display_LED:		# this function will display the number based on s2 - s1
		
		#########################################################
		####### this will solve the left part (left digit)#######
		#########################################################
		
		left_part:
			
		li s3, 0
		bne s2, s3, to1
		
		#display number 0
		li a0, 0x3f
		li t0, SEVENSEG_LEFT
		sb a0, 0(t0)
		
		j right_part 
		
		to1:
		
		li s3, 1
		bne s2, s3, to2
		
		# display number 1
		li a0, 0x06	
		li t0, SEVENSEG_LEFT
		sb a0, 0(t0)
		
		j right_part 
		
		to2:
		
		li s3, 2
		bne s2, s3, to3
		
		# display number 2
		li a0, 0x5b	
		li t0, SEVENSEG_LEFT
		sb a0, 0(t0)
		
		j right_part 
		
		to3:
		
		li s3, 3
		bne s2, s3, to4
		
		# display number 3
		li a0, 0x4f	
		li t0, SEVENSEG_LEFT
		sb a0, 0(t0)
		
		j right_part 
		
		
		to4:
		
		li s3, 4
		bne s2, s3, to5
		
		# display number 4
		li a0, 0x66	
		li t0, SEVENSEG_LEFT
		sb a0, 0(t0)
		
		j right_part
		
		to5:
		
		li s3, 5
		bne s2, s3, to6
		
		# display number 5
		li a0, 0x6d
		li t0, SEVENSEG_LEFT
		sb a0, 0(t0)
		
		j right_part
		
		to6:
		
		li s3, 6
		bne s2, s3, to7
		
		# display number 6
		li a0, 0x7d
		li t0, SEVENSEG_LEFT
		sb a0, 0(t0)
		
		j right_part
		
		to7:
		
		li s3, 7
		bne s2, s3, to8
		
		# display number 7
		li a0, 0x07
		li t0, SEVENSEG_LEFT
		sb a0, 0(t0)
		
		j right_part

		to8:
		
		li s3, 8
		bne s2, s3, to9
		
		# display number 8
		li a0, 0x7f
		li t0, SEVENSEG_LEFT
		sb a0, 0(t0)
		
		j right_part
		
		to9:
		
		#display number 9
		li a0, 0x6f
		li t0, SEVENSEG_LEFT
		sb a0, 0(t0)
		
		j right_part
		
		#########################################################
		###### this will solve the right part (right digit)######
		#########################################################
		
		right_part:
		
		li s3, 0
		bne s1, s3, right_to1
		
		#display number 0
		li a0, 0x3f
		li t0, SEVENSEG_RIGHT
		sb a0, 0(t0)
		
		j end_part 
		
		right_to1:
		
		li s3, 1
		bne s1, s3, right_to2
		
		# display number 1
		li a0, 0x06	
		li t0, SEVENSEG_RIGHT
		sb a0, 0(t0)
		
		j end_part 
		
		right_to2:
		
		li s3, 2
		bne s1, s3, right_to3
		
		# display number 2
		li a0, 0x5b	
		li t0, SEVENSEG_RIGHT
		sb a0, 0(t0)
		
		j end_part 
		
		right_to3:
		
		li s3, 3
		bne s1, s3, right_to4
		
		# display number 3
		li a0, 0x4f	
		li t0, SEVENSEG_RIGHT
		sb a0, 0(t0)
		
		j end_part 
		
		
		right_to4:
		
		li s3, 4
		bne s1, s3, right_to5
		
		# display number 4
		li a0, 0x66	
		li t0, SEVENSEG_RIGHT
		sb a0, 0(t0)
		
		j end_part
		
		right_to5:
		
		li s3, 5
		bne s1, s3, right_to6
		
		# display number 5
		li a0, 0x6d
		li t0, SEVENSEG_RIGHT
		sb a0, 0(t0)
		
		j end_part
		
		right_to6:
		
		li s3, 6
		bne s1, s3, right_to7
		
		# display number 6
		li a0, 0x7d
		li t0, SEVENSEG_RIGHT
		sb a0, 0(t0)
		
		j end_part
		
		right_to7:
		
		li s3, 7
		bne s1, s3, right_to8
		
		# display number 7
		li a0, 0x07
		li t0, SEVENSEG_RIGHT
		sb a0, 0(t0)
		
		j end_part

		right_to8:
		
		li s3, 8
		bne s1, s3, right_to9
		
		# display number 8
		li a0, 0x7f
		li t0, SEVENSEG_RIGHT
		sb a0, 0(t0)
		
		j end_part
		
		right_to9:
		
		#display number 9
		li a0, 0x6f
		li t0, SEVENSEG_RIGHT
		sb a0, 0(t0)

		end_part:
		
		jr ra
