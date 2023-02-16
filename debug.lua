local Addon = select(2, ...)

local DEBUG = {}
Addon.DEBUG = DEBUG

function DEBUG:Info(value, name, type)
    if not name then name = Addon.CONSTS.METADATA.NAME end
    if (not type) or (type == "Print") then
        Addon:Print(name, value)
        return
    end

    if (type == "VDT") and ViragDevTool_AddData then
        ViragDevTool_AddData(value, Addon.CONST.METADATA.NAME .. "_" .. name)
        return
    end

end