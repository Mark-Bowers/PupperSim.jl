
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

function deadband(value, band_radius)
    return max(value - band_radius, 0) + min(value + band_radius, 0)
end

function clipped_first_order_filter(input, target, max_rate, tau)
    rate = (target - input) / tau
    return clamp(rate, -max_rate, max_rate)
end

function execute_axes_robotcmd(s::mjSim, joy::GLFW.Joystick)
    # axes = GLFW.GetJoystickAxes(joy)
    axes = map((x) -> round(x; digits=1), GLFW.GetJoystickAxes(joy))
    # println("Current axes $axes")

    lx=1; ly=2; rx=3; rt=5

    joystickname = GLFW.GetJoystickName(joy)
    # println("Using $joystickname")
    if occursin("Xbox", joystickname)
        ry=4; lt=6
    elseif joystickname == "Wireless Controller"
        lt=4; ry=6
    end

    # shorthand
    config  = s.robot.controller.config
    state   = s.robot.state
    command = s.robot.command

    # Not sure why these are reversed
    command.horizontal_velocity[1] = axes[ly] * -config.max_x_velocity
    command.horizontal_velocity[2] = axes[lx] * -config.max_y_velocity
    # but they are also reversed in JoystickInterface.py
    # x_vel = msg["ly"] * self.config.max_x_velocity
    # y_vel = msg["lx"] * -self.config.max_y_velocity
    # command.horizontal_velocity = np.array([x_vel, y_vel])

    # command.yaw_rate = msg["rx"] * -self.config.max_yaw_rate
    command.yaw_rate = axes[rx] * -config.max_yaw_rate

    #=
    pitch = msg["ry"] * self.config.max_pitch
    deadbanded_pitch = deadband(
        pitch, self.config.pitch_deadband
    )
    pitch_rate = clipped_first_order_filter(
        state.pitch,
        deadbanded_pitch,
        self.config.max_pitch_rate,
        self.config.pitch_time_constant,
    )
    command.pitch = state.pitch + message_dt * pitch_rate
    =#

    # max_pitch = config.max_pitch
    pitch = axes[ry] * -config.max_pitch_rate
    println("pitch: $pitch")
    deadbanded_pitch = deadband(
        pitch, config.pitch_deadband
    )
    pitch_rate = clipped_first_order_filter(
        state.pitch,
        deadbanded_pitch,
        config.max_pitch_rate,
        config.pitch_time_constant,
    )
    println("pitch_rate: $pitch_rate")
    message_dt = 1.0 / s.refreshrate
    command.pitch = state.pitch + message_dt * pitch_rate
    c_pitch = command.pitch
    println("Setting command.pitch to $c_pitch")
    #=
    height_movement = msg["dpady"]
    command.height = state.height - message_dt * self.config.z_speed * height_movement

    roll_movement = - msg["dpadx"]
    command.roll = state.roll + message_dt * self.config.roll_speed * roll_movement
    =#

end

function get_prev_buttons(joy::GLFW.Joystick, joystickname::String)
    if occursin("Xbox", joystickname)
        prev_buttons = zeros(UInt8, 19)
    elseif joystickname == "Wireless Controller"
        prev_buttons = zeros(UInt8, 18)
    end
end


function gamepad(s::mjSim, joy::GLFW.Joystick)
    present = GLFW.JoystickPresent(joy)
    if present
        execute_axes_robotcmd(s, joy)
        joystickname = GLFW.GetJoystickName(joy)
        prev_buttons = get_prev_buttons(joy, joystickname)
        buttons = GLFW.GetJoystickButtons(joy)
        toggle = buttons .& (prev_buttons .⊻ buttons)
        global prev_buttons = deepcopy(buttons)
        robotcmd = NO_COMMAND
        if occursin("Xbox", joystickname)
        # For now we only know about two possible names
        # for controllers. Wireless Controller is DS4
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
