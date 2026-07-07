#include "Vec3.h"
#include <cmath>

//----------------------------------------------------
// Constructors
//----------------------------------------------------

Vec3::Vec3()
    : x(0.0f), y(0.0f), z(0.0f)
{
}

Vec3::Vec3(float x, float y, float z)
    : x(x), y(y), z(z)
{
}

Vec3::Vec3(const Vector3& vec)
    : x(vec.x), y(vec.y), z(vec.z)
{
}

//----------------------------------------------------
// Length
//----------------------------------------------------

float Vec3::LengthSquared() const
{
    return x * x + y * y + z * z;
}

float Vec3::Length() const
{
    return std::sqrt(LengthSquared());
}

//----------------------------------------------------
// Normalize
//----------------------------------------------------

void Vec3::Normalize()
{
    float len = Length();

    if (len <= 0.0f)
        return;

    x /= len;
    y /= len;
    z /= len;
}

Vec3 Vec3::Normalized() const
{
    float len = Length();

    if (len <= 0.0f)
        return Vec3();

    return Vec3(
        x / len,
        y / len,
        z / len
    );
}

//----------------------------------------------------
// Dot Product
//----------------------------------------------------

float Vec3::Dot(const Vec3& other) const
{
    return
        x * other.x +
        y * other.y +
        z * other.z;
}

//----------------------------------------------------
// Cross Product
//----------------------------------------------------

Vec3 Vec3::Cross(const Vec3& other) const
{
    return Vec3(
        y * other.z - z * other.y,
        z * other.x - x * other.z,
        x * other.y - y * other.x
    );
}

//----------------------------------------------------
// Conversion
//----------------------------------------------------

Vector3 Vec3::ToRaylib() const
{
    return { x, y, z };
}

//----------------------------------------------------
// Operators
//----------------------------------------------------

Vec3 Vec3::operator+(const Vec3& other) const
{
    return Vec3(
        x + other.x,
        y + other.y,
        z + other.z
    );
}

Vec3 Vec3::operator-(const Vec3& other) const
{
    return Vec3(
        x - other.x,
        y - other.y,
        z - other.z
    );
}

Vec3 Vec3::operator*(float scalar) const
{
    return Vec3(
        x * scalar,
        y * scalar,
        z * scalar
    );
}

Vec3 Vec3::operator/(float scalar) const
{
    return Vec3(
        x / scalar,
        y / scalar,
        z / scalar
    );
}

//----------------------------------------------------
// Compound Operators
//----------------------------------------------------

Vec3& Vec3::operator+=(const Vec3& other)
{
    x += other.x;
    y += other.y;
    z += other.z;

    return *this;
}

Vec3& Vec3::operator-=(const Vec3& other)
{
    x -= other.x;
    y -= other.y;
    z -= other.z;

    return *this;
}

Vec3& Vec3::operator*=(float scalar)
{
    x *= scalar;
    y *= scalar;
    z *= scalar;

    return *this;
}

Vec3& Vec3::operator/=(float scalar)
{
    x /= scalar;
    y /= scalar;
    z /= scalar;

    return *this;
}

//----------------------------------------------------
// Comparison
//----------------------------------------------------

bool Vec3::operator==(const Vec3& other) const
{
    return
        x == other.x &&
        y == other.y &&
        z == other.z;
}

bool Vec3::operator!=(const Vec3& other) const
{
    return !(*this == other);
}
