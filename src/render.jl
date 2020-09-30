include("imgui_widgets.jl")

function render(s::PupperSim.mjSim, w::GLFW.Window)
    # Update scene
    mjv_updateScene(s.m, s.d, s.vopt, s.pert, s.cam, MJCore.mjCAT_ALL, s.scn)

    # acquire head mounted camera image
    s.showcam && get_cameraview_image(s)    # must occur before main screen render

    # Render
    width, height = GLFW.GetFramebufferSize(w)
    elapsed_time = @elapsed mjr_render(mjrRect(0,0,width,height), s.scn, s.con)
    #println(round(elapsed_time * 1000; digits=3), " ms")
    #println(s.scn[].flags[1])  # shadows on (1) or off (0)
    if elapsed_time > 0.02 && s.scn[].flags[1] == 1
        # Rendering is taking 20 ms or longer
        @info("Turning off shadows to speed up rendering")
        flags = MVector(s.scn[].flags)
        flags[1] = 0
        s.scn[].flags = flags
    end

    #mjui_render(s.ui1, s.uistate, s.con)

    # display head mounted camera image
    s.showcam && render_camera_view(s)  # must occur after main screen render

    # If recording, record frame this frame
    s.record === nothing || record_video_frame(s, width, height)

    # Swap front and back buffers
    GLFW.SwapBuffers(w)
end
