local Addon = select(2, ...)

local Config = Addon:NewModule("Config")
Addon.Config = Config

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
                    desc = "Print prettified reputation message into chat",
                    width = "full",
                    get = function(info) return Addon.db.profile.Enabled end,
                    set = function(info, value)
                        Addon.db.profile.Enabled = value
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
    options.args.Profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(Addon.db)
    options.args.Profile.order = 80
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(Addon.CONST.METADATA.NAME, options)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions(Addon.CONST.METADATA.NAME)
end