local ADDON_NAME = ...;
local Addon = LibStub("AceAddon-3.0"):NewAddon(select(2, ...), ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0", "LibSink-2.0");
local LibToast = LibStub("LibToast-1.0")
local LSM = LibStub("LibSharedMedia-3.0")

local Debug = Addon.DEBUG
local Const = Addon.CONST
local Options

local AddonDB_Defaults = {
    profile = {
        Enabled = true,
        Sound = {
            Enabled = true,
            Alert = "AA - Default",
        },
        Toast = {
            Enabled = false,
        },
        Sink = {
            Enabled = false,
        },
        Debug = false,
    }
}

local playerName = UnitName("player")
local private = {}

local addonName, KT = ...

local media = {
    -- Sounds (Blizzard)
    { type = "SOUND", name = "Default", filePath = 569593 }, -- sound/spells/levelup.ogg
}

function private.defineMedia()
     for _, item in ipairs(media) do
        LSM:Register(LSM.MediaType[item.type], "AA - "..item.name, item.filePath)
    end
end

function private.defineToast()
    LibToast:Register("Achievement", function(toast, achievement, ...)
        toast:SetTitle("Achievement")
        toast:SetFormattedText(achievement)
        toast:SetUrgencyLevel(...)
    end)
end

function private.showToast(text)
    LibToast:Spawn("Achievement", text, "normal")
end

function private.Alert(text, name)
    if Options.Sound.Enabled then
        PlaySoundFile(LSM:Fetch("sound", Options.Sound.Alert))
    end
    if Options.Toast.Enabled then
        private.showToast(text)
    end

    if Options.Sink.Enabled then
        Addon:Pour(text, 1, 1, 1)
    end
end

function private.AchievementGained(event, text, name)
    if not Options.Enabled then return end

    if Options.Debug then
        local args = {
            event = event,
            text = text,
            name = name,
        }
        Debug:Info(args, "Event", "VDT")
        Debug:Info(event, "event")
        Debug:Info(text, "text")
        Debug:Info(name, "name")
    end

    if type(name) ~= "string" then return end

    name = Ambiguate(name, "none")
    if playerName == name then return end
    private.Alert(text, name)
end

function private.chatCmdShowConfig(input)
    local cmd = Addon:GetArgs(input)
    if not cmd or cmd == "" or cmd == "help" or cmd == "?" then
        local argStr  = "   |cff00ff00/aa %s|r - %s"
        local arg2Str = "   |cff00ff00/aa %s|r or |cff00ff00%s|r - %s"
        Addon:Print("Available Chat Command Arguments")
        print(format(argStr, "config", "Opens configuration window."))
        print(format(argStr, "toggle", "Toggles watching for achievements."))
        print(format(argStr, "test", "Fire test achievement."))
        print(format(arg2Str, "help", "?", "Print this again."))
        print(format(argStr, "ver", "Print Addon Version"))
    elseif cmd == "config" then
        -- happens twice because there is a bug in the blizz implementation and the first call doesn't work. subsequent calls do.
        InterfaceOptionsFrame_OpenToCategory(Const.METADATA.NAME)
        InterfaceOptionsFrame_OpenToCategory(Const.METADATA.NAME)
    elseif cmd == "ver" then
        Addon:Print(("You are running version |cff1784d1%s|r."):format(Const.METADATA.VERSION))
    elseif cmd == "toggle" then
        Addon.db.profile.Enabled = not Addon.db.profile.Enabled
    elseif cmd == "test" then
        private.Alert("You will never ever get any achievement again!", "You fool")
    end
end

function Addon:OnEnable()
    Addon.db = LibStub("AceDB-3.0"):New(ADDON_NAME .. "DB", AddonDB_Defaults, true) -- set true to prefer 'Default' profile as default
    Options = Addon.db.profile
    private.defineToast()
    private.defineMedia()
    Addon:RegisterChatCommand("aa", private.chatCmdShowConfig)
    Addon:RegisterEvent("CHAT_MSG_GUILD_ACHIEVEMENT", private.AchievementGained)
end

function Addon:OnDisable()
    Addon:UnregisterEvent("CHAT_MSG_GUILD_ACHIEVEMENT")
end