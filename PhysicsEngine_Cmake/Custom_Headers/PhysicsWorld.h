#pragma once
#include "Vec3.h"
#include "Physics3D.h"
#include<vector>

class PhysicsWorld {

public:
	Vec3 gravity = Vec3(0, -9.81f, 0);

	std::vector<RigidBody3D*> bodies;

	void Step(float dt);
};