.data
prompt: .asciz "Nhap chuoi ky tu : "
# ASCII into hexa
hex: .byte '0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'
disk1: .space 4		
disk2: .space 4
disk3: .space 4
array: .space 32	                        # Store parities (results for data XOR)
string: .space 5000	                        # Input string
enter: .asciz "\n"
error_length: .asciz "Do dai chuoi khong hop le! Nhap lai.\n"
disk: .asciz  "      Disk 1                Disk 2                 Disk 3\n"
msg1: .asciz   "-----------------      ----------------       ----------------\n"
msg2: .asciz   "|     "
msg3: .asciz   "      |      "
msg4: .asciz  "[[ "
msg5: .asciz "]]       "
comma: .asciz ","
message: .asciz "Try another string???"

.text
main:	
	la s1, disk1				# s1 = address of disk 1 
	la s2, disk2				# s2 = address of disk 2	
	la s3, disk3				# s3 = address of disk 3
	la a2, array				# Address of parities
	
	j input
	nop
	
input:	li a7, 4				# Print " Nhap chuoi ky tu"
	la a0, prompt			
	ecall
	
	li a7, 8				# Get string 
	la a0, string					
	li a1, 1000
	ecall
						
	mv s0, a0				# s0 = address of input string
	
	li a7, 4				# Print " Disk1 Disk2 Disk3"
	la a0, disk
	ecall
	li a7, 4				# Print " ------ "
	la a0, msg1
	ecall

#------------------ Check whether input string's length is multiple of 8 ---------------------------------
length: 
	addi t3, zero, 0 			# t3 = length
	addi t0, zero, 0 			# t0 = index

check_char: 					
# Check \n?
	add t1, s0, t0 			        # t1 = address of string[i]
	lb t2, 0(t1) 				# t2 = string[i]
	li s4, 10                               # '\n' = 10 ASCII
	beq t2, s4, test_length 		# string[i] = '\n' 
	nop
	
	addi t3, t3, 1 			        # length++
	addi t0, t0, 1			        # index++
	j check_char				
	nop
	
test_length: 
	mv t5, t3				# t5 = string length
	beq t0,zero,error 			# If only '\n' -> error
	
	andi t1, t3, 0x0000000f		        # t1 = last byte
	bne t1, zero, test1			# last byte = 0 or =8 --> multiple of 8
	j block1			        # last byte != 0 and != 0 --> error
	nop
test1:	li s11, 8
        beq t1, s11, block1			
	j error
	nop
	
error:	li a7, 4				# Print "Do dai chuoi khong hop le! Nhap lai.\n"
	la a0, error_length
	ecall
	j input					# Back to input
	nop




HEX: 
#-------------------------  Get parities  -------------------------------------------------------------------
# Co 1 dau vao la s8 chua parity string roi chuyen tu ascii sang hexa
	li t4, 7				# t4 = 7
	
loopH:	
	blt t4, zero, endloopH			# t4 < 0  -> endloop
	slli s6, t4, 2				# s6 = t4*4
	srl a0, s8, s6			        # a0 = s8 >> s6
	andi a0, a0, 0x0000000f 		# Get the last byte of a0
	la s7, hex 				# s7 = adrress of hex
	add s7, s7, a0 			        # s7 = s7 + a0
	li a4, 1
	bgt t4, a4, nextc			# if t4 > 1 , jump to nextC
	lb a0, 0(s7) 				# Print hex[a0]
	li a7, 11						
	ecall


nextc:	addi t4,t4,-1				# t4 --
	j loopH					
	nop

endloopH: 
	jr ra
	nop
	

#------------------------------ RAID5 SIMULATION------------------------------------
RAID5:
# Block 1 : byte parity is stored in disk 3
# Block 2 : byte parity is stored in disk 2
# Block 3 : byte parity is stored in disk 1
block1:	 		
# Funtion block1: First 2 4-byte blocks are stored in disk1, disk2; parity is stored in disk3
	addi t0, zero, 0			
	addi s9, zero, 0				
	addi s8, zero, 0
	la s1, disk1				# s1 = adress of disk1
	la s2, disk2				# s2 = address of disk2
	la a2, array				# 
	
print11:					
	li a7, 4				# print msg2 : "|     " 
	la a0, msg2			
	ecall
	
