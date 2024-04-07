define(i, w28)

			.text
output:			.string "%s %d%s is %s\n"
val:			.string "%d\n"
out:			.string "%s %d%s is %s\n"
month_error:		.string "Invalid month number. Try again\n"
day_error:		.string "Invalid day number. Try again\n"

s1:			.string "Winter"
s2:			.string "Spring"
s3:			.string "Summer"
s4:			.string "Fall"

mo1:			.string "January"
mo2:			.string "February"
mo3:			.string "March"
mo4:			.string "April"
mo5:			.string "May"
mo6:			.string "June"
mo7:			.string "July"
mo8:			.string "August"
mo9:			.string "September"
mo10:			.string "October"
mo11:			.string "November"
mo12:			.string "December"

end_th:			.string "th"
end_st:			.string "st"
end_nd:			.string "nd"
end_rd:			.string "rd"

			.data
seasons:		.dword s1, s2, s3, s4
months:			.dword mo1, mo2, mo3, mo4, mo5, mo6, mo7, mo8, mo9, mo10, mo11, mo12
days:			.word 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
endings:		.dword end_st, end_nd, end_rd, end_th, end_th, end_th, end_th, end_th, end_th, end_th, end_th, end_th, end_th, end_th, end_th, end_th, end_th, end_th, end_th, end_th, end_st, end_nd, end_rd, end_th, end_th, end_th, end_th, end_th, end_th, end_th, end_st

			.text
fp			.req x29								// Define register x29 as fp
lr			.req x30								// Define register x30 as lr

			month_offset = 20
			day_offset = 24

			.balign 4								// Make sure that our code is divisible by 4
												// and that all addresses are aligned with the word length of the machine
			.global main								// Make main label visible globally

main:
			stp fp, lr, [sp, -48]!							// Allocate 48 bytes on the stack
			mov fp, sp								// Move SP to FP

			mov w19, w0								// Save first cmd argument in w19
			mov x20, x1								// Save first cmd argument in x20
			mov i, #1								// Set i to 1

			cmp w19, #3								// Compare value in w19 and 3
			b.lt getArgsPretest							// If less than -> branch to getArgsPretest
			b setDefault								// Else -> branch to setDefault

setDefault:		mov w19, #3								// Set w19 to 3

getArgsPretest:
			cmp i, #3								// Compare i and 3
			b.lt getArgsLoop							// If less than -> branch to getArgsLoop
			b body									// Else -> branch to body

getArgsLoop:
			ldr x0, [x20, i, SXTW 3]						// Load i-th cmd argument
			
			cmp i, #1								// Compare i and 1
			b.eq storeMonth								// If equal -> branch to storeMonth

			cmp i, #2								// Compare i and 2
			b.eq storeDay								// If equal -> branch to storeDay

			b incrementI								// Branch to incrementI

storeDay:		bl atoi									// Call atoi function
			str w0, [fp, day_offset]						// Store value in w0 as day
			b incrementI								// Branch to incrementI

storeMonth:		bl atoi									// Call atoi function
			str w0, [fp, month_offset]						// Store value in w0 as month
			b incrementI								// Branch to incrmentI

incrementI:
			add i, i, #1								// Increment i by 1
			b getArgsPretest							// Branch to getArgsPretest

body:
			ldr w23, [fp, month_offset]						// Load month into w23

			cmp w23, #0								// Compare value in w23 and 0
			b.le monthError								// If less or equal -> branch to monthError

			cmp w23, #12								// Compare value in w23 and 12
			b.gt monthError								// If greater than -> branch to monthError

			sub w23, w23, #1							// Decrement value in w23 by 1

			adrp x21, months							// Get base address of months
			add x21, x21, :lo12:months						// Format lower 12 bits correctly
			ldr x26, [x21, w23, SXTW 3]						// Load months[w23] into register x26
		
			ldr w24, [fp, day_offset]						// Load day number into w24

			adrp x21, days								// Get base address of days
			add x21, x21, :lo12:days						// Format the lower 12 bits correctly
			ldr w25, [x21, w23, SXTW 2]						// Load days[w23] into w25 

			cmp w24, #1								// Compare value in w24 and 1
			b.lt dayError								// If less than -> branch to dayError

			cmp w24, w25								// Compare values in w24 and w25
			b.gt dayError								// If greater than -> branch to dayError

			mov w25, #0								// Set w25 to 0
			mov w22, #0								// Set w22 to 0
			mov i, #0								// Set i to 0

sumPretest:
			cmp i, w23								// Compare i and w23
			b.lt sumLoop								// If less than -> branch to sumLoop
			b incrementSum								// Branch to incrementSum

sumLoop:
			adrp x21, days								// Get base address of days
			add x21, x21, :lo12:days						// Format the lower 12 bits correctly
			ldr w22, [x21, w23, SXTW 2]						// Load days[w23] into w22
			add w25, w25, w22							// w25 = w25 + w22
			add i, i, #1								// Increment i by 1
			b sumPretest								// Branch to sumPretest

incrementSum:		add w25, w25, w24							// w25 = w25 + w24

			cmp w25, #79								// Compare value in w25 and 79
			b.le setWinter								// If less or equal -> branch to setWinter

			cmp w25, #171								// Compare value in w25 and 171
			b.le setSpring								// If less or equal -> branch to setSpring

			cmp w25, #263								// Compare value in w25 and 263
			b.le setSummer								// If less or equal -> branch to setSummer

			cmp w25, #354								// Compare value in w25 and 354
			b.le setFall								// If less or equal -> branch to setFall

			cmp w25, #365								// Compare value in w25 and 365
			b.le setWinter								// If less or equal -> branch to setWinter

setWinter:
			mov i, #0								// Set i to 0
			b sendOutput								// Branch to sendOutput

setSpring:
			mov i, #1								// Set i to 1
			b sendOutput								// Branch to sendOutput

setSummer:
			mov i, #2								// Set i to 2
			b sendOutput								// Branch to sendOutput

setFall:
			mov i, #3								// Set i to 3
			b sendOutput								// Branch to sendOutput

sendOutput:
			ldr x0, =out								// Load out string to x0
			mov x1, x26								// Pass x26 as an argument
			mov w2, w24								// Pass w24 as an argument
			adrp x21, endings							// Get base address of endings
			add x21, x21, :lo12:endings						// Format the lower 12 bits correctly
			sub w24, w24, #1							// Decrement value in w24 by 1
			ldr x3, [x21, w24, SXTW 3]						// Load endings[w24] into x3
			adrp x21, seasons							// Get base address of seasons
			add x21, x21, :lo12:seasons						// Format the lower 12 bits correctly
			ldr x4, [x21, i, SXTW 3]						// Load seasons[i] into x4
			bl printf								// Call printf function
			b exit 									// Branch to exit

monthError:
			ldr x0, =month_error							// Load month_error string into x0
			bl printf								// Call printf function
			b exit									// Branch to exit

dayError:
			ldr x0, =day_error							// Load day_error string into x0
			bl printf								// Call printf function
			b exit									// Branch to exit

exit:
			ldp fp, lr, [sp], 48							// Deallocate 48 bytes from the stack
			ret									// Return to OS
