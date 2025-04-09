.data
    numbers:    .space  80000 
    input_buffer_size:   .word   80000 
    count:      .word   0
    neg_bitmask:   .space  2500  
    input_filename:   .space  256
    file_read_buffer:    .space  1024
    msg_prompt_input:     .string "Enter filename: "
    error_msg:  .string "\nError opening file\n"
    menu:       .string "\nUser select sorting algorithm:\n1. Bubble Sort\n2. Insertion Sort\n3. Selection Sort\n4. Quick Sort\n5.Close\nChoice: "   
    fd:         .word   0
    newline:    .string "\n"
    space:      .string " "
    start_time: .word   0
    end_time:   .word   0   
    msg_execution_time:   .string "\nExecution time (ms): "   
    output_filename:    .string "D:/HUST/Computer Architecture Lab/output1.txt"
    out_fd:     .word   0
    buffer_number:     .space  12
    msg_file_error_open:  .string "\nError writing to output file\n"
    char_minus:      .string "-"
    tmp_sort_buffer:   .space  80000
.text
.globl main
main:
    # print msg_prompt_input
    li a7, 4
    la a0, msg_prompt_input
    ecall 
    # read input_filename
    li a7, 8
    la a0, input_filename
    li a1, 256
    ecall
    # delete newline from input_filename
    la t0, input_filename
remove_newline_from_filename:
    lb t1, 0(t0)
    beqz t1, open_input_file
    li t2, 10
    beq t1, t2, replace_null
    addi t0, t0, 1
    j remove_newline_from_filename
replace_null:
    sb zero, 0(t0) 
open_input_file:
    li a7, 1024
    la a0, input_filename
    li a1, 0
    ecall
    bltz a0, file_error_open
    la t1, fd
    sw a0, 0(t1)
    jal read_numbers
menu_loop:
    li a7, 4
    la a0, menu
    ecall
    li a7, 5
    ecall
    li t0, 1
    beq a0, t0, bubble_sort_array
    li t0, 2
    beq a0, t0, insertion_sort_array
    li t0, 3
    beq a0, t0, selection_sort_array
    li t0, 4
    beq a0, t0, quick_sort_array
    li t0,5
    beq a0, t0, exit
    j exit
file_error_open:
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
    la t1, count       
    sw zero, 0(t1)    
    li t0, 0           # So hien tai dang duoc xay dung
    li t1, 0           # Co cho biet dang trong so
    li t6, 0           # Co danh dau (0 = duong, 1 = am)
read_loop:
    # Doc mot ky tu tu file
    li a7, 63          # Syscall ReadFile
    lw a0, fd          # Mo ta file
    la a1, file_read_buffer     # Dia chi buffer
    li a2, 1           # Doc mot ky tu
    ecall
    # Kiem tra neu cuoi file
    beqz a0, read_done
    # Tai ky tu
   lb t2, 0(a1)
    # Kiem tra dau tru
    li t3, 45          # ASCII cho '-'
    bne t2, t3, not_char_minus
    beqz t1, set_negative   # Chi dat am neu o dau so
    j read_loop
set_negative:
    li t6, 1           # Dat co danh dau la am
    li t1, 1           # Dat co trong so
    j read_loop 
not_char_minus:
    # Kiem tra neu la dau cach hoac newline
    li t3, 32          # Space
    beq t2, t3, save_number
    li t3, 10          # Newline
    beq t2, t3, save_number 
    # Chuyen doi ASCII thanh so va cong vao so hien tai
    addi t2, t2, -48   # Chuyen doi ASCII thanh so
    li t3, 10
    mul t0, t0, t3     # So hien tai * 10
    add t0, t0, t2     # Cong vao chu so moi
    li t1, 1           # Dat co trong so
    j read_loop 
save_number:
    beqz t1, read_loop  # Neu khong trong so, tiep tuc   
    # Ap dung dau neu la am
    beqz t6, save_positive
    neg t0, t0         # Doi dau so neu co am duoc dat   
