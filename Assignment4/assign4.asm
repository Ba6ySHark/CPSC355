define(temp, w21)
define(true, 1)
define(false, 0)

first_string:		.string "first"												// Define the string to output first
second_string:		.string "second"											// Define the string to output second
initial_values:		.string "Initial cuboid values:\n"									// Define the string to output intital values
cuboid_repr:		.string "Cuboid %s origin = (%d, %d)\nBase width = %d Base length = %d\nHeight = %d\nVolume = %d\n\n"	// Define the string representation of the cuboid
changed_string:		.string "\nChanged cuboid values:\n"									// Define the string to output changed values

fp			.req x29												// Define register x29 as fp
lr			.req x30												// Define register x30 as lr

			alloc = -(16 + 24 + 24) & -16										// Define alloc size
			dealloc = -alloc											// Define dealloc size
			offset_first = 16											// Define offset for the first cuboid
			offset_second = 40											// Define offset for the second cuboid
			origin_x = 0												// Define offset for the origin.x field
			origin_y = 4												// Define offset for the origin.y field
			base_width = 8												// Define offset for the base.width field
			base_length = 12											// Define offset for the base.length field
			height = 16												// Define offset for the height of cuboid
			volume = 20												// Define offset for the volume of cuboid

			.balign 4												// Make sure that our code is divisible by 4
																// and that all addresses are aligned with the word length of the machine
			.global main												// Set main as the start label

main:
			stp x29, x30, [sp, alloc]!										// Allocate space on the stack
			mov x29, sp												// Move sp to fp

			add x0, fp, offset_first										// Pass address of first cuboid as an argument
			bl new_cuboid												// Call new_cuboid function

			add x0, fp, offset_second										// Pass address of second cuboid as an argument
			bl new_cuboid												// Call new_cuboid function

			add x0, fp, offset_first										// Pass address of the first cuboid as an argument
			ldr x1, =first_string											// Load the first_string to register x1
			bl print_cuboid												// Call print_cuboid function

			add x0, fp, offset_second										// Pass address of the second cuboid as an argument
			ldr x1, =second_string											// Load the second_string to register x1
			bl print_cuboid												// Call print_cuboid function

			add x0, fp, offset_first										// Pass address of the first cuboid as an argument
			add x1, fp, offset_second										// Pass address of the second cuboid as an argument
			bl equal_size												// Call equal_size function
			
			cmp w0, true												// Check if cuboids are equal
			b.eq if_equal												// if they are -> branch to if_equal
			b not_equal												// else -> branch to not_equal

if_equal:
			add x0, fp, offset_first										// Pass address of the first cuboid as an argument
			mov w1, #3												// Pass 3 as an argument
			mov w2, #-6												// Pass -6 as an argument
			bl move													// Call move function

			add x0, fp, offset_second										// Pass address of the second cuboid as an argument
			mov w1, #4												// Pass 4 as an argument
			bl scale												// Call scale function

not_equal:
			ldr x0, =changed_string											// Load pointer to changed_string to the register x0
			bl printf												// Call printf function

			add x0, fp, offset_first										// Pass address of the first cuboid as an argument
			ldr x1, =first_string											// Load pointer to first_string to register x1
			bl print_cuboid												// Call print_cuboid function

			add x0, fp, offset_second										// Pass address of the second cuboid as an argument
			ldr x1, =second_string											// Load pointer to second_string to register x1
			bl print_cuboid												// Call print_cuboid function

			b exit													// Branch to exit

new_cuboid:
			stp x29, x30, [sp, -16]!										// Allocate 16 bytes on the stack
			mov x29, sp												// Move sp to fp
							
			mov temp, #0												// Set temp to 0
			str temp, [x0, origin_x]										// Set origin.x to temp
			str temp, [x0, origin_y]										// Set origin.y to temp

			mov temp, #2												// Set temp to 2
			str temp, [x0, base_width]										// Set base.width to temp
			str temp, [x0, base_length]										// Set base.length to temp
	
			mov temp, #3												// Set temp to 3
			str temp, [x0, height]											// Set height to temp

			mov temp, #12												// Set temp to 12
			str temp, [x0, volume]											// Set volume to temp

			ldp x29, x30, [sp], 16											// Deallocate 16 bytes on the stack
			ret													// Return to the caller routine

