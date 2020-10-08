const GLFW_LOCK_KEY_MODS = 0x00033004
const GLFW_MOD_CAPS_LOCK = 0x0010   # Caps Lock key is enabled
const GLFW_MOD_NUM_LOCK  = 0x0020   # Num Lock key is enabled

# keypad helper function
function keypadcmd(key::GLFW.Key, mods::Int32)::RobotCmd
    # Keypad keys have a different meaning if ctrl, alt, or both are pressed
    ctrl_or_alt = mods & (GLFW.MOD_CONTROL | GLFW.MOD_ALT) != 0
    ctrl_or_alt && return NO_COMMAND # ctrl, alt, or both are pressed

    # No other modifiers affect this set of keys
    key == GLFW.KEY_KP_SUBTRACT && return TOGGLE_TROT
    key == GLFW.KEY_KP_ADD      && return CYCLE_HOP

    # Only caps lock does not affect this set of keys
    unmodified = mods == 0 || mods == GLFW_MOD_CAPS_LOCK
    unmodified || return NO_COMMAND

    # The following comparisons assume that Num Lock is not toggled on
    key == GLFW.KEY_KP_7 && return INCREASE_HEIGHT    # Increase ride height
    key == GLFW.KEY_KP_8 && return PITCH_NOSE_UP      # Nose up, tail down
    key == GLFW.KEY_KP_9 && return INCREASE_VELOCITY  # Increase trot forward
    key == GLFW.KEY_KP_4 && return DECREASE_YAW       # Veer left
    key == GLFW.KEY_KP_6 && return INCREASE_YAW       # Veer right
    key == GLFW.KEY_KP_1 && return DECREASE_HEIGHT    # Decrease ride height
    key == GLFW.KEY_KP_2 && return PITCH_NOSE_DOWN    # Nose down, tail up
    key == GLFW.KEY_KP_3 && return DECREASE_VELOCITY  # Increase trot forward (reverse)
    key == GLFW.KEY_KP_0 && return ROLL_LEFT          # Roll body to the left
    key == GLFW.KEY_KP_DECIMAL && return ROLL_RIGHT   # Roll body to the right

    return NO_COMMAND
end

function keyboardcmd(key::GLFW.Key, mods::Int32)::RobotCmd
    # Ensure that key is in the shifted state (caps lock or shift key)
    keys_shifted = mods & GLFW.MOD_SHIFT > 0
    keys_shifted || return NO_COMMAND

    # Velocity PgUp / PgDn
    if     key == GLFW.KEY_PAGE_UP return INCREASE_VELOCITY
    elseif key == GLFW.KEY_PAGE_DOWN return DECREASE_VELOCITY

    # Height Home / End
    elseif key == GLFW.KEY_HOME return INCREASE_HEIGHT
    elseif key == GLFW.KEY_END return DECREASE_HEIGHT

    # Yaw left / right arrow
    elseif key == GLFW.KEY_LEFT return INCREASE_YAW
    elseif key == GLFW.KEY_RIGHT return DECREASE_YAW

    # Pitch up / down arrow
    elseif key == GLFW.KEY_UP return PITCH_NOSE_UP
    elseif key == GLFW.KEY_DOWN return PITCH_NOSE_DOWN

    # Roll left/right (Ins/Del)
    elseif key == GLFW.KEY_INSERT return ROLL_LEFT
    elseif key == GLFW.KEY_DELETE return ROLL_RIGHT

    # Toggle activate (`) / trot (-) / hop (+)
    elseif key == GLFW.KEY_1 return TOGGLE_ACTIVATION
    elseif key == GLFW.KEY_MINUS return TOGGLE_TROT
    elseif key == GLFW.KEY_EQUAL return CYCLE_HOP  # (+)

    # Turn left (<) / right (>)
    elseif key == GLFW.KEY_COMMA return TURN_LEFT   # Turn left while trotting in place
    elseif key == GLFW.KEY_PERIOD return TURN_RIGHT # Turn right while trotting in place

    end
end

