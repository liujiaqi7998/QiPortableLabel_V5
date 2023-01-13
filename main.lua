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

sys.taskInit(function()
    io.mount(io.SDCARD)
    axp173.init()

    -- musicplayer.ReadFileTable()
    -- musicplayer.showFileTable()
    axp173.setOutputEnable(axp173.OUTPUT_CHANNEL.OP_LDO4, true)
    disp.int()

    disp.clear()
    -- disp.drawrect(0, 0, 30, 60, 0x00)
    disp.setcolor(0X00)
    disp.setfontheight(25)
    disp.puttext(common.utf8ToGb2312("一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十"),0, 12)
    disp.globalUpdate(0)
    -- disp.WeatherglobalUpdate(0,"/lua/out.bin")

    disp.clear()
    -- disp.drawrect(0, 0, 30, 60, 0x00)
    disp.globalUpdate(1)

    disp.show()
    disp.sleep()
    axp173.setOutputEnable(axp173.OUTPUT_CHANNEL.OP_LDO4, false)

    while true do
        -- mmmm(1)
        log.info("OK")
        sys.wait(1000)
        -- mmmm(0)
        sys.wait(1000)

        -- print("testI2c.init1",type())
    end

end)

sys.init(0, 0)
sys.run()
