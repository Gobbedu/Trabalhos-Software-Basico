# =======================================================
#   Feito por Eduardo Gobbo Willi Vasconcellos Goncalves
#   GRR20203892
#   Makefile do programa FOTOMOSAICO
#  ======================================================= 

# PRECISA CORRIGIR AKI AINDA

CFLAGS = -Wall -ansi -g -std=c99
LDLIBS = -lm

# nome do arquivo compilado
NAME = main

# codigo
CODED = main.c 
HEADERS = h 
#objetos gerados
objects = main.o nossomal.o 


# REGRAS DE COMPILACAO
all: main

main: $(objects) 
	gcc -o $(NAME) $(objects) $(LDLIBS)

main.o: $(CODED)
	gcc $(CFLAGS) -c $(CODED)

clean:
	rm $(objects) 

purge: clean
	rm $(NAME)
