module(..., package.seeall)
require 'global_variable'

local page = 0
local book_table = {}
local now_book_id = 1
local now_book_name = ""
local book_page = 0 -- 当前电子书页码
-- 扫描电子书目录里面的所有书，保存在列表，进入该模式后进行一次扫描即可
function ReadFileTable()
    global_variable.page_id = ""
    if io.opendir("/sdcard0/book") then
        local m = 1
        while true do
            local fType, fName, fSize = io.readdir()
            if fType == 32 then
                log.debug("sd card file", fName, fSize)
                book_table[m] = fName
            elseif fType == nil then
                break
            end
            m = m + 1
        end
        io.closedir("/sdcard0/book")
    end
end

function showFileTable()
    global_variable.page_id = ""
    axp173.setOutputEnable(axp173.OUTPUT_CHANNEL.OP_LDO4, true)
    disp.int()
    ----------------------------
    disp.clear()
    disp.setcolor(0X00)
    disp.setfontheight(30)
    disp.puttext(common.utf8ToGb2312("电子书列表"), 10, 0)
    -- 遍历读取sd目录

    for i = 1, 4 do
        local name = book_table[page * 4 + i]

        if name == nil then
            break
        else
            log.info("book", name)
            disp.puttext(common.utf8ToGb2312(i .. "." .. name), 10, i * 40)
        end
    end

    disp.puttext(common.utf8ToGb2312("第" .. (page + 1) ..
                                         "页，长按4下一页，1上一页"),
                 0, 260)
    disp.globalUpdate(0)
    -----------------------------
    disp.clear()
    disp.globalUpdate(1)
    disp.show()
    -----------------------------
    disp.sleep()
    axp173.setOutputEnable(axp173.OUTPUT_CHANNEL.OP_LDO4, false)
    global_variable.page_id = "BookFileTable"
end

function menu_keyMapping(id, islong)
    if id == 1 then
        if islong == true then
            if page - 1 > 0 then
                page = page - 1
                showFileTable()
            else
                -- 返回上一级菜单
                show_menu()
            end
        else
            now_book_id = 1
            ReadBook()
        end
    end
    if id == 2 then
        now_book_id = 2
        ReadBook()
    end
    if id == 3 then
        now_book_id = 2
        ReadBook()
    end
    if id == 4 then
        if islong == true then
            if page + 1 < (#book_table / 4) then
                page = page + 1
                showFileTable()
            end
        else
            now_book_id = 4
            ReadBook()
        end
    end
end

function reader_keyMapping(id, islong)
    local book_size = io.fileSize("/sdcard0/book/" .. now_book_name)
    if id == 1 then
        if islong == true then
            -- 返回上一级菜单
            now_book_name = ""
            book_page = 0
            showFileTable()
        else
            if (book_page - 1)* 170 >= 0 then
                book_page = book_page + 1
                ReadBook()
            end
        end
    end
    if id == 2 then
        if (book_page + 1)* 170 <= book_size then
            book_page = book_page + 1
            ReadBook()
        end
    end
    if id == 3 then
        if (book_page - 10)* 170 >= 0 then
            book_page = book_page + 1
            ReadBook()
        end
    end
    if id == 4 then
        if (book_page + 10)* 170 <= book_size then
            book_page = book_page + 10
            ReadBook()
        end
    end
end

function ReadBook()
    global_variable.page_id = ""
    now_book_name = book_table[page * 4 + now_book_id]
    local fileStr = io.readStream("/sdcard0/book/" .. now_book_name,
                                  book_page * 170 , 170)

    axp173.setOutputEnable(axp173.OUTPUT_CHANNEL.OP_LDO4, true)
    disp.int()
    ----------------------------
    disp.clear()
    disp.setcolor(0X00)
    disp.setfontheight(25)
    -- 可以显示170个字符
    disp.puttext(fileStr, 0, 12)

    disp.globalUpdate(0)
    -----------------------------
    disp.clear()
    disp.globalUpdate(1)
    disp.show()
    -----------------------------
    disp.sleep()
    axp173.setOutputEnable(axp173.OUTPUT_CHANNEL.OP_LDO4, false)

    global_variable.page_id = "ReadBook"
end
