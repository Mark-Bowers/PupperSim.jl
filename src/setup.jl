# Globals
const FONTSCALE = MJCore.FONTSCALE_200  # can be 100, 150, 200
const maxgeom = 5000                    # preallocated geom array in mjvScene

include("sensor.jl")

# Callbacks
include("keyboard_handler.jl")
include("mouse_handler.jl")

# Utility functions for working with the model's cameras
function list_named_cameras(m::jlModel)
    println("Total number of named cameras: ", m.ncam)
    for i = 1:min(m.ncam, mj.MAXUIMULTI-2)
        println("\t$i: $(mj_id2name(m, mj.OBJ_CAMERA, i-1))")
    end
end

function get_named_cam_id(m::jlModel, camera_name::AbstractString)
    # returns -1 if model does not contain the named camera
    Int(mj_name2id(m, MJCore.mjOBJ_CAMERA, camera_name)::Int32)
end

include("imgui_setup.jl")

# Set up simulator and GLFW window environments
function setup(mm::jlModel, dd::jlData, width=1200, height=900) # TODO named args for callbacks
    GLFW.WindowHint(GLFW.SAMPLES, 4)
    GLFW.WindowHint(GLFW.VISIBLE, 1)

    s = mjSim(mm, dd, "Simulate"; width=width, height=height)

    @info("Refresh Rate: $(s.refreshrate)")
    @info("Resolution: $(width)x$(height)")

    # Make the window's context current
    GLFW.MakeContextCurrent(s.window)
    GLFW.SwapInterval(1) # enable vsync

    # init abstract visualization
    mjv_defaultCamera(s.cam)
    mjv_defaultOption(s.vopt)
    #profilerinit()
    sensorinit(s)

    # make empty scene
    mjv_defaultScene(s.scn)
    mjv_makeScene(s.m, s.scn, maxgeom)

    # mujoco setup
    mjv_defaultPerturb(s.pert)
    mjr_defaultContext(s.con)
    mjr_makeContext(s.m, s.con, FONTSCALE)  # model specific setup

    alignscale(s)
    mjv_updateScene(s.m, s.d, s.vopt, s.pert, s.cam, MJCore.mjCAT_ALL, s.scn)

    # List the named cameras
    # list_named_cameras(s.m)

    # MWB !!! TODO: Generalize this. Name should come from a config file, or  if there are
    # only 3 cameras total (-1, 0, and 1), then we probably know that s.camid should be 1.
    # Get the id of the head mounted camera
    s.camid = get_named_cam_id(s.m, "puppercam")

    # Set up the CImGui environment
    imgui_setup(s.window)

    # create texture for image drawing
    s.camviewid = ImGui_ImplOpenGL3_CreateImageTexture(s.camviewport.width, s.camviewport.height, format=GL_RGB)

    # Set up GLFW callbacks
    GLFW.SetInputMode(s.window, GLFW_LOCK_KEY_MODS, true)
    GLFW.SetKeyCallback(s.window, (w,k,sc,a,m)->keyboard(s,w,k,sc,a,m))
    GLFW.SetCursorPosCallback(s.window, (w,x,y)->mouse_move(s,w,x,y))
    GLFW.SetMouseButtonCallback(s.window, (w,b,a,m)->mouse_button(s,w,b,a,m))
    GLFW.SetScrollCallback(s.window, (w,x,y)->scroll(s,w,x,y))
    ##GLFW.SetDropCallback(s.window, drop)

   return s
end
