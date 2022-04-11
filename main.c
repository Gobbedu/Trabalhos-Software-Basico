#include <stdio.h>

extern void* nossomal();
extern void* inicia_alocador();
extern void* finaliza_alocador();
// extern void testee(); // from teste.s, teste.o

int main(void){
	int x;
	void* adr;

	// testee();
	adr = inicia_alocador();
	printf("brk inicial  %p\n", adr);

	adr = nossomal();
	printf("global var %p\n", adr);

	adr = finaliza_alocador();
	printf("brk  %p\n", adr);

	return 0;
}
