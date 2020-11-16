.globl hashmap_test
.globl generic_hashmap_new
.globl generic_hash
.globl generic_compare
.globl custom_hashmap_new
.globl simple_hash
.text

# Structure of generic hashmap item:
# Size: 24
# Int(8 bytes): Length of key
# Pointer (8 bytes): Key
# (8 bytes): Data (For example Int or Pointer)


# Parameters:
# %rdi: initial capacity
# Returns pointer to new simple hashmap
# Must call hashmap_free() on pointer to free
generic_hashmap_new:
    mov %rdi, %rsi
    mov $24, %rdi
    mov $generic_hash, %rdx
    mov $generic_compare, %rcx
    call custom_hashmap_new
    ret

# Parameters:
# %rdi: Pointer to struct
# %rsi: seed0
# %rdx: seed1
generic_hash:
    mov %rdx, %rcx
    mov %rsi, %rdx
    mov %rdi, %r8
    mov 8(%r8), %rdi
    mov 0(%r8), %rsi
    jmp hashmap_sip # tailcall

# Parameters:
# %rdi: Pointer to a
# %rsi: Pointer to b
generic_compare:
    xor %r8, %r8
    inc %r8
    mov (%rdi), %rdx
    mov (%rsi), %rcx
    sub %rdx, %rcx
    cmovnz %r8, %rax
    jnz generic_compare_return
    
    mov 8(%rdi), %rdi
    mov 8(%rsi), %rsi
    call memcmp
    xor %r8, %r8
    xor %r9, %r9
    inc %r9
    test %rax, %rax
    cmovz %r8, %rax
    cmovnz %r9, %rax
    
    generic_compare_return:
    ret

# Parameters:
# %rdi: Pointer to data
# %rsi: length of data in bytes
# Returns hash
simple_hash:
    mov $8095681424991211376, %rdx
    mov $7070195203744986504, %rcx
    jmp hashmap_sip

# Parameters:
# %rdi: Struct size
# %rsi: Initial capacity
# %rdx: Hash function (hash(struct, seed0, seed1) -> u64)
# %rcx: Compare function (a == b -> false, a != b -> true)
# Returns pointer to new hashmap
# Must call hashmap_free() on pointer to free
custom_hashmap_new:
    # Clock fucked with some registers, so just to be safe, push them all.
    # Just get the current time to seed the hash function
    push %rdi
    push %rsi
    push %rdx
    push %rcx
    call clock
    mov %rax, %r10
    pop %rcx
    pop %rdx
    pop %rsi
    pop %rdi
    
    mov %rdx, %r8
    mov %rcx, %r9
    mov $8095681424991211376, %rdx
    add %r10, %rdx
    mov $7070195203744986504, %rcx
    add %r10, %rcx
    pushq $0
    call hashmap_new
    add $8, %rsp
    ret


hashmap_test:
    push %r12
    xor %rdi, %rdi
    call generic_hashmap_new
    mov %rax, %r12
    
    .set mapstruct, 24
    .set point, mapstruct + 16
    .set keys, point + 8 * 8
    push %rbp
    mov %rsp, %rbp
    sub $keys, %rsp
    
    # Setting keyvalues
    
    movq $1, -keys(%rbp)
    movq $1, -keys + 8(%rbp)
    
    movq $1, -keys + 8 * 2(%rbp)
    movq $2, -keys + 8 * 3(%rbp)
    
    movq $2, -keys + 8 * 4(%rbp)
    movq $1, -keys + 8 * 5(%rbp)
    
    movq $2, -keys + 8 * 6(%rbp)
    movq $2, -keys + 8 * 7(%rbp)
    
    # Setting key size
    movq $2 * 8, -mapstruct(%rbp)
    
    # Setting values
    
    # map[&keys[0]] = 3
    lea -keys(%rbp), %r8
    mov %r8, -mapstruct + 8(%rbp)
    movq $3, -mapstruct + 16(%rbp)
    
    mov %r12, %rdi
    lea -mapstruct(%rbp), %rsi
    call hashmap_set
    
    # map[&keys[2]] = 1
    lea -keys + 2 * 8(%rbp), %r8
    mov %r8, -mapstruct + 8(%rbp)
    movq $1, -mapstruct + 16(%rbp)
    
    mov %r12, %rdi
    lea -mapstruct(%rbp), %rsi
    call hashmap_set
    
    # map[&keys[4]] = 4
    lea -keys + 4 * 8(%rbp), %r8
    mov %r8, -mapstruct + 8(%rbp)
    movq $4, -mapstruct + 16(%rbp)
    
    mov %r12, %rdi
    lea -mapstruct(%rbp), %rsi
    call hashmap_set
    
    # map[&keys[6]] = 1
    lea -keys + 6 * 8(%rbp), %r8
    mov %r8, -mapstruct + 8(%rbp)
    movq $1, -mapstruct + 16(%rbp)
    
    mov %r12, %rdi
    lea -mapstruct(%rbp), %rsi
    call hashmap_set
    
    # Reading values
    
    # point = (1, 2)
    movq $2, -point(%rbp)
    movq $1, -point + 8(%rbp)
    
    # mapstruct.key = &point
    lea -point(%rbp), %r8
    mov %r8, -mapstruct + 8(%rbp)
    
    # print(map[point])
    mov %r12, %rdi
    lea -mapstruct(%rbp), %rsi
    call hashmap_get
    mov 16(%rax), %rdi
    call print_int_dec_s
    call newline
    
    # Map test_iter over kvps
    mov %r12, %rdi
    mov $test_iter, %rsi
    call hashmap_scan
    
    leave
    
    mov %r12, %rdi
    call hashmap_free
    pop %r12
    ret

# Parameters:
# %rdi: pointer to item
# (%rsi: udata)
# Returns true
test_iter:
    mov %rdi, %r9
    mov 8(%r9), %r8
    mov (%r8), %rdi
    call print_int_dec_s
    mov $s1, %rdi
    call print
    mov 8(%r8), %rdi
    call print_int_dec_s
    mov $s2, %rdi
    call print
    mov 16(%r9), %rdi
    call print_int_dec_s
    call newline
    mov $1, %rax
    ret

.data

s1:
    .string ", "
s2:
    .string " => "
