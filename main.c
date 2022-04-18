// #include <stdio.h>

// funcoes auxiliares para teste
extern void iniciaAlocador();
extern void finalizaAlocador();
extern void* alocaMem(int num_bytes);
extern void liberaMem(void* bloco);
extern void imprimeMapa();

// funcoes auxiliares
void teste(void);
void teste2(void);


int main(void){
	iniciaAlocador();

	teste2();

	finalizaAlocador();
	return 0;
}

void teste(void)
{
	void *p1, *p2, *p3, *ini;

	printf("\ninicio:   ");
	imprimeMapa();
	
	p1 = alocaMem(1);
	p2 = alocaMem(2);
	p3 = alocaMem(3);

	printf("aloca  3: ");
	imprimeMapa();

	printf("free  p1: ");
	liberaMem(p1);
	imprimeMapa();

	printf("free  p2: ");
	liberaMem(p2);
	imprimeMapa();

	printf("free  p3: ");
	liberaMem(p3);
	imprimeMapa();

	
	
	
}

void teste2()
{
	void *p1, *p2, *p3;

	p1 = alocaMem(4079);
	printf("aloca 4080");
	imprimeMapa();

	liberaMem(p1);
	printf("libera 4020");
	imprimeMapa();
}