.section .data
	inicio_heap: 	.quad 0			# valor inicial da heap, antes do iniciaAlocador
	final_heap:		.quad 0			# valor final da heap, em qualquer dado momento
	Block_size:		.quad 4080		# tamanho dos blocos alocados, quando heap cheia
	LIVRE: 			.quad 0			# bool que representa um bloco LIVRE
	OCUPA:			.quad 1			# bool que representa um bloco OCUPADO
	
	olhos:			.quad 0			# variavel que contem o ultimo nó analizado
	circular:		.quad 0			# se olhos ja circularam na heap, $1, else $0, usamos pra
	 								# decidir se é preciso aumentar a heap ou nao

	strinit:		.string " "
	strnodo:		.string "( %i | %i ).."
	strfinal:		.string "final Heap asm\n"

.section .text

.globl iniciaAlocador, finalizaAlocador, alocaMem, liberaMem, imprimeMapa, PrintFinal
# nao_cabe, nao_proximo, deu_volta,


iniciaAlocador:
	# ||<= %brk
	# | L | 4080 |  ---- 4080 ---- |<= %brk (um total de 4096)
	# ^olhos
	#            ^16(olhos)

	# chama printf antes pra alocar o buffer e nn atrapalhar a brk
	movq $strinit, %rdi
	call printf

	# pergunta pro SO endereco de brk e salva 	
	movq $12, %rax							# comando: cade brk?
	movq $0, %rdi							# me diga pfr
	syscall 								# brk vem no %rax
	movq %rax, inicio_heap					# inicio_heap = endereco de brk
	movq %rax, olhos						# inicia olhos para primeiro nó

	# aumenta heap em Block_size bytes + IG
	movq inicio_heap, %rbx					# rbx = brk
	movq Block_size, %r10					# r10 = Block_size
	addq $16, %r10							# r10 += sizeof(IG)
	addq %r10, %rbx 						# rbx = inicio_heap + Block_size + 16

	# empurra brk pra baixo => brk = brk + Block_size
	movq $12, %rax
	movq %rbx, %rdi
	syscall
	movq %rax, final_heap

	# registra INFORMACOES GERENCIAIS (IG)
	# inicio_heap = Livre
	# 8(inicio_heap) = tamanho Livre
	# tam total disp = tam bloco - tam IG
	movq inicio_heap, %rax					# rax = inicio_heap
	movq LIVRE, %rbx						# rbx = LIVRE
	movq %rbx, 0(%rax)						# inicio_heap[0] = bloco seguinte esta LIVRE
	movq Block_size, %rbx					# rbx = 4096
	# subq $16, %rbx							# tamanho disponivel eh 4096 - tamanho IG
	movq %rbx, 8(%rax)						# inicio_heap[1] = tam disponivel (4080)

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

		# if ( cabe )
		movq LIVRE, %rcx
		cmpq %rax, %rcx					# 0(olhos)-> IG[0] != LIVRE		
		jne nao_cabe					

		movq %rdi, %rax					# rax = tamAloc
		addq $16, %rax					# cabe um aloc e o proximo IG?
		cmpq %rax, %rbx					# %rbx <= %rax
		jl nao_cabe					# jump if tamanho nodo < tamAloc + 16

		# coube!
		movq $0, circular				# circular = 0 reinicia flag da volta
		
		# aloca tamAloc					
		movq OCUPA, %rax				# seta IG
		movq %rax, 0(%r9)				# bloco OCUPADO

		movq 8(%r9), %r11 				# r11 = tamanho antigo do bloco
		movq %rdi, 8(%r9)				# salva novo tamanho do bloco

		# cria proximo IG				# r10 -> vai ser o proximo 'olho'
		movq olhos, %r10				# r10 = endereco de olhos
		addq $16, %r10					# r10 += 16
		addq %rdi, %r10					# r10 = olhos + novo tamanho + 16

		movq LIVRE, %rbx				# proximo IG = (ender de olhos) + tam antigo bloco + 16 [tam IG[1] + prox byte dpois do tamAloc]
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
		# if(proximo):					# 8(olhos) + tamAloc + 16 < final_heap
		# 	proximo						# olhos = olhos + 8(olhos) + 16     
		# 	jmp loop

		movq olhos, %r9
		movq 8(%r9), %rax				# endereco do proximo no em rax
		addq %r9, %rax					# rax = olhos + 8(olhos)
		addq $16, %rax					# rax = olhos + tam_bloco + 16

		movq final_heap, %rcx
		cmpq %rcx, %rax					# se proximo >= heap nao prox
		jge nao_proximo

		movq %rax, olhos				# olhos = proximo
		jmp alocaMem					# procura denovo

	nao_proximo:
		# if(circular == 0):			# se bateu na heap e nao deu a volta, da a volta
		# 	circular = 1
		# 	olhos = inicio_heap
		# 	jmp loop

		movq circular, %rax
		cmpq $1, %rax
		je deu_volta				# if(circular == 1) jump deu_volta, se nao, continua

		movq inicio_heap, %rax		# olhos = inicio_heap
		movq %rax, olhos

		movq $1, circular			# deu a volta

		jmp alocaMem				# comeca a procurar denovo

		# if(circular == 1):		# se bateu na heap e deu volta
		# 	aumenta heap			# aumenta heap
		# 	seta IG 				
		# 	jmp loop				# procura dnv, se nn couber ainda, cai aki dnv
