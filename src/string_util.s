.globl str_eq
.globl parse_str_int_n
.globl parse_str_int
.text

# Parameters:
# %rdi: Pointer to null terminated string 1
# %rsi: Pointer to null terminated string 2
str_eq:
    push %r12
    push %r13
    
    xor %rax, %rax
    
    str_eq_loop:
        xor %r12, %r12
        xor %r13, %r13
        movb (%rdi), %r12b
        movb (%rsi), %r13b
        cmp %r12, %r13
        jne str_eq_loop_false
        
        inc %rdi
        inc %rsi
        
        test %r12, %r12
        jnz str_eq_loop
    inc %rax
    str_eq_loop_false:
    
    pop %r13
    pop %r12
    ret

# Parameters:
# %rdi: pointer to string
# %rsi: length of string
# Returns resulting number
parse_str_int_n:
    push %r12
    
    # Check if minus sign and save bool in %r12
    xor %r12, %r12
    xor %r8, %r8
    movb (%rdi), %r8b
    cmp $45, %r8
    jne parse_str_int_n_non_negative
    inc %r12
    inc %rdi
    dec %rsi
    parse_str_int_n_non_negative:
    
    xor %rax, %rax
    parse_str_int_n_loop:
        xor %r8, %r8
        movb (%rdi), %r8b
        sub $48, %r8
        
        imul $10, %rax
        add %r8, %rax
        
        inc %rdi
        dec %rsi
        
        test %rsi, %rsi
        jnz parse_str_int_n_loop
    
    test %r12, %r12
    jz parse_str_int_n_non_negative2
    neg %rax
    parse_str_int_n_non_negative2:
    
    pop %r12
    ret

# Parameters:
# %rdi: pointer to null terminated string
# Returns resulting number
parse_str_int:
    mov %rdi, %r8
    call strlen
    mov %r8, %rdi
    mov %rax, %rsi
    call parse_str_int_n
    ret

