.data
    # Existing data section
    numbers:    .space  80000 
    buf_size:   .word   80000 
    count:      .word   0
    
    # Add bitmask array for negative numbers (1 bit per number)
    # For 80000 bytes of numbers (20000 integers), we need 20000 bits = 2500 bytes
    neg_mask:   .space  2500
    
    filename:   .space  256
    readbuf:    .space  1024
    prompt:     .string "Enter filename: "
    error_msg:  .string "\nError opening file\n"
    menu:       .string "\nSelect sorting algorithm:\n1. Bubble Sort\n2. Insertion Sort\n3. Selection Sort\n4. Quick Sort\n5.Quit\nChoice: "
    
    fd:         .word   0
    newline:    .string "\n"
    space:      .string " "
    start_time: .word   0
    end_time:   .word   0
    
    time_msg:   .string "\nExecution time (ms): "
    
    # New data for output file
    outfile:    .string "C:\\Users\\Admin\\OneDrive\\BÁCH KHOA\\2024-1\\Assembly Language and Computer Architecture Lab\\CA\\FinalProject\\results3.txt"
    out_fd:     .word   0
    numbuf:     .space  12
    write_err:  .string "\nError writing to output file\n"
    minus:      .string "-"
    # Add temporary buffer for merge sort
    temp_buf:   .space  80000

.text
.globl main
main:
    # Print filename prompt
    li a7, 4
    la a0, prompt
    ecall 
    # Read filename
    li a7, 8
    la a0, filename
    li a1, 256
    ecall
    # Remove newline from filename
    la t0, filename
remove_newline:
    lb t1, 0(t0)
    beqz t1, open_file
    li t2, 10
    beq t1, t2, replace_newline
    addi t0, t0, 1
    j remove_newline
replace_newline:
    sb zero, 0(t0)
    
open_file:
    li a7, 1024
    la a0, filename
    li a1, 0
    ecall
    bltz a0, file_error
    la t1, fd
    sw a0, 0(t1)
    jal read_numbers
    
menu_loop:
    # Display menu
    li a7, 4
    la a0, menu
    ecall
    
    # Read choice
    li a7, 5
    ecall
    
    # Branch based on choice
    li t0, 1
    beq a0, t0, bubble_sort
    li t0, 2
    beq a0, t0, insertion_sort
    li t0, 3
    beq a0, t0, selection_sort
    li t0, 4
    beq a0, t0, quick_sort
    li t0,5
    beq a0, t0, exit
    j exit
file_error:
    # Print error message
    li a7, 4
    la a0, error_msg
    ecall
    j exit
read_numbers:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)
    sw s2, 0(sp)

    # Reset count
    la t1, count       # Load address of count
    sw zero, 0(t1)     # Store zero at count
    
    # Initialize variables
    li t0, 0           # Current number being built
    li t1, 0           # Flag for if we're in a number
    li t6, 0           # Sign flag (0 = positive, 1 = negative)

read_loop:
    # Read one character from file
    li a7, 63          # ReadFile syscall
    lw a0, fd          # File descriptor
    la a1, readbuf     # Buffer address
    li a2, 1           # Read one character
    ecall

    # Check if end of file
    beqz a0, read_done
    
    # Load character
    lb t2, 0(a1)
    
    # Check if minus sign
    li t3, 45          # ASCII for '-'
    bne t2, t3, not_minus
    beqz t1, set_negative   # Only set negative if at start of number
    j read_loop
    
set_negative:
    li t6, 1           # Set negative flag
    li t1, 1           # Set in-number flag
    j read_loop
    
not_minus:
    # Check if space or newline
    li t3, 32          # Space
    beq t2, t3, save_number
    li t3, 10          # Newline
    beq t2, t3, save_number
    
    # Convert ASCII to number and add to current number
    addi t2, t2, -48   # Convert ASCII to number
    li t3, 10
    mul t0, t0, t3     # Current * 10
    add t0, t0, t2     # Add new digit
    li t1, 1           # Set flag that we're in a number
    j read_loop
    
