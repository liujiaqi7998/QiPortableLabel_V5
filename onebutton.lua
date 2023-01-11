require 'global_variable'
require 'pins'
require 'sys'

button1 = 0
button2 = 0
button3 = 0
button4 = 0

local getGpio5Fnc = pins.setup(pio.P0_5, 1, pio.PULLUP)
local getGpio17Fnc = pins.setup(pio.P0_17, 1, pio.PULLUP)
local getGpio16Fnc = pins.setup(pio.P0_16, 1, pio.PULLUP)
local getGpio9Fnc = pins.setup(pio.P0_9, 1, pio.PULLUP)

sys.timerLoopStart(function()
    if getGpio5Fnc() == 0 then
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
    if getGpio9Fnc() == 0 then
        button4 = button4 + 1
        return
    end

    if button1 > 15 then
        log.debug("按钮长按",1)
        reset_button()
        return
    end
    if button2 > 15 then
        log.debug("按钮长按",1)
        reset_button()
        return
    end
    if button3 > 15 then
        log.debug("按钮长按",1)
        reset_button()
        return
    end
    if button4 > 15 then
        log.debug("按钮长按",1)
        reset_button()
        return
    end

    if button1 > 3 then
        log.debug("按钮短按",1)
        reset_button()
        return
    end
    if button2 > 3 then
        log.debug("按钮短按",2)
        reset_button()
        return
    end
    if button3 > 3 then
        log.debug("按钮短按",3)
        reset_button()
        return
    end
    if button4 > 3 then
        log.debug("按钮短按",4)
        reset_button()
        return
    end
end, 100)

function reset_button()
    button1 = 0
    button2 = 0
    button3 = 0
    button4 = 0
end

function button_callback()
    
end