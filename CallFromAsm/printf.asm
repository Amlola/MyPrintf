global main
extern printf

section .text

main:
    sub rsp, 8
    mov rdi, Str
    mov rsi, People
    mov rdx, [Num]
    mov rax, 0
    call printf

    add rsp, 8
    ret


section .data

Str:        db "Hello %s, I fffk your mouth %d times", 0x0a, 0
People:     db "Katya", 0
Num         dq 3