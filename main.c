#include <stdio.h>

// funcoes auxiliares para teste
extern void iniciaAlocador();
extern void* finalizaAlocador();
extern void* alocaMem();
extern void liberaMem();
extern void imprimeMapa(); // a verdadeira ta dando ruim

// funcoes auxiliares
extern void* getBrk();
extern void* getInit();
extern void* getFim();
void printIG(void *base, int deslc);
char* status(double n);

void cimprimeMapa(void);

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
	void *p1, *p2, *ini;
	iniciaAlocador();
	printf("\ninicia alocador:\n");
	cimprimeMapa(); printf("\n");

	printf("aloca p1:\n");
	p1 = alocaMem(1);
	cimprimeMapa(); printf("\n");

	printf("aloca p2:\n");
	p2 = alocaMem(2);
	cimprimeMapa(); printf("\n");

	printf("libera p1:\n");
	liberaMem(p1);
	cimprimeMapa(); printf("\n");

	printf("libera p2:\n");
	liberaMem(p2);
	cimprimeMapa(); printf("\n");


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

void cimprimeMapa(void)
{
	void *final, *inicio, *olhos;
	long *olho;
	char state;
	final = getFim();
	inicio = getInit();

	olhos = inicio;

	while(olhos  + 16 < final)
	{
		olho = (long *)olhos;
		state = (olho[0] == 0) ? 'L' : 'X';
		printf("( %c | %li )..", state, olho[1]);

		olhos += olho[1] + 16;
	}
	printf("final heap\n");

}

void printIG(void *base, int deslc)
{
	long *IG;
	IG = (long *) (base + deslc);
	printf("%p\n", base);
	printf("init IG[0]: %s\n", status(IG[0]));
	printf("init IG[1]: %ld\n\n", IG[1]);
}

