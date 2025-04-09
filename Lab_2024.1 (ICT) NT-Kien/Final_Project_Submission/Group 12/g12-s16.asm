.data
menu:      .asciz "Choose a song (1-Twinkle, 2-Happy, 3-Jingle, 4-Ode): "  # Menu for song selection
invalid:   .asciz "Invalid selection!\n"  # Error message when an invalid option is chosen
delay_value: .word 1  # Delay time for creating pauses between notes

.text
.globl main

main:
	# Display the song selection menu
	la a0, menu           # Load the address of the menu string
	li a7, 4              # Syscall: Print string
	ecall

	# Read the user input for song choice
	li a7, 5              # Syscall: Read integer
	ecall
	addi t0, a0 , 0       # Store the input value in t0

	# Check the user input and jump to the corresponding song
	li t1, 1              # T1 = 1
	beq t0, t1, music1    # If input is 1 -> Twinkle song
	
	li t1, 2              # T1 = 2
	beq t0, t1, music2    # If input is 2 -> Happy Birthday song
	
	li t1, 3              # T1 = 3
	beq t0, t1, music3    # If input is 3 -> Jingle Bells song
	
	li t1, 4              # T1 = 4
	beq t0, t1, music4    # If input is 4 -> Ode to Joy song
	
	# Display error message if the selection is invalid
	la a0, invalid        # Load the address of the error message
	li a7, 4              # Syscall: Print string
	ecall
	j main                # Return to the menu

# Song 1: Twinkle Twinkle Little Star
music1:
	li a3, 100	# a3 sets the volume: 100
	li a2, 2	# a2 sets the instrument type: piano
	li a7, 31	# Make sound syscall

	# Play the melody for Twinkle Twinkle Little Star
	# To change the melody, modify the pitch (a0) and duration (a1) for each note
	jal Do
	jal Do
	jal Sol
	jal Sol
	jal La
	jal La
	jal Sol
	jal Sleep

	jal Fa
	jal Fa
	jal Mi
	jal Mi
	jal Re
	jal Re
	jal Do
	jal Sleep
	j main  # Return to the menu

# Song 2: Happy Birthday
music2:
	li a3, 50	# a3 sets the volume: 50
	li a2, 24	# a2 sets the instrument type: guitar
	li a7, 31	# Make sound syscall

	# Play the melody for Happy Birthday
	# Modify pitch (a0) and duration (a1) for each note as needed
	jal Do
	jal Do
	jal Re
	jal Do
	jal Fa
	jal Mi
	jal Sleep

	jal Do
	jal Do
	jal Re
	jal Do
	jal Sol
	jal Fa
	jal Sleep

	jal Do
	jal Do
	jal Do
	jal La
	jal Fa
	jal Mi
	jal Re
	jal Sleep

	jal Si
	jal Si
	jal La
	jal Fa
	jal Sol
	jal Fa
	jal Sleep
	j main

# Song 3: Jingle Bells
music3:
	li a3, 70	# a3 sets the volume: 70
	li a2, 11	# a2 sets the instrument type: Chromatic Percussion
	li a7, 31	# Make sound syscall

	# Play the melody for Jingle Bells
	# Modify pitch (a0) and duration (a1) for each note as needed
	jal Mi
	jal Mi
	jal Mi
	jal Sleep
	jal Mi
	jal Mi
	jal Mi
	jal Sleep

	jal Mi
	jal Sol
	jal Do
	jal Re
	jal Mi
	jal Sleep

	jal Fa
	jal Fa
	jal Fa
	jal Fa
	jal Fa
	jal Mi
	jal Mi
	jal Sleep

	jal Mi
	jal Mi
	jal Re
	jal Re
	jal Mi
	jal Re
	jal Sol
	jal Sleep
	j main

