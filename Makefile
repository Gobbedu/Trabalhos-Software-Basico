# =======================================================
#   Feito por Eduardo Gobbo Willi Vasconcellos Goncalves
#   GRR20203892
#   Makefile do programa FOTOMOSAICO
#  ======================================================= 

CFLAGS = -Wall -ansi -g -std=c99
LDLIBS = -no-pie

# nome do arquivo compilado
NAME = a.out

# codigo
ASS = nossomal.s
OBJ = nossomal.o

# REGRAS DE COMPILACAO
all: main

main: nossomal.o 
	gcc $(LDLIBS) main.c $(OBJ) -o $(NAME)

%.o: %.s
	as $(LDLIBS) $(ASS) -o $(OBJ)

clean:
	rm *.o

purge: clean
	rm $(NAME)
