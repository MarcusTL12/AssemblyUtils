.globl strlen
.globl str_eq
.globl parse_str_int_n
.globl parse_str_int
.globl str_split_char
.globl str_make_token_iterator
.globl str_next_token
.text


# Parameters:
# %rdi: pointer to string
# %rsi: length of string
# Returns resulting number
parse_str_int_n:
    push %r12
    
    # Check if minus sign and save bool in %r12
    xor %r12, %r12
    xor %r8, %r8
    movb (%rdi), %r8b
    cmp $45, %r8
    jne parse_str_int_n_non_negative
    inc %r12
    inc %rdi
    dec %rsi
    parse_str_int_n_non_negative:
    
    xor %rax, %rax
    parse_str_int_n_loop:
        xor %r8, %r8
        movb (%rdi), %r8b
        sub $48, %r8
        
        imul $10, %rax
        add %r8, %rax
        
        inc %rdi
        dec %rsi
        
        test %rsi, %rsi
        jnz parse_str_int_n_loop
    
    test %r12, %r12
    jz parse_str_int_n_non_negative2
    neg %rax
    parse_str_int_n_non_negative2:
    
    pop %r12
    ret

# Parameters:
# %rdi: pointer to null terminated string
# Returns resulting number
parse_str_int:
    mov %rdi, %r8
    call strlen
    mov %r8, %rdi
    mov %rax, %rsi
    call parse_str_int_n
    ret

# Parameters:
# %rdi: pointer to string
# %rsi: length of string
# %dl: character to split on
# %rcx: pointer to buffer to put the substring pointers into
# %r8: pointer to buffer to put the substring lenghts into
# %r9: length of buffers
# Returns:
# Integer number of substrings found
str_split_char:
    push %r12
    # %r10 stores the length of the current substring
    xor %r10, %r10
    # %r11 stores the start of the current substring
    mov %rdi, %r11
    # %rax stores the current number of substrings
    xor %rax, %rax
    
    # The main loop of the function.
    # Each iteration of this loop should result in a single substring
    # (if any exist)
    str_split_char_loop:
        # Each substring starts with a non-split character
        # This loop looks for one such
        str_split_char_find_nonsplit:
            # Check if the current character is a split-char
            # If not exit the loop
            # or increment the string pointer
            movb (%rdi), %r12b
            cmp %dl, %r12b
            jne str_split_char_find_nonsplit_end
            # Increment the string pointer and decrement the remaining
            # length of the string
            inc %rdi
            dec %rsi
            
            # Check if the remaining length of the string is 0
            # If so, exit the outer loop
            test %rsi, %rsi
            jz str_split_char_loop_end
            
            jmp str_split_char_find_nonsplit
        str_split_char_find_nonsplit_end:
        
        # If we've come here, we've found a non-split character that is the
        # start of a substring, so this is to be added to the buffer
        mov %rdi, (%rcx)
        add $8, %rcx
        
        inc %rax
        
        # Set length of current string to 0
        xor %r10, %r10
        
        # This loop looks for the end of the current substring
        str_split_char_find_substring:
            # Check if current char is splitting
            # If it is, jump out of the loop
            # If not, increment string pointer
            movb (%rdi), %r12b
            cmp %dl, %r12b
            je str_split_char_find_substring_end
            # Increment the string pointer and decrement the remaining
            # length of the string
            inc %rdi
            dec %rsi
            
            # Increment length of current substring
            inc %r10
            
            # Check if we've reached the end of the string
            # If so, jump out of loop, but add the final substring
            # to the buffers
            test %rsi, %rsi
            jz str_split_char_loop_end_and_add_final
            jmp str_split_char_find_substring
        str_split_char_find_substring_end:
        
        # If we've come here we have found a complete substring
        # and should add its length into the buffer
        mov %r10, (%r8)
        add $8, %r8
        
        # Remaining buffers reduced by one
        dec %r9
        
        # Check if the buffers are full (None remaining)
        # If so, jump out of outer loop
        test %r9, %r9
        jz str_split_char_loop_end
        
        # If we've reached the end of the loop without any breaks
        # jump to the top of the loop
        jmp str_split_char_loop
    str_split_char_loop_end_and_add_final:
    # If we've here, the final string is to be added to the buffer
    mov %r10, (%r8)
    str_split_char_loop_end:
    pop %r12
    ret

# String token iterator struct:
# Size: 17 bytes
# [0, 8): Current string pointer
# [8, 16): Remaining length of string
# 16: character to split on


# Parameters:
# %rdi: Pointer to token iterator object
# %rsi: Pointer to string
# %rdx: Length of string
# %cl: character to split on
str_make_token_iterator:
    mov %rsi, (%rdi)
    mov %rdx, 8(%rdi)
    mov %cl, 16(%rdi)
    ret


# Parameters
# %rdi: Pointer to token iterator
# %rsi: Pointer to save token start to
# Returns length of token; 0 means string is empty
str_next_token:
    mov (%rdi), %r8
    mov 8(%rdi), %rcx
    mov 16(%rdi), %dl
    str_token_find_non_split:
        cmp (%r8), %dl
        jne str_token_find_non_split_end
        
        inc %r8
        dec %rcx
        jz str_token_empty
        jmp str_token_find_non_split
    str_token_find_non_split_end:
    
    mov %r8, (%rsi)
    
    str_token_find_split:
        cmp (%r8), %dl
        je str_token_find_split_end
        
        inc %r8
        dec %rcx
        jnz str_token_find_split
    str_token_find_split_end:
    
    mov %r8, (%rdi)
    mov %rcx, 8(%rdi)
    sub (%rsi), %r8
    mov %r8, %rax
    
    ret
    
    str_token_empty:
    xor %rax, %rax
    movq $0, 8(%rdi)
    ret
