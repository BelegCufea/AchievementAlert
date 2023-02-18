local Addon = select(2, ...)

local Config = Addon:NewModule("Config")
local ConfigRegistry = LibStub("AceConfigRegistry-3.0")
local ConfigDialog = LibStub("AceConfigDialog-3.0")
--local LSM = LibStub("LibSharedMedia-3.0")

local options = {
	name = Addon.CONST.METADATA.NAME,
	type = "group",
    childGroups = "tab",
	args = {
        General = {
            type = "group",
            order = 10,
            name = "General",
            args = {
                Enabled = {
                    type = "toggle",
                    order = 10,
                    name = "Enabled",
                    desc = "Enables watching achievements",
                    width = "full",
                    get = function(info) return Addon.db.profile.Enabled end,
                    set = function(info, value)
                        Addon.db.profile.Enabled = value
                    end
                },
                Sound = {
                    type = "group",
                    order = 20,
                    name = "Sound",
                    inline = true,
                    args = {
                        Enabled = {
                            type = "toggle",
                            order = 10,
                            name = "Play sound",
                            get = function() return Addon.db.profile.Sound.Enabled end,
                            set = function(info, value)
                                Addon.db.profile.Sound.Enabled = value
                            end,
                        },
                        Sound = {
                            type = "select",
                            order = 20,
                            name = "Sound",
                            desc = "Select a sound",
                            width = 1.2,
                            disabled = function() return  not Addon.db.profile.Sound.Enabled end,
                            dialogControl = "LSM30_Sound",
                            values = AceGUIWidgetLSMlists.sound,
                            get = function() return Addon.db.profile.Sound.Alert end,
                            set = function(info, value)
                                Addon.db.profile.Sound.Alert = value
                            end,
                        },
                    },
                },
                Toast = {
                    type = "toggle",
                    order = 30,
                    name = "Toast",
                    desc = "Shows toast on achievement gain",
                    width = "full",
                    get = function(info) return Addon.db.profile.Toast.Enabled end,
                    set = function(info, value)
                        Addon.db.profile.Toast.Enabled = value
                    end
                },
                SinkEnabled = {
                    type = "toggle",
                    order = 40,
                    name = "Also display on:",
                    width = "full",
                    get = function(info) return Addon.db.profile.Sink.Enabled end,
                    set = function(info, value)
                        Addon.db.profile.Sink.Enabled = value
                    end
                },
                Debug = {
                    type = "toggle",
                    order = 90,
                    name = "Debug",
                    desc = "Print debug messages in chat",
                    width = "full",
                    get = function(info) return Addon.db.profile.Debug end,
                    set = function(info, value)
                        Addon.db.profile.Debug = value
                    end
                },
            },
        },
    },
}

function Config:OnEnable()
    options.args.General.args.Sink = Addon:GetSinkAce3OptionsDataTable()
    options.args.General.args.Sink.order = 45
    options.args.General.args.Sink.inline = true
    options.args.General.args.Sink.disabled = function() return not (Addon.db.profile.Sink.Enabled) end
    options.args.Profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(Addon.db)
    options.args.Profile.order = 80
	ConfigRegistry:RegisterOptionsTable(Addon.CONST.METADATA.NAME, options)
	ConfigDialog:AddToBlizOptions(Addon.CONST.METADATA.NAME)
    Addon:SetSinkStorage(Addon.db.profile)
end