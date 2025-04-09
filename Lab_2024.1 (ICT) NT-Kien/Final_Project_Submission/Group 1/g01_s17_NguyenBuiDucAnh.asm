.eqv IN_ADDRESS_HEXA_KEYBOARD 0xFFFF0012
.eqv OUT_ADDRESS_HEXA_KEYBOARD 0xFFFF0014
.eqv SEVENSEG_LEFT  0xFFFF0011
.eqv SEVENSEG_RIGHT 0xFFFF0010

# Seven-segment encoding for digits 0-9
.eqv SEG_0  0x3F
.eqv SEG_1  0x06
.eqv SEG_2  0x5B
.eqv SEG_3  0x4F
.eqv SEG_4  0x66
.eqv SEG_5  0x6D
.eqv SEG_6  0x7D
.eqv SEG_7  0x07
.eqv SEG_8  0x7F
.eqv SEG_9  0x6F

.data
SEG_MAP:    .byte SEG_0, SEG_1, SEG_2, SEG_3, SEG_4, SEG_5, SEG_6, SEG_7, SEG_8, SEG_9
namthuong:  .word 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
namnhuan:   .word 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31

.text

main:
    # Initialize keyboard addresses
    li a5, IN_ADDRESS_HEXA_KEYBOARD    
    li a6, OUT_ADDRESS_HEXA_KEYBOARD   
    
polling:
    # First, calculate and update all time values
    jal calculate_time
    # Check if seconds is 0 to play sound
    beqz s10, minute_alert
    # If seconds is not 0, reset the sound flag
    j check_keypad
    
minute_alert:
    li a7, 31
    li a0, 69
    li a1, 100
    li a2, 7
    li a3, 50
    ecall
    j polling
    
check_keypad:
    # Check row 1
    li t0, 0x01
    sb t0, 0(a5)
    lb t1, 0(a6)
    bne t1, zero, handle_key
    
    # Check row 2
    li t0, 0x02
    sb t0, 0(a5)
    lb t1, 0(a6)
    bne t1, zero, handle_key
    
    j polling  # If no key pressed, continue polling

handle_key:
    # If press 1 (0x21)
    li t0, 0x21
    beq t1, t0, display_hour
    # If press 2 (0x41)
    li t0, 0x41
    beq t1, t0, display_min
    # If press 3 (0xffffff81)
    li t0, 0xffffff81
    beq t1, t0, display_sec
    # If press 4 (0x12)
    li t0, 0x12
    beq t1, t0, display_day
    # If press 5 (0x22)
    li t0, 0x22
    beq t1, t0, display_month
    # If press 6 (0x42)
    li t0, 0x42
    beq t1, t0, display_year
    
    j polling

calculate_time:
    li a7, 30
    ecall
    
    li t1, 1000
    li t2, 2
    li s0, 32
    li s1, 0
    
    fcvt.d.wu fa0, a0, dyn
    fcvt.d.wu fa1, a1, dyn
    fcvt.d.wu ft0, zero, dyn
    fcvt.d.wu ft1, t1, dyn
    fcvt.d.wu ft2, t2, dyn	
    
time_loop:
    beq s1, s0, time_end
    fmul.d fa1, fa1, ft2
    addi s1, s1, 1
    j time_loop		
    