# se nao cabe nodo, nao tem proximo e ja deu a volta
# aloca mais espaco na heap
	deu_volta:
		movq Block_size, %rax		# tamanho a aumentar a heap
		movq final_heap, %rbx		# rax novo final_heap 

		movq %rdi, %r15

		addq %rax, %rbx				# rbx = final_heap += 4096
		addq $16, %rbx
		movq $12, %rax				# SO favor aumentar
		movq %rbx, %rdi				# a heap para %rbx
		syscall		
		movq %rax, final_heap		# atualiza valor final_heap	

		movq %r15, %rdi		

		# cria proximo IG SEM MEXER NOS OLHOS  r10 -> vai ser o proximo 'olho'
		movq olhos, %r12				# r12 = endereco de olhos
		movq 8(%r12), %rax				# tamanho do bloco
		addq %rax, %r12					# r12 += tam bloco
		addq $16, %r12					# proximo olhos = olhos + tam bloco + 16(tam IG)

		movq LIVRE, %rbx				# prox IG = (ender de olhos) + tam antigo bloco + 16 [tam IG[1] + prox byte dpois do tamAloc]
		movq %rbx, 0(%r12)				# proximo IG[0] -> LIVRE // antes dava ruim aki
		
		movq Block_size, %rbx			# rbx = tamanho  bloco
		movq %rbx, 8(%r12)				# 8(proximo) =  tam_bloco_novo 

		# caso bloco livre atras, junta
		movq LIVRE, %rax
		movq olhos, %rbx
		movq 0(%rbx), %rcx
		cmpq %rax, %rcx
		jne alocaMem

		# junta livre atras com livre agora
		movq Block_size, %rax 
		movq 8(%rbx), %rcx
		addq $16, %rcx 
		addq %rax, %rcx
		movq %rcx, 8(%rbx)

		jmp alocaMem

# pseudo codigo aki pfr
# %rcx = inicio heap
# %rbx = inicio heap
# %rbx += IG[1]
# %rbx += 16
# while(%rbx < brk)
# {
#     if((%rcx) == LIVRE)
#	  {
#		 if((%rbx) == LIVRE)
#		 {
#			 8(%rcx) += 8(%rbx)
#			 8(%rcx) += 16
#			 %rbx += 8(%rbx)
#			 %rbx += 16
#		 }
#		 else
#		 {
#			 %rcx += 8(%rbx)
#			 %rcx += 16
#			 %rbx = %rcx
#			 %rbx += 8(%rbx)
#			 %rbx += 16
#		 }
# 	  }
#	  else
#	  {
#		 %rcx += 8(%rbx)
#		 %rcx += 16
#		 %rbx = %rcx
#		 %rbx += 8(%rbx)
#		 %rbx += 16
#	  }
# } 
# rbx -> r13  esses registradores sao preservados
# rcx -> r12
ocupado:
	movq LIVRE, %r10
	movq OCUPA, %r11

	movq 8(%r12), %rax			# move base 1 pra frente (rcx)
	addq %rax, %r12				# mudando a cabeça de verificação
	addq $16, %r12			

	movq 8(%r13), %rax 			# move (rbx) 1 pra frente 
	addq %rax, %r13				# %rbx += 16 -> (IG anterior)
	addq $16, %r13	

	cmpq %r14, %r13				# se esta no fim da heap
	jge fim						# sai
	
	cmpq %r11, 0(%r12) 			# se base estiver ocupado
	je ocupado					# muda a cabeça de verificação

	cmpq %r10, 0(%r12) 			# se base estiver livre
	je varredura				# inicia verificação a partir dele

	jmp fim

