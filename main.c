#include <stdio.h>

// funcoes auxiliares para teste
extern void iniciaAlocador();
extern void* finalizaAlocador();
extern void* alocaMem();
extern void liberaMem();

// funcoes auxiliares
extern void* getBrk();
extern void* getInit();
void printIG(void *base, int deslc);
char* status(double n);

void teste1(void);
void teste2(void);
void teste3(void);
void testeFusao(void);

int main(void){

	testeFusao();

	return 0;
}

void testeFusao(void)
{
	void *p1, *p2, *p3, *ini;
	iniciaAlocador();

	ini = getInit();

	p1 = alocaMem(1);
	printf("p1 is: ");
	printIG(p1, -16);

	p2 = alocaMem(2);
	printf("p2 is: ");
	printIG(p2, -16);

	p3 = alocaMem(3);
	printf("p3 is: ");
	printIG(p3, -16);

	printf("proximo de p3 is:");
	printIG(p3, 3);

	liberaMem(p2);
	liberaMem(p3);
	liberaMem(p1);

	printf("libera p1 & p2 & p3, inicio is:");
	printIG(ini, 0);

	finalizaAlocador();
}

void teste2(void)
{
	void *pont1, *pont2, *pont3;
	iniciaAlocador();

	pont1 = alocaMem(2024);
	if (pont1)
		printf("pont1 is :%p\n", pont1);

	pont2 = alocaMem(2041);
	if( pont2 ) 
		printf("pont2 is :%p\n", pont2);


	finalizaAlocador();
}

// aloca banana(3) e ptr(5), depois libera banana, 
// testa empilhamento da heap
void teste1(void)
{
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

}

char* status(double n)
{
	if( n == 0) return "LIVRE 0";
	if( n == 1) return "OCUPADO 1";
	else return "ERRO! != 0 ou 1";
}

void printIG(void *base, int deslc)
{
	long *IG;
	IG = (long *) (base + deslc);
	printf("%p\n", base);
	printf("init IG[0]: %s\n", status(IG[0]));
	printf("init IG[1]: %ld\n\n", IG[1]);
}

