.globl hashmap_test
.text

# Structure of hashmap item:
# Size: 24
# Int(8 bytes): Length of key
# Pointer (8 bytes): Key
# (Pointer) (8 bytes): Data


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
simple_hash:
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
    xor %rdi, %rdi
    call simple_hashmap_new
    
    mov %rax, %rdi
    call hashmap_free
    ret
