.section .data
	topoInicialHeap: 	.quad 0
	Block_size:		.quad 4096
	LIVRE: 			.quad 0
	OCUPA:			.quad 1
	straux: 		.string ""

.section .text

.globl nossomal, iniciaAlocador, finalizaAlocador, alocaMem, liberaMem, getBrk

# retorna o endereco de brk em rax 
getBrk:
	movq $12, %rax
	movq $0, %rdi
	syscall # brk comes on %rax, 
	ret		# returns %rax

iniciaAlocador:
	# ||<= %brk
	# | L | 4096 |  ---- 4096 ---- |<= %brk

	# chama printf antes pra alocar o buffer e nn atrapalhar a brk
	movq $straux, %rdi
	call printf

	# pergunta pro SO endereco de brk e salva 	
	movq $12, %rax							# comando: cade brk?
	movq $0, %rdi							# me diga pfr
	syscall 								# brk vem no %rax
	movq %rax, topoInicialHeap						# topoInicialHeap = endereco de brk

	# aumenta heap em Block_size bytes + IG
	movq topoInicialHeap, %rbx						# rbx = brk
	movq Block_size, %r10					# r10 = Block_size
	# imul $8, %r10							# r10 *= 8
	addq $16, %r10							# r10 += sizeof(IG)
	addq %r10, %rbx 						# rbx = topoInicialHeap + Block_size*8 + 16

	# empurra brk pra baixo => brk = brk + 8*Block_size
	movq $12, %rax
	movq %rbx, %rdi
	syscall

	# registra INFORMACOES GERENCIAIS (IG)
	# topoInicialHeap = Livre/Ocupado
	# 8(topoInicialHeap) = tamanho Livre/Ocupado  
	# tam total disp = tam bloco - tam IG
	movq topoInicialHeap, %rax						# rax = topoInicialHeap
	movq Block_size, %rbx					# rbx = 4096
	movq %rbx, 8(%rax)						# topoInicialHeap[1] = tam disponivel (4096)
	movq LIVRE, %rbx						# rbx = LIVRE
	movq %rbx, (%rax)						# topoInicialHeap[0] = bloco seguinte esta LIVRE
	ret

finalizaAlocador:

	# reposiciona brk para o endereco inicial (TODO)
	movq $12, %rax 							# resize brk
	movq topoInicialHeap, %rdi							# nova altura
	syscall 
	
	# call getBrk								# devolve altura inicial de brk
	# movq topoInicialHeap, %rax


nossomal:
	call getBrk 							# devolve altura inicial de brk
	ret


