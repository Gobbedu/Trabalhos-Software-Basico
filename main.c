#include <stdio.h>

extern void iniciaAlocador();
extern void* finalizaAlocador();
extern void* nossomal();
extern void* getBrk();

extern int 	 getConteudo(void *address);
// extern void testee(); // from teste.s, teste.o

int main(void){
	int x, a, b;
	void *adr, *d, *c;

	printf("\n\nbrk inicial\t\t %p\n",getBrk());
	printf("brk com print\t\t %p\n", getBrk());


	iniciaAlocador();
	printf("inicia alocador \n");

	printf("brk dpois de alocar\t %p\n", getBrk());

	// a = getConteudo(getBrk());
	// b = getConteudo(getBrk());
	// printf("valor brk[0]: %i\nvalor brk[1]: %i\n", a, b);

	finalizaAlocador();
	printf("brk finaliza alocador\t %p\n", getBrk());

	return 0;
}
