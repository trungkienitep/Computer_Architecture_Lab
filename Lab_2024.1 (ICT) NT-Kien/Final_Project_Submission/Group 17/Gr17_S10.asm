.eqv IN_ADDRESS_HEXA_KEYBOARD 0xFFFF0012 
.eqv OUT_ADDRESS_HEXA_KEYBOARD 0xFFFF0014 
.eqv SEVENSEG_LEFT 0xFFFF0011         # Address of the LED on the left 
# Bit 0 = segment a 
# Bit 1 = segment b 
# ... 
# Bit 7 = dot sign 
.eqv SEVENSEG_RIGHT 0xFFFF0010        # Address of the LED on the right 
.data 
password: .byte 1, 2, 3, 4	       # Mật khẩu ban đầu 
buffer_password: .space 32 
len: .word 4 
buffer: .space 32                     # Lưu mật khẩu tối đa 16 ký tự 
index: .word 0                        # Chỉ số hiện tại trong buffer, nơi lưu mật khẩu nhập vào  
wrong_attempts: .word 0               # Biến đếm số lần nhập sai mật khẩu 
msg_enter_password: .asciz "Please enter your password:\n" 
msg_unlock_success: .asciz "Unlock successful! Welcome.\n" 
msg_enter_old_password: .asciz "Please enter your old password:\n" 
msg_enter_new_password: .asciz "Please enter your new password:\n" 
msg_password_updated: .asciz "Password has been successfully updated.\n" 
msg_password_wrong: .asciz "Incorrect password. Please try again.\n" 
msg_lock_suspended: .asciz "Too many incorrect attempts. Lock is suspended for 1 minute.\n" 
msg_press_A_to_change: .asciz "Press A to change the password.\n" 
msg_short_password: .asciz "Password is too short. It must be at least 4 characters long.\n" 
.text 
main: 
    li t1, IN_ADDRESS_HEXA_KEYBOARD   # Input address for row assignment 
    li t2, OUT_ADDRESS_HEXA_KEYBOARD  # Output address for reading key pressed 
start: 
    la s0, buffer                     # Điểm bắt đầu của buffer 
    la s1, index                      # Địa chỉ lưu chỉ số 
loop_main: 
    # Display the message to enter the password 
    la a0, msg_enter_password 
    jal print_message 
    # Read and check password
    jal READ_PASSWORD 
    jal CHECK_PASSWORD 
    # If password is correct, show LED 
    beqz a0, handle_password_incorrect  # Nếu a0 = 0, mật khẩu sai 
    la t6, wrong_attempts 
    sw zero, 0(t6)                      # Khôi phục số lần nhập sai về 0 
    la a0, msg_unlock_success 
    jal print_message 
    jal LED_ON 
    la a0, msg_press_A_to_change 
    jal print_message 
    j wait_for_A 
end_main: 
    li a7, 10 
    ecall 
handle_password_incorrect: 
    la t6, wrong_attempts 
    lw t4, 0(t6) 
    addi t4, t4, 1 
    sw t4, 0(t6) 
    la a0, msg_password_wrong 
    jal print_message 
    # Nếu đã nhập sai quá 3 lần, tạm ngưng chương trình 
    li t6, 3 
    bge t4, t6, lock_suspended 
    jal LED_OFF 
    j loop_main 
lock_suspended: 
    # Hiển thị thông báo tạm ngưng khóa 
    la a0, msg_lock_suspended 
    jal print_message 
# Tạm dừng mọi nút bấm trong 1 phút (60 giây) 
wait_1_minute: 
    li a0, 60000                      # Giả lập thời gian đợi 1 phút  
    li a7, 32 
    ecall 
    # Sau 1 phút, khôi phục lại số lần nhập sai 
    la t6, wrong_attempts 
    sw zero, 0(t6) 
    j loop_main 
