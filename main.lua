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
    -- axp173.setOutputEnable(axp173.OUTPUT_CHANNEL.OP_LDO4, true)
    -- disp.int()

    -- disp.clear()
    -- -- disp.drawrect(0, 0, 30, 60, 0x00)
    -- page = 0
    -- disp.setcolor(0X00)
    -- disp.setfontheight(30)
    -- disp.puttext(common.utf8ToGb2312("播放SD卡音乐"), 10, 0)
    -- -- 遍历读取sd目录
    -- if io.opendir("/sdcard0/music") then
    --     for i = page * 4 + 1, page * 4 + 4 do
    --         local fType, fName, fSize = io.readdir()
    --         if fType == 32 then
    --             log.info("sd card file", fName, fSize)
    --             disp.puttext(common.utf8ToGb2312(i .. "." .. fName), 10, i * 40)
    --         elseif fType == nil then
    --             break
    --         end
    --     end
    --     io.closedir("/sdcard0/music")
    -- else
    --     disp.puttext(common.utf8ToGb2312("SD卡音乐目录打开失败"), 10,
    --                  30)
    -- end
    -- disp.puttext(common.utf8ToGb2312("第" .. (page + 1) ..
    --                                      "页，长按4下一页，1上一页"),
    --              0, 260)
    -- disp.globalUpdate(0)
    -- -- disp.WeatherglobalUpdate(0,"/lua/out.bin")

    -- disp.clear()
    -- -- disp.drawrect(0, 0, 30, 60, 0x00)
    -- disp.globalUpdate(1)

    -- disp.show()
    -- disp.sleep()
    -- axp173.setOutputEnable(axp173.OUTPUT_CHANNEL.OP_LDO4, false)

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
