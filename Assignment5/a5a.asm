define(QUEUESIZE, 8)
define(MODMASK, 0x7)
define(FALSE, 0)
define(TRUE, 1)

			.data									// Data section
			.global head								// Make head variable visible globally
head:			.word -1								// Assign -1 to head
			.global tail								// Make tail variable visible globally
tail:			.word -1								// Assign -1 to tail

			.bss									// Zeroed memory
			.global queue								// Make queue variable visible globally
queue:			.skip 4 * QUEUESIZE							// Allocate 4 * QUEUESIZE bytes for queue

			.text									// Machine code section

queue_overflow:		.string "\nQueue overflow! Cannot enqueue into a full queue.\n"		// Queue overflow string
queue_underflow:	.string "\nQueue underflow! Cannot dequeue from an empty queue.\n"	// Queue underflow string
queue_empty:		.string "\nEmpty queue\n"						// Empty queue string
queue_contents:		.string "\nCurrent queue contents:\n"					// Current queue contents string
queue_head:		.string " <-- head of queue"						// Head of the queue string
queue_tail:		.string " <-- tail of queue"						// Tail of the queue string
blank_line:		.string "\n"								// Skip one line
value:			.string "   %d"								// String for printing out queue contents

fp			.req x29								// Define register x29 as fp
lr			.req x30								// Define register x30 as lr

			.balign 4								// Make sure that code is divisible by 4
												// and that all addresses are aligned with the word length of the machine
			.global queueEmpty							// Make queueEmpty visible globally
queueEmpty:
			stp fp, lr, [sp, -32]!							// Allocate 32 bytes on the stack
			mov fp, sp								// Move SP to FP

			str w20, [fp, 16]							// Store contents of w20 to the stack
			str x19, [fp, 20]							// Store contents of x19 to the stack

			adrp x19, head								// Get base address of head
			add x19, x19, :lo12:head						// Format lower 12 bits correctly
			ldr w20, [x19]								// Load contents of head to w20

			cmp w20, #-1								// Compare value from w20 and -1
			b.eq afterQEcmp								// If equal -> branch to afterQEcmp
			mov w0, FALSE								// Else -> set w0 to false
			b endQEmpty								// Then branch to endQEmpty

afterQEcmp:		mov w0, TRUE								// Set w0 to true
			b endQEmpty								// Branch to endQEmpty

endQEmpty:		ldr w20, [fp, 16]							// Restore value of w20
			ldr x19, [fp, 20]							// Restore value of x19
			ldp fp, lr, [sp], 32							// Deallocate 32 bytes from the stack
			ret									// Return to OS

			.global queueFull							// Make queueFull visible globally
queueFull:
			stp fp, lr, [sp, -32]!							// Allocate 32 bytes on the stack
			mov fp, sp								// Move SP to FP

			str x19, [fp, 16]							// Store contents of x19 to the stack
			str w20, [fp, 24]							// Store contents of w20 to the stack
			str w21, [fp, 28]							// Store contents of w21 to the stack

			adrp x19, head								// Get base address of head
			add x19, x19, :lo12:head						// Format lower 12 bits correctly
			ldr w20, [x19]								// Load contents of head to w20

			adrp x19, tail								// Get base address of tail
			add x19, x19, :lo12:tail						// Format lower 12 bits correctly
			ldr w21, [x19]								// Load contents of tail to w21

			add w21, w21, #1							// Increment value in w21 by 1
			and w21, w21, MODMASK							// And value in w21 with MODMASK

			cmp w21, w20								// Compare w21 and w20
			b.eq afterQFcmp								// If equal -> branch to afterQFcmp
			mov w0, FALSE								// Else -> set w0 to false
			b endQFull								// Branch to endQFull

afterQFcmp:		mov w0, TRUE								// Set w0 to true
			
endQFull:		ldr x19, [fp, 16]							// Restore value in x19
			ldr w20, [fp, 24]							// Restore value in w20
			ldr w21, [fp, 28]							// Restore value in w21
			ldp fp, lr, [sp], 32							// Deallocate 32 bytes from the stack
			ret									// Return to OS

			.global enqueue								// Make enqueue visible globally