save_positive:
    # Luu so vao mang
    la t3, count       # Tai dia chi cua count
    lw t3, 0(t3)       # Tai gia tri count
    slli t4, t3, 2     # t4 = count * 4
    la t5, numbers
    add t5, t5, t4
    sw t0, 0(t5)       # Luu so  
    # Tang count
    addi t3, t3, 1
    la t4, count       # Tai dia chi cua count
    sw t3, 0(t4)       # Luu count moi  
    # Reset cho so tiep theo
    li t0, 0           # Reset so hien tai
    li t1, 0           # Reset co trong so
    li t6, 0           # Reset co am
    j read_loop
read_done:
    # Neu chung ta dang trong so khi file ket thuc, luu no
    beqz t1, close_file  
    # Ap dung dau neu la am
    beqz t6, save_last_positive
    neg t0, t0         # Doi dau so neu co am duoc dat  
save_last_positive:
    la t3, count       # Tai dia chi cua count
    lw t3, 0(t3)       # Tai gia tri count
    slli t4, t3, 2
    la t5, numbers
    add t5, t5, t4
    sw t0, 0(t5)
    addi t3, t3, 1
    la t4, count       # Tai dia chi cua count
    sw t3, 0(t4)       # Luu count moi
close_file:
    # Dong file
    li a7, 57          # Syscall Close file
    lw a0, fd
    ecall 
    lw ra, 12(sp)
    lw s0, 8(sp)
    lw s1, 4(sp)
    lw s2, 0(sp)
    addi sp, sp, 16
    ret
flag_negative_numbers:
    # a0 = dia chi mang
    # a1 = size
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)
    sw s2, 0(sp)   
    mv s0, a0          # s0 = dia chi mang
    mv s1, a1          # s1 = size
    li s2, 0           # s2 = bo dem  
flag_loop:
    bge s2, s1, flag_done  
    # Tai so hien tai
    slli t0, s2, 2     # t0 = bo dem * 4
    add t0, s0, t0
    lw t1, 0(t0)      # Tai so  
    # Bo qua neu duong
    bgez t1, skip_flag   
    # Tinh toan byte va vi tri bit trong bitmask
    mv t0, s2          # Sao chep chi so
    srai t1, t0, 3     # Byte offset = chi so / 8
    andi t2, t0, 0x7   # Vi tri bit = chi so % 8
    li t3, 1
    sll t3, t3, t2     # Dich chuyen 1 den vi tri bit chinh xac   
    # Dat bit trong bitmask
    la t4, neg_bitmask
    add t4, t4, t1     # Them byte offset
    lb t5, 0(t4)       # Tai byte hien tai
    or t5, t5, t3      # Dat bit
    sb t5, 0(t4)       # Luu byte da cap nhat  
skip_flag:
    addi s2, s2, 1
    j flag_loop  
flag_done:
    lw ra, 12(sp)
    lw s0, 8(sp)
    lw s1, 4(sp)
    lw s2, 0(sp)
    addi sp, sp, 16
    ret
quick_sort_array:
    # Lay thoi gian bat dau
    jal get_time
    sw a0, start_time, t0   
    # Khoi tao quicksort
    la a0, numbers
    li a1, 0
    lw a2, count
    addi a2, a2, -1
    jal quick_sort_logic   
    # Danh dau cac so am
    la a0, numbers
    lw a1, count
    jal flag_negative_numbers   
    # Lay thoi gian ket thuc va tinh thoi gian thuc thi
    jal get_time
    sw a0, end_time, t0
    jal print_time   
    # Ghi ket qua vao file
    jal write_results
    j menu_loop
