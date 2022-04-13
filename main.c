#include <stdio.h>

extern void inicia_alocador();
extern void* finaliza_alocador();
extern void* nossomal();
extern void* getBrk();
// extern void testee(); // from teste.s, teste.o

int main(void){
	int x, a, b;
	void* adr;

	printf("\n\nbrk inicial\t\t %p\n",getBrk());
	printf("brk com print\t\t %p\n", getBrk());


	inicia_alocador();
	printf("inicia alocador \n");

	printf("brk dpois de alocar\t %p\n", getBrk());

	a = (int)getBrk();
	b = (int)(getBrk() + 1);
	printf("valor brk[0]: %i\nvalor brk[1]: %i\n", a, b);

	finaliza_alocador();
	printf("brk finaliza alocador\t %p\n", getBrk());

	return 0;
}