enqueue:
			stp fp, lr, [sp, -48]!							// Allocate 48 bytes on the stack
			mov fp, sp								// Move SP to FP

			str x19, [fp, 16]							// Store contents of x19 to the stack
			str w20, [fp, 24]							// Store contents of w20 to the stack
			str w21, [fp, 28]							// Store contents of w21 to the stack
			str w22, [fp, 32]							// Store contents of w22 to the stack

			mov w22, w0								// Move contents of w0 to w22

			adrp x19, tail								// Get base address of tail
			add x19, x19, :lo12:tail						// Format lower 12 bits correctly
			ldr w20, [x19]								// Load contents of tail to w20

			adrp x19, head								// Get base address of head
			add x19, x19, :lo12:head						// Format lower 12 bits correctly
			ldr w21, [x19]								// Load contents of head to w21
			
			bl queueFull								// Call queueFull function
			cmp w0, TRUE								// Compare w0 and 1
			b.ne notFullEnqueue							// If not equal -> branch to notFullEnqueue
			
			ldr x0, =queue_overflow							// Else -> load queue_overflow string to x0
			bl printf								// Call printf function
	
			b finalEnqueue								// Branch to finalEnqueue
		
notFullEnqueue:
			bl queueEmpty								// Call queueEmpty function
			cmp w0, TRUE								// Compare w0 and 1
			b.ne notEmptyEnqueue							// If not equal -> branch to notEmptyEnqueue

			mov w20, #0								// Move 0 to w20
			mov w21, #0								// Move 0 to w21
			
			adrp x19, tail								// Get base address of tail
			add x19, x19, :lo12:tail						// Format lower 12 bits correctly
			str w20, [x19]								// Load contents of tail to w20

			adrp x19, head								// Get base address of head
			add x19, x19, :lo12:head						// Format lower 12 bits correctly
			str w21, [x19]								// Load contents of head to w21

			b endEnqueue								// Branch to endEnqueue

notEmptyEnqueue:
			add w20, w20, #1							// Increment value in w20 by 1
			and w20, w20, MODMASK							// And value in w20 with MODMASK
			
			adrp x19, tail								// Get base address of tail
			add x19, x19, :lo12:tail						// Format lower 12 bits correctly
			str w20, [x19]								// Load contents of tail to w20

endEnqueue:
			adrp x19, queue								// Get base address of queue
			add x19, x19, :lo12:queue						// Format lower 12 bits correctly
			str w22, [x19, w20, SXTW 2]						// Load contents of queue[w20] to w22

finalEnqueue:
			ldr x19, [fp, 16]							// Restore value of x19
			ldr w20, [fp, 24]							// Restore value of w20
			ldr w21, [fp, 28]							// Rstore value of w21
			ldr w22, [fp, 32]							// Restore value of w22

			ldp fp, lr, [sp], 48							// Deallocate 48 bytes from the stack
			ret									// Return to OS

			.global display								// Make display visible globally
display:
			stp fp, lr, [sp, -48]!							// Allocate 48 bytes on the stack
			mov fp, sp								// Move SP to FP

			str x19, [fp, 16]							// Store contents of x19 to the stack
			str w20, [fp, 24]							// Store contents of w20 to the stack
			str w21, [fp, 28]							// Store contents of w21 to the stack
			str w22, [fp, 32]							// Store contents of w22 to the stack
			str w23, [fp, 36]							// Store contents of w23 to the stack
			str w24, [fp, 40]							// Store contents of w24 to the stack

			bl queueEmpty								// Call queueEmpty function
			cmp w0, TRUE								// Compare w0 and 1
			b.ne notEmptyDisplay							// If not equal -> branch to notEmptyDisplay
			ldr x0, =queue_empty							// Else -> load queue_empty string to x0
			bl printf								// Call printf function
			b exitDisplay								// Branch to exitDisplay

notEmptyDisplay:
			adrp x19, tail								// Get base address of tail
			add x19, x19, :lo12:tail						// Format lower 12 bits correctly
			ldr w20, [x19]								// Load contents of tail to w20

			adrp x19, head								// Get base address of head
			add x19, x19, :lo12:head						// Format lower 12 bits correctly
			ldr w21, [x19]								// Load contents of head to w21

			sub w22, w20, w21							// w22 = w20 - w21
			add w22, w22, #1							// Increment w22 by 1

			cmp w22, #0								// Compare w22 and 0
			b.gt countLE0								// If greater than -> branch to countLE0
			add w22, w22, QUEUESIZE							// Increment w22 by QUEUESIZE

countLE0:
			ldr x0, =queue_contents							// Load queue_contents string to x0
			bl printf								// Call printf function

			adrp x19, queue								// Get base address of queue
			add x19, x19, :lo12:queue						// Format lower 12 bits correctly

			mov w23, w21								// Move w21 to w23
			mov w24, #0								// Set w24 to 0

