# get printf and scanf
.extern printf 
.extern scanf
.extern rand

.section .data
user_string:
    .space 255, 0x0

.section .rodata # all of the const strings
random_num:
    .string "Enter tne random number: "
num_seeds:
    .string "Enter configuration seeds: "
easy_mode:
    .string "Would you like to play in easy mode? (y/n) "
incorrect:
    .string "\nincorrect"
guess:
    .string "What is your guess: "
scanf_fmt:
    .string "%255s"
y:
    .string "y"
n:
    .string "n"

# start the main function
.section .text
.globl main
.type	main, @function
main:
    # Enter
    pushq %rbp
    movq %rsp, %rbp 

    # printf the configuration
    movq $num_seeds, %rdi
    xorq %rax, %rax # reset the rax register
    call printf

    # Read the string
    movq $scanf_fmt, %rdi
    movq $user_string, %rsi
    xorq %rax, %rax
    call scanf


  #  # call random
  #  xorq %rax, %rax
  #  call rand
    # ranadom 
 #   movq %rax, %rsi   # random number as argument
 #   xorq %rax, %rax   # zero out rax for printf (printf expects rax = 0)
 #   call printf    # call printf to display the result

    # i will put a scnf number instead random

    # "scanf the random number"
    movq $random_num, %rdi
    xorq %rax, %rax # reset the rax register
    call printf

    # Read the string
    movq $scanf_fmt, %rdi
    movq $user_string, %r8
    xorq %rax, %rax
    call scanf




    # printf the configuration
    movq $easy_mode, %rdi
    xorq %rax, %rax # reset the rax register
    call printf

    # Read the string (if the user want easy)
    movq $scanf_fmt, %rdi
    movq $user_string, %rsi
    xorq %rax, %rax
    call scanf
    
    # put y,n in registers to equal
    movq $y, (%rbx)
    movq $n, %rcx
    movq $user_string, %rdi # move the answer of the user to the rdi register
    # movb (%rdi), %al # move the first letter to the al register

    # check if the user enter y or n and jmp to the label
    cmpq (%rdi), (%rbx)
    je .easy
    jne .hard


.easy:
    movq $guess, %rdi
    xorq %rax, %rax # reset the rax register
    call printf
    jmp .done

.hard:
    movq $incorrect, %rdi
    xorq %rax, %rax # reset the rax register
    call printf
    jmp .done
    
.try_guess:
    

# Exit
.done:
    xorq %rax, %rax
    movq %rbp, %rsp
    popq %rbp
    ret
