define(x, x19)
define(y, x20)
define(z, x21)

out_string:     .string "The loop was executed %d times\n"

                .balign 4
                .global main

main:
                stp x29, x30, [sp, -16]!
                mov x29, sp

                mov x, #1
                mov y, #10

                mov z, x

loop_test:
                cmp z, y
                b.gt exit

loop_body:
                ldr x0, =out_string
                mov x1, z
                bl printf

                add z, z, #1

                b loop_test

exit:
                ldp x29, x30, [sp], 16
                ret