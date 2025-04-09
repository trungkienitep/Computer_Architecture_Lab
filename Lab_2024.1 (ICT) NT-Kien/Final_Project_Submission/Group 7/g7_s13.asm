.eqv MONITOR_SCREEN 0x10010000 # Start address of the bitmap display
.eqv RED 0x00FF0000 # Common color values
.eqv LIGHTER_RED 0x00FF8080
.eqv GREEN 0x0000FF00
.eqv LIGHTER_GREEN 0x0080FF80
.eqv BLUE 0x000000FF
.eqv LIGHTER_BLUE 0x008080FF
.eqv YELLOW 0x00FFFF00
.eqv LIGHTER_YELLOW 0x00FFFF80
.eqv IN_ADDRESS_HEXA_KEYBOARD 0xFFFF0012
.eqv OUT_ADDRESS_HEXA_KEYBOARD 0xFFFF0014
.data
X: .space 16
mang: .space 400
string: .asciz "Round win!"
nline: .asciz "\n"
string2: .asciz "You lose!"
.text 
set_up_program:
 li a0, MONITOR_SCREEN # Load address of the display
 li t0, RED 
 sw t0, 0(a0) 
 li t0, GREEN 
 sw t0, 4(a0) 
 li t0, BLUE 
 sw t0, 8(a0) 
 li t0, YELLOW 
 sw t0, 12(a0)
 li t5, 0

 round:	
 la s6, mang		
 addi t5, t5, 1
 add t4, zero, t5
 # Light up a number of random buttons (according to round)
 display:
 beq t4, zero, continue
 li a1, 4
 li a7, 42
 ecall
 beq a0, zero, call_subroutine0   # If a0 == 0, call subroutine0
 li t0, 1
 beq a0, t0, call_subroutine1     # If a0 == 1, call subroutine1
 li t0, 2
 beq a0, t0, call_subroutine2     # If a0 == 2, call subroutine2
 li t0, 3
 beq a0, t0, call_subroutine3
 # Continue on let player press the buttons
continue:
 add s4, zero, t5
 la s6, mang
 loop:
 li t1, IN_ADDRESS_HEXA_KEYBOARD 
 li t2, OUT_ADDRESS_HEXA_KEYBOARD 
 li t3, 0x01 # check row 4 with key 0, 1, 2, 3
 lw s7, 0(s6)         
 addi s6, s6, 4       
polling: 
    sb t3, 0(t1)   
    lb a0, 0(t2)   
    
    beq s7, a0, match 
    beq a0, zero, polling
    j exit         
match:
    addi s4, s4, -1
sleep: 
 li a0, 100 # sleep 100ms
 li a7, 32
 ecall
 li a0, 0
 bne s4, zero, loop
Complete_a_round: 
li a7, 4
la a0, string
ecall
la a0, nline
li a7, 4
ecall
li a0, 0
j round
exit:
la a0, string2
li a7, 4
ecall
li a7, 10
ecall
# Subroutine 0: Draw RED color at address MONITOR_SCREEN
call_subroutine0:
    li a0, MONITOR_SCREEN
    li t0, LIGHTER_RED
    sw t0, 0(a0)      # Store RED color at the first pixel
    li t1, 1000000      # Set counter for delay
    li a0, 1000 # sleep 100ms
    li a7, 32
    ecall
    # Change to Yellow after delay
    li a0, MONITOR_SCREEN
    li t0, RED
    sw t0, 0(a0)
    li t1, 0x11
    sw t1, 0(s6)         # Đẩy giá trị màu vào stack
    addi s6, s6, 4      # Giảm stack pointer để tạo không gian
    addi t4, t4, -1
    j display            # Return

# Subroutine 1: Draw GREEN color at address MONITOR_SCREEN + 4
call_subroutine1:
    li a0, MONITOR_SCREEN
    li t0, LIGHTER_GREEN
    sw t0, 4(a0)      # Store GREEN color at the second pixel
    li t1, 1000000      # Set counter for delay
    li a0, 1000 # sleep 100ms
    li a7, 32
    ecall
    # Change to Yellow after delay
    li a0, MONITOR_SCREEN
    li t0, GREEN
    sw t0, 4(a0)
    li t1, 0x21
    sw t1, 0(s6)         # Đẩy giá trị màu vào stack
    addi s6, s6, 4      # Giảm stack pointer để tạo không gian
    addi t4, t4, -1
    j display            # Return

# Subroutine 2: Draw BLUE color at address MONITOR_SCREEN + 8
call_subroutine2:
    li a0, MONITOR_SCREEN
    li t0, LIGHTER_BLUE
    sw t0, 8(a0)      # Store BLUE color at the third pixel
    li t1, 1000000      # Set counter for delay
    li a0, 1000 # sleep 100ms
    li a7, 32
    ecall
    # Change to Yellow after delay
    li a0, MONITOR_SCREEN
    li t0, BLUE
    sw t0, 8(a0)
    li t1, 0x41
    sw t1, 0(s6)         # Đẩy giá trị màu vào stack
    addi s6, s6, 4      # Giảm stack pointer để tạo không gian
    addi t4, t4, -1
    j display            # Return
# Subroutine 3: Draw BLUE color at address MONITOR_SCREEN + 12
call_subroutine3:
    li a0, MONITOR_SCREEN
    li t0, LIGHTER_YELLOW
    sw t0, 12(a0)      # Store YELLLOW color at the third pixel
    # Delay loop (simulate 1 second)
    li t1, 1000000      # Set counter for delay
    li a0, 1000 # sleep 100ms
    li a7, 32
    ecall
    # Change to Yellow after delay
    li a0, MONITOR_SCREEN
    li t0, YELLOW
    sw t0, 12(a0)         # Update pixel to YELLOW
    li t1, 0xffffff81
    sw t1, 0(s6)         # Đẩy giá trị màu vào stack
    addi s6, s6, 4      # Giảm stack pointer để tạo không gian
    addi t4, t4, -1
    j display 