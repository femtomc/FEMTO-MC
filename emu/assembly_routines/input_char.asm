(main):				lui R1, 0						-- Flush R1.	
					addi R1, (CHAR)					-- Load the CHAR addr into R1.
					lui R2, 255						-- Flush R2 and load REG_IO_CONTROL.
					mem R3, R2, 8 					-- Load from REG_IO_CONTROL to R3.
					log R3, R3, 1 					-- Check REG_IO_CONTROL is not asserted (for input). Store in R3.
					lui R7, 0						-- Setup for loop
					addi R7, 200
					lui R8, 0
					addi R8, (loop)

					beq R0, R3, 0					-- If condition not satisfied, jumps to beginning.

(loop):				lui R5, 255						-- Flush R5.
					addi R5, 4						-- Store REG_IO_BUF_1 addr in R5.
					lui R9, 0
					mem R9, R5, 8 					-- Store the word in REG_IOBUF_1 to R7.
					mem R9, R7, 4
					addi R7, 1
					beq R0, R0, 0

(CHAR): 			.word 100, 0 					-- Memory address to store char "Y" in REG_IO_BUF_1.
(REG_IO_CONTROL): 	.word 65280, 1
(REG_IO_BUF_2): 	.word 65288, 0
