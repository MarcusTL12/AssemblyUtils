.globl min_n
.globl min_3
.text

# Parameters:
# %rdi: Pointer to array
# %rsi: Length of array
# Returns minimum of array
min_n:
    mov (%rdi), %rax
    add $8, %rdi
    dec %rsi
    min_n_loop:
        test %rsi, %rsi
        jz min_n_loop_end
        mov (%rdi), %r8
        cmp %rax, %r8
        cmovl %r8, %rax
        
        add $8, %rdi
        dec %rsi
        jmp min_n_loop
    min_n_loop_end:
    ret

# Parameters:
# %rdi: First number
# %rsi: Second number
# %rdx: Third number
# Returns minimum of these three
min_3:
    mov %rdi, %rax
    cmp %rax, %rsi
    cmovl %rsi, %rax
    cmp %rax, %rdx
    cmovl %rdx, %rax
    ret
