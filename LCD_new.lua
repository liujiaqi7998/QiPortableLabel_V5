--- 模块功能：E2417JS0D1驱动芯片墨水屏命令配置
-- @author 666Qi
-- @module ui.mipi_ink_E2417JS0D1
-- @url https://www.pervasivedisplays.com/product/4-2-e-ink-display-spectra-r2-0/
-- @license MIT
-- @copyright 666Qi
-- @release 2022.12.22
--
require 'sys'
require "pins"
require 'Light'

-- VLCD电压域配置
pmd.ldoset(15, pmd.LDO_VLCD)

-- 引脚初始化
local GpioResetFnc = pins.setup(pio.P0_11, 0) -- Reset引脚初始化
local GpioBusyFnc = pins.setup(pio.P0_4, 0) -- Busy引脚初始化

-- LCD初始化用数组
local para = {
    width = 400, -- 分辨率宽      度，400像素；用户根据屏的参数自行修改
    height = 300, -- 分辨率高度，300像素；用户根据屏的参数自行修改
    bpp = 1, -- 位深度，1表示单色。单色屏就设置为1，不可修改
    bus = disp.BUS_SPI4LINE, -- lcd位标准SPI接口，不可修改
    xoffset = 0, -- X轴偏移
    yoffset = 0, -- Y轴偏移
    freq = 110000, -- 9000000 9M spi时钟频率，支持110K到13M（即110000到13000000）之间的整数（包含110000和13000000）
    hwfillcolor = 0xff, -- 填充色，白色
    pinrst = pio.P0_6, -- reset，复位引脚
    pinrs = pio.P0_1, -- DC，命令/数据选择引脚
    initcmd = {0x00}, --初始化命令
    sleepcmd = {0x00}, --休眠命令
    wakecmd = {0x00} --唤醒命令

}

--[[
函数名：ReadBusy
功能  ：屏幕忙等待
参数  ：无
返回值：无
]]
disp.ReadBusy = function()
    log.debug("e-Paper busy")
    while (GpioBusyFnc() == 0) do
        sys.wait(100) -- DelayMs 100 
    end
    log.debug("e-Paper busy release")
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
函数名：int
功能  ：初始化LCD参数
参数  ：无
返回值：无
]]
disp.int = function()
    Light.show(0,0,255)
    sys.wait(10)
    log.debug("e-Paper init")
    disp.init(para) -- 初始化LCD参数
    disp.clear() -- 清除缓存
    GpioResetFnc(1) -- 拉高复位引脚
    disp.Reset() -- 复位
    disp.write(0xe5); -- CMD:temperature 输入温度
    disp.write(0x00030019); -- DATA:25 C
    disp.write(0xe0); -- CMD:temperature 激活温度
    disp.write(0x00030002); -- DATA:0x02 激活温度
    disp.write(0x00); -- CMD:Panel Setting (PSR)  面板设置
    disp.write(0x0003000F); -- DATA: 4.2"
    disp.write(0x00030089); -- DATA: 4.2"
end

--[[
函数名：globalUpdate
功能  ：系统缓存区图片上传到屏幕缓存区
参数  ：1,红色缓存区；0,黑色缓存区
返回值：无
]]
disp.globalUpdate = function(color)
    log.debug("e-Paper globalUpdate")
    if color == 1 then
        -- 切换红色缓存区
        disp.write(0x00020013)
    else
        -- 切换黑色缓存区
        disp.write(0x00020010)
    end
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
                if color == 1 then
                    -- 切换红色缓存区
                    out = 255 - out
                end
                disp.write(0x00030000 + out)
            end
        end
    end
end

--[[
函数名：show
功能  ：控制屏幕刷新成缓存区内容
参数  ：无
返回值：无
]]
disp.show = function()
    log.debug("e-Paper show")
    disp.write(0x00020004) -- CMD:DC-DC power-on command
    disp.ReadBusy();
    disp.write(0x00020012) -- CMD:DISPLAY_REFRESH
    disp.ReadBusy();
end

--[[
函数名：sleep
功能  ：屏幕休眠控制
参数  ：无
返回值：无
]]
disp.sleep = function()
    log.debug("e-Paper sleep")
    -- 休眠流程
    disp.write(0x02); -- POWER_OFF
    disp.ReadBusy();
    GpioResetFnc(0) -- 拉低复位引脚
    GpioBusyFnc(0) -- 拉低忙引脚

    -- 关闭LED
    Light.close()
    Light.close()
    sys.wait(10)
end

--[[
函数名：BINglobalUpdate
功能  ：显示储存器中的BIN图片文件
参数  ：无
返回值：无
]]
disp.BINglobalUpdate = function(color, uri)
    log.debug("e-Paper globalUpdate by .bin")
    if io.exists(uri) == false then
        log.info("file not exists", uri)
        uri = "/lua/pic_bin/file_bad_img.bin"
    end
    if color == 1 then
        -- 切换红色缓存区
        disp.write(0x00020013)
    else
        -- 切换黑色缓存区
        disp.write(0x00020010)
    end
    local fileIn = io.open(uri, "rb")
    local content = fileIn:read("*all")
    local length = fileIn:seek("end")
    fileIn:close()
    for i = 1, length do
        local out = tonumber(string.byte(content, i, i))
        if color == 0 then
            -- 切换黑色缓存区
            out = 255 - out
        end
        disp.write(0x00030000 + out)
    end
end

