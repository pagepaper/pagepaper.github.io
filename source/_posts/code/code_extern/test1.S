.file   "test1.cpp"
 	        .text
 	        .align 2
 	.globl f
 	        .type   f, @function
 	f:
 	.LFB3:
 	        pushl   %ebp
 	.LCFI0:
 	        movl    %esp, %ebp
 	.LCFI1:
 	        movl    $1, %eax
 	        popl    %ebp
 	        ret
 	.LFE3:
 	        .size   f, .-f
 	        .align 2
 	.globl main
 	        .type   main, @function
 	main:
 	.LFB5:
 	        pushl   %ebp
 	.LCFI2:
 	        movl    %esp, %ebp
 	.LCFI3:
 	        subl    $8, %esp
 	.LCFI4:
 	        andl    $-16, %esp
 	        movl    $0, %eax
 	        subl    %eax, %esp
 	        call    f
 	        movl    $0, %eax
 	        leave
 	        ret
 	.LFE5:
 	        .size   main, .-main
 	        .section        .note.GNU-stack,"",@progbits
 	        .ident  "GCC: (GNU) 3.3.4"