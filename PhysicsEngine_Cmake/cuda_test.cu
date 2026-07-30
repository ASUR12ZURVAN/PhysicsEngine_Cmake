#include <cuda_runtime.h>
#include <stdio.h>

__global__ void kernel()
{
    printf("Hello from CUDA GPU\n");
    printf("CUDA IS HELL");
}

void runCudaTest()
{
    kernel << <1, 1 >> > ();
    cudaDeviceSynchronize();
}