save_number:
    beqz t1, read_loop  # If not in number, continue
    
    # Apply sign if negative
    beqz t6, save_positive
    neg t0, t0         # Negate the number if negative flag is set
    
save_positive:
    # Save number to array
    la t3, count       # Load address of count
    lw t3, 0(t3)       # Load count value
    slli t4, t3, 2     # t4 = count * 4
    la t5, numbers
    add t5, t5, t4
    sw t0, 0(t5)       # Save number
    
    # Increment count
    addi t3, t3, 1
    la t4, count       # Load address of count
    sw t3, 0(t4)       # Store new count
    
    # Reset for next number
    li t0, 0           # Reset current number
    li t1, 0           # Reset in-number flag
    li t6, 0           # Reset negative flag
    j read_loop

read_done:
    # If we were in a number when file ended, save it
    beqz t1, close_file
    
    # Apply sign if negative
    beqz t6, save_last_positive
    neg t0, t0         # Negate the number if negative flag is set
    
save_last_positive:
    la t3, count       # Load address of count
    lw t3, 0(t3)       # Load count value
    slli t4, t3, 2
    la t5, numbers
    add t5, t5, t4
    sw t0, 0(t5)
    addi t3, t3, 1
    la t4, count       # Load address of count
    sw t3, 0(t4)       # Store new count

close_file:
    # Close the file
    li a7, 57          # Close file syscall
    lw a0, fd
    ecall
    
    lw ra, 12(sp)
    lw s0, 8(sp)
    lw s1, 4(sp)
    lw s2, 0(sp)
    addi sp, sp, 16
    ret
# ================================== BIT MASK=========================================
mark_negatives:
    # a0 = array address
    # a1 = size
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)
    sw s2, 0(sp)
    
    mv s0, a0          # s0 = array address
    mv s1, a1          # s1 = size
    li s2, 0           # s2 = counter
    
mark_loop:
    bge s2, s1, mark_done
    
    # Load current number
    slli t0, s2, 2     # t0 = counter * 4
    add t0, s0, t0
    lw t1, 0(t0)      # Load number
    
    # Skip if positive
    bgez t1, skip_mark
    
    # Calculate byte and bit position in bitmask
    mv t0, s2          # Copy index
    srai t1, t0, 3     # Byte offset = index / 8
    andi t2, t0, 0x7   # Bit position = index % 8
    li t3, 1
    sll t3, t3, t2     # Shift 1 to correct bit position
    
    # Set bit in bitmask
    la t4, neg_mask
    add t4, t4, t1     # Add byte offset
    lb t5, 0(t4)       # Load current byte
    or t5, t5, t3      # Set bit
    sb t5, 0(t4)       # Store updated byte
    
skip_mark:
    addi s2, s2, 1
    j mark_loop
    
mark_done:
    lw ra, 12(sp)
    lw s0, 8(sp)
    lw s1, 4(sp)
    lw s2, 0(sp)
    addi sp, sp, 16
    ret
# ======================================= SORTING ========================================
##################
# Quicksort
##################
quick_sort:
    # Get start time
    jal get_time
    sw a0, start_time, t0
    
    # Initialize quicksort
    la a0, numbers
    li a1, 0
    lw a2, count
    addi a2, a2, -1
    jal quicksort_impl
    
    # Mark negative numbers
    la a0, numbers
    lw a1, count
    jal mark_negatives
    
    # Get end time and calculate duration
    jal get_time
    sw a0, end_time, t0
    jal print_time
    
    # Write results to file
    jal write_results
    j menu_loop

quicksort_impl:
    # a0 = array address
    # a1 = left index
    # a2 = right index
    addi sp, sp, -24
    sw ra, 20(sp)
    sw s0, 16(sp)
    sw s1, 12(sp)
    sw s2, 8(sp)
    sw s3, 4(sp)
    sw s4, 0(sp)
    
    # Save arguments
    mv s0, a0         # s0 = array address
    mv s1, a1         # s1 = left
    mv s2, a2         # s2 = right
    
    # Base case: if left >= right, return
    bge s1, s2, quicksort_done
    
    # Call partition
    mv a0, s0         # array address
    mv a1, s1         # left index
    mv a2, s2         # right index
    jal partition
    mv s3, a0         # s3 = pivot index
    
    # Recursively sort left partition
    mv a0, s0         # array address
    mv a1, s1         # left index
    addi a2, s3, -1   # pivot - 1
    jal quicksort_impl
    
    # Recursively sort right partition
    mv a0, s0         # array address
    addi a1, s3, 1    # pivot + 1
    mv a2, s2         # right index
    jal quicksort_impl
    