print_message: 
    addi sp, sp, -4 
    sw a0, 0(sp)                     # Lưu giá trị của a0 (địa chỉ chuỗi) 
    li a7, 4                         # Syscall: Print string 
    ecall                            # In chuỗi 
    lw a0, 0(sp) 
    addi sp, sp, 4 
    jr ra   
back_to_program: 
    jr ra 
# --------------------------------------------------------------- 
# Function LED_ON: Bật LED (Hiển thị tất cả các segment) 
# --------------------------------------------------------------- 
LED_ON: 
    li t0, SEVENSEG_LEFT              # Địa chỉ LED trái 
    li a0, 0x7F                       # LED = 8 (Hiển thị tất cả các segment) 
    sb a0, 0(t0)                      # Ghi giá trị vào LED trái 
    li t0, SEVENSEG_RIGHT             # Địa chỉ LED phải 
    li a0, 0x7F                       # LED = 8 (Hiển thị tất cả các segment) 
    sb a0, 0(t0)                      # Ghi giá trị vào LED phải 
    jr ra                             # Quay lại gọi hàm 
# --------------------------------------------------------------- 
# Function LED_OFF: Tắt LED (Tắt tất cả các segment) 
# --------------------------------------------------------------- 
LED_OFF: 
    li t0, SEVENSEG_LEFT              # Địa chỉ LED trái 
    li a0, 0x00                       # Tắt LED (Tất cả các segment = 0) 
    sb a0, 0(t0)                      # Ghi giá trị vào LED trái 
    li t0, SEVENSEG_RIGHT             # Địa chỉ LED phải 
    li a0, 0x00                       # Tắt LED (Tất cả các segment = 0) 
    sb a0, 0(t0)                      # Ghi giá trị vào LED phải 
    jr ra                             # Quay lại gọi hàm 
# --------------------------------------------------------------- 
# Function READ_PASSWORD : Read password input from keypad 
# --------------------------------------------------------------- 
READ_PASSWORD: 
    li t5, 0x0 
    la s0, buffer 
    la s1, index 
    sw t5, 0(s1) 
loop: 
    li t3, 0x1                        # Quét từ row 0x1 (row đầu tiên) 
scan_rows: 
    sb t3, 0(t1)                      # Gán giá trị hàng hiện tại 
    lb a0, 0(t2)                      # Đọc mã nút bấm 
    beqz a0, next_row                 # Không có nút nào được bấm -> kiểm tra hàng tiếp theo 
    li t4, 0x88                       # Kiểm tra nếu nút bấm là F 
    andi a1, a0, 0xFF 
    beq a1, t4, back_to_program       # Nếu nút F được bấm, quay lại luồng chương trình để kiểm tra mật khẩu 
    addi sp, sp, -4 
    sw ra, 0(sp) 
    jal decode 
    lw ra, 0(sp) 
    addi sp, sp, 4 
    # Kiểm tra nếu mã phím không hợp lệ 
    li t4, 0xFF 
    beq a0, t4, invalid_key           # Nếu a0 = 0xFF, gọi đến nhãn invalid_key 
    sb a0, 0(s0)                      # Lưu mã nút bấm vào buffer 
    addi s0, s0, 1                    # Tăng địa chỉ buffer 
    lw t5, 0(s1)                      # Đọc chỉ số hiện tại 
    addi t5, t5, 1                    # Tăng chỉ số 
    sw t5, 0(s1)                      # Lưu lại chỉ số mới  
    addi sp, sp, -4 
    sw ra, 0(sp) 
    jal print_number 
    lw ra, 0(sp) 
    addi sp, sp, 4 
    sb zero, 0(t2) 
    li a0, 100                        # Sleep 100ms (debounce) 
    li a7, 32 
    ecall 
next_row: 
    slli t3, t3, 1                    # Chuyển sang row tiếp theo (0x1 -> 0x2 -> 0x4 -> 0x8) 
    li t4, 0x10                       # Hết tất cả các row (sau 0x8) 
    blt t3, t4, scan_rows             # Tiếp tục quét nếu còn row 
    j loop                            # Quay lại vòng lặp chính 
