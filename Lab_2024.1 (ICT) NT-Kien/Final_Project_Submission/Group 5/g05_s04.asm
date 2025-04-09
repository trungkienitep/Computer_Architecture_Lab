    .data

# Pointer variables
    CharPtr:
    .word     0
    BytePtr:
    .word     0
    WordPtr:
    .word     0
    Array2dPtr:
    .word     0

    CharCount:
    .word     0
    ByteCount:
    .word     0
    WordCount:
    .word     0

    Sys_TheTopOfFree:
    .word     1
    Sys_MyFreeSpace:
    .space    1024

# Messages
    space:
    .asciz    "  "
    prompt_array_not_allocated:
    .asciz    "array not allocated\n"
    all_assigned:
    .asciz    "All elements assigned.\n"
    prompt_array_menu:
    .asciz    "Choose which array to assign values:\n1. Char Array\n2. Byte Array\n3. Word Array\n"
    enter_char_msg:
    .asciz    "Enter a character: "
    enter_int_msg:
    .asciz    "Enter an integer: "
    freeMem:
    .asciz    "Memory freed\n"
    message_char:
    .asciz    "Enter the number of characters : "
    message_byte:
    .asciz    "Enter the number of characters for the byte array : "
    message_word:
    .asciz    "Enter the number of words : "
    message_success:
    .asciz    "Memory allocated. The starting address is: "
    message_lessthan1:
    .asciz    "Number of elements cannot be less than 1 \n"
    endl:
    .asciz    "\n"
    address_str:
    .asciz    "\nAddress of CharPtr, BytePtr, WordPtr, 2dArrayPtr are: \n"
    value_str:
    .asciz    "\nValues stored in arrays:\n"
    da_cap_phat:
    .asciz    "Allocated bytes: "
    message_row:
    .asciz    "\nEnter the number of rows: "
    message_col:
    .asciz    "\nEnter the number of columns: "
    row:
    .word     1
    col:
    .word     1
    input_row:
    .asciz    "\nEnter row i (first row i=0): "
    input_col:
    .asciz    "\nEnter column j (first column j=0): "
    input_val:
    .asciz    "\nEnter value for 2d array element : "
    output_val:
    .asciz    "\nReturn value : "
    bound_error:
    .asciz    "\nError: Segmentation fault. Index out of bounds.\n"
    arrMes1:
    .asciz    "A["
    arrMes2:
    .asciz    "] = "
    arrMin:
    .asciz    "Min element in the array: "
    cpyMess:
    .asciz    "Copied from CharPtr to BytePtr.\n"
    no_space_msg:
    .asciz    "no space left to copy\n"

# Messages for Task5
    char_array_values_msg:
    .asciz    "Char array values: "
    char_not_allocated_msg:
    .asciz    "Char array not allocated\n"
    char_no_elements_msg:
    .asciz    "Char array has no elements\n"

    second_char_array_values_msg:
    .asciz    "Byte array values: "
    second_char_not_allocated_msg:
    .asciz    "Byte array not allocated\n"
    second_char_no_elements_msg:
    .asciz    "Byte array has no elements\n"

    word_array_values_msg:
    .asciz    "Word array values: "
    word_not_allocated_msg:
    .asciz    "Word array not allocated\n"
    word_no_elements_msg:
    .asciz    "Word array has no elements\n"

# Menu options
    menu:
    .asciz    "\n1. Allocate Char.\n2. Allocate Byte.\n3. Allocate word.\n4. Assign values to an array.\n5. Display array values.\n6. Display array addresses.\n7. Free allocated memory.\n8. Check allocated memory.\n9. Allocate a 2D word array.\n10. Set Array[i][j].\n11. Get Array[i][j].\n12. Copy data from CharPtr to BytePtr.\n0. Exit the program"

    .text
    jal       SysInitMem

    .global   main
    main:
    print_menu:
    la        a0, menu
    jal       take_the_int
    mv        s0,a0

    li        t0,1
    beq       s0,t0,task1
    li        t0,2
    beq       s0,t0,task2
    li        t0,3
    beq       s0,t0,task3
    li        t0,4
    beq       s0,t0,task4
    li        t0,5
    beq       s0,t0,task5
    li        t0,6
    beq       s0,t0,task6
    li        t0,7
    beq       s0,t0,task7
    li        t0,8
    beq       s0,t0,task8
    li        t0,9
    beq       s0,t0,task9
    li        t0,10
    beq       s0,t0,task10
    li        t0,11
    beq       s0,t0,task11
    li        t0,12
    beq       s0,t0,task12
    li        t0,0
    beq       s0,t0,terminated

