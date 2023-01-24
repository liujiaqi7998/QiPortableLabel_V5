PROJECT = 'test'
VERSION = '2.0.0'
require 'log'
LOG_LEVEL = log.LOGLEVEL_TRACE
require 'sys'

--加载日志功能模块，并且设置日志输出等级
--如果关闭调用log模块接口输出的日志，等级设置为log.LOG_SILENT即可
require "log"
LOG_LEVEL = log.LOGLEVEL_TRACE
require "net"
--每1分钟查询一次GSM信号强度
--每1分钟查询一次基站信息
net.startQueryAll(60000, 60000)
--此处关闭RNDIS网卡功能
--否则，模块通过USB连接电脑后，会在电脑的网络适配器中枚举一个RNDIS网卡，电脑默认使用此网卡上网，导致模块使用的sim卡流量流失
--如果项目中需要打开此功能，把ril.request("AT+RNDISCALL=0,1")修改为ril.request("AT+RNDISCALL=1,1")即可
--注意：core固件：V0030以及之后的版本、V3028以及之后的版本，才以稳定地支持此功能
ril.request("AT+RNDISCALL=0,1")
log.openTrace(true,1,115200)

require 'common'
require 'ntp'
require 'LCD_new'
require 'axp173'
require 'global_variable'
require 'onebutton'
require 'musicplayer'
require 'ebook'
require 'calendar'
require 'audio'
require 'Light'
require 'weather'

local menu_page = 1

function show_menu()
    
    global_variable.page_id = ""
    axp173.setOutputEnable(axp173.OUTPUT_CHANNEL.OP_LDO4, true)
    disp.int()
    disp.BINglobalUpdate(0, "/lua/menu" .. menu_page .. ".bin")
    disp.clear()
    disp.setcolor(0X00)
    disp.setfontheight(25)
    disp.puttext(common.utf8ToGb2312("小奇智能便签"), 123, 10)
    disp.setfontheight(35)
    local t = os.date("*t")
    disp.puttext(common.utf8ToGb2312(string.format("%04d 年", 2023)), 50, 70) --t.year
    disp.puttext(common.utf8ToGb2312(string.format("%02d月%02d日",01,23 )), 50, 110)--t.month,t.day
    disp.setfontheight(22)
    disp.puttext(common.utf8ToGb2312(string.format("信号:%02d/31", 30 )), 50, 160) -- net.getRssi()
    
    disp.globalUpdate(1)
    disp.show()
    disp.sleep()
    axp173.setOutputEnable(axp173.OUTPUT_CHANNEL.OP_LDO4, false)
    global_variable.page_id = "MainMenu"
end

function main_menu_keyMapping(id, islong)
    if id == 1 then
        if islong == true then
            if menu_page - 1 > 0 then
                menu_page = menu_page - 1
                show_menu()
            end
        else
            if menu_page == 1 then calendar.ShowCalendar() end
        end
    end
    if id == 2 then 
        weather.refresh()
    end
    if id == 3 then
        if menu_page == 1 then
            musicplayer.ReadFileTable()
            musicplayer.showFileTable()
        end
    end
    if id == 4 then
        if islong == true then
            if menu_page + 1 <= 2 then
                menu_page = menu_page + 1
                show_menu()
            end
        else
            if menu_page == 1 then
                ebook.ReadFileTable()
                ebook.showFileTable()
            end
        end
    end
end

sys.taskInit(function()
    -- LED初始化
    Light.init()
    Light.show(50, 50, 50)
    -- 挂载 SD 卡
    io.mount(io.SDCARD)
    -- 初始化 axp173 芯片
    axp173.init()
    -- 设置电压
    axp173.setOutputVoltage(axp173.OUTPUT_CHANNEL.OP_DCDC1, 3400)
    -- 立即同步一次，之后每隔1小时自动同步一次：
    ntp.timeSync(1)

    

    show_menu()


    -- axp173.setOutputEnable(axp173.OUTPUT_CHANNEL.OP_LDO4, true)
    -- disp.int()
    -- disp.WeatherglobalUpdate(0,"/lua/w.bin")

    -- disp.clear()
    -- -- disp.drawrect(0, 0, 30, 60, 0x00)
    -- disp.globalUpdate(1)

    -- disp.show()
    -- disp.sleep()
    -- axp173.setOutputEnable(axp173.OUTPUT_CHANNEL.OP_LDO4, false)

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
    -- -- disp.BINglobalUpdate(0,"/lua/1111.bin")
    -- -- disp.BINglobalUpdate(1,"/lua/2222.bin")
    -- disp.show()
    -- disp.sleep()
    -- axp173.setOutputEnable(axp173.OUTPUT_CHANNEL.OP_LDO4, false)

    while true do
        -- m = WS2812.SendOneFrame(10,"123456781234567812345678")
        -- print(m)
        -- mmmm(1)
        log.info("OK")
        sys.wait(1000)

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
        -- 播放sd卡根目录下的pwron.mp3
        -- audio.play(1,"TTS","小奇开发芯片测试",audiocore.VOL1,function() sys.publish("AUDIO_PLAY_END") end)
        -- sys.waitUntil("AUDIO_PLAY_END") 
        -- print("testI2c.init1",type())
    end

end)

sys.init(0, 0)
sys.run()
