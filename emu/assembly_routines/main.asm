-- PROMPTS and MAIN SUBROUTINE CALLS

(main):				lui R1, 0						-- Flush R1.	
					addi R1, (prompt_1_0)			-- Load prompt_1 addr into R1.
					lui R2, 0
					addi R2, (REG_IO_CONTROL)
					mem R2, R2, 0
					lui R13, 0
					lui R14, 0
					addi R14, (loop)				-- First prompt.
					addi R13, (jump_back)
					jump R14, R14, 0
					lui R14, 0
					lui R5, 0
					addi R5, (accumulator_1)
					lui R13, 0
					addi R13, (accumulator_1)
					addi R14, (input_signed_int)	-- Jump to input routine.
					jump R14, R14, 0
					lui R1, 0
					lui R2, 0
					addi R2, (REG_IO_CONTROL)
					mem R2, R2, 0
					lui R3, 0
					lui R4, 0
					lui R5, 0
					lui R6, 0
					lui R7, 0
					lui R8, 0
					lui R14, 0
					lui R13, 0
					addi R1, (prompt_2_0)			-- Second prompt.
					addi R14, (loop)
					addi R13, (jump_back)
					jump R14, R14, 0
					lui R14, 0
					lui R5, 0
					addi R5, (accumulator_2)
					lui R13, 0
					addi R13, (accumulator_2)
					addi R14, (input_signed_int)	-- Jump again.
					jump R14, R14, 0
					lui R14, 0
					addi R14, (mult)
					jump R14, R14, 0				-- Mult call.
					lui R14, 0
					addi R14, (output_s_int)		-- Output call.
					lui R14, 0					
					addi R14, (main)				-- Back to main. Shouldn't happen as there is a call back to start in output_s_int.
					beq R14, R0, 0

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

(jump_back): 		jump R14, R14, 0

-- INPUT FOR MULT

(input_signed_int):	lui R1, 0						-- Flush.
					lui R3, 0
					lui R4, 0
					lui R6, 0
					addi R6, (input_signed_int)
					lui R7, 0
					lui R8, 0
					lui R9, 0
					lui R10, 0
					lui R11, 0
					lui R12, 0
					lui R15, 0
					lui R2, 0						-- Flush R2 and load REG_IO_CONTROL.
					addi R2, (REG_IO_CONTROL)
					mem R2, R2, 0
					mem R3, R2, 0 					-- Load from REG_IO_CONTROL to R3.
					lui R4, 0
					addi R4, 1
					log R4, R3, 0 					-- Check REG_IO_CONTROL is not asserted (for input).
					beq R6, R4, 0					-- If condition not satisfied, jumps to beginning.

(minus_check):		addi R8, (input_loop)
					lui R4, 0
					addi R4, (TEMP_store)
					lui R6, 0
					addi R6, (REG_IOBUF_1)
					mem R6, R6, 0
					mem R9, R6, 0 					-- Store the word in REG_IOBUF_1 to R9.
					lui R1, 0
					addi R1, 1
					mem R9, R6, 1					-- Should echo right back.

					add R12, R9, 0					-- Copy from R9 to R12.
					log R12, R12, 1					-- Negate R12.
					addi R10, 45					-- Minus check.
					log R12, R10, 0					-- Check for minus.
					lui R11, 0
					addi R11, (sign)				-- Setup for minus check
					beq R11, R12, 0					-- Jump to sign branch if check R9 equals R10.
					lui R10, 0
					addi R10, 48
					add R9, R10, 11
					mem R9, R4, 1
					addi R4, 1
					lui R15, 0
					addi R15, 1
					beq R8, R0, 0

(sign):				lui R12, 0
					addi R12, 1
					beq R8, R0, 0

(input_loop):		mem R9, R2, 0					-- Check for REG_IO_CONTROL
					lui R6, 0
					addi R6, 1
					log R6, R9, 0
					beq R8, R6, 0					-- Branch back to loop start if no char waiting.
					lui R6, 0
					addi R6, (REG_IOBUF_1)
					mem R6, R6, 0
					mem R9, R6, 0
					mem R9, R6, 1
					lui R1, 0						-- Flush out REG_IO_CONTROL.
					addi R1, 1
					mem R1, R2, 1
					lui R10, 0
					lui R11, 0
					addi R11, (store_setup)
					lui R10, 0
					addi R10, 10					-- Newline checks.
					log R10, R9, 0
					beq R11, R10, 10
					lui R10, 0
					addi R10, 48
					add R9, R10, 11
					mem R9, R4, 1
					addi R4, 1
					addi R15, 1
					beq R8, R0, 0					-- Back to loop.

(store_setup):		lui R10, 0
					addi R10, 10
					mem R10, R6, 1
					mem R9, R6, 1
					lui R10, 0
					addi R10, 1
					add R4, R10, 11
					addi R15, 1
					addi R4, 1
					mem R0, R5, 1
					mem R5, R5, 0
					lui R6, 0
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

