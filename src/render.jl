include("imgui_widgets.jl")

using BangBang

function render(s::PupperSim.mjSim, w::GLFW.Window)
    # Update scene
    mjv_updateScene(s.m, s.d, s.vopt, s.pert, s.cam, MJCore.mjCAT_ALL, s.scn)

    # acquire head mounted camera image
    s.showcam && get_cameraview_image(s)    # must occur before main screen render

    # Render
    width, height = GLFW.GetFramebufferSize(w)

    #println("shadowClip: $(s.con.x.shadowClip), shadowScale: $(s.con.x.shadowScale), shadowSize: $(s.con.x.shadowSize)")

    elapsed_time = @elapsed mjr_render(mjrRect(0,0,width,height), s.scn, s.con)
    #println(round(elapsed_time * 1000; digits=3), " ms")

    #println(s.scn[].flags[1])  # shadows on (1) or off (0)
    if s.scn[].flags[1] == 1
        if elapsed_time > 0.01  # Rendering time is greater than 10 ms
            if s.m.vis.quality.shadowsize > 64
                @set!! s.m.vis.quality.shadowsize = s.m.vis.quality.shadowsize / 2
                mjr_makeContext(s.m, s.con, FONTSCALE)
                #println("Decreased shadowsize: $(s.m.vis.quality.shadowsize)")
            else
                @info("Turning off shadows to speed up rendering")
                flags = MVector(s.scn[].flags)
                flags[1] = 0
                s.scn[].flags = flags
            end
        elseif elapsed_time < 0.002 && s.m.vis.quality.shadowsize < 16384
            @set!! s.m.vis.quality.shadowsize = s.m.vis.quality.shadowsize * 2
            mjr_makeContext(s.m, s.con, FONTSCALE)  # model specific setup
            #println("Increased shadowsize: $(s.m.vis.quality.shadowsize)")
        end
    end

    #mjui_render(s.ui1, s.uistate, s.con)

    # display head mounted camera image
    s.showcam && render_camera_view(s)  # must occur after main screen render

    # If recording, record frame this frame
    s.record === nothing || record_video_frame(s, width, height)

    # Swap front and back buffers
    GLFW.SwapBuffers(w)
end
