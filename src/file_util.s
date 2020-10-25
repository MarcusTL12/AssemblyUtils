.globl open_file_r
.globl read_file
.globl close_file

.globl make_buffered_file_reader
.globl read_buffered_file

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
# [24, 32): Next index to be read.
# [32, 40): Amount of unread bytes in buffer. If zero, buffer must be refilled.

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
    movq $0, 32(%rdi)
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

# Parameters
# %rdi: Pointer to file reader object
# %rsi: Pointer to memory buffer
# %rdx: Amount of bytes to read
# Returns
# Amount of bytes actually read
# Note: Do not try to read mote than the buffer size of the reader
# This may lead to undefined behaviour
read_buffered_file:
    push %r12
    push %r13
    push %r14
    push %r15
    
    # Save file reader object as %r12
    mov %rdi, %r12
    
    # Save number of bytes to read as %r13
    mov %rdx, %r13
    
    # Save amount of bytes read
    xor %r14, %r14
    
    # Save destination to %r15
    mov %rsi, %r15
    
    # Check if there is enough bytes in the buffer to not refill
    cmp 32(%r12), %rdx
    jle read_buffered_file_enough
    
    # If we're here, we should copy the rest of the buffer, and refill it
    
    # Load dest into %rdi
    mov %r15, %rdi
    
    # load source into %rsi
    mov 8(%r12), %r8
    mov 24(%r12), %r9
    lea (%r8, %r9, 1), %rsi
    
    # Load amount to read into %rdx
    mov 32(%r12), %rdx
    
    # Need %rdx for later
    push %rdx
    call memcpy
    
    # Fill file reader
    mov %r12, %rdi
    call fill_buffered_file_reader
    
    # Restore %rdx from before memcpy was called
    pop %rdx
    
    # Move destination pointer forward by amount just read
    add %rdx, %r15
    
    # Increase the amount of bytes read by the amount of bytes read
    add %rdx, %r14
    
    # Decrease the remaining amount of bytes to read
    # by the amount of bytes read
    sub %rdx, %r13
    
    # Now we fill the destination buffer as we would if
    # we didn't have to refill
    
    read_buffered_file_enough:
    # Load dest into %rdi
    mov %r15, %rdi
    
    # Load source into %rsi
    mov 8(%r12), %r8
    mov 24(%r12), %r9
    lea (%r8, %r9, 1), %rsi
    
    mov %r13, %rdx
    call memcpy
    
    # We have read the amount of bytes, so we should subtract that from the
    # available data, as well as increment the index to the next available
    # byte
    add %r13, 24(%r12)
    sub %r13, 32(%r12)
    
    # add number of bytes read to the result, and move to the return register
    add %r13, %r14
    mov %r14, %rax
    
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    ret


.data
