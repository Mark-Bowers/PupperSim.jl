# Segment image into red ball (filtered to red channel only) and background (conveted to grayscale)
# returns total number of red pixels, and x and y coordinates at centroid of red pixels
function segment_image(image::AbstractArray, img_width::Int, img_height::Int, drawcross::Bool = true;
        crosscolor = RGB{N0f8}(0, 1, 0))
    # Initialize counters
    c = 0; xs = 0; ys = 0

    # Count, sum, and segment
    for x = 1:img_width
        for y = 1:img_height
            p = image[x, y]

            # Check if red channel contribution is at least twice the green or blue channel for this pixel
            is_red = p.r > .1 && p.g < p.r / 2 && p.b < p.r / 2

            # Segment between ball (render red channel only) and the background (conveted to grayscale)
            if is_red
                c += 1; xs += x; ys += y
                image[x, y] = RGB{N0f8}(p.r, 0, 0)
            else
                image[x, y] = convert(ColorTypes.Gray{N0f8}, p)
            end
        end
    end

    # Return if no red pixels found
    c == 0 && return 0, 0.0, 0.0    # centroid values are invalid

    x = round(Int, xs / c)
    y = round(Int, ys / c)

    # Check if cross would be clipped
    fits_inside = x > 1 && y > 1 && x < img_width && y < img_height

    if drawcross && fits_inside
        # Draw crosshairs
        image[x, y]   = crosscolor
        image[x-1, y] = crosscolor
        image[x+1, y] = crosscolor
        image[x, y-1] = crosscolor
        image[x, y+1] = crosscolor
    end

    # Normalize mean point around center point
    x /= img_width; y /= img_height
    x -= 0.5; y -= 0.5

    return c, x, y # count of red pixels, mean x value, mean y value (translated and scaled)
end

# Acquire image for the inset view
function get_cameraview_image(s::mjSim)
    # Compute the necessary buffer size to hold the camera view image
    img_width = Int(s.camviewport.width)    # Convert from Int32s to Ints with WORD_SIZE bits (64)
    img_height = Int(s.camviewport.height)
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

    # Isolate the red ball
    c, x, y = segment_image(image, img_width, img_height)
    #println("$c, $x, $y")

    # Flip the image horizonally for ImGui and reshape back to UInt8 buffer
    reshape(reinterpret(UInt8, hflip!(image)), (buflen,))
end

function render_camera_view(s::mjSim)
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