# task1: allocate char array
    task1:
    la        a0, message_char
    jal       take_the_int
    sltiu     s10,a0,1 #check if input < 1 ? a10 = 0 mean input is >= 1
    beq       s10,zero,done_check_char
    la        a0,message_lessthan1
    li        a7,4
    ecall
    jal       main

    done_check_char:
    mv        a1,a0                    # no +1 for null terminator
    la        a0,CharPtr
    li        a2,1
    jal       malloc
    mv        s0,a0
    la        t0,CharCount
    sw        a1,0(t0)

    la        a0, message_success
    li        a7,4
    ecall
    mv        a0,s0
    li        a7,34
    ecall
    la        a0,endl
    li        a7,4
    ecall
    jal       main

# task2: allocate byte array
    task2:
    la        a0, message_byte
    jal       take_the_int
    sltiu     s10,a0,1 #check if input < 1 ? a10 = 0 mean input is >= 1
    beq       s10,zero,done_check_Byte
    la        a0,message_lessthan1
    li        a7,4
    ecall
    jal       main

    done_check_Byte:
    mv        a1,a0                    # no +1 for null terminator
    la        a0,BytePtr
    li        a2,1
    jal       malloc
    mv        s0,a0
    la        t0, ByteCount
    sw        a1, 0(t0)

    la        a0, message_success
    li        a7,4
    ecall
    mv        a0,s0
    li        a7,34
    ecall
    la        a0,endl
    li        a7,4
    ecall
    jal       main

# task3: allocate word array
    task3:
    la        a0,message_word
    jal       take_the_int
    sltiu     s10,a0,1 #check if input < 1 ? a10 = 0 mean input is >= 1
    beq       s10,zero,done_check_Word
    la        a0,message_lessthan1
    li        a7,4
    ecall
    jal       main

    done_check_Word:
    mv        a1,a0
    la        a0,WordPtr
    li        a2,4
    jal       malloc
    mv        s0,a0
    la        t0, WordCount
    sw        a1, 0(t0)

    la        a0,message_success
    li        a7,4
    ecall
    mv        a0,s0
    li        a7,34
    ecall
    la        a0,endl
    li        a7,4
    ecall
    jal       main

# task4: Assign values to an array (char/byte/word)
    task4:
    li        a7,4
    la        a0, endl
    ecall

    li        a7,4
    la        a0, prompt_array_menu
    ecall

    li        a7,5
    ecall
    mv        t3,a0

    li        t1,1
    beq       t3,t1,assign_char
    li        t1,2
    beq       t3,t1,assign_byte
    li        t1,3
    beq       t3,t1,assign_word

    jal       main

    assign_char:
    la        t0,CharPtr
    lw        t0,0(t0)
    beq       t0,zero,no_alloc
    la        t1,CharCount
    lw        t1,0(t1)
    j         start_assign

    assign_byte:
    la        t0,BytePtr
    lw        t0,0(t0)
    beq       t0,zero,no_alloc
    la        t1,ByteCount
    lw        t1,0(t1)
    j         start_assign

    assign_word:
    la        t0,WordPtr
    lw        t0,0(t0)
    beq       t0,zero,no_alloc
    la        t1,WordCount
    lw        t1,0(t1)
    j         start_assign

    no_alloc:
    li        a7,4
    la        a0, prompt_array_not_allocated
    ecall
    jal       main

    start_assign:
    li        t6,1                     # default: char arrays
    li        t5,3
    beq       t3,t5,set_word_size
# If not word, keep t6=1 for char/byte arrays
    j         assign_loop

    set_word_size:
    li        t6,4                     # word array

    assign_loop:
    li        t4,0

    assign_loop_start:
    beq       t4,t1,assign_done

    li        t5,4
    beq       t6,t5,is_word

