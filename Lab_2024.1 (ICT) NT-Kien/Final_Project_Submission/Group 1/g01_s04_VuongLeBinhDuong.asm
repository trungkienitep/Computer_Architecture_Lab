.data
    # String messages
    ValueChar:   .asciz "\nChar Pointer Value: " 
    ValueByte:   .asciz "\nByte Pointer Value: " 
    ValueWord:   .asciz "\nWord Pointer Value: " 
    Value2DWord: .asciz "\n2D Word Pointer Value: "
    AddressChar: .asciz "Char Pointer Address: "
    AddressByte: .asciz "Byte Pointer Address: "
    AddressWord: .asciz "Word Pointer Address: "
    Address2DWord: .asciz "2D Word Pointer Address: "
    
    enteri: .asciz "Enter i: "
    enterj: .asciz "Enter j: "
    
    mainmenu: .asciz "\n----- Menu -----"
    newline:   .asciz "\n"
    entersize: .asciz "Enter number of index: "
    enterelements: .asciz "Enter value: "
    message1:   .asciz "\n1. Char\n"
    message2:   .asciz "2. Byte\n"
    message3:   .asciz "3. Word\n"
    message4: .asciz "4. 2D Word\n"
    message5: .asciz "5. Display value and address of pointers. \n"
    message6: .asciz "6. Free memory allocated. \n"
    message7: .asciz "7. Calculate memory allocated. \n"
    message8: .asciz "8. Copy char pointer. \n"
    message9: .asciz "9. Exit. \n"
    errormessage: .asciz "Unvalid input, please enter value from 1 to 9.\n"
    prompt:   .asciz "Choose an option: "
    notinitialize: .asciz "\nNot Initialize.\n"
    memory: .asciz "Number of bytes(memory) allocated: "
    return: .asciz "4. Return.\n"
    
    message4.1: .asciz "\n1. Get a[i][j]. \n"
    message4.2: .asciz "2. Set a[i][j]. \n"
    message4.3: .asciz "3. Return.\n"
    message4.4: .asciz "Value: "
    message4.5: .asciz "The value has been update. \n"
    
    message8.1: .asciz "Cannot copy! \n"
    message8.2: .asciz "Copy finish. \n" 
    # Pointer variables
    CharPtr:   .word  0 # Character pointer
    BytePtr:   .word  0 # Byte pointer
    WordPtr:   .word  0 # Word pointer
    TwoDWordPtr: .word 0
    # System memory management variables
    Sys_TheTopOfFree: .word 0
    Sys_MyFreeSpace:  .space 10000  # Allocate more space for dynamic memory

    CopyPtr: .word 0
    
.text

main:
    # Initialize memory management
    call SysInitMem 

menu:
    # Print menu options
    li      a7, 4
    la      a0, mainmenu
    ecall
    li      a7, 4
    la      a0, message1
    ecall
    la      a0, message2
    ecall
    la      a0, message3
    ecall
    la      a0, message4
    ecall
    la      a0, message5
    ecall
    la      a0, message6
    ecall
    la      a0, message7
    ecall
    la      a0, message8
    ecall
    la      a0, message9
    ecall
    la      a0, prompt
    ecall

    # Read user choice
    li      a7, 5
    ecall

case_1:
    li t1, 1
    bne a0, t1, case_2
    
    #enter size and elements
    li a7, 4
    la a0, entersize
    ecall
    
    li a7, 5
    ecall
    
    mv a1, a0
    mv s6, a0
    

    # Allocate memory and input data
    la a0, CharPtr
    li a2, 1    # Size of each element: 1 byte
    jal malloc
    call NhapDulieuChar
    jal DisplayAddressValueChar
    
    j menu
    
case_2:
    li t1, 2
    bne a0, t1, case_3
    
    #enter size and elements
    li a7, 4
    la a0, entersize
    ecall
    
    li a7, 5
    ecall
    
    mv a1, a0
    
    la a0, BytePtr
    li a2, 1
    jal malloc
    call NhapDulieuByte
    jal DisplayAddressValueByte
    
    j menu
    
case_3:
    li t1, 3
    bne a0, t1, case_4
    
    mv a6, a0
    #enter size and elements
    li a7, 4
    la a0, entersize
    ecall
    
    li a7, 5
    ecall
    
    mv a1, a0
    
    la a0, WordPtr
    li a2, 4
    jal malloc
    call NhapDulieuWord
    jal DisplayAddressValueWord
    
    j menu
    
