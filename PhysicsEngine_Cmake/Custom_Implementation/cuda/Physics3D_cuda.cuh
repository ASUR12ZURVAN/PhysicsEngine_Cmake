#pragma once

#include "Vec3_cuda.cuh"
#include <cstddef>

extern "C" {

// Opaque handle for a GPU simulation instance
struct GpuSimulation;

// Create a simulation instance with capacity for `capacity` balls.
// Returns nullptr on failure.
GpuSimulation* gpuSimCreate(size_t capacity);

// Destroy the simulation and free device memory
void gpuSimDestroy(GpuSimulation* sim);

// Initialize N balls with given arrays (host arrays)
// positions, velocities, radii, inverseMass must be length N
void gpuSimInitialize(GpuSimulation* sim, size_t N, const cuda_impl::Vec3Cuda* positions, const cuda_impl::Vec3Cuda* velocities, const float* radii, const float* invMasses);

// Step the simulation by dt, run for `steps` iterations (internal substeps can be used)
void gpuSimStep(GpuSimulation* sim, float dt, int steps);

// Copy back positions (host array of length N)
void gpuSimGetPositions(GpuSimulation* sim, cuda_impl::Vec3Cuda* outPositions, size_t maxCount);

// Get current count
size_t gpuSimGetCount(GpuSimulation* sim);

} // extern "C"
