(main):				lui R1, 0
					addi R1, (test_load)
					mem R1, R1, 0
					lui R2, 0
					addi R2, 1
					shiftr R2, R1, 0
					lui R3, 0
					addi R3, (ex)
					mem R2, R3, 1
					beq R0, R0, 0

(ex):				.word 16, 0
(test_load):		.word 17, 4