case_4:
    li t1, 4
    bne a0, t1, case_5
    
    la a0, TwoDWordPtr
    lw t1 0(a0)
    
    bne t1, zero, sub_menu
    
    li a7, 4
    la a0, newline
    ecall
    
    li a7, 4
    la a0, enteri
    ecall
    
    li a7, 5
    ecall
    mv a1, a0
    
    li a7, 4
    la a0, enterj
    ecall
    
    li a7, 5
    ecall
    mv a2, a0
         
    la a0, TwoDWordPtr
    jal malloc2
    mv t0, a0     # Base address of the array stored in t0
    
    mv a0, t0        # Load base address to a0
    li t0, 0
    la t2, TwoDWordPtr   # Initialize t0
    lw t2, 0(t2)
    mv t1, a1       # Store the number of rows in t1
    mul a1, a1, a2     # Calculate total number of elements
    
input_loop2:
    beq t0, a1, input_end2 # If t0 == total elements, end input loop
    
    li a7, 4
    la a0, enterelements 
    ecall
    
    li a7, 5      # Read input value
    ecall
    sw a0, 0(t2)    # Store the value in memory
    addi t2, t2, 4     # Move to the next memory address
    addi t0, t0, 1    # Increment the counter
    j input_loop2     # Jump back to input_loop2

input_end2:
    mv a1, t1    # Restore the original value of rows

    
sub_menu:
    li a7, 4       # Print string
    la a0, message4.1
    ecall
    la a0, message4.2
    ecall
    la a0, message4.3
    ecall
    la a0, prompt
    ecall
    li a7, 5      # Read integer
    ecall
    
sub_case_1:
    li t1, 1
    bne a0, t1, sub_case_2  # If input != 1, jump to sub_case_2
    li a7, 4            # Print string
    la a0, enteri
    ecall
    li a7, 5       # Read integer
    ecall
    mv s0, a0    # Store value in s0
    li a7, 4       # Print string
    la a0, enterj
    ecall
    li a7, 5     # Read integer
    ecall
    mv s1, a0   # Store value in s1
    la t0, TwoDWordPtr
    lw a0, 0(t0)     # Load array pointer
    jal ra, getArray        # Call getArray
    mv s2, a0    # Store returned value in s2
    li a7, 4       # Print string
    la a0, message4.4
    ecall
    li a7, 1     # Print integer
    mv a0, s2
    ecall
    j sub_menu     # Go back to sub_menu

sub_case_2:
    li t1, 2
    bne a0, t1, sub_case_3  # If input != 2, jump to sub_case_3
    li a7, 4       # Print string
    la a0, enteri
    ecall
    li a7, 5     # Read integer
    ecall
    mv s0, a0      # Store value in s0
    li a7, 4       # Print string
    la a0, enterj
    ecall
    li a7, 5     # Read integer
    ecall
    mv s1, a0    # Store value in s1
    li a7, 4        # Print string
    la a0, message4.4
    ecall
    li a7, 5      # Read integer
    ecall
    mv s2, a0       # Copy value to s2
    la t0, TwoDWordPtr
    lw a0, 0(t0)      # Load array pointer
    jal setArray        # Call setArray
    
    li a7, 4
    la a0, newline
    ecall
    
    j sub_menu      # Go back to sub_menu

sub_case_3:
    li t1, 3
    bne a0, t1, error    # If input != 3, jump to error
    j menu        # Go back to menu

case_5:
    li t1, 5
    bne a0, t1, case_6
       
    jal DisplayAddressValueChar
    jal DisplayAddressValueByte
    jal DisplayAddressValueWord
    jal DisplayAddressValueTwoDWord
    
    j menu
    
case_6:
    li t1, 6
    bne  a0, t1, case_7
    
    call Free

    j menu
    
case_7:
    li t1, 7
    bne a0, t1, case_8
    
    li a7, 4
    la a0, memory
    ecall
    
    call MemoryCalculated
    
    li a7, 1
    ecall
    
    li a7, 4
    la a0, newline
    ecall
    
    j menu

case_8:
    li t1, 8
    bne a0, t1, case_9   
    
    #enter size and elements
    li a7, 4
    la a0, entersize
    ecall
    
    li a7, 5
    ecall
    
    mv a1, a0
    
    blt s6, a1, copy_error
    
    li s3, 0
    la t1, CopyPtr      

CopyChar_Loop:
    li a7, 4
    la a0, enterelements  # Print message
    ecall
    li a7, 12   # Syscall to read a char
    ecall
    sb a0, 0(t1)   # Store the input char
    addi t1, t1, 1   # Move to next byte
    addi s3, s3, 1
    
    li a7, 4
    la a0, newline
    ecall
    
    bne s3, a1, CopyChar_Loop
    
    jal strcpy
    
    li a7, 4
    la a0, message8.2
    ecall
    
    j menu

