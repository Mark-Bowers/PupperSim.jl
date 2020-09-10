const vfname = "puppersim.mp4"      # Video file name

##################################################### functions
function finish_recording(s::mjSim)
    # Primarily see avio.jl reference in render function below. Also of potential interest:
    # https://github.com/JuliaIO/VideoIO.jl/tree/master/examples
    # https://discourse.julialang.org/t/creating-a-video-from-a-stack-of-images/646/7

    @static if use_VideoIO
        println("Saving video to: $vfname")
        props = [:priv_data => ("crf"=>"22","preset"=>"medium")]
        @time encodedvideopath = VideoIO.encodevideo(vfname, s.imgstack, framerate=30, AVCodecContextProperties=props, silent=false)
        s.imgstack = []
    else
        println("Closing $vfname")
        close(s.record)
    end

    println("Done writing video!")
    s.record = nothing
end

function record_video(s::mjSim)
    if s.record === nothing
        println("Recording")
        @static if use_VideoIO
            s.record = 0
        else
            println("Saving video to $vfname")
            w, h = GLFW.GetFramebufferSize(s.window)

            # -y overwrite output files
            # -f force format
            @ffmpeg_env s.record = open(`ffmpeg -y
                            -f rawvideo -pixel_format rgb24
                            -video_size $(w)x$(h) -framerate $(s.refreshrate)
                            -i pipe:0
                            -preset fast -threads 0
                            -vf "vflip" $vfname`, "w")
        end
    else
        finish_recording(s)
    end
end

function record_video_frame(s::mjSim, width, height)
    @static if use_VideoIO
    if s.record <= max_video_frames
        s.record += 1

        # Image dims must be a multiple of two
        width  = div(width,  2) * 2 # ensure that width is even
        height = div(height, 2) * 2 # ensure that height is even
        buflen = width * height * sizeof(TPixel)

        # If user has resized the window, we may need to allocate a new buffer
        if length(s.vidbuf) != buflen
            s.vidbuf = Vector{UInt8}(undef, buflen)
        end

        # Get the pixels from MuJoCo
        viewrect = mjrRect(0, 0, width, height)
        mjr_readPixels(s.vidbuf, C_NULL, viewrect, s.con)

        # Reference: @testset "Encoding video across all supported colortypes" block in file avio.jl:
        # (https://github.com/JuliaIO/VideoIO.jl/blob/master/test/avio.jl)

        # Reinterpret the video buffer as pixels
        pixels = reinterpret(TPixel, s.vidbuf)

        # Shape the buffer into an image array
        image = reshape(pixels, width, height)

        # Allocate an uninitialized frame on the image stack
        push!(s.imgstack, Array{TPixel,2}(undef, height, width))

        # Permute image array from column major to row major and write the
        # result to the uninitialized memory at the top of the image stack
        permutedims!(s.imgstack[end], image, (2,1))

        # Flip the image in place on the image stack in the vertical direction
        vflip!(s.imgstack[end])
    else    # s.record <= max_video_frames
        finish_recording(s)
    end     # s.record <= max_video_frames
    else    # @static if use_VideoIO
        buflen = width * height * sizeof(TPixel)

        # If user has resized the window, we may need to allocate a new buffer
        if length(s.vidbuf) != buflen
            s.vidbuf = Vector{UInt8}(undef, buflen)
        end

        # Get the pixels from MuJoCo
        viewrect = mjrRect(0, 0, width, height)
        mjr_readPixels(s.vidbuf, C_NULL, viewrect, s.con)
        write(s.record, s.vidbuf)
    end # @static if use_VideoIO
end
