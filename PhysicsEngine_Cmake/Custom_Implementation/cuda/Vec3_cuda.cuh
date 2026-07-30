#pragma once

#include <raylib.h>

#ifndef HOST_DEVICE
#if defined(__CUDACC__)
#define HOST_DEVICE __host__ __device__
#else
#define HOST_DEVICE
#endif
#endif

namespace cuda_impl {

struct Vec3Cuda {
	float x;
	float y;
	float z;

	HOST_DEVICE Vec3Cuda() : x(0.0f), y(0.0f), z(0.0f) {}
	HOST_DEVICE Vec3Cuda(float x_, float y_, float z_) : x(x_), y(y_), z(z_) {}
	HOST_DEVICE Vec3Cuda(const ::Vector3& v) : x(v.x), y(v.y), z(v.z) {}

	HOST_DEVICE float LengthSquared() const { return x*x + y*y + z*z; }
	HOST_DEVICE float Length() const { return sqrtf(LengthSquared()); }

	HOST_DEVICE void Normalize() {
		float len = Length();
		if (len <= 0.0f) return;
		x /= len; y /= len; z /= len;
	}

	HOST_DEVICE Vec3Cuda Normalized() const {
		float len = Length();
		if (len <= 0.0f) return Vec3Cuda();
		return Vec3Cuda(x/len, y/len, z/len);
	}

	HOST_DEVICE float Dot(const Vec3Cuda& other) const {
		return x*other.x + y*other.y + z*other.z;
	}

	HOST_DEVICE Vec3Cuda Cross(const Vec3Cuda& o) const {
		return Vec3Cuda(
			y*o.z - z*o.y,
			z*o.x - x*o.z,
			x*o.y - y*o.x
		);
	}

	HOST_DEVICE ::Vector3 ToRaylib() const { return { x, y, z }; }

	HOST_DEVICE Vec3Cuda operator+(const Vec3Cuda& o) const { return Vec3Cuda(x+o.x, y+o.y, z+o.z); }
	HOST_DEVICE Vec3Cuda operator-(const Vec3Cuda& o) const { return Vec3Cuda(x-o.x, y-o.y, z-o.z); }
	HOST_DEVICE Vec3Cuda operator*(float s) const { return Vec3Cuda(x*s, y*s, z*s); }
	HOST_DEVICE Vec3Cuda operator/(float s) const { return Vec3Cuda(x/s, y/s, z/s); }

	HOST_DEVICE Vec3Cuda& operator+=(const Vec3Cuda& o) { x+=o.x; y+=o.y; z+=o.z; return *this; }
	HOST_DEVICE Vec3Cuda& operator-=(const Vec3Cuda& o) { x-=o.x; y-=o.y; z-=o.z; return *this; }
	HOST_DEVICE Vec3Cuda& operator*=(float s) { x*=s; y*=s; z*=s; return *this; }
	HOST_DEVICE Vec3Cuda& operator/=(float s) { x/=s; y/=s; z/=s; return *this; }

	HOST_DEVICE bool operator==(const Vec3Cuda& o) const { return x==o.x && y==o.y && z==o.z; }
	HOST_DEVICE bool operator!=(const Vec3Cuda& o) const { return !(*this == o); }
};

} // namespace cuda_impl
