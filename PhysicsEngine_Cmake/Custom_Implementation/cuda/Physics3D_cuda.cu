#include "Physics3D_cuda.cuh"
#include "Vec3_cuda.cuh"
#include <cuda_runtime.h>
#include <cstdlib>
#include <cstdio>
#include <cmath>

struct GpuSimulation {
	size_t capacity;
	size_t count;

	cuda_impl::Vec3Cuda* d_pos;
	cuda_impl::Vec3Cuda* d_vel;
	float* d_rad;
	float* d_invMass;
};

// Simple error check
#define CUDA_CHECK(expr) do { cudaError_t e = (expr); if (e != cudaSuccess) { fprintf(stderr, "CUDA error %s:%d: %s\n", __FILE__, __LINE__, cudaGetErrorString(e)); exit(1); } } while(0)

extern "C" {

GpuSimulation* gpuSimCreate(size_t capacity) {
	GpuSimulation* sim = (GpuSimulation*)malloc(sizeof(GpuSimulation));
	sim->capacity = capacity;
	sim->count = 0;
	sim->d_pos = nullptr;
	sim->d_vel = nullptr;
	sim->d_rad = nullptr;
	sim->d_invMass = nullptr;

	size_t bytesVec = sizeof(cuda_impl::Vec3Cuda) * capacity;
	size_t bytesF = sizeof(float) * capacity;
	CUDA_CHECK(cudaMalloc(&sim->d_pos, bytesVec));
	CUDA_CHECK(cudaMalloc(&sim->d_vel, bytesVec));
	CUDA_CHECK(cudaMalloc(&sim->d_rad, bytesF));
	CUDA_CHECK(cudaMalloc(&sim->d_invMass, bytesF));

	return sim;
}

void gpuSimDestroy(GpuSimulation* sim) {
	if (!sim) return;
	cudaFree(sim->d_pos);
	cudaFree(sim->d_vel);
	cudaFree(sim->d_rad);
	cudaFree(sim->d_invMass);
	free(sim);
}

void gpuSimInitialize(GpuSimulation* sim, size_t N, const cuda_impl::Vec3Cuda* positions, const cuda_impl::Vec3Cuda* velocities, const float* radii, const float* invMasses) {
	if (!sim) return;
	if (N > sim->capacity) N = sim->capacity;
	sim->count = N;
	size_t bytesVec = sizeof(cuda_impl::Vec3Cuda) * N;
	size_t bytesF = sizeof(float) * N;
	CUDA_CHECK(cudaMemcpy(sim->d_pos, positions, bytesVec, cudaMemcpyHostToDevice));
	CUDA_CHECK(cudaMemcpy(sim->d_vel, velocities, bytesVec, cudaMemcpyHostToDevice));
	CUDA_CHECK(cudaMemcpy(sim->d_rad, radii, bytesF, cudaMemcpyHostToDevice));
	CUDA_CHECK(cudaMemcpy(sim->d_invMass, invMasses, bytesF, cudaMemcpyHostToDevice));
}

// Device helpers
__device__ inline cuda_impl::Vec3Cuda deviceMax(const cuda_impl::Vec3Cuda& a, const cuda_impl::Vec3Cuda& b) { return cuda_impl::Vec3Cuda(fmaxf(a.x,b.x), fmaxf(a.y,b.y), fmaxf(a.z,b.z)); }

// Integrate positions: simple explicit Euler
__global__ void integrate_kernel(cuda_impl::Vec3Cuda* pos, cuda_impl::Vec3Cuda* vel, const float* invMass, size_t n, float dt, cuda_impl::Vec3Cuda gravity) {
	size_t i = blockIdx.x * blockDim.x + threadIdx.x;
	if (i >= n) return;
	float im = invMass[i];
	// If inverse mass is 0 => static
	if (im <= 0.0f) return;
	cuda_impl::Vec3Cuda v = vel[i];
	// Apply gravity scaled by mass
	v.x += gravity.x * dt * (1.0f / im);
	v.y += gravity.y * dt * (1.0f / im);
	v.z += gravity.z * dt * (1.0f / im);
	pos[i].x += v.x * dt;
	pos[i].y += v.y * dt;
	pos[i].z += v.z * dt;
	vel[i] = v;
}

// Simple floor collision at y = 0
__global__ void floor_collision_kernel(cuda_impl::Vec3Cuda* pos, cuda_impl::Vec3Cuda* vel, const float* rad, const float* invMass, size_t n, float restitution) {
	size_t i = blockIdx.x * blockDim.x + threadIdx.x;
	if (i >= n) return;
	float r = rad[i];
	if (pos[i].y - r < 0.0f) {
		// push above floor
		pos[i].y = r;
		// reflect velocity
		vel[i].y = -vel[i].y * restitution;
		// small friction damping
		vel[i].x *= 0.99f;
		vel[i].z *= 0.99f;
	}
}

// Naive pairwise collision resolution (elastic spheres)
__global__ void sphere_collision_kernel(cuda_impl::Vec3Cuda* pos, cuda_impl::Vec3Cuda* vel, const float* rad, const float* invMass, size_t n, float restitution) {
	size_t i = blockIdx.x * blockDim.x + threadIdx.x;
	if (i >= n) return;
	for (size_t j = i + 1; j < n; ++j) {
		cuda_impl::Vec3Cuda pi = pos[i];
		cuda_impl::Vec3Cuda pj = pos[j];
		float dx = pj.x - pi.x;
		float dy = pj.y - pi.y;
		float dz = pj.z - pi.z;
		float dist2 = dx*dx + dy*dy + dz*dz;
		float rsum = rad[i] + rad[j];
		float rsum2 = rsum * rsum;
		if (dist2 <= 0.0f) continue;
		if (dist2 < rsum2) {
			float dist = sqrtf(dist2);
			float penetration = rsum - dist;
			// normalize
			float nx = dx / dist;
			float ny = dy / dist;
			float nz = dz / dist;
			// Move them apart based on inverse mass
			float im1 = invMass[i];
			float im2 = invMass[j];
			float invSum = im1 + im2;
			if (invSum > 0.0f) {
				float push1 = (im1 / invSum) * penetration;
				float push2 = (im2 / invSum) * penetration;
				pos[i].x -= nx * push1;
				pos[i].y -= ny * push1;
				pos[i].z -= nz * push1;
				pos[j].x += nx * push2;
				pos[j].y += ny * push2;
				pos[j].z += nz * push2;
			}
			// Relative velocity along normal
			float rvx = vel[j].x - vel[i].x;
			float rvy = vel[j].y - vel[i].y;
			float rvz = vel[j].z - vel[i].z;
			float relVel = rvx*nx + rvy*ny + rvz*nz;
			if (relVel < 0.0f) {
				float e = restitution;
				float jn = -(1.0f + e) * relVel / (invSum);
				// apply impulse
				if (im1 > 0.0f) {
					vel[i].x -= (jn * nx) * (1.0f / im1);
					vel[i].y -= (jn * ny) * (1.0f / im1);
					vel[i].z -= (jn * nz) * (1.0f / im1);
				}
				if (im2 > 0.0f) {
					vel[j].x += (jn * nx) * (1.0f / im2);
					vel[j].y += (jn * ny) * (1.0f / im2);
					vel[j].z += (jn * nz) * (1.0f / im2);
				}
			}
		}
	}
}

void gpuSimStep(GpuSimulation* sim, float dt, int steps) {
	if (!sim) return;
	size_t n = sim->count;
	if (n == 0) return;
	const int block = 128;
	int grid = (int)((n + block - 1) / block);
	cuda_impl::Vec3Cuda gravity(0.0f, -9.81f, 0.0f);
	float restitution = 0.6f;
	for (int s = 0; s < steps; ++s) {
		integrate_kernel<<<grid, block>>>(sim->d_pos, sim->d_vel, sim->d_invMass, n, dt, gravity);
		CUDA_CHECK(cudaGetLastError());
		// collisions
		sphere_collision_kernel<<<grid, block>>>(sim->d_pos, sim->d_vel, sim->d_rad, sim->d_invMass, n, restitution);
		CUDA_CHECK(cudaGetLastError());
		floor_collision_kernel<<<grid, block>>>(sim->d_pos, sim->d_vel, sim->d_rad, sim->d_invMass, n, restitution);
		CUDA_CHECK(cudaGetLastError());
	}
	CUDA_CHECK(cudaDeviceSynchronize());
}

void gpuSimGetPositions(GpuSimulation* sim, cuda_impl::Vec3Cuda* outPositions, size_t maxCount) {
	if (!sim || !outPositions) return;
	size_t n = sim->count;
	if (maxCount < n) n = maxCount;
	size_t bytes = sizeof(cuda_impl::Vec3Cuda) * n;
	CUDA_CHECK(cudaMemcpy(outPositions, sim->d_pos, bytes, cudaMemcpyDeviceToHost));
}

size_t gpuSimGetCount(GpuSimulation* sim) {
	if (!sim) return 0;
	return sim->count;
}

} // extern "C"
