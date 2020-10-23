.globl print
.globl print_n
.globl newline
.globl print_int_hex
.globl print_int_dec
.globl print_int_dec_s
.text

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
    push %r10
    push %r12
    push %rsi
    mov %rdi, %r12
    mov %rdi, %rsi
    call strlen
    mov %r12, %rdi
    mov %rax, %rsi
    call print_n
    pop %rsi
    pop %r12
    pop %r10
    ret

# Does not take parameters, or return anything.
# Only prits a newline character
newline:
    push %rdi
    push %rsi
    mov $newline_char, %rdi
    mov $1, %rsi
    call print_n
    pop %rsi
    pop %rdi
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
