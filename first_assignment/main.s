# Roei Derman 322467184
# get printf and scanf
.extern printf 
.extern scanf
.extern srand
.extern rand

.section .data
user_string: .long 0
random_number: .long 10
seeds_number: .long 10
counter_turns: .long 0
N: .long 10

.section .rodata # all of the const strings
num_seeds_print:
    .string "Enter configuration seed: "
easy_mode:
    .string "Would you like to play in easy mode? (y/n) "
incorrect:
    .string "Incorrect. "
guess:
    .string "What is your guess? "
scanf_fmt:
    .string "%255s"
scanf_fmt_integers:
    .asciz "%d"
y:
    .string "y"
greater_than:
    .string "Incorrect. Your guess was above the actual number ...\n"
lower_than:
    .string "Incorrect. Your guess was below the actual number ...\n"
congratz:
    .string "Congratz! You won %d rounds!"
game_over:
    .string "\nGame over, you lost :(. The correct answer was %d"
double_nothing:
    .string "Double or nothing! Would you like to continue to another round? (y/n) "

# start the main function
.section .text
.globl main
.type	main, @function
main:
    # Enter
    pushq %rbp
    movq %rsp, %rbp 

    movq $10, N

    # printf the configuration
    movq $num_seeds_print, %rdi
    xorq %rax, %rax # reset the rax register
    call printf

    # Read the string
    movq $scanf_fmt_integers, %rdi
    movq $seeds_number, %rsi
    xorq %rax, %rax
    call scanf

    movq seeds_number, %r13
    movq N, %r14
    
    movq seeds_number, %rdi # Seed value, can use any constant or read from input
    call srand  

    call rand 
    movq N, %rsi
    xorq %rdx, %rdx
    divq %rsi
    incq %rdx
    movq %rdx, random_number

    movq %r13, seeds_number
    movq %r14, N

    # printf if the user want easy mode or not
    movq $easy_mode, %rdi
    xorq %rax, %rax # reset the rax register
    call printf

    # Read the string (if the user want easy)
    movq $scanf_fmt, %rdi
    movq $user_string, %rsi
    xorq %rax, %rax
    call scanf
    
    # put y in registers to equal
    movq $y, %r8
    movq $user_string, %rdi # move the answer of the user to the rdi register
    movb (%rdi), %al # move the first letter to the al register

    # init the counters to 0
    movq $1, %r15 #r15 will keep the number of rounds

    movq $0, %r9
    movq %r9, counter_turns

    # check if the user enter y or n and jmp to the label
    cmpb %al, (%r8)
    je .easy_loop
    jne .hard_loop
    jmp .done

# easy mode
.easy_loop:
    cmpq $5, counter_turns
    je .game_over

    # print the guess message
    movq $guess, %rdi
    xorq %rax, %rax # reset the rax register
    call printf

    jmp .try_guess_easy # call to try gusesses from the user
    jmp .done

# user guess if i am in the easy mode
.try_guess_easy:
    # Read the guess of the user
    movq $scanf_fmt_integers, %rdi
    movq $user_string, %rsi
    xorq %rax, %rax
    call scanf

    movq $user_string, %rdi # move the answer of the user to the rdi register
    movw (%rdi), %cx # move the first letter to the cl register

    jmp .compare_easy # jump to compare the numbers

# compare if i am in the easy mode
.compare_easy:
    
   #compare between the numbers if bigger or smaller
    movq $random_number, %rdi
    movw (%rdi), %bx

    cmp %bx, %cx
    jg .greater # if greater jump to greater label
    jl .lower # if lower jump to lower label
    je .equals_easy 

.greater:
    # printf the if the number is greater
    movq $greater_than, %rdi
    xorq %rax, %rax # reset the rax register
    call printf

    incq counter_turns # increase the couner of turns
    jmp .easy_loop

.lower:
    # printf the if the number is greater
    movq $lower_than, %rdi
    xorq %rax, %rax # reset the rax register
    call printf

    incq counter_turns # increase the couner of turns
    jmp .easy_loop

# hard mode
.hard_loop:
    # check if done too mant turns
    cmpq $5, counter_turns
    je .game_over

    # print the guess message
    movq $guess, %rdi
    xorq %rax, %rax # reset the rax register
    call printf

    jmp .try_guess_hard

.next_hard:
    incq counter_turns # counter of turns
    jmp .hard_loop

