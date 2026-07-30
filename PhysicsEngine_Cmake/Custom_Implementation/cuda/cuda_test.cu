#include <cuda_runtime.h>
#include <iostream>
#include <vector>
#include <stdio.h>

// CUDA kernel
__global__ void addKernel(const float* a, const float* b, float* c, int n)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;

    if (i < n)
    {
        c[i] = a[i] + b[i];
    }
}

__global__ void helloKernel(int id)
{
    printf("[CUDA] Hello from GPU thread %d\n", id);
}

int main()
{
    const int N = 1024;
    const size_t bytes = N * sizeof(float);

    std::vector<float> h_a(N, 1.0f);
    std::vector<float> h_b(N, 2.0f);
    std::vector<float> h_c(N, 0.0f);

    float* d_a, * d_b, * d_c;

    // Allocate GPU memory
    cudaMalloc(&d_a, bytes);
    cudaMalloc(&d_b, bytes);
    cudaMalloc(&d_c, bytes);

    // Copy data to GPU
    cudaMemcpy(d_a, h_a.data(), bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, h_b.data(), bytes, cudaMemcpyHostToDevice);

    // Launch kernel
    int threads = 256;
    int blocks = (N + threads - 1) / threads;

    addKernel << <blocks, threads >> > (d_a, d_b, d_c, N);

    // Wait for GPU
    cudaDeviceSynchronize();

    // Copy result back
    cudaMemcpy(h_c.data(), d_c, bytes, cudaMemcpyDeviceToHost);

    // Verify
    bool ok = true;
    for (int i = 0; i < N; ++i)
    {
        if (h_c[i] != 3.0f)
        {
            ok = false;
            break;
        }
    }

    // Print GPU info
    cudaDeviceProp prop;
    cudaGetDeviceProperties(&prop, 0);

    std::cout << "GPU: " << prop.name << std::endl;
    std::cout << "Compute Capability: "
        << prop.major << "." << prop.minor << std::endl;

    if (ok)
        std::cout << "CUDA test PASSED!" << std::endl;
    else
        std::cout << "CUDA test FAILED!" << std::endl;

    // Device Query
    int deviceCount = 0;
    cudaError_t err = cudaGetDeviceCount(&deviceCount);
    if (err != cudaSuccess) {
        printf("cudaGetDeviceCount failed: %s\n", cudaGetErrorString(err));
        return -1;
    }

    printf("[CUDA] deviceCount=%d\n", deviceCount);
    for (int d = 0; d < deviceCount; ++d) {
        cudaDeviceProp prop{};
        cudaGetDeviceProperties(&prop, d);
        printf("[CUDA] Device %d: %s, SM %d.%d, MPs=%d, mem=%zu MB\n",
               d, prop.name, prop.major, prop.minor, prop.multiProcessorCount, (size_t)(prop.totalGlobalMem / (1024 * 1024)));
    }

    // Launch a simple kernel
    helloKernel<<<1, 4>>>(42);
    err = cudaGetLastError();
    if (err != cudaSuccess) {
        printf("Kernel launch failed: %s\n", cudaGetErrorString(err));
        return -1;
    }
    cudaDeviceSynchronize();
    err = cudaGetLastError();
    if (err != cudaSuccess) {
        printf("Post-synchronize error: %s\n", cudaGetErrorString(err));
    }

    // Cleanup
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);

    return 0;
}