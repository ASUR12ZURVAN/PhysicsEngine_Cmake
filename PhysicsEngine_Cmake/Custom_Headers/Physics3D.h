#pragma once
#include "Vec3.h"
#include<raylib.h>

class RigidBody3D
{
private:
    float mass;
    float inverseMass;
    float restitution;
    float friction;

    Vec3 accumulatedForce;
    Vec3 accumulatedTorque;

public:
    Vec3 position;
    Vec3 velocity;
    Vec3 acceleration;
    Vec3 angularVelocity;  //to be used for rotational dynamics


    RigidBody3D();

    const Vec3& GetPosition() const;
    const float GetMass() const;
    const Vec3& GetVelocity() const;

    void SetPosition(const Vec3& pos);
    void SetVelocity(const Vec3& vel);


    void ApplyForce(const Vec3& force);
    void ApplyForceAtPoint(const Vec3& force, const Vec3& point);
    void ApplyImpulse(const Vec3& impulse);

    void Integrate(float dt);
};