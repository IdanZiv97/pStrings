# 318175197 Idan Ziv

    .section .rodata
    .align 8
    format_scan_int:    .string "%d"    # format to be passed as the 1st argument for scaning an int
    format_scan_string:   .string "%s"    # format to be passed as the 1st argument for scaning a string

	.text
	.global   run_main
	.type   run_main, @function
run_main:

    # create the stack frame for run_main
    pushq    %rbp  
    movq    %rsp ,%rbp    # setting the rbp as the current rsp
    subq    $528, %rsp    # init 528 bytes in the stack for the next varibales. (to allign the stack by 16)
    # Note: the memory needed for the proccess is actualy 520 bytes (256 bytes per pString, and the choice 4 bytes) but
    # the number is not divisible by 16, which is required by scanf. So I addd 8 bytes (520 / 16 = 32.5) to make sure the
    # stack pointer is aligned

    # getting the 1st pString

    # getting the length
    movq    $format_scan_int, %rdi    # pass the proper scan format as the 1st argument
    leaq  	-528(%rbp), %rsi    # pass the address in the stack frame of the 1st pstring's length
    movq  	$0, %rax    # set %rax to 0
    call  	scanf
    # getting the string
    movq  	$format_scan_string, %rdi    # pass the proper scan format as the 1st argument
    leaq  	-527(%rbp), %rsi    # pass the address in the stack frame of the 1st pstring's string
    movq  	$0, %rax    # set %rax to 0
    call  	scanf

    # getting the 2nd pString

    # getting the length
    movq    $format_scan_int, %rdi    # pass the proper scan format as the 1st argument
    leaq  	-272(%rbp), %rsi    # pass the address in the stack frame of the 2nd pstring's length
    movq  	$0, %rax    # set %rax to 0
    call  	scanf
    # getting the string
    movq  	$format_scan_string, %rdi    # pass the proper scan format as the 1st argument
    leaq  	-271(%rbp), %rsi    # pass the address in the stack frame of the 2nd pstring's string
    movq  	$0, %rax    # set %rax to 0
    call  	scanf

    # getting the user's choice

    movq    $format_scan_int, %rdi    # pass the proper scan foramt as the 1st argument
    leaq  	-16(%rbp), %rsi    # pass the address in the stack frame of the user's choice int
    movq  	$0, %rax    # set %rax to 0
    call  	scanf

    # calling run_func in order to perform the user's choice, according to the jump table
    movl    -16(%rbp), %edi    # passing the choice of the user as an argument to the function
                               # this way we make sure the upper 32-bit are set to 0
    leaq    -528(%rbp), %rsi    # passing a pointer to the 1st pString
    leaq    -272(%rbp), %rdx    # passing a Pointer to the 2nd pString
    call    run_func

    # Clearing the stack frame of the proccess

    movq    %rbp ,%rsp
    popq   	%rbp
    ret
