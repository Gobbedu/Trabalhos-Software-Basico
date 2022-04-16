#include <stdio.h>

#define LIVRE 1
#define OCUPA 0
#define Len 7
int main(int argc, char const *argv[])
{
    int Heap[Len] = {OCUPA, LIVRE, LIVRE, LIVRE, OCUPA, LIVRE, LIVRE};
    int a, b;
    
    // call fusao
    goto fusao;

fusao:
    a = 0;
    percorre:
    while( a < Len)
    {
        if(Heap[a] == OCUPA)
        {
            a = a + 1;
            goto percorre;
        }

        printf("a livre %i\n", a);
        goto varre;
    }
    // ret

varre:
    b = a + 1;
    while( b < Len )
    {
        if(Heap[b] == OCUPA)
        {
            a = b;
            goto percorre;
        }
        printf("livres a%i b%i \n", a, b);
        Heap[a] = Heap[a] + Heap[b] + 16;

        b = b + 1;
    }


    for(int i =0; i < Len; i++)
        printf("heap[%i]: %i\n", i, Heap[i]);
    
    return 0;
}
