(input_signed_int):	lui R1, 0						-- Flush.
					lui R2, 0
					lui R3, 0
					lui R4, 0
					lui R5, 0
					lui R6, 0
					lui R7, 0
					lui R8, 0
					lui R9, 0
					lui R10, 0
					lui R11, 0
					lui R12, 0
					lui R13, 0						-- Will point to array in memory.
					addi R13, (Pointer_10000)
					lui R14, 0						-- Will use R14 as an output reg.
					lui R15, 0
					addi R2, (accumulated)			-- Core use registers.
					mem R2, R2, 0
					addi R3, (REG_IO_CONTROL)
					mem R3, R3, 0
					addi R4, (REG_IO_BUF_1)
					mem R4, R4, 0
					addi R15, (out_subroutine)
					addi R7, (minus_branch)

(minus_check):		lui R5, 128
					lui R6, 128
					log R5, R2, 0
					lui R8, 0
					addi R8, 15
					shiftr R5, R8, 0				-- Check if negative.
					beq R7, R5, 1
					addi R14, 1
					lui R10, 0
					add R10, R2, 0
					lui R8, 0
					addi R8, (out_subroutine)
					beq R8, R2, 0
					lui R8, 0
					addi R8, (accumulate)
					jump R8, R8, 0

(out_subroutine):	mem R7, R3, 0
					lui R8, 0
					addi R8, 2
					log R8, R7, 0
					beq R15, R8, 0					-- Check if R14 is 0 (don't print).
					lui R8, 0
					addi R8, (convert_to_b10)
					beq R8, R14, 0
					mem R14, R4, 1 					-- Out on R14.
					beq R0, R2, 0					-- Finish program. Loop.
					lui R14, 0
					jump R15, R15, 0

(minus_branch):		lui R14, 0
					addi R14, 45
					log R2, R2, 1					-- Now negated.
					addi R2, 1
					beq R15, R10, 0					-- Check if R10 is 0.
					jump R15, R15, 0				-- Go to out subroutine to print out.

(convert_to_b10):	mem R9, R13, 0					-- Get current array element to compare.
					lui R8, 0
					addi R8, (r10_check)
					beq R8, R10, 0
					add R2, R9, 11
					lui R8, 0
					addi R8, (minus_check)
					lui R7, 0
					addi R7, (switch_arr_el)
					jump R8, R8, 0

(r10_check):		lui R10, 0
					add R10, R2, 0					-- Copy R2 to R10.
					jump R8, R8, 0

(accumulate):		lui R8, 0
					addi R8, (convert_to_b10)
					jump R8, R8, 0

(switch_arr_el):	addi R13, 1						-- Increment array pointer and jump to out subroutine for R1.
					lui R8, 0
					mem R8, R13, 0
					beq R0, R8, 0					-- Check if array is done.
					lui R2, 0
					add R2, R10, 0
					lui R15, 0
					lui R8, 0
					addi R8, (convert_to_b10)
					addi R15, (out_subroutine)
					beq R8, R14, 1
					jump R15, R15, 0
					jump R8, R8, 0
					
(TEMP_store):		.word 200, 0
(accumulated): 		.word 216, -35

(Pointer_10000):	.word 180, 10000
(Pointer_1000):		.word 181, 1000
(Pointer_100):		.word 182, 100
(Pointer_10):		.word 183, 10
(Pointer_1):		.word 184, 1

(REG_IO_CONTROL): 	.word 1500, 32640
(REG_IO_BUF_1): 	.word 1501, 32642
