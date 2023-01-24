module(..., package.seeall)
require 'http'
require 'global_variable'

-- 地区id，请前往https://api.luatos.org/luatos-calendar/v1/check-city/ 查询自己所在位置的id
local location = "101020100"
-- 天气接口信息，需要自己申请，具体参数请参考https://api.luatos.org/ 页面上的描述
local appid, appsecret = "27548549", "3wdKWuRZ"

local back_body = ""
local function cbFnc(result, prompt, head, body)
    log.info("testHttp.cbFnc", "bodyLen=" .. body:len())
    if result == 200 then
        back_body = body
    else
        back_body = ""
    end
    sys.publish("http_finish")
end

local function requestHttp()
    local url = "http://apicn.luatos.org:23328/luatos-calendar/v1"
    local body = "mac=111&battery=10&location=" .. location .. "&appid=" ..
                     appid .. "&appsecret=" .. appsecret
    http.request("GET", url, nil, nil, body, nil, cbFnc)
    sys.waitUntil("http_finish")
    return back_body
end

function refresh()
    global_variable.page_id = ""
    Light.show(0, 250, 250)

    log.info("refresh", "start!")
    local data
    for i = 1, 5 do -- 重试最多五次
        collectgarbage("collect")
        data = requestHttp()
        collectgarbage("collect")
        if #data > 100 then break end
        log.info("load fail", "retry!")
    end
    if #data < 100 then
        axp173.setOutputEnable(axp173.OUTPUT_CHANNEL.OP_LDO4, true)
        disp.int()
        disp.clear()
        disp.setcolor(0X00)
        disp.setfontheight(30)
        disp.puttext(common.utf8ToGb2312("天气数据错误"), 123, 150)
        disp.globalUpdate(0)
        disp.clear()
        disp.globalUpdate(1)
        disp.show()
        disp.sleep()
        axp173.setOutputEnable(axp173.OUTPUT_CHANNEL.OP_LDO4, false)
        global_variable.page_id = "Weather"
        return
    end
    collectgarbage("collect")

    axp173.setOutputEnable(axp173.OUTPUT_CHANNEL.OP_LDO4, true)
    disp.int()
    disp.WeatherglobalUpdate(0, data)
    disp.clear()
    disp.globalUpdate(1)
    disp.show()
    disp.sleep()
    axp173.setOutputEnable(axp173.OUTPUT_CHANNEL.OP_LDO4, false)

    log.info("refresh", "done")
    global_variable.page_id = "Weather"
end
