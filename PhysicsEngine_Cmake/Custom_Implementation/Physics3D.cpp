#pragma once

#include<raylib.h>
#include "Physics3D.h"

#include<random>
#include<vector>


RigidBody3D::RigidBody3D()
{
    mass = 1.0f;
    inverseMass = 1.0f;
    restitution = 0.5f;
    friction = 0.5f;

    position = Vec3();
    velocity = Vec3();
    acceleration = Vec3();

    accumulatedForce = Vec3();
}

void RigidBody3D::ApplyForce(const Vec3& test_force) {
    accumulatedForce += test_force;
}

void RigidBody3D::ApplyImpulse(const Vec3& impulse) {
    velocity += impulse * inverseMass;
}

void RigidBody3D::ApplyForceAtPoint(const Vec3& force,const Vec3& point) {
    ApplyForce(force);
    //rotational mechanics would be added later
}

/*****
* Semi implicit Euler's Integration for Physics
* Also try to learn more about inversemass concept
*****/

void RigidBody3D::Integrate(float dt) {
    //computing acceleration
    Vec3 acceleration = accumulatedForce * inverseMass;

    velocity += acceleration * dt;

    position += velocity * dt;

    accumulatedForce = Vec3();
}

//Getters and Setters implemented for private fields

const Vec3& RigidBody3D::GetVelocity() const {
    return velocity;
}

const float RigidBody3D::GetMass() const {
    return mass;
}

const Vec3& RigidBody3D::GetPosition() const {
    return position;
}
void RigidBody3D::SetPosition(const Vec3& pos) {
    position = pos;
}

void RigidBody3D::SetVelocity(const Vec3& vel) {
    velocity = vel;
}



