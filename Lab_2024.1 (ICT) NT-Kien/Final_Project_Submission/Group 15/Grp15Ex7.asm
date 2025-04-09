.data
line1:  .asciz  "                                            ************* \n"
line2:  .asciz  "**************                             *3333333333333*\n"
line3:  .asciz  "*222222222222222*                          *33333******** \n"
line4:  .asciz  "*22222******222222*                        *33333*        \n"
line5:  .asciz  "*22222*      *22222*                       *33333******** \n"
line6:  .asciz  "*22222*        *22222*     *************   *3333333333333*\n"
line7:  .asciz  "*22222*        *22222*   **11111*****111*  *33333******** \n"
line8:  .asciz  "*22222*        *22222*  **1111**      **   *33333*        \n"
line9:  .asciz  "*22222*       *222222*  *1111*             *33333******** \n"
line10: .asciz  "*22222*******222222*   *11111*             *3333333333333*\n"
line11: .asciz  "*2222222222222222*     *11111*              ************* \n"
line12: .asciz  "***************        *11111*                            \n"
line13: .asciz  "      ---               *1111**                           \n"
line14: .asciz  "    / o o \\              *1111****   *****                \n"
line15: .asciz  "    \\   > /               **111111***111*                 \n"
line16: .asciz  "     -----                  ***********    dce.hust.edu.vn\n"

Message0: .string "------------Menu----------\n"
Message1: .string "1. Print with color\n"
Message2: .string "2. Print without color\n"
Message3: .string "3. Change order\n"
Message4: .string "4. Change color\n"
Message5: .string "5. Exit\n"
Message6: .string "Enter choice: "
Message4_1: .string "Enter color for D(0->9): "
Message4_2: .string "Enter color for C(0->9): "
Message4_3: .string "Enter color for E(0->9): "

.text
.globl main
main:
    # Kh?i t?o màu ban ??u
    li t0, 50          # t0: curr D color (ASCII '2' = 50)
    li t1, 49          # t1: curr C color (ASCII '1' = 49)
    li t2, 51          # t2: curr E color (ASCII '3' = 51)

menu:
    # Hi?n th? menu
    la a0, Message0
    li a7, 4
    ecall

    la a0, Message1
    li a7, 4
    ecall

    la a0, Message2
    li a7, 4
    ecall

    la a0, Message3
    li a7, 4
    ecall

    la a0, Message4
    li a7, 4
    ecall

    la a0, Message5
    li a7, 4
    ecall

    la a0, Message6
    li a7, 4
    ecall

    li a7, 5
    ecall
    addi t3, a0, 0     # L?u l?a ch?n vào t3

    # ?i?u h??ng menu
    li t4, 1
    li t5, 2
    li t6, 3
    li s0, 4
    li s1, 5
    beq t3, t4, menu1
    beq t3, t5, menu2
    beq t3, t6, menu3
    beq t3, s0, menu4
    beq t3, s1, end_main
    j menu

menu1:
    # X? lý in dòng có màu
    li t0, 0
    li t1, 16
    la t2, line1
loop1:
    beq t0, t1, menu
    mv a0, t2
    li a7, 4
    ecall
    addi t2, t2, 60
    addi t0, t0, 1
    j loop1

menu2:
	li t0, 0 #i=0
	li t1, 16 #max	=16
	
	la t2,line1 #t2: pointer to character, starting at first character of line1
outer_loop2:
	beq t0, t1, menu #i=16 -> main
	li t3, 0 #j=0
	li t4, 60 #max=60
inner_loop2:
	beq t3, t4, continue_outer_loop2 #j=60 -> continue_outer_loop2
	lb t5, 0(t2) #t5: cur char
	li t6, 48
	li s0, 57
	blt t5, t6, print_char2
	bgt t5, s0, print_char2
	li t5, ' ' #if char is digit, replace it with blank space
print_char2:
	li a7, 11
	mv a0, t5
	ecall
continue_inner_loop2:	
	addi t2, t2, 1 #move to next char
	addi t3, t3, 1 #j=j+1
	j inner_loop2
continue_outer_loop2:
	addi t0, t0, 1  #i=i+1
	j outer_loop2

menu3:
    # Thay ??i th? t? in
    li t0, 0
    li t1, 16
    la t2, line1
