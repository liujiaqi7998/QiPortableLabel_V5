--
module(..., package.seeall)

local getGpio10Fnc = pins.setup(pio.P0_10, 1, pio.PULLUP)

local mode = 0
local close_str = string.rep("\x00", 24)

function init()
    -- 挂载小奇的 WS2812 库
    local handle = dl.open("/lua/WS2812.lib", "Initialize")
    if handle == false then return end
    WS2812.SendOneFrame(10,close_str)
    WS2812.SendOneFrame(10,close_str)
    -- sys.wait(1000)
    -- show(255,0,0)
    -- sys.wait(1000)
    -- WS2812.SendOneFrame(10,close_str)
    -- sys.wait(1000)
    -- show(0,255,0)
    -- sys.wait(1000)
    -- WS2812.SendOneFrame(10,close_str)
    -- sys.wait(1000)
    -- show(0,0,255)
    -- sys.wait(1000)
    -- WS2812.SendOneFrame(10,close_str)
    -- sys.wait(1000)
    -- show(255,0,0)
    -- sys.wait(1000)
    -- WS2812.SendOneFrame(10,close_str)
    -- sys.wait(1000)
    -- show(0,255,0)
    -- sys.wait(1000)
    -- WS2812.SendOneFrame(10,close_str)
    -- sys.wait(1000)
    -- show(0,0,255)
    -- sys.wait(1000)
    -- WS2812.SendOneFrame(10,close_str)
    -- sys.taskInit(function()

    --     while true do
    --         -- if mode == 0 then
    --         --     WS2812.SendOneFrame(10,
    --         --                         "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00")
    --         --     WS2812.SendOneFrame(10,
    --         --                         "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00")
    --         -- end
    --         -- if mode == 1 then
    --         --     WS2812.SendOneFrame(10,
    --         --                         "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00")
    --         --     WS2812.SendOneFrame(10,
    --         --                         "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00")
    --         --     sys.wait(1000)
    --         --     WS2812.SendOneFrame(10, "123456781234567812345678")
    --         --     sys.wait(1000)
    --         -- end
    --     end
    -- end)
end

function show(R,G,B)
    -- G R B
    WS2812.SendOneFrame(10, string.char(G,R,B) .. string.rep("\x00", 21))
end

function close()
    WS2812.SendOneFrame(10,close_str)
    sys.wait(10)
    WS2812.SendOneFrame(10,close_str)
end

function change_mode(x)
    mode = x
end