loopPretestDisplay:
			cmp w24, w22								// Compare values of w24 and w22
			b.lt loopDisplay							// If less that -> branch to loopDisplay
			b exitDisplay								// Else -> branch to exitDisplay

loopDisplay:
			ldr x0, =value								// Load value string to x0
			ldr w1, [x19, w24, SXTW 2]						// Load queue[w24] to w1
			bl printf								// Call printf function

			cmp w23, w21								// Compare values of w23 and w21
			b.ne tailCmpDisplay							// If not equal -> branch to tailCmpDisplay
			ldr x0, =queue_head							// Load queue_head string to x0
			bl printf								// Call printf function

tailCmpDisplay:
			cmp w23, w20								// Compare values in w23 and w20
			b.ne incrementDisplay							// If not equal -> branch to incrementDisplay
			ldr x0, =queue_tail							// Load queue_tail string to x0
			bl printf								// Call printf function

incrementDisplay:
			ldr x0, =blank_line							// Load blank_line string to x0
			bl printf								// Call printf function

			add w23, w23, #1							// Increment value in w23 by 1
			and w23, w23, MODMASK							// And value in w23 with MODMASK
			add w24, w24, #1							// Increment value in w24 by 1

			b loopPretestDisplay							// Branch to loopPretestDisplay

exitDisplay:
			ldr x19, [fp, 16]							// Restore value of x19
			ldr w20, [fp, 24]							// Restore value of w20
			ldr w21, [fp, 28]							// Restore value of w21
			ldr w22, [fp, 32]							// Restore value of w22
			ldr w23, [fp, 36]							// Restore value of w23
			ldr w24, [fp, 40]							// Restore value of w24
			ldp fp, lr, [sp], 48							// Deallocate 48 bytes from the stack
			ret									// Return to OS

			.global dequeue								// Make dequeue visible globally
dequeue:
			stp fp, lr, [sp, -48]!							// Allocate 48 bytes on the stack
			mov fp, sp								// Move SP to FP

			str x19, [fp, 16]							// Store contents of x19 to the stack
			str w20, [fp, 24]							// Store contents of w20 to the stack
			str w21, [fp, 28]							// Store contents of w21 to the stack
			str w22, [fp, 32]							// Store contents of w22 to the stack

			bl queueEmpty								// Call queueEmpty function
			cmp w0, TRUE								// Compare w0 and 1
			b.ne notEmptyDequeue							// If not equal -> branch to notEmptyDequeue
			ldr x0, =queue_underflow						// Load queue_underflow string to x0
			bl printf								// Call printf function
			mov w0, #-1								// Set w0 to -1
			b exitDequeue								// Branch to exitDequeue

notEmptyDequeue:
			adrp x19, tail								// Get base address of tail
			add x19, x19, :lo12:tail						// Format lower 12 bits correctly
			ldr w20, [x19]								// Load tail to w20

			adrp x19, head								// Get base address of head
			add x19, x19, :lo12:head						// Format lower 12 bits correctly
			ldr w21, [x19]								// Load head to w21

			adrp x19, queue								// Get base address of queue
			add x19, x19, :lo12:queue						// Format lower 12 bits correctly

			ldr w22, [x19, w21, SXTW 2]						// Load queue[w21] to w22

			cmp w20, w21								// Compare value in w20 and w21
			b.ne elseDequeue							// If not equal -> branch to elseDequeue

			mov w20, #0								// Else -> move 0 to w20
			adrp x19, tail								// Get base address of tail
			add x19, x19, :lo12:tail						// Format lower 12 bits correctly
			str w20, [x19]								// Store tail as 0

			mov w21, #0								// Set 0 to w21
			adrp x19, head								// Get base address of head
			add x19, x19, :lo12:head						// Format lower 12 bits correctly
			str w21, [x19]								// Store lower as 0

			b afterElseDequeue							// Branch to afterElseDequeue

elseDequeue:
			add w21, w21, #1							// Increment w21 by 1
			and w21, w21, MODMASK							// And value in w21 with MODMASK
			adrp x19, head								// Get base address of head
			add x19, x19, :lo12:head						// Format lower 12 bits correctly
			str w21, [x19]								// Store head as 1

afterElseDequeue:
			mov w0, w22								// Set w0 to value in w22

exitDequeue:
			ldr x19, [fp, 16]							// Restore value of x19
			ldr w20, [fp, 24]							// Restore value of w20
			ldr w21, [fp, 28]							// Restore value of w21
			ldr w22, [fp, 32]							// Restore value of w22
			ldp fp, lr, [sp], 48							// Deallocate 48 bytes from the stack
			ret									// Return to OS
