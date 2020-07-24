(mult):						lui R1, 0						-- Flush R1.	
							addi R1, (SIGNED_INT_1)			-- Load the first signed int addr into R1.
							mem R1, R1, 0
							lui R2, 0						-- Flush R2.
							addi R2, (SIGNED_INT_2)			-- Load the second signed int addr in R2.
							mem R2, R2, 0
							lui R3, 0						-- R3 will be the sign register.
							lui R4, 128						-- We can use this to assert if one of the operands is neg.
							lui R5, 0
							addi R5, (first_signed)
							lui R6, 0
							addi R6, (negated_first_signed)
							lui R7, 0
							addi R7, (second_signed)
							lui R8, 0
							addi R8, (negated_second_signed)
							lui R9, 0
							addi R9, (shift_loop)
							lui R11, 0
							addi R11, (SHIFT_ARR_1)
							lui R13, 0						-- This will be counter in shift_loop.
							lui R15, 0						-- Accumulator for result.


(first_signed):				log R4, R1, 0
							shiftr R4, R0, 15
							beq R6, R4, 1
							beq R7, R0, 0

(negated_first_signed): 	log R1, R1, 1					-- Negate then increment R1.
							addi R1, 1
							addi R3, 1
							beq R7, R0, 0

(second_signed):			log R4, R2, 0
							shiftr R4, 15
							beq R8, R4, 1
							beq R9, R0, 0

(negated_second_signed): 	log R2, R2, 1					-- Negate then increment R2.
							addi R2, 1
							addi R3, 1
							
							lui R10, 0						-- This removes the sign indicator in R3 if both are negative.
							addi R10, 1
							log R3, R10, 0
											
							beq R9, R0, 0					-- Branch to final loop.

(shift_loop):				lui R4, 0						-- Flush registers.
							lui R5, 0
							lui R6, 0						-- Flush registers.
							lui R7, 0
							addi R7, (write_out)
							lui R8, 0
							addi R8, (OUT_WORD)
							add R4, R1, 0
							add R5, R2, 0
							shiftl R4, R13, 0				-- Shift first operand to left.
							mem R14, R11, 0					-- Retrieve array to match second operand on from memory.
							addi R11, 1
							log R5, R14, 0					-- Match with logical result.
							shiftr R5, R13, 0
							addi R13, 1
							beq R7, R13, 15					-- Branch breaks if maximum number of bits is iterates.
							beq R9, R5, 0					-- Check if match is true (i.e. that digit is present in second operand).
							add R15, R4, 0
							beq R9, R0, 0					-- Else, back to loop.

(write_out):				mem R15, R8, 1
							beq R0, R3, 0
							log R15, R15, 1
							addi R15, 1
							mem R15, R8, 1
							beq R0, R0, 0

(SIGNED_INT_1): 			.word 	100,   4 				-- Some bug in the lexer which trashes new lines after (-) only on this directive - I fixed by including a comment.
(SIGNED_INT_2): 			.word 	101,   4

(SHIFT_ARR_1): 				.word 102, 1
(SHIFT_ARR_2): 				.word 103, 2
(SHIFT_ARR_4): 				.word 104, 4
(SHIFT_ARR_8): 				.word 105, 8
(SHIFT_ARR_16): 			.word 106, 16
(SHIFT_ARR_32): 			.word 107, 32
(SHIFT_ARR_64): 			.word 108, 64
(SHIFT_ARR_128): 			.word 109, 128
(SHIFT_ARR_256): 			.word 110, 256
(SHIFT_ARR_512): 			.word 111, 512
(SHIFT_ARR_1024): 			.word 112, 1024
(SHIFT_ARR_2048): 			.word 113, 2048
(SHIFT_ARR_4096): 			.word 114, 4096
(SHIFT_ARR_8192): 			.word 115, 8192
(SHIFT_ARR_16384): 			.word 116, 16384

(OUT_WORD):					.word 500, 0
