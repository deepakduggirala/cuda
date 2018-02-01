#include<stdio.h>

int main(void)
{
	int count;
	
	cudaDeviceProp prop;
	
	cudaGetDeviceCount(&count);
	printf("No:of devices: %d\n\n",count);
	
	for(int i=0; i<count; i++)
	{
		cudaGetDeviceProperties( &prop, i);
		printf( "--- General Information for device %d ---\n", i );
		printf( "Name:%s\n", prop.name );
		printf( "Compute capability:%d.%d\n", prop.major, prop.minor );
		printf( "Clock rate:%d\n", prop.clockRate );
		printf( "Max Threads per block: %d\n",prop.maxThreadsPerBlock );
	}
}
