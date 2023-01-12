module(..., package.seeall)
require 'global_variable'
require 'audio'

local page = 0
local music_table = {}
local now_music_name = ""

-- 扫描音乐目录里面的所有歌曲，保存在列表，进入该模式后进行一次扫描即可
function ReadFileTable()
    global_variable.page_id = ""
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
    global_variable.page_id = ""
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
    global_variable.page_id = "MusicFileTable"
end

function menu_keyMapping(id, islong)
    if id == 1 then
        if islong == true then
            if page - 1 > 0 then
                page = page - 1
                showFileTable()
            else
                -- 返回上一级菜单
            end
        else
            music_play(1)
        end
    end
    if id == 2 then music_play(2) end
    if id == 3 then music_play(3) end
    if id == 4 then
        if islong == true then
            if page + 1 < (#music_table / 4) then
                page = page + 1
                showFileTable()
            end
        else
            music_play(4)
        end
    end
end

function player_keyMapping(id, islong)
    local voice_level = audio.getVolume()
    if id == 1 then
        audio.stop(function(result)
            sys.publish("AUDIO_PLAY_END result:" .. result)
        end)
        if islong == true then
            -- 返回上一级菜单
            now_music_name = ""
            showFileTable()
        end
    end
    if id == 2 then
        if voice_level < 7 then
            voice_level = voice_level + 1
            audio.setVolume(voice_level)
            log.debug("音量增加",voice_level)
        end
    end
    if id == 3 then
        if voice_level > 0 then
            voice_level = voice_level - 1
            audio.setVolume(voice_level)
            log.debug("音量减小",voice_level)
        end
    end
    if id == 4 then
        
        if now_music_name == "" then
            log.error("播放错误","没有要播放的now_music_name")
            return
        end
        audio.stop(function(result)
            sys.publish("AUDIO_PLAY_END result:" .. result)
        end)
        audio.play(0, "FILE", "/sdcard0/music/" .. now_music_name, voice_level,
                   function(result)
            sys.publish("AUDIO_PLAY_END result:" .. result)
        end, nil, nil)
    end
end

function music_play(id)
    global_variable.page_id = ""
    
    local music_name = music_table[page * 4 + id]
    now_music_name = music_name
    audio.play(0, "FILE", "/sdcard0/music/" .. music_name, audio.getVolume(),
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
    disp.puttext(common.utf8ToGb2312(
                     "按键:1停止,2音量加\n3音量减,4重新播放,长按1退出"),
                 0, 180)
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

    global_variable.page_id = "MusicPlayer"
end
