# Acquire image for the inset view
function get_cameraview_image(s::mjSim)
    # Compute the necessary buffer size to hold the camera view image
    img_width = s.camviewport.width
    img_height = s.camviewport.height
    buflen = img_width * img_height * sizeof(TPixel)

    # We may need to allocate a new buffer if user has resized the window
    if length(s.cambuf) != buflen
        s.cambuf = Vector{UInt8}(undef, buflen)
    end

    # Save current camera view
    current_camid = s.cam[].fixedcamid
    current_camtype = s.cam[]._type

    # Switch to head mounted camera view
    s.cam[].fixedcamid = s.camid
    s.cam[]._type = Int(mj.CAMERA_FIXED)

    # Update camera for the head mounted camera
    mjv_updateCamera(s.m, s.d, s.cam, s.scn)

    # Get the pixels from MuJoCo for the inset view
    mjr_render(s.camviewport, s.scn, s.con)                 # 1 allocation: 32 bytes!
    mjr_readPixels(s.cambuf, C_NULL, s.camviewport, s.con)  # 1 allocation: 32 bytes!

    # Restore current camera view
    s.cam[].fixedcamid = current_camid
    s.cam[]._type = current_camtype

    # Update camera for the restored camera
    mjv_updateCamera(s.m, s.d, s.cam, s.scn)

    # Shape the buffer into an image array of RGB pixels
    image = reshape(reinterpret(TPixel, s.cambuf), img_width, img_height)

    # Flip the image horizonally for ImGui and reshape back to UInt8 buffer
    reshape(reinterpret(UInt8, hflip!(image)), (buflen,))
end

function render_image(s::mjSim)
    # Start the Dear ImGui frame for Picture-in-picture (PiP) inset camera view
    ImGui_ImplOpenGL3_NewFrame()
    ImGui_ImplGlfw_NewFrame()
    CImGui.NewFrame()

    # Show image
    CImGui.Begin("Camera View")
    ImGui_ImplOpenGL3_UpdateImageTexture(s.camviewid, s.cambuf, s.camviewport.width, s.camviewport.height, format = GL_RGB)
    CImGui.Image(Ptr{Cvoid}(s.camviewid), (s.camviewport.width, s.camviewport.height))
    CImGui.End()

    # ImGui rendering
    CImGui.Render()
    ImGui_ImplOpenGL3_RenderDrawData(CImGui.GetDrawData())
end
