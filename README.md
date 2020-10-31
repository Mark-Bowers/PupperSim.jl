# PupperSim.jl

## Overview
Stanford Pupper open source robot simulation using the MuJoCo physics engine. Written in Julia.

## Obtaining a MuJoCo License

To use MuJoCo, you'll need a valid license which you can obtain from
[here](https://www.roboti.us/license.html). Up to three, thirty-day trials can be obtained
for free from MuJoCo's website and students are eligible for a free personal license.
Once you have obtained the license file, set the environment variable `MUJOCO_KEY_PATH`
to point to its location. On Linux machines this would look like:
```
$ export MUJOCO_KEY_PATH=/path/to/mjkey.txt
```

On a mac this is done by adding the line
```
export MUJOCO_KEY_PATH=/path/to/mjkey.txt
```
to your ~/.bash_profile.

## Installation

Install Julia by visiting https://julialang.org/downloads/

From the Julia REPL, type `]` to enter Pkg mode:
```julia-repl
julia> ]
(v1.5) pkg> add https://github.com/Mark-Bowers/QuadrupedController.jl
(v1.5) pkg> registry add https://github.com/Lyceum/LyceumRegistry.git
(v1.5) pkg> add MuJoCo@0.3.0
(v1.5) pkg> add https://github.com/Mark-Bowers/PupperSim.jl
(v1.5) pkg> add Conda
```

Then, press backspace to exit the Pkg mode and return to the regular Julia REPL.
```julia-repl
julia> using Conda
julia> Conda.add_channel("conda-forge")
julia> Conda.add("transforms3d")
```

Now you're ready to use the Pupper simulator!

## Usage
This is example code for how to render Pupper with MuJoCo.jl, with most of the structure and features taken from the simulate.cpp example code provided by the default [MuJoCo software](http://mujoco.org/). While some of the newest UI features are missing, the current code allows for dynamics simulation with mouse and camera interactivity.

```julia
using PupperSim
PupperSim.simulate()
```

This will use GLFW to open up an OpenGL window rendering the system / robot. The system starts paused; press `space` to begin time.

Click and drag with the left mouse button to orbit the camera, and with the right mouse button to pan the camera.

To perturb the robot, double click on the body you want to perturb, then hold Control and click and drag with the mouse. Using the left mouse button will apply a rotational torque while the right button will apply a translational force.

## Additional Information

https://mark-bowers.github.io/

## Credits
This effort is based on previous work by **Nathan Kau** [PupperSimulation](https://github.com/Nate711/PupperSimulation) and **Kendall Lowrey** [MujocoSim](hhttps://github.com/klowrey/MujocoSim.jl).
