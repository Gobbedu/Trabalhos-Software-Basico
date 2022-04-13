.globl allocate, deallocate

.section .data
memory_start:
    .quad 0
memory_end:
    .quad 0

.section .text
.equ HEADER_SIZE, 16
.equ HDR_IN_USE_OFFSET, 0
.equ HDR_SIZE_OFFSET, 8

.equ BRK_SYSCALL, 12

# Registrar uso:
# - %rdx - tamanho solicitado
# - %rsi - ponteiro para a memória atual que está sendo examinada
# - %rcx - cópia da memória_fim

allocate_init:
    # Encontre o intervalo do programa.
    movq $0, %rdi
    movq $BRK_SYSCALL, %rax
    syscall
    # A pausa atual será o início e o fim da nossa memória
    movq %rax, memory_start
    movq %rax, memory_end
    jmp allocate_continue

allocate_move_break:
    # A pausa antiga é salva em %r8 para retornar ao usuário
    movq %rcx, %r8
    # Calcular onde queremos que a nova pausa seja
    # (intervalo antigo + tamanho)
    movq %rcx, %rdi
    addq %rdx, %rdi
    # Salvar este valor
    movq %rdi, memory_end
    # Diga ao Linux onde está o novo intervalo
    movq $BRK_SYSCALL, %rax
    syscall
    # O endereço está em %r8 - tamanho e disponibilidade da marca
    movq $1, HDR_IN_USE_OFFSET(%r8)
    movq %rdx, HDR_SIZE_OFFSET(%r8)
    # O valor de retorno real está além do nosso cabeçalho
    addq $HEADER_SIZE, %r8
    movq %r8, %rax
    ret

allocate:
    # Salve o valor solicitado em %rdx
    movq %rdi, %rdx
    # A quantidade real necessária é realmente maior
    addq $HEADER_SIZE, %rdx
    # Se não inicializamos, faça isso
    cmpq $0, memory_start
    je allocate_init

allocate_continue:
    movq memory_start, %rsi
    movq memory_end, %rcx

allocate_loop:
    # Se chegamos ao fim da memória
    # temos que alocar nova memória por
    # movendo a pausa.
    cmpq %rsi, %rcx
    je allocate_move_break
    # o próximo bloco está disponível?
    cmpq $0, HDR_IN_USE_OFFSET(%rsi)
    jne try_next_block
    # o próximo bloco é grande o suficiente?
    cmpq %rdx, HDR_SIZE_OFFSET(%rsi)
    jb try_next_block
    # Esse bloco é ótimo!
    # Marcar como indisponível
    movq $1, HDR_IN_USE_OFFSET(%rsi)
    # Vá além do cabeçalho
    addq $HEADER_SIZE, %rsi
    # Devolva o valor
    movq %rsi, %rax
    ret

try_next_block:
    # Este bloco não funcionou, vá para o próximo
    addq HDR_SIZE_OFFSET(%rsi), %rsi
    jmp allocate_loop

deallocate:
    # Free é simples - basta marcar o bloco como disponível
    movq $0, HDR_IN_USE_OFFSET - HEADER_SIZE(%rdi)
    ret