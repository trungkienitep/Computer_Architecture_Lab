.eqv IN_ADDRESS_HEXA_KEYBOARD  0xFFFF0012     # Input address for the keyboard (memory-mapped I/O)
.eqv OUT_ADDRESS_HEXA_KEYBOARD 0xFFFF0014     # Output address for the keyboard (memory-mapped I/O)

.data

# Key mappings for selecting songs (1-4) or pausing (0)
key_map:
    .word 0x21, song1_data      # Key 1 -> song1
    .word 0x41, song2_data      # Key 2 -> song2
    .word 0x81, song3_data      # Key 3 -> song3
    .word 0x12, song4_data      # Key 4 -> song4
    .word 0x11, pause_song      # Key 0 -> pause music
    .word 0                     # End of key map

# Song data for each song script: [Pitch, Duration, Instrument Type, Volume]
song1_data:
    .word 60, 500, 5, 100
    .word 60, 500, 5, 100
    .word 62, 500, 5, 100
    .word 64, 500, 5, 100
    .word 65, 500, 5, 100
    .word 67, 500, 5, 100
    .word 69, 500, 5, 100
    .word 71, 500, 5, 100
    .word 72, 500, 5, 100
    .word 74, 500, 5, 100
    .word 76, 500, 5, 100
    .word 77, 500, 5, 100
    .word 79, 500, 5, 100
    .word 81, 500, 5, 100
    .word 83, 500, 5, 100
    .word 84, 500, 5, 100
    .word 72, 500, 5, 100
    .word 71, 500, 5, 100
    .word 69, 500, 5, 100
    .word 67, 500, 5, 100
    .word 65, 500, 5, 100
    .word 64, 500, 5, 100
    .word 62, 500, 5, 100
    .word 60, 500, 5, 100
    .word 0, 0, 0, 0           # End of song data

song2_data:
    .word 64, 500, 0, 100
    .word 64, 500, 0, 100
    .word 66, 1000, 0, 100
    .word 64, 1000, 0, 100
    .word 69, 1000, 0, 100
    .word 68, 2000, 0, 100
    .word 64, 500, 0, 100
    .word 64, 500, 0, 100
    .word 66, 1000, 0, 100
    .word 64, 1000, 0, 100
    .word 71, 1000, 0, 100
    .word 69, 2000, 0, 100
    .word 64, 500, 0, 100
    .word 64, 500, 0, 100
    .word 76, 1000, 0, 100
    .word 72, 1000, 0, 100
    .word 69, 1000, 0, 100
    .word 68, 1000, 0, 100
    .word 66, 1000, 0, 100
    .word 74, 500, 0, 100
    .word 74, 500, 0, 100
    .word 72, 1000, 0, 100
    .word 69, 1000, 0, 100
    .word 71, 1000, 0, 100
    .word 69, 2000, 0, 100
    .word 0, 0, 0, 0           # End of song data

song3_data:
    .word 60, 500, 7, 100
    .word 60, 500, 7, 100
    .word 62, 500, 7, 100
    .word 64, 500, 7, 100
    .word 65, 500, 7, 100
    .word 64, 500, 7, 100
    .word 62, 500, 7, 100
    .word 60, 500, 7, 100
    .word 60, 500, 7, 100
    .word 60, 500, 7, 100
    .word 62, 500, 7, 100
    .word 64, 500, 7, 100
    .word 65, 500, 7, 100
    .word 64, 500, 7, 100
    .word 62, 500, 7, 100
    .word 60, 500, 7, 100
    .word 60, 500, 7, 100
    .word 62, 500, 7, 100
    .word 64, 500, 7, 100
    .word 65, 500, 7, 100
    .word 64, 500, 7, 100
    .word 62, 500, 7, 100
    .word 60, 500, 7, 100
    .word 0, 0, 0, 0           # End of song data

