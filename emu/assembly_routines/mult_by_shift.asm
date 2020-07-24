-- This program implements multiplication using the barrel shifter. It works on positive integers, so it can be used when equipped with other subroutines which deal with signed integers to do multiplication.

(main):				lui R1, 0					-- Flush registers.
					lui R2, 0
					addi R2, (accumulator_1)		-- Load accumulator 1.
					mem R2, R2, 0
					lui R3, 0
					addi R3, (accumulator_2)		-- Load accumulator 2.
					mem R3, R3, 0
					lui R5, 0
					addi R5, (accumulate)		-- Store accumulate location.
					lui R6, 0
					addi R6, (loop)
					lui R7, 0 					-- R7 will be used to AND the shifted first accumulator to push the LSBs on a particular iterate to 0. This is required because shifting is implemented using a barrel shifter.
					lui R8, 0 					-- R8 will be used to AND the shifted second accumulator to push the MSBs on a particular iterate to 0. This is required because shifting is implemented using a barrel shifter. This also greatly accelerates the computation, as we can break out of the loop as soon as the second accumulator is 0.
					lui R13, 0
					addi R13, (store_out)
					lui R14, 0
					addi R14, (store)			-- Out memory location.
					lui R15, 0
					addi R15, 15 				-- Loop counter.

(loop):				lui R4, 0
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

(store_out):		lui R14, 0
					addi R14, (store)
					mem R1, R14, 1
					lui R2, 0
					add R2, R1, 0
					lui R3, 0
					add R3, R1, 0
					lui R4, 0
					add R4, R1, 0
					lui R5, 0
					add R5, R1, 0
					beq R0, R0, 0				-- Loop infinitely.

(accumulator_1):		.word 100, 5
(accumulator_2):		.word 101, 14
(store):				.word 102, 0
