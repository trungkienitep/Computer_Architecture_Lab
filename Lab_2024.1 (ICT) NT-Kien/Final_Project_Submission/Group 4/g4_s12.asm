.data
prompt:        .asciz "Enter BMP file path: "
error_size:    .asciz "Error: Image size exceeds 512x512.\n"
error_type:    .asciz "Error: Not a BMP file.\n"
buffer:        .space   256          # Buffer to hold the input file path
fake_buffer:   .space   1100000
big_buffer:    .space   1100000      # Large buffer containing header + pixels
error_open:    .asciz "Error: Cannot open file. Check file path and permissions.\n"
# Screen address (depends on the environment)
.eqv MONITOR_SCREEN, 0x10010000
    .text
    .globl main
main:
    # Step 1: Print prompt
    li a7, 4            # syscall print_string
    la a0, prompt
    ecall
    # Read file path
    li a7, 8            # syscall read_string
    la a0, buffer       # Buffer address to read the path
    li a1, 256          # Maximum size
    ecall
    # Remove newline
    la t0, buffer
remove_newline:
    lb t1, (t0)
    beqz t1, open_file  # if '\0', jump to open_file
    li t2, 10           # newline ASCII character 10
    beq t1, t2, replace_newline
    addi t0, t0, 1
    j remove_newline
replace_newline:
    sb zero, (t0)       # replace newline with '\0'
open_file:
    # Open file
    li a7, 1024         # syscall open
    la a0, buffer
    li a1, 0            # read-only
    ecall
    mv t0, a0           # t0 = fd
    blt t0, zero, open_file_error # error if t0 < 0
    
    
    # Read BMP header (54 bytes)
    li   t1, 54
    la   a1, big_buffer
    mv   a0, t0
    mv   a2, t1
    li   a7, 63         # read
    ecall
    blt  a0, t1, error  # error if read < 54 bytes
    
    # Check BMP file type (first 2 bytes are 'B' and 'M')
    la   t2, big_buffer
    lbu  t3, 0(t2)       # t3 = first byte
    lbu  t4, 1(t2)       # t4 = second byte
    li   t5, 'B'
    bne  t3, t5, type_error
    li   t5, 'M'
    bne  t4, t5, type_error
    
    
    # Get width from offset 18 (4 bytes)
    addi t3, t2, 18
    lw   t4, 0(t3)       # t4 = width
    addi t3, t2, 22
    lw   t5, 0(t3)       # t5 = height
    
    
    
    # Check image size (width > 512 || height > 512)
    li t6, 512           # limit threshold 512
    bgt t4, t6, size_error   # if width > 512, error
    bgt t5, t6, size_error   # if height > 512, error
    
    # Get pixel data offset at byte 10 (4 bytes)
    addi t3, t2, 10
    lw   t6, 0(t3)       # t6 = pixel data offset
    
    
    # Move file pointer to pixel data
    mv   a0, t0
    mv   a1, t6
    li   a2, 0           # SEEK_SET
    li   a7, 62          # lseek
    ecall
    blt  a0, zero, error
    
    
    # Calculate rowSize (padded)
    li    s10, 3
    mul   s7, t4, s10     # s7 = width * 3
    
    # Calculate pixel data size
    mul   s8, s7, t5
    
    # Read pixel data
    la   a1, big_buffer
    mv   a0, t0
    mv   a2, s8
    li   a7, 63
    ecall
    blt  a0, s8, error
    # Display pixels
    # BMP: bottom-to-top, we iterate in reverse
    li a3, MONITOR_SCREEN
    mv s1, t5    # s1 = height
    mv s2, t4    # s2 = width
loop_rows:

    addi s1, s1, -1       # s1--
    blt  s1, zero, done   # if s1 < 0, done
    # row_start = big_buffer + s1 * rowSize
    mul s9, s1, s7
    la  t3, big_buffer
    add t3, t3, s9
    mv s4, s2
    mv s5, t3
loop_cols:
    beqz s4, next_row
    lbu t1, 0(s5)   # B
    lbu t2, 1(s5)   # G
    lbu s11, 2(s5)  # R
    # BGR -> RGB: 0x00RRGGBB
    slli s11, s11, 16
    slli t2, t2, 8
    or   s11, s11, t2
    or   s11, s11, t1
    sw  s11, 0(a3)
    addi a3, a3, 4
    addi s5, s5, 3
    addi s4, s4, -1
    j loop_cols
next_row:
    j loop_rows
done:
    # Close file
    mv a0, t0
    li a7, 57   # close
    ecall
    # Exit
    li a0, 0
    li a7, 10
    ecall
open_file_error:
    # Print error: file cannot be opened
    li a7, 4
    la a0, error_open
    ecall
    j error
size_error:
    # Print error: size exceeds the limit
    li a7, 4
    la a0, error_size
    ecall
    j error
type_error:
    # Print error: not a BMP file
    li a7, 4
    la a0, error_type
    ecall
    j error
error:
    li a0, 0
    li a7, 10
    ecall

