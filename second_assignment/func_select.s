.extern	printf
.extern	scanf

.section .rodata
print_fmt: .string "%d"
print_fmt_string: .string "%s"
print_fmt_pstring: .string "first pstring length: %d, second pstring length: %d"
invalid_fmt: .string "invalid option!\n"
swap_fmt: .string "length: %d, string: %s\n"
format_scan_num:     .string "%lu"
print_fmt_pstijcpy: .string "length: %lu, string: %s\nlength: %lu, string: %s\n"
print_cat_fmt: .string "length: %lu, string: %s\nlength: %lu, string: %s\n"

.section .text
    .global run_func

run_func:
    # Enter
    pushq %rbp
    movq %rsp, %rbp

    #(rbp - 8) - 8 bytes align
    #(rbp - 16) - 8 bytes second string
    #(rbp - 24) - 8 bytes first string
    #(rbp - 32) - 8 bytes number
    sub $8, %rsp
    push %rdx 
    push %rsi
    push %rdi

    #call the label with the number we got
    cmpq $37, -32(%rbp)
    je .L37
    cmpq $34, -32(%rbp)
    je .L34
    cmpq $33, -32(%rbp)
    je .L33
    cmpq $31, -32(%rbp)
    je .L31
    jmp .INVALID

    jmp .done

.L31:
# call the pstrlen function with the first string
    movq -24(%rbp), %rdi
    call pstrlen
    movq %rax, %r14

# call the pstrlen function with the second string and print
    movq -16(%rbp), %rdi
    call pstrlen
    movq %rax, %rdx
    movq %r14, %rsi
    movq $print_fmt_pstring, %rdi
    xorq %rax, %rax
    call printf

    jmp .done
.L33:
    # call the swap function with the first string
    movq -24(%rbp), %rdi
    call swapCase
    movq %rax, %r12

    # check the length of the first string 
    movq -24(%rbp), %rdi
    call pstrlen
    movq %rax, %r9

    #print the details of the first string
    movq %r12, %rdx
    movq %r9, %rsi
    movq $swap_fmt, %rdi
    xorq %rax, %rax
    call printf

    # call the swap function with the second string
    movq -16(%rbp), %rdi
    call swapCase
    movq %rax, %r13

    # check the length of the second string
    movq -16(%rbp), %rdi
    call pstrlen
    movq %rax, %r15

    # print the second string and his length
    movq %r13, %rdx
    movq %r15, %rsi
    movq $swap_fmt, %rdi
    xorq %rax, %rax
    call printf

    jmp .done
.L34:
    subq $16, %rsp

    # Get a number from the user (i)
    movq    $format_scan_num, %rdi
    leaq    -40(%rbp), %rsi
    call    scanf
    # Get a number from the user (j)
    movq    $format_scan_num, %rdi
    leaq    -48(%rbp), %rsi
    call    scanf

    # check the length of the second string
    movq -24(%rbp), %rdi
    call pstrlen
    movq %rax, %r12

    # check the length of the second string
    movq -16(%rbp), %rdi
    call pstrlen
    movq %rax, %r13

    # move the arguments to the function
    movq -24(%rbp), %rdi
    movq -16(%rbp), %rsi
    movq -40(%rbp), %rdx
    movq -48(%rbp), %rcx
    call pstrijcpy

    movq -16(%rbp), %r14
    incq %r14 
    
    # move all the arguments to the function
    movq %r12, %rsi
    movq %rax, %rdx
    movq %r13, %rcx
    movq %r14, %r8
    movq $print_fmt_pstijcpy, %rdi
    xorq %rax, %rax
    call printf
    jmp .done
.L37:
    movq -24(%rbp), %rdi
    movq -16(%rbp), %rsi

    # look at the size of the strings
    movb (%rdi), %al  # Move the first byte at address %rdi into the lower 8 bits of %rax (%al)
    andq $0xFF, %rax  # Clear the upper 56 bits of %rax to ensure only the byte is preserved
    movq %rax, %r12

    movb (%rsi), %al  # Move the first byte at address %rdi into the lower 8 bits of %rax (%al)
    andq $0xFF, %rax  # Clear the upper 56 bits of %rax to ensure only the byte is preserved
    movq %rax, %r13
    

    movq $0, %rcx
    addq %r13, %rcx
    addq %r12, %rcx

    cmpq $254, %rcx
    jg big_number_select

    jmp small_number_select


    // movq -24(%rbp), %rdi
    // movq -16(%rbp), %rsi
    // call pstrcat
    // // movq %rax, %r14

big_number_select:
    # call the swap function with the first string
    movq -16(%rbp), %rdi
    call pstrlen
    movq %rax, %r13

    # check the length of the first string 
    movq -24(%rbp), %rdi
    call pstrlen
    movq %rax, %r12

    movq -24(%rbp), %rdi
    movq -16(%rbp), %rsi
    call pstrcat

    movq -16(%rbp), %r14
    incq %r14

    movq %r12, %rsi
    movq %rax, %rdx
    movq %r13, %rcx
    movq %r14, %r8
    movq $print_cat_fmt, %rdi
    xorq %rax, %rax
    call printf

    jmp .done

small_number_select:

    // // movq -24(%rbp), %rdi
    // // movq -16(%rbp), %rsi
    // // call pstrcat

  #  addq %r13, %r12

     # call the swap function with the first string
    movq -16(%rbp), %rdi
    call pstrlen
    movq %rax, %r13

    # check the length of the first string 
    movq -24(%rbp), %rdi
    call pstrlen
    movq %rax, %r12

    movq -24(%rbp), %rdi
    movq -16(%rbp), %rsi
    call pstrcat

    addq %r13, %r12

    movq -16(%rbp), %r14
    incq %r14

    movq %r12, %rsi
    movq %rax, %rdx
    movq %r13, %rcx
    movq %r14, %r8
    movq $print_cat_fmt, %rdi
    xorq %rax, %rax
    call printf

    jmp .done
.INVALID:
    movq $invalid_fmt, %rdi
    call printf

    jmp .done

.done:
    #leave
    movq	%rbp, %rsp
	popq	%rbp
	ret

