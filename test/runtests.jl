using PupperSim
using Test

@testset "PupperSim.jl" begin
    @test size(names(PupperSim)) == (4,)
    @test names(PupperSim)[1] == :PupperSim
    @test names(PupperSim)[2] == :loadmodel
    @test names(PupperSim)[3] == :pupper
    @test names(PupperSim)[4] == :simulate
end

@testset "pupper" begin
    robot = pupper()
    @test string(robot.command) == "QuadrupedController.Command([0.4, 0.0], 0.0, -0.06, 0.1, 0.0, 0, false, false, false)"
end

@testset "PupperSim.RobotCmd" begin
    @test string(PupperSim.TURN_LEFT) == "TURN_LEFT"
    @test Int(PupperSim.TURN_LEFT) == 13
end

using GLFW
const GLFW_MOD_CAPS_LOCK = 0x0010   # Caps Lock key is enabled
const GLFW_MOD_NUM_LOCK  = 0x0020   # Num Lock key is enabled

@testset "PupperSim.keypadcmd" begin
    @test PupperSim.keypadcmd(GLFW.KEY_KP_ADD, Int32(0))                    == PupperSim.CYCLE_HOP
    @test PupperSim.keypadcmd(GLFW.KEY_KP_ADD, Int32(GLFW.MOD_SHIFT))       == PupperSim.CYCLE_HOP
    @test PupperSim.keypadcmd(GLFW.KEY_KP_ADD, Int32(GLFW.MOD_CONTROL))     == PupperSim.NO_COMMAND
    @test PupperSim.keypadcmd(GLFW.KEY_KP_ADD, Int32(GLFW.MOD_ALT))         == PupperSim.NO_COMMAND
    @test PupperSim.keypadcmd(GLFW.KEY_KP_ADD, Int32(GLFW.MOD_SUPER))       == PupperSim.CYCLE_HOP
    @test PupperSim.keypadcmd(GLFW.KEY_KP_ADD, Int32(GLFW_MOD_CAPS_LOCK))   == PupperSim.CYCLE_HOP
    @test PupperSim.keypadcmd(GLFW.KEY_KP_ADD, Int32(GLFW_MOD_NUM_LOCK))    == PupperSim.CYCLE_HOP

    @test PupperSim.keypadcmd(GLFW.KEY_KP_7, Int32(0))                      == PupperSim.INCREASE_HEIGHT
    @test PupperSim.keypadcmd(GLFW.KEY_KP_7, Int32(GLFW.MOD_SHIFT))         == PupperSim.NO_COMMAND
    @test PupperSim.keypadcmd(GLFW.KEY_KP_7, Int32(GLFW.MOD_CONTROL))       == PupperSim.NO_COMMAND
    @test PupperSim.keypadcmd(GLFW.KEY_KP_7, Int32(GLFW.MOD_ALT))           == PupperSim.NO_COMMAND
    @test PupperSim.keypadcmd(GLFW.KEY_KP_7, Int32(GLFW.MOD_SUPER))         == PupperSim.NO_COMMAND
    @test PupperSim.keypadcmd(GLFW.KEY_KP_7, Int32(GLFW_MOD_CAPS_LOCK))     == PupperSim.INCREASE_HEIGHT
    @test PupperSim.keypadcmd(GLFW.KEY_KP_7, Int32(GLFW_MOD_NUM_LOCK))      == PupperSim.NO_COMMAND
end

@testset "PupperSim.keyboardcmd" begin
    @test PupperSim.keyboardcmd(GLFW.KEY_PAGE_UP, Int32(0))                 == PupperSim.NO_COMMAND
    @test PupperSim.keyboardcmd(GLFW.KEY_PAGE_UP, Int32(GLFW.MOD_SHIFT))    == PupperSim.INCREASE_VELOCITY
    @test PupperSim.keyboardcmd(GLFW.KEY_PAGE_UP, Int32(GLFW.MOD_CONTROL))  == PupperSim.NO_COMMAND
    @test PupperSim.keyboardcmd(GLFW.KEY_PAGE_UP, Int32(GLFW.MOD_ALT))      == PupperSim.NO_COMMAND
    @test PupperSim.keyboardcmd(GLFW.KEY_PAGE_UP, Int32(GLFW.MOD_SUPER))    == PupperSim.NO_COMMAND
    @test PupperSim.keyboardcmd(GLFW.KEY_PAGE_UP, Int32(GLFW_MOD_CAPS_LOCK))== PupperSim.NO_COMMAND
    @test PupperSim.keyboardcmd(GLFW.KEY_PAGE_UP, Int32(GLFW_MOD_NUM_LOCK)) == PupperSim.NO_COMMAND

    @test PupperSim.keyboardcmd(GLFW.KEY_PERIOD, Int32(0))                  == PupperSim.NO_COMMAND
    @test PupperSim.keyboardcmd(GLFW.KEY_PERIOD, Int32(GLFW.MOD_SHIFT))     == PupperSim.TURN_RIGHT
    @test PupperSim.keyboardcmd(GLFW.KEY_PERIOD, Int32(GLFW.MOD_CONTROL))   == PupperSim.NO_COMMAND
    @test PupperSim.keyboardcmd(GLFW.KEY_PERIOD, Int32(GLFW.MOD_ALT))       == PupperSim.NO_COMMAND
    @test PupperSim.keyboardcmd(GLFW.KEY_PERIOD, Int32(GLFW.MOD_SUPER))     == PupperSim.NO_COMMAND
    @test PupperSim.keyboardcmd(GLFW.KEY_PERIOD, Int32(GLFW_MOD_CAPS_LOCK)) == PupperSim.NO_COMMAND
    @test PupperSim.keyboardcmd(GLFW.KEY_PERIOD, Int32(GLFW_MOD_NUM_LOCK))  == PupperSim.NO_COMMAND
end