in_range(key::Int, low::Int, high::Int) = key in low:high
is_keypad_robotcmd(key::GLFW.Key) = in_range(Int(key), Int(GLFW.KEY_KP_0), Int(GLFW.KEY_KP_ENTER))
is_keyboard_robotcmd(key::GLFW.Key) = in_range(Int(key), Int(GLFW.KEY_INSERT), Int(GLFW.KEY_END)) ||
            key == GLFW.KEY_1 || key == GLFW.KEY_MINUS || key == GLFW.KEY_EQUAL ||
            key == GLFW.KEY_COMMA || key == GLFW.KEY_PERIOD

is_robotcmd_turn(c::RobotCmd) = c == TURN_LEFT || c == TURN_RIGHT
# Repeat keys valid for velocity, height, roll, pitch, and yaw commands
is_robotcmd_real_valued(c::RobotCmd) = in_range(Int(c), Int(INCREASE_VELOCITY), Int(ROLL_RIGHT))

const keycmds = Dict{GLFW.Key, Function}(
    GLFW.KEY_F1=>(s)->begin  # help
        s.showhelp += 1
        if s.showhelp > 2 s.showhelp = 0 end
    end,
    GLFW.KEY_F2=>(s)->begin  # option
        s.showoption = !s.showoption
    end,
    GLFW.KEY_F3=>(s)->begin  # info
        s.showinfo = !s.showinfo
    end,
    GLFW.KEY_F4=>(s)->begin  # depth
        s.showdepth = !s.showdepth
    end,
    GLFW.KEY_F5=>(s)->begin  # toggle full screen
        s.showfullscreen = !s.showfullscreen
        s.showfullscreen ? GLFW.MaximizeWindow(s.window) : GLFW.RestoreWindow(s.window)
    end,
    #GLFW.KEY_F6=>(s)->begin  # stereo
    #   s.stereo = s.scn.stereo == MJCore.mjSTEREO_NONE ? mjSTEREO_QUADBUFFERED : MJCore.mjSTEREO_NONE
    #   s.scn[].stereo
    #end,
    GLFW.KEY_F7=>(s)->begin  # sensor figure
        s.showsensor = !s.showsensor
    end,
    GLFW.KEY_F8=>(s)->begin  # profiler
        s.showprofiler = !s.showprofiler
    end,
    GLFW.KEY_ENTER=>(s)->begin  # slow motion
        s.slowmotion = !s.slowmotion
        s.slowmotion ? println("Slow Motion Mode!") : println("Normal Speed Mode!")
    end,
    GLFW.KEY_SPACE=>(s)->begin  # pause
        s.paused = !s.paused
        s.paused ? println("Paused") : println("Running")
    end,
    GLFW.KEY_PAGE_UP=>(s)->begin    # previous keyreset
        s.keyreset = min(s.m.nkey - 1, s.keyreset + 1)
    end,
    GLFW.KEY_PAGE_DOWN=>(s)->begin  # next keyreset
        s.keyreset = max(-1, s.keyreset - 1)
    end,
    # continue with reset
    GLFW.KEY_BACKSPACE=>(s)->begin  # reset
        mj_resetData(s.m.m, s.d.d)
        if s.keyreset >= 0 && s.keyreset < s.m.nkey
            s.time = s.m.key_time[s.keyreset+1]
            s.d.qpos[:] = s.m.key_qpos[:,s.keyreset+1]
            s.d.qvel[:] = s.m.key_qvel[:,s.keyreset+1]
            s.d.act[:]  = s.m.key_act[:,s.keyreset+1]
        end
        mj_forward(s.m, s.d)
        #profilerupdate()
        sensorupdate(s)
    end,
    GLFW.KEY_RIGHT=>(s)->begin  # step forward
        if s.paused
            mj_step(s.m, s.d)
            #profilerupdate()
            sensorupdate(s)
        end
    end,
    GLFW.KEY_LEFT=>(s)->begin  # step back
    #    if s.paused
    #       dt = s.m.opt.timestep
    #       s.m.opt.timestep = -dt
    #       #cleartimers(s.d)
    #       mj_step(s.m, s.d)
    #       s.m.opt.timestep = dt
    #       #profilerupdate()
    #       sensorupdate(s)
    #    end
    end,
    GLFW.KEY_DOWN=>(s)->begin  # step forward 100
        if s.paused
            #cleartimers(d)
            for n=1:100 mj_step(s.m, s.d) end
            #profilerupdate()
            sensorupdate(s)
        end
    end,
    GLFW.KEY_UP=>(s)->begin  # step back 100
    #    if s.paused
    #       dt = s.m.opt.timestep
    #       s.m.opt.timestep = -dt
    #       #cleartimers(d)
    #       for n=1:100 mj_step(s.m, s.d) end
    #       s.m.opt.timestep = dt
    #       #profilerupdate()
    #       sensorupdate(s)
    #    end
    end,
    GLFW.KEY_ESCAPE=>(s)->begin  # free camera
        s.cam[].type = MJCore.CAMERA_FREE
    end,
    GLFW.KEY_EQUAL=>(s)->begin  # bigger font
        if fontscale < 200
            fontscale += 50
            mjr_makeContext(s.m.m, s.con, fontscale)
        end
    end,
    GLFW.KEY_MINUS=>(s)->begin  # smaller font
        if fontscale > 100
            fontscale -= 50
            mjr_makeContext(s.m.m, s.con, fontscale)
        end
    end,
    GLFW.KEY_LEFT_BRACKET=>(s)->begin  # '[' previous fixed camera or free
        fixedcamtype = s.cam[].type
        if s.m.ncam > 0 && fixedcamtype == MJCore.mjCAMERA_FIXED
            fixedcamid = s.cam[].fixedcamid
            if (fixedcamid  > 0)
                s.cam[].fixedcamid = fixedcamid-1
            elseif fixedcamid == 0
                s.cam[].type = MJCore.mjCAMERA_FREE
                s.cam[].fixedcamid = fixedcamid-1
            end
        end
    end,
    GLFW.KEY_RIGHT_BRACKET=>(s)->begin  # ']' next fixed camera
        if s.m.ncam > 0
            fixedcamtype = s.cam[].type
            fixedcamid = s.cam[].fixedcamid
            if fixedcamid < s.m.ncam - 1
                s.cam[].fixedcamid = fixedcamid+1
                s.cam[].type = MJCore.mjCAMERA_FIXED
            end
        end
    end,
    GLFW.KEY_SEMICOLON=>(s)->begin  # cycle over frame rendering modes
        frame = s.vopt.frame
        s.vopt[].frame = max(0, frame - 1)
    end,
    GLFW.KEY_APOSTROPHE=>(s)->begin  # cycle over frame rendering modes
        frame = s.vopt.frame
        s.vopt[].frame = min(MJCore.mjNFRAME-1, frame+1)
    end,
    GLFW.KEY_PERIOD=>(s)->begin  # cycle over label rendering modes
        label = s.vopt.label
        s.vopt[].label = max(0, label-1)
    end,
    GLFW.KEY_SLASH=>(s)->begin  # cycle over label rendering modes
        label = s.vopt.label
        s.vopt[].label = min(MJCore.mjNLABEL-1, label+1)
    end
)

