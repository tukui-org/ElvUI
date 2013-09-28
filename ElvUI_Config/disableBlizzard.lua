local addon = _G["ElvUI"]
local L = addon:GetLocales()
local options = addon:GetOptions()
local module = addon:GetModule("DisableBlizzard")

local defaults = addon:GetDefaults("private").disableBlizzard
options.args.disableBlizzard = {
	name = L["Disable Blizzard"],
	type = "group",
	order = 2,
	get = function(info) return addon.private.disableBlizzard[ info[#info] ] end,
	set = function(info, value) 
		addon.private.disableBlizzard[ info[#info] ] = value
		StaticPopup_Show("PRIVATE_RL")
	end,	
	args = {}
}

for option, value in pairs(defaults) do
	options.args.disableBlizzard.args[option] = {
		name = L[option],
		type = "toggle"
	}
end