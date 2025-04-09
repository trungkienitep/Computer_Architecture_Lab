.eqv IN_ADDRESS_HEXA_KEYBOARD 0xFFFF0012 
.eqv OUT_ADDRESS_HEXA_KEYBOARD 0xFFFF0014
.eqv SEVENSEG_LEFT 0xFFFF0011 
.eqv SEVENSEG_RIGHT 0xFFFF0010 
.eqv SPEED 500
.data
	color: .word 0x00FF0000, 0x0000FF00, 0x000000FF, 0x00FFFF0F ## R G B Y 
	offset: .word 0, 16,128,144
	base_add: .word 0x10000000
	pixel_len: .word 4
	masks: .word 0x00404040, 0x00404040, 0x00404040, 0x00404040
	scores: .word 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x67
	number_sequence: .word 
.text

main:	
init_variables:
	addi a4, zero, 0 ### STATE OF THE PROGRAM 0 FOR MACHINE AND 1 FOR USER
	la s8, number_sequence ### ADDRESS TO STORE THE SEQUENCE OF COLOR
	la s9, number_sequence ### STARTING ADDRESS OF THE LIST OF SQUARE IDS
	la s7, scores ## USER SCORES

machine_code_section:
##always push a new value to the stack in the machine_code_section
	li a7, 42
	li a0, 0
	li a1, 4
	ecall
	addi a0,a0, 1
	sw a0, 0(s8)
	addi s8, s8, 4
	addi a5, s9, 0
	machine_loop:
### set bit to 0 to prevent human_code_section
	addi a4,zero,0
	beq a5, s8, end_machine_loop
	lw a0, 0(a5)
	jal set_highlight_color
	jal display_all_color
	li a7, 32
	li a0, SPEED
	ecall
	addi a0, a0, 5
	jal set_highlight_color
	jal display_all_color
	li a7, 32
	li a0, SPEED
	ecall
	addi a5,a5, 4
	j machine_loop
end_machine_loop:
	addi a2, s9, 0
	addi a4,zero, 1
	j human_code_section

human_code_section:
enable_keyboard_interrupt:
	la s11, handler
	csrrs zero, utvec, s11
	li s10, 0x100
	csrrs zero, uie, s10 
	csrrsi zero, ustatus, 0x1 
	li s10, IN_ADDRESS_HEXA_KEYBOARD
	li t3, 0x80 
	sb t3, 0(s10)
human_inner_loop:
	beqz a4, increase_segment_display
	j human_inner_loop

increase_segment_display:
	addi s7,s7,4
	li t4, SEVENSEG_RIGHT
	lw s6, 0(s7)
	sb s6, 0(t4)
	li t4, SEVENSEG_LEFT
	addi s6, zero, 0
	sb s6, 0(t4)
	j machine_code_section
	
set_highlight_color:
	addi sp, sp, -16
	sw ra, 12(sp)
	sw a0, 8(sp)
	sw s5, 4(sp)
	sw a7, 0(sp)
### RESET hightlight array ( to all be dim )
	lui a7, 0x00404
	addi a7, a7, 0x040    
	la s5, masks
	sw a7, 0(s5)
	sw a7, 4(s5)
	sw a7, 8(s5)
	sw a7, 12(s5)
### SET highlight color ( set 1 square to be highlighted ) 
	addi a7, zero, 0xFFFFFFFF
	addi a0, a0, -1
	slli a0,a0, 2
	la s5, masks
	add s5, s5, a0
	sw a7, 0(s5)
	lw a7, 0(sp)
	lw s5, 4(sp)
	lw a0, 8(sp)
	lw ra, 12(sp)
	addi sp,sp, 16
	jr ra
	
display_all_color:
	addi sp, sp, -40
	sw a0, 36(sp)
	sw ra, 32(sp)
	sw s0, 28(sp)
	sw s1, 24(sp)
	sw s2, 20(sp)
	sw s3, 16(sp)
	sw s4, 12(sp)
	sw s5, 8(sp)
	sw t5, 4(sp)
	sw t6, 0(sp)

	la s3, color ### LOAD the color
	la s4, offset ### load the offset
	la s5, masks 
	addi t5, zero, 0
	addi t6, zero, 4
init_loop:
	beq t5, t6, exit_init_loop
	lw s0, 0(s3)
	lw t3, 0(s4)
	lw s1, 0(s5)  ### load the mask ( signify the intensity of color )
	lw s2, base_add
	add s2, s2, t3
	jal display_color
	addi t5, t5, 1
	addi s3,s3, 4
	addi s4, s4, 4
	addi s5,s5,4
	j init_loop
	
