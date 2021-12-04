# 318175197 Idan Ziv
    .section    .rodata
    .align 8

.JUMP_TABLE:    # cases for switch case
    .quad   .f_pstrlen    # case 50
    .quad   .f_default    # case 51 - default
    .quad   .f_replaceChar    # case 52
    .quad   .f_pstrijcpy    # case 53
    .quad   .f_swapCase    # case 54
    .quad   .f_pstrijcmp    # case 55
    .quad   .f_default    # case 56 - default 
    .quad   .f_default    # case 57 - default
    .quad   .f_default    # case 58 - default
    .quad   .f_default    # case 59 - default
    .quad   .f_pstrlen    # case 60

    # literals for pstr.h functions
    msg_pstrlen:     .string    "first pstring length: %d, second pstring length: %d\n"
    msg_replaceChar:    .string    "old char: %c, new char: %c, first string: %s, second string: %s\n"
    format_pstr_info:   .string    "length: %d, string: %s\n"
    msg_pstrijcmp:    .string    "compare result: %d\n"
    msg_default_case:    .string    "invalid option!\n"
    # literals for scanf, printf
    format_scan_int:     .string    " %d"
    format_scan_char:    .string    " %c"
    format_scan_string:    .string    " %s"

    .text
    .global run_func
    .type run_func, @function
run_func:   # the case number is in %rdi (%edi), the 1st pString in %rsi, the 2nd pString in %rdx
    # create stack frame to hold the pointers to pStrings and chars that will be scaned.
    pushq    %rbp
    movq    %rsp, %rbp
    # correcting the input offset to match the first case
    leaq    -50(%rdi), %rbx # setting the choice to match the range
    cmpq    $10, %rbx # check if the choice is in range
    ja    .f_default # if the number is not in range we ha
    jmp    *.JUMP_TABLE(,%rbx,8)    # jump to the proper case

.f_pstrlen:
    # getting the length of the 1st pString
    movq    %rsi, %rdi    # send the pointer as the parameter
    call    pstrlen
    movq    %rax, %r11    # saving the return value from pstrlen to the stack

    # getting the length of the 2nd pString
    movq    %rdx, %rdi    # send the pointer as the parameter
    call    pstrlen
    movq    %rax, %r10    # saving the return value from pstrlen to the stack

    # print the message
    movq    $msg_pstrlen, %rdi    # pasing the proper message to printf
    movq    %r11, %rsi    # passing the length of the 1st pString
    movq    %r10, %rdx    # passing the length of the 2nd pString
    xorq    %rax, %rax    # set %rax to 0
    call    printf

    # Jump to end sequence to deallocate the stack frame
    jmp    .end_sequence

.f_replaceChar:
    # allocate memory for the two chars on the stack - 1-byte * 2
    subq    $16, %rsp    # this makes rsp as the offset, subtracted 16 in order to keep the alignment
    
    # push the pointers to the stack
    pushq    %rdx    # pointer to the 2nd pString
    pushq    %rsi    # pointer to the 1st pString
    
    # scan the oldChar
    movq    $format_scan_char, %rdi    # pass the proper scan format
    leaq    16(%rsp), %rsi    # oldChar will be saved on the stack
    xorq    %rax, %rax    # set %rax to 0
    call    scanf

    # scan the newChar
    movq    $format_scan_char, %rdi    # pass the proper scan format
    leaq    17(%rsp), %rsi    # newChar will be saved on the stack
    xorq    %rax, %rax    # set %rax to 0
    call    scanf

    # call replaceChar on the 1st pString
    popq    %rdi    # the pointer to the 1st pString
    movq    %rdi, %r12    # create a copy of the pointer for later use
    leaq    8(%rsp), %rsi    # pass oldChar as an argument to replaceChar
    leaq    9(%rsp), %rdx    # pass newChar as an argument to replaceChar    
    call    replaceChar

    # call replace char on the 2nd pString
    popq    %rdi    # the pointer to the 2nd pString, the are now in of set of 0,1
    movq    %rdi, %r14    # create a copy of the pointer for later use
    leaq    (%rsp), %rsi    # pass oldChar as an argument to replaceChar
    leaq    1(%rsp), %rdx    # pass newChar as an argument to replaceChar
    call    replaceChar

    # printing the result
    movq    $msg_replaceChar, %rdi    # pass the proper format for printf
    movzbq    (%rsp), %rsi    # pass the oldChar
    movzbq    1(%rsp), %rdx    # pass the newChar
    # pass the pointer, recall they must be adjusted to the start of the string itself
    movq    %r12, %rcx    # 1st pString pointer
    incq    %rcx
    movq    %r14, %r8     # 2nd pString pointer
    incq    %r8
    xorq    %rax, %rax    # set %rax to 0
    call    printf
    # restoring the stack frame
    jmp    .end_sequence


