.globl open_file_r
.globl read_file
.globl close_file

.globl file_size

.globl make_buffered_file_reader
.globl read_buffered_file
.globl read_buf_file_byte
.globl read_buf_file_line

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
    
    read_buffered_file_load_and_fill:
    
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
    
    # Check if the remaining length to be read is both
    # greater than the current available and greater then the buffer size.
    # If so, repeat the load and fill stage
    xor %r10, %r10
    xor %r11, %r11
    xor %r8, %r8
    inc %r8
    cmp 16(%r12), %r13
    cmovg %r8, %r10
    mov 32(%r12), %r11
    test %r11, %r11
    cmovnz %r8, %r11
    test %r10, %r11
    jnz read_buffered_file_load_and_fill
    
    # If the amount to still be read is greater than whats available
    # The amount to be read is changed to the available amount.
    # This happens when the file is empty so the buffer could not be filled
    cmp 32(%r12), %r13
    cmovg 32(%r12), %r13
    
    # Now we fill the destination buffer as we would if
    # we didn't have to refill
    
    read_buffered_file_enough:
    # Load dest into %rdi
    mov %r15, %rdi
    
    # Load source into %rsi
    mov 8(%r12), %r8
    mov 24(%r12), %r9
    lea (%r8, %r9, 1), %rsi
    
    # Load amount of byte to read to %rdx and memcpy
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

# Parameters
# %rdi: Pointer to buffered file object
# Returns
# The byte
# Sets zero flag when no bytes was read
read_buf_file_byte:
    dec %rsp
    
    lea (%rsp), %rsi
    xor %rdx, %rdx
    inc %rdx
    call read_buffered_file
    mov %rax, %r8
    
    xor %rax, %rax
    movb (%rsp), %al
    
    inc %rsp
    
    test %r8, %r8
    ret

# Parameters
# %rdi: Pointer to buffered file object
# %rsi: Pointer to buffer
# Returns
# Length of line read
read_buf_file_line:
    push %r12
    push %r13
    push %r14
    push %r15
    
    # Store file object and buffer pointer to %r12 and %r13 respectively
    mov %rdi, %r12
    mov %rsi, %r13
    
    # Store line length in %r14
    xor %r14, %r14
    
    # Store newline character in %r15
    mov $10, %r15
    
    find_non_line_break:
        mov %r12, %rdi
        call read_buf_file_byte
        jz read_buf_file_line_exit
        
        cmp %rax, %r15
        je find_non_line_break
    
    # If we're here, we've encountered a non linebreak character
    # and should start writing to the buffer
    
    find_end_of_line:
        movb %al, (%r13, %r14, 1)
        # inc %r13
        inc %r14
        
        mov %r12, %rdi
        call read_buf_file_byte
        jz read_buf_file_line_exit
        
        cmp %rax, %r15
        jne find_end_of_line
    
    read_buf_file_line_exit:
    mov %r14, %rax
    
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    ret


# Parameters:
# %rdi: Filename
# Returns size of file in bytes
file_size:
    push %rbp
    mov %rsp, %rbp
    sub $-144, %rsp
    
    mov %rsp, %rsi
    call stat
    mov 48(%rsp), %rax
    
    leave
    ret