time_end:
    li s7, 25200
    fcvt.d.wu ft7, s7	
    
    fadd.d fa0, fa1, fa0
    fdiv.d fa0, fa0, ft1
    fadd.d fa0, ft7, fa0
    
    
    # Continue with rest of your time calculation code here
    li s0, 60	#So giay / 1 phut hoac so phut 1 gio
    li s1, 3600	#So giay / 1 gio
    li s2, 86400	#So giay / 1 ngay
    li s3, 1461	#So ngay trong nam
    li s4, 30	#So ngay trung binh 1 thang
    li s5, 1970	#Nam tham chieu
    li s6, 13	#So nam nhuan
    li s7 4
    
    fcvt.d.wu fs0, s0	
    fcvt.d.wu fs1, s1
    fcvt.d.wu fs2, s2
    fcvt.d.wu fs3, s3 
    fcvt.d.wu fs4, s4
    fcvt.d.wu fs6, s6
    
    # Calculate year
    fdiv.d ft0, fa0, fs2
    
    fcvt.wu.d s9, ft0		#s9 lưu số ngày (số nguyên) từ 1.1.1970 đến hiện tại
    fcvt.d.wu fs9, s9
    flt.d t0, ft0, fs9
    sub s9, s9, t0
  
    
    fcvt.d.wu fs7, s7 dyn
    fdiv.d fs3, fs3, fs7, dyn
    fdiv.d ft1, ft0, fs3, dyn
    
    fcvt.wu.d t1, ft1, dyn
    
    
    fcvt.d.wu fs9, t1, dyn
    flt.d t0, ft1, fs9
    sub t1, t1, t0 		#t1 chứa số năm tính từ 1.1.1970	
    
    add s5, s5, t1		#s5 chua nam hien tai
    
    # Calculate month
    fcvt.d.wu ft1, t1
    fnmsub.d ft2, ft1, fs3, ft0	
    fdiv.d ft3, ft2, fs4
    fcvt.wu.d t3, ft3		#t3 chua thang hien tai
    
    # Calculate day
    addi t3, t3, -1
    
    li a4, 4
    li s10, 100
    
    rem a2, s5, a4
    rem a3, s5, s10
    
    li t5, 0
    li t0, 0
    la s10, namnhuan
    la s11, namthuong
    
    bne a2, zero, tinhnamthuong
    beq a3, zero, tinhnamthuong
    
looptinhngay:	
    bge t0, t3, calculate_continue
    
    lw t4, 0(s10)
    add t5, t5, t4
    addi s10, s10, 4
    addi t0, t0, 1
    j looptinhngay
    
tinhnamthuong:
    bge t0, t3, calculate_continue
    
    lw t4, 0(s11)
    add t5, t5, t4
    addi s11, s11, 4	
    addi t0, t0, 1
    j tinhnamthuong
    
calculate_continue:
    fcvt.d.wu ft5, t5
    fsub.d  ft6, ft2, ft5
    fcvt.wu.d t6, ft6			#t6 chua ngay hien tai
    addi t6 t6 1
    
    # Calculate hour
    fcvt.d.wu fs9, s9
    fnmsub.d ft2, fs9, fs2, fa0	
    fdiv.d ft0, ft2, fs1
    fcvt.wu.d s8, ft0			#s8 chua gio hien tai
    
    fcvt.d.wu fa1, s8
    flt.d t0, ft0, fa1
    sub s8, s8, t0
    
    # Calculate minute
    fcvt.d.wu fs8, s8
    fnmsub.d ft3, fs8, fs1, ft2	
    fdiv.d ft0, ft3, fs0
    fcvt.wu.d s9, ft0			#s9 chua phut hien tai
    
    fcvt.d.wu fa1, s9
    flt.d t0, ft0, fa1
    sub s9, s9, t0
    
    # Calculate seconds
    fcvt.d.wu fs9, s9
    fnmsub.d ft0, fs9, fs0, ft3	
    fcvt.wu.d s10, ft0			#s10 chua giay hien tai
    
    fcvt.d.wu fa1, s10
    flt.d t0, ft0, fa1
    sub s10, s10, t0
    
    jr ra

display_hour:
    mv t1, s8
    j encode_display

display_min:
    mv t1, s9
    j encode_display

display_sec:
    mv t1, s10
    j encode_display

display_day:
    mv t1, t6
    j encode_display

display_month:
    addi t1, t3, 1      # Add 1 back since we subtracted it earlier
    j encode_display

display_year:
    li a0, 100
    rem t1, s5, a0
    j encode_display

encode_display:
    # Split number into digits and encode for seven-segment display
    li t2, 10
    div t3, t1, t2     # Get tens digit
    rem t4, t1, t2     # Get ones digit

    # Display tens digit on left display
    la t5, SEG_MAP
    add t5, t5, t3
    lb t6, 0(t5)
    li t0, SEVENSEG_LEFT
    sb t6, 0(t0)

    # Display ones digit on right display
    la t5, SEG_MAP
    add t5, t5, t4
    lb t6, 0(t5)
    li t0, SEVENSEG_RIGHT
    sb t6, 0(t0)

    j polling