exit_init_loop:
	lw t6, 0(sp)
	lw t5, 4(sp)
	lw s5, 8(sp)
	lw s4, 12(sp)
	lw s3, 16(sp)
	lw s2, 20(sp)
	lw s1, 24(sp)
	lw s0, 28(sp)
	lw ra, 32(sp)
	lw a0, 36(sp)
	addi sp, sp, 40
	jr ra
	
display_color:
	addi sp, sp, -36
	sw a0, 32(sp)
	sw s2, 28(sp)
	sw ra, 24(sp)
	sw t3, 20(sp)
	sw t2, 16(sp)
	sw t1, 12(sp)
	sw t0, 8(sp)
	sw s1, 4(sp)
	sw s0, 0(sp)
		
	and s0,s0,s1 ## appli mask 
	addi t2, zero, 0x0  ### loop for column
	addi t3, zero, 0x4
	
display_column:
	beq t2,t3, end_display_color
	addi t0, zero, 0x0 ## loop for row
	addi t1, zero, 0x4
	
display_row:
	beq t0, t1, end_display_row
	sw s0, 0(s2)
	addi s2, s2, 0x4
	addi t0,t0, 1
	j display_row
	
end_display_row:
	addi t2, t2, 0x1
	addi s2, s2, 0x10
	j display_column
		
end_display_color:
	lw s0, 0(sp)
	lw s1, 4(sp)
	lw t0, 8(sp)
	lw t1, 12(sp)
	lw t2, 16(sp)
	lw t3, 20(sp)
	lw ra, 24(sp)
	lw s2, 28(sp)
	lw a0, 32(sp)
	addi sp,sp, 36
	jr ra

handler:
disable_user_interrupt:
	li s10, 0x100            
	csrrc zero, uie, s10    
	csrrci zero, ustatus, 0x1 
save_context:
	beqz a4, handler_exit
	addi sp, sp, -28
	sw a1, 0(sp)
	sw a7, 4(sp)
	sw t1, 8(sp)
	sw t2, 12(sp)
	sw a0, 16(sp)
	sw t5, 20(sp)
	sw t6, 24(sp)
get_user_input:
	li t1, IN_ADDRESS_HEXA_KEYBOARD
	addi t2, zero, 0x81
	sb t2, 0(t1) # Must reassign expected row
	li t1, OUT_ADDRESS_HEXA_KEYBOARD
	lb a1, 0(t1)
	
	andi a1, a1, 0xF0
	srli a1, a1, 4
	addi a0,zero,0
	
count_loop:
	beq a1, zero, end_count
	addi a0, a0, 1
	srli a1, a1, 1
	j count_loop
	
end_count:
	addi a1, a0, 0
	jal set_highlight_color
	jal display_all_color
	li a7, 32
	li a0, SPEED
	ecall
	addi a0, a0, 5
	jal set_highlight_color
	jal display_all_color
	li a7, 32
	li a0, SPEED
	ecall
	lw t5, 0(a2)
	xor t6, a1, t5
	bnez t6, exit
	addi a2,a2, 4
	beq a2, s8, next_puzzle
	
end_check:
	lw a1, 0(sp)
	lw a7, 4(sp)
	lw t1, 8(sp)
	lw t2, 12(sp)
	lw a0, 16(sp)
	lw t5, 20(sp)
	lw t6, 24(sp)
	addi sp, sp, 28
	j handler_exit
	
next_puzzle:
	addi a4, zero, 0
	lw a1, 0(sp)
	lw a7, 4(sp)
	lw t1, 8(sp)
	lw t2, 12(sp)
	lw a0, 16(sp)
	lw t5, 20(sp)
	lw t6, 24(sp)
	addi sp, sp, 28
		
    	li s10, 0x100            
    	csrrs zero, uie, s10     

    	csrrsi zero, ustatus, 0x1 
    	li a7, 32
	li a0, SPEED
	ecall
	j increase_segment_display
	
handler_exit:
    	li s10, 0x100            
    	csrrs zero, uie, s10      
   	csrrsi zero, ustatus, 0x1 
	uret
exit:
	addi s7, zero, 0xFF
	li t4, SEVENSEG_RIGHT
	li t5, SEVENSEG_LEFT
	sb s7, 0(t4)
	sb s7, 0(t5)








