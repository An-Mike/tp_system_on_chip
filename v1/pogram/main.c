#include <stdio.h>

int main(void)
{
    int compteur = 0;
    
    printf("=== DEBUT ===\n");
    
    while(1)
    {
        compteur++;
        printf("tick %d\n", compteur);
        
        /* attente active */
        volatile int i;
        for(i = 0; i < 2500000; i++);
    }
    
    return 0;
}