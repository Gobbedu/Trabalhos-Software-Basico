/********************************************************
*   Implementação de um alocador de memória em assembly.
* 	Anderson Aparecido do Carmo Frasão 			GRr20204069
*	&
* 	Eduardo Gobbo Willi Vasconcellos Gonçalves 	GRR20203892  
*
*  	Software Básico - CI1064
********************************************************/

// pode comentar stdio.h que funciona ,
// foi declarado para evitar warnings na compilacao
#include <stdio.h>
# include "meuAlocador.h"
// funcoes auxiliares
void teste(void);
void teste1(void);


int main(void){

	iniciaAlocador();
	teste();
	finalizaAlocador();
	
	iniciaAlocador();
	teste1();
	finalizaAlocador();

	return 0;
}

void teste1(void)
{
	void *p1, *p2, *p3;
	long *aux;

	// printf("alguma coisa\n");
	imprimeMapa();
	
	p1 = alocaMem(4);
	imprimeMapa();
	p2 = alocaMem(4);
	imprimeMapa();
	p3 = alocaMem(10);
	imprimeMapa();
	liberaMem(p1);
	imprimeMapa();
	liberaMem(p2);
	imprimeMapa();

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

	printf("free  p1: ");
	liberaMem(p1);
	imprimeMapa();

	printf("free  p2: ");
	liberaMem(p2);
	imprimeMapa();
	
}

