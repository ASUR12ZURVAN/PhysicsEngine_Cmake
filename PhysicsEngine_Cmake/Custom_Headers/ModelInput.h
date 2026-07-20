#pragma once
#pragma once

#include <raylib.h>
#include <string>

#include "Vec3.h"

class ModelInput
{
public:
    ModelInput();
    explicit ModelInput(const std::string& filePath);
    ~ModelInput();

    bool Load(const std::string& filePath);
    void Unload();

    void Draw(const Vec3& position,
        float scale = 1.0f,
        Color tint = WHITE) const;

    BoundingBox GetBoundingBox() const;

    bool IsLoaded() const;

private:
    Model model;
    BoundingBox boundingBox;
    bool loaded = false;
};