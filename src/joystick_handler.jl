# GLFW Gamepad functions
# https://www.glfw.org/docs/latest/input_guide.html#gamepad

global prev_buttons = nothing

function get_axes_and_buttons_map(joy::GLFW.Joystick)
	joystickname = GLFW.GetJoystickName(joy)
	if JoystickIsGamepad(joy)
		# Works for Windows and likely also on Mac
		# Works for Xbox Controller or DS4 Controller
		global AXIS_LEFT_X       = 1
		global AXIS_LEFT_Y       = 2
		global AXIS_RIGHT_X      = 3
		global AXIS_RIGHT_Y      = 4

		global BUTTON_DPAD_UP    = 12
		global BUTTON_DPAD_RIGHT = 13
		global BUTTON_DPAD_DOWN  = 14
		global BUTTON_DPAD_LEFT  = 15

		global button_commands = SVector{15, RobotCmd}(
		    CYCLE_HOP,          # GLFW_GAMEPAD_BUTTON_CROSS
		    NO_COMMAND, NO_COMMAND, NO_COMMAND,
		    TOGGLE_ACTIVATION,  # GLFW_GAMEPAD_BUTTON_LEFT_BUMPER
		    TOGGLE_TROT,        # GLFW_GAMEPAD_BUTTON_RIGHT_BUMPER
		    NO_COMMAND, NO_COMMAND, NO_COMMAND, NO_COMMAND,
		    NO_COMMAND, NO_COMMAND, NO_COMMAND, NO_COMMAND, NO_COMMAND)

	elseif occursin("Xbox", joystickname)
		# Jaystick Cannot function as gamepad on linux
		# lookup buttons and axes for Xbox controller
		global AXIS_LEFT_X       = 1
		global AXIS_LEFT_Y       = 2
		global AXIS_RIGHT_X      = 3
		global AXIS_RIGHT_Y      = 4

		global BUTTON_DPAD_UP    = 16
		global BUTTON_DPAD_RIGHT = 17
		global BUTTON_DPAD_DOWN  = 18
		global BUTTON_DPAD_LEFT  = 19

		global button_commands = SVector{19, RobotCmd}(
			CYCLE_HOP,          # XBox Controller A
			NO_COMMAND, NO_COMMAND, NO_COMMAND,
			NO_COMMAND, NO_COMMAND,
			TOGGLE_ACTIVATION,  # Xbox LEFT_BUMPER
			TOGGLE_TROT,        # Xbox RIGHT_BUMPER
			NO_COMMAND, NO_COMMAND, NO_COMMAND,
			NO_COMMAND, NO_COMMAND, NO_COMMAND,
			NO_COMMAND, NO_COMMAND, NO_COMMAND,
			NO_COMMAND, NO_COMMAND)
	elseif joystickname == "Wireless Controller"
		# Jaystick Cannot function as gamepad on linux
		# lookup buttons and axes for DS4 controller
		global AXIS_LEFT_X       = 1
		global AXIS_LEFT_Y       = 2
		global AXIS_RIGHT_X      = 3
		global AXIS_RIGHT_Y      = 6

		global BUTTON_DPAD_UP    = 15
		global BUTTON_DPAD_RIGHT = 16
		global BUTTON_DPAD_DOWN  = 17
		global BUTTON_DPAD_LEFT  = 18

		global button_commands = SVector{18, RobotCmd}(
			NO_COMMAND,
			CYCLE_HOP,          # DS4 Controller X
			NO_COMMAND, NO_COMMAND,
			TOGGLE_ACTIVATION,  # GLFW_GAMEPAD_BUTTON_LEFT_BUMPER
			TOGGLE_TROT,        # GLFW_GAMEPAD_BUTTON_RIGHT_BUMPER
			NO_COMMAND, NO_COMMAND, NO_COMMAND,
			NO_COMMAND, NO_COMMAND, NO_COMMAND,
			NO_COMMAND, NO_COMMAND, NO_COMMAND,
			NO_COMMAND, NO_COMMAND, NO_COMMAND)
	end
end

struct GLFWgamepadstate
	buttons::SVector{15, UInt8}  # unsigned char buttons[15];    // GLFW_PRESS or GLFW_RELEASE
	axes::SVector{6, Float32}    # float axes[6];                // -1.0 to 1.0 inclusive
end

#= GetGamepadState
This function retrieves the state of the specified joystick remapped to an Xbox-like gamepad.
If the specified joystick is not present or does not have a gamepad mapping this function will return GLFW_FALSE but will not generate an error. Call glfwJoystickPresent to check whether it is present regardless of whether it has a mapping.
Not all devices have all the buttons or axes provided by GLFWgamepadstate. Unavailable buttons and axes will always report GLFW_RELEASE and 0.0 respectively.
Possible errors include GLFW_NOT_INITIALIZED and GLFW_INVALID_ENUM.
Added in version 3.3 (MWB !!! How can we make sure the user is using GLFW 3.3?)
=#

JoystickIsGamepad(joy::GLFW.Joystick) = Bool(ccall((:glfwJoystickIsGamepad, GLFW.libglfw), Cint, (Cint,), joy))

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

function handle_behavior_state_change(s::mjSim, buttons)
    if (prev_buttons == nothing)
        triggered = buttons
    else
        triggered = buttons .& (prev_buttons .⊻ buttons)
    end
    global prev_buttons = deepcopy(buttons)

    for (doit, robotcmd) in zip(triggered, button_commands)
		b_doit = Bool(doit)
		#println("do it: $b_doit")
        if Bool(doit)
            # println("Executing Robot Command: $(repr(robotcmd))")
            execute_robotcmd(s, robotcmd)
        end
    end
end

function gamepad(s::mjSim, joy::GLFW.Joystick)

	get_axes_and_buttons_map(joy)

	if JoystickIsGamepad(joy)
	    state = Ref{GLFWgamepadstate}()

	    if GetGamepadState(joy, state)
	        buttons = state[].buttons

	        handle_behavior_state_change(s, buttons)
	        handle_scalar_settings(s, buttons, state[].axes)
	    end
	else
		# println("Joystick is not gamepad")
		axes = GLFW.GetJoystickAxes(joy)
		buttons = GLFW.GetJoystickButtons(joy)
		# axes_buttons = vcat(axes, buttons)
		handle_behavior_state_change(s, buttons)
		handle_scalar_settings(s, buttons, axes)
	end
end
