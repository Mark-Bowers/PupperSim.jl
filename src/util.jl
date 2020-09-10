# Flip image pixels vertically
@static if use_VideoIO
function vflip!(A)
    nrows, ncols = size(A)
    nrp1 = nrows + 1
    for col = 1:ncols
        for row = 1:div(nrows,  2)
            t = A[nrp1-row, col]
            A[nrp1-row, col] = A[row, col]
            A[row, col] = t
        end
    end

    return A
end
end

# Flip image pixels horizontally
function hflip!(A)
    nrows, ncols = size(A)
    ncp1 = ncols + 1
    for row = 1:nrows
        for col = 1:div(ncols, 2)
            t = A[row, ncp1-col]
            A[row, ncp1-col] = A[row, col]
            A[row, col] = t
        end
    end

    return A
end

function alignscale(s::mjSim)
    s.cam[].lookat = s.m.m[].stat.center
    s.cam[].distance = 1.5*s.m.m[].stat.extent

    # set to free camera
    s.cam[]._type = Cint(mj.CAMERA_FREE)
end

function str2vec(s::String, len::Int)
    str = zeros(UInt8, len)
    str[1:length(s)] = codeunits(s)
    return str
end

#=
function reloadmodel(s::mjSim)
    width, height = GLFW.GetFramebufferSize(s.window)

    loadmodel(s.modelfile, width, height)
end
=#

function print_state(s::mjSim)
    #println(s.d.qpos)
    c = s.robot.command
    println("== Robot state ==")
    println("velocity: $(round(c.horizontal_velocity[1], digits=2))")
    println("height:   $(round(c.height,    digits=2))")
    println("yaw:      $(round(c.yaw_rate,  digits=2))")
    println("pitch:    $(round(c.pitch,     digits=2))")
    println("roll:     $(round(c.roll,      digits=2))")
    #println("=================")
end
