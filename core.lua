local ADDON_NAME = ...;
local Addon = LibStub("AceAddon-3.0"):NewAddon(select(2, ...), ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0");


local AddonDB_Defaults = {
    profile = {
        Enabled = true,
        Debug = false,
    }
}

local playerName = UnitName("player")
local private = {}

function private.AchievementGained(event, text, name)
    if not Addon.db.profile.Enabled then return end

    if Addon.db.profile.Debug then
        local args = {
            event = event,
            text = text,
            name = name,
        }
        Addon.DEBUG:Info(args, "Event", "VDT")
        Addon.DEBUG:Info(event, "event")
        Addon.DEBUG:Info(text, "text")
        Addon.DEBUG:Info(name, "name")
    end

    if type(name) ~= "string" then return end

    name = Ambiguate(name, "none")
    if playerName == name then return end
    if event == "CHAT_MSG_GUILD_ACHIEVEMENT" then
        PlaySound( 124 ) -- "LEVELUPSOUND"
    end
end



function Addon:OnEnable()
    Addon.db = LibStub("AceDB-3.0"):New(ADDON_NAME .. "DB", AddonDB_Defaults, true) -- set true to prefer 'Default' profile as default
    Addon:RegisterEvent("CHAT_MSG_GUILD_ACHIEVEMENT", private.AchievementGained)
    Addon:RegisterEvent("CHAT_MSG_ACHIEVEMENT", private.AchievementGained)
end

function Addon:OnDisable()
    Addon:UnregisterEvent("CHAT_MSG_GUILD_ACHIEVEMENT")
    Addon:UnregisterEvent("CHAT_MSG_ACHIEVEMENT")
end