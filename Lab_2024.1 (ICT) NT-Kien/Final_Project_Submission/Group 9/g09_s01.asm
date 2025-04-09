# Cac hang so cho man hinh va mau sac
.eqv DISPLAY_ADDRESS 0x10010000  # Dia chi bat dau cua Bitmap Display
.eqv YELLOW 0x00FFFF66
.eqv BACKGROUND 0x00000000

# Cac hang so cho phim
.eqv KEYBOARD_CONTROL 0xFFFF0000
.eqv KEYBOARD_DATA 0xFFFF0004
.eqv KEY_A 0x61  # sang trai
.eqv KEY_D 0x64  # sang phai
.eqv KEY_S 0x73  # xuong duoi
.eqv KEY_W 0x77  # len tren
.eqv KEY_Z 0x78  # giam toc
.eqv KEY_X 0x7a # tang toc
.eqv KEY_ENTER 0x0a  # thoat

# Hang so khac
.eqv MOVE_DISTANCE 10  # Khoang cach di chuyen
.eqv CIRCLE_RADIUS 20  # Ban kinh hinh tron

.data
    coords: .space 512  # Mang luu toa do cac diem

.text
.globl main

main:
    # Khoi tao cac gia tri
    li s0, 256      # x = 256 (toa do x ban dau)
    li s1, 256      # y = 256 (toa do y ban dau)
    li s2, 20       # R = 20 (ban kinh)
    li s3, 512      # Chieu rong man hinh
    li s4, 512      # Chieu cao man hinh
    li s5, YELLOW   # Mau hinh tron
    li s6, MOVE_DISTANCE  # Khoang cach di chuyen
    li s7, 0        # dx (thay doi theo x)
    li s8, 0        # dy (thay doi theo y)
    li s9, 70       # Toc do delay

    # Ve hinh tron ban dau
    jal draw_circle

game_loop:
    # Doc phim
    li t0, KEYBOARD_CONTROL
    lw t1, 0(t0)
    beqz t1, check_bounds
    
    # Doc ma phim
    li t0, KEYBOARD_DATA
    lw t2, 0(t0)
    
    # Xu ly phim
    li t3, KEY_A
    beq t2, t3, move_left
    li t3, KEY_D
    beq t2, t3, move_right
    li t3, KEY_W
    beq t2, t3, move_up
    li t3, KEY_S
    beq t2, t3, move_down
    li t3, KEY_Z
    beq t2, t3, speed_up
    li t3, KEY_X
    beq t2, t3, speed_down
    li t3, KEY_ENTER
    beq t2, t3, exit_program
    j check_bounds

move_left:
    neg s7, s6      # dx = -MOVE_DISTANCE
    li s8, 0        # dy = 0
    j check_bounds

move_right:
    mv s7, s6       # dx = MOVE_DISTANCE
    li s8, 0        # dy = 0
    j check_bounds

move_up:
    li s7, 0        # dx = 0
    neg s8, s6      # dy = -MOVE_DISTANCE
    j check_bounds

move_down:
    li s7, 0        # dx = 0
    mv s8, s6       # dy = MOVE_DISTANCE
    j check_bounds

speed_up:
    addi s9, s9, -10  # Giam delay = tang toc
    j check_bounds

speed_down:
    addi s9, s9, 10   # Tang delay = giam toc
    j check_bounds

check_bounds:
    # Kiem tra bien phai
    add t0, s0, s2    # x + R
    add t0, t0, s7    # + dx
    bge t0, s3, reverse_x
    
    # Kiem tra bien trai
    sub t0, s0, s2    # x - R
    add t0, t0, s7    # + dx
    bltz t0, reverse_x
    
    # Kiem tra bien tren
    sub t0, s1, s2    # y - R
    add t0, t0, s8    # + dy
    bltz t0, reverse_y
    
    # Kiem tra bien duoi
    add t0, s1, s2    # y + R
    add t0, t0, s8    # + dy
    bge t0, s4, reverse_y
    
    j update_position

reverse_x:
    neg s7, s7        # Doi chieu dx
    j update_position

reverse_y:
    neg s8, s8        # Doi chieu dy
    j update_position

update_position:
    # Xoa hinh tron cu
    li s5, BACKGROUND
    jal draw_circle
    
    # Cap nhat vi tri
    add s0, s0, s7    # x += dx
    add s1, s1, s8    # y += dy
    
    # Ve hinh tron moi
    li s5, YELLOW
    jal draw_circle
    
    # Delay
    mv a0, s9
    li a7, 32
    ecall
    
    j game_loop

draw_circle:
    # Luu ra
    addi sp, sp, -4
    sw ra, 0(sp)
    
    # Bresenham circle algorithm
    li t0, 0          # x = 0
    mv t1, s2         # y = r
    li t2, 3          # d = 3
    sub t3, t2, s2    # d = 3 - 2r
    sub t3, t3, s2    
    
draw_loop:
    bgt t0, t1, draw_end   # while x <= y
    
    # Plot 8 points
    # Tren phai
    add a0, s0, t0    # x0 + x
    add a1, s1, t1    # y0 + y
    jal plot_pixel_safe
    
    add a0, s0, t1    # x0 + y
    add a1, s1, t0    # y0 + x
    jal plot_pixel_safe
    
    # Tren trai
    sub a0, s0, t0    # x0 - x
    add a1, s1, t1    # y0 + y
    jal plot_pixel_safe
    
    sub a0, s0, t1    # x0 - y
    add a1, s1, t0    # y0 + x
    jal plot_pixel_safe
    
    # Duoi phai
    add a0, s0, t0    # x0 + x
    sub a1, s1, t1    # y0 - y
    jal plot_pixel_safe
    
    add a0, s0, t1    # x0 + y
    sub a1, s1, t0    # y0 - x
    jal plot_pixel_safe
    
    # Duoi trai
    sub a0, s0, t0    # x0 - x
    sub a1, s1, t1    # y0 - y
    jal plot_pixel_safe
    
    sub a0, s0, t1    # x0 - y
    sub a1, s1, t0    # y0 - x
    jal plot_pixel_safe
    
    # Cap nhat cac bien
    bgez t3, adjust_d_positive
    
    # d < 0
    slli t4, t0, 2    # 4x
    addi t4, t4, 6    # 4x + 6
    add t3, t3, t4    # d += 4x + 6
    j continue_draw
    
adjust_d_positive:
    # d >= 0
    slli t4, t0, 2    # 4x
    sub t4, t4, t1    # 4x - y
    sub t4, t4, t1    # 4x - 2y
    sub t4, t4, t1    # 4x - 3y
    sub t4, t4, t1    # 4x - 4y
    addi t4, t4, 10   # 4x - 4y + 10
    add t3, t3, t4    # d += 4x - 4y + 10
    addi t1, t1, -1   # y--
    
continue_draw:
    addi t0, t0, 1    # x++
    j draw_loop
    
draw_end:
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

plot_pixel_safe:
    # Kiem tra bien
    bltz a0, plot_end     # x < 0
    bge a0, s3, plot_end  # x >= width
    bltz a1, plot_end     # y < 0
    bge a1, s4, plot_end  # y >= height
    
    # Tinh offset
    mul t6, a1, s3    # y * width
    add t6, t6, a0    # + x
    slli t6, t6, 2    # * 4 bytes/pixel
    li t4, DISPLAY_ADDRESS
    add t6, t6, t4
    
    # Ve pixel
    sw s5, 0(t6)
    
plot_end:
    ret

exit_program:
    li a7, 10
    ecall
