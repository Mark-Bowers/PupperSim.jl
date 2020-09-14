@static if Sys.isapple()
    # OpenGL 3.2 + GLSL 150
    const glsl_version = 150
    GLFW.WindowHint(GLFW.CONTEXT_VERSION_MAJOR, 3)
    GLFW.WindowHint(GLFW.CONTEXT_VERSION_MINOR, 2)
    GLFW.WindowHint(GLFW.OPENGL_PROFILE, GLFW.OPENGL_CORE_PROFILE) # 3.2+ only
    GLFW.WindowHint(GLFW.OPENGL_FORWARD_COMPAT, GL_TRUE) # required on Mac
else
    #=
    using GLFW_jll
    function glfwGetVersion()
        major, minor, rev = Ref{Cint}(), Ref{Cint}(), Ref{Cint}()
        ccall((:glfwGetVersion, libglfw), Cvoid, (Ref{Cint}, Ref{Cint}, Ref{Cint}), major, minor, rev)
        return major[], minor[], rev[]
    end

    major, minor, rev = glfwGetVersion()
    #(3, 3, 2)

    GLSL Version | OpenGL Version |   Date     | Shader Preprocessor
    1.10.59[1]	        2.0	    30 April 2004	    #version 110
    1.20.8[2]	        2.1	    07 September 2006	#version 120
    1.30.10[3]	        3.0	    22 November 2009	#version 130
    1.40.08[4]	        3.1	    22 November 2009	#version 140
    1.50.11[5]	        3.2	    04 December 2009	#version 150
    3.30.6[6]	        3.3	    11 March 2010	    #version 330
    4.00.9[7]	        4.0	    24 July 2010	    #version 400
    4.10.6[8]	        4.1	    24 July 2010	    #version 410
    4.20.11[9]	        4.2	    12 December 2011	#version 420
    4.30.8[10]	        4.3	    7 February 2013	    #version 430
    4.40.9[11]	        4.4	    16 June 2014	    #version 440
    4.50.7[12]	        4.5	    09 May 2017         #version 450
    4.60.5[13]	        4.6	    14 June 2018	    #version 460

    const glsl_version = major * 100 + minor * 10

    major = 3
    minor = 3
    const glsl_version = major * 100 + minor * 10
    =#

    # OpenGL 3.3 + GLSL 330
    const glsl_version = 330
    GLFW.WindowHint(GLFW.CONTEXT_VERSION_MAJOR, 3)
    GLFW.WindowHint(GLFW.CONTEXT_VERSION_MINOR, 3)
    # GLFW.WindowHint(GLFW.OPENGL_PROFILE, GLFW.OPENGL_CORE_PROFILE) # 3.2+ only
end

function imgui_setup(window::GLFW.Window)
    # setup Dear ImGui context
    ctx = CImGui.CreateContext()

    # setup Dear ImGui style
    CImGui.StyleColorsDark()
    # CImGui.StyleColorsClassic()
    # CImGui.StyleColorsLight()

    # load Fonts
    # - If no fonts are loaded, dear imgui will use the default font.
    fonts = CImGui.GetIO().Fonts
    default_font = CImGui.AddFontDefault(fonts)
    @assert default_font != C_NULL

    # You can also load multiple fonts and use `CImGui.PushFont/PopFont` to select them.
    # - `CImGui.AddFontFromFileTTF` will return the `Ptr{ImFont}` so you can store it if you need to select the font among multiple.
    # - If the file cannot be loaded, the function will return C_NULL. Please handle those errors in your application (e.g. use an assertion, or display an error and quit).
    # - The fonts will be rasterized at a given size (w/ oversampling) and stored into a texture when calling `CImGui.Build()`/`GetTexDataAsXXXX()``, which `ImGui_ImplXXXX_NewFrame` below will call.
    # - Read 'fonts/README.txt' for more instructions and details.

    # fonts_dir = joinpath(pathof(CImGui), "../..", "fonts")
    # CImGui.AddFontFromFileTTF(fonts, joinpath(fonts_dir, "Cousine-Regular.ttf"), 15)
    # CImGui.AddFontFromFileTTF(fonts, joinpath(fonts_dir, "DroidSans.ttf"), 16)
    # CImGui.AddFontFromFileTTF(fonts, joinpath(fonts_dir, "Karla-Regular.ttf"), 10)
    # CImGui.AddFontFromFileTTF(fonts, joinpath(fonts_dir, "ProggyTiny.ttf"), 10)
    # CImGui.AddFontFromFileTTF(fonts, joinpath(fonts_dir, "Roboto-Medium.ttf"), 16)
    # CImGui.AddFontFromFileTTF(fonts, joinpath(fonts_dir, "Recursive Mono Casual-Regular.ttf"), 16)
    # CImGui.AddFontFromFileTTF(fonts, joinpath(fonts_dir, "Recursive Mono Linear-Regular.ttf"), 16)
    # CImGui.AddFontFromFileTTF(fonts, joinpath(fonts_dir, "Recursive Sans Casual-Regular.ttf"), 16)
    # CImGui.AddFontFromFileTTF(fonts, joinpath(fonts_dir, "Recursive Sans Linear-Regular.ttf"), 16)

    # setup Platform/Renderer bindings
    #ImGui_ImplGlfw_InitForOpenGL(s.window, true)
    ImGui_ImplGlfw_InitForOpenGL(window, false) # Don't install callbacks
    ImGui_ImplOpenGL3_Init(glsl_version)
end
