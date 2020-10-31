.globl md5_str
.text

.set MD5_CTX_size, 92


# md5 functions:

# MD5_Init:
# Parameters:
# %rdi: Pointer to MD5_CTX (buffer of 92 bytes)

# MD5_Update:
# %rdi: Pointer to MD5_CTX
# %rsi: Pointer to data buffer
# %rdx: length of data buffer (<=512 bytes)

# MD5_Final
# %rdi: Pointer to digest buffer (16 bytes)
# %rsi: Pointer to MD5_CTX

# Parameters:
# %rdi: Pointer to data buffer
# %rsi: Length of data
# %rdx: Pointer to string buffer
md5_str:
    push %r12
    push %r13
    push %r14
    push %r15
    
    mov %rdi, %r12
    mov %rsi, %r13
    mov %rdx, %r15
    
    # Local varables:
    # -MD5_CTX_size(%rbp): MD5_CTX
    # -MD5_CTX_size - 16(%rbp): Digest buffer
    push %rbp
    mov %rsp, %rbp
    sub $MD5_CTX_size + 16, %rsp
    
    lea -MD5_CTX_size(%rbp), %rdi
    call MD5_Init
    
    md5_loop:
        # %r14 = min(%r13, 512)
        # %r13 -= %r14
        mov $512, %r8
        mov %r13, %r14
        cmp %r8, %r14
        cmovg %r8, %r14
        sub %r14, %r13
        
        lea -MD5_CTX_size(%rbp), %rdi
        mov %r12, %rsi
        mov %r14, %rdx
        call MD5_Update
        
        # %r12 += %r14
        add %r14, %r12
        test %r13, %r13
        jnz md5_loop
    
    lea -MD5_CTX_size - 16(%rbp), %rdi
    lea -MD5_CTX_size(%rbp), %rsi
    call MD5_Final
    
    lea -MD5_CTX_size - 16(%rbp), %rdi
    mov %r15, %rsi
    call digest_to_hex
    
    leave
    
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    ret

# Parameters:
# %rdi: Pointer to digest
# %rsi: Pointer to string buffer
digest_to_hex:
    mov $digits, %r11
    
    mov $2, %rdx
    
    mov (%rdi), %r8
    digest_outer:
        mov $8, %rcx
        digest_loop:
            movb %r8b, %r10b
            and $0x0f, %r10
            
            shr $4, %r8
            
            movb (%r11, %r10, 1), %r9b
            movb %r9b, 1(%rsi)
            
            # Again
            
            movb %r8b, %r10b
            and $0x0f, %r10
            
            shr $4, %r8
            
            movb (%r11, %r10, 1), %r9b
            movb %r9b, (%rsi)
            
            inc %rsi
            inc %rsi
            
            dec %rcx
            jnz digest_loop
        mov 8(%rdi), %r8
        dec %rdx
        jnz digest_outer
    
    ret


.data

digits:
    .ascii "0123456789abcdef"
