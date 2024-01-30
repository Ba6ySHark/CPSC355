define(x, x19)
define(y, x20)
define(min, x21)
define(min, x22)
define(coef1, x23)
define(coef2, x24)
define(coef3, x25)
define(coef4, x26)
define(temp, x27)

									// Steven Susorov UCID: 30197973

out_string:	.string "X: %d, Y: %d, current minimum: %d\n"		// Define output string

		.balign 4						// Makes sure that our code is divisible by 4
									// and that all addresses are aligned with the word length of the machine
		.global main						// Sets main as the start label

main:
		stp x29, x30, [sp, -16]!				// Stores LP and SP to the stack
		mov x29, sp						// Moves SP to FP
		
		mov x, #-10						// Moves -10 in register labeled x
		mov coef1, #3						// Moves 3 in register labeled coef1
		mov coef2, #31						// Moves 31 in register labeled coef2
		mov coef3, #-15						// Moves -15 in register labeled coef3
		mov coef4, #-127					// Moves -127 in register labeled coef4

		b pretest						// Branches to pretest

loop:
		madd y, coef3, x, coef4					// Multiplies coef3 by x and adds coef4 to it
									// stores the result in register labeled y
		mul temp, x, x						// Squares x, stores the result in register labeled temp
		madd y, coef2, temp, y					// Multiplies coef2 by temp and adds y to it
									// stores the result in register labeled y
		mul temp, temp, x					// Multiplies temp by x (brings x to the power of 3), stores the result in temp
		madd y, coef1, temp, y					// Multiplies coef1 by temp and adds y to it
									// Stores the result in register labeled y
		b minimum						// Branches to minimum
		
after_cmp:	ldr x0, =out_string					// Loads address of out_string to x0
		mov x1, x						// Passes x as an argument to the function
		mov x2, y						// Passes y as an argument to the function
		mov x3, min						// Passes min as an argument to the function
		bl printf						// Calls printf function

		add x, x, #1						// Increments current values of x by 1
		b pretest						// Branches to pretest

pretest:
		cmp x, #4						// Compares the value in register labeled x to 4
		b.gt exit						// If greater than -> branches to exit
		b loop							// Else branches to loop

minimum:
		cmp x, #-10						// Compares the value in register labeled x to -10
		b.eq set_min						// if equal -> branches to set_min
		b find_min						// Else branches to find_min

set_min:
		mov min, y						// Moves value in register labeled y to the register labeled min
		b after_cmp						// Branches to after_cmp

find_min:
		cmp y, min						// Compares the values in register y to the value in register min
		b.lt set_min						// If less than -> branches to set_min
		b after_cmp						// Else branches to after_cmp

exit:
		ldp x29, x30, [sp], 16					// Restore the SP to x29 and x30, then do SP + 16 and set to SP
		ret							// Return to OS
