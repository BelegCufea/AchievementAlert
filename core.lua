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

local playerName = UnitName("player") .. "-" .. GetRealmName()
local private = {}

local addonName, KT = ...

local media = {
    -- Sounds (Blizzard)
    { type = "SOUND", name = "Default", filePath = 569593 }, -- sound/spells/levelup.ogg
}

function Addon:Test()
    local currentTime = time()
    local dateTable = date("*t", currentTime)
    local day = dateTable.day
    local month = dateTable.month
    local year = dateTable.year
    local achievement = "|cffffff00|Hachievement:411:"..UnitGUID('player')..":1:"..month..":"..day..":"..year..":4294967295:4294967295:4294967295:4294967295|h[Murky]|h|r"
    private.Alert("%s will never ever get " .. achievement .. " achievement!", playerName)
end

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

function private.showToast(name, text)
    if ls_Toasts then
        local LST = ls_Toasts
        local E,C = LST[1], LST[2]

        local toast = E:GetToast()
        local achievementName = string.match(text, "|.-|r")
        local achievementID = string.match(text, "|Hachievement:(%d+):")

        Debug:Info(achievementName, "Achievement")
        Debug:Info(achievementID, "ID")

        toast.Title:SetText(name)
        toast.Text:SetText(achievementName)
        toast.IconText1:SetText("")

        if achievementID then
            local _, _, points, _, _, _, _, _, _, icon, _, _ = GetAchievementInfo(achievementID)
            if not toast:ShouldHideLeaves() then
                toast:ShowLeaves()
            end
            if C.db.profile.colors.border then
                toast.Border:SetVertexColor(1, 0.675, 0.125) -- ACHIEVEMENT_GOLD_BORDER_COLOR
                toast:SetLeavesVertexColor(1, 0.675, 0.125)
            end
            if C.db.profile.colors.icon_border then
                toast.IconBorder:SetVertexColor(1, 0.675, 0.125)
            end
            toast.IconText1:SetText(points == 0 and "" or points)
            toast.Icon:SetTexture(icon)
            toast.IconBorder:Show()
        end

        toast:Spawn(C.db.profile.types.achievement.anchor, C.db.profile.types.achievement.dnd)
    else
        LibToast:Spawn("Achievement", text, "normal")
    end
end

function private.Alert(text, name)
    local guild
    C_GuildInfo.GuildRoster()
    local numMembers = GetNumGuildMembers()
    for i=1, numMembers do
        local fullName, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline, status, class, achievementPoints, achievementRank, isMobile, canSoR, repStanding, guid = GetGuildRosterInfo(i)
        if fullName == name then
            name = string.format("[|c%s%s|r:%d]", RAID_CLASS_COLORS[class].colorStr, Ambiguate(name, "guild"), level)
            guild = true
            break
        end
    end

    if not guild then
        local playerGUID = string.match(text, "|Hachievement:%d+:(%S+)|")
        local _, class = GetPlayerInfoByGUID(playerGUID)
        name = string.format("[|c%s%s|r]", RAID_CLASS_COLORS[class].colorStr, Ambiguate(name, "none"))
    end

    local alertText = string.format(text, name)
    if Options.Sound.Enabled then
        PlaySoundFile(LSM:Fetch("sound", Options.Sound.Alert))
    end
    if Options.Toast.Enabled then
        private.showToast(name, text)
    end

    if Options.Sink.Enabled then
        Addon:Pour(alertText, 1, 1, 1)
    end
end

function private.AchievementGained(event, text, name)
    if not Options.Enabled then return end

    if type(name) ~= "string" then return end

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
        if Addon.db.profile.Enabled then
            Addon:Print("Alerts are |cff00ff00Enabled|r")
        else
            Addon:Print("Alerts are |cffff0000Disabled|r")
        end
    elseif cmd == "test" then
        Addon:Test()
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