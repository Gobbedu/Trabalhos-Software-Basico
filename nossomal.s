.section .data
	inicio_heap: 	.quad 0			# valor inicial da heap, antes do iniciaAlocador
	final_heap:		.quad 0			# valor final da heap, em qualquer dado momento
	Block_size:		.quad 4096		# tamanho dos blocos alocados, quando heap cheia
	LIVRE: 			.quad 0			# bool que representa um bloco LIVRE
	OCUPA:			.quad 1			# bool que representa um bloco OCUPADO
	
	olhos:			.quad 0			# variavel que contem o ultimo nó analizado
	circular:		.quad 0			# se olhos ja circularam na heap, $1, else $0, usamos pra
									# decidir se é preciso aumentar a heap ou nao

	strinit:		.string "inicia printf\n"
	straux: 		.string "brk[0 e 1]: %i %i\n"

.section .text

.globl nossomal, iniciaAlocador, finalizaAlocador, alocaMem, liberaMem, getBrk, getInit


# retorna o endereco de brk em rax 
getBrk:
	movq $12, %rax
	movq $0, %rdi
	syscall # brk comes on %rax, 
	ret		# returns %rax

getInit:
	movq inicio_heap, %rax;
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
	movq LIVRE, %rbx						# rbx = LIVRE
	movq %rbx, 0(%rax)						# inicio_heap[0] = bloco seguinte esta LIVRE
	movq Block_size, %rbx					# rbx = 4096
	movq %rbx, 8(%rax)						# inicio_heap[1] = tam disponivel (4096)

	movq inicio_heap, %rax					# inicia olhos para primeiro nó
	movq %rax, olhos

	# imprime conteudo da IG
	# movq (%rax), %rsi 	
	# movq 8(%rax), %rdx
	# movq $straux, %rdi
	# call printf

	ret


# recebe em %rdi o tamanho a ser alocado
# devolve em %rax o endereco do bloco alocado
# Se foi alocado, o olho ja aponta para o proximo nodo livre
# <================= PSEUDO CODIGO =================>
# loop:
# 	if(cabe):							# LIVRE && tamAloc +16 < tamNodo 
# 		aloca tamAloc					# seta IG
# 		circular = 0					# reinicia flag da volta
# 		return endereco					# return 16(olhos) 1o byte acessivel
# 	if(nao_cabe):						# else
# 		if(proximo):					# 8(olhos) + tamAloc + 16 < final_heap
# 			proximo						# olhos = olhos + 8(olhos) + 8     // nn tenho ctz 
#			jmp loop
# 		if(nao_proximo):				# else
# 			if(circular == 0):			# se bateu na heap e nao deu a volta, da a volta
# 				circular = 1
# 				olhos = inicio_heap
# 				jmp loop
# 			if(circular == 1):			# se bateu na heap e deu volta
# 				aumenta heap			# aumenta heap
# 				seta IG 				
# 				jmp loop				# procura dnv, se nn couber ainda, cai aki dnv
alocaMem:
		movq olhos, %r9					# r9 = olhos, ao longo do alocaMem inteiro
		movq 0(%r9), %rax				# rax = status do nodo
		movq 8(%r9), %rbx				# rbx = tamanho nodo

		#if ( cabe )
		cmpq %rax, LIVRE				# 0(olhos)-> IG[0] != LIVRE		
		jne nao_cabe

		movq %rdi, %rax					# rax = tamAloc
		addq $16, %rax				 	# rax = tamAloc + 16
		cmpq %rax, %rbx					# %rbx <= %rax
		jle nao_cabe					# jump if tamanho nodo <= tamAloc + 16

		# print auxiliar
		# movq $1, %rax # 1 CABE

		# circular = 0					# reinicia flag da volta
		movq $0, circular
		
		# aloca tamAloc					# seta IG
		movq OCUPA, %rax
		movq %rax, 0(%r9)				# bloco OCUPADO

		movq 8(%r9), %r11 				# r11 = tamanho antigo do bloco
		movq %rdi, 8(%r9)				# salva novo tamanho do bloco

		# cria proximo IG				# r10 -> vai ser o proximo 'olho'
		movq olhos, %r10				# r10 = endereco de olhos
		addq $16, %r10					# r10 += 16
		addq %rdi, %r10					# r10 += novo tamanho

		movq LIVRE, %rbx				# prox IG = (ender de olhos) + tam antigo bloco + 16 [tam IG[1] + prox byte dpois do tamAloc]
		movq %rbx, 0(%r10)				# proximo IG[0] -> LIVRE
		
		movq %r11, %rbx					# rbx = tamanho antigo bloco
		subq 8(%r9), %rbx				# rbx -= tamanho novo bloco
		subq $16, %rbx					# rbx -= 16
		movq %rbx, 8(%r10)				# proximo IG[1] = tam_bloco_old - tam_bloco_novo - 16 (tamanho IG)
		
		# return endereco
		movq olhos, %rax				# rax = endereco olhos
		addq $16, %rax					# rax = endereco olhos + 16 (endereco 1o byte usavel)

		# setar proximo olho
		movq %r10, olhos

		ret								# retorna endereco do bloco usavel 

	# if(!cabe)	
nao_cabe: 
		# print auxiliar
		movq $0, %rax # 0 NAO CABE

		# if(proximo):					# 8(olhos) + tamAloc + 16 < final_heap
		# 	proximo						# olhos = olhos + 8(olhos) + 8     // nn tenho ctz 
		# 	jmp loop




		jmp fim_alocaMem


fim_alocaMem:
	ret

ocupado:
	addq 8(%rbx), %rbx 		# proximo bloco de memoria
	addq $16, %rbx
	movq %rbx, %rcx
	cmpq $LIVRE, (%rbx) 	# se o primeiro bloco estiver livre
	je varredura
	cmpq $OCUPA, (%rbx) 	# se o bloco estiver ocupado
	je ocupado
	ret

soma_ful:
	addq 8(%rbx), %rax
	ret

varredura:
	cmpq $LIVRE, (%rcx) 	# se livre
	je soma_ful				# soma ao tamanho do bloco anterior
	addq 8(%rcx), %rcx 		# proximo bloco de memoria
	addq $16, %rcx
	movq %rcx, %rbx
	cmpq $LIVRE, (%rcx) 	# se livre
	je varredura
	cmpq $OCUPA, (%rcx) 	# se o bloco estiver ocupado
	je ocupado
	ret

fusao:
	movq $inicio_heap, %rax # inicio da heap vai pra %rax
	movq %rax, %rbx 		# guarda o endereço
	movq %rbx, %rcx
	addq 8(%rcx), %rcx 		# proximo bloco de memoria
	addq $16, %rcx
	cmpq $LIVRE, (%rax) 	# se o primeiro bloco estiver livre
	je varredura			# inicia a varredura
	cmpq $OCUPA, (%rax) 	# se o bloco estiver ocupado
	je ocupado
	ret

liberaMem:
	movq LIVRE, %rax
	movq %rax, -16(%rdi)
	
	call fusao

	ret


finalizaAlocador:
	# diminui brk para o endereco inicial
	movq $12, %rax 							# resize brk
	movq inicio_heap, %rdi					# nova altura
	syscall 
	
	ret