quicksort_done:
    lw ra, 20(sp)
    lw s0, 16(sp)
    lw s1, 12(sp)
    lw s2, 8(sp)
    lw s3, 4(sp)
    lw s4, 0(sp)
    addi sp, sp, 24
    ret

partition:
    # a0 = array address
    # a1 = left index
    # a2 = right index
    # Returns: a0 = pivot index
    addi sp, sp, -24
    sw ra, 20(sp)
    sw s0, 16(sp)
    sw s1, 12(sp)
    sw s2, 8(sp)
    sw s3, 4(sp)
    sw s4, 0(sp)
    
    mv s0, a0         # s0 = array address
    mv s1, a1         # s1 = left
    mv s2, a2         # s2 = right
    
    # Choose rightmost element as pivot
    slli t0, s2, 2    # t0 = right * 4
    add t0, s0, t0
    lw s3, 0(t0)      # s3 = pivot value
    
    addi s4, s1, -1   # i = left - 1
    mv t1, s1         # j = left
    
partition_loop:
    bge t1, s2, partition_done
    
    # Load current element
    slli t0, t1, 2
    add t0, s0, t0
    lw t2, 0(t0)      # t2 = arr[j]
    
    # Compare with pivot
    bgt t2, s3, skip_swap
    
    # Increment i
    addi s4, s4, 1
    
    # Swap elements if i != j
    slli t0, s4, 2
    add t0, s0, t0    # Address of arr[i]
    slli t3, t1, 2
    add t3, s0, t3    # Address of arr[j]
    
    lw t4, 0(t0)      # t4 = arr[i]
    lw t5, 0(t3)      # t5 = arr[j]
    sw t5, 0(t0)      # arr[i] = arr[j]
    sw t4, 0(t3)      # arr[j] = arr[i]
    
skip_swap:
    addi t1, t1, 1    # j++
    j partition_loop
    
partition_done:
    # Place pivot in its final position
    addi s4, s4, 1    # i++
    
    # Swap pivot with element at i
    slli t0, s4, 2
    add t0, s0, t0    # Address of arr[i]
    slli t1, s2, 2
    add t1, s0, t1    # Address of arr[right]
    
    lw t2, 0(t0)      # t2 = arr[i]
    lw t3, 0(t1)      # t3 = arr[right]
    sw t3, 0(t0)      # arr[i] = arr[right]
    sw t2, 0(t1)      # arr[right] = arr[i]
    
    # Return pivot index
    mv a0, s4
    
    lw ra, 20(sp)
    lw s0, 16(sp)
    lw s1, 12(sp)
    lw s2, 8(sp)
    lw s3, 4(sp)
    lw s4, 0(sp)
    addi sp, sp, 24
    ret
##################
# buble_sort
##################  
bubble_sort:
    # Get start time
    jal get_time
    sw a0, start_time, t0
    
    # Implement bubble sort
    la a0, numbers     # Load array address
    lw a1, count       # Load array size
    jal bubble_sort_impl
        # Mark negative numbers
    la a0, numbers
    lw a1, count
    jal mark_negatives
    # Get end time and calculate duration
    jal get_time
    sw a0, end_time, t0
    jal print_time
    
    # Write results to file
    jal write_results
    j exit
##################
# insertion_sort:
################## 
insertion_sort:
    # Get start time
    jal get_time
    sw a0, start_time, t0
    
    # Implement insertion sort
    la a0, numbers     # Load array address
    lw a1, count       # Load array size
    jal insertion_sort_impl
        # Mark negative numbers
    la a0, numbers
    lw a1, count
    jal mark_negatives
    # Get end time and calculate duration
    jal get_time
    sw a0, end_time, t0
    jal print_time
    
    # Write results to file
    jal write_results
    j exit
##################
# selection_sort:
################## 
selection_sort:
    # Get start time
    jal get_time
    sw a0, start_time, t0
    
    # Implement selection sort
    la a0, numbers     # Load array address
    lw a1, count       # Load array size
    jal selection_sort_impl
        # Mark negative numbers
    la a0, numbers
    lw a1, count
    jal mark_negatives
    # Get end time and calculate duration
    jal get_time
    sw a0, end_time, t0
    jal print_time
    
    # Write results to file
    jal write_results
    j exit

bubble_sort_impl:
    # a0 = array address
    # a1 = size
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)
    sw s2, 0(sp)
    
    mv s0, a0          # s0 = array address
    mv s1, a1          # s1 = size
    li s2, 0           # s2 = i
    
outer_loop_bubble:
    bge s2, s1, bubble_done
    li t0, 0           # j = 0
    
inner_loop_bubble:
    sub t1, s1, s2
    addi t1, t1, -1
    bge t0, t1, inner_done_bubble
    
    # Compare adjacent elements
    slli t2, t0, 2
    add t2, s0, t2
    lw t3, 0(t2)      # arr[j]
    lw t4, 4(t2)      # arr[j+1]
    
    ble t3, t4, no_swap_bubble
    
    # Swap elements
    sw t4, 0(t2)
    sw t3, 4(t2)
    
no_swap_bubble:
    addi t0, t0, 1
    j inner_loop_bubble
    
inner_done_bubble:
    addi s2, s2, 1
    j outer_loop_bubble
    
bubble_done:
    lw ra, 12(sp)
    lw s0, 8(sp)
    lw s1, 4(sp)
    lw s2, 0(sp)
    addi sp, sp, 16
    ret

insertion_sort_impl:
    # a0 = array address
    # a1 = size
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)
    sw s2, 0(sp)
    
    mv s0, a0          # s0 = array address
    mv s1, a1          # s1 = size
    li s2, 1           # s2 = i = 1
    
outer_loop_insertion:
    bge s2, s1, insertion_done
    
    # Get current element
    slli t0, s2, 2     # t0 = i * 4
    add t0, s0, t0
    lw t1, 0(t0)      # key = arr[i]
    addi t2, s2, -1    # j = i-1
    
inner_loop_insertion:
    bltz t2, inner_done_insertion    # if j < 0, break
    
    # Compare elements
    slli t3, t2, 2
    add t3, s0, t3
    lw t4, 0(t3)      # arr[j]
    
    ble t4, t1, inner_done_insertion
    
    # Move element
    sw t4, 4(t3)      # arr[j+1] = arr[j]
    
    addi t2, t2, -1    # j--
    j inner_loop_insertion
    
inner_done_insertion:
    # Place key in correct position
    addi t2, t2, 1
    slli t3, t2, 2
    add t3, s0, t3
    sw t1, 0(t3)
    
    addi s2, s2, 1     # i++
    j outer_loop_insertion
    
insertion_done:
    lw ra, 12(sp)
    lw s0, 8(sp)
    lw s1, 4(sp)
    lw s2, 0(sp)
    addi sp, sp, 16
    ret

selection_sort_impl:
    # a0 = array address
    # a1 = size
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)
    sw s2, 0(sp)
    
    mv s0, a0          # s0 = array address
    mv s1, a1          # s1 = size
    li s2, 0           # s2 = i
    
outer_loop_selection:
    addi t0, s1, -1
    bge s2, t0, selection_done
    
    mv t1, s2          # min_idx = i
    addi t2, s2, 1     # j = i + 1
    
inner_loop_selection:
    bge t2, s1, inner_done_selection
    
    # Compare elements
    slli t3, t2, 2
    add t3, s0, t3
    lw t4, 0(t3)      # arr[j]
    
    slli t5, t1, 2
    add t5, s0, t5
    lw t6, 0(t5)      # arr[min_idx]
    
    bge t4, t6, no_update_min
    mv t1, t2          # Update min_idx
    
