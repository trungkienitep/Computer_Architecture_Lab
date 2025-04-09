.data
buffer: .space 1000
input_display: .asciz "Enter the input string: "
input_warning: .asciz "Length of the string must be a multiple 8\n"

disk_title_1: .asciz "    DISK 1    "
disk_title_2: .asciz "    DISK 2    "
disk_title_3: .asciz "    DISK 3    "

begin_line_bound: .asciz "\n --------------"
space_line_bound: .asciz "        "
space_title_bound: .asciz "         "
space_large_title_bound: .asciz "          "
line_bound: .asciz " --------------"

loop_begin_first: .asciz "\n|     "
loop_begin: .asciz "|     "
loop_end: .asciz "     |"

partition_begin_first: .asciz "\n[[ "
partition_begin: .asciz "[[ "
partition_end: .asciz "]]"

comma_space: .asciz ","



.text
input:
  li a7, 4
  la a0, input_display
  ecall
  
  li a7, 8
  la a0, buffer
  li a1, 100
  ecall
  
  li t6, 3
  li s8, 1
  li s9, 2
  li t1, 10
  li t2, 0
  
count_char:
  la s1 buffer

count_char_loop:
  lb s2 0(s1)
  beq s2, t1, exit_loop
  addi t2, t2, 1
  addi s1, s1, 1
  j count_char_loop
  
exit_loop:
  li t4, 8
  rem t4, t2, t4
  bnez t4 re_input
  li t4, 8
  div t4, t2, t4
  j disk_title
  
re_input:
  li a7, 4
  la a0, input_warning
  ecall
  j input
  
  
  
#Print the disk title
disk_title:  
  li a7, 4
  la a0, disk_title_1
  ecall

  li a7, 4
  la a0, space_large_title_bound
  ecall
  
  li a7, 4
  la a0, disk_title_2
  ecall
  
  li a7, 4
  la a0, space_large_title_bound
  ecall
  
  li a7, 4
  la a0, disk_title_3
  ecall
  
#Print the begin line of boundary
begin_bound:
  li a7, 4
  la a0, begin_line_bound
  ecall
  
  li a7, 4
  la a0, space_title_bound
  ecall
  
  li a7, 4
  la a0, line_bound
  ecall
  
  li a7, 4
  la a0, space_title_bound
  ecall
  
  li a7, 4
  la a0, line_bound
  ecall
  
prepare_loop:
  li t3, 0
  la s1, buffer
  j start_loop
  
start_loop:
  beq t3, t4, end_bound
  li s3, 0
  li s4, 7
  
first_load_prepare:
  blt s4, s3, end_prepare
  lb s5,0(s1)
  addi sp, sp, -1
  sb s5, 0(sp)
  addi s3, s3, 1
  addi s1, s1, 1 
  j first_load_prepare
  
end_prepare:

start_xor:
  lb s6, 3(sp)
  lb s7, 7(sp)
  xor s7, s7, s6
  sb s7 -1(sp)
  
  lb s6, 2(sp)
  lb s7, 6(sp)
  xor s7, s7, s6
  sb s7 -2(sp)
  
  lb s6, 1(sp)
  lb s7, 5(sp)
  xor s7, s7, s6
  sb s7 -3(sp)
  
  lb s6, 0(sp)
  lb s7, 4(sp)
  xor s7, s7, s6
  sb s7 -4(sp)
  
  li t5, 0
  rem t5, t3, t6
  add s10 zero sp
  beqz t5, print_1
  beq t5, s8, print_2
  beq t5, s9, print_3
  
print_1:
start_print:
  li a7, 4
  la a0, loop_begin_first
  ecall
  
  li a7, 11
  lb a0, 7(sp)
  ecall

  li a7, 11
  lb a0, 6(sp)
  ecall  
  
  li a7, 11
  lb a0, 5(sp)
  ecall  
  
  li a7, 11
  lb a0, 4(sp)
  ecall

  li a7, 4
  la a0, loop_end
  ecall
  
  li a7, 4
  la a0, space_line_bound
  ecall
  
  li a7, 4
  la a0, loop_begin
  ecall

  li a7, 11
  lb a0, 3(sp)
  ecall  
  
  li a7, 11
  lb a0, 2(sp)
  ecall  
  
  li a7, 11
  lb a0, 1(sp)
  ecall  
  
  li a7, 11
  lb a0, 0(sp)
  ecall
  
  li a7, 4
  la a0, loop_end
  ecall
  
  li a7, 4
  la a0, space_line_bound
  ecall
  
  li a7, 4
  la a0, partition_begin
  ecall

  li s3, 0
  li s4, 3
  j xor_print_loop

xor_print_loop:
  blt s4, s3, end_xor_print
  lb a1, -1(s10)
  andi s6, a1, 0xf0
  srli s6, s6, 4
  
  bge s6, t1, print_char_first
  blt s6, t1, print_num_first
  
print_num_first:
  li a7, 1
  add a0, zero ,s6
  ecall
  j after_first_print
  
print_char_first:
  addi s6, s6, 87
  li a7, 11
  add a0, zero ,s6
  ecall
  j after_first_print
  
after_first_print:
  andi s7, a1, 0x0f
  bge s7, t1, print_char_second
  blt s7, t1, print_num_second
  
print_num_second:
  li a7, 1
  add a0, zero ,s7
  ecall
  j after_second_print
  
print_char_second:
  addi s7, s7, 87
  li a7, 11
  add a0, zero ,s7
  ecall
  j after_second_print
  
after_second_print:
  addi s10, s10, -1
  bne s3, s4, add_comma_space
  addi s3, s3, 1
  j xor_print_loop
  
add_comma_space:
  li a7, 4
  la a0, comma_space
  ecall
  addi s3, s3, 1
  j xor_print_loop
  
