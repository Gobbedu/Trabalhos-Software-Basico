// #include <stdio.h>

// funcoes auxiliares para teste
extern void iniciaAlocador();
extern void finalizaAlocador();
extern void* alocaMem(int num_bytes);
extern void liberaMem(void* bloco);
extern void imprimeMapa();

// funcoes auxiliares
void teste(void);


int main(void){
	iniciaAlocador();

	teste();

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
	
	printf("free  p1: ");
	liberaMem(p1);
	imprimeMapa();

	printf("free  p2: ");
	liberaMem(p2);
	imprimeMapa();

	printf("free  p3: ");
	liberaMem(p3);
	imprimeMapa();

	// printf("free  p1: ");
	// liberaMem(p1);
	// imprimeMapa();
	
}

