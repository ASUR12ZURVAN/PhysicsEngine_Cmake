# Physics Engine 3D

A custom **3D Physics Engine** built from scratch in **C++** using **Raylib**, focused on learning and implementing real-time rigid body simulation without relying on existing physics libraries.

> **Status:** 🚧 In Development

---

## Overview

This project aims to build a modular, extensible, and performant 3D physics engine implementing the core concepts used in modern game engines.

Current implementation includes:

- Custom 3D vector mathematics library
- Rigid Body dynamics
- Force accumulation
- Euler integration
- Sphere-to-sphere collision detection
- Impulse-based collision resolution
- World boundary collisions
- Real-time rendering using Raylib
- Interactive camera controls

The long-term goal is to evolve this into a complete physics engine featuring broad-phase collision detection, constraints, continuous collision detection, multithreading, and GPU acceleration.

---

## Features

### Physics

- RigidBody3D implementation
- Mass and inverse mass
- Linear velocity
- Force accumulation
- Gravity
- Explicit Euler integration
- Restitution (bounciness)
- Impulse-based collision response

### Collision Detection

- Sphere vs Sphere
- World boundary collision
- Penetration correction
- Collision normal calculation

### Rendering

- 3D visualization using Raylib
- Dynamic camera movement
- Real-time simulation
- FPS counter

### Mathematics

Custom implementations of:

- Vec3
- Dot Product
- Cross Product
- Vector normalization
- Magnitude
- Distance
- Quaternion (work in progress)

---

## Project Structure

```
PhysicsEngine/
│
├── src/
│   ├── main.cpp
│   ├── Physics3D.cpp
│   ├── Vec3.cpp
│   └── ...
│
├── include/
│   ├── Physics3D.h
│   ├── Vec3.h
│   └── ...
│
├── assets/
│
├── CMakeLists.txt
│
└── README.md
```

---

## Simulation Pipeline

Each frame performs the following steps:

```
Apply Forces
      ↓
Integrate Motion
      ↓
Boundary Collision
      ↓
Sphere-Sphere Collision
      ↓
Impulse Resolution
      ↓
Render Scene
```

---

## Current Physics Model

For every simulation step:

1. Apply gravity
2. Integrate velocity
3. Integrate position
4. Resolve world boundary collisions
5. Detect sphere collisions
6. Resolve collisions using impulse equations
7. Render updated positions

---

## Controls

| Key | Action |
|------|--------|
| ↑ ↓ ← → | Move Camera |
| Space | Restart Simulation |
| ESC | Exit |

---

## Technologies Used

- **C++17**
- **Raylib**
- **CMake**
- **Visual Studio 2022**

---

## Future Roadmap

### Physics

- [ ] Semi-Implicit Euler Integrator
- [ ] Verlet Integration
- [ ] RK4 Integrator
- [ ] Angular Velocity
- [ ] Torque
- [ ] Rotational Dynamics
- [ ] Friction
- [ ] Sleeping Bodies
- [ ] Continuous Collision Detection (CCD)

### Collision

- [ ] AABB
- [ ] OBB
- [ ] Plane
- [ ] Capsule
- [ ] Convex Hull
- [ ] GJK Algorithm
- [ ] EPA Algorithm
- [ ] SAT

### Broad Phase

- [ ] Uniform Grid
- [ ] Spatial Hashing
- [ ] Sweep and Prune
- [ ] BVH

### Constraints

- [ ] Distance Constraint
- [ ] Hinge Joint
- [ ] Spring
- [ ] Fixed Joint
- [ ] Slider Joint

### Performance

- [ ] Data-Oriented Design (SoA)
- [ ] SIMD Optimization
- [ ] Multithreading
- [ ] CUDA Acceleration
- [ ] Parallel Collision Solver

### Engine Features

- [ ] Physics World
- [ ] Scene Serialization
- [ ] Debug Renderer
- [ ] Collision Events
- [ ] Entity System

---

## Learning Objectives

This project is intended to deepen understanding of:

- Classical Mechanics
- Rigid Body Dynamics
- Collision Detection
- Numerical Integration
- Linear Algebra
- Quaternion Mathematics
- Optimization Techniques
- Parallel Programming
- GPU Computing
- Game Engine Architecture

---

## Inspiration

The engine is inspired by techniques used in:

- NVIDIA PhysX
- Bullet Physics
- Box2D
- Unity Physics
- Unreal Chaos Physics

as well as research papers including:

- Impulse-based Dynamic Simulation of Rigid Body Systems (SIGGRAPH '95)

---

## Building

### Requirements

- C++17 compatible compiler
- CMake
- Raylib

### Build

```bash
git clone https://github.com/<username>/PhysicsEngine.git

cd PhysicsEngine

mkdir build
cd build

cmake ..

cmake --build .
```

---

## Example

Current simulation:

- Multiple rigid bodies
- Gravity
- Elastic collisions
- Boundary interactions
- Interactive camera

---

## License

This project is released under the MIT License.

---

## Author

**Sumit Kumar Sahu**

Computer Science undergraduate passionate about:

- Physics Simulation
- Game Engine Development
- High Performance Computing
- Systems Programming
- Quantitative Computing