loop3:
    beq t0, t1, menu
    sb zero, 22(t2)
    sb zero, 42(t2)
    sb zero, 58(t2)

    li a7, 4
    addi a0, t2, 43
    ecall

    li a7, 11
    li a0, 32          # In kho?ng tr?ng
    ecall

    li a7, 4
    addi a0, t2, 23
    ecall

    li a7, 11
    li a0, 32
    ecall

    li a7, 4
    mv a0, t2
    ecall

    li a7, 11
    li a0, 10          # In xu?ng dòng
    ecall

    # Ph?c h?i
    li t3, 32
    sb t3, 22(t2)
    sb t3, 42(t2)
    li t3, 10
    sb t3, 58(t2)

    addi t0, t0, 1
    addi t2, t2, 60
    j loop3
menu4:
  # Kh?i t?o màu ban ??u
    li s3, 50          # t0: curr D color (ASCII '2' = 50)
    li s4, 49          # t1: curr C color (ASCII '1' = 49)
    li s5, 51          # t2: curr E color (ASCII '3' = 51)

    # X? lý thay ??i màu
enter_D:
    li a7, 4                # Print "Enter color for D"
    la a0, Message4_1
    ecall

    li a7, 5                # Read user input
    ecall
    mv s8, a0               # L?u giá tr? nh?p vào t6
    li s0, 48               # ASCII '0' = 48
    li s1, 57               # ASCII '9' = 57
    blt s8, s0, enter_D     # N?u t6 < '0', nh?p l?i
    bgt s8, s1, enter_D     # N?u t6 > '9', nh?p l?i
enter_C:
    li a7, 4                # Print "Enter color for C"
    la a0, Message4_2
    ecall

    li a7, 5                # Read user input
    ecall
    mv s9, a0               # L?u giá tr? nh?p vào t6
    blt s9, s0, enter_C     # N?u t6 < '0', nh?p l?i
    bgt s9, s1, enter_C     # N?u t6 > '9', nh?p l?i
enter_E:
    li a7, 4                # Print "Enter color for E"
    la a0, Message4_3
    ecall

    li a7, 5                # Read user input
    ecall
    mv s10, a0               # L?u giá tr? nh?p vào t6
    blt s10, s0, enter_E     # N?u t6 < '0', nh?p l?i
    bgt s10, s1, enter_E     # N?u t6 > '9', nh?p l?i
init_menu4:
    li t0, 0                # i = 0
    li t1, 16               # max = 16

    la s2, line1            # s2: con tr? ??n ký t? ??u tiên c?a line1    
outer_loop4:
    beq t0, t1, update_color # N?u i == 16, thoát vòng l?p
    li t3, 0                # j = 0
    li t4, 60               # max = 60 (s? ký t? trên m?i dòng)

inner_loop4:
    beq t3, t4, continue_outer_loop4 # N?u j == 60, thoát vòng l?p trong
    lb t5, 0(s2)           # t5: ký t? hi?n t?i
    
    li s6, 22
    li s7, 42
    blt t3, s6, check_D    # N?u j < 22, thu?c D
    blt t3, s7, check_C    # N?u j < 42, thu?c C
    j check_E              # Ng??c l?i, thu?c E

check_D:
    beq t5, s3, update_D   # N?u ký t? trùng màu D hi?n t?i, c?p nh?t
    j print_char4

check_C:
    beq t5, s4, update_C   # N?u ký t? trùng màu C hi?n t?i, c?p nh?t
    j print_char4

check_E:
    beq t5, s5, update_E   # N?u ký t? trùng màu E hi?n t?i, c?p nh?t
    j print_char4

update_D:
    sb s8, 0(s2)           # L?u màu m?i c?a D vào b? nh?
    mv t5, s8              # C?p nh?t giá tr? ký t? t5
    j print_char4

update_C:
    sb s9, 0(s2)           # L?u màu m?i c?a C vào b? nh?
    mv t5, s9              # C?p nh?t giá tr? ký t? t5
    j print_char4

update_E:
    sb s10, 0(s2)           # L?u màu m?i c?a E vào b? nh?
    mv t5, s10              # C?p nh?t giá tr? ký t? t5
    j print_char4

print_char4:
    li a7, 11              # ecall ?? in ký t?
    mv a0, t5
    ecall

continue_inner_loop4:
    addi s2, s2, 1         # Di chuy?n ??n ký t? ti?p theo
    addi t3, t3, 1         # j = j + 1
    j inner_loop4

continue_outer_loop4:
    addi t0, t0, 1         # i = i + 1
    j outer_loop4

update_color:
    mv t0, s8              # C?p nh?t màu D hi?n t?i
    mv t1, s9              # C?p nh?t màu C hi?n t?i
    mv t2, s10              # C?p nh?t màu E hi?n t?i
    j menu



end_main:
    li a7, 10
    ecall
