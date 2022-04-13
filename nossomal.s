.section .data
	inicio_heap: 	.quad 0			# valor inicial da heap, antes do iniciaAlocador
	final_heap:		.quad 0			# valor final da heap, em qualquer dado momento
	Block_size:		.quad 4096		# tamanho dos blocos alocados, quando heap cheia
	LIVRE: 			.quad 0			# bool que representa um bloco LIVRE
	OCUPA:			.quad 1			# bool que representa um bloco OCUPADO
	
	olhos:			.quad 0			# variavel que contem o ultimo nó analizado
	circular:		.quad 0			# se olhos ja circularam na heap, $1, else $0, usamos pra
									# decidir se é preciso aumentar a heap ou nao

	strinit:		.string ""
	straux: 		.string "brk[0 e 1]: %i %i\n"

.section .text

.globl nossomal, iniciaAlocador, finalizaAlocador, alocaMem, liberaMem, getBrk, getConteudo


# recebe em %rdi o tamanho a ser alocado
# devolve em %rax o endereco do bloco alocado
# PSEUDO CODIGO =>
loop:
	if(cabe):							# LIVRE && tamAloc +16 < tamNodo 
		aloca tamAloc					# seta IG
		circular = 0					# reinicia flag da volta
		return endereco					# return 16(olhos) 1o byte acessivel
	if(nao_cabe):						# else
		if(proximo):					# 8(olhos) + tamAloc + 16 < final_heap
			proximo						# olhos = olhos + 8(olhos) + 8     // nn tenho ctz 
		if(nao_proximo):				# else
			if(circular == 0):			# se bateu na heap e nao deu a volta, da a volta
				circular = 1
				olhos = inicio_heap
				jmp loop
			if(circular == 1):			# se bateu na heap e deu volta
				aumenta heap			# aumenta heap
				seta IG 				
				jmp loop				# procura dnv, se nn couber ainda, cai aki dnv



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
	addq %r10, %rbx 						# rbx = inicio_heap + Block_size + 16

	# empurra brk pra baixo => brk = brk + Block_size
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
	movq %rax, olhos						# inicia olhos para primeiro nó

	# imprime conteudo da IG
	# movq (%rax), %rsi 	
	# movq 8(%rax), %rdx
	# movq $straux, %rdi
	# call printf

	ret


finalizaAlocador:
	# diminui brk para o endereco inicial
	movq $12, %rax 							# resize brk
	movq inicio_heap, %rdi					# nova altura
	syscall 
	
	ret

fusao:
	# movq %rdi, %rbx 
	# addq -8, %rbx
	# movq %rbx, %rcx
	# addq (%rbx), %rcx
	# addq 8, %rcx
	# cmpq $0, (%rcx)

	#
	# pega o inicio da heap
	# verifica se = 0
	# se sim, guarda o endereço
	# va para o proximo bloco de memoria
	# se livre, soma o tamanho dele no tamanho do bloco anterior
		# va para o proximo endereço de memoria
		# se livre, soma o tamanho dele no tamanho do primeiro bloco
		# faça isso ate encontrar um bloco ocupado
	# se ocupado, descarta o endereço guardado
		# va para o proximo endereço de memoria livre
		# guarde esse endereço
		# va para o proximo endereço de memoria
		# se livre, soma o tamanho dele no tamanho do bloco guardado
		# faça isso ate encontrar um bloco ocupado	
	# faça isso ate o final do bloco maior
	#

	ret

liberaMem:
	movq $LIVRE, -16(%rdi) # espaço de memoria livre
	
	call fusao

	ret

alocaMem:

