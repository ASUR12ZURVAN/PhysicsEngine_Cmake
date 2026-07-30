#include "Custom_Implementation/cuda/Physics3D_cuda.cuh"
#include "Custom_Implementation/cuda/Vec3_cuda.cuh"
#include <cuda_runtime.h>
#include <cstdio>
#include <vector>

void runCudaSim()
{
	int devCount = 0;
	cudaGetDeviceCount(&devCount);
	printf("[runCudaSim] cuda devices=%d\n", devCount);
	if (devCount <= 0) return;

	const size_t N = 2000; // number of balls
	GpuSimulation* sim = gpuSimCreate(N);
	std::vector<cuda_impl::Vec3Cuda> pos(N);
	std::vector<cuda_impl::Vec3Cuda> vel(N);
	std::vector<float> rad(N);
	std::vector<float> invMass(N);

	int cols = 8;
	float spacing = 0.6f;
	for (size_t i = 0; i < N; ++i) {
		int r = (int)(i / cols);
		int c = (int)(i % cols);
		pos[i] = cuda_impl::Vec3Cuda(c * spacing, 2.0f + r * spacing, 0.0f);
		vel[i] = cuda_impl::Vec3Cuda(0.0f, 0.0f, 0.0f);
		rad[i] = 0.25f;
		invMass[i] = 1.0f; // mass 1
	}

	gpuSimInitialize(sim, N, pos.data(), vel.data(), rad.data(), invMass.data());

	const int steps = 300; // frames
	const float dt = 1.0f / 60.0f;

	for (int i = 0; i < steps; ++i) {
		gpuSimStep(sim, dt, 1);
	}

	std::vector<cuda_impl::Vec3Cuda> out(N);
	gpuSimGetPositions(sim, out.data(), N);

	for (size_t i = 0; i < N; ++i) {
		printf("Ball %zu pos = (%f, %f, %f)\n", i, out[i].x, out[i].y, out[i].z);
	}

	gpuSimDestroy(sim);
}