copy_error:
    li a7, 4
    la a0, message8.1
    ecall
    
    j menu

case_9:
    li  t1, 9
    bne  a0, t1, error

    li a7, 10
    ecall
    
error:
    li a7, 4
    la a0, errormessage
    ecall
    j menu
    
# Initialize memory management system
SysInitMem:
    la t0, Sys_TheTopOfFree
    la t1, Sys_MyFreeSpace
    sw t1, (t0)
    ret

# Dynamic memory allocation
malloc:
    la t0, Sys_TheTopOfFree
    lw t1, 0(t0)    # Load current free memory pointer
    li a5, 3
    bne a6, a5, initialize 
    andi t3, t1, 0x03
    beq t3, zero, initialize
    addi t1, t1, 4
    sub t1, t1, t3    
initialize:
    sw t1, (a0)    # Store allocated address
    mv a0, t1     # Return allocated address

    mul t2, a1, a2   # Calculate total size
    add t3, t1, t2  # Update free memory pointer
    sw t3, (t0)
    jr ra
    
# Input data for CharPtr
NhapDulieuChar:
    li s3, 0
    la t1, CharPtr      # Load address of CharPtr
    lw t1, (t1)  # Load allocated memory address

NhapDulieuChar_Loop:
    li a7, 4
    la a0, enterelements  # Print message
    ecall
    li a7, 12      # Syscall to read a char
    ecall
    sb a0, 0(t1)   # Store the input char
    addi t1, t1, 1      # Move to next byte
    addi s3, s3, 1
    
    li a7, 4
    la a0, newline
    ecall
    
    bne s3, a1, NhapDulieuChar_Loop
    ret

# Input data for BytePtr
NhapDulieuByte:
    li s3, 0
    la t1, BytePtr     # Load address of BytePtr
    lw t1, (t1)

NhapDulieuByte_Loop:
    li a7, 4
    la a0, enterelements
    ecall
    li a7, 5       # Syscall to read integer (1 byte)
    ecall
    sb a0, 0(t1)
    addi t1, t1, 1    # Move to next byte
    addi s3, s3, 1
    bne s3, a1, NhapDulieuByte_Loop
    ret

# Input data for WordPtr
NhapDulieuWord:
    li s3, 0
    la t1, WordPtr    # Load address of WordPtr
    lw t1, (t1)

NhapDulieuWord_Loop:
    li a7, 4
    la a0, enterelements
    ecall
    li a7, 5      # Syscall to read integer
    ecall
    sw a0, 0(t1)     # Store the input word
    addi t1, t1, 4    # Move to next word
    addi s3, s3, 1
    bne s3, a1, NhapDulieuWord_Loop
    ret
    
DisplayAddressValueChar:
# Display CharPtr value and address
    la   a0, CharPtr
    lw   t1, 0(a0)       # Load the pointer address
    beq t1, zero, NotInitialize
    lb   t2, 0(t1)     # Load the value pointed by CharPtr

    # Print CharPtr value label
    li   a7, 4
    la   a0, ValueChar
    ecall
    # Print CharPtr value
    li   a7, 11     # Print a character
    mv   a0, t2
    ecall
    # Print newline
    li   a7, 4
    la   a0, newline
    ecall

    # Print CharPtr address label
    li   a7, 4
    la   a0, AddressChar
    ecall
    # Print CharPtr address
    li   a7, 34
    mv   a0, t1
    ecall
    # Print newline
    li   a7, 4
    la   a0, newline
    ecall
    
    jr ra
    
DisplayAddressValueByte:
# Display BytePtr value and address
    la   a0, BytePtr
    lw   t1, (a0)     # Load the pointer address
    beq t1, zero, NotInitialize
    lb   t2, 0(t1)   # Load the value pointed by BytePtr

    # Print BytePtr value label
    li   a7, 4
    la   a0, ValueByte
    ecall
    # Print BytePtr value
    li   a7, 1
    mv   a0, t2
    ecall
    # Print newline
    li   a7, 4
    la   a0, newline
    ecall

    # Print BytePtr address label
    li   a7, 4
    la   a0, AddressByte
    ecall
    # Print BytePtr address
    li   a7, 34
    mv   a0, t1
    ecall
    # Print newline
    li   a7, 4
    la   a0, newline
    ecall
    
    jr ra
    
