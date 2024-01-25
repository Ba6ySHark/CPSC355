define(x, x19)
define(y, x20)

out_string:     .string "This is a string no %d\n"

                .balign 4
                .global main

main:
                stp x29, x30, [sp, -16]!
                mov x29, sp

                mov x, #1
                mov y, #2

                // b label2 : unconditional branching

                // cmp y, x
                //b.gt label2 : conditional branching

label1:
                ldr x0, =out_string
                mov x1, x
                bl printf

label2:
                ldr x0, =out_string
                mov x1, y
                bl printf

exit:
                ldp x29, x30, [sp], 16
                ret