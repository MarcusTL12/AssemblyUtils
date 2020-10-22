.globl int_to_hex
.globl int_to_dec
.globl int_to_dec_s

.text

# Parameters:
# %rdi: integer to be converted
# %rsi: pointer to buffer
# Returns:
# Integer amount of characters in the resulting string
int_to_hex:
    push %r9
    push %r10
    push %r11
    push %r12
    
    mov %rsi, %r9
    xor %r10, %r10
    mov %rdi, %r11
    i2h_loop:
        mov %r11, %rdi
        call byte_to_hex
        movw %ax, (%r9)
        shr $8, %r11
        add $2, %r9
        add $2, %r10
        cmp $0, %r11
        jne i2h_loop
    mov %r10, %r12
    mov %rsi, %rdi
    mov %r12, %rsi
    call mem_reverse_bytes
    mov %r12, %rax
    
    pop %r12
    pop %r11
    pop %r10
    pop %r9
    
    ret

# Parameters:
# %rdi: the byte
# Returns:
# hex characters in %ax
byte_to_hex:
    push %r8
    xor %rax, %rax
    # first digit
    mov %rdi, %rcx
    and $0x0f, %rcx
    mov $digits, %rdx
    add %rcx, %rdx
    movb (%rdx), %al
    # second digit
    mov %rdi, %rcx
    and $0xf0, %rcx
    shr $4, %rcx
    mov $digits, %rdx
    add %rcx, %rdx
    xor %r8, %r8
    movb (%rdx), %r8b
    shl $8, %r8
    or  %r8, %rax
    pop %r8
    ret

# Pararameters:
# %rdi: integer
# %rsi: pointer to buffer
# Returns
# length of string
int_to_dec:
    push %r8
    push %r9
    push %r10
    push %r11
    push %r12
    
    mov %rsi, %r8
    xor %r9, %r9
    int_to_dec_loop:
        xor %rdx, %rdx
        mov %rdi, %rax
        mov $10, %r10
        divq %r10
        mov %rax, %rdi
        mov $digits, %rcx
        add %rdx, %rcx
        movb (%rcx), %al
        movb %al, (%r8)
        inc %r8
        inc %r9
        cmp $0, %rdi
        jne int_to_dec_loop
    mov %r9, %r12
    mov %rsi, %rdi
    mov %r12, %rsi
    call mem_reverse_bytes
    mov %r9, %rax
    
    pop %r12
    pop %r11
    pop %r10
    pop %r9
    pop %r8
    ret

# Parameters:
# %rdi: integer
# %rsi: pointer to buffer
# Returns
# length of string
int_to_dec_s:
    push %r8
    push %r12
    xor %r12, %r12
    cmp $0, %rdi
    jge int_to_dec_s_if1
        mov $neg_sign, %r8
        movb (%r8), %r8b
        movb %r8b, (%rsi)
        inc %rsi
        neg %rdi
        inc %r12
    int_to_dec_s_if1:
    call int_to_dec
    add %r12, %rax
    pop %r12
    pop %r8
    ret

.data
digits:
    .ascii "0123456789ABCDEF"

neg_sign:
    .ascii "-"
