#include <stdio.h>

#define M 2
#define N 2
#define K 2

__global__ void matMulKernel(float* A, float* B, float* C)
{
	int row = blockIdx.y * blockDim.y + threadIdx.y;
	int col = blockIdx.x * blockDim.x + threadIdx.x;
	if(row >= M || col >= N) return;
	float sum =0;
	for(int i=0;i<N;i++)
	{
		sum += A[row*N + i]*B[i*K + col];
	}
	C[row*K + col] = sum;
}

int main(void)
{	

	//decalre host matrices
	float hA[M*N],hB[N*K],hC[M*K];
	
	//populate host matrices
	for(int i=0;i<M;i++)
	{
		for(int j=0;j<N;j++)
		{
			hA[i*N+j] = (float)(rand()%10);
//			printf("%f ",hA[i*N+j]);
		}
//		printf("\n");
	}
//	printf("\n");
	
	for(int i=0;i<N;i++)
	{
		for(int j=0;j<K;j++)
		{
			hB[i*K+j] = (float)(rand()%10);
//			printf("%f ",hB[i*K+j]);
		}
//		printf("\n");
	}
//	printf("\n");
	
	//load dA and dB into device memory
	float* dA, *dB, *dC;
	cudaError_t err;
	uint size = M*N*sizeof(float);
	err = cudaMalloc((void**)&dA, size);
	printf("CUDA malloc A: %s\n",cudaGetErrorString(err));
	err = cudaMemcpy(dA,hA,size,cudaMemcpyHostToDevice);
	printf("Copy B to device: %s\n",cudaGetErrorString(err)); 
	
	
	size = N*K*sizeof(float);
	err = cudaMalloc((void**)&dB, size);
	printf("CUDA malloc B: %s\n",cudaGetErrorString(err));
	err = cudaMemcpy(dB,hB,size,cudaMemcpyHostToDevice);
	printf("Copy B to device: %s\n",cudaGetErrorString(err));
	
	//create dC in device memory
	size = N*K*sizeof(float);
	err = cudaMalloc((void**)&dC, size);
	printf("CUDA malloc C: %s\n",cudaGetErrorString(err));
	
	//kernel
	
	dim3 blockSize(16,32);
	dim3 gridSize;
	gridSize.x = (K+15)/16;
	gridSize.y = (M+31)/32;
	
	matMulKernel<<<gridSize, blockSize>>>(dA, dB, dC);
	err = cudaThreadSynchronize();
  	printf("Run kernel: %s\n", cudaGetErrorString(err));
  	
  	// Read C from device memory
  	err = cudaMemcpy(hC, dC, size, cudaMemcpyDeviceToHost); 
  	printf("Copy C off of device: %s\n",cudaGetErrorString(err));
	
	//Free device memory
	cudaFree(dA);
	cudaFree(dB);
	cudaFree(dC);
	
/*	for(int i=0;i<M;i++)
	{
		for(int j=0;j<K;j++)
		{
			printf("%f ",hC[i*K+j]);
		}
		printf("\n");
	}*/
}

