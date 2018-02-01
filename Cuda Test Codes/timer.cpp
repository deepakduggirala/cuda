#include<stdio.h>
#include<time.h>
#include<stdlib.h>
using namespace std;
#define M 1000
#define N 1000
#define K 1000

timespec diff(timespec start, timespec end)
{
	timespec temp;
	if ((end.tv_nsec-start.tv_nsec)<0) {
		temp.tv_sec = end.tv_sec-start.tv_sec-1;
		temp.tv_nsec = 1000000000+end.tv_nsec-start.tv_nsec;
	} else {
		temp.tv_sec = end.tv_sec-start.tv_sec;
		temp.tv_nsec = end.tv_nsec-start.tv_nsec;
	}
	return temp;
}

int main(void)
{	
	int i,j;
	timespec time1, time2, time3;
	
	//decalre host matrices
	float hA[M*N],hB[N*K],hC[M*K];
	
	clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &time1);
	//populate host matrices
	for(i=0;i<M;i++)
	{
		for(j=0;j<N;j++)
		{
			hA[i*N+j] = (float)(rand()%10);
			//printf("%f ",hA[i*N+j]);
		}
	//	printf("\n");
	}
//	printf("\n");
	clock_gettime(CLOCK_PROCESS_CPUTIME_ID, &time2);
	time3 = diff(time1,time2);
	printf("%ld:%ld\n",time3.tv_sec, time3.tv_nsec);
}
