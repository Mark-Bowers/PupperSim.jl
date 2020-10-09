
global xbox_button_map = Dict([(1, "A"), (2, "B"), (4, "X"), (5, "Y"), (7, "LB"), (8, "RB"),
                          (12, "Option"), (16, "DUp"), (17, "DRight"), (18, "DDown"),
                          (19, "DLeft")])

  global ps4_button_map = Dict([(1, "Square"), (2, "X"), (3, "Circle"), (4, "Triangle"),
                                (5, "Bumper L1"), (6, "Bumper R1"), (8, "Share"),
                                (9, "Option"), (14, "Home"), (15, "DUp"), (16, "DRight"),
                                (17, "DDown"), (18, "DLeft")])

global xbox_button_controller_map = Dict([(1, CYCLE_HOP), (7, TOGGLE_ACTIVATION),
                                         (8, TOGGLE_TROT), (16, INCREASE_HEIGHT),
                                         (17, ROLL_RIGHT), (18, DECREASE_HEIGHT),
                                         (19, ROLL_LEFT)])

global ps4_button_controller_map = Dict([(2, CYCLE_HOP), (5, TOGGLE_ACTIVATION),
                                          (6, TOGGLE_TROT), (15, INCREASE_HEIGHT),
                                          (16, ROLL_RIGHT), (17, DECREASE_HEIGHT),
                                          (18, ROLL_LEFT)])

function execute_axes_robotcmd(s::mjSim, joy::GLFW.Joystick)
    c = s.robot.command # shorthand
    conf = s.robot.controller.config

    # max_yaw_rate = conf.max_yaw_rate
    max_pitch = conf.max_pitch

    joystickname = GLFW.GetJoystickName(joy)
    axes = map((x) -> round(x; digits=1), GLFW.GetJoystickAxes(joy))
    # axes = GLFW.GetJoystickAxes(joy)
    # println("Current axes $axes")
    if occursin("Xbox", joystickname)
        # println("Using $joystickname")

        y_velocity_weight = -1*axes[1]
        x_velocity_weight = -1*axes[2]
        yaw_rate_weight = -1*axes[3]
        # For some reason, pushing analog stick up makes value go more neg
        # This is counter-intuitive
        pitch_weight = -1*axes[4]

        # TODO: Clarify if turn left/right means adjust yaw or call these commands
        # if axes_weights[3] < -0.5               turn_left(s.robot)
        # elseif axes_weights[3] > 0.5            turn_right(s.robot)

    elseif joystickname == "Wireless Controller"
        # look up weights for ps4
        x_velocity_weight = axes[1]
        y_velocity_weight = -1*axes[2]
        yaw_rate_weight = axes[3]
        pitch_weight = -1*axes[6]
    end

    c.horizontal_velocity[1] = x_velocity_weight * conf.max_x_velocity
    c.horizontal_velocity[2] = y_velocity_weight * conf.max_y_velocity

    # TODO: Ask what max_stance_yaw is
    # if c.yaw_rate < conf.max_stance_yaw
    c.yaw_rate = yaw_rate_weight *conf.max_yaw_rate
    # end

    c.pitch += pitch_weight * conf.max_pitch_rate

    # println("Max pitch $max_pitch")
    # if c.pitch < max_pitch
    #     oldpitch = c.pitch
    #     # newpitch = c.pitch + pitch_weight * conf.max_pitch_rate
    #     # println("Adjusting pitch from $oldpitch to $newpitch")
    #     # c.pitch = newpitch
    #     println("Pitch weight $pitch_weight")
    #     println("Pitch $oldpitch")
    # end
end

prev_buttons = zeros(UInt8, 18)

function gamepad(s::mjSim, joy::GLFW.Joystick)
    present = GLFW.JoystickPresent(joy)
    if present
        execute_axes_robotcmd(s, joy)
        buttons = GLFW.GetJoystickButtons(joy)
        toggle = buttons .& (prev_buttons .⊻ buttons)
        global prev_buttons = deepcopy(buttons)
        robotcmd = NO_COMMAND
        joystickname = GLFW.GetJoystickName(joy)
        if occursin("Xbox", joystickname)
        # For now we only know about two possible
        # names for controllers. Wireless Controller
        # IS PS4
            button_map = xbox_button_map
            button_controller_map = xbox_button_controller_map
        elseif joystickname == "Wireless Controller"
            button_map = ps4_button_map
            button_controller_map = ps4_button_controller_map
        end
        for (key, value) in button_map
            if toggle[key] == 1
                println("Pressed button ", button_map[key])
                if key in keys(button_controller_map)
                    robotcmd = button_controller_map[key]
                else
                    println("Button has no controller function")
                end
            end
        end
        # sleep(1)
        cmd = repr(robotcmd)
        if !(robotcmd == NO_COMMAND)
            println("Executing Robot Command: $cmd")
        end
        execute_robotcmd(s, robotcmd)
    end
end
