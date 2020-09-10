function mouse_move(s::mjSim, window::GLFW.Window, xpos::Float64, ypos::Float64)
    # no buttons down: nothing to do
    if !s.button_left && !s.button_middle && !s.button_right
        return
    end

    # compute mouse displacement, save
    dx = xpos - s.lastx
    dy = ypos - s.lasty
    s.lastx = xpos
    s.lasty = ypos

    width, height = GLFW.GetWindowSize(window)

    mod_shift = GLFW.GetKey(window, GLFW.KEY_LEFT_SHIFT) || GLFW.GetKey(window, GLFW.KEY_RIGHT_SHIFT)

    # determine action based on mouse button
    if s.button_right
        action = mod_shift ? Int(mj.MOUSE_MOVE_H) : Int(mj.MOUSE_MOVE_V)
    elseif s.button_left
        action = mod_shift ? Int(mj.MOUSE_ROTATE_H) : Int(mj.MOUSE_ROTATE_V)
    else
        action = Int(mj.MOUSE_ZOOM)
    end

    # move perturb or camera
    if s.pert[].active != 0
        mjv_movePerturb(s.m.m, s.d.d, action,
                        dx / height, dy / height,
                        s.scn, s.pert)
    else
        mjv_moveCamera(s.m.m, action,
                        dx / height, dy / height,
                        s.scn, s.cam)
    end
end

# past data for double-click detection
function mouse_button(s::mjSim, window::GLFW.Window,
                      button::GLFW.MouseButton, act::GLFW.Action, mods::Int32)
    # update button state
    s.button_left = GLFW.GetMouseButton(window, GLFW.MOUSE_BUTTON_LEFT)
    s.button_middle = GLFW.GetMouseButton(window, GLFW.MOUSE_BUTTON_MIDDLE)
    s.button_right = GLFW.GetMouseButton(window, GLFW.MOUSE_BUTTON_RIGHT)

    # Alt: swap left and right
    if mods == GLFW.MOD_ALT
        tmp = s.button_left
        s.button_left = s.button_right
        s.button_right = tmp

        if button == GLFW.MOUSE_BUTTON_LEFT
            button = GLFW.MOUSE_BUTTON_RIGHT
        elseif button == GLFW.MOUSE_BUTTON_RIGHT
            button = GLFW.MOUSE_BUTTON_LEFT
        end
    end

    # update mouse position
    x, y = GLFW.GetCursorPos(window)
    s.lastx = x
    s.lasty = y

    # set perturbation
    newperturb = 0
    if act == GLFW.PRESS && mods == GLFW.MOD_CONTROL && s.pert[].select > 0
        # right: translate;  left: rotate
        if s.button_right
            newperturb = Int(mj.PERT_TRANSLATE)
        elseif s.button_left
            newperturb = Int(mj.PERT_ROTATE)
        end
        # perturbation onset: reset reference
        if newperturb>0 && s.pert[].active==0
            mjv_initPerturb(s.m.m, s.d.d, s.scn, s.pert)
        end
    end
    s.pert[].active = newperturb

    # detect double-click (250 msec)
    if act == GLFW.PRESS && (time() - s.lastclicktm < 0.25) && (button == s.lastbutton)
        # determine selection mode
        if button == GLFW.MOUSE_BUTTON_LEFT
            selmode = 1
        elseif mods == GLFW.MOD_CONTROL
            selmode = 3; # CTRL + Right Click
        else
            selmode = 2; # Right Click
        end
        # get current window size
        width, height = GLFW.GetWindowSize(window)

        # find geom and 3D click point, get corresponding body
        selpnt = zeros(3)
        selgeom, selskin = Int32(0), Int32(0)
        selbody = mjv_select(s.m.m, s.d.d, s.vopt,
                            width / height, x / width,
                            (height - y) / height,
                            s.scn, selpnt, selgeom, selskin)

        # set lookat point, start tracking if requested
        if selmode == 2 || selmode == 3
            # copy selpnt if geom clicked
            if selbody >= 0
                s.cam[].lookat = SVector{3,Float64}(selpnt...)
            end

            # switch to tracking camera
            if selmode == 3 && selbody >= 0
                s.cam[]._type = Int(mj.CAMERA_TRACKING)
                s.cam[].trackbodyid = selbody
                s.cam[].fixedcamid = -1
            end
        else # set body selection
            if selbody >= 0
                # compute localpos
                tmp = selpnt - s.d.xpos[:,selbody+1]
                res = reshape(s.d.xmat[:,selbody+1], 3, 3)' * tmp
                s.pert[].localpos = SVector{3}(res)

                # record selection
                s.pert[].select = selbody
                s.pert[].skinselect = selskin
            else
                s.pert[].select = 0
                s.pert[].skinselect = -1
            end
        end

        # stop perturbation on select
        s.pert[].active = 0
    end
    # save info
    if act == GLFW.PRESS
        s.lastbutton = button
        s.lastclicktm = time()
    end
end

function scroll(s::mjSim, window::GLFW.Window, xoffset::Float64, yoffset::Float64)
    # scroll: emulate vertical mouse motion = 5% of window height
    mjv_moveCamera(s.m.m, Int(mj.MOUSE_ZOOM), 0.0, -0.05 * yoffset, s.scn, s.cam)
end

function drop(window::GLFW.Window,
    count::Int, paths::String)
end
