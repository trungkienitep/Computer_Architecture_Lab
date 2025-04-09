.data
buffer: .space 1000                    
prompt_Input: .asciz "Nhập chuỗi kí tự: "   
prompt_Condition: .asciz "Chiều dài chuỗi phải chia hết cho 8\n"  
prompt1: .asciz "       Disk 1       "       # Tiêu đề đĩa 1
prompt2: .asciz "       Disk 2       "       # Tiêu đề đĩa 2
prompt3: .asciz "       Disk 3       "       # Tiêu đề đĩa 3
# Các chuỗi định dạng và ngăn cách
dauPhay: .asciz ","                   # Dấu phẩy
SpaceDnB: .asciz "\n --------------------"
CachDong: .asciz "--------------------"     # Đường viền
space: .asciz "        "              # Khoảng trắng
space_Disk: .asciz "          "       # Khoảng trắng lớn hơn
GDauDong: .asciz "\n|       "           # Bắt đầu dòng (Khi chuyển sang disk 1 mới)
DauDong: .asciz    "|       "              # Bắt đầu dòng
CuoiDong: .asciz "       |"             # Kết thúc dòng
mongoac: .asciz "[[  "                 # Mở ngoặc vuông
mongoacD: .asciz "\n[[  "                 # Mở ngoặc vuông
dongngoac: .asciz "  ]] "                # Đóng ngoặc vuông
endln : .asciz "\n"                   # Dòng mới

.text
# Hàm chính để xử lý mã hóa và hiển thị dữ liệu đĩa
xu_ly_ma_hoa:
  # Hiển thị lời nhắc nhập
  li a7, 4
  la a0, prompt_Input
  ecall
  # Nhập chuỗi
  li a7, 8
  la a0, buffer
  li a1, 100
  ecall
  # Khởi tạo các biến điều khiển ban đầu
  li t6, 3                # Số lượng đĩa
  li s8, 1                # Chỉ số đĩa thứ 2
  li s9, 2                # Chỉ số đĩa thứ 3
  li t1, 10               # Giá trị ngưỡng cho chuyển đổi số/chữ
  li t2, 0                # Bộ đếm độ dài chuỗi
# Đếm số ký tự trong chuỗi đầu vào
dem_ky_tu:
  la s1 buffer
dem_ky_tu_lap:
  lb s2 0(s1)
  beq s2, t1, thoat_vong_lap   # Nếu gặp ký tự kết thúc
  addi t2, t2, 1           # Tăng bộ đếm
  addi s1, s1, 1           # Chuyển con trỏ sang ký tự tiếp theo
  j dem_ky_tu_lap
thoat_vong_lap:
  # Kiểm tra điều kiện độ dài chuỗi
  li t4, 8
  rem t4, t2, t4
  bnez t4, nhap_lai        # Nếu không chia hết cho 8, nhập lại
  li t4, 8
  div t4, t2, t4           # Số lượng khối 8 byte
  j in_tieu_de_dia         # Chuyển đến in tiêu đề đĩa
nhap_lai:
  # Hiển thị cảnh báo và yêu cầu nhập lại
  li a7, 4
  la a0, prompt_Condition
  ecall
  j xu_ly_ma_hoa
  
# In tiêu đề các đĩa
in_tieu_de_dia:  
  # In tiêu đề từng đĩa với khoảng trắng
  li a7, 4
  la a0, prompt1
  ecall

  li a7, 4
  la a0, space_Disk
  ecall
  
  li a7, 4
  la a0, prompt2
  ecall
  
  li a7, 4
  la a0, space_Disk
  ecall
  
  li a7, 4
  la a0, prompt3
  ecall
  
Tao_ranh_gioi:
  li a7, 4
  la a0, SpaceDnB
  ecall
  
  li a7, 4
  la a0, space
  ecall
  
  li a7, 4
  la a0, CachDong
  ecall
  
  li a7, 4
  la a0, space
  ecall
  
  li a7, 4
  la a0, CachDong
  ecall
  
Chuan_bi_du_lieu:
  li t3, 0
  la s1, buffer
  j Loop
  
Loop:
  beq t3, t4, Gach_Cuoi_Dong
  li s3, 0
  li s4, 7
  
Lay_Ky_Tu:
  blt s4, s3, Xong_chuan_bi
  lb s5,0(s1)
  addi sp, sp, -1
  sb s5, 0(sp)
  addi s3, s3, 1
  addi s1, s1, 1 
  j Lay_Ky_Tu
  
Xong_chuan_bi:

Xor:
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
  beqz t5, InDia1
  beq t5, s8, InDia2
  beq t5, s9, InDia3
  
InDia1:
start_print:
  li a7, 4
  la a0, GDauDong
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
  la a0, CuoiDong
  ecall
  
  li a7, 4
  la a0, space
  ecall
  
  li a7, 4
  la a0, DauDong
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
  la a0, CuoiDong
  ecall
  
  li a7, 4
  la a0, space
  ecall
  
  li a7, 4
  la a0, mongoac
  ecall

  li s3, 0
  li s4, 3
  j Xor_print

Xor_print:
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
  j Xor_print
  
add_comma_space:
  li a7, 4
  la a0, dauPhay
  ecall
  addi s3, s3, 1
  j Xor_print
  
end_xor_print:
  li a7, 4
  la a0, dongngoac
  ecall
  j end_current_loop

InDia2:
start_print_2:
  li a7, 4
  la a0, GDauDong
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
  la a0, CuoiDong
  ecall
  
  li a7, 4
  la a0, space
  ecall
  
  li a7, 4
  la a0, mongoac
  ecall
  
  li s3, 0
  li s4, 3
  j Xor_print2
  
Xor_print2:
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
  j Xor_print2
  
add_comma_space_2:
  li a7, 4
  la a0, dauPhay
  ecall
  addi s3, s3, 1
  j Xor_print2
  
end_xor_print_2:
  li a7, 4
  la a0, dongngoac
  ecall
  
  li a7, 4
  la a0, space
  ecall
  
  li a7, 4
  la a0, DauDong
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
  la a0, CuoiDong
  ecall
	
  j end_current_loop 
InDia3:
start_print_3:
  li a7, 4
  la a0, mongoacD
  ecall
  
  li s3, 0
  li s4, 3
  j Xor_print3
  
Xor_print3:
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
  j Xor_print3
  
add_comma_space_3:
  li a7, 4
  la a0, dauPhay
  ecall
  addi s3, s3, 1
  j Xor_print3
  
end_xor_print_3:
  li a7, 4
  la a0, dongngoac
  ecall
  
  li a7, 4
  la a0, space
  ecall

  li a7, 4
  la a0, DauDong
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
  la a0, CuoiDong
  ecall
  
  li a7, 4
  la a0, space
  ecall
  
  li a7, 4
  la a0, DauDong
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
  la a0, CuoiDong
  ecall

  li s3, 0
  li s4, 3
  j end_current_loop
  
end_current_loop:
  addi t3, t3, 1
  addi sp, sp, 8
  j Loop
Gach_Cuoi_Dong:
  li a7, 4
  la a0, SpaceDnB
  ecall
  
  li a7, 4
  la a0, space
  ecall
  
  li a7, 4
  la a0, CachDong
  ecall
  
  li a7, 4
  la a0, space
  ecall
  
  li a7, 4
  la a0, CachDong
  ecall