decode:                               # Chuyển đổi số nhập vào từ vị trí nhận được khi nhập 
    andi a1, a0, 0xFF 
    li t4, 0x11 
    li t6, 0x0                        
    beq a1, t4, save 
    li t4, 0x21 
    li t6,0x1                       	 
    beq a1, t4, save 
    li t4, 0x41  
    li t6, 0x2                       
    beq a1, t4, save 
    li t4, 0x81   
    li t6, 0x3                       
    beq a1, t4, save 
    li t4, 0x12    
    li t6, 0x4       
    beq a1, t4, save 
    li t4, 0x22 
    li t6, 0x5         
    beq a1, t4, save 
    li t4, 0x42  
    li t6, 0x6           
    beq a1, t4, save 
    li t4, 0x82 
    li t6, 0x7           
    beq a1, t4, save 
    li t4, 0x14 
    li t6, 0x8             
    beq a1, t4, save 
    li t4, 0x24 
    li t6, 0x9 
    beq a1, t4, save 
    # Nếu không khớp bất kỳ phím nào, trả về 0xFF để báo lỗi 
    li a0, 0xFF                       # Đặt a0 = 0xFF khi không khớp phím nào 
    jr ra                             # Quay lại 
invalid_key: 
    sb zero, 0(t2) 
    j loop 
save:                               
    add a0, zero, t6 
    jr ra 
print_number: 
    addi sp, sp, -4 
    sw a0, 0(sp) 
    li a7, 1                          # Syscall: Print integer 
    ecall                             # In giá trị trong a0 
    # In ký tự xuống dòng 
    li a0, 10                         # Mã ASCII của '\n' 
    li a7, 11                         # Syscall: Print character 
    ecall 
    lw a0, 0(sp) 
    addi sp, sp, 4 
    jr ra 
# --------------------------------------------------------------- 
# Function CHECK_PASSWORD: Compare entered password with stored password 
# --------------------------------------------------------------- 
CHECK_PASSWORD: 
    la s0, buffer                     # Bắt đầu đọc buffer 
    la s1, index                      # Bắt đầu đọc mật khẩu lưu trữ 
    la s2, password 
    lw t5, 0(s1) 
    addi sp, sp, -4 
    sw t5, 0(sp) 
    la t6, len 
    lw t6, 0(t6)                       # Đặt chiều dài mật khẩu tối thiểu 
    bne t5, t6, password_incorrect    # Nếu số ký tự nhập vào khác số kí tự của mật khẩu -> sai 
compare_loop: 
    beqz t5, password_correct         # Nếu không còn ký tự, mật khẩu đúng 
    lb a0, 0(s0)                      # Lấy ký tự từ buffer 
    lb a1, 0(s2)                      # Lấy ký tự từ password 
    bne a0, a1, password_incorrect    # Nếu khác nhau, mật khẩu sai 
    addi s0, s0, 1                    # Tăng địa chỉ buffer 
    addi s2, s2, 1                    # Tăng địa chỉ password 
    addi t5, t5, -1                   # Giảm số lượng ký tự còn lại 
    j compare_loop                    # Quay lại so sánh ký tự tiếp theo 
password_correct: 
    li a0, 1     
    j recover 
password_incorrect: 
    li a0, 0 
    j recover 
recover: 
    lw t5, 0(sp) 
    sw t5, 0(s1) 
    addi sp, sp, 4 
    j back_to_program 
# wait for change password     
wait_for_A: 
    li t3, 0x1                        # Quét từ row 0x1 (row đầu tiên) 
scan_rows_A: 
    sb t3, 0(t1)                        # Gán giá trị hàng hiện tại 
    lb a0, 0(t2)                        # Đọc mã nút bấm 
    beqz a0, next_row_A                 # Không có nút nào được bấm -> kiểm tra hàng tiếp theo 
    li t4, 0x44                         # Mã phím A 
    andi a1, a0, 0xFF 
    beq a1, t4, change_password         # Nếu phím A được bấm, xử lý đổi mật khẩu 
    sb zero, 0(t2) 
    li a0, 100                        # Sleep 100ms (debounce) 
    li a7, 32 
    ecall 