.f_pstrijcpy:
    pushq    %rbp
    movq    %rsp, %rbp
    # save the stack frame, create room for 
    subq    $8, %rsp    # room for 2 ints from the user, using 16 to keep the alignmet of the stack pointer
                        # as a multiple of 16
     # save the pointers to the strings
    pushq    %rdx    # pointer to the 2nd pString
    pushq    %rsi    # pointer to the 1st pString
    
    # scanning the 1st index
    movq    $format_scan_int, %rdi    # pass the proper format
    leaq    16(%rsp), %rsi    # pass the memory address 
    xorq    %rax, %rax    # set %rax to 0
    call    scanf

    # scannig the 2nd index
    movq    $format_scan_int, %rdi    # pass the proper format
    leaq    20(%rsp), %rsi    # pass the memory address
    xorq    %rax, %rax    # set %rax to 0
    call    scanf

    # calling pstrijcpy
    popq    %rdi    # 1st pString is the first element on the stack and is the dest argument.
                    # reduce the offset of the stack by 8
    movq    %rdi, %r12    # save a copy for later use (printing the case message)
    popq    %rsi    # 1st pString is the second element and is the src argument.
                    # reduce the offset of the stack by 8
    movq    %rsi, %r13    # save a copy for later use (printing the case message)
    movl    (%rsp), %edx    # passing the index i
    movl    4(%rsp), %ecx    # passing the index j
    call    pstrijcpy

    # printing the 1st pString - src
    movq    $format_pstr_info, %rdi    # pass the proper format for printf
    movzbq    (%r12), %rsi    # passing the length of the pString to %rsi
    incq    %r12    # adjusting the pointer to string part
    movq    %r12, %rdx    # passing the pointer to the string to %rdx
    xorq    %rax, %rax    # set %rax to 0
    pushq   %r11    # to keep the stack pointer alignmet
    call    printf
    popq    %r11

    # printing the 2nd pString - dest
    movq    $format_pstr_info, %rdi    # pass the proper format for printf
    movzbq    (%r13), %rsi    # passing the length of the pString to %rsi
    incq    %r13    # adjusting the pointer to string part
    movq    %r13, %rdx    # passing the pointer to the string to %rdx
    xorq    %rax, %rax    # set %rax to 0
    call    printf

    # reallocating data
    movq    %rbp, %rsp
    popq    %rbp
    jmp    .end_sequence

.f_swapCase:
    # save the pointer of 2nd pString (%rdx)
    pushq    %rdx
    movq    %rsi, %rdi    # pass 1st pString to swapCase
    call    swapCase

    # print result of swapCase for 1st pString
    movq    $format_pstr_info, %rdi    # pass the proper format
    movzbq    (%rax), %rsi    # pass the pstr's length as argument
    incq    %rax    # adjust pointer to string part
    movq    %rax, %rdx    # pass the pstr's string as argument
    xorq    %rax, %rax    # set %rax to 0
    call    printf

    # call swapCase on 2nd pString
    popq    %rdi    # pass 2nd pString to swapCase
    call    swapCase
    
    # print result of swapCase on 2nd pString
    movq    $format_pstr_info, %rdi
    movzbq     (%rax), %rsi    # pass pstr's lenght as argument
    incq    %rax    # adjust pointer to string part
    movq    %rax, %rdx    # pass the pstr's string as argument
    xorq    %rax, %rax    # set %rax to 0
    call printf

    jmp    .end_sequence

.f_pstrijcmp:
    # set new stack frame
    pushq    %rbp
    movq    %rsp, %rbp
    # create space for two ints
    subq    $8, %rsp    # two ints => 4 * 2 = 8
    # save the pointers to pString
    pushq    %rdx    # the pointer to the 2nd pString
    pushq    %rsi    # the pointer to the 2nd pString
    
    # scan the int i
    movq    $format_scan_int, %rdi    # pass the proper format fpr scanf
    leaq    16(%rsp), %rsi    # pass the address of int i
    xorq    %rax, %rax    # set %rax to 0
    call    scanf
    
    # scan the int j
    movq    $format_scan_int, %rdi    # pass the proper format for scanf
    leaq    20(%rsp), %rsi    # pass the address of int j
    xorq    %rax, %rax
    call    scanf

    # send the arguments for pstrijcmp
    popq    %rdi    # pointer to 1st pString
    movq    %rdi, %r13    # create a copy for later use (printing compare result)
    popq    %rsi    # pointer to 2nd pString
    movq    %rsi, %r14    # Note: the offset from %rsp to the ints is now 0 and 4
    movl    (%rsp), %edx    # pass index i
    movl    4(%rsp), %ecx    # pass index j
    call    pstrijcmp
    
    movl    %eax, %esi    # save compare result
    movq    $msg_pstrijcmp, %rdi    # pass the proper format for printf
    xorq    %rax, %rax    # set %rax to 0
    call    printf

    movq    %rbp, %rsp
    popq    %rbp
    jmp    .end_sequence



.f_default:
    movq    $msg_default_case, %rdi    # pass the proper format for printf
    xorq    %rax, %rax    # set %rax to 0
    call printf
    jmp    .end_sequence   # restore the stack frame

.end_sequence:
    # restore stack frame
    movq    %rbp, %rsp
    popq    %rbp
    ret