end_xor_print:
  li a7, 4
  la a0, partition_end
  ecall
  j end_current_loop
  
## PRINT STRATEGY 2  
print_2:
start_print_2:
  li a7, 4
  la a0, loop_begin_first
  ecall
  
  li a7, 11
  lb a0, 7(sp)
  ecall
  
  li a7, 11
  lb a0, 6(sp)
  ecall  
  
  li a7, 11
  lb a0, 5(sp)
  ecall  
  
  li a7, 11
  lb a0, 4(sp)
  ecall

  li a7, 4
  la a0, loop_end
  ecall
  
  li a7, 4
  la a0, space_line_bound
  ecall
  
  li a7, 4
  la a0, partition_begin
  ecall
  
  li s3, 0
  li s4, 3
  j xor_print_loop_2
  
xor_print_loop_2:
  blt s4, s3, end_xor_print_2
  lb a1, -1(sp)
  andi s6, a1, 0xf0
  srli s6, s6, 4
  
  bge s6, t1, print_char_first_2
  blt s6, t1, print_num_first_2
  
print_num_first_2:
  li a7, 1
  add a0, zero ,s6
  ecall
  j after_first_print_2
  
print_char_first_2:
  addi s6, s6, 87
  li a7, 11
  add a0, zero ,s6
  ecall
  j after_first_print_2
  
after_first_print_2:
  andi s7, a1, 0x0f
  bge s7, t1, print_char_second_2
  blt s7, t1, print_num_second_2
  
print_num_second_2:
  li a7, 1
  add a0, zero ,s7
  ecall
  j after_second_print_2
  
print_char_second_2:
  addi s7, s7, 87
  li a7, 11
  add a0, zero ,s7
  ecall
  j after_second_print_2
  
after_second_print_2:
  addi s10, s10, -1
  bne s3, s4, add_comma_space_2
  addi s3, s3, 1
  j xor_print_loop_2
  
add_comma_space_2:
  li a7, 4
  la a0, comma_space
  ecall
  addi s3, s3, 1
  j xor_print_loop_2
  
end_xor_print_2:
  li a7, 4
  la a0, partition_end
  ecall
  
  li a7, 4
  la a0, space_line_bound
  ecall
  
  li a7, 4
  la a0, loop_begin
  ecall

  li a7, 11
  lb a0, 3(sp)
  ecall  
  
  li a7, 11
  lb a0, 2(sp)
  ecall  
  
  li a7, 11
  lb a0, 1(sp)
  ecall  
  
  li a7, 11
  lb a0, 0(sp)
  ecall
  
  li a7, 4
  la a0, loop_end
  ecall
	
  j end_current_loop
  
## PRINT STRATEGY 3  
print_3:
start_print_3:
  li a7, 4
  la a0, partition_begin_first
  ecall
  
  li s3, 0
  li s4, 3
  j xor_print_loop_3
  
xor_print_loop_3:
  blt s4, s3, end_xor_print_3
  lb a1, -1(sp)
  andi s6, a1, 0xf0
  srli s6, s6, 4
  
  bge s6, t1, print_char_first_3
  blt s6, t1, print_num_first_3
  
print_num_first_3:
  li a7, 1
  add a0, zero ,s6
  ecall
  j after_first_print_3
  
print_char_first_3:
  addi s6, s6, 87
  li a7, 11
  add a0, zero ,s6
  ecall
  j after_first_print_3
  
after_first_print_3:
  andi s7, a1, 0x0f
  bge s7, t1, print_char_second_3
  blt s7, t1, print_num_second_3
  
print_num_second_3:
  li a7, 1
  add a0, zero ,s7
  ecall
  j after_second_print_3
  
print_char_second_3:
  addi s7, s7, 87
  li a7, 11
  add a0, zero ,s7
  ecall
  j after_second_print_3
  
after_second_print_3:
  addi s10, s10, -1
  bne s3, s4, add_comma_space_3
  addi s3, s3, 1
  j xor_print_loop_3
  
add_comma_space_3:
  li a7, 4
  la a0, comma_space
  ecall
  addi s3, s3, 1
  j xor_print_loop_3
  
end_xor_print_3:
  li a7, 4
  la a0, partition_end
  ecall
  
  li a7, 4
  la a0, space_line_bound
  ecall

  li a7, 4
  la a0, loop_begin
  ecall
  
  li a7, 11
  lb a0, 7(sp)
  ecall
  
  li a7, 11
  lb a0, 6(sp)
  ecall  
  
  li a7, 11
  lb a0, 5(sp)
  ecall  
  
  li a7, 11
  lb a0, 4(sp)
  ecall

  li a7, 4
  la a0, loop_end
  ecall
  
  li a7, 4
  la a0, space_line_bound
  ecall
  
  li a7, 4
  la a0, loop_begin
  ecall

  li a7, 11
  lb a0, 3(sp)
  ecall  
  
  li a7, 11
  lb a0, 2(sp)
  ecall  
  
  li a7, 11
  lb a0, 1(sp)
  ecall  
  
  li a7, 11
  lb a0, 0(sp)
  ecall
  
  li a7, 4
  la a0, loop_end
  ecall

  li s3, 0
  li s4, 3
  j end_current_loop
  
end_current_loop:
  addi t3, t3, 1
  addi sp, sp, 8
  j start_loop
  
#Print the end line of boundary
end_bound:
  li a7, 4
  la a0, begin_line_bound
  ecall
  
  li a7, 4
  la a0, space_title_bound
  ecall
  
  li a7, 4
  la a0, line_bound
  ecall
  
  li a7, 4
  la a0, space_title_bound
  ecall
  
  li a7, 4
  la a0, line_bound
  ecall
  
  
  
