# Add source to this project's executable.
add_executable(PhysicsEngine_Cmake
    PhysicsEngine_Cmake.cpp
    PhysicsEngine_Cmake.h

    Custom_Implementation/Vec3.cpp
    Custom_Headers/Vec3.h  
)

# Use C++20
set_property(TARGET PhysicsEngine_Cmake PROPERTY CXX_STANDARD 20)

# -------------------------------
# Raylib
# -------------------------------

# Include raylib headers
target_include_directories(PhysicsEngine_Cmake PRIVATE
    ${CMAKE_SOURCE_DIR}/RayLib_Dependencies/include
    ${CMAKE_SOURCE_DIR}/PhysicsEngine_Cmake/Custom_Headers
)

# Link raylib
target_link_libraries(PhysicsEngine_Cmake PRIVATE
    "${CMAKE_SOURCE_DIR}/RayLib_Dependencies/lib/raylib.lib"

    winmm
    gdi32
    user32
    shell32
    opengl32
    kernel32
)
# Copy raylib.dll beside the executable after every build
add_custom_command(TARGET PhysicsEngine_Cmake POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${CMAKE_SOURCE_DIR}/RayLib_Dependencies/lib/raylib.dll"
        $<TARGET_FILE_DIR:PhysicsEngine_Cmake>
)