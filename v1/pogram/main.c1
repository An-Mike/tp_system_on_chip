#define switches (volatile char *) 0x04003010
#define leds (char *)  0x04003000
int main()
{ 
    while (1) *leds = *switches;
    return 0;
}
