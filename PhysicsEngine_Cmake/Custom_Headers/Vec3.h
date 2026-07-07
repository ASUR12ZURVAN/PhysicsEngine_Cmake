#pragma once

#include <raylib.h>

class Vec3
{
public:

    float x;
    float y;
    float z;

    // Constructors
    Vec3();
    Vec3(float x, float y, float z);
    Vec3(const Vector3& vec);

    // Magnitude
    float Length() const;
    float LengthSquared() const;

    // Normalization
    void Normalize();
    Vec3 Normalized() const;

    // Products
    float Dot(const Vec3& other) const;
    Vec3 Cross(const Vec3& other) const;

    // Conversion
    Vector3 ToRaylib() const;

    // Operators
    Vec3 operator+(const Vec3& other) const;
    Vec3 operator-(const Vec3& other) const;
    Vec3 operator*(float scalar) const;
    Vec3 operator/(float scalar) const;

    Vec3& operator+=(const Vec3& other);
    Vec3& operator-=(const Vec3& other);
    Vec3& operator*=(float scalar);
    Vec3& operator/=(float scalar);

    bool operator==(const Vec3& other) const;
    bool operator!=(const Vec3& other) const;
};