# Example: DCE. and  ****
b11:	
# Store DCE. into disk1					
	lb t1, (s0)				# t1 = first value of input string 			
	addi t3, t3, -1			        # t3 = length -1
	sb t1, (s1)				# store t1 into disk1  	
b12:	
# Store **** ịnto disk2
	addi s5, s0, 4				# s5 = s0 + 4
	lb t2, (s5)				# t2 = string[5]
	addi t3, t3, -1			        # t3 = t3  - 1 
	sb t2, (s2)				# store t2 into disk2
b13:	
# Store XOR result into disk3
	xor a3, t1, t2			        # a3 = t1 xor t2
	sw a3, (a2)				# Store a3 into a2
	addi a2, a2, 4			        # Parity string
	addi t0, t0, 1			        # Next char
	addi s0, s0, 1			        # Eliminate considered char, eg : "D"
	addi s1, s1, 1			        # Address of disk 1 +1
	addi s2, s2, 1			        # Address of disk 2 +1 
	li a6, 3                                # a6 = 3
	bgt t0, a6, reset			# 4 byte are considered --> reset disk
	j b11
	nop
reset:	
# Reset disks
	la s1, disk1				
	la s2, disk2				
	
print12: 			
# Print disk1
	lb a0, (s1)			# Print each char in disk1		
	li a7, 11		
	ecall
	addi s9, s9, 1		
	addi s1, s1, 1
	bgt s9, a6, next11		# Print 4 times --> end priting disk1 
	j print12
	nop
	
next11:	 
# Prepair for printing disk2    "|         |"			
	li a7, 4			
	la a0, msg3
	ecall
	li a7, 4
	la a0, msg2
	ecall
	
print13:			
# Print disk2
	lb a0, (s2)
	li a7, 11
	ecall
	addi s8, s8, 1
	addi s2, s2, 1
	bgt s8, a6, next12		# Print 4 times --> end printing disk2
	j print13				
	nop
	
next12:				
# Prepair for printing disk3
	li a7, 4										
	la a0, msg3
	ecall
	li a7, 4
	la a0, msg4
	ecall
	la a2, array			# a2 = address of parity string[i]
	addi s9, zero, 0		# s9 = i
	
print14:				
# Convert parity string --> ASCII and print
	lb s8, (a2)			# s8 = adress of parity string[i]
	jal HEX
	nop
	li a7, 4			
	la a0, comma			# Print ','
	ecall
	
	addi s9, s9, 1		# Parity string's index +1
	addi a2, a2, 4		# Skip considered parity string 
	li a5, 2
	bgt s9, a5, endisk1		# Print first 3 parities with ','
	j print14	
endisk1:				# Print last parity --> end printing disk3
	lb s8, (a2)			
	jal HEX
	nop
	li a7, 4
	la a0, msg5
	ecall
	
	li a7, 4			# Next line, new block
	la a0, enter
	ecall
	beq t3, zero, exit1		# If string length = 0 --> exit
	j block2			# else --> block2
	nop
	
#----------------------------------------
block2:	
# Funtion block2: Next 2 4-byte blocks are stored in disk1, disk3; parity is stored in disk2
	la a2, array				
	la s1, disk1				
	la s3, disk3				
	addi s0, s0, 4
	addi t0, zero, 0
		
print21:					
# print "|     "
	li a7, 4
	la a0, msg2
	ecall

# Example: ABCD and 1234
b21:	
# Store 4 bytes into disk1
	lb t1, (s0)				
	addi t3, t3, -1			
	sb t1, (s1)				
b23:	
# Store next 4 bytes into disk3
	addi s5, s0, 4
	lb t2, (s5)
	addi t3, t3, -1
	sb t2, (s3)
	
b22:	
# Store XOR result into disk2
	xor a3, t1, t2
	sw a3, (a2)
	addi a2, a2, 4
	addi t0, t0, 1
	addi s0, s0, 1
	addi s1, s1, 1
	addi s3, s3, 1
	bgt t0, a6, reset2
	j b21
	nop
reset2:	
# Reset disks
	la s1, disk1			
	la s3, disk3			
	addi s9, zero, 0		# Index
	
print22:
	lb a0, (s1)
	li a7, 11
	ecall
	addi s9, s9, 1
	addi s1, s1, 1
	bgt s9, a6, next21
	j print22
	nop
	
next21:		
	li a7, 4
	la a0, msg3
	ecall
	la a2, array
	addi s9, zero, 0
	li a7, 4
	la a0, msg4
	ecall	
	
