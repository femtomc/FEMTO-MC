(main):				lui R5, 0
					lui R6, 0
					lui R7, 0
					addi R7, (end)
					lui R10, 0
					lui R1, 0
					addi R1, (reg_io)
					mem R1, R1, 0
					addi R10, (reg_buf_1)
					mem R10, R10, 0
					addi R6, (in)
					addi R5, (out)
					jump R8, R6, 0
					beq R0, R0, 0

(in):				lui R2, 0
					addi R2, 1
					mem R3, R1, 0
					log R2, R3, 0
					beq R6, R2, 0
					mem R3, R10, 0

(out):				lui R4, 0
					addi R4, 13
					log R4, R3, 0
					mem R3, R10, 1
					beq R7, R4, 13
					beq R0, R0, 0

(end):				beq R7, R0, 0

(reg_buf_1):		.word 40, 32642
(reg_io):			.word 41, 32640