quick_sort_logic:
    # a0 = dia chi mang
    # a1 = chi so ben trai
    # a2 = chi so ben phai
    addi sp, sp, -24
    sw ra, 20(sp)
    sw s0, 16(sp)
    sw s1, 12(sp)
    sw s2, 8(sp)
    sw s3, 4(sp)
    sw s4, 0(sp)  
    # Luu cac tham so
    mv s0, a0         # s0 = dia chi mang
    mv s1, a1         # s1 = ben trai
    mv s2, a2         # s2 = ben pha   
   # Dieu kien dung: neu ben trai >= ben phai, thoat
    bge s1, s2, quick_sort_end  
    # Goi ham partition_elements
    mv a0, s0         # dia chi mang
    mv a1, s1         # chi so ben trai
    mv a2, s2         # chi so ben phai
    jal partition_elements
    mv s3, a0         # s3 = chi so pivot    
    # De quy sap xep phan ben trai
    mv a0, s0         # dia chi mang
    mv a1, s1         # chi so ben trai
    addi a2, s3, -1   # pivot - 1
    jal quick_sort_logic
    # De quy sap xep phan ben phai
    mv a0, s0         # dia chi mang
    addi a1, s3, 1    # pivot + 1
    mv a2, s2         # chi so ben phai
    jal quick_sort_logic   
quick_sort_end:
    lw ra, 20(sp)
    lw s0, 16(sp)
    lw s1, 12(sp)
    lw s2, 8(sp)
    lw s3, 4(sp)
    lw s4, 0(sp)
    addi sp, sp, 24
    ret
partition_elements:
    addi sp, sp, -24
    sw ra, 20(sp)
    sw s0, 16(sp)
    sw s1, 12(sp)
    sw s2, 8(sp)
    sw s3, 4(sp)
    sw s4, 0(sp)  
    mv s0, a0         # s0 = dia chi mang
    mv s1, a1         # s1 = ben trai
    mv s2, a2         # s2 = ben phai
    slli t0, s2, 2    # t0 = ben phai * 4
    add t0, s0, t0
    lw s3, 0(t0)      # s3 = gia tri pivot  
    addi s4, s1, -1   # i = ben trai - 1
    mv t1, s1         # j = ben trai  
partition_loop_elements:
    bge t1, s2, partition_elements_done   
    # Tai phan tu hien tai
    slli t0, t1, 2
    add t0, s0, t0
    lw t2, 0(t0)      # t2 = arr[j]   
    # So sanh voi pivot
    bgt t2, s3, skip_swap   
    # Tang i
    addi s4, s4, 1    
    # Doi phan tu neu i != j
    slli t0, s4, 2
    add t0, s0, t0    # Dia chi cua arr[i]
    slli t3, t1, 2
    add t3, s0, t3    # Dia chi cua arr[j]   
    lw t4, 0(t0)      # t4 = arr[i]
    lw t5, 0(t3)      # t5 = arr[j]
    sw t5, 0(t0)      # arr[i] = arr[j]
    sw t4, 0(t3)      # arr[j] = arr[i]  
skip_swap:
    addi t1, t1, 1    # j++
    j partition_loop_elements   
partition_elements_done:
    # Dat pivot vao vi tri cuoi cung
    addi s4, s4, 1    # i++    
    # Doi pivot voi phan tu tai i
    slli t0, s4, 2
    add t0, s0, t0    # Dia chi cua arr[i]
    slli t1, s2, 2
    add t1, s0, t1    # Dia chi cua arr[right] 
    lw t2, 0(t0)      # t2 = arr[i]
    lw t3, 0(t1)      # t3 = arr[right]
    sw t3, 0(t0)      # arr[i] = arr[right]
    sw t2, 0(t1)      # arr[right] = arr[i] 
    # Tra ve chi so pivot
    mv a0, s4   
    lw ra, 20(sp)
    lw s0, 16(sp)
    lw s1, 12(sp)
    lw s2, 8(sp)
    lw s3, 4(sp)
    lw s4, 0(sp)
    addi sp, sp, 24
    ret
bubble_sort_array:
    # Lay thoi gian bat dau
    jal get_time
    sw a0, start_time, t0   
    # Thuc hien bubble sort
    la a0, numbers     # Tai dia chi mang
    lw a1, count       # Tai kich thuoc mang
    jal bubble_sort_core
        # Danh dau cac so am
    la a0, numbers
    lw a1, count
    jal flag_negative_numbers
    # Lay thoi gian ket thuc va tinh thoi gian thuc thi
    jal get_time
    sw a0, end_time, t0
    jal print_time   
    # Ghi ket qua vao file
    jal write_results
    j exit
