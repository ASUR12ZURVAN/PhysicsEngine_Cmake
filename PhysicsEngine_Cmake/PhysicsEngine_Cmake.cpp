#include <raylib.h>
#include <vector>
#include <cmath>
#include "Vec3.h"
#include "Physics3D.h"


extern void runCudaTest();
extern void runCudaSim();

constexpr int BALL_COUNT = 50;
constexpr float BALL_RADIUS = 0.5f;
constexpr float RESTITUTION = 0.8f;

//RESTITUTION would decide how the balls would bounce off

void ApplyCollectiveForce(std::vector<RigidBody3D>& balls,float dt) {
    for (int i{}; i < balls.size(); i++) {
        balls[i].SetPosition(Vec3(-5.0f + i * 2.5f, 5.0f, 0.0f));
        balls[i].SetVelocity(Vec3((float)(i - 2) * 2.0f, 0.0f, (float)(i % 2 == 0 ? 2 : -2)));
    }

    //for all apply the force after resetting the position 
    for (auto& it : balls) {
        it.ApplyForce(Vec3(0, -9.81f * it.GetMass(), 0));
        it.Integrate(dt);
    }
}

void ResolveCollision(RigidBody3D& a, RigidBody3D& b, float radius) {
    Vec3 delta = b.position - a.position;
    float dist = delta.Length();
    if (dist < 1e-6f) return; // Prevent division by zero

    float penetration = 2 * radius - dist;
    if (penetration > 0) {
        Vec3 normal = delta / dist;

        // Separate balls
        a.position -= normal * (penetration * 0.5f);
        b.position += normal * (penetration * 0.5f);

        // Relative velocity
        Vec3 relVel = b.velocity - a.velocity;
        float velAlongNormal = relVel.Dot(normal);

        if (velAlongNormal < 0) {
            float invMassA = 1.0f / a.GetMass();
            float invMassB = 1.0f / b.GetMass();

            float j = -(1 + RESTITUTION) * velAlongNormal;
            j /= invMassA + invMassB;

            Vec3 impulse = normal * j;
            a.velocity -= impulse * invMassA;
            b.velocity += impulse * invMassB;
        }
    }
}

int main()
{
    // Run GPU simulation demo when available
    runCudaSim();
    runCudaTest();
    runCudaTest();
    const int screenWidth = 1280;
    const int screenHeight = 720;

    InitWindow(screenWidth, screenHeight, "3D Physics Engine");

    Camera3D camera{};
    camera.position = { 0.0f, 10.0f, 20.0f };
    camera.target = { 0.0f, 0.0f, 0.0f };
    camera.up = { 0.0f, 1.0f, 0.0f };
    camera.fovy = 45.0f;
    camera.projection = CAMERA_PERSPECTIVE;

    std::vector<RigidBody3D> balls(BALL_COUNT);



    // Initialize balls with positions and velocities
    for (int i = 0; i < BALL_COUNT; ++i) {
        balls[i].SetPosition(Vec3(-5.0f + i * 2.5f, 5.0f, 0.0f));
        balls[i].SetVelocity(Vec3((float)(i - 2) * 2.0f, 0.0f, (float)(i % 2 == 0 ? 2 : -2)));
    }

    SetTargetFPS(60);

    while (!WindowShouldClose())
    {
        float dt = 1.0f / 60.0f;
        constexpr float GRID_MIN_X = -10.0f;
        constexpr float GRID_MAX_X = 10.0f;
        constexpr float GRID_MIN_Y = BALL_RADIUS; // ground
        constexpr float GRID_MAX_Y = 10.0f;       // ceiling
        constexpr float GRID_MIN_Z = -10.0f;
        constexpr float GRID_MAX_Z = 10.0f;

        // Physics step
        for (auto& ball : balls) {
            // Gravity
            ball.ApplyForce(Vec3(0, -9.81f * ball.GetMass(), 0));
            ball.Integrate(dt);

            // X boundaries
            if (ball.position.x < GRID_MIN_X + BALL_RADIUS) {
                ball.position.x = GRID_MIN_X + BALL_RADIUS;
                if (ball.velocity.x < 0) ball.velocity.x *= -RESTITUTION;
            }
            if (ball.position.x > GRID_MAX_X - BALL_RADIUS) {
                ball.position.x = GRID_MAX_X - BALL_RADIUS;
                if (ball.velocity.x > 0) ball.velocity.x *= -RESTITUTION;
            }

            // Y boundaries (ground and ceiling)
            if (ball.position.y < GRID_MIN_Y) {
                ball.position.y = GRID_MIN_Y;
                if (ball.velocity.y < 0) ball.velocity.y *= -RESTITUTION;
            }
            if (ball.position.y > GRID_MAX_Y - BALL_RADIUS) {
                ball.position.y = GRID_MAX_Y - BALL_RADIUS;
                if (ball.velocity.y > 0) ball.velocity.y *= -RESTITUTION;
            }

            // Z boundaries
            if (ball.position.z < GRID_MIN_Z + BALL_RADIUS) {
                ball.position.z = GRID_MIN_Z + BALL_RADIUS;
                if (ball.velocity.z < 0) ball.velocity.z *= -RESTITUTION;
            }
            if (ball.position.z > GRID_MAX_Z - BALL_RADIUS) {
                ball.position.z = GRID_MAX_Z - BALL_RADIUS;
                if (ball.velocity.z > 0) ball.velocity.z *= -RESTITUTION;
            }
        }
        // Ball-ball collisions
        for (size_t i = 0; i < balls.size(); ++i) {
            for (size_t j = i + 1; j < balls.size(); ++j) {
                ResolveCollision(balls[i], balls[j], BALL_RADIUS);
            }
        }

        // Camera controls
        if (IsKeyDown(KEY_RIGHT)) camera.position.x += 0.15f;
        if (IsKeyDown(KEY_LEFT)) camera.position.x -= 0.15f;
        if (IsKeyDown(KEY_UP)) camera.position.z -= 0.15f;
        if (IsKeyDown(KEY_DOWN)) camera.position.z += 0.15f;

        /// Apply and restart the simulation on a particular key 
        /// for better visualization.

        if (IsKeyDown(KEY_SPACE)) {
            ApplyCollectiveForce(balls,dt);
        }

        camera.target = balls[0].position.ToRaylib();

        // Draw
        BeginDrawing();
        ClearBackground(RAYWHITE);
        BeginMode3D(camera);

        DrawGrid(20, 1.0f);

        for (const auto& ball : balls) {
            DrawSphere(ball.position.ToRaylib(), BALL_RADIUS, RED);
        }

        EndMode3D();
        DrawText("Arrow Keys : Move Camera", 20, 20, 20, BLACK);
        DrawFPS(20, 50);
        EndDrawing();
    } 

    CloseWindow();
    return 0;
}