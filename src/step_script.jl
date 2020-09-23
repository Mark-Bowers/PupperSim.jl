const crouch_height = -0.06
# const crouch_height = -0.14
const normal_height = -0.16

function step_script(s::mjSim, robot)
    elapsed_time = round(Int, s.d.time * 1000)  # elapsed time in milliseconds (non-paused simulation)

    # check every 100 milliseconds for another action to take
    if !s.paused && elapsed_time % 100 == 0 && elapsed_time > 0
        #println(elapsed_time, ": ", elapsed_time, "\tframecount: ", round(Int, s.framecount))

        if elapsed_time == 100
            toggle_activate(robot)
        end

        # After he's done falling and getting up, we return to a normal height and pitch
        if elapsed_time == 2000 && robot.command.height > -0.1
            robot.command.height = normal_height
            robot.command.pitch = 0.0
            # We begin trotting here for a few seconds
            toggle_trot(robot)
            println("Standing up and beginning march with velocity", robot.command.horizontal_velocity)
        end
    end
end
