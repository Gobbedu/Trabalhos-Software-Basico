.section .data
	inicio_heap: 	.quad 0
	Block_size:		.quad 4096
	LIVRE: 			.quad 0
	OCUPA:			.quad 1
	straux: 		.string ""

.section .text

.globl nossomal, inicia_alocador, finaliza_alocador, alocaMem, freeMem, getBrk

# retorna o endereco de brk em rax 
getBrk:
	movq $12, %rax
	movq $0, %rdi
	syscall # brk comes on %rax, 
	ret		# returns %rax

inicia_alocador:
	# ||<= %brk
	# | L | 4096 |  ---- 4096 ---- |<= %brk

	# chama printf antes pra alocar o buffer e nn atrapalhar a brk
	movq $straux, %rdi
	call printf

	# pergunta pro SO endereco de brk e salva 	
	movq $12, %rax							# comando: cade brk?
	movq $0, %rdi							# me diga pfr
	syscall 								# brk vem no %rax
	movq %rax, inicio_heap						# inicio_heap = endereco de brk

	# aumenta heap em Block_size bytes + IG
	movq inicio_heap, %rbx						# rbx = brk
	movq Block_size, %r10					# r10 = Block_size
	# imul $8, %r10							# r10 *= 8
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
	movq inicio_heap, %rax						# rax = inicio_heap
	movq Block_size, %rbx					# rbx = 4096
	movq %rbx, 8(%rax)						# inicio_heap[1] = tam disponivel (4096)
	movq LIVRE, %rbx						# rbx = LIVRE
	movq %rbx, (%rax)						# inicio_heap[0] = bloco seguinte esta LIVRE


finaliza_alocador:

	# reposiciona brk para o endereco inicial (TODO)
	# movq $12, %rax 							# resize brk
	# movq inicio_heap, %rdi							# nova altura
	# syscall 
	
	# call getBrk								# devolve altura inicial de brk
	# movq inicio_heap, %rax


nossomal:
	call getBrk 							# devolve altura inicial de brk
	ret


