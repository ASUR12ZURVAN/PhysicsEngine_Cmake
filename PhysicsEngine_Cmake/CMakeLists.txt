cmake_minimum_required(VERSION 3.18)

project(PhysicsEngine_Cmake LANGUAGES CXX CUDA)

# Use C++20
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Use CUDA C++20
set(CMAKE_CUDA_STANDARD 20)
set(CMAKE_CUDA_STANDARD_REQUIRED ON)

# CUDA architecture
# RTX 4060 Laptop GPU = Compute Capability 8.9
set(CMAKE_CUDA_ARCHITECTURES 89)


# --------------------------------
# Executable Sources
# --------------------------------

add_executable(PhysicsEngine_Cmake

    PhysicsEngine_Cmake.cpp

    Custom_Implementation/Vec3.cpp
    Custom_Implementation/Physics3D.cpp
    Custom_Implementation/PhysicsWorld.cpp

    # CUDA source
    cuda_test.cu
    cuda_simulator.cu
)


# Enable CUDA separable compilation
set_target_properties(PhysicsEngine_Cmake PROPERTIES
    CUDA_SEPARABLE_COMPILATION ON
)


# --------------------------------
# Include directories
# --------------------------------

target_include_directories(PhysicsEngine_Cmake PRIVATE

    ${CMAKE_SOURCE_DIR}/RayLib_Dependencies/include

    ${CMAKE_SOURCE_DIR}/PhysicsEngine_Cmake/Custom_Headers
)


# --------------------------------
# Link Raylib
# --------------------------------

target_link_libraries(PhysicsEngine_Cmake PRIVATE

    "${CMAKE_SOURCE_DIR}/RayLib_Dependencies/lib/raylib.lib"

    winmm
    gdi32
    user32
    shell32
    opengl32
    kernel32
)


# --------------------------------
# Copy raylib.dll after build
# --------------------------------

add_custom_command(TARGET PhysicsEngine_Cmake POST_BUILD

    COMMAND ${CMAKE_COMMAND} -E copy_if_different

    "${CMAKE_SOURCE_DIR}/RayLib_Dependencies/lib/raylib.dll"

    $<TARGET_FILE_DIR:PhysicsEngine_Cmake>
)

# Ensure the CUDA simulation implementation is compiled and linked
set_source_files_properties(Custom_Implementation/cuda/Physics3D_cuda.cu PROPERTIES LANGUAGE CUDA)
target_sources(PhysicsEngine_Cmake PRIVATE Custom_Implementation/cuda/Physics3D_cuda.cu)

# Link CUDA runtime if available (try modern CUDAToolkit, then legacy CUDA)
find_package(CUDAToolkit QUIET)
if (CUDAToolkit_FOUND AND TARGET CUDAToolkit::cudart)
    target_link_libraries(PhysicsEngine_Cmake PRIVATE CUDAToolkit::cudart)
else()
    find_package(CUDA QUIET)
    if (CUDA_FOUND)
        if (TARGET CUDA::cudart)
            target_link_libraries(PhysicsEngine_Cmake PRIVATE CUDA::cudart)
        elseif (DEFINED CUDA_CUDART_LIBRARY)
            target_link_libraries(PhysicsEngine_Cmake PRIVATE ${CUDA_CUDART_LIBRARY})
        else()
            message(STATUS "CUDA found but cudart target/library not available; continuing without linking cudart")
        endif()
    else()
        message(STATUS "CUDA not found - building without CUDA runtime")
    endif()
endif()
