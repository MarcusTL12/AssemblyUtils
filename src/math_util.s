
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
        
    ret
