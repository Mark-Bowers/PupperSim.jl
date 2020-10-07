@enum RobotCmd::Cint begin
    NO_COMMAND = -1

    # Commands to increase/decrease the value of scalar parameters:
    # velocity, yaw, height, pitch, and roll
    INCREASE_VELOCITY   # Increase forward trot
    DECREASE_VELOCITY   # Decrease forward trot (reverse)
    INCREASE_YAW        # Veer right
    DECREASE_YAW        # Veer left
    INCREASE_HEIGHT     # Increase ride height
    DECREASE_HEIGHT     # Decrease ride height
    PITCH_NOSE_UP       # Nose up, tail down
    PITCH_NOSE_DOWN     # Nose down, tail up
    ROLL_LEFT           # Roll body to the left
    ROLL_RIGHT          # Roll body to the right

    # Commands to change the behavior state
    TOGGLE_ACTIVATION   # DEACTIVATED->REST, REST->DEACTIVATED
    TOGGLE_TROT         # REST->TROT, TROT->REST, HOP->TROT, FINISHHOP->TROT
    CYCLE_HOP           # REST->HOP, HOP->FINISHHOP, FINISHHOP->REST, TROT->HOP

    # Synthesized commands - not currently directly accessible via joystick
    TURN_LEFT           # Turn left while trotting in place
    TURN_RIGHT          # Turn right while trotting in place
end

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

function execute_robotcmd(s::mjSim, robotcmd::RobotCmd)
    c = s.robot.command # shorthand

    # Velocity PgUp / PgDn
    if robotcmd == INCREASE_VELOCITY        c.horizontal_velocity[1] += 0.01
    elseif robotcmd == DECREASE_VELOCITY    c.horizontal_velocity[1] -= 0.01

    # Height Home / End
    elseif robotcmd == INCREASE_HEIGHT      c.height -= 0.005
    elseif robotcmd == DECREASE_HEIGHT      c.height += 0.005

    # Yaw left / right arrow
    elseif robotcmd == INCREASE_YAW         c.yaw_rate += 0.02
    elseif robotcmd == DECREASE_YAW         c.yaw_rate -= 0.02

    # Pitch up / down arrow
    elseif robotcmd == PITCH_NOSE_UP        c.pitch += 0.03
    elseif robotcmd == PITCH_NOSE_DOWN      c.pitch -= 0.03

    # Roll left (/) / right (+)
    elseif robotcmd == ROLL_LEFT            c.roll += 0.02
    elseif robotcmd == ROLL_RIGHT           c.roll -= 0.02

    # Toggle activate (-) / trot (+) / hop (Enter)
    elseif robotcmd == TOGGLE_ACTIVATION    toggle_activate(s.robot)
    elseif robotcmd == TOGGLE_TROT          toggle_trot(s.robot)
    elseif robotcmd == CYCLE_HOP            toggle_hop(s.robot)

    # Turn left/right (0/.)
    elseif robotcmd == TURN_LEFT            turn_left(s.robot)
    elseif robotcmd == TURN_RIGHT           turn_right(s.robot)
    end
end
