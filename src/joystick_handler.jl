
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

# function axes_map(joystick)
#     axes = GLFW.GetJoystickAxes(joystick)
#     return axes[1:4]
# end

function axes_map(joystick)
    axes = GLFW.GetJoystickAxes(joystick)
    if axes[1] < -0.5
        println("Left analong stick steering left")
    elseif axes[1] > 0.5
        println("Left analog stick steering right")
    end
    if axes[2] < -0.5
        println("Left analog stick steering up")
    elseif axes[2] > 0.5
        println("Left analog stick steering down")
    end
    if axes[3] < -0.5
        println("Right analog stick steering left")
    elseif axes[3] > 0.5
        println("Right analog stick steering right")
    end
    if axes[4] < -0.5
        println("Right analog stick steering up")
    elseif axes[4] > 0.5
        println("Right analog stick steering down")
    end
    if axes[5] == 1.0
        println("Pressing RT")
    end
    if axes[6] == 1.0
        println("Pressing LT")
    end
end


function gamepad(s::mjSim, joy::GLFW.Joystick)
    present = GLFW.JoystickPresent(joy)
    if present
        execute_axes_robotcmd(s, joy)
        buttons = GLFW.GetJoystickButtons(joy)
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
            if buttons[key] == 1
                println("Pressing button ", button_map[key])
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

# function gamepad2(s, joystick)
#     while !GLFW.WindowShouldClose(s.window)
#         present = GLFW.JoystickPresent(joystick)
#         if present
#             axes = GLFW.GetJoystickAxes(joystick)
#             axes_map(joystick)
#             buttons = GLFW.GetJoystickButtons(joystick)
#             for i = 1:19
#                 if buttons[i] == 1
#                     println("Pressing button ", button_map[i])
#                 end
#             end
#             # sleep(1)
#         end
#     end
# end

# function lookup_button(joystick_buttons, joystick)
#     scanning = true
#     while scanning
#         for i = 1:19
#             if GLFW.GetJoystickButtons(joystick)[i] == 1
#                 println("Pressing button ", joystick_buttons[i])
#                 scanning = false
#             end
#         end
#     end
# end

# function joystickcmd(joy)
#     for i = 1:19
#         if GLFW.GetJoystickButtons(joy)[i] == 1
#             print("Pressing button ", button_map[i])
#             return button_controller_map[i]
#         end
#         return NO_COMMAND
#     end
# end

# in_range(key::Int, low::Int, high::Int) = key in low:high
# is_joystick_robotcmd(button_position::Int) = in_range(button_position, 1, 19)
#
# function joystick(s::mjSim, window::GLFW.Window, joy::GLFW.joystick)
#     println(GLFW.JoystickPresent(joy))
#     robotcmd = joystickcmd(joy)
#     # if is_joystick_robotcmd(button_position)
#     # robotcmd = (button_position)
#     # else
#         # robotcmd = NO_COMMAND
# end
