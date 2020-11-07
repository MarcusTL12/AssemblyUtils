.globl hashmap_test
.globl simple_hash
.globl simple_compare
.text

# Structure of hashmap item:
# Size: 24
# Int(8 bytes): Length of key
# Pointer (8 bytes): Key
# (8 bytes): Data (For example Int or Pointer)


# Parameters:
# %rdi: initial size
# Returns pointer to new simple hashmap
# Must call hashmap_free() on pointer to free
simple_hashmap_new:
    mov %rdi, %rsi
    mov $24, %rdi
    xor %rdx, %rdx
    xor %rcx, %rcx
    mov $simple_hash, %r8
    mov $simple_compare, %r9
    pushq $0
    call hashmap_new
    add $8, %rsp
    ret

# Parameters:
# %rdi: Pointer to struct
# %rsi: seed0
# %rdx: seed1
simple_hash:
    mov %rdx, %rcx
    mov %rsi, %rdx
    mov %rdi, %r8
    mov 8(%r8), %rdi
    mov 0(%r8), %rsi
    call hashmap_sip
    ret

# Parameters:
# %rdi: Pointer to a
# %rsi: Pointer to b
# returns True if keys are equal
simple_compare:
    xor %r8, %r8
    mov (%rdi), %rdx
    mov (%rsi), %rcx
    sub %rdx, %rcx
    cmovnz %r8, %rax
    jnz simple_compare_return
    
    mov 8(%rdi), %rdi
    mov 8(%rsi), %rsi
    call memcmp
    xor %r8, %r8
    xor %r9, %r9
    inc %r9
    test %rax, %rax
    cmovnz %r8, %rax
    cmovz %r9, %rax
    
    simple_compare_return:
    ret


hashmap_test:
    push %r12
    xor %rdi, %rdi
    call simple_hashmap_new
    mov %rax, %r12
    
    .set mapstruct, 24
    .set point, mapstruct + 16
    push %rbp
    mov %rsp, %rbp
    sub $point, %rsp
    
    # Setting values
    
    # map[(1, 1)] = 3
    movq $16, -mapstruct(%rbp)
    lea -point(%rbp), %r8
    movq $1, -point(%rbp)
    movq $1, -point + 8(%rbp)
    mov %r8, -mapstruct + 8(%rbp)
    movq $3, -mapstruct + 16(%rbp)
    
    mov
    
    # mov %r12, %rdi
    # lea -mapstruct(%rbp), %rsi
    # call hashmap_set
    
    # # map[(1, 2)] = 1
    # movq $1, -point(%rbp)
    # movq $2, -point + 8(%rbp)
    
    # movq $1, -mapstruct + 16(%rbp)
    
    # mov %r12, %rdi
    # lea -mapstruct(%rbp), %rsi
    # call hashmap_set
    
    # # map[(2, 1)] = 4
    # movq $2, -point(%rbp)
    # movq $1, -point + 8(%rbp)
    
    # movq $1, -mapstruct + 16(%rbp)
    
    # mov %r12, %rdi
    # lea -mapstruct(%rbp), %rsi
    # call hashmap_set
    
    # # map[(2, 2)] = 1
    # movq $2, -point(%rbp)
    # movq $2, -point + 8(%rbp)
    
    # movq $1, -mapstruct + 16(%rbp)
    
    # mov %r12, %rdi
    # lea -mapstruct(%rbp), %rsi
    # call hashmap_set
    
    # # Reading values
    
    # # point = (1, 2)
    # movq $1, -point(%rbp)
    # movq $2, -point + 8(%rbp)
    
    # # print(map[point])
    # mov %r12, %rdi
    # lea -mapstruct(%rbp), %rsi
    # call hashmap_get
    # mov %rax, %rdi
    # call print_int_dec_s
    # call newline
    
    leave
    
    mov %r12, %rdi
    call hashmap_free
    pop %r12
    ret
