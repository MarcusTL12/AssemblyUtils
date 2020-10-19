.globl strlen
.globl print
.globl print_n
.globl newline
.globl print_int_hex
.globl print_int_dec
.globl print_int_dec_s
.text

# Parameters:
# %rdi: Pointer to null terminated string
strlen:
    xor %rax, %rax
    xor %r10, %r10
    dec %rax
strlen_loop:
    inc %rax
    mov (%rdi), %r10b
    inc %rdi
    cmp $0, %r10b
    jne strlen_loop
    ret

# Parameters
# %rdi: Pointer to string
# %rsi: amount of bytes to print
print_n:
    mov %rsi, %rdx
    mov %rdi, %rsi
    mov $1, %rax
    mov $1, %rdi
    syscall
    ret

# Parameters:
# %rdi: Pointer to null terminated string
print:
    mov %rdi, %r12
    mov %rdi, %rsi
    call strlen
    mov %r12, %rdi
    mov %rax, %rsi
    call print_n
    ret

# Does not take parameters, or return anything.
# Only prits a newline character
newline:
    mov $newline_char, %rdi
    mov $1, %rsi
    call print_n
    ret

newline_char:
    .ascii "\n"

# Parameters:
# %rdi: Integer
print_int_hex:
    sub $16, %rsp
    
    mov %rsp, %rsi
    call int_to_hex
    
    mov %rsp, %rdi
    mov %rax, %rsi
    call print_n
    
    add $16, %rsp
    
    ret

# Parameters:
# %rdi: Integer
print_int_dec:
    sub $20, %rsp
    
    mov %rsp, %rsi
    call int_to_dec
    
    mov %rsp, %rdi
    mov %rax, %rsi
    call print_n
    
    add $20, %rsp
    
    ret

# Parameters:
# %rdi: signed integer
print_int_dec_s:
    sub $21, %rsp
    
    mov %rsp, %rsi
    call int_to_dec_s
    
    mov %rsp, %rdi
    mov %rax, %rsi
    call print_n
    
    add $21, %rsp
    
    ret
