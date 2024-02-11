define(multiplier, w19)
define(multiplicand, w20)
define(product, w21)
define(i, w22)
define(negative, w23)
define(result, x24)
define(temp1, x25)
define(temp2, x26)

initial_values:		.string "Multiplier = 0x%08x (%d)  Multiplicand = 0x%08x (%d) \n\n"	// Define the string that outputs initial values
out_string:		.string "Product = 0x%08x Multiplier = 0x%08x \n"			// Define the string that outputs final values in hex
result_string:		.string "64-bit Result = 0x%016lx (%ld) \n"				// Define the string that outputs final values in 64-bit format
							
			.balign 4								// Makes sure that our code is divisible by 4
												// and that all addresses are aligned with the word length of the machine
			.global main								// Sets main as the start label

main:
			stp x29, x30, [sp, -16]!						// Stores the LP and SP to the stack
			mov x29, sp								// Moves SP to FP

			mov multiplicand, #31							// Moves the first 8 bits of number 522133279 to the multiplier
			lsl multiplicand, multiplicand, 8					// Logically shifts multiplier left by 8 bits

			mov w27, #31								// Moves the second 8 bits of number 522133279 to the register 27
			orr multiplicand, multiplicand, w27					// Adds these 8 bits to the multiplicand
			lsl multiplicand, multiplicand, 8					// Logically shifts multiplier left by 8 bits

			mov w27, #31								// Moves the third 8 bits of number 522133279 to the register 27
			orr multiplicand, multiplicand, w27					// Adds these 8 bits to the multiplicand
			lsl multiplicand, multiplicand, 8					// Logically shifts multiplicand left by 8 bits

			mov w27, #31								// Moves the last 8 bits of number 522133279 to the register 27
			orr multiplicand, multiplicand, w27					// Adds these 8 bits to the multiplicand

			mov multiplier, #200							// Sets multiplier to 200
			mov product, #0								// Sets product to 0
			mov i, #0								// Sets i to 0

			ldr x0, =initial_values							// Loads address of initial_values string to register 0
			mov w1, multiplier							// Passes the value of multiplier as the firts argument
			mov w2, multiplier							// Passes the value of multiplier as the second argument
			mov w3, multiplicand							// Passes the value of multiplicand as the third argument
			mov w4, multiplicand							// Passes the value of multiplicand as the fourth argument
			bl printf								// Calls printf function

			cmp multiplier, #0							// Compares current value of multiplier to 0
			b.lt set_true								// if less than -> branches to set_true
			b set_false								// else -> branches to set_false

set_true:
			mov negative, #1							// Sets negative to 1
			b pretest								// Unconditionally branches to pretest

set_false:
			mov negative, #0							// Sets negative to 0
			b pretest								// Uncnditionally branches to pretest

pretest:
			cmp i, #32								// Compares current value of i to 32
			b.lt loop								// if less than -> branches to loop
			b after_loop								// else -> branches to after_loop

loop:
			tst multiplier, 0x1							// Ands the value in multiplier and 0x1
												// checks if the last bit is set
			b.gt increment_product							// if the bit is set -> branches to increment_product
			b continue								// else -> branches to continue

increment_product:
			add product, product, multiplicand					// Adds multiplicand to product and saves the result as product

continue:
			asr multiplier, multiplier, 1						// Arithmetically shifts right multiplier by 1 bit
			tst product, 0x1							// Ands product with 0x1
												// checks if the last bit is set
			b.gt orr_multiplier							// if the last bit is set -> branches to orr_multiplier
			b and_multiplier							// else -> branches to and_multiplier

orr_multiplier:
			orr multiplier, multiplier, 0x80000000					// Changes the sign bit of multiplier
			b contd									// Branches to contd

and_multiplier:
			and multiplier, multiplier, 0x7FFFFFFF					// Changes the sign bit of multiplier

contd:
			asr product, product, 1							// Arithmetically shifts right product by 1 bit
			add i, i, #1								// Increments the value of i by 1
			b pretest								// Branches to pretest

after_loop:
			cmp negative, 0								// Compares the value of negative to 0
			b.eq out								// if equal -> branches to out
			sub product, product, multiplicand					// else -> subtracts multiplicand from product

out:
			ldr x0, =out_string							// Loads address of out_string to register 0
			mov w1, product								// Passes product as the first argument
			mov w2, multiplier							// Passes multiplier as the second argument
			bl printf								// Calls printf function

combine:
			sxtw x28, product							// Saves the value of product in a 64-bit register
			and temp1, x28, 0xFFFFFFFF						// Ands the value from register 28 with 0xFFFFFFFF
												// stores the result in temp1
			lsl temp1, temp1, 32							// Shifts left temp1 by 32 bits
			sxtw x28, multiplier							// Saves the value of multiplier in a 64-bit register
			and temp2, x28, 0xFFFFFFFF						// Ands the value from register 28 with 0xFFFFFFFF
												// stores the result in temp2
			add result, temp1, temp2						// Adds the value from temp1 to the value from temp2
												// Stores the result as result
			ldr x0, =result_string							// Loads address of result_string to register 0
			mov x1, result								// Passes result as the first argument
			mov x2, result								// Passes result as the second argument
			bl printf								// Calls printf function

exit:
			ldp x29, x30, [sp], 16							// Restores the SP to x29 and x30
												// then does SP + 16 and set to SP
			ret									// Returns to OS