next_row_A: 
    slli t3, t3, 1                      # Chuyển sang hàng tiếp theo 
    li t4, 0x10                         # Hết tất cả các hàng 
    blt t3, t4, scan_rows_A             # Tiếp tục quét nếu còn hàng 
    j wait_for_A                        # Quay lại quét hàng đầu tiên 
change_password: 
    # Chuyển đến hàm đổi mật khẩu 
    jal LED_OFF 
    jal CHANGE_PASSWORD 
    j start                             # Quay lại vòng lặp chính 
# --------------------------------------------------------------- 
# Function CHANGE_PASSWORD: Handle changing the password 
# --------------------------------------------------------------- 
CHANGE_PASSWORD:    
    li a2, 0                            # Số lần nhập sai mật khẩu 
    li a3, 3				 # Cho phép nhập mật khẩu sai tối đa bao nhiêu lần 
    addi sp, sp -4 
    sw ra, 0(sp) 
retry_old_password:  
    # Hiển thị thông báo nhập mật khẩu cũ 
    la a0, msg_enter_old_password 
    jal print_message 
    # Đọc mật khẩu cũ từ người dùng 
    jal READ_PASSWORD 
    # Kiểm tra mật khẩu cũ 
    jal CHECK_PASSWORD 
    beqz a0, change_password_wrong     # Nếu a0 = 0, mật khẩu sai 
update_new_password: 
    # Hiển thị thông báo nhập mật khẩu mới 
    la a0, msg_enter_new_password 
    jal print_message 
    # Đọc mật khẩu mới từ người dùng 
    jal READ_PASSWORD 
    la s0, buffer                     # Địa chỉ của buffer chứa mật khẩu mới 
    la s1, index    
    lw t5, 0(s1)                      # Lấy chiều dài mật khẩu mới từ index 
    li t6, 4 
    blt t5, t6, password_too_short 
    # Lưu mật khẩu mới vào vùng nhớ password            
    la s2, password                   # Địa chỉ của password cũ 
    la t6, len 
    sw t5, 0(t6)                      # Cập nhật chiều dài mới vào len 
copy_new_password: 
    beqz t5, password_updated        # Nếu không còn ký tự, cập nhật xong 
    lb a0, 0(s0)                     # Lấy từng ký tự từ buffer 
    sb a0, 0(s2)                     # Ghi vào vùng nhớ password 
    addi s0, s0, 1                   # Tăng địa chỉ buffer 
    addi s2, s2, 1                   # Tăng địa chỉ password 
    addi t5, t5, -1                  # Giảm số lượng ký tự còn lại 
    j copy_new_password              # Lặp lại cho ký tự tiếp theo 
password_updated: 
    # Hiển thị thông báo mật khẩu đã cập nhật thành công 
    la a0, msg_password_updated 
    jal print_message 
    lw ra, 0(sp) 
    addi sp, sp, 4 
    jr ra 
password_too_short: 
    la a0, msg_short_password       # Hiển thị thông báo mật khẩu quá ngắn 
    jal print_message 
    j update_new_password            # Yêu cầu nhập lại mật khẩu mới 
change_password_wrong: 
    addi a2, a2, 1 
    bge a2, a3, lock_user 
    la a0, msg_password_wrong 
    jal print_message 
    j retry_old_password            # Yêu cầu nhập lại 
lock_user: 
    # Hiển thị thông báo khóa 
    la a0, msg_lock_suspended 
    jal print_message 
    li a0, 60000                      # Giả lập thời gian đợi 1 phút  
    li a7, 32 
    ecall 
    # Sau 1 phút, khôi phục lại số lần nhập sai 
    li a2, 0 
    j retry_old_password            # Yêu cầu nhập lại sau khi hết khóa 
