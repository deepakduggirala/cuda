#include<stdio.h>

__global__ void printHello(void)
{
	printf("Hello World from the device.\n");
}

int main(void)
{
	printHello<<<1,1>>>();
	return 0;
}
