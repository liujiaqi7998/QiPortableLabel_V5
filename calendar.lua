module(..., package.seeall)
require 'global_variable'

local page = 1

function calendar_keyMapping(id, islong)
    if id == 1 then
        -- 上级菜单
        show_menu()
    end
    if id == 3 then if page - 1 >= 1 then page = page - 1 ShowCalendar() end  end
    if id == 4 then if page + 1 <= 12 then page = page + 1 ShowCalendar()end end
end

function ShowCalendar()

    global_variable.page_id = ""

    axp173.setOutputEnable(axp173.OUTPUT_CHANNEL.OP_LDO4, true)
    disp.int()
    ----------------------------
    disp.BINglobalUpdate(0, "/sdcard0/calendar/" .. page .. ".bin")
    -----------------------------
    disp.clear()
    disp.globalUpdate(1)
    disp.show()
    -----------------------------
    disp.sleep()
    axp173.setOutputEnable(axp173.OUTPUT_CHANNEL.OP_LDO4, false)

    global_variable.page_id = "ShowCalendar"
end
