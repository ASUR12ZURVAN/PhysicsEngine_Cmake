#include <raylib.h>

#include "Vec3.h"

int main()
{
    const int screenWidth = 1280;
    const int screenHeight = 720;

    InitWindow(screenWidth, screenHeight, "3D Physics Engine");

    Camera3D camera{};

    camera.position = { 0.0f, 5.0f, 10.0f };
    camera.target = { 0.0f, 0.0f, 0.0f };
    camera.up = { 0.0f, 1.0f, 0.0f };
    camera.fovy = 45.0f;
    camera.projection = CAMERA_PERSPECTIVE;

    // Our custom vector
    Vec3 ballPosition(0.0f, 1.0f, 0.0f);

    SetTargetFPS(60);

    while (!WindowShouldClose())
    {
        //-------------------------------------------------
        // Camera Controls
        //-------------------------------------------------

        if (IsKeyDown(KEY_RIGHT))
            camera.position.x += 0.15f;

        if (IsKeyDown(KEY_LEFT))
            camera.position.x -= 0.15f;

        if (IsKeyDown(KEY_UP))
            camera.position.z -= 0.15f;

        if (IsKeyDown(KEY_DOWN))
            camera.position.z += 0.15f;

        camera.target = ballPosition.ToRaylib();

        //-------------------------------------------------
        // Draw
        //-------------------------------------------------

        BeginDrawing();

        ClearBackground(RAYWHITE);

        BeginMode3D(camera);

        DrawGrid(20, 1.0f);

        DrawSphere(
            ballPosition.ToRaylib(),
            1.0f,
            RED
        );

        EndMode3D();

        DrawText("Arrow Keys : Move Camera", 20, 20, 20, BLACK);
        DrawFPS(20, 50);

        EndDrawing();
    }

    CloseWindow();

    return 0;
}