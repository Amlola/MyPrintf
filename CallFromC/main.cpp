#include <stdio.h>

extern "C" int _Sum(int, int);

int main() 
    {
    int result = _Sum(8, 4);

    printf("%d\n", result);

    return 0;
    }