--- 模块功能：AXP173 电源芯片控制模块
-- @author 666Qi
-- @module power.PMU_AXP173
-- @url http://www.x-powers.com/index.php/Info/product_detail/article_id/27
-- @license MIT
-- @copyright 666Qi
-- @release 2023.01.08
--
module(..., package.seeall)

OUTPUT_CHANNEL = {
    OP_DCDC1 = 0,
    OP_LDO4 = 1,
    OP_LDO2 = 2,
    OP_LDO3 = 3,
    OP_DCDC2 = 4
}

ADC_CHANNEL = {
    ADC_TS = 0,
    ADC_APS_V = 1,
    ADC_VBUS_C = 2,
    ADC_VBUS_V = 3,
    ADC_ACIN_C = 4,
    ADC_ACIN_V = 5,
    ADC_BAT_C = 6,
    ADC_BAT_V = 7
};

CHARGE_CURRENT = {
    CHG_100mA = 0,
    CHG_190mA = 1,
    CHG_280mA = 2,
    CHG_360mA = 3,
    CHG_450mA = 4,
    CHG_550mA = 5,
    CHG_630mA = 6,
    CHG_700mA = 7,
    CHG_780mA = 8,
    CHG_880mA = 9,
    CHG_960mA = 10,
    CHG_1000mA = 11,
    CHG_1080mA = 12,
    CHG_1160mA = 13,
    CHG_1240mA = 14,
    CHG_1320mA = 15
};
COULOMETER_CTRL = {
    COULOMETER_RESET = 5,
    COULOMETER_PAUSE = 6,
    COULOMETER_ENABLE = 7
};
POWEROFF_TIME = {
    POWEROFF_4S = 0,
    POWEROFF_6S = 1,
    POWEROFF_8S = 2,
    POWEROFF_10S = 3
};
CHARGE_LED_FRE = {
    HIGH_RES = 0,
    CHARGE_LED_1HZ = 1,
    CHARGE_LED_4HZ = 2,
    LOW_LEVEL = 3
};

-- i2cid 1,2,3对应硬件的I2C1,I2C2,I2C3
-- 之前的i2cid为0不再使用
local i2cid = 2
local i2cslaveaddr = 0x34

function init()
    if i2c.setup(i2cid, i2c.SLOW, i2cslaveaddr) ~= i2c.SLOW then
        print("axp173 i2c init fail")
        return
    end
end

-- /* Private functions */
function _getMin(a, b)
    if a < b then
        return a
    else
        return b
    end
end

function _getMax(a, b)
    if a > b then
        return a
    else
        return b
    end
end

function _getMid(input, min, max) return _getMax(_getMin(input, max), min) end

--[[
@brief Set channels' output enable or disable
@param channel Output channel
@param state true:Enable, false:Disable
]]
function setOutputEnable(channel, state)
    local buff = string.byte(i2c.read(i2cid, 0x12, 1))
    if state == true then
        -- buff | (1U << channel)
        buff = bit.bor(buff, bit.lshift(1, channel))
    else
        -- buff & ~(1U << channel)
        buff = (bit.band(buff, bit.bnot(bit.lshift(1, channel))))
    end
    i2c.write(i2cid, 0x12, buff)
    print("Change Output Enable finish")
end

--[[
@brief Set channels' output voltage
@param channel Output channel
@param voltage DCDC1 & LDO4: 700~3500(mV), DCDC2: 700~2275(mV), LDO2 & LDO3: 1800~3300{mV}
]]
function setOutputVoltage(channel, voltage)
    if channel == OUTPUT_CHANNEL.OP_DCDC1 then
        -- voltage = (_getMid(voltage, 700, 3500) - 700) / 25;
        -- buff = _I2C_read8Bit(0x26);
        -- buff = (buff & 0B10000000) | (voltage & 0B01111111);
        -- _I2C_write1Byte(0x26, buff);
        voltage = math.floor((_getMid(voltage, 700, 3500) - 700) / 25)
        local buff = string.byte(i2c.read(i2cid, 0x26, 1))
        buff = bit.bor(bit.band(buff, 0x80), bit.band(voltage, 0x7F))
        i2c.write(i2cid, 0x26, buff)
    end
    if channel == OUTPUT_CHANNEL.OP_DCDC2 then
        -- voltage = (_getMid(voltage, 700, 2275) - 700) / 25;
        -- buff = _I2C_read8Bit(0x23);
        -- buff = (buff & 0B11000000) | (voltage & 0B00111111);
        -- _I2C_write1Byte(0x23, buff);
        voltage = math.floor((_getMid(voltage, 700, 2275) - 700) / 25)
        local buff = string.byte(i2c.read(i2cid, 0x23, 1))
        buff = bit.bor(bit.band(buff, 0xC0), bit.band(voltage, 0x3F))
        i2c.write(i2cid, 0x23, buff)
    end
    if channel == OUTPUT_CHANNEL.OP_LDO2 then
        -- voltage = (_getMid(voltage, 1800, 3300) - 1800) / 100;
        -- buff = _I2C_read8Bit(0x28);
        -- buff = (buff & 0B00001111) | (voltage << 4);
        -- _I2C_write1Byte(0x28, buff);
        voltage = math.floor((_getMid(voltage, 1800, 3300) - 1800) / 100)
        local buff = string.byte(i2c.read(i2cid, 0x28, 1))
        buff = bit.bor(bit.band(buff, 0x0f), bit.lshift(voltage, 4))
        i2c.write(i2cid, 0x28, buff)
    end
    if channel == OUTPUT_CHANNEL.OP_LDO3 then
        -- voltage = (_getMid(voltage, 1800, 3300) - 1800) / 100;
        -- buff = _I2C_read8Bit(0x28);
        -- buff = (buff & 0B11110000) | (voltage);
        -- _I2C_write1Byte(0x28, buff);
        voltage = math.floor((_getMid(voltage, 1800, 3300) - 1800) / 100)
        local buff = string.byte(i2c.read(i2cid, 0x28, 1))
        buff = bit.bor(bit.band(buff, 0xF0), voltage)
        i2c.write(i2cid, 0x28, buff)
    end
    if channel == OUTPUT_CHANNEL.OP_LDO4 then
        -- voltage = (_getMid(voltage, 700, 3500) - 700) / 25;
        -- buff = _I2C_read8Bit(0x27);
        -- buff = (buff & 0B10000000) | (voltage & 0B01111111);
        -- _I2C_write1Byte(0x27, buff);
        voltage = math.floor((_getMid(voltage, 700, 3500) - 700) / 25)
        local buff = string.byte(i2c.read(i2cid, 0x27, 1))
        buff = bit.bor(bit.band(buff, 0x80), bit.band(voltage, 0x7F))
        i2c.write(i2cid, 0x27, buff)
    end
    print("change Output Voltage finish")