insertion_sort_array:
    # Lay thoi gian bat dau
    jal get_time
    sw a0, start_time, t0    
    # Thuc hien insertion sort
    la a0, numbers     # Tai dia chi mang
    lw a1, count       # Tai kich thuoc mang
    jal insertion_sort_array_impl
        # Danh dau cac so am
    la a0, numbers
    lw a1, count
    jal flag_negative_numbers
    # Lay thoi gian ket thuc va tinh thoi gian thuc thi
    jal get_time
    sw a0, end_time, t0
    jal print_time   
    # Ghi ket qua vao file
    jal write_results
    j exit
selection_sort_array:
    # Lay thoi gian bat dau
    jal get_time
    sw a0, start_time, t0   
    # Thuc hien selection sort
    la a0, numbers     # Tai dia chi mang
    lw a1, count       # Tai kich thuoc mang
    jal selection_sort_array_impl   
    # Danh dau cac so am
    la a0, numbers
    lw a1, count
    jal flag_negative_numbers    
    # Lay thoi gian ket thuc va tinh thoi gian thuc thi
    jal get_time
    sw a0, end_time, t0
    jal print_time    
    # Ghi ket qua vao file
    jal write_results
    j exit
bubble_sort_core:
    # a0 = dia chi mang
    # a1 = kich thuoc
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)
    sw s2, 0(sp)
    mv s0, a0          # s0 = dia chi mang
    mv s1, a1          # s1 = kich thuoc
    li s2, 0           # s2 = i    
outer_loop_bubble_sort:
    bge s2, s1, bubble_done
    li t0, 0           # j = 0    
inner_loop_bubble_sort:
    sub t1, s1, s2
    addi t1, t1, -1
    bge t0, t1, inner_done_bubble_sort
    slli t2, t0, 2
    add t2, s0, t2
    lw t3, 0(t2)      # arr[j]
    lw t4, 4(t2)      # arr[j+1]    
    ble t3, t4, no_swap_bubble_sort
    sw t4, 0(t2)
    sw t3, 4(t2)   
no_swap_bubble_sort:
    addi t0, t0, 1
    j inner_loop_bubble_sort   
inner_done_bubble_sort:
    addi s2, s2, 1
    j outer_loop_bubble_sort   
bubble_done:
    lw ra, 12(sp)
    lw s0, 8(sp)
    lw s1, 4(sp)
    lw s2, 0(sp)
    addi sp, sp, 16
    ret
insertion_sort_array_impl:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)
    sw s2, 0(sp)
    mv s0, a0          # s0 = dia chi mang
    mv s1, a1          # s1 = kich thuoc
    li s2, 1           # s2 = i = 1 
outer_loop_insertion:
    bge s2, s1, insertion_done
    
    # Lay phan tu hien tai
    slli t0, s2, 2     # t0 = i * 4
    add t0, s0, t0
    lw t1, 0(t0)      # key = arr[i]
    addi t2, s2, -1    # j = i-1
    
inner_loop_insertion:
    bltz t2, inner_done_insertion    # neu j < 0, thoat   
    # So sanh cac phan tu
    slli t3, t2, 2
    add t3, s0, t3
    lw t4, 0(t3)      # arr[j]    
    ble t4, t1, inner_done_insertion    
    # Di chuyen phan tu
    sw t4, 4(t3)      # arr[j+1] = arr[j]   
    addi t2, t2, -1    # j--
    j inner_loop_insertion    
inner_done_insertion:
    # Dat key vao vi tri chinh xac
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
selection_sort_array_impl:
    # a0 = dia chi mang
    # a1 = kich thuoc
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)
    sw s2, 0(sp)   
    mv s0, a0          # s0 = dia chi mang
    mv s1, a1          # s1 = kich thuoc
    li s2, 0           # s2 = i   
outer_loop_selection:
    addi t0, s1, -1
    bge s2, t0, selection_done  
    mv t1, s2          # min_idx = i
    addi t2, s2, 1     # j = i + 1  
