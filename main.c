#include <stdio.h>

extern void iniciaAlocador();
extern void* finalizaAlocador();
extern void* nossomal();
extern void* alocaMem();
extern void liberaMem();

// funcoes auxiliares
extern void* getBrk();
extern void* getInit();

char* status(double n){
	if( n == 0) return "LIVRE 0";
	if( n == 1) return "OCUPADO 1";
	else return "ERRO! != 0 ou 1";
}

int main(void){
	int *aux;
	long *IG;
	void *adr, *banana, *d, *c;

	iniciaAlocador();
	printf("inicia alocador \n\n");

	adr = getInit();
	IG = (long *) adr;
	printf("inicio heap is :%p\n", adr);
	printf("init IG[0]: %s\n", status(IG[0]));
	printf("init IG[1]: %ld\n\n", IG[1]);

	banana = alocaMem(3);
	printf("ender aloc is %p\n", adr);
	IG = (long *) (banana - 16);
	printf("IG[0]: %s\n", status(IG[0]));
	printf("IG[1]: %ld\n\n", IG[1]);

	adr = banana + IG[1] ; 			// endereco proximo IG = adr + tam bloco + 16(tam IG)
	IG = (long *) adr;
	// for(int i = -16; i <= 16; i++){
	printf("proximo IG is: %p\n", adr);
	printf("prox IG[0]: %s \n", status(IG[0]));
	printf("prox IG[1]: %ld \n\n", IG[1]);
	// }

	liberaMem(banana);
	printf("LIBEROU ALLOC\n");

	banana = getInit();
	IG = (long *) banana;
	printf("ender inicial is %p\n", banana);
	printf("IG[0]: %s\n", status(IG[0]));
	printf("IG[1]: %ld\n\n", IG[1]);

	adr = banana + IG[1] + 16 ; 			// endereco proximo IG = adr + tam bloco + 16(tam IG)
	IG = (long *) adr ;
	// for(int i = -16; i <= 16; i++){
	printf("proximo IG is: %p\n", adr);
	printf("prox IG[0]: %s \n", status(IG[0]));
	printf("prox IG[1]: %ld \n\n", IG[1]);
	// }

	finalizaAlocador();
	// printf("brk finaliza alocador\t %p\n", getBrk());

	return 0;
}