song4_data:
    .word 60, 500, 4, 100
    .word 60, 500, 4, 100
    .word 67, 500, 4, 100
    .word 67, 500, 4, 100
    .word 69, 500, 4, 100
    .word 67, 500, 4, 100
    .word 65, 500, 4, 100
    .word 65, 500, 4, 100
    .word 64, 500, 4, 100
    .word 64, 500, 4, 100
    .word 62, 500, 4, 100
    .word 60, 500, 4, 100
    .word 67, 500, 4, 100
    .word 67, 500, 4, 100
    .word 65, 500, 4, 100
    .word 65, 500, 4, 100
    .word 64, 500, 4, 100
    .word 64, 500, 4, 100
    .word 62, 500, 4, 100
    .word 60, 500, 4, 100
    .word 0, 0, 0, 0           # End of song data

# Pause song label (no music data, just halts playback)
pause_song:

error_msg: .asciz "Phim khong hop le\n"          # Error message for invalid key press
paused_msg: .asciz "Music Paused\n"               # Message when music is paused

.text
.globl main
main:
    li s1, IN_ADDRESS_HEXA_KEYBOARD  # Load input address for the keyboard
    li s2, OUT_ADDRESS_HEXA_KEYBOARD # Load output address for the keyboard
    li t3, 0x01                      # Set initial bit for key press checking

polling:
    sb t3, 0(s1)                     # Write the polling bit to the input address
    lbu a0, 0(s2)                    # Load the current key press (byte) from the keyboard

    beqz a0, next_row                # If no key is pressed, skip to next row

    li t1, 17                        # Define key code for "0" (pause key)
    beq a0, t1, pause_music          # If the key pressed is "0", pause music

    mv a0, a0                        # Store key value in a0 for further processing
    call find_song                   # Call function to find corresponding song
    beqz a0, show_invalid_key        # If no song found, show an error message
    call play_song                   # Call function to play the selected song

    li a0, 500                       # Short delay after each iteration
    li a7, 32
    ecall

next_row:
    slli t3, t3, 1                   # Shift bit to check the next key
    li t4, 0x10                      # Check if all keys have been polled
    bne t3, t4, continue_polling     # If not all keys checked, continue polling
    li t3, 0x01                      # Reset polling bit to check from the start

continue_polling:
    j polling                        # Jump back to polling loop

show_invalid_key:
    li a7, 4
    la a0, error_msg                # Load error message for invalid key
    ecall
    j polling                        # Continue polling for next input

pause_music:
    li a7, 33                        # System call to pause the music
    ecall
    li a7, 4
    la a0, paused_msg               # Load "Music Paused" message
    ecall
    j polling                        # Return to polling for new input

# Function to find which song corresponds to the pressed key
find_song:
    la t0, key_map                  # Load the address of the key_map
find_song_loop:
    lw t1, 0(t0)                    # Load the key value from the key map
    beqz t1, not_found              # If no match found, return
    bne a0, t1, next_entry          # If key doesn't match, go to next entry
    lw a0, 4(t0)                    # If match, load the corresponding song data
    ret

next_entry:
    addi t0, t0, 8                  # Move to next key in the map
    j find_song_loop

not_found:
    li a0, 0                        # Return 0 if no song found
    ret

# Function to play the selected song
play_song:
    mv t0, a0                        # Load song data address
play_song_loop:
    lbu t1, 0(s2)                    # Check if the key is still pressed (if not, stop)
    li t2, 0x00
    beq t1, t2, return               # If no key is pressed, exit

    lw t1, 0(t0)                     # Get the pitch of the current note
    beqz t1, return                  # If pitch is 0, end of song

    lw a0, 0(t0)                     # Load pitch
    lw a1, 4(t0)                     # Load duration
    lw a2, 8(t0)                     # Load instrument type
    lw a3, 12(t0)                    # Load volume

    li a7, 31                        # System call to play sound
    ecall

    addi t0, t0, 16                  # Move to the next note in the song
    j play_song_loop                 # Continue playing the next note

return:
    ret
