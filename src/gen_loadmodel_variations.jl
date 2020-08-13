function gen_loadmodel_variations(max_frames = 15 * 60)
    whparams(w, h) = "$(lpad(w, 4)), $h"    # helper function
    wharray = [1200 900; 1024 768; 800 600; 512 384; 400 300]   # array of 4//3 width x height options

    for i = 1:size(wharray)[1]
        wh = wharray[i, :]
        aspect_ratio = wh[1,1]//wh[2,1] # rational representation of w/h (w//h)
        @assert aspect_ratio == 4//3 "aspect ratio $aspect_ratio not equal to 4//3"
        pixels = *(wh...)               # number of pixels per image
        bytes = pixels * 3              # 3 bytes per pixel
        mb_per_frame = round(bytes/1048576, digits=2)
        max_sizeof_imgstack = round((max_frames * mb_per_frame)/1024, digits=1)
        println("#s = loadmodel(modelpath, $(whparams(wh...))) # $mb_per_frame MB/frame (max sizeof(imgstack): $max_sizeof_imgstack GB)")
    end
end

gen_loadmodel_variations()

