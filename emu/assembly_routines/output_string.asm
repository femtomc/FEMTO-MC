(prompt_1_0): 			.asciiz 500, "Please enter your first number: "
(prompt_2_0):			.asciiz 800, "Please enter your second number: "

(main):				lui R1, 0						-- Flush R1.	
					addi R1, (prompt_1_0)			-- Load the CHAR addr into R1.
					lui R2, 127						-- Flush R2 and load REG_IO_CONTROL.
					addi R2, 128
					lui R13, 0
					lui R14, 0
					addi R14, (loop)
					addi R13, (branch_forever)
					jump R14, R14, 0
					lui R14, 0
					addi R14, (input_stuff)
					lui R1, 0
					addi R1, (prompt_2_0)
					lui R14, 0

(loop):				lui R11, 0
					addi R11, (loop)
					mem R3, R2, 0 					-- Load from REG_IO_CONTROL to R3.
					lui R4, 0
					addi R4, 2
					lui R7, 0						-- Flush R7.
					mem R7, R1, 0					-- Load char from (prompt_1_0) (stored in R1) into R7.
					beq R13, R7, 0					-- Check if null.
					log R4, R3, 0 					-- Check REG_IO_CONTROL is asserted. Store in R3.
					beq R11, R4, 0					-- If condition not satisfied, jumps to beginning.
					lui R5, 127						-- Flush R5.
					addi R5, 130
					mem R7, R5, 1 					-- Store the word in R7 into REG_IO_BUF_1.
					addi R1, 1						-- Increment R1.
					jump R12, R11, 0

(branch_forever): 	jump R14, R14, 0
