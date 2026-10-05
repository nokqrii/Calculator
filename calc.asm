; ============================================================
; x86-64 ASSEMBLY CALCULATOR
; NASM syntax
; Linux x86-64
; Uses Linux syscalls directly.
; ============================================================

global _start

section .data
    welcome db "=== PURE ASM CALCULATOR ===", 10
            db "Enter expression like: 12 + 5", 10
            db "> "

    welcome_len equ $ - welcome

    result_msg db "Result: "
    result_len equ $ - result_msg
    newline db 10
    error_msg db "Invalid expression.", 10
    error_len equ $ - error_msg


section .bss
    input       resb 128
    output      resb 32
    num1        resq 1
    num2        resq 1
    operator    resb 1

section .text

_start:

    ; ========================================================
    ; WRITE WELCOME MESSAGE
    ;
    ; syscall:
    ;   rax = 1   -> write
    ;   rdi = 1   -> stdout
    ;   rsi       -> address
    ;   rdx       -> length
    ; ========================================================

    mov     rax, 1
    mov     rdi, 1
    mov     rsi, welcome
    mov     rdx, welcome_len
    syscall


    ; ========================================================
    ; READ USER INPUT
    ;
    ; syscall:
    ;   rax = 0   -> read
    ;   rdi = 0   -> stdin
    ;   rsi       -> buffer
    ;   rdx       -> maximum bytes
    ; ========================================================

    mov     rax, 0
    mov     rdi, 0
    mov     rsi, input
    mov     rdx, 128
    syscall


    ; ========================================================
    ; PARSE FIRST NUMBER
    ; ========================================================

    mov     rsi, input
    call    parse_number

    mov     [num1], rax


    ; ========================================================
    ; SKIP SPACES
    ; ========================================================

skip_space:

    mov     al, [rsi]

    cmp     al, ' '
    je      .skip

    cmp     al, 10
    je      invalid

    jmp     got_operator

.skip:

    inc     rsi
    jmp     skip_space


    ; ========================================================
    ; GET OPERATOR
    ; ========================================================

got_operator:

    mov     al, [rsi]
    mov     [operator], al

    inc     rsi


    ; ========================================================
    ; SKIP SPACES
    ; ========================================================

skip_space_2:

    mov     al, [rsi]

    cmp     al, ' '
    jne     parse_second

    inc     rsi
    jmp     skip_space_2


    ; ========================================================
    ; PARSE SECOND NUMBER
    ; ========================================================

parse_second:

    call    parse_number

    mov     [num2], rax


    ; ========================================================
    ; SELECT OPERATION
    ; ========================================================

    mov     al, [operator]

    cmp     al, '+'
    je      do_add

    cmp     al, '-'
    je      do_sub

    cmp     al, '*'
    je      do_mul

    cmp     al, '/'
    je      do_div

    jmp     invalid


; ============================================================
; ADDITION
; ============================================================

do_add:

    mov     rax, [num1]
    add     rax, [num2]

    jmp     print_result


; ============================================================
; SUBTRACTION
; ============================================================

do_sub:

    mov     rax, [num1]
    sub     rax, [num2]

    jmp     print_result


; ============================================================
; MULTIPLICATION
; ============================================================

do_mul:

    mov     rax, [num1]
    imul    rax, [num2]

    jmp     print_result


; ============================================================
; DIVISION
; ============================================================

do_div:

    mov     rax, [num1]
    cqo

    idiv    qword [num2]

    jmp     print_result


; ============================================================
; PARSE NUMBER
;
; Input:
;   RSI -> ASCII characters
;
; Output:
;   RAX = integer
;
; Example:
;
;   "123"
;
; becomes:
;
;   1
;   1 * 10 + 2 = 12
;   12 * 10 + 3 = 123
; ============================================================

parse_number:

    xor     rax, rax


parse_loop:

    mov     bl, [rsi]

    ; Check if digit

    cmp     bl, '0'
    jb      parse_done

    cmp     bl, '9'
    ja      parse_done


    ; Convert ASCII -> integer

    sub     bl, '0'

    movzx   rbx, bl


    ; RAX = RAX * 10

    imul    rax, 10


    ; RAX += digit

    add     rax, rbx


    inc     rsi

    jmp     parse_loop


parse_done:

    ret


; ============================================================
; PRINT RESULT
;
; RAX = signed integer
; ============================================================

print_result:

    ; Save result

    mov     rbx, rax


    ; Print "Result: "

    mov     rax, 1
    mov     rdi, 1
    mov     rsi, result_msg
    mov     rdx, result_len
    syscall


    ; Restore result

    mov     rax, rbx

    ; Handle negative number

    test    rax, rax
    jns     positive


    ; Print '-'

    push    rax

    mov     byte [output], '-'

    mov     rax, 1
    mov     rdi, 1
    mov     rsi, output
    mov     rdx, 1
    syscall

    pop     rax

    neg     rax


positive:

    ; ========================================================
    ; Convert integer -> ASCII
    ;
    ; Repeatedly divide by 10.
    ; Remainder becomes the next digit.
    ; ========================================================

    mov     rdi, output
    add     rdi, 31

    mov     byte [rdi], 10

    dec     rdi

    mov     rcx, 0

convert_loop:

    xor     rdx, rdx

    mov     rbx, 10

    div     rbx

    add     dl, '0'

    mov     [rdi], dl

    dec     rdi

    inc     rcx

    test    rax, rax
    jnz     convert_loop


    inc     rdi


    ; ========================================================
    ; WRITE NUMBER
    ; ========================================================

    mov     rax, 1
    mov     rsi, rdi
    mov     rdi, 1

    ; RCX contains digit count.
    ; Add newline.

    inc     rcx

    mov     rdx, rcx

    syscall


    ; ========================================================
    ; EXIT
    ; ========================================================

    mov     rax, 60
    xor     rdi, rdi
    syscall


; ============================================================
; INVALID INPUT
; ============================================================

invalid:

    mov     rax, 1
    mov     rdi, 1
    mov     rsi, error_msg
    mov     rdx, error_len
    syscall

    mov     rax, 60
    mov     rdi, 1
    syscall