--[[
函数名：WeatherglobalUpdate
功能  ：显示天气文件
参数  ：无
返回值：无
]]
-- disp.WeatherglobalUpdate = function(color, Weather)
--     log.debug("e-Paper globalUpdate by Weather")
--     -- if io.exists(uri) == false then
--     --     log.info("file not exists", uri)
--     --     uri = "/lua/pic_bin/file_bad_img.bin"
--     -- end
--     -- if color == 1 then
--     --     -- 切换红色缓存区
--     --     disp.write(0x00020013)
--     -- else
--     --     -- 切换黑色缓存区
--     --     disp.write(0x00020010)
--     -- end
--     -- local fileIn = io.open(uri, "rb")
--     -- local content = fileIn:read("*all")
--     -- local length = fileIn:seek("end")
--     -- fileIn:close()

--     if #Weather < 5000 then
--         log.error("e-Paper WeatherglobalUpdate length small")
--         return
--     end

--     for j = 1, 2500 do
--         if color == 0 then
--             -- 切换黑色缓存区
--             disp.write(0x000300ff)
--         else
--             disp.write(0x00030000)
--         end
--     end

--     local kk = 1
--     for i = 1, 200 do
--         for j = 1, 13 do
--             if color == 0 then
--                 -- 切换黑色缓存区
--                 disp.write(0x000300ff)
--             else
--                 disp.write(0x00030000)
--             end
--         end

--         for j = 1, 25 do
--             local out = tonumber(string.byte(Weather, kk, kk))
--             -- return ((num & 0x01) << 7) | ((num & 0x02) << 5) | ((num & 0x04) << 3) | ((num & 0x08) << 1) |
--             --    ((num & 0x10) >> 1) | ((num & 0x20) >> 3) | ((num & 0x40) >> 5) | ((num & 0x80) >> 7);
--             out = bit.bor(bit.lshift(bit.band(out, 0x01), 7),
--                           bit.lshift(bit.band(out, 0x02), 5),
--                           bit.lshift(bit.band(out, 0x04), 3),
--                           bit.lshift(bit.band(out, 0x08), 1),
--                           bit.rshift(bit.band(out, 0x10), 1),
--                           bit.rshift(bit.band(out, 0x20), 3),
--                           bit.rshift(bit.band(out, 0x40), 5),
--                           bit.rshift(bit.band(out, 0x80), 7))
--             if color == 0 then
--                 -- 切换黑色缓存区
--                 out = 255 - out
--             end
--             disp.write(0x00030000 + out)
--             kk = kk + 1

--         end

--         for j = 1, 12 do
--             if color == 0 then
--                 -- 切换黑色缓存区
--                 disp.write(0x000300ff)
--             else
--                 disp.write(0x00030000)
--             end
--         end
--     end

--     for j = 1, 2500 do
--         if color == 0 then
--             -- 切换黑色缓存区
--             disp.write(0x000300ff)
--         else
--             disp.write(0x00030000)
--         end
--     end

-- end

--[[
函数名：WeatherglobalUpdate
功能  ：显示天气文件
参数  ：无
返回值：无
]]
disp.WeatherglobalUpdate = function(color, uri)
    log.debug("e-Paper globalUpdate by .bin")
    if io.exists(uri) == false then
        log.info("file not exists", uri)
        uri = "/lua/file_bad_img.bin"
    end
    if color == 1 then
        -- 切换红色缓存区
        disp.write(0x00020013)
    else
        -- 切换黑色缓存区
        disp.write(0x00020010)
    end
    local fileIn = io.open(uri, "rb")
    local content = fileIn:read("*all")
    local length = fileIn:seek("end")
    fileIn:close()

    if length < 5000 then
        log.error("e-Paper WeatherglobalUpdate length small")
        return
    end

    for j = 1, 2500 do
        if color == 0 then
            -- 切换黑色缓存区
            disp.write(0x000300ff)
        else
            disp.write(0x00030000)
        end
    end

    local kk = 1
    for i = 1, 200 do
        for j = 1, 13 do
            if color == 0 then
                -- 切换黑色缓存区
                disp.write(0x000300ff)
            else
                disp.write(0x00030000)
            end
        end

        for j = 1, 25 do
            local out = tonumber(string.byte(content, kk, kk))
            -- return ((num & 0x01) << 7) | ((num & 0x02) << 5) | ((num & 0x04) << 3) | ((num & 0x08) << 1) |
            --    ((num & 0x10) >> 1) | ((num & 0x20) >> 3) | ((num & 0x40) >> 5) | ((num & 0x80) >> 7);
            out = bit.bor(bit.lshift(bit.band(out, 0x01), 7),
                          bit.lshift(bit.band(out, 0x02), 5),
                          bit.lshift(bit.band(out, 0x04), 3),
                          bit.lshift(bit.band(out, 0x08), 1),
                          bit.rshift(bit.band(out, 0x10), 1),
                          bit.rshift(bit.band(out, 0x20), 3),
                          bit.rshift(bit.band(out, 0x40), 5),
                          bit.rshift(bit.band(out, 0x80), 7))
            if color == 0 then
                -- 切换黑色缓存区
                out = 255 - out
            end
            disp.write(0x00030000 + out)
            kk = kk + 1

        end

        for j = 1, 12 do
            if color == 0 then
                -- 切换黑色缓存区
                disp.write(0x000300ff)
            else
                disp.write(0x00030000)
            end
        end
    end

    for j = 1, 2500 do
        if color == 0 then
            -- 切换黑色缓存区
            disp.write(0x000300ff)
        else
            disp.write(0x00030000)
        end
    end

end

--[[
    disp.int()

    disp.clear()
    disp.drawrect(0, 0, 30, 60, 0x00)
    disp.globalUpdate(0)

    disp.clear()
    disp.drawrect(30, 30, 30, 60, 0x00)
    disp.globalUpdate(1)
    
    disp.show()
    disp.sleep()
]]
