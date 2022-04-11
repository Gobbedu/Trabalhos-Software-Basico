#include <stdio.h>

extern int testee();

int main(void){
	int x;

	x = testee();

	printf("%i\n", x);
		
	return 0;
}
