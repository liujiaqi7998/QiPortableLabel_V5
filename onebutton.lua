require 'global_variable'
require 'pins'
require 'sys'
require 'musicplayer'
require 'ebook'
require 'calendar'

local button1 = 0
local button2 = 0
local button3 = 0
local button4 = 0
local short_times = 2
local long_times = 8
local getGpio5Fnc = pins.setup(pio.P0_5, 1, pio.PULLUP)
local getGpio17Fnc = pins.setup(pio.P0_18, 1, pio.PULLUP) 
local getGpio16Fnc = pins.setup(pio.P0_17, 1, pio.PULLUP)
local getGpio9Fnc = pins.setup(pio.P0_9, 1, pio.PULLUP)

sys.timerLoopStart(function()
    if getGpio9Fnc() == 0 then
        button1 = button1 + 1
        return
    end
    if getGpio17Fnc() == 0 then
        button2 = button2 + 1
        return
    end
    if getGpio16Fnc() == 0 then
        button3 = button3 + 1
        return
    end
    if getGpio5Fnc() == 0 then
        button4 = button4 + 1
        return
    end

    if button1 > long_times then
        reset_button()
        button_callback(1, true)
        return
    end
    if button2 > long_times then
        reset_button()
        button_callback(2, true)
        return
    end
    if button3 > long_times then
        reset_button()
        button_callback(3, true)
        return
    end
    if button4 > long_times then
        reset_button()
        button_callback(4, true)
        return
    end

    if button1 > short_times then
        reset_button()
        button_callback(1, false)
        return
    end
    if button2 > short_times then
        reset_button()
        button_callback(2, false)
        return
    end
    if button3 > short_times then
        reset_button()
        button_callback(3, false)
        return
    end
    if button4 > short_times then
        reset_button()
        button_callback(4, false)
        return
    end
end, 50)

function reset_button()
    button1 = 0
    button2 = 0
    button3 = 0
    button4 = 0
end

function button_callback(id, islong)
    local l = "短按"
    if islong == true then l = "长按" end
    log.debug("按钮:" .. id, l, "当前page:" .. global_variable.page_id)

    sys.taskInit(function()
        if global_variable.page_id == "MusicPlayer" then
            musicplayer.player_keyMapping(id, islong)
            return
        end
        if global_variable.page_id == "MusicFileTable" then
            musicplayer.menu_keyMapping(id, islong)
            return
        end
        if global_variable.page_id == "BookFileTable" then
            ebook.menu_keyMapping(id, islong)
            return
        end
        if global_variable.page_id == "ReadBook" then
            ebook.reader_keyMapping(id, islong)
            return
        end
        if global_variable.page_id == "ShowCalendar" then
            calendar.calendar_keyMapping(id, islong)
            return
        end
        if global_variable.page_id == "MainMenu" then
            main_menu_keyMapping(id, islong)
            return
        end
        
    end)

end
