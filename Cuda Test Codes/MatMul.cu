#include <iostream>

using namespace std;

#define BLOCK_SIZE 16

__global__ void gpuMM(float *A, float *B, float *C, int N)
{
	// Matrix multiplication for NxN matrices C=A*B
	// Each thread computes a single element of C
	int row = blockIdx.y*blockDim.y + threadIdx.y;
	int col = blockIdx.x*blockDim.x + threadIdx.x;

	float sum = 0.f;
	for (int n = 0; n < N; ++n)
	    sum += A[row*N+n]*B[n*N+col];

	C[row*N+col] = sum;
}

int main(int argc, char *argv[])
{
	// Perform matrix multiplication C = A*B
	// where A, B and C are NxN matrices
	// Restricted to matrices where N = K*BLOCK_SIZE;
	int N,K;
	K = 100;			
	N = K*BLOCK_SIZE;
	
	cout << "Executing Matrix Multiplcation" << endl;
	cout << "Matrix size: " << N << "x" << N << endl;

	// Allocate memory on the host
	float *hA,*hB,*hC;
	hA = new float[N*N];
	hB = new float[N*N];
	hC = new float[N*N];

	// Initialize matrices on the host
	for (int j=0; j<N; j++){
	    for (int i=0; i<N; i++){
	    	hA[j*N+i] = 2.f*(j+i);
			hB[j*N+i] = 1.f*(j-i);
	    }
	}

	// Allocate memory on the device
	int size = N*N*sizeof(float);	// Size of the memory in bytes
	float *dA,*dB,*dC;
	cudaMalloc(&dA,size);
	cudaMalloc(&dB,size);
	cudaMalloc(&dC,size);

	dim3 threadBlock(BLOCK_SIZE,BLOCK_SIZE);
	dim3 grid(K,K);
	
	// Copy matrices from the host to device
	cudaMemcpy(dA,hA,size,cudaMemcpyHostToDevice);
	cudaMemcpy(dB,hB,size,cudaMemcpyHostToDevice);
	
	//Execute the matrix multiplication kernel
	
	gpuMM<<<grid,threadBlock>>>(dA,dB,dC,N);
		
	// Now do the matrix multiplication on the CPU
	float sum;
	for (int row=0; row<N; row++){
		for (int col=0; col<N; col++){
			sum = 0.f;
			for (int n=0; n<N; n++){
				sum += hA[row*N+n]*hB[n*N+col];
			}
			hC[row*N+col] = sum;
		}
	}
	
	// Allocate memory to store the GPU answer on the host
	float *C;
	C = new float[N*N];
	
	// Now copy the GPU result back to CPU
	cudaMemcpy(C,dC,size,cudaMemcpyDeviceToHost);
	
	// Check the result and make sure it is correct
	for (int row=0; row<N; row++){
		for (int col=0; col<N; col++){
			if ( C[row*N+col] != hC[row*N+col] ){
				cout << "Wrong answer!" << endl;
				row = col = N;
			}
		}
	}
		
	cout << "Finished." << endl;
	
}