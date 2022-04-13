.globl main
.section .data
scanformat:
    .ascii "%499s\0"
outformat:
    .ascii "%s\n\0"
.section .text
.equ LOCAL_BUFFER, -8
main:
    # Aloque uma variável local (alinhada a 16 bytes)
    enter $16, $0
    # Obtenha a memória e armazene-a em nossa variável local
    movq $500, %rdi
    call malloc
    movq %rax, LOCAL_BUFFER(%rbp)
    movq $5, (%rax)
    # Leia os dados do stdin
    movq stdin, %rdi
    movq $scanformat, %rsi
    movq LOCAL_BUFFER(%rbp), %rdx
    movq $0, %rax
    call fscanf
    # Escreva os dados para stdout
    movq stdout, %rdi
    movq $outformat, %rsi
    movq LOCAL_BUFFER(%rbp), %rdx
    movq $0, %rax
    call fprintf
    # Libere o buffer
    movq LOCAL_BUFFER(%rbp), %rdi
    call free
    # Return
    movq $0, %rax
    leave
    ret
