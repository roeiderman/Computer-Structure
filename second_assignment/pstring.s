.extern	printf
.extern	scanf

.section .rodata
print_fmt_string: .string "%s"
print_fmt_integer: .string "%d"
invalid_fmt: .string "invalid input!\n"
cannot_cat_fmt: .string "cannot concatenate strings!\n"


.section .text
    .global pstrlen
    .global swapCase
    .global pstrijcpy
    .global pstrcat


pstrlen:
    //     # Note that we backup %rdi in order to subtract it from the pointer to the string end
    //     movq    %rdi, %r8
    // loop_pstrlen:
    //     cmpb    $0, (%rdi)  # If reached to a null-byte (string end)
    //     je      pstrlen_done
    //     incq    %rdi        # Increase the pointer by 1 to get to the next char
    //     jmp     loop_pstrlen        # Continue looping
    // pstrlen_done:
    //     subq    %r8, %rdi   # Calculate the string length
    //     decq    %rdi
    //     movq    %rdi, %rax  # Note that return value must be in %rax, so we move the length there
    //     ret
    pushq %rbp
    movq %rsp, %rbp


    movb (%rdi), %al  # Move the first byte at address %rdi into the lower 8 bits of %rax (%al)
    andq $0xFF, %rax  # Clear the upper 56 bits of %rax to ensure only the byte is preserved
    
    movq %rbp, %rsp
    popq %rbp
    ret               # Return the value in %rax

swapCase:
        pushq %rbp
        movq %rsp, %rbp
        incq %rdi
        #Note that we backup %rdi in order to subtract it from the pointer to the string end
        movq    %rdi, %r8
    loop_swap:
        cmpb    $0, (%rdi)  # If reached to a null-byte (string end)
        je      swap_done
        movb (%rdi), %al
        
        cmpb $0x41, %al
        jl   not_letter       # jump if less than 'A'
        cmpb $0x5A, %al
        jle   is_uppercase    # jump if less than or equal to 'Z'
        
        # Check if character is between 'a' and 'z' (lowercase)
        cmpb $0x61, %al
        jl   not_letter       # jump if less than 'a'
        cmpb $0x7A, %al
        jle   is_lowercase    # jump if less than or equal to 'z'
        jmp  not_letter

is_uppercase:
    addb    $0x20, %al
    movb    %al, (%rdi)
    incq    %rdi        # Increase the pointer by 1 to get to the next char
    jmp     loop_swap   # Continue looping

is_lowercase:  
    subb    $0x20, %al
    movb    %al, (%rdi)
    incq    %rdi        # Increase the pointer by 1 to get to the next char
    jmp     loop_swap   # Continue looping

not_letter:
    incq    %rdi        # Increase the pointer by 1 to get to the next char
    jmp     loop_swap        # Continue looping

swap_done:
    movq    %r8, %rax  # Note that return value must be in %rax, so we move the length there
    movq %rbp, %rsp
    popq %rbp
    ret               # Return the value in %rax



pstrijcpy:
    pushq %rbp
    movq %rsp, %rbp

    movq $0, %r15 #conter
    # Note that we backup %rdi in order to subtract it from the pointer to the string end
    // movq    %rdi, %r8

    # look at the size of the strings
    movb (%rdi), %al  # Move the first byte at address %rdi into the lower 8 bits of %rax (%al)
    andq $0xFF, %rax  # Clear the upper 56 bits of %rax to ensure only the byte is preserved
    movq %rax, %r12

    movb (%rsi), %al  # Move the first byte at address %rdi into the lower 8 bits of %rax (%al)
    andq $0xFF, %rax  # Clear the upper 56 bits of %rax to ensure only the byte is preserved
    movq %rax, %r13

    incq %rdi        # Move to next char in destination
    incq %rsi        # Move to next char in source
    movq    %rdi, %r8

    # check if the bounds that we get in func_select are invalid
    cmpq %r12, %rdx
    jge invalid_input
    cmpq %r12, %rcx
    jge invalid_input
    cmpq %r13, %rdx
    jge invalid_input
    cmpq %r13, %rcx
    jge invalid_input
    cmpq %rcx, %rdx
    jg invalid_input
loop_pstrijcpy:
    cmpb $0, (%rdi)  # Check if reached null-byte (string end)
    je pstrijcpy_done

    # Range check: Is counter between %rdx (lower bound) and %rcx (upper bound)?
    cmpq %rdx, %r15  # Compare counter with lower bound
    jl continue      # If counter < lower bound, skip to continue
    cmpq %rcx, %r15  # Compare counter with upper bound
    jg continue      # If counter > upper bound, skip to continue

    # If we're here, we're within the specified range
    movb (%rsi), %al  # Load character from source
    movb %al, (%rdi)  # Copy character to destination

continue:
    incq %r15        # Increment counter
    incq %rdi        # Move to next char in destination
    incq %rsi        # Move to next char in source
    jmp loop_pstrijcpy  # Continue looping

invalid_input:
    movq $invalid_fmt, %rdi
    xorq %rax, %rax
    call printf
    jnp pstrijcpy_done

pstrijcpy_done:
    movq    %r8, %rax  # Note that return value must be in %rax, so we move the length there
    movq %rbp, %rsp
    popq %rbp
    ret               # Return the value in %rax


pstrcat:
    // incq %rdi   
    // movq    %rdi, %r8
    pushq %rbp
    movq %rsp, %rbp

    # look at the size of the strings
    movb (%rdi), %al  # Move the first byte at address %rdi into the lower 8 bits of %rax (%al)
    andq $0xFF, %rax  # Clear the upper 56 bits of %rax to ensure only the byte is preserved
    movq %rax, %r12

    movb (%rsi), %al  # Move the first byte at address %rdi into the lower 8 bits of %rax (%al)
    andq $0xFF, %rax  # Clear the upper 56 bits of %rax to ensure only the byte is preserved
    movq %rax, %r13

    incq %rdi
    incq %rsi   
    movq    %rdi, %r8

    movq $0, %rcx
    addq %r13, %rcx
    addq %r12, %rcx

    cmpq $254, %rcx
    jg big_number

end_first_string:
        cmpb    $0, (%rdi)  # If reached to a null-byte (string end)
        je connent_strings
        incq %rdi
        jmp end_first_string

connent_strings:
    movb (%rsi), %al  # Load character from source
    movb %al, (%rdi)  # Copy character to destination

    incq %rsi
    incq %rdi
    cmpb $0, (%rsi)
    jne connent_strings
    movb $0, %al  # Load character from source
    movb %al, (%rdi)  # Copy character to destination
    jmp pstrcat_done

big_number:
    movq $cannot_cat_fmt, %rdi
    xorq %rax, %rax
    call printf

    jmp pstrcat_done
pstrcat_done:
    movq    %r8, %rax  # Note that return value must be in %rax, so we move the length there
    movq %rbp, %rsp
    popq %rbp
    ret               # Return the value in %rax