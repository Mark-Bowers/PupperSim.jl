module PupperSim    #  9.716722 seconds (11.72 M allocations: 650.717 MiB, 1.66% gc time)
                    # 10.893923 seconds (13.63 M allocations: 756.021 MiB, 2.05% gc time)
                    # 13.839607 seconds (16.71 M allocations: 918.154 MiB, 1.52% gc time)

# modified from https://github.com/klowrey/MujocoSim.jl/

export loadmodel, pupper, simulate

@time using GLFW                    # 0.418646 seconds (564.20 k allocations: 33.920 MiB)
@time using MuJoCo                  # 2.657531 seconds (10.89 M allocations: 579.276 MiB, 6.15% gc time), was 0.705183 seconds (2.45 M allocations: 162.621 MiB)
      using MuJoCo.MJCore           # 0.000602 seconds (463 allocations: 28.750 KiB)
      using StaticArrays            # 0.000598 seconds (482 allocations: 29.875 KiB)
@time using FixedPointNumbers       # 0.058240 seconds (121.71 k allocations: 7.553 MiB)
@time using ColorTypes              # 0.352808 seconds (366.70 k allocations: 22.285 MiB)

const use_VideoIO = true

@static if use_VideoIO
    @time using VideoIO             # 2.877718 seconds (6.32 M allocations: 345.427 MiB, 5.85% gc time)

    const max_video_duration = 60   # max video duration in seconds
    const video_fps = 30            # frames per second determined by GLFW.GetPrimaryMonitor refresh rate
    const max_video_frames = video_fps * max_video_duration
else
    @time using FFMPEG              # 1.175542 seconds (3.00 M allocations: 160.817 MiB, 3.63% gc time)
end

@time using QuadrupedController     # 1.068143 seconds (3.38 M allocations: 171.183 MiB, 10.19% gc time)
@time using CImGui
      using CImGui.GLFWBackend
      using CImGui.OpenGLBackend
      using CImGui.GLFWBackend.GLFW
      using CImGui.OpenGLBackend.ModernGL

include("Sim.jl")

include("util.jl")
include("record_video.jl")
include("setup.jl")

"""
    loadmodel(modelfile = "model/Pupper.xml", width = 1920, height = 1080)

Loads MuJoCo XML model and starts the simulation
"""
function loadmodel(
        modelfile = normpath(joinpath(dirname(pathof(@__MODULE__)), "../model/Pupper.xml")),
        width = 1920, height = 1080
    )
    m = jlModel(modelfile)
    d = jlData(m)

    s = PupperSim.setup(m, d, width, height)

    s.modelfile = modelfile
    @info("Model file: $modelfile")

    # Turn off shadows initially on Linux
    flags = MVector(s.scn[].flags)
    flags[1] = !Sys.islinux()
    s.scn[].flags = flags

    GLFW.SetWindowRefreshCallback(s.window, (w)->render(s,w))    # Called on window resize

    return s
end

"""
    pupper(velocity = 0.4, yaw_rate = 0.0)

Creates a Robot controller with specified initial velocity and yaw_rate
"""
function pupper(velocity = 0.1, yaw_rate = 0.0)
    config = Configuration()
    config.z_clearance = 0.02     # height to pick up each foot during trot

    command = Command([velocity, 0], yaw_rate, crouch_height)
    # command.pitch = 0.1

    # Create the robot (controller and controller state)
    Robot(config, command)
end

include("simstep.jl")
include("render.jl")

# Run the simulation
"""
    simulate([s::mjSim[, robot::Robot]])

Run the simulation loop
"""
function simulate(s::mjSim = loadmodel(), robot::Union{Robot, Nothing} = pupper())
    # Assign the passed in robot to our simulator
    s.robot = robot

    # Loop until the user closes the window
    while !GLFW.WindowShouldClose(s.window)
        simstep(s)

        render(s, s.window)
        GLFW.PollEvents()
    end

    GLFW.DestroyWindow(s.window)

    return
end

"""
    simulate(modelpath::String, width = 0, height = 0, robot = nothing)

Run the simulation loop
"""
function simulate(modelpath::String, width = 0, height = 0, robot = nothing)
    simulate(loadmodel(modelpath, width, height), robot)
end

end