# char/byte arrays read char
    li        a7,4
    la        a0, enter_char_msg
    ecall
    li        a7,12
    ecall
    mv        s1,a0
    add       t2,t0,t4
    sb        s1,0(t2)
    j         next_element

    is_word:
# word array read int
    li        a7,4
    la        a0,enter_int_msg
    ecall
    li        a7,5
    ecall
    mv        s1,a0
    slli      t2,t4,2
    add       t2,t2,t0
    sw        s1,0(t2)

    next_element:
    addi      t4,t4,1
    j         assign_loop_start

    assign_done:
# No null terminator logic, just done
    li        a7,4
    la        a0, all_assigned
    ecall
    jal       main

# task5: Display array values
    task5:
    la        a0, value_str
    li        a7,4
    ecall

# Print Char array
    la        t0,CharCount
    lw        t2,0(t0)
    la        t0,CharPtr
    lw        t0,0(t0)
    beq       t0,zero,char_not_alloc
    beq       t2,zero,char_no_elem
    li        a7,4
    la        a0,char_array_values_msg
    ecall
    li        t3,0
    char_loop:
    beq       t3,t2,char_done
    add       t4,t0,t3
    lb        a0,0(t4)
    li        a7,11                    # print char
    ecall
    li        a7,4
    la        a0,space
    ecall
    addi      t3,t3,1
    j         char_loop

    char_done:
    li        a7,4
    la        a0,endl
    ecall
    j         char_skip

    char_not_alloc:
    li        a7,4
    la        a0,char_not_allocated_msg
    ecall
    j         char_skip

    char_no_elem:
    li        a7,4
    la        a0,char_no_elements_msg
    ecall

    char_skip:

# Print Byte array (second char array)
    la        t0,ByteCount
    lw        t2,0(t0)
    la        t0,BytePtr
    lw        t0,0(t0)
    beq       t0,zero,second_char_not_alloc
    beq       t2,zero,second_char_no_elem
    li        a7,4
    la        a0,second_char_array_values_msg
    ecall
    li        t3,0
    byte_loop:
    beq       t3,t2,byte_done
    add       t4,t0,t3
    lb        a0,0(t4)
    li        a7,11                    # print char
    ecall
    li        a7,4
    la        a0,space
    ecall
    addi      t3,t3,1
    j         byte_loop

    byte_done:
    li        a7,4
    la        a0,endl
    ecall
    j         byte_skip

    second_char_not_alloc:
    li        a7,4
    la        a0,second_char_not_allocated_msg
    ecall
    j         byte_skip

    second_char_no_elem:
    li        a7,4
    la        a0,second_char_no_elements_msg
    ecall

    byte_skip:

# Print Word array
    la        t0,WordCount
    lw        t2,0(t0)
    la        t0,WordPtr
    lw        t0,0(t0)
    beq       t0,zero,word_not_alloc
    beq       t2,zero,word_no_elem
    li        a7,4
    la        a0,word_array_values_msg
    ecall
    li        t3,0
    word_loop:
    beq       t3,t2,word_done
    slli      t4,t3,2
    add       t4,t4,t0
    lw        a0,0(t4)
    li        a7,1                     # print int
    ecall
    li        a7,4
    la        a0,space
    ecall
    addi      t3,t3,1
    j         word_loop

    word_done:
    li        a7,4
    la        a0,endl
    ecall
    j         word_skip

    word_not_alloc:
    li        a7,4
    la        a0,word_not_allocated_msg
    ecall
    j         word_skip

    word_no_elem:
    li        a7,4
    la        a0,word_no_elements_msg
    ecall

    word_skip:
    jal       main

# task6: Display array addresses
    task6:
    la        a0, address_str
    li        a7,4
    ecall

    la        a0,endl
    li        a7,4
    ecall

# Print the address stored in CharPtr
    la        t0, CharPtr              # t0 = address of CharPtr variable
    lw        a0,0(t0)                 # a0 = *CharPtr (the pointer value)
    li        a7,34                    # print pointer in hex
    ecall

    la        a0,endl
    li        a7,4
    ecall

