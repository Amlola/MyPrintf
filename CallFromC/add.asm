global _Sum

section .text

_Sum:
    mov rax, rdi
    add rax, rsi
    ret