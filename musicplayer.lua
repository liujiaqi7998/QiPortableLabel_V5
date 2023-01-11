module(..., package.seeall)

page = 0
music_table = {}

-- 扫描音乐目录里面的所有歌曲，保存在列表，进入该模式后进行一次扫描即可
function ReadFileTable()
    page_id = nil
    if io.opendir("/sdcard0/music") then
        local m = 1
        while true do
            local fType, fName, fSize = io.readdir()
            if fType == 32 then
                log.debug("sd card file", fName, fSize)
                music_table[m] = fName
            elseif fType == nil then
                break
            end
            m = m + 1
        end
        io.closedir("/sdcard0/music")
    end
end

function showFileTable()
    page_id = nil
    axp173.setOutputEnable(axp173.OUTPUT_CHANNEL.OP_LDO4, true)
    disp.int()
    ----------------------------
    disp.clear()
    disp.setcolor(0X00)
    disp.setfontheight(30)
    disp.puttext(common.utf8ToGb2312("播放SD卡音乐"), 10, 0)
    -- 遍历读取sd目录

    for i = 1, 4 do
        local name = music_table[page * 4 + i]

        if name == nil then
            break
        else
            log.info("music", name)
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
    page_id = "MusicFileTable"
end

function menu_keyMapping(id, islong)
    if id == 1 then
        if islong == true then
            if page - 1 > 1 then
                page = page - 1
                showFileTable()
            else
                -- 返回上一级菜单
            end
        else

        end
    end
    if id == 2 then
        -- body
    end
    if id == 3 then
        -- body
    end
    if id == 4 then
        if islong == true then
            if page + 1 < (#music_table / 4) then
                page = page + 1
                showFileTable()
            end
        else

        end
    end
end

function player_keyMapping(id, islong)
    local voice_level = audio.getVolume()
    if id == 1 then
        audio.stop(function(result)
            sys.publish("AUDIO_PLAY_END result:" .. result)
        end)
    end
    if id == 2 then
        if voice_level < 7 then
            voice_level =  voice_level + 1 
            audio.setVolume(voice_level)
        end
    end
    if id == 3 then
        if voice_level > 0 then
            voice_level =  voice_level - 1 
            audio.setVolume(voice_level)
        end
    end
    if id == 4 then end
end

function music_play(id)
    page_id = nil

    local music_name = music_table[page * 4 + id]

    audio.play(0, "FILE", "/sdcard0/music" .. music_name, audiocore.VOL3,
               function(result)
        sys.publish("AUDIO_PLAY_END result:" .. result)
    end, nil, nil)

    axp173.setOutputEnable(axp173.OUTPUT_CHANNEL.OP_LDO4, true)
    disp.int()
    ----------------------------
    disp.clear()
    disp.setcolor(0X00)
    disp.setfontheight(30)
    disp.puttext(common.utf8ToGb2312(music_name), 100, 100)
    disp.puttext(common.utf8ToGb2312("按键:1停止,2音量加,3音量减"), 0,
                 150)
    disp.globalUpdate(0)
    -----------------------------
    disp.clear()
    disp.setcolor(0X00)
    disp.setfontheight(30)
    disp.puttext(common.utf8ToGb2312("正在播放音乐"), 100, 50)
    disp.globalUpdate(1)
    disp.show()
    -----------------------------
    disp.sleep()
    axp173.setOutputEnable(axp173.OUTPUT_CHANNEL.OP_LDO4, false)
    
    page_id = "MusicPlayer"
end
