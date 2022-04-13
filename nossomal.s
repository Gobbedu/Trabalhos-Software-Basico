.section .data
	inicio_heap: 	.quad 0
	Block_size:		.quad 4096
	LIVRE: 			.quad 0
	OCUPA:			.quad 1
	strinit:		.string ""
	straux: 		.string "brk[0 e 1]: %i %i\n"

.section .text

.globl nossomal, iniciaAlocador, finalizaAlocador, alocaMem, liberaMem, getBrk, getConteudo

# retorna o endereco de brk em rax 
getBrk:
	movq $12, %rax
	movq $0, %rdi
	syscall # brk comes on %rax, 
	ret		# returns %rax


#retorna em %rax o conteudo do endereco recebido em %rdi
getConteudo:
	movq (%rdi), %rax
	ret


iniciaAlocador:
	# ||<= %brk
	# | L | 4096 |  ---- 4096 ---- |<= %brk

	# chama printf antes pra alocar o buffer e nn atrapalhar a brk
	movq $strinit, %rdi
	call printf

	# pergunta pro SO endereco de brk e salva 	
	movq $12, %rax							# comando: cade brk?
	movq $0, %rdi							# me diga pfr
	syscall 								# brk vem no %rax
	movq %rax, inicio_heap					# inicio_heap = endereco de brk

	# aumenta heap em Block_size bytes + IG
	movq inicio_heap, %rbx					# rbx = brk
	movq Block_size, %r10					# r10 = Block_size
	addq $16, %r10							# r10 += sizeof(IG)
	addq %r10, %rbx 						# rbx = inicio_heap + Block_size*8 + 16

	# empurra brk pra baixo => brk = brk + 8*Block_size
	movq $12, %rax
	movq %rbx, %rdi
	syscall

	# registra INFORMACOES GERENCIAIS (IG)
	# inicio_heap = Livre/Ocupado
	# 8(inicio_heap) = tamanho Livre/Ocupado  
	# tam total disp = tam bloco - tam IG
	movq inicio_heap, %rax					# rax = inicio_heap
	movq Block_size, %rbx					# rbx = 4096
	movq %rbx, 8(%rax)						# inicio_heap[1] = tam disponivel (4096)
	movq LIVRE, %rbx						# rbx = LIVRE
	movq %rbx, (%rax)						# inicio_heap[0] = bloco seguinte esta LIVRE

	movq (%rax), %rsi 
	movq 8(%rax), %rdx
	movq $straux, %rdi
	call printf

	ret


finalizaAlocador:
	# diminui brk para o endereco inicial
	movq $12, %rax 							# resize brk
	movq inicio_heap, %rdi					# nova altura
	syscall 
	
	ret


nossomal:
	call getBrk 							# devolve altura inicial de brk
	ret


