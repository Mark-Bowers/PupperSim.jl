#=
This file calculates the raw video sizes for several screen resolutions.
The output is included in PupperSim.jl as a comment block for the loadmodel function.

> julia calculate_raw_videos_sizes.jl
=#

function calculate_raw_videos_sizes(max_frames)
    whparams(w, h) = "$(lpad(w, 4)), $(lpad(h, 4))" # helper function
    wharray = [1920 1080; 1600 900; 1200 900; 1024 768; 800 600; 512 384; 400 300]   # array of resolution options

    for i = 1:size(wharray)[1]          # 1:number of rows
        wh = wharray[i, :]
        aspect_ratio = wh[1,1]//wh[2,1] # rational representation of w/h (w//h)
        @assert aspect_ratio == 16//9 || aspect_ratio == 4//3  "unrecognized aspect ratio: $aspect_ratio"
        pixels = *(wh...)               # number of pixels per image
        bytes = pixels * 3              # 3 bytes per pixel
        mb_per_frame = round(bytes/1048576, digits=2)
        raw_video_size = round((max_frames * mb_per_frame)/1024, digits=1)
        println("# At resolution ($(whparams(wh...))): $mb_per_frame MB/frame, total raw video size: $(lpad(raw_video_size, 4)) GB")
    end
end

# These constants copied from PupperSim.jl 
const max_video_duration = 60       # max video duration in seconds
const video_frames_per_second = 30  # determined by GLFW.GetPrimaryMonitor refresh rate
const max_video_frames = video_frames_per_second * max_video_duration

calculate_raw_videos_sizes(max_video_frames)

