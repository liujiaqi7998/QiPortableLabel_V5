--- 模块功能：E2417JS0D1驱动芯片墨水屏命令配置
-- @author 666Qi
-- @module ui.mipi_ink_E2417JS0D1
-- @url https://www.pervasivedisplays.com/product/4-2-e-ink-display-spectra-r2-0/
-- @license MIT
-- @copyright openLuat
-- @release 2022.12.22
--
-- VLCD电压域配置
require 'sys'
require "pins"

local para = {
    width = 400, -- 分辨率宽      度，400像素；用户根据屏的参数自行修改
    height = 300, -- 分辨率高度，300像素；用户根据屏的参数自行修改
    bpp = 1, -- 位深度，1表示单色。单色屏就设置为1，不可修改
    xoffset = 0, -- X轴偏移
    yoffset = 0, -- Y轴偏移
    freq = 110000, -- 9000000 9M spi时钟频率，支持110K到13M（即110000到13000000）之间的整数（包含110000和13000000）
    hwfillcolor = 0xff, -- 填充色，白色
    pinrst = pio.P0_6, -- reset，复位引脚
    pinrs = pio.P0_1, -- DC，命令/数据选择引脚
    initcmd = {}
}

pmd.ldoset(15, pmd.LDO_VLCD)
local GpioResetFnc = pins.setup(pio.P0_11, 0) -- Reset引脚初始化
local GpioBusyFnc = pins.setup(pio.P0_4, 0) -- Busy引脚初始化

-- 调试使用函数
-- local GpioResetFnc = function(var)
-- end
-- local GpioBusyFnc = function(var)
-- end

--[[
函数名：init
功能  ：初始化LCD参数
参数  ：无
返回值：无
]]
local function init()
    log.debug("e-Paper init")
    disp.init(para)
    disp.clear()
end
--[[
函数名：Reset
功能  ：屏幕电源复位
参数  ：无
返回值：无
]]
disp.Reset = function()
    log.debug("e-Paper Reset")
    GpioResetFnc(1)
    disp.write(0x00010005) -- DelayMs 5 
    GpioResetFnc(0)
    disp.write(0x00010010) -- DelayMs 10 
    GpioResetFnc(1)
    disp.write(0x00010005) -- DelayMs 5 
end
--[[
函数名：ReadBusy
功能  ：屏幕忙等待
参数  ：无
返回值：无
]]
disp.ReadBusy = function()
    log.debug("e-Paper busy")
    while (GpioBusyFnc() == 0) do
        sys.wait(50) -- DelayMs 50 
    end
    log.debug("e-Paper busy release")
end
--[[
函数名：sleep
功能  ：屏幕休眠控制
参数  ：0休眠，1唤醒
返回值：无
]]
disp.sleep = function(enable)
    if enable == 0 then
        log.debug("e-Paper sleep")
        -- 休眠流程
        disp.write(0x02); -- POWER_OFF
        disp.ReadBusy();
        disp.write(0x07); -- DEEP_SLEEP
        disp.write(0x000300A5);
        --go_sleep()
    elseif enable == 1 then
        log.debug("e-Paper Global mode")
        -- 激活:普通更新
        disp.Reset()
        disp.write(0xe5); -- CMD:temperature 输入温度
        disp.write(0x00030019); -- DATA:25 C
        disp.write(0xe0); -- CMD:temperature 激活温度
        disp.write(0x00030002); -- DATA:0x02 激活温度
        disp.ReadBusy();
        disp.write(0x00); -- CMD:Panel Setting (PSR)  面板设置
        disp.write(0x0003000F); -- DATA: 4.2"
        disp.write(0x00030089); -- DATA: 4.2"
    elseif enable == 2 then
        log.debug("e-Paper Fast mode")
        -- 激活:快速更新
        disp.Reset()
        disp.write(0xe5); -- CMD:temperature 输入温度
        disp.write(0x00030059); -- DATA:25 C + 0x40
        disp.write(0xe0); -- CMD:temperature 激活温度
        disp.write(0x00030002); -- DATA:0x02 激活温度
        disp.ReadBusy();
        disp.write(0x00); -- CMD:Panel Setting (PSR)  面板设置
        disp.write(0x0003001F); -- DATA: 0x0F | 0x10
        disp.write(0x0003008B); -- DATA: 0x89 | 0x02
        disp.ReadBusy();
        disp.write(0x50); -- CMD:Vcom and data interval Setting
        disp.write(0x00030007); -- DATA: 0x07
    end
end

-- 小奇显示函数
disp.qi_update = function()
	local pic = disp.getframe()
    for n = 0, 37 do
        for m = 0, 7 do
            for j = 1, 50 do
                local out = 0
                local row = (8 * j) - 7
                row = row + 400 * n
                local data = string.byte(pic:sub(row, row))
                out = (math.floor(data / 2 ^ m) % 2) * 128
                data = string.byte(pic:sub(row + 1, row + 1))
                out = out + (math.floor((data) / 2 ^ m) % 2) * 64
                data = string.byte(pic:sub(row + 2, row + 2))
                out = out + (math.floor((data) / 2 ^ m) % 2) * 32
                data = string.byte(pic:sub(row + 3, row + 3))
                out = out + (math.floor((data) / 2 ^ m) % 2) * 16
                data = string.byte(pic:sub(row + 4, row + 4))
                out = out + (math.floor((data) / 2 ^ m) % 2) * 8
                data = string.byte(pic:sub(row + 5, row + 5))
                out = out + (math.floor((data) / 2 ^ m) % 2) * 4
                data = string.byte(pic:sub(row + 6, row + 6))
                out = out + (math.floor((data) / 2 ^ m) % 2) * 2
                data = string.byte(pic:sub(row + 7, row + 7))
                out = out + (math.floor((data) / 2 ^ m) % 2)
                disp.write(0x00030000 + out)
            end
        end
    end
end

--[[
函数名：qi_update_full
功能  ：缓存区刷成指定颜色
参数  ：颜色
返回值：无
]]
disp.qi_cho_color = function(num)
    if num == 1 then
        -- 切换红色缓存区
        disp.write(0x00020013)
    else
        -- 切换黑色缓存区
        disp.write(0x00020010)
    end
end

--[[
函数名：qi_update_full
功能  ：缓存区刷成指定颜色
参数  ：颜色
返回值：无
]]
disp.qi_update_full = function(num)
    num = num + 0x00030000
    for i = 1, 15000 do -- 发数据
		disp.write(num)
	end
end

--[[
函数名：show
功能  ：控制屏幕刷新成缓存区内容
参数  ：无
返回值：无
]]
disp.show = function()
    disp.write(0x00010002) -- DelayMs 2 
    disp.write(0x00020004) -- CMD:DISPLAY_REFRESH
    disp.ReadBusy();
    disp.write(0x00020012) -- CMD:DISPLAY_REFRESH
    disp.write(0x00010100) -- DelayMs 100 
    disp.ReadBusy();
end

init()

--[[
    disp.sleep(1)

    disp.clear()
    disp.drawrect(0, 0, 30, 60, 0x00)
    disp.qi_update(0)

    disp.clear()
    disp.drawrect(30, 30, 30, 60, 0x00)
    disp.qi_update(1)
    
    disp.show()
    disp.sleep(0)
]]