function quit(s::mjSim)
    s.record !== nothing && finish_recording(s)
    GLFW.SetWindowShouldClose(window, true)
end

function keyboard_visualization_keys(s::mjSim, key::GLFW.Key, mods::Int32)
    #println("mjNVISFLAG: $(MJCore.mjNVISFLAG), mjVISSTRING: $(MJCore.mjVISSTRING)\nmjNRNDFLAG: $(MJCore.mjNRNDFLAG), mjRNDSTRING: $(MJCore.mjRNDSTRING), mjNGROUP: $(MJCore.mjNGROUP)")

    # toggle visualization flag
    # NVISFLAG: 22, VISSTRING: ["Convex Hull" "0" "H"; "Texture" "1" "X"; "Joint" "0" "J"; "Actuator" "0" "U"; "Camera" "0" "Q"; "Light" "0" "Z"; "Tendon" "0" "V"; "Range Finder" "0" "Y"; "Constraint" "0" "N"; "Inertia" "0" "I"; "SCL Inertia" "0" "S"; "Perturb Force" "0" "B"; "Perturb Object" "1" "O"; "Contact Point" "0" "C"; "Contact Force" "0" "F"; "Contact Split" "0" "P"; "Transparent" "0" "T"; "Auto Connect" "0" "A"; "Center of Mass" "0" "M"; "Select Point" "0" "E"; "Static Body" "0" "D"; "Skin" "0" ";"]
    if key != GLFW.KEY_S
        for i=1:MJCore.mjNVISFLAG
            #name = MJCore.mjVISSTRING[1, i]
            #println("Comparing $(Int(key)) to $(MJCore.mjVISSTRING[3, i][1])")
            if Int(key) == Int(MJCore.mjVISSTRING[3, i][1])
                flags = MVector(s.vopt[].flags)
                flags[i] = flags[i] == 0 ? 1 : 0
                s.vopt[].flags = flags
                return
            end
        end
    end

    # toggle rendering flag
    # NRNDFLAG: 9,  RNDSTRING: ["Shadow" "1" "S"; "Wireframe" "0" "W"; "Reflection" "1" "R"; "Additive" "0" "L"; "Skybox" "1" "K"; "Fog" "0" "G"; "Haze" "1" "/"; "Segment" "0" ","; "Id Color" "0" "."], NGROUP: 6
    for i=1:MJCore.mjNRNDFLAG
        if Int(key) == Int(MJCore.mjRNDSTRING[3, i][1])
            flags = MVector(s.scn[].flags)
            flags[i] = flags[i] == 0 ? 1 : 0
            s.scn[].flags = flags
            return
        end
    end

    # toggle geom/site group
    for i=1:MJCore.mjNGROUP
        if Int(key) == i + Int('0')
            if mods & GLFW.MOD_SHIFT == true
                sitegroup = MVector(s.vopt[].sitegroup)
                sitegroup[i] = sitegroup[i] > 0 ? 0 : 1
                s.vopt[].sitegroup[i] = sitegroup
                return
            else
                geomgroup = MVector(s.vopt[].geomgroup)
                geomgroup[i] = geomgroup[i] > 0 ? 0 : 1
                s.vopt[].geomgroup = geomgroup
                return
            end
        end
    end
