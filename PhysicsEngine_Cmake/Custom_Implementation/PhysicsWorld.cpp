#include "PhysicsWorld.h"
#include "Vec3.h"
#include<raylib.h>
#include<vector>

//physics world simulated
// Rotation to be added later om 

void PhysicsWorld::Step(float dt) {
	for (auto body : bodies) {
		body->ApplyForce(gravity * body->GetMass());
		body->Integrate(dt);
	}
}

