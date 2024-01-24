out_string:     .string "The sum is %d\n"

                .balign 4
                .global main

main:
                stp x29, x30, [sp, -16]!
                mov x29, sp

                mov x19, #1
                mov x20, #1

                add x21, x19, x20

                ldr x0, =out_string
                mov x1, x21
                bl printf

exit:
                ldp x29, x30, [sp], 16
                ret