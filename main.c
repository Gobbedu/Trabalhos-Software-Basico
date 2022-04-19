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

	// teste();
	teste2();

	finalizaAlocador();
	return 0;
}

void teste(void)
{
	void *p1, *p2, *p3, *ini;

	printf("\ninicio:   ");
	imprimeMapa();
	
	p1 = alocaMem(4);
	p2 = alocaMem(4);
	p3 = alocaMem(4);

	printf("aloca  3: ");
	imprimeMapa();

	printf("free  p3: ");
	liberaMem(p3);
	imprimeMapa();

	printf("free  p2: ");
	liberaMem(p2);
	imprimeMapa();

	printf("free  p1: ");
	liberaMem(p1);
	imprimeMapa();

	
}

void teste2()
{
	void *p1, *p2, *p3;

	p1 = alocaMem(4080);
	printf("aloca 4080");
	imprimeMapa();

	p2 = alocaMem(2040);
	printf("aloca  2040");
	imprimeMapa();

	printf("libera 4080");
	liberaMem(p1);
	imprimeMapa();

	p1 = alocaMem(3000);
	printf("aloca  3000");
	imprimeMapa();

	printf("libera 2040");
	liberaMem(p2);
	imprimeMapa();

	printf("libera 3000");
	liberaMem(p1);
	imprimeMapa();
}
