    .globl _start

_start:
    @ FALL_THROUGH

_write:
    mov r7, #4
    mov r0, #1
    ldr r1, =message
    mov r2, #35
    swi 0

_exit:
    mov r7, #1
    mov r0, #0
    swi 0

    .data
message: .ascii "___ARM: Hello World from Docker___\n"