inner_loop_selection:
    bge t2, s1, inner_done_selection   
    # So sanh cac phan tu
    slli t3, t2, 2
    add t3, s0, t3
    lw t4, 0(t3)      # arr[j]    
    slli t5, t1, 2
    add t5, s0, t5
    lw t6, 0(t5)      # arr[min_idx]    
    bge t4, t6, no_update_min
    mv t1, t2          # Cap nhat min_idx   
no_update_min:
    addi t2, t2, 1
    j inner_loop_selection  
inner_done_selection:
    # Hoan doi cac phan tu neu can
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
    bge s2, s0, read_loop  # Neu da parse het buffer, doc tiep   
    # Doc ky tu
    add t0, s1, s2
    lb t1, 0(t0)   
    # Kiem tra xem co phai space khong
    li t2, 32         # ASCII cho space
    beq t1, t2, next_char    # Chuyen doi ASCII sang so
    addi t1, t1, -48  # Chuyen ASCII thanh so
    # Luu so vao mang numbers
    lw t3, count
    slli t4, t3, 2    # t4 = count * 4 (de tinh offset)
    la t5, numbers
    add t5, t5, t4
    sw t1, 0(t5)      # Luu so vao mang    
    # Tang count
    addi t3, t3, 1
    sw t3, count, t6
next_char:
    addi s2, s2, 1
    j parse_loop
get_time:
    li a7, 30         # Syscall GetTime
    ecall
    ret
print_time:
    # Tinh toan va in thoi gian thuc thi
    la t0, start_time
    lw t1, 0(t0)
    la t0, end_time
    lw t2, 0(t0)
    sub t3, t2, t1    # Thoi gian thuc thi 
    li a7, 4
    la a0, msg_execution_time
    ecall   
    li a7, 1
    mv a0, t3
    ecall
    ret
number_to_string:
    # a0 = dia chi buffer
    # a1 = so can chuyen doi
    addi sp, sp, -24
    sw ra, 20(sp)
    sw s0, 16(sp)
    sw s1, 12(sp)
    sw s2, 8(sp)
    sw s3, 4(sp)
    sw s4, 0(sp)   
    mv s0, a0         # Luu dia chi buffer
    mv s1, a1         # Luu so can chuyen doi
    li s2, 0          # Khoi tao bo dem do dai
    li s3, 0          # Co danh dau so am    
    # Xu ly truong hop so 0
    bnez s1, check_sign
    li t0, 48         # ASCII '0'
    sb t0, 0(s0)
    li a0, 1          # Do dai la 1
    j num_to_str_done    
check_sign:
    # Kiem tra so am
    bgez s1, convert_digits
    li s3, 1                   # Dat co danh dau am
    neg s1, s1                 # Chuyen so thanh duong   
convert_digits:
    # Chuyen doi cac chu so theo thu tu nguoc lai
    mv t0, s0
digit_loop:
    beqz s1, finalize_string
    li t1, 10
    rem t2, s1, t1    # Lay chu so cuoi cung
    div s1, s1, t1
    addi t2, t2, 48   # Chuyen thanh ASCII
    sb t2, 0(t0)
    addi t0, t0, 1
    addi s2, s2, 1
    j digit_loop   
finalize_string:
    # Them dau tru neu la so am
    beqz s3, reverse_string
    li t1, 45         # ASCII '-'
    sb t1, 0(t0)
    addi t0, t0, 1
    addi s2, s2, 1
reverse_string:
    mv a0, s0
    addi a1, t0, -1   # Cuoi chuoi
    jal str_reverse   
    mv a0, s2         # Tra ve do dai    
num_to_str_done:
    lw ra, 20(sp)
    lw s0, 16(sp)
    lw s1, 12(sp)
    lw s2, 8(sp)
    lw s3, 4(sp)
    lw s4, 0(sp)
    addi sp, sp, 24
    ret
