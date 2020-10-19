.globl open_file_r
.globl read_file
.globl close_file

.text

# Parameters:
# %rdi: Pointer to filename
# Returns:
# File id
open_file_r:
    mov $2, %rax
    xor %rsi, %rsi
    mov $0777, %rdx
    syscall
    ret

# Parameters:
# %rdi: File id
# %rsi: Pointer to memory buffer
# %rdx: Amount of bytes to read
# Returns:
# Amount of bytes actually read
read_file:
    xor %rax, %rax
    syscall
    ret

# Parameters:
# %rdi: File id
close_file:
    mov $3, %rax
    syscall
    ret
