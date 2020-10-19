.globl mem_reverse_bytes
.text

# Parameters:
# %rdi: pointer to start of memory
# %rsi: amount of bytes
mem_reverse_bytes:
    mov %rdi, %rcx
    add %rsi, %rcx
    dec %rcx
    mem_reverse_bytes_loop:
        cmp %rdi, %rcx
        jle mem_reverse_bytes_loop_end
        movb (%rdi), %al
        movb (%rcx), %ah
        movb %ah, (%rdi)
        movb %al, (%rcx)
        inc %rdi
        dec %rcx
        jmp mem_reverse_bytes_loop
    mem_reverse_bytes_loop_end:
    ret