(out_to_mem):		lui R6, 0
					add R6, R5, 0
					log R6, R6, 1
					addi R6, 1
					mem R6, R13, 1
					beq R14, R12, 1
					mem R5, R13, 1
					jump R14, R14, 0

-- MULT

(mult):				lui R1, 0						-- Flush registers.
					lui R2, 0
					addi R2, (accumulator_1)		-- Load accumulator 1.
					mem R2, R2, 0
					lui R3, 0
					addi R3, (accumulator_2)		-- Load accumulator 2.
					mem R3, R3, 0
					lui R5, 0
					addi R5, (accumulate)		-- Store accumulate location.
					lui R6, 0
					addi R6, (mult_loop)
					lui R7, 0 					-- R7 will be used to AND the shifted first accumulator to push the LSBs on a particular iterate to 0. This is required because shifting is implemented using a barrel shifter.
					lui R8, 0 					-- R8 will be used to AND the shifted second accumulator to push the MSBs on a particular iterate to 0. This is required because shifting is implemented using a barrel shifter. This also greatly accelerates the computation, as we can break out of the loop as soon as the second accumulator is 0.
					lui R13, 0
					addi R13, (store_out)
					addi R13, (store_out)
					lui R15, 0
					addi R15, 15 				-- Loop counter.

(mult_loop):		lui R4, 0
					addi R4, 1
					log R4, R2, 0				-- Checks if R2 has 1 at LSB. Implies that that we need to accumulate shifted R3 to the accumulation register.
					beq	R5, R4, 1
					addi R4, 1
					shiftr R2, R4, 0
					shiftl R3, R4, 0

					addi R8, 1
					shiftr R8, R4, 0
					log R8, R8, 1				-- Interesting idiom - R8 acts as a filter on the MSBs of R3. 
					log R2, R8, 0
					log R8, R8, 1

					addi R7, 1
					shiftl R7, R4, 0
					log R7, R7, 1				-- Interesting idiom - R7 acts as a filter on the LSBs of R3. 
					log R3, R7, 0
					log R7, R7, 1

					add R15, R4, 11				-- Ticks one off loop counter.
					beq R13, R15, 0
					beq R13, R2, 0
					jump R9, R6, 0

(accumulate):		add R1, R3, 0
					shiftr R2, R4, 0
					shiftl R3, R4, 0

					addi R8, 1
					shiftr R8, R4, 0
					log R8, R8, 1				-- Interesting idiom - R8 acts as a filter on the MSBs of R3. 
					log R2, R8, 0
					log R8, R8, 1

					addi R7, 1
					shiftl R7, R4, 0
					log R7, R7, 1				-- Interesting idiom - R7 acts as a filter on the LSBs of R3. 
					log R3, R7, 0
					log R7, R7, 1
					add R15, R4, 11				-- Ticks one off loop counter.
					jump R9, R6, 0				-- Unused R9.

(store_out):		lui R8, 0
					addi R8, (store)
					mem R1, R8, 1
					lui R2, 0
					add R2, R1, 0
					lui R3, 0
					add R3, R1, 0
					lui R4, 0
					add R4, R1, 0
					lui R5, 0
					add R5, R1, 0
					jump R14, R14, 0

-- Output signed int over serial.

(output_s_int):		lui R1, 0						-- Flush.
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
					addi R13, (Pointer_10000_out)
					lui R14, 0						-- Will use R14 as an output reg.
					lui R15, 0
					addi R2, (store)			-- Core use registers.
					mem R2, R2, 0
					addi R3, (REG_IO_CONTROL)
					mem R3, R3, 0
					addi R4, (REG_IO_BUF_1)
					mem R4, R4, 0
					addi R15, (out_subroutine)
					addi R7, (minus_branch)

(out_minus_check):	lui R5, 128
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
					addi R8, (accumulate_out)
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
					addi R8, (out_minus_check)
					lui R7, 0
					addi R7, (switch_arr_el)
					jump R8, R8, 0

(r10_check):		lui R10, 0
					add R10, R2, 0					-- Copy R2 to R10.
					jump R8, R8, 0

(accumulate_out):	lui R8, 0
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
					
-- DATA

(Pointer_10000_out):	.word 780, 10000
(Pointer_1000_out):		.word 781, 1000
(Pointer_100_out):		.word 782, 100
(Pointer_10_out):		.word 783, 10
(Pointer_1_out):		.word 784, 1
(TEMP_store):			.word 600, 0
(accumulator_1): 		.word 620, 0
(accumulator_2): 		.word 621, 0
(store):				.word 622, 0
(prompt_1_0): 			.asciiz 1000, "Please enter your first number: "
(prompt_2_0):			.asciiz 1100, "Please enter your second number: "
(Pointer_10000):		.word 685, 10000
(Pointer_1000):			.word 684, 1000
(Pointer_100):			.word 683, 100
(Pointer_10):			.word 682, 10
(Pointer_1):			.word 681, 1
(REG_IO_CONTROL): 		.word 1500, 32640
(REG_IOBUF_1): 			.word 1501, 32642
