#********************************************************
#   Implementação de um alocador de memória em assembly.
# 	Anderson Aparecido do Carmo Frasão 			GRr20204069
#	&
# 	Eduardo Gobbo Willi Vasconcellos Gonçalves 	GRR20203892  
#
#  	Software Básico - CI1064
#********************************************************

CFLAGS = -Wall -ansi -g -std=c99
PIE = -no-pie 
DYLINK = -dynamic-linker /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 \
/usr/lib/x86_64-linux-gnu/crt1.o /usr/lib/x86_64-linux-gnu/crti.o \
/usr/lib/x86_64-linux-gnu/crtn.o

# nome do arquivo compilado
NAME = avalia

# codigo
OBJ = meuAlocador.o

# roda testes macabros pra tentar quebrar o codigo
# codigoC = testesss

# execucao normal
codigoC = avalia

# REGRAS DE COMPILACAO
all: main

# gcc $(PIE) main.c $(OBJ) -o $(NAME)
# usa o ligador ao inves do gcc pra juntar tudo
main: meuAlocador.o
	gcc $(PIE) $(codigoC).c -c -g -o $(codigoC).o
	ld meuAlocador.o $(codigoC).o -o $(NAME) $(DYLINK) -lc

%.o: %.s
	as $(PIE) -g meuAlocador.s -o meuAlocador.o


clean:
	rm *.o

purge: clean
	rm $(NAME)

