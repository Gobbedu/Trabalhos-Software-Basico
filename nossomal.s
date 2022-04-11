.section .data
	EnderinitBRK: 	.quad 0
	straux: 		.string ""

.section .text

.globl nossomal, inicia_alocador, finaliza_alocador, alocaMem, freeMem


inicia_alocador:
	# chama printf antes pra alocar o buffer e nn atrapalhar a brk
	movq $straux, %rdi
	call printf

	# pergunta pro SO endereco de brk e salva 	
	movq $12, %rax
	movq $0 , %rdi
	syscall
	movq %rax, EnderinitBRK
	ret


finaliza_alocador:
	call inicia_alocador


	ret


nossomal:
	movq $9000, %rax

	ret


