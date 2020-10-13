include("step_script.jl")

# Simulate physics for 1/240 seconds (the default timestep)
function simstep(s::mjSim)
    # Create local simulator d (data), and m (model) variables
    d = s.d
    m = s.m

    if s.robot !== nothing
        # Check for gamepad input
        if GLFW.JoystickPresent(GLFW.JOYSTICK_1)
            gamepad(s, GLFW.JOYSTICK_1)
        else
            println("No Joystick detected")
        end

        # Execute next step in command script
        step_script(s::mjSim, s.robot)

        # Step the controller forward by dt
        run!(s.robot)

        # Apply updated joint angles to sim
        d.ctrl .= unsafe_wrap(Array{Float64,1}, pointer(s.robot.state.joint_angles), 12)

        # If Pupper controller, subtract the l1 joint angles from the l2 joint angles
        # to fake the kinematics of the parallel linkage
        if true  # TODO: verify that the controller is a Pupper quadruped controller
            d.ctrl[[3,6,9,12]] .= d.ctrl[[3,6,9,12]] - d.ctrl[[2,5,8,11]]
        end
    end

    if s.paused
        if s.pert[].active > 0
            mjv_applyPerturbPose(m, d, s.pert, 1)  # move mocap and dynamic bodies
            mj_forward(m, d)
        end
    else
        #slow motion factor: 10x
        factor = s.slowmotion ? 10 : 1

        # advance effective simulation time by 1/refreshrate
        startsimtm = d.time
        starttm = time()
        refreshtm = 1.0/(factor*s.refreshrate)
        updates = refreshtm / m.opt.timestep

        steps = round(Int, round(s.framecount+updates)-s.framecount)
        s.framecount += updates

        for i=1:steps
            # clear old perturbations, apply new
            d.xfrc_applied .= 0.0
            if s.pert[].select > 0
                mjv_applyPerturbPose(m, d, s.pert, 0) # move mocap bodies only
                mjv_applyPerturbForce(m, d, s.pert)
            end

            mj_step(m, d)

            # break on reset
            (d.time < startsimtm) && break
        end
    end
end