# Ham tro giup dao nguoc chuoi tai cho
str_reverse:
    # a0 = dia chi bat dau
    # a1 = dia chi ket thuc
    bge a0, a1, str_rev_done
    
    # Hoan doi ky tu
    lb t0, 0(a0)
    lb t1, 0(a1)
    sb t1, 0(a0)
    sb t0, 0(a1)
    
    # Di chuyen con tro
    addi a0, a0, 1
    addi a1, a1, -1
    j str_reverse 
str_rev_done:
    ret
write_results:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)
    sw s2, 0(sp)   
    # Mo file results.txt de ghi
    li a7, 1024       # Syscall Open file
    la a0, output_filename    # input_filename
    li a1, 1          # Chi ghi
    li a2, 0x1ff      # Quyen truy cap file (777 trong octal)
    ecall   
    # Kiem tra neu mo file thanh cong
    bltz a0, msg_file_error_openor
    sw a0, out_fd, t0 # Luu mo ta file   
    # Ghi so vao file
    li s0, 0          # Khoi tao bo dem
    lw s1, count      # Tai tong so luong
    la s2, numbers    # Tai dia chi mang  
write_loop:
    bge s0, s1, write_done  
    # Tai so hien tai
    slli t0, s0, 2
    add t1, s2, t0
    lw t2, 0(t1)       # Tai so   
    # Chuyen so thanh chuoi
    la a0, buffer_number
    mv a1, t2
    jal number_to_string
    mv t3, a0          # t3 = do dai cua chuoi   
    # Ghi so vao file
    li a7, 64          # Syscall WriteFile
    lw a0, out_fd
    la a1, buffer_number
    mv a2, t3          # Do dai chinh xac
    ecall   
    # Ghi dau cach sau so (tru so cuoi cung)
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
    # Ghi newline o cuoi
    li a7, 64
    lw a0, out_fd
    la a1, newline
    li a2, 1
    ecall   
    # Dong file output
    li a7, 57         # Syscall Close file
    lw a0, out_fd
    ecall 
    lw ra, 12(sp)
    lw s0, 8(sp)
    lw s1, 4(sp)
    lw s2, 0(sp)
    addi sp, sp, 16
    ret
msg_file_error_openor:
    # In thong bao loi
    li a7, 4
    la a0, msg_file_error_open
    ecall  
    lw ra, 12(sp)
    lw s0, 8(sp)
    lw s1, 4(sp)
    lw s2, 0(sp)
    addi sp, sp, 16
    ret
write_positive_numbers:
    # Tai so
    slli t0, s0, 2
    add t1, s2, t0
    lw t2, 0(t1)
    # Lay gia tri tuyet doi thu cong
    bgez t2, skip_abs
    neg t2, t2
skip_abs:
    
    la a0, buffer_number
    mv a1, t2
    jal number_to_string # Ghi so
    li a7, 64
    lw a0, out_fd
    la a1, buffer_number
    mv a2, a0         # Do dai tra ve boi number_to_string
    ecall   
    # Ghi dau cach (tru so cuoi cung)
    addi t0, s1, -1
    bge s0, t0, skip_space   
    li a7, 64
    lw a0, out_fd
    la a1, space
    li a2, 1
    ecall
check_negative:
    bgez s1, positive_conversion   # Neu so >= 0, bo qua xu ly so am  
    # Xu ly so am
    li t0, 45         # ASCII '-'
    sb t0, 0(s0)      # Luu ky tu tru
    addi s0, s0, 1    # Di chuyen con tro buffer
    addi s2, s2, 1    # Tang do dai
    neg s1, s1        # Chuyen so thanh duong   
positive_conversion:
    mv t0, s0         # Vi tri hien tai trong buffer
    mv t1, s1         # Ban sao lam viec cua so
reverse_digits:
    mv a0, s0         # Bat dau cua chuoi
    add a1, s0, s2
    addi a1, a1, -1   # Cuoi chuoi  
    # Them ky tu ket thuc
    add t0, s0, s2
    sb zero, 0(t0)  
    jal str_reverse
    mv a0, s2         # Tra ve do dai
exit:
    li a7, 10         # Syscall Exit
    ecall
