(input_signed_int):	lui R1, 0						-- Flush.
					lui R3, 0
					lui R4, 0
					lui R6, 0
					lui R7, 0
					lui R8, 0
					lui R9, 0
					lui R10, 0
					lui R11, 0
					lui R12, 0
					lui R13, 0
					lui R14, 0
					lui R15, 0
					lui R2, 0						-- Flush R2 and load REG_IO_CONTROL.
					addi R2, (REG_IO_CONTROL)
					mem R2, R2, 0
					mem R3, R2, 0 					-- Load from REG_IO_CONTROL to R3.
					lui R4, 0
					addi R4, 1
					log R4, R3, 1 					-- Check REG_IO_CONTROL is not asserted (for input).
					beq R0, R4, 0					-- If condition not satisfied, jumps to beginning.

(minus_check):		addi R13, 48 					-- For shifting from ascii to numeric
					addi R7, 200
					addi R8, (input_loop)
					addi R11, (sign)				-- Setup for minus check
					addi R10, 45					-- Minus check.
					addi R4, (TEMP_store)
					lui R5, 0
					addi R5, (REG_IOBUF_1)
					mem R5, R5, 0
					mem R9, R5, 0 					-- Store the word in REG_IOBUF_1 to R9.
					mem R9, R5, 1
					add R12, R9, 0					-- Copy from R9 to R12.
					log R12, R12, 1					-- Negate R12.
					log R12, R10, 0					-- Check for minus.
					beq R11, R12, 0					-- Jump to sign branch if check R9 equals R10.
					lui R10, 0
					addi R10, 48
					add R9, R10, 11
					mem R9, R4, 1
					addi R4, 1
					lui R15, 0
					addi R15, 1
					beq R8, R0, 0

(sign):				lui R6, 0
					addi R6, 1
					beq R8, R0, 0

(input_loop):		mem R9, R2, 0					-- Check for REG_IO_CONTROL
					lui R4, 0
					addi R4, 1
					log R4, R9, 0
					beq R8, R4, 0					-- Branch back to loop start if no char waiting.
					mem R9, R5, 0
					mem R9, R5, 1
					lui R10, 0
					lui R11, 0
					addi R11, (store_setup)
					lui R14, 0
					addi R14, 10					-- Newline checks.
					log R14, R9, 0
					beq R11, R14, 10
					addi R10, 48
					add R9, R10, 11
					mem R9, R4, 1
					addi R4, 1
					addi R15, 1
					beq R8, R0, 0					-- Back to loop.

(store_setup):		lui R10, 0
					addi R10, 1
					add R4, R10, 11
					addi R15, 1
					addi R4, 1
					lui R5, 0
					addi R5, (accumulator)
					mem R5, R5, 0
					lui R6, 0
					lui R7, 0
					addi R7, 80
					lui R1, 0
					addi R1, (store_loop)
					lui R2, 0
					addi R2, (inner_loop)
					lui R7, 0
					addi R7, (out_to_mem)

(store_loop):		lui R3, 0
					addi R3, 1
					add R15, R3, 11
					add R4, R3, 11
					lui R3, 0
					mem R9, R4, 0			
					addi R3, (Pointer_1)
					add R3, R6, 0
					mem R3, R3, 0

(inner_loop):		beq R7, R15, 0
					addi R6, 1
					lui R10, 0
					addi R10, 1
					beq R1, R9, 0
					add R9, R10, 11
					add R6, R10, 11
					add R5, R3, 0
					beq R2, R0, 0

(out_to_mem):		lui R1, 0
					addi R1, (accumulator)
					lui R6, 0
					add R6, R5, 0
					log R6, R6, 1
					addi R6, 1
					mem R6, R1, 1
					beq R0, R12, 0
					mem R5, R1, 1
					beq R0, R0, 0

(TEMP_store):		.word 200, 0
(accumulator): 		.word 216, 0

(Pointer_10000):	.word 185, 10000
(Pointer_1000):		.word 184, 1000
(Pointer_100):		.word 183, 100
(Pointer_10):		.word 182, 10
(Pointer_1):		.word 181, 1

(REG_IO_CONTROL): 	.word 1500, 32640
(REG_IO_BUF_2): 	.word 1501, 32642
