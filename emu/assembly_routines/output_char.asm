(main):				lui R1, 0						-- Flush R1.	
					addi R1, (CHAR)					-- Load the CHAR addr into R1.
					lui R2, 255						-- Flush R2 and load REG_IO_CONTROL address.
					mem R2, R2, 8 					-- Load from REG_IO_CONTROL to R2.
					lui R4, 0
					addi R4, 2
					log R3, R4, 1
					lui R7, 0
					mem R7, R1, 8
					log R3, R3, 1 					-- Check REG_IO_CONTROL is asserted. Store in R3.
					mem R7, R1, 4
					beq R0, R3, 0					-- If condition not satisfied, jumps to beginning.
					lui R5, 255						-- Flush R5.
					addi R5, 4						-- Store REG_IO_BUF_1 addr in R5.
					mem R7, R5, 4 					-- Store the word out to REG_IO_BUF_1.
					beq R0, R0, 0

(CHAR): 			.word 100, "Y"