end

function keyboard(s::mjSim, window::GLFW.Window,
                key::GLFW.Key, scancode::Int32, act::GLFW.Action, mods::Int32)

    # Check for robot command key
    if is_keypad_robotcmd(key)                             # KeyPad keys
        robotcmd = keypadcmd(key, mods)
    elseif is_keyboard_robotcmd(key)
        robotcmd = keyboardcmd(key, mods)
    else
        robotcmd = NO_COMMAND
    end

    # Handle key
    if act == GLFW.RELEASE                              # Key release
        # Stop turning on key release
        is_robotcmd_turn(robotcmd) && end_turn(s.robot)
    elseif act == GLFW.REPEAT                           # Key is held down
        # Repeat keys valid for velocity, height, roll, pitch, and yaw commands
        is_robotcmd_real_valued(robotcmd) && execute_robotcmd(s, robotcmd)
    elseif robotcmd != NO_COMMAND                       # Robot command
        execute_robotcmd(s, robotcmd)
    elseif mods & GLFW.MOD_CONTROL == GLFW.MOD_CONTROL  # Ctrl key commands
        if     key == GLFW.KEY_A alignscale(s)
        #elseif key == GLFW.KEY_L reloadmodel(s)
        elseif key == GLFW.KEY_P print_state(s)
        elseif key == GLFW.KEY_Q quit(s)
        elseif key == GLFW.KEY_V record_video(s)
        elseif key == GLFW.KEY_RIGHT_BRACKET s.showcam = !s.showcam
        end
    elseif mods & GLFW.MOD_ALT == GLFW.MOD_ALT          # Alt key commands
        # Placeholder
    elseif mods & GLFW.MOD_SUPER == GLFW.MOD_SUPER      # Super key commands
        # Placeholder
    else                                                # Other unshifed or shifed key commands
        try
            # Attempt lookup in keycmds dict
            keycmds[key](s) # call anonymous function in keycmds Dict
        catch
            # Key was not in the dictionary or keycmds otherwise threw an exception
            keyboard_visualization_keys(s, key, mods)
        end
    end
end