end

function powerOFF()
    -- _I2C_write1Byte(0x32, (_I2C_read8Bit(0x32) | 0B10000000));
    local buff = string.byte(i2c.read(i2cid, 0x32, 1))
    buff = bit.bor(buff, 0x80)
    i2c.write(i2cid, 0x32, buff)
end

function setPowerOffTime(time)
    -- _I2C_write1Byte(0x36, ((_I2C_read8Bit(0x36) & 0B11111100) | time));
    local buff = string.byte(i2c.read(i2cid, 0x36, 1))
    buff = bit.bor(bit.band(buff, 0xFC), time)
    i2c.write(i2cid, 0x36, buff)
end

function isACINExist()
    -- return ( _I2C_read8Bit(0x00) & 0B10000000 ) ? true : false;
    local buff = string.byte(i2c.read(i2cid, 0x00, 1))
    if bit.band(buff, 0x80) == 1 then
        return true
    else
        return false
    end
end

function isACINAvl()
    -- return ( _I2C_read8Bit(0x00) & 0B01000000 ) ? true : false;
    local buff = string.byte(i2c.read(i2cid, 0x00, 1))
    if bit.band(buff, 0x40) == 1 then
        return true
    else
        return false
    end
end

function isVBUSExist()
    -- return ( _I2C_read8Bit(0x00) & 0B00100000 ) ? true : false;
    local buff = string.byte(i2c.read(i2cid, 0x00, 1))
    if bit.band(buff, 0x20) == 1 then
        return true
    else
        return false
    end
end

function isVBUSAvl()
    -- return ( _I2C_read8Bit(0x00) & 0B00010000 ) ? true : false;
    local buff = string.byte(i2c.read(i2cid, 0x00, 1))
    if bit.band(buff, 0x10) == 1 then
        return true
    else
        return false
    end
end

--[[
 * @brief Get bat current direction
 * 
 * @return true Bat charging
 * @return false Bat discharging
]]
function getBatCurrentDir()
    -- return ( _I2C_read8Bit(0x00) & 0B00000100 ) ? true : false;
    local buff = string.byte(i2c.read(i2cid, 0x00, 1))
    if bit.band(buff, 0x04) == 1 then
        return true
    else
        return false
    end
end

function isAXP173OverTemp()
    -- return ( _I2C_read8Bit(0x01) & 0B10000000 ) ? true : false;
    local buff = string.byte(i2c.read(i2cid, 0x01, 1))
    if bit.band(buff, 0x80) == 1 then
        return true
    else
        return false
    end
end

--[[
 * @brief Get bat charging state
 * 
 * @return true Charging
 * @return false Charge finished or not charging
]]
function isCharging()
    -- return ( _I2C_read8Bit(0x01) & 0B01000000 ) ? true : false;
    local buff = string.byte(i2c.read(i2cid, 0x01, 1))
    if bit.band(buff, 0x40) == 1 then
        return true
    else
        return false
    end
end

function isBatExist()
    -- return ( _I2C_read8Bit(0x01) & 0B00100000 ) ? true : false;
    local buff = string.byte(i2c.read(i2cid, 0x01, 1))
    if bit.band(buff, 0x20) == 1 then
        return true
    else
        return false
    end
end

function isChargeCsmaller()
    -- return ( _I2C_read8Bit(0x01) & 0B00000100 ) ? true : false;
    local buff = string.byte(i2c.read(i2cid, 0x01, 1))
    if bit.band(buff, 0x04) == 1 then
        return true
    else
        return false
    end
end

-- 下面是库仑计内容 --

function setCoulometer(option, state)
    local buff = string.byte(i2c.read(i2cid, 0xB8, 1))
    if state == true then
        -- buff | (1U << option)
        buff = bit.bor(buff, bit.lshift(1, option))
    else
        -- buff & ~(1U << option)
        buff = (bit.band(buff, bit.bnot(bit.lshift(1, option))))
    end
    i2c.write(i2cid, 0xB8, buff)
end

-- inline uint32_t AXP173::getCoulometerChargeData() {
--     return _I2C_read32Bit(0xB0);
-- }

-- inline uint32_t AXP173::getCoulometerDischargeData() {
--     return _I2C_read32Bit(0xB4);
-- }

-- float AXP173::getCoulometerData() {
--     uint32_t coin = getCoulometerChargeData();
--     uint32_t coout = getCoulometerDischargeData();
--     // data = 65536 * current_LSB * (coin - coout) / 3600 / ADC rate
--     return 65536 * 0.5 * (int32_t)(coin - coout) / 3600.0 / 25.0;
-- }