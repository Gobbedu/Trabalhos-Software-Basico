.section .data
.section .text
.globl _inicio, testee
testee:
	movq $96, %rax
	ret

_inicio:
	call testee
	#vazio memo

