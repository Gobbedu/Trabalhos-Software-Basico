# =======================================================
#   Feito por Eduardo Gobbo Willi Vasconcellos Goncalves
#   GRR20203892
#   Makefile do programa FOTOMOSAICO
#  ======================================================= 

CFLAGS = -Wall -ansi -g -std=c99
PIE = -no-pie 
DYLINK = -dynamic-linker /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 \
/usr/lib/x86_64-linux-gnu/crt1.o /usr/lib/x86_64-linux-gnu/crti.o \
/usr/lib/x86_64-linux-gnu/crtn.o

# nome do arquivo compilado
NAME = a.out

# codigo
OBJ = nossomal.o

# REGRAS DE COMPILACAO
all: main

# gcc $(PIE) main.c $(OBJ) -o $(NAME)
# usa o ligador ao inves do gcc pra juntar tudo
main: nossomal.o
	gcc $(PIE) main.c -c -g -o main.o
	ld nossomal.o main.o -o $(NAME) $(DYLINK) -lc

%.o: %.s
	as $(PIE) -g nossomal.s -o nossomal.o


clean:
	rm *.o

purge: clean
	rm $(NAME)