no_update_min:
    addi t2, t2, 1
    j inner_loop_selection
    
inner_done_selection:
    # Swap elements if needed
    beq t1, s2, no_swap_selection
    
    slli t2, s2, 2
    add t2, s0, t2
    lw t3, 0(t2)      # temp = arr[i]
    
    slli t4, t1, 2
    add t4, s0, t4
    lw t5, 0(t4)      # arr[min_idx]
    
    sw t5, 0(t2)      # arr[i] = arr[min_idx]
    sw t3, 0(t4)      # arr[min_idx] = temp
    
no_swap_selection:
    addi s2, s2, 1
    j outer_loop_selection
    
selection_done:
    lw ra, 12(sp)
    lw s0, 8(sp)
    lw s1, 4(sp)
    lw s2, 0(sp)
    addi sp, sp, 16
    ret


parse_loop:
    bge s2, s0, read_loop  # N?u ?ã parse h?t buffer, ??c ti?p
    
    # ??c ký t?
    add t0, s1, s2
    lb t1, 0(t0)
    
    # Ki?m tra xem có ph?i space không
    li t2, 32         # ASCII cho space
    beq t1, t2, next_char
    
    # Chuy?n ??i ASCII sang s?
    addi t1, t1, -48  # Convert ASCII to number
    
    # L?u s? vào m?ng numbers
    lw t3, count
    slli t4, t3, 2    # t4 = count * 4 (?? tính offset)
    la t5, numbers
    add t5, t5, t4
    sw t1, 0(t5)      # L?u s? vào m?ng
    
    # T?ng count
    addi t3, t3, 1
    sw t3, count, t6

next_char:
    addi s2, s2, 1
    j parse_loop

# ========================= PRINT ============================
get_time:
    li a7, 30         # GetTime syscall
    ecall
    ret

print_time:
    # Calculate and print duration
    la t0, start_time
    lw t1, 0(t0)
    la t0, end_time
    lw t2, 0(t0)
    sub t3, t2, t1    # Duration
    
    li a7, 4
    la a0, time_msg
    ecall
    
    li a7, 1
    mv a0, t3
    ecall
    ret

# Helper function to convert number to string
number_to_string:
    # a0 = buffer address
    # a1 = number to convert
    addi sp, sp, -24
    sw ra, 20(sp)
    sw s0, 16(sp)
    sw s1, 12(sp)
    sw s2, 8(sp)
    sw s3, 4(sp)
    sw s4, 0(sp)
    
    mv s0, a0         # Save buffer address
    mv s1, a1         # Save number
    li s2, 0          # Initialize length counter
    li s3, 0          # Flag for negative number
    
    # Handle zero case
    bnez s1, check_sign
    li t0, 48         # ASCII '0'
    sb t0, 0(s0)
    li a0, 1          # Length is 1
    j num_to_str_done
    
check_sign:
    # Check if number is negative
    bgez s1, convert_digits
    li s3, 1                   # Negative flag
    neg s1, s1                 # Make number positive
    
convert_digits:
    # Convert digits in reverse order
    mv t0, s0
digit_loop:
    beqz s1, finalize_string
    li t1, 10
    rem t2, s1, t1    # Extract last digit
    div s1, s1, t1
    addi t2, t2, 48   # Convert to ASCII
    sb t2, 0(t0)
    addi t0, t0, 1
    addi s2, s2, 1
    j digit_loop
    
finalize_string:
    # Add minus sign if negative
    beqz s3, reverse_string
    li t1, 45         # ASCII '-'
    sb t1, 0(t0)
    addi t0, t0, 1
    addi s2, s2, 1

reverse_string:
    mv a0, s0
    addi a1, t0, -1   # End of string
    jal str_reverse
    
    mv a0, s2         # Return length
    
num_to_str_done:
    lw ra, 20(sp)
    lw s0, 16(sp)
    lw s1, 12(sp)
    lw s2, 8(sp)
    lw s3, 4(sp)
    lw s4, 0(sp)
    addi sp, sp, 24
    ret

