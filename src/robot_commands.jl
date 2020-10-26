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

function execute_robotcmd(s::mjSim, robotcmd::RobotCmd)
    c = s.robot.command # shorthand
    # set_height!, adjust_height!

    # Velocity PgUp / PgDn
    if robotcmd == INCREASE_VELOCITY        c.horizontal_velocity[1] += 0.01
    elseif robotcmd == DECREASE_VELOCITY    c.horizontal_velocity[1] -= 0.01

    # Height Home / End
    elseif robotcmd == INCREASE_HEIGHT      adjust_height!(s.robot, +1)
    elseif robotcmd == DECREASE_HEIGHT      adjust_height!(s.robot, -1)

    # Yaw left / right arrow
    elseif robotcmd == INCREASE_YAW         c.yaw_rate -= 0.02
    elseif robotcmd == DECREASE_YAW         c.yaw_rate += 0.02

    # Pitch up / down arrow
    elseif robotcmd == PITCH_NOSE_UP        set_pitch!(s.robot, -1)
    elseif robotcmd == PITCH_NOSE_DOWN      set_pitch!(s.robot, +1)

    # Roll left (/) / right (+)
    elseif robotcmd == ROLL_LEFT            adjust_roll!(s.robot, -1)
    elseif robotcmd == ROLL_RIGHT           adjust_roll!(s.robot, +1)

    # Toggle activate (-) / trot (+) / hop (Enter)
    elseif robotcmd == TOGGLE_ACTIVATION    toggle_activate(s.robot)
    elseif robotcmd == TOGGLE_TROT          toggle_trot(s.robot)
    elseif robotcmd == CYCLE_HOP            toggle_hop(s.robot)

    # Turn left/right (0/.)
    elseif robotcmd == TURN_LEFT            turn_left(s.robot)
    elseif robotcmd == TURN_RIGHT           turn_right(s.robot)
    end
end
