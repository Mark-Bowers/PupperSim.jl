# GLFW Gamepad functions
# https://www.glfw.org/docs/latest/input_guide.html#gamepad

const AXIS_LEFT_X       = 1
const AXIS_LEFT_Y       = 2
const AXIS_RIGHT_X      = 3
const AXIS_RIGHT_Y      = 4

const BUTTON_DPAD_UP    = 12
const BUTTON_DPAD_RIGHT = 13
const BUTTON_DPAD_DOWN  = 14
const BUTTON_DPAD_LEFT  = 15

struct GLFWgamepadstate
	buttons::SVector{15, UInt8}  # unsigned char buttons[15];    // GLFW_PRESS or GLFW_RELEASE
	axes::SVector{6, Float32}    # float axes[6];                // -1.0 to 1.0 inclusive
end

#= GetGamepadState
This function retrieves the state of the specified joystick remapped to an Xbox-like gamepad.
If the specified joystick is not present or does not have a gamepad mapping this function will return GLFW_FALSE but will not generate an error. Call glfwJoystickPresent to check whether it is present regardless of whether it has a mapping.
Not all devices have all the buttons or axes provided by GLFWgamepadstate. Unavailable buttons and axes will always report GLFW_RELEASE and 0.0 respectively.
Possible errors include GLFW_NOT_INITIALIZED and GLFW_INVALID_ENUM.
Added in version 3.3.
=#

GetGamepadState(joy::GLFW.Joystick, state) = Bool(ccall((:glfwGetGamepadState, GLFW.libglfw), Cint, (Cint, Ref{GLFWgamepadstate}), joy, state))

function handle_scalar_settings(s::mjSim, buttons, axes)
    config  = s.robot.controller.config
    command = s.robot.command

    # Velocity
    command.horizontal_velocity[1] = axes[AXIS_LEFT_Y] * -config.max_x_velocity
    command.horizontal_velocity[2] = axes[AXIS_LEFT_X] * -config.max_y_velocity

    # Yaw
    command.yaw_rate = axes[AXIS_RIGHT_X] * -config.max_yaw_rate

    # Pitch
    set_pitch!(s.robot, axes[AXIS_RIGHT_Y])

    # Roll
    dpadx = Int(buttons[BUTTON_DPAD_RIGHT]) - Int(buttons[BUTTON_DPAD_LEFT])
    dpadx != 0 && adjust_roll!(s.robot, dpadx)

    # Height
    dpady = Int(buttons[BUTTON_DPAD_UP]) - Int(buttons[BUTTON_DPAD_DOWN])
    dpady != 0 && adjust_height!(s.robot, dpady)
end

prev_buttons = @SVector fill(0x00, 15)
button_commands = SVector{15, RobotCmd}(
    CYCLE_HOP,          # GLFW_GAMEPAD_BUTTON_CROSS
    NO_COMMAND, NO_COMMAND, NO_COMMAND,
    TOGGLE_ACTIVATION,  # GLFW_GAMEPAD_BUTTON_LEFT_BUMPER
    TOGGLE_TROT,        # GLFW_GAMEPAD_BUTTON_RIGHT_BUMPER
    NO_COMMAND, NO_COMMAND, NO_COMMAND, NO_COMMAND,
    NO_COMMAND, NO_COMMAND, NO_COMMAND, NO_COMMAND, NO_COMMAND)

function handle_behavior_state_change(s::mjSim, buttons)
    triggered = buttons .& (prev_buttons .⊻ buttons)
    global prev_buttons = deepcopy(buttons)

    for (doit, robotcmd) in zip(triggered, button_commands)
        if Bool(doit)
            # println("Executing Robot Command: $(repr(robotcmd))")
            execute_robotcmd(s, robotcmd)
        end
    end
end

function gamepad(s::mjSim, joy::GLFW.Joystick)
    state = Ref{GLFWgamepadstate}()

    if GetGamepadState(joy, state)
        buttons = state[].buttons
        axes = state[].axes

        # println("Gamepad state: $(repr(state))")
        #message = "Gamepad state: $buttons $(map((x) -> round(x; digits=2), axes))"
        #send(s.socket, message)

        handle_behavior_state_change(s, buttons)
        handle_scalar_settings(s, buttons, axes)
    end
end
