#include <stdio.h>

extern "C" int _MyPrintf(const char* format, ...);

int main() 
    {
    _MyPrintf("%d\n%b\n%c\n%s\n%%\n%x\n%c\n%o\n%o\n"
             "%d %s %x %d%%%c%b\n", 123456, 5, 'c', "far", 0xA1B2C3DE, 'f', 05555, -1234, -1, "love", 3802, 100, 33, 31);

    printf("----------------------\n");

    printf("%d\n%c\n%s\n%%\n%x\n%c\n%o\n"
          "%d %s %x %d%%%c\n", 123456, 'c', "string", 0xA1B2C3DE, 'f', 05555, -1, "love", 3802, 100, 33);

    return 0;
    }