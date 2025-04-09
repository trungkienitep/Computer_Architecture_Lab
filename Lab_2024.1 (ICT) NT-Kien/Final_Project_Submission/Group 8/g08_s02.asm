.data
    sample_text:         .asciz "The quick brown fox jumps over the lazy dog"
    prompt_start:        .asciz "Press any key to start typing test:\n"
    word_count_msg:      .asciz "Number of words: "
    correct_chars_msg:   .asciz "Number of correct characters: "
    elapsed_time_msg:    .asciz "Elapsed time (seconds): "
    typing_speed_msg:    .asciz "Typing Speed (words/min): "
    retry_prompt:        .asciz "Do you want to try again?"
    newline:             .asciz "\n"
    word_count:          .word 0
    
# Memory-mapped I/O addresses
.eqv KEYBOARD_CONTROL   0xFFFF0000
.eqv KEYBOARD_DATA      0xFFFF0004
.eqv DISPLAY_CONTROL    0xFFFF0008
.eqv DISPLAY_DATA       0xFFFF000C
.eqv DISPLAY_7SEG_LEFT  0xFFFF0011
.eqv DISPLAY_7SEG_RIGHT 0xFFFF0010

# Seven-segment display patterns (0-9)
seven_seg_patterns:
    .byte 0x3F, 0x06, 0x5B, 0x4F, 0x66  # 0-4
    .byte 0x6D, 0x7D, 0x07, 0x7F, 0x6F  # 5-9

.text
.globl main

main:
retry_start:
    # Initialize variables
    li s0, 0          # s0 = correct character counter
    li s1, 0          # s1 = total characters typed
    sw zero, word_count, t0  # Reset word count
    
    # Reset seven-segment display
    jal reset_display_chars
    
    # Display start prompt
    li a7, 4
    la a0, prompt_start
    ecall
    
    # Wait for key press to start
    jal wait_for_key
    
    # Get start time
    li a7, 30
    ecall
    mv s2, a0        # s2 = start time
    
    # Initialize text pointer
    la s3, sample_text
    li s4, 0         # Previous character (for word counting)
    
typing_loop:
    # Get keyboard input
    jal get_keyboard_input
    mv s5, a0        # Save current character
    
    # Display typed character
    jal display_char
    
    # Check for Enter key (end condition)
    li t0, 10        # ASCII for newline
    beq s5, t0, end_typing_test
    
    # Compare with sample text
    lb t1, (s3)
    beq s5, t1, correct_char
    j check_word
    
correct_char:
    addi s0, s0, 1   # Increment correct characters
    jal display_correct_chars
    
check_word:
    # Check if current char is space
    li t0, 32        # ASCII for space
    bne s5, t0, next_char
    
    # Check if previous char wasn't space
    li t0, 32
    beq s4, t0, next_char
    
    # Increment word count
    lw t1, word_count
    addi t1, t1, 1
    sw t1, word_count, t0
    
next_char:
    mv s4, s5        # Save current char as previous
    addi s3, s3, 1   # Move to next sample text char
    addi s1, s1, 1   # Increment total chars
    j typing_loop

end_typing_test:
    # Check last word (if doesn't end with space)
    li t0, 32        # ASCII for space
    beq s4, t0, skip_last_word
    
    # Count last word
    lw t1, word_count
    addi t1, t1, 1
    sw t1, word_count, t0
    
skip_last_word:
    # Get end time
    li a7, 30
    ecall
    mv s3, a0        # s3 = end time
    
    # Calculate elapsed time
    sub s4, s3, s2   # s4 = elapsed time in milliseconds
    
    # Display results
    # 1. Word count
    li a7, 4
    la a0, word_count_msg
    ecall
    
    li a7, 1
    lw a0, word_count
    ecall
    
    li a7, 4
    la a0, newline
    ecall
    
    # 2. Correct characters
    li a7, 4
    la a0, correct_chars_msg
    ecall
    
    li a7, 1
    mv a0, s0
    ecall
    
    li a7, 4
    la a0, newline
    ecall
    
    # 3. Elapsed time
    li a7, 4
    la a0, elapsed_time_msg
    ecall
    
    # Convert ms to seconds
    fcvt.s.w ft0, s4         # Convert ms to float
    li t0, 1000
    fcvt.s.w ft1, t0         # Convert 1000 to float
    fdiv.s ft0, ft0, ft1     # Divide by 1000 for seconds
    
    fmv.s fa0, ft0
    li a7, 2                 # Print float
    ecall
    
    li a7, 4
    la a0, newline
    ecall
    
    # 4. Typing speed
    li a7, 4
    la a0, typing_speed_msg
    ecall
    
    # Check if elapsed time <= 1 ms
    li t0, 10              
    bgt s4, t0, calculate_typing_speed  # If elapsed time > 1 ms, go to typing speed calculation
    
    # If elapsed time <= 1 ms, typing speed is 0
    li a0, 0
    li a7, 1                 # syscall print integer
    ecall
    
    j typing_speed_done      # Jump to done after printing 0
    
calculate_typing_speed:
    # Calculate words per minute
    lw t0, word_count
    fcvt.s.w ft1, t0         # Convert word count to float
    li t0, 60
    fcvt.s.w ft2, t0         # ft2 = 60
    fmul.s ft1, ft1, ft2     # ft1 = ft1 * 60
    fdiv.s ft0, ft1, ft0     # words/minute
    
    fmv.s fa0, ft0
    li a7, 2                 # syscall print float
    ecall
    
    li a7, 4
    la a0, newline
    ecall

typing_speed_done:
    li a7, 4
    la a0, newline
    ecall
    
    # Retry prompt
    la a0, retry_prompt
    li a7, 50
    ecall
    
    beqz a0, retry_start    # If input = 0 (Yes), retry
    
    # Else, exit program
    li a7, 10
    ecall

# Helper functions
wait_for_key:
    li t0, KEYBOARD_CONTROL
wait_key_loop:
    lw t1, (t0)
    andi t1, t1, 1
    beqz t1, wait_key_loop
    ret

get_keyboard_input:
    li t0, KEYBOARD_CONTROL
    li t1, KEYBOARD_DATA
wait_input_loop:
    lw t2, (t0)
    andi t2, t2, 1
    beqz t2, wait_input_loop
    lw a0, (t1)
    ret

display_char:
    li t0, DISPLAY_CONTROL
wait_display:
    lw t1, (t0)
    andi t1, t1, 1
    beqz t1, wait_display
    li t0, DISPLAY_DATA
    sw a0, (t0)
    ret

display_correct_chars:
    # Get patterns for digits
    la t0, seven_seg_patterns
    
    # Calculate tens digit
    li t1, 10
    div t2, s0, t1       # t2 = tens
    add t3, t0, t2
    lb t4, (t3)
    
    # Display left digit
    li t5, DISPLAY_7SEG_LEFT
    sb t4, (t5)
    
    # Calculate ones digit
    rem t2, s0, t1       # t2 = ones
    add t3, t0, t2
    lb t4, (t3)
    
    # Display right digit
    li t5, DISPLAY_7SEG_RIGHT
    sb t4, (t5)
    ret

reset_display_chars:
    la t0, seven_seg_patterns
    lb t1, (t0)          # Get pattern for '0'
    
    # Reset both digits to 0
    li t2, DISPLAY_7SEG_LEFT
    sb t1, (t2)
    li t2, DISPLAY_7SEG_RIGHT
    sb t1, (t2)
    ret
