define(fd, w19)
define(buf_base, x20)
define(term, d25)
define(x, d26)

			.data									// Define data section
	
one:			.double 0r1.0
zero:			.double 0r0.0
target:			.double 0r1.0e-10

			.text									// Define code section

pn:			.string "input.bin"
file_error:		.string "Unable to find input.bin file. Is it in the same directory?\n"
outX:			.string "X: %13.1f"
outEX:			.string "e^X: %13.10f"
outENX:			.string "e^-X: %13.10f"
space:			.string "        "
line:			.string "\n"

fp			.req x29
lr			.req x30
												// Assembler equates
			alloc = -16
			dealloc = -alloc
			buf_s = 16
			buf_size = 8
			AT_FDCWD = -100

			.balign 4
			.global main								// Main routine
main:
			stp fp, lr, [sp, alloc]!
			mov fp, sp
			
			mov w0, AT_FDCWD							// Read the input.bin file from the same directory
			adrp x1, pn
			add x1, x1, :lo12:pn
			mov w2, 0
			mov w3, 0
			mov x8, 56
			svc 0
			mov fd, w0

			cmp fd, 0								// If file was not read -> throw an error
			b.lt throw_file_error
			add buf_base, fp, buf_s							// Else -> calculate base address for buffer

loop:
			mov w0, fd								// Read next int from the file
			mov x1, buf_base
			mov w2, buf_size
			mov x8, 63
			svc 0
			
			cmp x0, buf_size							// If read item is leass than 8 bytes -> branch to exit
			b.ne exit

			ldr x, [buf_base]							// Else -> print X, e^X and e^-X

			ldr x0, =outX								
			fmov d0, x
			bl printf

			ldr x0, =space
			bl printf

			fmov d0, x
			bl calculate_ex
			ldr x0, =outEX
			bl printf

			ldr x0, =space
			bl printf

			fmov d0, x
			bl calculate_enx
			ldr x0, =outENX
			bl printf

			ldr x0, =line
			bl printf

			b loop

throw_file_error:
			ldr x0, =file_error
			bl printf
			b exit

exit:
			ldp fp, lr, [sp], dealloc
			ret

			.global calculate_ex							// Calculate e^X routine			
calculate_ex:
			stp fp, lr, [sp, -16]!
			mov fp, sp

			fmov d27, d0

			adrp x21, one								// Load 1.0 to the registers
			add x21, x21, :lo12:one
			ldr d22, [x21]
			ldr d23, [x21]
			ldr d24, [x21]
			ldr d11, [x21]
			ldr term, [x21]
			ldr d10, [x21]

			adrp x21, target							// Load target to the register
			add x21, x21, :lo12:target
			ldr d9, [x21]
			
ex_pretest:
			fcmp term, d9								// Compare current term with 0r1.0e-10
			b.ge ex_loop								// If greater or equal -> branch to ex_loop
			b exit_calculate_ex							// Else -> branch to exit_calculate_ex

ex_loop:
			fmul d23, d23, d27							// Calculate next term and add it to the result
			fmul d24, d24, d22
			fdiv term, d23, d24
			fadd d10, d10, term
			fadd d22, d22, d11 
			b ex_pretest

exit_calculate_ex:
			fmov d0, d10								// Return result and exit routine
			ldp fp, lr, [sp], 16
			ret

			.global calculate_enx							// Calculate e^-X routine
calculate_enx:
			stp fp, lr, [sp, -16]!
			mov fp, sp

			fmov d27, d0

			adrp x21, one								// Load 1.0 to the registers
			add x21, x21, :lo12:one
			ldr d22, [x21]
			ldr d23, [x21]
			ldr d24, [x21]
			ldr d11, [x21]
			ldr term, [x21]
			ldr d10, [x21]

			adrp x21, target							// Load target to the register
			add x21, x21, :lo12:target
			ldr d9, [x21]

			mov x13, #0

enx_pretest:
			fabs d12, term								// d12 = abs(term)
			fcmp d12, d9								// Compare d12 and 0r1.0-10
			b.ge enx_loop								// If greater or equal -> branch to enx_loop
			b exit_calculate_enx							// Else -> branch to exit_calculate_enx

negate:
			fneg term, term								// term = -term
			b after_negate

enx_loop:
			fmul d23, d23, d27							// Calculate next term and add it to result
			fmul d24, d24, d22
			fdiv term, d23, d24
			
			mov x14, x13
			mov x15, #2
			sdiv x14, x14, x15
			mul x14, x14, x15
			sub x14, x13, x14
			cmp x14, #0
			b.eq negate

after_negate:
			fadd d10, d10, term
			fadd d22, d22, d11
			add x13, x13, #1
			b enx_pretest

exit_calculate_enx:
			fmov d0, d10								// Return result
			ldp fp, lr, [sp], 16							// Exit the routine
			ret