# compare if i am in the hard mode
.compare_hard:
    movq $random_number, %rdi #move the random number to a register
    movw (%rdi), %bx

    cmpw %bx, %cx #compare between the two numbers
    je .equals_hard
    jne .not_equals

.equals_easy:

    movq $double_nothing, %rdi
    xorq %rax, %rax # reset the rax register
    call printf

    # Read the string (if the user want easy)
    movq $scanf_fmt, %rdi
    movq $user_string, %rsi
    xorq %rax, %rax
    call scanf
    
    # put y in registers to equal
    movq $y, %r8
    movq $user_string, %rdi # move the answer of the user to the rdi register
    movb (%rdi), %al # move the first letter to the al register


    # check if the user enter y or n and jmp to the label
    cmpb %al, (%r8)
    je .random_easy

    # check why number isn't print
    movq $congratz, %rdi
    movq %r15, %rsi
    xorq %rax, %rax # reset the rax register
    call printf
    jmp .done


.equals_hard:

    movq $double_nothing, %rdi
    xorq %rax, %rax # reset the rax register
    call printf

    # Read the string (if the user want double)
    movq $scanf_fmt, %rdi
    movq $user_string, %rsi
    xorq %rax, %rax
    call scanf

    movq $user_string, %rdi # move the answer of the user to the rdi register
    movb (%rdi), %al # move the first letter to the al register

    # put y,n in registers to equal
    movq $y, %r8
    # check if the user enter y or n and jmp to the label
    cmpb %al, (%r8)
    je .random_hard

    # check why number isn't print
    movq $congratz, %rdi
    movq %r15, %rsi
    xorq %rax, %rax # reset the rax register
    call printf
    jmp .done

.not_equals:
    # print the incorrect message
    movq $incorrect, %rdi
    xorq %rax, %rax # reset the rax register
    call printf
    jmp .next_hard



# user guess if i am in the hard mode
.try_guess_hard:
    # Read the guess of the user
    movq $scanf_fmt_integers, %rdi
    movq $user_string, %rsi
    xorq %rax, %rax
    call scanf

    movq $user_string, %rdi # move the answer of the user to the rdi register
    movw (%rdi), %cx # move the first letter to the cl register


    jmp .compare_hard
    jmp .done

.random_easy:
    movq %r14, N
    movq %r13, seeds_number

    # multiply N by 2
    movl N, %eax       # Move N into eax register
    imull $2, %eax     # Multiply eax by 2
    movl %eax, N       # Store result back in N

    # multiply seed by 2
    movl seeds_number, %eax       # Move N into eax register
    imull $2, %eax     # Multiply eax by 2
    movl %eax, seeds_number       # Store result back in N

    #store the values of n, seed_number,  in registers
    movq N, %r14
    movq seeds_number, %r13
    
    
    movq seeds_number, %rdi # Seed value, can use any constant or read from input
    call srand  

    call rand 
    movq N, %rsi
    xorq %rdx, %rdx
    divq %rsi
    incq %rdx
    movq %rdx, random_number

    movq %r13, seeds_number
    movq %r14, N


    incq %r15 # incrase the number of rounds
    movq $0, counter_turns # reset the number of rounds
    jmp .easy_loop


.random_hard:
    movq %r14, N
    movq %r13, seeds_number

    # multiply N by 2
    movl N, %eax       # Move N into eax register
    imull $2, %eax     # Multiply eax by 2
    movl %eax, N       # Store result back in N

    # multiply seed by 2
    movl seeds_number, %eax       # Move N into eax register
    imull $2, %eax                # Multiply eax by 2
    movl %eax, seeds_number       # Store result back in N

    #store the values of n, seed_number,  in registers
    movq N, %r14
    movq seeds_number, %r13
    
    
    movq seeds_number, %rdi # Seed value
    call srand  

    call rand 
    movq %rax, %rdi
    movq N, %rsi
    xorq %rdx, %rdx
    divq %rsi
    incq %rdx
    movq %rdx, random_number

    movq %r13, seeds_number
    movq %r14, N

    incq %r15 # incrase the number of rounds
    movq $0, counter_turns
    jmp .hard_loop


.game_over:
    # print that the game is over
    movq $game_over, %rdi
    movq random_number, %rsi
    xorq %rax, %rax # reset the rax register
    call printf

# Exit
.done:
    xorq %rax, %rax
    movq %rbp, %rsp
    popq %rbp
    ret
