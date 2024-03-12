global _MyPrintf

SCALE equ 8

section .text


;               SYSTEM V
;----------------------------------------
; must push | return    | parameters
;----------------------------------------
;1) rsp     | rax       | rdi
;2) rbp     |           | rsi   
;3) rbx     |           | rdx
;4) r12     |           | rcx
;5) r13     |           | r8
;6) r14     |           | r9
;7) r15     |           |


_MyPrintf:
    push r12
    push rbx

    push rbp
    mov rbp, rsp

    push r9
    push r8
    push rcx
    push rdx
    push rsi

    mov r9, rbp         ; r9 = rbp
    sub r9, 40          ; 5 (parameters) * 8

    mov rsi, rdi
    mov rdi, Buffer

    xor r12, r12        ; current write smbl
    xor r10, r10        ; BufferSize

    .cycle:
        cmp r10, BufferCapacity
        jbe .syntax_analys

        call fflush

    .syntax_analys:
        lodsb
        cmp al, '%'
        jne .not_specific

        lodsb
        cmp al, '%'
        jne .switch

        stosb
        inc r10

        jmp .cycle

    .not_specific:
        cmp al, 0
        je .print
        
        stosb
        inc r10

        jmp .cycle

;-----------------------------------------
    .print:
        call fflush
        mov rax, r12

    .return:
        leave           ; mov sp, bp

        pop r12  
        pop rbx

        ret
;------------------------------------------
    
    .switch:
        cmp al, 'b' 
        jb .error

        cmp al, 'x'
        ja .error

        mov rdx, .jump_table[(rax - 'b') * SCALE]

        cmp r12, 5
        jne .specific            

        add r9, 32         ; saved registers + rbp

    .specific:
        inc r12

        mov rbx, [r9]

        add r9, 8

        jmp rdx

        jmp .cycle

    .jump_table: 
        dq .binary                              ; b  ASCII - 98
        dq .char                                ; c  ASCII - 99
        dq .decimal                             ; d  ASCII - 100
        times ('o' - 'd' - 1) dq .error
        dq .octal                               ; o  ASCII - 111
        times ('s' - 'o' - 1) dq .error
        dq .string                              ; s  ASCII - 115
        times ('x' - 's' - 1) dq .error
        dq .hex                                 ; x  ASCII - 120

    .binary:
        call print_binary
        jmp .cycle

    .char:
        call print_char
        jmp .cycle

    .decimal:
        call print_decimal
        jmp .cycle

    .octal:
        call print_octal
        jmp .cycle

    .hex:
        call print_hex
        jmp .cycle

    .string:
        call print_string
        jmp .cycle
    
    .error:
        mov  rax, 0x01       
        mov  rdi, 1         ; write to stdout

        mov  rsi, ErrorMsg
        mov  rdx, ErrorMsgLen

        syscall

        mov rax, -1
        jmp .return
        
;------------------------------------------
; Clear Buffer
; Enter: r10 - BufferSize
;        rdi - current cell Buffer      
;
; Destr: r10, rdi
;------------------------------------------
fflush:
    push rsi
    push rdx
    push rax

    mov  rax, 0x01       
    mov  rdi, 1         ; write to stdout

    mov  rsi, Buffer
    mov  rdx, r10

    syscall

    pop  rax
    pop  rdx
    pop  rsi

    mov  rdi, Buffer
    mov  r10, 0         ; BufferSize = 0 

    ret

;-------------------------------------print_funcs-------------------------------------------

;------------------------------------------
; Enter: bl - symbol
;        r10 - BufferSize      
;        rdi - current cell Buffer
;
; Destr: r10, rdi
;------------------------------------------
print_char:
    mov [rdi], bl
    inc  rdi
    inc  r10

    ret


;------------------------------------------
; Enter: rbx - string
;        r10 - BufferSize      
;        rdi - current cell Buffer
;
; Destr: r10, rdi
;------------------------------------------
print_string:
    mov r8, rsi

    mov rsi, rbx

    .cycle:
        lodsb

        cmp al, 0
        je .return

        cmp r10, BufferCapacity
        jbe .continue

        call fflush

        .continue:
            stosb
            inc r10

        jmp .cycle

    .return:
        mov rsi, r8
        ret


;------------------------------------------
; Enter: rbx - number
;        r10 - BufferSize      
;        rdi - current cell Buffer
;        r13 - max size of number
;        cl  - max digit in number (rol)
;        r15d - bit mask
;
; Destr: r10, rdi, r8, dl
;------------------------------------------
print_powers_of_two:
    test rbx, rbx
    jne .not_null

    mov al, '0'
    stosb
    inc r10
    jmp .return

    .not_null:
        xor r8, r8 
        xor dl, dl

    .cycle:
        cmp r8, r13
        jae .return

        rol rbx,  cl
        mov r14d, ebx
        and r14d, r15d
        inc r8

        test dl, dl
        jne .print_smbl             ; check meaningless

        test r14d, r14d          
        je .cycle

        inc dl
    
    .print_smbl:
        mov al, HexAlphabit[r14d]

        cmp r10, BufferCapacity
        jbe .print

        call fflush

        .print:
            stosb
            inc r10
            jmp .cycle
    
    .return:
        ret


print_binary:
    mov cl, 1       ; rol                    
    mov r15d, 01h   ; bit mask  
    mov r13, 32                 
    shl rbx, 32
    call print_powers_of_two
    ret


print_octal:
    mov cl, 3       ; rol
    mov r15d, 07h   ; bit mask
    mov r13, 11
    shl rbx, 31
    call print_powers_of_two
    ret


print_hex:
    mov cl, 4       ; rol
    mov r15d, 0Fh   ; bit mask
    mov r13, 8
    shl rbx, 32
    call print_powers_of_two
    ret


;------------------------------------------
; Enter: rbx - number
;        r10 - BufferSize      
;        rdi - current cell Buffer
;
; Destr: r10, rdi
;------------------------------------------
print_decimal:
    mov r8, 10
    xor r14, r14        ; counter

    test ebx, ebx
    jns .cycle          ; positive

    mov al, '-'
    stosb
    inc r10

    neg ebx

    .cycle:
        xor rdx, rdx

        mov eax, ebx    ; ax = N
        div r8          ; ax = N / 10

        mov ebx, eax    ; saving next integer

        mov eax, edx    ; ax = N % 10

        add al, '0'

        mov DecBuffer[r14], al
        inc r14

        cmp ebx, 0h
        jne .cycle
    
    add r10, r14
    cmp r10, BufferCapacity
    jbe .not_fflush

    call fflush
    add r10, r14

    .not_fflush:
        dec r14
        mov al, DecBuffer[r14]
        stosb
        test r14, r14
        ja .not_fflush

    ret


section .data

BufferCapacity equ 256
Buffer:        times BufferCapacity db 0

ErrorMsg:      db "Unknown specifier format", 0x0a
ErrorMsgLen    equ $ - ErrorMsg

DecBufferCap equ 16
DecBuffer:   times DecBufferCap db 0

HexAlphabit:   db "0123456789abcdef"