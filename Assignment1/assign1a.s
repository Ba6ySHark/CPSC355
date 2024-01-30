									// Steven Susorov UCID: 30197973 

out_string:	.string "x: %d, y: %d, current minimum: %d\n"		//  Define output string

		.balign 4						// Makes sure that our code is divisible by 4
									// and that all addresses are aligned with the word length of the machine
		.global main						// Sets main as the start label

main:
		stp x29, x30, [sp, -16]!				// Stores the LP and SP to the stack
		mov x29, sp						// Moves SP to FP

		mov x19, #-10						// Move -10 in register 19
		mov x20, #4						// Move 4 in register 20
		mov x21, #3						// Move 3 in register 21
		mov x22, #31						// Move 31 in register 22
		mov x23, #-15						// Move -15 in register 23

loop_pretest:
		cmp x19, x20						// Compares current x value to 4
		b.gt exit						// if current value of x is greater that 4 then finishes the program
		
loop:
		mul x24, x19, x19					// Squares the value of x and stores it in register 24
		mul x24, x24, x19					// Multiplies the value stored in register 24 by x
		mul x24, x24, x21					// Multiplies the value stored in register 24 by 3

		mul x25, x19, x19					// Squares the value of x and stores it in register 25
		mul x25, x25, x22					// Multiplies the value stored in register 25 by 31
		
		mul x26, x19, x23					// Multiplies the value of x by -15 and stores it in register 26
	
		add x27, x24, x25					// Adds the values stored in registers 24 and 25
		add x27, x27, x26					// Adds the values stored in registers 26 and 27
		add x27, x27, #-127					// Increments the values stored in register 27 by -127

		b min							// branch to min

after_cmp:	
		ldr x0, =out_string					// Loads address of out_string to register 0
		mov x1, x19						// Passes value in register 19 as an argument to the function
		mov x2, x27						// Passes value in register 27 as an argument to the function
		mov x3, x28						// Passes value in register 28 as an argument to the funtion
		bl printf						// Calls printf function

		add x19, x19, #1					// Increments current value of x by 1
		b loop_pretest						// branches to loop_pretest

min:
		cmp x19, #-10						// Compares the current value of x to -10
		b.eq set_min						// if they are equal branches to set_min
		b find_min						// else branches to find_min

set_min:
		mov x28, x27						// Moves the value from register 27 to register 28
		b after_cmp						// branches to after_cmp

find_min:
		cmp x27, x28						// Compares the values stored in register 27 and 28
		b.lt set_min						// if the value in register 27 is less than value in register 28
									// branch to set_min
		b after_cmp						// else branch to after_cmp

exit:
		ldp x29, x30, [sp], 16					// Restore the SP to x29 and x30, then do SP + 16 and set to SP
		ret							// Return to OS