# Helper function to reverse a string in-place
str_reverse:
    # a0 = start address
    # a1 = end address
    bge a0, a1, str_rev_done
    
    # Swap characters
    lb t0, 0(a0)
    lb t1, 0(a1)
    sb t1, 0(a0)
    sb t0, 0(a1)
    
    # Move pointers
    addi a0, a0, 1
    addi a1, a1, -1
    j str_reverse
    
str_rev_done:
    ret

# ============================================
# Write results to file (updated)
# ============================================
write_results:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)
    sw s2, 0(sp)
    
    # Open results.txt for writing
    li a7, 1024       # Open file syscall
    la a0, outfile    # Filename
    li a1, 1          # Write-only flag
    li a2, 0x1ff      # File permissions (777 in octal)
    ecall
    
    # Check if file opened successfully
    bltz a0, write_error
    sw a0, out_fd, t0 # Save file descriptor
    
    # Write numbers to file
    li s0, 0          # Initialize counter
    lw s1, count      # Load total count
    la s2, numbers    # Load array address
    
write_loop:
    bge s0, s1, write_done
    
    # Load current number
    slli t0, s0, 2
    add t1, s2, t0
    lw t2, 0(t1)       # Load number
    
    # Convert number to string
    la a0, numbuf
    mv a1, t2
    jal number_to_string
    mv t3, a0          # t3 = length of the string
    
    # Write number to file
    li a7, 64          # WriteFile syscall
    lw a0, out_fd
    la a1, numbuf
    mv a2, t3          # Correct length
    ecall
    
    # Write space after number (except for last number)
    addi t0, s1, -1
    bge s0, t0, skip_space
    
    li a7, 64
    lw a0, out_fd
    la a1, space
    li a2, 1
    ecall
    
skip_space:
    addi s0, s0, 1
    j write_loop

write_done:
    # Write newline at end
    li a7, 64
    lw a0, out_fd
    la a1, newline
    li a2, 1
    ecall
    
    # Close output file
    li a7, 57         # Close file syscall
    lw a0, out_fd
    ecall
    
    lw ra, 12(sp)
    lw s0, 8(sp)
    lw s1, 4(sp)
    lw s2, 0(sp)
    addi sp, sp, 16
    ret

write_error:
    # Print error message
    li a7, 4
    la a0, write_err
    ecall
    
    lw ra, 12(sp)
    lw s0, 8(sp)
    lw s1, 4(sp)
    lw s2, 0(sp)
    addi sp, sp, 16
    ret


# ========================= WRITE ===========================


    
write_positive:
    # Load number
    slli t0, s0, 2
    add t1, s2, t0
    lw t2, 0(t1)
    
    # Get absolute value manually
    bgez t2, skip_abs
    neg t2, t2
skip_abs:
    
    la a0, numbuf
    mv a1, t2
    jal number_to_string
    
    # Write number
    li a7, 64
    lw a0, out_fd
    la a1, numbuf
    mv a2, a0         # Length returned by number_to_string
    ecall
    
    # Write space (except for last number)
    addi t0, s1, -1
    bge s0, t0, skip_space
    
    li a7, 64
    lw a0, out_fd
    la a1, space
    li a2, 1
    ecall


check_negative:
    bgez s1, positive_conversion   # If number >= 0, skip negative handling
    
    # Handle negative number
    li t0, 45         # ASCII '-'
    sb t0, 0(s0)      # Store minus sign
    addi s0, s0, 1    # Move buffer pointer
    addi s2, s2, 1    # Increment length
    neg s1, s1        # Make number positive
    
positive_conversion:
    mv t0, s0         # Current position in buffer
    mv t1, s1         # Working copy of number
   
    
reverse_digits:
    mv a0, s0         # Start of string
    add a1, s0, s2
    addi a1, a1, -1   # End of string
    
    # Add null terminator
    add t0, s0, s2
    sb zero, 0(t0)
    
    jal str_reverse
    
    mv a0, s2         # Return length


exit:
    li a7, 10         # Exit syscall
    ecall
