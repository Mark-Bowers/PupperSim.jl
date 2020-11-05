function step_script(s::mjSim, robot)
    elapsed_time = round(Int, s.d.time * 1000)  # elapsed time in milliseconds (non-paused simulation)

    # check every 100 milliseconds for another action to take
    if !s.paused && elapsed_time % 100 == 0 && elapsed_time > 0
        #println(elapsed_time, ": ", elapsed_time, "\tframecount: ", round(Int, s.framecount))

        # Start trotting 2 seconds after starting the simulation
        if elapsed_time == 2000 && robot.command.horizontal_velocity[1] > 0
            toggle_trot(robot)
            println("Beginning march with velocity", robot.command.horizontal_velocity)
        end
    end
end
