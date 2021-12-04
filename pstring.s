# 318175197 Idan Ziv
.section .rodata
    .align 8
    format_invalidInput: .string "invalid input!\n"

    .text
    .global pstrlen
    .type pstrlen, @function
pstrlen: # the pstring address is saved on %rdi
    # There is no need to create a stack frame, since we are not using any local vars
    movzbq (%rdi), %rax # the length of the pstring is the on the first address of the pstring
    ret

    .global replaceChar
    .type replaceChar, @function
replaceChar: # %rdi- pointer to pstring, %rsi - oldChar, %rdx - new char
    # Note: we are changing the pString itself, so we don't create a new pString,
    #       but we return the same pointer that we got
    movq    %rdi, %rax    # setting the return value to be the pointer we are working with
    # create a pointer to the end of the string
    movzbq    (%rdi), %r9     # saving the size of the pString
    leaq    (%rdi, %r9), %rdi    # creating a pointer to the end of the string
    movb    (%rsi), %r10b    # Note: we have pointers to chars saved in the memory, so we need to derefernce
    movb    (%rdx), %r11b    # them in order to perfom the comparisons and rewrites
    
    # starting from the end of the string, all the way down
    # when we reach to the address of the size we will stop (since we covered the whole string)
.replaceChar_doWhile:
    cmpb    %r10b, (%rdi)    # check if the current char in the string equals to the oldChar (which is save as a byte)
    je    .replaceChar_makeSwap   
    decq    %rdi    # == pstr--
    cmpq    %rdi, %rax    # check if we reached the end
    jl    .replaceChar_doWhile    # continue the loop
    ret
.replaceChar_makeSwap:
    movb    %r11b, (%rdi)    # write the newChar instead of the oldChar)
    decq    %rdi    # == pstr--
    cmpq    %rdi, %rax    # check if we reach the end
    jl    .replaceChar_doWhile
    ret
    

    .global pstrijcpy
    .type pstrijcpy, @function
pstrijcpy: # %rdi - dst, %rsi - src, %rdx -i, %rcx - j
    pushq   %r11
    movq    %rdi, %rax
    # check the input
    cmpl %edx, %ecx    # check if i > j
    jl    .pstrijcpy_invalidInput
    cmpb    $0, %dl    # check if i < 0
    jl    .pstrijcmp_invalidInput
    cmpb    (%rdi), %dl    # check if j > dst.len
    jge    .pstrijcpy_invalidInput
    cmpb    (%rsi), %cl    # check if j > src.len
    jge    .pstrijcpy_invalidInput    
    # if the input is valid we can continute
    incq    %rdi    # adjust pointer to the string part
    incq    %rsi    # adjust pointer to the string part
    movq    %rsi, %r11    # a copy of the src pointer
    leaq    (%rdi, %rdx), %rdi   # pointer to dst + i
    leaq    (%rsi, %rdx), %rsi   # pointer to src + i
    leaq    (%r11, %rcx), %r11   # pointer to src + j
    incq    %r11    # this points to src + j +1 - we will use it as a sentry to finish the scan
.pstrijcpy_doWhile:
    # rewrite the char, takes two steps since we need to write from memory to memory
    movb    (%rsi), %r8b    # src[i] -> temp
    movb    %r8b, (%rdi)    # temp -> dst[i]
    incq    %rsi    # src++
    incq    %rdi    # dst++
    # check if the stop condition is meant
    cmpq    %rsi, %r11
    jne    .pstrijcpy_doWhile
    popq    %r11
    ret
.pstrijcpy_invalidInput:
    popq    %r11
    movq    $format_invalidInput, %rdi    # pass proper fomrat to printf
    xorq    %rax, %rax    # set %rax to 0
    call    printf
    ret

    .global swapCase
    .type swapCase, @function
swapCase: # %rdi - *pstr
    movq    %rdi, %rax    # save the original pointer as the return value
    movzbq    (%rdi), %rbx    # set up counter = pstr.len
    # adjust the pointer to the string part
    incq    %rdi    # pstr++ 
.swapCase_checkChar: # checking if the value of the current char is in a proper range
    # check if pstr[i] < 65 or pstr[i] > 122 - if so it is not a char
    cmpb $65,   (%rdi) # ?: pstr[i] >= 65
    jl .swapCase_nextChar
    cmpb $122, (%rdi) # ?: pstr[i] <= 122
    ja .swapCase_nextChar
    # check if an upper case
    cmpb $90, (%rdi) # ?: pstr[i] <= 90
    jb .swapCase_isUpperCase
    # check if in the range between upper and lower case
    cmpb $97, (%rdi) # ?: pstr[i] < 97
    jb .swapCase_nextChar
    # check if a lower case
    cmpb $122, (%rdi)
    jb .swapCase_isLowerCase

.swapCase_nextChar:
    incq    %rdi # pstr++
    subb    $1, %bl    # counter--
    # check if we reached the begining
    cmpb $0, %bl    # check if counter == 0
    jne .swapCase_checkChar # if it not we haven't finished - go back to the loop
    ret
.swapCase_isUpperCase:
    # add '32' to the value - the difference between the ASCII value of upper and lower case is 32
    addq $32, (%rdi)
    # go next char
    jmp .swapCase_nextChar
.swapCase_isLowerCase:
    # subtract '32' to the value - the difference between the ASCII value of upper and lower case is 32
    subq $32, (%rdi)
    # go next char
    jmp .swapCase_nextChar

    .global pstrijcmp
    .type pstrijcmp, @function
pstrijcmp: # %rdi - pstr1, %rsi - pstr2, %rdx - i, %rcx - j
    # check input
    cmpl %edx, %ecx    # check if i > j
    jl    .pstrijcmp_invalidInput
    cmpb    $0, %dl    # check if i < 0
    jl    .pstrijcmp_invalidInput
    cmpb    (%rdi), %dl    # check if j > dst.len
    jge   .pstrijcmp_invalidInput
    cmpb    (%rsi), %cl    # check if j > src.len
    jge   .pstrijcmp_invalidInput

    # If input is valid, create pointers
    incq    %rdi    # adjust pointer to the string part
    incq    %rsi    # adjust pointer to the string part
    movq    %rdi, %r11    # create a copy of the address, to reference the end of the range
    leaq    (%rdi, %rdx), %rdi    # pointer to pstr1 + i
    leaq    (%rsi, %rdx), %rsi    # pointer to pstr2 + i
    leaq    (%r11, %rcx), %r11    # pointer to pstr1 + j
    incq    %r11    # this points to pstr1 + j + 1 - we will use it as a sentry to finish the comparison
.pstrijcmp_doWhile:
    movb    (%rdi), %r12b    # pstr1[i] == pstr2[i] ?
    cmpb    %r12b, (%rsi)    # can't access memory to memory, so we use a buffer
    jl    .pstrijcmp_pstr1isBigger
    jg    .pstrijcmp_pstr2isBigger
    incq    %rdi    # pstr1++
    incq    %rsi    # pstr2++
    cmpq    %r11, %rdi    # check if we reached the end of the range
    jne    .pstrijcmp_doWhile
    movq    $0, %rax
    ret

.pstrijcmp_pstr2isBigger:
    movl    $-1, %eax    # set the compare result to 1
    ret
.pstrijcmp_pstr1isBigger:
    movl    $1, %eax     # set the compare result to -1
    ret

.pstrijcmp_invalidInput:
    movq    $format_invalidInput, %rdi    # pass the proper format for printf
    xorq    %rax, %rax    # set %rax to 0
    call    printf
    movl    $-2, %eax     # return the proper compare result
    ret
