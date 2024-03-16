define(i, w19)
define(j, w22)
define(temp, w23)
define(array_base, x20)

initial_value:		.string "v[%d]: %d\n"							// Define string that outputs array item
label_1:		.string "Initital Array:\n"						// Define string that precedes unsorted array
label_2:		.string "\nSorted Array:\n"						// Define string that precedes sorted array

fp			.req x29								// Define register x29 as fp
lr			.req x30								// Define register x30 as lr

			i_size = 4								// Define i size (int -> 4 bytes)
			j_size = 4								// Define j size (int -> 4 bytes)
			temp_size = 4								// Define temp size (int -> 4 bytes)
			array_size = 4 * 50							// Define array size (int * 50 -> 200 bytes)
			alloc = -(16 + i_size + j_size + temp_size + array_size) & -16		// Define alloc -> space to be allocated on the stack
			dealloc = -alloc							// Define dealloc -> space to be deallocated on the stack
			i_offset = 16								// Define i offset (fr -> 16 bytes)
			j_offset = 20								// Define j offset (fr + i_size -> 20 bytes)
			temp_offset = 24							// Define temp offset (fr + i_size + j_size -> 24 bytes)
			base_offset = 28							// Define the first element of the array offset
												// (fr + i_size + j_size + temp_size -> 28 bytes)

			.balign 4								// Make sure that our code is divisible by 4
												// and that all addresses are aligned with the word length of the machine
			.global main								// Set main as the start label

main:
			stp fp, lr, [sp, alloc]!						// Store fp and sp, allocates space on the stack
			mov fp, sp								// Move sp to fp

			add array_base, fp, base_offset						// Calculate the address of the first item in the array (offset)

			mov i, #0								// Set i to be 0
			str i, [fp, i_offset]							// Store current value of i to the stack

			ldr x0, =label_1							// Load address of label_1 string to register x0
			bl printf								// Call printf function

populate_pretest:
			ldr i, [fp, i_offset]							// Load value of i
			cmp i, #50								// Compare i to 50
			b.lt populate_loop							// if less than -> branch to populate_loop
			mov i, #1								// else -> set i to 1
			str i, [fp, i_offset]							// else -> store i on the stack
			b sort_outer_pretest							// else -> branch to sort_outer_pretest

populate_loop:
			bl rand									// Call rand function
			mov w21, w0								// Save the result of the function call in register w21
			and w21, w21, 0xFF							// And the value stored in register w21 with 0xFF
												// then save the result in register w21
			ldr i, [fp, i_offset]							// Load the value of i
			str w21, [array_base, i, SXTW 2]					// Store the value from register w21 as an array item on the stack

			ldr x0, =initial_value							// Load address of initial_value string to register x0
			mov w1, i								// Pass i as the first argument
			mov w2, w21								// Pass the value from register w21 as the second argument
			bl printf								// Call printf function

			add i, i, #1								// Increment i by 1
			str i, [fp, i_offset]							// Store current value of i to the stack
			b populate_pretest							// Branch to populate_pretest

sort_outer_pretest:
			ldr i, [fp, i_offset]							// Load the value of i
			cmp i, #50								// Compare i to 50
			b.lt sort_outer_loop							// if less than -> branch to sort_outer_loop
			mov i, #0								// else -> set the value of i to 0
			str i, [fp, i_offset]							// else -> store current value of i to the stack
			b print_label								// Branch to print_label

sort_outer_loop:
			ldr i, [fp, i_offset]							// Load value of i
			ldr temp, [array_base, i, SXTW 2]					// Load current array item to temp
			str temp, [fp, temp_offset]						// Store current value of temp to the stack
			str i, [fp, j_offset]							// Store current value of i as j to the stack
			
sort_inner_pretest:
			ldr j, [fp, j_offset]							// Load value of j
			cmp j, #0								// Compare j to 0
			b.le after_inner_loop							// if less or equal -> branch to after_inner_loop
			ldr temp, [fp, temp_offset]						// Load value of temp
			mov w25, j								// Move j to register w25
			sub w25, w25, #1							// Subtract 1 from the value stored in register w25
			ldr w26, [array_base, w25, SXTW 2]					// Load array item to register w26
			cmp temp, w26								// Compare temp with the value stored in register w26
			b.lt sort_inner_loop							// if less than -> branch to sort_inner_loop
			b after_inner_loop							// Branch after_inner_loop

sort_inner_loop:
			ldr j, [fp, j_offset]							// Load value of j 
			mov w25, j								// Move j in register w25
			sub w25, w25, #1							// Subtract 1 from the value stored in register w25
			ldr w26, [array_base, w25, SXTW 2]					// Load the array item into register w26
			str w26, [array_base, j, SXTW 2]					// Store the current value from register w26 in array on the stack

			sub j, j, #1								// Subtract 1 from j
			str j, [fp, j_offset]							// Store value of j on the stack
			b sort_inner_pretest							// Branch to sort_inner_pretest

after_inner_loop:
			ldr temp, [fp, temp_offset]						// Load value of temp
			ldr j, [fp, j_offset]							// Load value of j
			str temp, [array_base, j, SXTW 2]					// Store value of temp as array item

			ldr i, [fp, i_offset]							// Load value of i
			add i, i, #1								// Increment i by 1
			str i, [fp, i_offset]							// Store i to the stack
			b sort_outer_pretest							// Branch to sort_outer_pretest
print_label:
			ldr x0, =label_2							// Load the address of label_2 string into register x0
			bl printf								// Call printf function

print_loop_pretest:
			ldr i, [fp, i_offset]							// Load value of i
			cmp i, #50								// Compare i to 50
			b.lt print_loop								// if less than -> branch to print_loop
			b exit									// else -> branch to exit

print_loop:
			ldr i, [fp, i_offset]							// Load value of i
			ldr w26, [array_base, i, SXTW 2]					// Load array item to the register w26
			ldr x0, =initial_value							// Load the address of initial_value string to the register x0
			mov w1, i								// Pass i as the first argument
			mov w2, w26								// Pass the value in register w26 as the second argument
			bl printf								// Call printf function

			add i, i, #1								// Increment i by 1
			str i, [fp, i_offset]							// Store the value of i to the stack
			b print_loop_pretest							// Branch to print_loop_pretest

exit:
			ldp fp, lr, [sp], dealloc						// Restores the sp to x29 and x30
												// then does sp + 16 and set to sp
			ret									// Return to OS
