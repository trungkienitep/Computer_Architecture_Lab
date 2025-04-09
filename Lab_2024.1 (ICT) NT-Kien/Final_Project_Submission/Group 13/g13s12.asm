.data
prompt:        .asciz "Enter BMP file path: "
error_size:    .asciz "Error: Image size exceeds 512x512.\n"
error_type:    .asciz "Error: Not a BMP file.\n"
buffer:        .space   256          # Input file path buffer
fake_buffer:   .space   1100000
big_buffer:    .space   1100000      # Buffer for header + pixels
error_open:    .asciz "Error: Cannot open file. Check file path and permissions.\n"
# Screen address (depends on the environment)
.eqv MONITOR_SCREEN, 0x10010000
    .text
    .globl main
main:
    # Print prompt for file path input
    li a7, 4            # syscall print_string
    la a0, prompt
    ecall
    # Read file path from user
    li a7, 8            # syscall read_string
    la a0, buffer       # Buffer address for input
    li a1, 256          # Max size
    ecall
    # Remove newline character
    la t0, buffer
remove_newline:
    lb t1, (t0)
    beqz t1, open_file  # Jump to open_file if end of string
    li t2, 10           # Newline ASCII value
    beq t1, t2, replace_newline
    addi t0, t0, 1
    j remove_newline
replace_newline:
    sb zero, (t0)       # Replace newline with null terminator
open_file:
    # Open file in read-only mode
    li a7, 1024         # syscall open
    la a0, buffer
    li a1, 0            # read-only mode
    ecall
    mv t0, a0           # Store file descriptor
    blt t0, zero, open_file_error # Check for error if fd < 0
    
    # Read BMP header (54 bytes)
    li   t1, 54
    la   a1, big_buffer
    mv   a0, t0
    mv   a2, t1
    li   a7, 63         # syscall read
    ecall
    blt  a0, t1, error  # Check if header read is less than 54 bytes
    
    # Validate BMP file type (first 2 bytes 'B' and 'M')
    la   t2, big_buffer
    lbu  t3, 0(t2)       # Read first byte
    lbu  t4, 1(t2)       # Read second byte
    li   t5, 'B'
    bne  t3, t5, type_error
    li   t5, 'M'
    bne  t4, t5, type_error
    
    # Get image width and height from header
    addi t3, t2, 18
    lw   t4, 0(t3)       # Width
    addi t3, t2, 22
    lw   t5, 0(t3)       # Height
    
    # Check if image size exceeds 512x512
    li t6, 512           # Size limit (512)
    bgt t4, t6, size_error   # Error if width > 512
    bgt t5, t6, size_error   # Error if height > 512
    
    # Get pixel data offset from header
    addi t3, t2, 10
    lw   t6, 0(t3)       # Pixel data offset
    
    # Move to the pixel data
    mv   a0, t0
    mv   a1, t6
    li   a2, 0           # SEEK_SET
    li   a7, 62          # syscall lseek
    ecall
    blt  a0, zero, error
    
    # Calculate row size (with padding)
    li    s10, 3
    mul   s7, t4, s10     # Row size = width * 3
    
    # Calculate total pixel data size
    mul   s8, s7, t5
    
    # Read pixel data
    la   a1, big_buffer
    mv   a0, t0
    mv   a2, s8
    li   a7, 63
    ecall
    blt  a0, s8, error
    
    # Display pixel data (bottom-to-top row order)
    li a3, MONITOR_SCREEN
    mv s1, t5    # Height
    mv s2, t4    # Width
loop_rows:
    addi s1, s1, -1       # Move to previous row
    blt  s1, zero, done   # Exit loop when all rows processed
    # Get starting address of current row
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
    # Convert BGR to RGB format: 0x00RRGGBB
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
    li a7, 57   # syscall close
    ecall
    # Exit program
    li a0, 0
    li a7, 10
    ecall
open_file_error:
    # Print error if file cannot be opened
    li a7, 4
    la a0, error_open
    ecall
    j error
size_error:
    # Print error if image size exceeds 512x512
    li a7, 4
    la a0, error_size
    ecall
    j error
type_error:
    # Print error if not a BMP file
    li a7, 4
    la a0, error_type
    ecall
    j error
error:
    li a0, 0
    li a7, 10
    ecall
