PROJECT = 'test'
VERSION = '2.0.0'
require 'log'
LOG_LEVEL = log.LOGLEVEL_TRACE
require 'sys'
require 'LCD_new'
require 'common'
require 'axp173'
require 'global_variable'
require 'onebutton'
require 'musicplayer'
require 'ebook'
require 'calendar'
require 'audio'

local getGpio10Fnc = pins.setup(pio.P0_10, 1, pio.PULLUP)

sys.taskInit(function()
    -- 挂载 SD 卡
    io.mount(io.SDCARD)
    -- 初始化 axp173 芯片
    axp173.init()
    -- 挂载小奇的 WS2812 库
    local handle = dl.open("/lua/WS2812.lib", "Initialize")
    if handle == false then
        return
    end
    -- WS2812.init(10)
    
    -- local buff = zbuff.create({8,8,24})
    -- buff:drawLine(1,2,5,6,0x00ffff)
    -- sensor.ws2812b(7,"buff",300,700,700,700)

    -- calendar.ShowCalendar()
    -- ebook.ReadFileTable()
    -- ebook.showFileTable()
    -- musicplayer.ReadFileTable()
    -- musicplayer.showFileTable()
    -- axp173.setOutputEnable(axp173.OUTPUT_CHANNEL.OP_LDO4, true)
    -- disp.int()

    -- disp.clear()
    -- -- disp.drawrect(0, 0, 30, 60, 0x00)
    -- disp.setcolor(0X00)
    -- disp.setfontheight(25)
    -- disp.puttext(common.utf8ToGb2312("一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十"),0, 12)
    -- disp.globalUpdate(0)
    -- -- disp.WeatherglobalUpdate(0,"/lua/out.bin")

    -- disp.clear()
    -- -- disp.drawrect(0, 0, 30, 60, 0x00)
    -- disp.globalUpdate(1)

    -- disp.show()
    -- disp.sleep()
    -- axp173.setOutputEnable(axp173.OUTPUT_CHANNEL.OP_LDO4, false)

    

    while true do
        m = WS2812.SendOneFrame(10,"123456781234567812345678")
        print(m)
        -- mmmm(1)
        log.info("OK")
        sys.wait(1000)
        -- mmmm(0)
        
        m = WS2812.SendOneFrame(10,"\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00")
        print(m)
        sys.wait(1000)
        -- getGpio10Fnc(1)
        -- getGpio10Fnc(0)
        -- getGpio10Fnc(1)
        -- getGpio10Fnc(0)
        -- pio.pin.setval(1, 10)
        -- pio.pin.setval(0, 10)
        -- pio.pin.setval(1, 10)
        -- pio.pin.setval(0, 10)
        -- pio.pin.setval(1, 10)
        -- pio.pin.setval(0, 10)
        -- pio.pin.setval(1, 10)
        -- pio.pin.setval(0, 10)
        -- pio.pin.setval(1, 10)
        -- pio.pin.setval(0, 10)
    --播放sd卡根目录下的pwron.mp3
    -- audio.play(1,"TTS","小奇开发芯片测试",audiocore.VOL1,function() sys.publish("AUDIO_PLAY_END") end)
    -- sys.waitUntil("AUDIO_PLAY_END") 
        -- print("testI2c.init1",type())
    end

end)

sys.init(0, 0)
sys.run()
