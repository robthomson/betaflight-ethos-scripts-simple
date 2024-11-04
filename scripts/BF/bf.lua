-- All BF globals should be stored in the bf table, to avoid conflict with globals from other scripts.
bf = {
    baseDir = "/scripts/BF/",
    runningInSimulator = system:getVersion().simulation,

    sportTelemetryPop = function()
        -- Pops a received SPORT packet from the queue. Please note that only packets using a data ID within 0x5000 to 0x50FF (frame ID == 0x10), as well as packets with a frame ID equal 0x32 (regardless of the data ID) will be passed to the Lua telemetry receive queue.
        local frame = bf.sensor:popFrame()
        if frame == nil then
            return nil, nil, nil, nil
        end
        -- physId = physical / remote sensor Id (aka sensorId)
        --   0x00 for FPORT, 0x1B for SmartPort
        -- primId = frame ID  (should be 0x32 for reply frames)
        -- appId = data Id
        return frame:physId(), frame:primId(), frame:appId(), frame:value()
    end,

    sportTelemetryPush = function(sensorId, frameId, dataId, value)
        -- OpenTX:
        -- When called without parameters, it will only return the status of the output buffer without sending anything.
        --   Equivalent in Ethos may be:   sensor:idle() ???
        -- @param sensorId  physical sensor ID
        -- @param frameId   frame ID
        -- @param dataId    data ID
        -- @param value     value
        -- @retval boolean  data queued in output buffer or not.
        -- @retval nil      incorrect telemetry protocol.  (added in 2.3.4)
        return bf.sensor:pushFrame({physId=sensorId, primId=frameId, appId=dataId, value=value})
    end,

    getRSSI = function()
        if bf.runningInSimulator then return 100 end
        if bf.rssiSensor ~= nil then return bf.rssiSensor:value() end
        return 0
    end,

    startsWith = function(str, prefix)
        if #prefix > #str then return false end
        for i = 1, #prefix do
            if str:byte(i) ~= prefix:byte(i) then
                return false
            end
        end
        return true
    end,

    loadScript = function(script)
        -- loadScript also works on 1.5.9, but is undocumented (?)
        if not bf.startsWith(script, bf.baseDir) then
            script = bf.baseDir..script
        end
        return loadfile(script)
    end,

    getWindowSize = function()
        return lcd.getWindowSize()
        --return 784, 406
        --return 472, 288
        --return 472, 240
    end,

    log = function(str)
        if not bf.logfile then
            bf.logfile = io.open("/bf.log", "a")
        end
        io.write(bf.logfile, string.format("%.2f ", bf.clock()) .. tostring(str) .. "\n")
    end,

    print = function(str)
        --print(tostring(str))
        --bf.log(str)
    end,

    clock = os.clock,

    apiVersion = nil
}