print23:	
	lb s8, (a2)
	jal HEX				
	nop
	li a7, 4
	la a0, comma		
	ecall
	addi s9, s9, 1
	addi a2, a2, 4
	bgt s9, a5, next22	
	j print23
	nop
		
next22:		 
	lb s8, (a2)
	jal HEX
	nop
	
	li a7, 4
	la a0, msg5
	ecall
	
	li a7, 4
	la a0, msg2
	ecall
	addi s8, zero, 0
	
print24:	
	lb a0, (s3)
	li a7, 11
	ecall
	addi s8, s8, 1
	addi s3, s3, 1
	bgt s8, a6, endisk2
	j print24
	nop

endisk2:	
	li a7, 4
	la a0, msg3
	ecall
	li a7, 4
	la a0, enter
	ecall
	beq t3, zero, exit1
	
#--------------------------------
block3:	
# Funtion block2: Next 2 4-byte blocks are stored in disk2, disk3; parity is stored in disk1
	la a2, array						
	la s2, disk2			
	la s3, disk3
	addi s0, s0, 4			
	addi t0, zero, 0			
print31:					
# Print '[['
	li a7, 4
	la a0, msg4
	ecall
b32:	
# Byte stored in Disk 2				
	lb t1, (s0)			
	addi t3, t3, -1	
	sb t1, (s2)
b33:	
# Store in Disk 3 
	addi s5, s0, 4			 
	lb t2, (s5)			
	addi t3, t3, -1		       
	sb t2, (s3)		
	
b31:	
# Store XOR result into disk1
	xor a3, t1, t2		
	sw a3, (a2)			
	addi a2, a2, 4		
	addi t0, t0, 1		
	addi s0, s0, 1		
	addi s2, s2, 1		
	addi s3, s3, 1		
	bgt t0, a6, reset3		
	j b32				
	nop
reset3:	
# Reset disks
	la s2, disk2
	la s3, disk3
	la a2, array
	addi s9, zero, 0		# Index
	
print32:
	lb s8, (a2)			
	jal HEX				
	nop		
	li a7, 4			
	la a0, comma
	ecall
	
	addi s9, s9, 1
	addi a2, a2, 4		
	bgt s9, a5, next31		
	j print32			
	nop		
	
next31:	
	lb s8, (a2)
	jal HEX
	nop

	li a7, 4
	la a0, msg5
	ecall
	li a7, 4
	la a0, msg2
	ecall
	addi s9, zero, 0
	
print33:
	lb a0, (s2)
	li a7, 11
	ecall
	addi s9, s9, 1
	addi s2, s2, 1
	bgt s9, a6, next32
	j print33
	nop
	
next32:	
	addi s9, zero, 0
	addi s8, zero, 0
	li a7, 4
	la a0, msg3
	ecall	
	li a7, 4
	la a0, msg2
	ecall	
print34:
	lb a0, (s3)
	li a7, 11
	ecall
	addi s8, s8, 1
	addi s3, s3, 1
	bgt s8, a6, endisk3
	j print34
	nop

endisk3:	
	li a7, 4
	la a0, msg3		
	ecall
	
	li a7, 4
	la a0, enter		
	ecall	
	beq t3, zero, exit1		
					

#-----------End first 6 4-byte blocks-----------------------------
#-----------Next 6 4-byte blocks----------------------------------

nextloop: addi s0, s0, 4		# Skip 4 consider characters
	j block1
	nop
	
exit1:
# Print ------ and end RAID simulation
	li a7, 4
	la a0, msg1
	ecall
	j ask
	nop
	
#--------------------END RAID 5 SIMULATION-------------------------


#--------------------TRY ANOTHER STRING----------------------------
ask:	li a7, 50			# Ask if wanna try
	la a0, message			
	ecall
	beq a0, zero, clear		# a0 :     0 = YES;  1 = NO;  2 = CANCEL
	nop
	j exit
	nop
	
# clear function: Return string to original state
clear:	
	la s0, string		
	add s3, s0, t5	# s3: last byte's address used in string 
	li t1, 0		# Set t1 = 0

goAgain:	
# Return string to empty state to start again
	sb t1, (s0)		
	nop
	addi s0, s0, 1
	bge s0, s3, input
	nop
	j goAgain
	nop

#-----Exit program----------
exit:	li a7, 10
	ecall
