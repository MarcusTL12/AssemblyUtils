.globl open_file_r
.globl read_file
.globl close_file
.globl make_buffered_file_reader

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

# File reader object:
# Size 40 bytes
# [0, 8): File id
# [8, 16): Pointer to buffer
# [16, 24): Length of buffer
# [24, 32): Next index to be read; If equal to length of buffer
# the buffer is to be refilled, else if equal to first free index
# the file is empty.
# [32, 40): First free index of buffer; Full if equal to length of buffer

# Parameters
# %rdi: Pointer to file reader object
# %rsi: File id
# %rdx: Pointer to buffer
# %rcx: Length of buffer
make_buffered_file_reader:
    mov %rsi, 0(%rdi)
    mov %rdx, 8(%rdi)
    mov %rcx, 16(%rdi)
    movq $0, 24(%rdi)
    ret

# Flushes the contents of the buffer and fills buffer from file
# Parameters
# %rdi: Poitner to file reader object
fill_buffered_file_reader:
    mov %rdi, %r8
    mov 0(%r8), %rdi
    mov 8(%r8), %rsi
    mov 16(%r8), %rdx
    call read_file
    mov %rax, 32(%r8)
    movq $0, 24(%r8)
    ret