seg_ocupado:
	movq LIVRE, %r10
	movq OCUPA, %r11

	movq %r13, %r12				# mudando a cabeça de verificação
								# para a posição do segundo olho

	movq 8(%r12), %rax			# move base 1 pra frente (rcx)
	addq $16, %rax
	addq %rax, %r12				# mudando a cabeça de verificação			

	movq 8(%r13), %rax 			# move (rbx) 1 pra frente 
	addq $16, %rax	
	addq %rax, %r13				# %rbx += 16 -> (IG anterior)

	movq 8(%r13), %rax 			# move (rbx) 2 pra frente 
	addq $16, %rax	
	addq %rax, %r13				# %rbx += 16 -> (IG anterior)
	
	cmpq %r14, %r13	 			# se esta no fim da heap
	jge fim						# sai
	
	cmpq %r11, 0(%r12) 			# se base estiver ocupado
	je ocupado					# muda a cabeça de verificação

	cmpq %r10, 0(%r12) 			# se base estiver livre
	je varredura				# inicia verificação a partir dele

	jmp fim

soma:
	movq LIVRE, %r10
	movq OCUPA, %r11

	movq 8(%r13), %rax			# rcx[1] += rbx[1] + 16
	addq $16, %rax				# %rcx += 16 -> (IG)
	addq %rax, 8(%r12)			# IG[1] += tamanho do bloco que esta livre a frente

	movq 8(%r13), %rax 			# move (rbx) 1 pra frente 
	addq %rax, %r13				# %rbx += 16 -> (IG anterior)
	addq $16, %r13	

	cmpq %r14, %r13				# se esta no fim da heap
	jge fim						# sai
	
	cmpq %r11, 0(%r12) 			# se base estiver ocupado
	je ocupado					# muda a cabeça de verificação

	cmpq %r10, 0(%r12) 			# se base estiver livre
	je varredura				# inicia verificação a partir dele

	ret

varredura:
	movq LIVRE, %r10
	movq OCUPA, %r11
	
	cmpq %r10, 0(%r13) 			# se o proximo bloco estiver livre
	je soma						# soma ao tamanho do bloco anterior

	cmpq %r11, 0(%r13) 			# se o bloco estiver ocupado
	je seg_ocupado

	ret

fusao:
	movq inicio_heap, %r12 		# inicio da heap vai pra %rax
	movq inicio_heap, %r13

	movq final_heap, %rax		# final da heap 
	movq %rax, %r14
	
	addq 8(%r13), %rcx 			# %rbx += IG[1] -> prox bloco
	addq $16, %rcx				# %rbx += 16 -> (IG anterior)
	addq %rcx, %r13

	cmpq %r14, %r12				# se esta no fim da heap
	jge fim						# sai

	cmpq %r14, %r13				# se esta no fim da heap
	jge fim						# sai

	movq OCUPA, %r10
	cmpq %r10, 0(%r12) 			# se o bloco estiver ocupado
	je ocupado					# va para o prox bloco

	movq LIVRE, %r10
	cmpq %r10, 0(%r12) 			# se o primeiro bloco estiver livre
	je varredura				# inicia a varredura

	ret

liberaMem:
	movq LIVRE, %rax			# recebe endereco 16 bytes a frente de IG
	movq %rax, -16(%rdi)		# IG[0] = LIVRE
	
	jmp fusao

	ret

finalizaAlocador:
	# diminui brk para o endereco inicial
	movq $12, %rax 							# resize brk
	movq inicio_heap, %rdi					# nova altura
	syscall 
	
	ret

fim:
	ret

# //////// pseudo codigo imprimeMapa ///////////
#   void *final, *olhos;
# 	long *olho;
# 	char state;
# 	final = getFim();
# 	olhos = getInit();

# 	while(olhos  + 16 < final)
# 	{
# 		olho = (long *)olhos;
# 		state = (olho[0] == 0) ? 'L' : 'X';
# 		// printf("( %c | %li )..", state, olho[1]);

# 		olhos += olho[1] + 16;
# 	}
# 	// printf("final heap\n");
PrintFinal:
		movq $strfinal, %rdi
		call printf
		ret

printNODO:
	movq 0(%rdi), %rsi
	movq 8(%rdi), %rdx
	movq $strnodo, %rdi
	call printf
	ret

imprimeMapa:
	movq inicio_heap, %r12
	movq final_heap, %r13
	subq $16, %r13

	loopMapa:
		#print("nodo", estado, tamanho);
		movq %r12, %rdi
		call printNODO

		# proximo nodo
		movq 8(%r12), %rax				# endereco do proximo no em rax
		addq %rax, %r12					# nodo = olhos + 8(olhos)
		addq $16, %r12					# nodo = olhos + tam_bloco + 16

		cmpq %r13, %r12					# if olho + 16 < final_heap, imprime proximo 
		jl loopMapa

		call PrintFinal
		ret



