# PupperSim.jl
Stanford Pupper open source robot simulation using the MuJoCo physics engine. Written in Julia.

# Usage
This is example code for how to render Pupper with MuJoCo.jl, with most of the structure and features taken from the simulate.cpp example code provided by the default [MuJoCo software](http://mujoco.org/). While some of the newest UI features are missing, the current code allows for dynamics simulation with mouse and camera interactivity.

```julia
using PupperSim
PupperSim.simulate()
```

This will use GLFW to open up an OpenGL window rendering the system / robot. The system starts paused; press `space` to begin time.

# Additional Information

https://mark-bowers.github.io/
