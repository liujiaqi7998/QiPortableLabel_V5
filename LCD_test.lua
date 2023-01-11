require 'sys'

-- LCD初始化用数组
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

--[[
函数名：int
功能  ：初始化LCD参数
参数  ：无
返回值：无
]]
disp.int = function()
    log.debug("e-Paper init")
    disp.init(para) -- 初始化LCD参数
    disp.clear() -- 清除缓存
end

--[[
函数名：globalUpdate
功能  ：系统缓存区图片上传到屏幕缓存区
参数  ：1,红色缓存区；0,黑色缓存区
返回值：无
]]
disp.globalUpdate = function()
    log.debug("e-Paper globalUpdate")
    local pic = disp.getframe()
    local txt = ""
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
                txt = txt ..string.char(out)
            end
        end
    end
    io.writeFile("/test.bin", txt)
    log.debug("文件大小", io.fileSize("/test.bin"))
end