print_cuboid:
			stp x29, x30, [sp, -32]!										// Allocate 32 bytes on the stack
			mov x29, sp												// Move sp to fp

			str x19, [x29, 16]											// Store current value in x19 on the stack

			mov x19, x0												// Set register x19 to 0
			ldr x0, =cuboid_repr											// Load pointer to cuboid_repr string to register x0
			mov x1, x1												// Pass x1 as an argument
			ldr w2, [x19, origin_x] 										// Load origin.x to register w2
			ldr w3, [x19, origin_y]											// Load origin.y to register w3
			ldr w4, [x19, base_width]										// Load base.width to register w4
			ldr w5, [x19, base_length]										// Load base.length to register w5
			ldr w6, [x19, height]											// Load cuboid's height to register w6
			ldr w7, [x19, volume]											// Load cuboid's volume to register w7
			bl printf												// Call printf function

			ldr x19, [x29, 16]											// Restore the value for register x19

			ldp x29, x30, [sp], 32											// Deallocate 32 bytes on the stack
			ret													// Return to the caller routine

equal_size:
			stp x29, x30, [sp, -32]!										// Allocate 32 bytes on the stack
			mov x29, sp												// Move sp to fp

			str w19, [x29, 16]											// Store value in register w19 to the stack
			mov w19, false												// Set w19 to false (0)

			ldr w9, [x0, base_width]										// Load first cuboid's base.width to w9
			ldr w10, [x0, base_length]										// Load first cuboid's base.length to w10
			ldr w11, [x0, height]											// Load first cuboid's height to w11

			ldr w12, [x1, base_width]										// Load second cuboid's base.width to w12
			ldr w13, [x1, base_length]										// Load second cuboid's base.length to w13
			ldr w14, [x1, height]											// Load second cuboid's height to w14

			cmp w9, w12												// Compare cuboids' widths
			b.ne end_equal												// If not equal -> branch to end_equal

			cmp w10, w13												// Compare cuboids' lengths
			b.ne end_equal												// If not equal -> branch to end_equal

			cmp w11, w14												// Compare cuboid's heights
			b.ne end_equal												// If not equal -> branch to end_equal

			mov w19, true												// Set w19 to true (1)

end_equal:
			mov w0, w19												// Pass value from w19 as an argument
			ldr w19, [x29, 16]											// Restore the value for register w19
			ldp x29, x30, [sp], 32											// Deallocate 32 bytes from the stack
			ret													// Return to the caller routine

move:
			stp x29, x30, [sp, -16]!										// Allocate 16 bytes on the stack
			mov x29, sp												// Move sp to fp

			ldr w9, [x0, origin_x]											// Load cuboid's origin.x to w9
			ldr w10, [x0, origin_y]											// Load cuboid's origin.y to w10
			
			add w9, w9, w1												// Add one of the argument to w9
			add w10, w10, w2											// Add one of the arguments to w10

			str w9, [x0, origin_x]											// Store the result on stack
			str w10, [x0, origin_y]											// store the result on stack

			ldp x29, x30, [sp], 16											// Deallocate 16 bytes from the stack
			ret													// Return to the caller routine
scale:
			stp x29, x30, [sp, -16]!										// Allocate 16 bytes o the stack
			mov x29, sp												// Move sp to fp

			ldr w9, [x0, base_width]										// Load cuboid's base.width to w9
			mul w9, w9, w1												// Multiply value in w9 by the argument
			str w9, [x0, base_width]										// Store the result

			ldr w10, [x0, base_length]										// Load cuboid's base.length to w10
			mul w10, w10, w1											// Multiply value in w10 by the argument
			str w10, [x0, base_length]										// Store the result
			
			ldr w11, [x0, height]											// Load cuboid's height ot w11
			mul w11, w11, w1											// Multiply value in w11 by the argument
			str w11, [x0, height]											// Store the result

			mul w12, w9, w10											// Multiply cuboid's width and length
			mul w12, w12, w11											// Multiply the product by cuboid's height
			str w12, [x0, volume]											// Store the result on stack

			ldp x29, x30, [sp], 16											// Deallocate 16 bytes from the stack
			ret													// Return to the caller routine

exit:
			ldp x29, x30, [sp], dealloc										// Deallocate memory from the stack
			ret													// Return to OS
