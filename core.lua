local ADDON_NAME = ...;
local Addon = LibStub("AceAddon-3.0"):NewAddon(select(2, ...), ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0", "LibSink-2.0");
local AceGUI = LibStub("AceGUI-3.0")

local Debug = Addon.DEBUG
local Const = Addon.CONST
local Options

local AddonDB_Defaults = {
    profile = {
        Enabled = true,
        Sound = {
            Enabled = true,
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

-- Function to create a toast with the given text
function private.showToast(text)
    --[[
    -- Create the toast frame
    local toast = CreateFrame("Frame", nil, UIParent)
    toast:SetSize(300, 50)
    toast:SetPoint("CENTER", UIParent, "CENTER")

    -- Create the toast text
    local toastText = toast:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    toastText:SetPoint("CENTER")
    toastText:SetJustifyH("CENTER")
    toastText:SetText(text)

    -- Animate the toast
    toast:SetScript("OnShow", function(self)
        self.anim = self:CreateAnimationGroup()
        self.anim.fadeOut = self.anim:CreateAnimation("Alpha")
        self.anim.fadeOut:SetDuration(1)
        self.anim.fadeOut:SetChange(-1)
        self.anim:SetScript("OnFinished", function() self:Hide() end)
        self.anim:Play()
    end)

    -- Show the toast
    toast:Show()
    ]]

    local toast = AceGUI:Create("Frame")
    toast:SetTitle("")
    toast:SetLayout("Fill")
    toast:SetWidth(300)
    toast:SetHeight(50)
    toast.frame:SetBackdropColor(0, 0, 0, 1)
    toast.frame:SetBackdropBorderColor(0, 0, 0, 1)

    local toastText = AceGUI:Create("Label")
    toastText:SetText(text)
    Debug:Info(GameFontNormal, "Font", "VDT")
    toastText:SetFont(GameFontNormal:GetFont(), 12, "")
    toastText:SetColor(1, 1, 1)
    toastText:SetFullWidth(true)
    toastText:SetFullHeight(true)
    toast:AddChild(toastText)

    toast:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)

    C_Timer.After(3, function () AceGUI:Release(toast) end)
end

function private.Alert(text, name)
    if Options.Sound.Enabled then
        PlaySound( 124 ) -- "LEVELUPSOUND"
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
        print(format(argStr, "version", "ver", "Print Addon Version"))
    elseif cmd == "config" then
        -- happens twice because there is a bug in the blizz implementation and the first call doesn't work. subsequent calls do.
        InterfaceOptionsFrame_OpenToCategory(Const.NAME)
        InterfaceOptionsFrame_OpenToCategory(Const.NAME)
    elseif cmd == "version" or cmd == "ver" then
        Addon:Print(("You are running version |cff1784d1%s|r."):format(Const.VERSION))
    elseif cmd == "toggle" then
        Addon.db.profile.Enabled = not Addon.db.profile.Enabled
    elseif cmd == "test" then
        private.Alert("You will never ever get any achievement again!", "You fool")
    end
end

function Addon:OnEnable()
    Addon.db = LibStub("AceDB-3.0"):New(ADDON_NAME .. "DB", AddonDB_Defaults, true) -- set true to prefer 'Default' profile as default
    Options = Addon.db.profile
    Addon:RegisterChatCommand("aa", private.chatCmdShowConfig)
    Addon:RegisterEvent("CHAT_MSG_GUILD_ACHIEVEMENT", private.AchievementGained)
end

function Addon:OnDisable()
    Addon:UnregisterEvent("CHAT_MSG_GUILD_ACHIEVEMENT")
end