DisplayAddressValueWord:
# Display WordPtr value and address
    la   a0, WordPtr
    lw   t1, 0(a0)      # Load the pointer address
    beq t1, zero, NotInitialize
    lw   t2, 0(t1)     # Load the value pointed by WordPtr

    # Print WordPtr value label
    li   a7, 4
    la   a0, ValueWord
    ecall
    # Print WordPtr value
    li   a7, 1
    mv   a0, t2
    ecall
    # Print newline
    li   a7, 4
    la   a0, newline
    ecall

    # Print WordPtr address label
    li   a7, 4
    la   a0, AddressWord
    ecall
    # Print WordPtr address
    li   a7, 34
    mv   a0, t1
    ecall
    # Print newline
    li   a7, 4
    la   a0, newline
    ecall
    jr ra

DisplayAddressValueTwoDWord:
    la a0, TwoDWordPtr
    lw t1, 0(a0)
    beq t1, zero, NotInitialize
    lw t2, 0(t1)
    
    # Print WordPtr value label
    li   a7, 4
    la   a0, Value2DWord
    ecall
    # Print WordPtr value
    li   a7, 1
    mv   a0, t2
    ecall
    # Print newline
    li   a7, 4
    la   a0, newline
    ecall

    # Print WordPtr address label
    li   a7, 4
    la   a0, Address2DWord
    ecall
    # Print WordPtr address
    li   a7, 34
    mv   a0, t1
    ecall
    # Print newline
    li   a7, 4
    la   a0, newline
    ecall
    jr ra

NotInitialize:
    li a7, 4
    la a0, notinitialize
    ecall
    
    jr ra

MemoryCalculated:
    la t0, Sys_MyFreeSpace
    la t1, Sys_TheTopOfFree
    lw t2, 0(t1)
    sub a0, t2, t0
    ret

Free:
    la   t0, Sys_TheTopOfFree      # Load address of Sys_TheTopOfFree
    lw   t1, 0(t0)       # Load the current top of free memory address
    
    # Load the beginning of the allocated space
    la   t2, Sys_MyFreeSpace     # This is where the allocated space starts
    
    # If Sys_TheTopOfFree is equal to or less than the start, nothing to clean
    blt  t1, t2, Free_End

    sw t2, 0(t0)

    # Reset the CharPtr to zero
    la   t0, CharPtr       # Load address of CharPtr
    sw   zero, 0(t0)    # Set CharPtr to zero

    # Reset the BytePtr to zero
    la   t0, BytePtr      # Load address of BytePtr
    sw   zero, 0(t0)      # Set BytePtr to zero

    # Reset the WordPtr to zero
    la   t0, WordPtr       # Load address of WordPtr
    sw   zero, 0(t0)     # Set WordPtr to zero
    
    la t0, TwoDWordPtr
    sw zero, 0(t0)

Free_Backwards_Loop:
    sb   zero, 0(t1)    # Set the current memory location to zero
    addi t1, t1, -1     # Move the pointer back by one word (4 bytes)
    bge  t1, t2, Free_Backwards_Loop  # Continue loop if still within allocated range

Free_End:
    ret    # Return from function

malloc2:
    addi sp, sp, -12     # Save necessary registers on stack
    sw ra, 8(sp)      # Save return address
    sw a1, 4(sp)     # Save a1
    sw a2, 0(sp)    # Save a2
    
    mul a1, a1, a2       # a1 = number of elements (rows * cols)
    li a2, 4         # a2 = size of one element (word = 4 bytes)
    jal malloc        # Call malloc to allocate memory
    
    lw ra, 8(sp)    # Restore return address
    lw a1, 4(sp)      # Restore a1
    lw a2, 0(sp)      # Restore a2
    addi sp, sp, 12     # Restore stack pointer
    ret     # Return
getArray:
    mul t0, s0, a2      # Element position = i * cols
    add t0, t0, s1     # Add j to get the final position
    slli t0, t0, 2     # Multiply by 4 (word size) to get the byte offset
    add t0, t0, a0   # Add base address to get the actual address
    lw a0, 0(t0)     # Load the value of the element
    ret        # Return
setArray:
    mul t0, s0, a2    # Element position = i * cols
    add t0, t0, s1   # Add j to get the final position
    slli t0, t0, 2      # Multiply by 4 (word size) to get the byte offset
    add t0, t0, a0     # Add base address to get the actual address
    sw s2, 0(t0)     # Store the value into the element
    ret     # Return

strcpy:
    li a5, 1
    la t0, CharPtr
    la t1, CopyPtr
    lw t0, (t0)
copy_loop:
    lb t4, 0(t1)
    sb t4, 0(t0)
    
    beq a5, s6 done
    
    addi a5, a5, 1
    addi t1, t1, 1    # Move to the next byte in B
    addi t0, t0, 1   # Move to the next byte in A
    
    j copy_loop    # Repeat the loop

done:
    # The copy is complete, and program ends here
    jr ra
