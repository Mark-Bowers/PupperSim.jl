const TPixel = RGB{N0f8}            # Pixel type

mutable struct mjSim
    modelfile

    # visual interaction controls
    lastx::Float64
    lasty::Float64
    button_left::Bool
    button_middle::Bool
    button_right::Bool

    lastbutton::GLFW.MouseButton
    lastclicktm::Float64
    lastcmdkey::Union{GLFW.Key, Nothing}

    refreshrate::Int

    # function keys
    showhelp::Int
    showoption::Bool
    showinfo::Bool
    showdepth::Bool
    showfullscreen::Bool
    # stereo::Bool
    showsensor::Bool
    # profiler::Bool

    slowmotion::Bool
    paused::Bool
    keyreset::Int

    # Video recording
    record::Any
    vidbuf::Vector{UInt8}
    imgstack::Array{Array{TPixel,2},1}

    framecount::Float64
    #framenum::Int
    #lastframenum::Int

    # MuJoCo things
    scn::Ref{mjvScene}
    cam::Ref{mjvCamera}
    vopt::Ref{mjvOption}
    pert::Ref{mjvPerturb}
    con::Ref{mjrContext}
    figsensor::Ref{mjvFigure}
    m::jlModel
    d::jlData

    # Robot controller
    robot::Union{Robot, Nothing}

    # GLFW handle
    window::GLFW.Window
    vmode::GLFW.VidMode

    # Widgets
    # Inset camera view
    showcam::Bool
    camid::Int
    camviewport::mjrRect
    camviewid::Int
    cambuf::Vector{UInt8}

    # ZMQ
    context::Context
    socket::Socket

    #uistate::mjuiState
    #ui0::mjUI
    #ui1::mjUI

    function mjSim(m::jlModel, d::jlData, name::String; width=0, height=0)
        vmode = GLFW.GetVideoMode(GLFW.GetPrimaryMonitor())
        @info("monitor resolution: $(vmode.width)x$(vmode.height)")
        w = width > 0 ? width : Int(floor(vmode.width / 2))
        h = height > 0 ? height : Int(floor(vmode.height / 2))

        s = 512 # Size of square camera viewport in pixels

        # Grab the camera viewport image from the center of the window
        camviewport = mjrRect((w-s)/2, (h-s)/2, s, s)

        # ZMQ
        context = Context()
        socket = Socket(context, PUB)
        bind(socket, "tcp://*:5556")

        new("", 0.0, 0.0, false, false, false, GLFW.MOUSE_BUTTON_1, 0.0, nothing,
            vmode.refreshrate,
            0, false, false, false, false, false, false, true, 0,
            nothing,
            Vector{UInt8}(undef, 0),
            [],
            0.0, #0, 0,
            Ref(mjvScene()),
            Ref(mjvCamera()),
            Ref(mjvOption()),
            Ref(mjvPerturb()),
            Ref(mjrContext()),
            Ref(mjvFigure()),
            m, d,
            nothing,
            GLFW.CreateWindow(w, h, name),
            vmode,
            false, -1, camviewport, -1, Vector{UInt8}(undef, 0),    # Inset camera view
            context,
            socket
            #ui1
        )
    end
end

#export mjSim