# Song 4: Ode to Joy
music4:
	li a3, 80	# a3 sets the volume: 80
	li a2, 33	# a2 sets the instrument type: Bass
	li a7, 31	# Make sound syscall

	# Play the melody for Ode to Joy
	# Modify pitch (a0) and duration (a1) for each note as needed
	jal Mi
	jal Mi
	jal Fa
	jal Sol
	jal Sol
	jal Fa
	jal Mi
	jal Re
	jal Do
	jal Do
	jal Re
	jal Mi
	jal Mi
	jal Sleep

	jal Re
	jal Re
	jal Mi
	jal Mi
	jal Fa
	jal Sol
	jal Sol
	jal Fa
	jal Mi
	jal Mi
	jal Sleep

	jal Mi
	jal Mi
	jal Fa
	jal Sol
	jal Sol
	jal Fa
	jal Mi
	jal Re
	jal Do
	jal Do
	jal Re
	jal Mi
	jal Mi
	jal Sleep
	j main

# Sleep function for creating a delay between notes
Sleep:
	la t0, delay_value
	lw t1, 0(t0)
Delay:
	addi t1, t1, -1
	bnez t1, Delay
	jr ra

# Note functions for musical notes
Do:
	li a0, 61    # Pitch of Do
	li a1, 1000  # Duration of Do
	ecall
	jr ra

Re:
	li a0, 62    # Pitch of Re
	li a1, 1000  # Duration of Re
	ecall
	jr ra

Mi:
	li a0, 64    # Pitch of Mi
	li a1, 1000  # Duration of Mi
	ecall
	jr ra

Fa:
	li a0, 65    # Pitch of Fa
	li a1, 1000  # Duration of Fa
	ecall
	jr ra

Sol:
	li a0, 67    # Pitch of Sol
	li a1, 1000  # Duration of Sol
	ecall
	jr ra

La:
	li a0, 69    # Pitch of La
	li a1, 1000  # Duration of La
	ecall
	jr ra

Si:
	li a0, 71    # Pitch of Si
	li a1, 1000  # Duration of Si
	ecall
	jr ra

# Long note functions for extended durations
Dolong:
	li a0, 61    # Pitch of Do
	li a1, 2000  # Duration of Do (longer duration)
	ecall
	jr ra

Relong:
	li a0, 62    # Pitch of Re
	li a1, 2000  # Duration of Re (longer duration)
	ecall
	jr ra

Milong:
	li a0, 64    # Pitch of Mi
	li a1, 2000  # Duration of Mi (longer duration)
	ecall
	jr ra

Falong:
	li a0, 65    # Pitch of Fa
	li a1, 2000  # Duration of Fa (longer duration)
	ecall
	jr ra

Sollong:
	li a0, 67    # Pitch of Sol
	li a1, 2000  # Duration of Sol (longer duration)
	ecall
	jr ra

Lalong:
	li a0, 69    # Pitch of La
	li a1, 2000  # Duration of La (longer duration)
	ecall
	jr ra

Silong:
	li a0, 71    # Pitch of Si
	li a1, 2000  # Duration of Si (longer duration)
	ecall
	jr ra

# Sharp note functions for higher pitches
Dothang:
	li a0, 62    # Pitch of D#
	li a1, 1000  # Duration of D#
	ecall
	jr ra

Rethang:
	li a0, 63    # Pitch of D#
	li a1, 1000  # Duration of D#
	ecall
	jr ra

Mithang:
	li a0, 65    # Pitch of F#
	li a1, 1000  # Duration of F#
	ecall
	jr ra

Fathang:
	li a0, 66    # Pitch of F#
	li a1, 1000  # Duration of F#
	ecall
	jr ra

Solthang:
	li a0, 68    # Pitch of G#
	li a1, 1000  # Duration of G#
	ecall
	jr ra

Lathang:
	li a0, 70    # Pitch of A#
	li a1, 1000  # Duration of A#
	ecall
	jr ra

Sithang:
	li a0, 72    # Pitch of B#
	li a1, 1000  # Duration of B#
	ecall
	jr ra