# Print the address stored in BytePtr
    la        t0, BytePtr
    lw        a0,0(t0)
    li        a7,34
    ecall

    la        a0,endl
    li        a7,4
    ecall

# Print the address stored in WordPtr
    la        t0, WordPtr
    lw        a0,0(t0)
    li        a7,34
    ecall

    la        a0,endl
    li        a7,4
    ecall

# Print the address stored in Array2dPtr
    la        t0, Array2dPtr
    lw        a0,0(t0)
    li        a7,34
    ecall

    la        a0,endl
    li        a7,4
    ecall

    jal       main

    la        a0, address_str
    li        a7,4
    ecall

    la        a0,endl
    li        a7,4
    ecall

    la        a0,CharPtr
    li        a7,34
    ecall

    la        a0,endl
    li        a7,4
    ecall

    la        a0,BytePtr
    li        a7,34
    ecall

    la        a0,endl
    li        a7,4
    ecall

    la        a0,WordPtr
    li        a7,34
    ecall

    la        a0,endl
    li        a7,4
    ecall

    la        a0,Array2dPtr
    li        a7,34
    ecall

    la        a0,endl
    li        a7,4
    ecall

    jal       main

# task7: Free all pointers and reset memory
    task7:
# Set all pointers to zero
    la        t0,CharPtr
    sw        zero,0(t0)
    la        t0,BytePtr
    sw        zero,0(t0)
    la        t0,WordPtr
    sw        zero,0(t0)
    la        t0,Array2dPtr
    sw        zero,0(t0)

# Also reset counts to zero
    la        t0,CharCount
    sw        zero,0(t0)
    la        t0,ByteCount
    sw        zero,0(t0)
    la        t0,WordCount
    sw        zero,0(t0)

# Re-initialize memory
    jal       SysInitMem

    la        a0,freeMem
    li        a7,4
    ecall

    la        a0,endl
    li        a7,4
    ecall
    jal       main

    la        t0,CharPtr
    sw        zero,0(t0)
    la        t0,BytePtr
    sw        zero,0(t0)
    la        t0,WordPtr
    sw        zero,0(t0)
    la        t0,Array2dPtr
    sw        zero,0(t0)

    jal       SysInitMem

    la        a0,freeMem
    li        a7,4
    ecall

    la        a0,endl
    li        a7,4
    ecall
    jal       main

# task8: Print how many bytes allocated
    task8:
    la        a0, da_cap_phat
    li        a7,4
    ecall
    jal       AllocatedMemory
    li        a7,1
    ecall

    la        a0,endl
    li        a7,4
    ecall

    jal       main

# task9: Allocate 2D word array
    task9:
    la        a0, message_row
    jal       take_the_int
    mv        t0,a0
    la        a0,message_col
    jal       take_the_int
    mv        a1,t0
    mv        a2,a0
    la        a0,Array2dPtr
    jal       Malloc2d
    mv        s0,a0
    la        a0, message_success
    li        a7,4
    ecall
    mv        a0,s0
    li        a7,34
    ecall
    jal       main

# task10: Set element in 2D array
    task10:
    la        a0,Array2dPtr
    lw        s2,0(a0)
    la        a0,input_row
    jal       take_the_int
    mv        s0,a0
    la        a0,input_col
    jal       take_the_int
    mv        s1,a0
    la        a0,input_val
    jal       take_the_int
    mv        a3,a0
    mv        a1,s0
    mv        a2,s1
    mv        a0,s2
    jal       Set_func
    jal       main

# task11: Get element from 2D array
    task11:
    la        a0,Array2dPtr
    lw        s1,0(a0)
    la        a0,input_row
    jal       take_the_int
    mv        s0,a0
    la        a0,input_col
    jal       take_the_int
    mv        a2,a0
    mv        a1,s0
    mv        a0,s1
    jal       Get_func
    mv        s0,a0
    la        a0,output_val
    li        a7,4
    ecall
    mv        a0,s0
    li        a7,1
    ecall
    jal       main

# task12: Copy data from CharPtr to BytePtr using counts
    task12:
    la        t0,CharPtr
    lw        t1,0(t0)                 # Load source address
    beq       t1,zero,no_src_alloc

    la        t0,BytePtr
    lw        t2,0(t0)                 # Load dest address
    beq       t2,zero,no_dest_alloc

