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

void printIG(void *base, int deslc){
	long *IG;
	IG = (long *) (base + deslc);
	printf("%p\n", base);
	printf("init IG[0]: %s\n", status(IG[0]));
	printf("init IG[1]: %ld\n\n", IG[1]);
}

int main(void){
	int *aux;
	long *IG;
	void *adr, *banana, *d, *c;

	iniciaAlocador();
	printf("inicia alocador \n\n");
	printf("IG inicial:"); printIG(getInit(), 0);

	banana = alocaMem(3);
	void *ptr = alocaMem(5);

	printf("banana is:");
	printIG(banana, -16);

	printf("segundo is:");
	printIG(ptr, -16);

	adr = banana + 3;	// endereco proximo IG = adr + tam bloco + 16(tam IG)
	printf("proximo banana is:");
	printIG(adr, 0);

	adr = ptr + 5;
	printf("proximo segundo is:");
	printIG(adr, 0);


	liberaMem(banana);
	printf("LIBEROU BANANA\n");

	banana = getInit();
	printf("nodo inicial is:"); 
	printIG(banana, 0);

	adr = banana + 3;  // endereco proximo IG = adr + tam bloco + 16(tam IG)
	printf("nodo 2 is: ");
	printIG(adr, 16);

	adr += 21;
	printf("nodo 3 is: ");
	printIG(adr, 16);

	finalizaAlocador();
	// printf("brk finaliza alocador\t %p\n", getBrk());

	return 0;
}
