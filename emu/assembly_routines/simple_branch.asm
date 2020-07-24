(main):				lui R1, 0
					addi R1, 1
					lui R2, 0
					addi R2, (jumper)
					beq R2, R1, 1
					beq R0, R0, 0
(jumper):			addi R5, 10
					beq R0, R0, 0
