include("robot_commands.jl")

global button_map = Dict([(1, "A"), (2, "B"), (4, "X"), (5, "Y"), (7, "LB"), (8, "RB"),
                          (12, "Option"), (16, "DUp"), (17, "DRight"), (18, "DDown"),
                          (19, "DLeft")])

global button_controller_map = Dict([(7, TOGGLE_ACTIVATION), (8, TOGGLE_TROT), (16, INCREASE_HEIGHT),
                              (17, ROLL_RIGHT), (18, DECREASE_HEIGHT), (19, ROLL_RIGHT)])

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


function gamepad(joystick)
    present = GLFW.JoystickPresent(joystick)
    if present
        axes = GLFW.GetJoystickAxes(joystick)
        axes_map(joystick)
        buttons = GLFW.GetJoystickButtons(joystick)
        for i = 1:19
            if buttons[i] == 1
                println("Pressing button ", button_map[i])
            end
        end
        # sleep(1)
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