# Load counts
    la        t0,CharCount
    lw        t3,0(t0)                 # t3 = CharCount
    la        t0,ByteCount
    lw        t4,0(t0)                 # t4 = ByteCount

    blt       t4,t3,no_space_left      # If ByteCount < CharCount, no space

# ByteCount >= CharCount, can copy
    mv        a0,t2                    # dest
    mv        a1,t1                    # src
    mv        a2,t3                    # number of chars to copy
    jal       copy_char_arrays         # copy exactly t3 chars

    la        a0, cpyMess
    li        a7,4
    ecall
    jal       main

    no_src_alloc:
    la        a0,message_lessthan1
    li        a7,4
    ecall
    jal       main

    no_dest_alloc:
    la        a0,message_lessthan1
    li        a7,4
    ecall
    jal       main

    no_space_left:
    la        a0,no_space_msg
    li        a7,4
    ecall
    jal       main

    terminated:
    li        a7,10
    ecall

    SysInitMem:
    la        s11,Sys_TheTopOfFree
    la        s9,Sys_MyFreeSpace
    sw        s9,0(s11)
    ret

    malloc:
    la        s11,Sys_TheTopOfFree
    lw        s10,0(s11)
    li        t0,4
    bne       a2,t0,not_word
    addi      s10,s10,3
    li        t0,0xfffffffc
    and       s10,s10,t0
    not_word:
    sw        s10,0(a0)
    mv        a0,s10
    mul       s9,a1,a2
    add       s8,s10,s9
    sw        s8,0(s11)
    ret

    Malloc2d:
    addi      sp,sp,-4
    sw        ra,0(sp)
    la        s0,row
    sw        a1,0(s0)
    sw        a2,4(s0)
    mul       a1,a1,a2
    li        a2,4
    jal       malloc
    lw        ra,0(sp)
    addi      sp,sp,4
    ret

    error_lessthan1:
    la        a0,message_lessthan1
    li        a7,4
    ecall
    jal       main

    Take_ptr_value:
    la        t0,CharPtr
    slli      t1,a0,2
    add       t0,t0,t1
    lw        a0,0(t0)
    ret

    print_task5:
    li        a7,34
    ecall
    la        a0,endl
    li        a7,4
    ecall
    ret

    Take_ptr_address:
    la        t0,CharPtr
    slli      t1,a0,2
    add       a0,t0,t1
    ret

    take_the_int:
    addi      t1,a0,0
    li        a7,51
    ecall
    beq       a1,zero,got_the_int
    li        t0,-2
    beq       a1,t0,terminated
    addi      a0,t1,0
    jal       main
    got_the_int:
    ret

    AllocatedMemory:
    la        s11,Sys_TheTopOfFree
    lw        s11,0(s11)
    la        s10,Sys_MyFreeSpace
    sub       a0,s11,s10
    ret

    Set_func:
    la        s0,row
    lw        s1,0(s0)
    lw        s2,4(s0)
    bge       a1,s1,bound_err
    bge       a2,s2,bound_err
    mul       s0,s2,a1
    add       s0,s0,a2
    slli      s0,s0,2
    add       s0,s0,a0
    sw        a3,0(s0)
    ret

    Get_func:
    la        s0,row
    lw        s1,0(s0)
    lw        s2,4(s0)
    bge       a1,s1,bound_err
    bge       a2,s2,bound_err
    mul       s0,s2,a1
    add       s0,s0,a2
    slli      s0,s0,2
    add       s0,s0,a0
    lw        a0,0(s0)
    ret

    bound_err:
    la        a0,bound_error
    li        a7,4
    ecall
    jal       main

# copy_char_arrays: Copies exactly a2 chars from source(a1) to dest(a0)
    copy_char_arrays:
    li        t0,0                     # counter i=0
    copy_loop:
    beq       t0,a2,done_copy
    lb        t1,0(a1)                 # load byte from source
    sb        t1,0(a0)                 # store byte to dest
    addi      a1,a1,1
    addi      a0,a0,1
    addi      t0,t0,1
    j         copy_loop

    done_copy:
    ret
