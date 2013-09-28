local addon = _G["ElvUI"]
local addonName = tostring(addon)

local DEFAULT_WIDTH = 900;
local DEFAULT_HEIGHT = 650;
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local ACR = LibStub("AceConfigRegistry-3.0")
local options = addon:GetOptions()
local L = addon:GetLocales()

AC:RegisterOptionsTable(addonName, options)
ACD:SetDefaultSize(addonName, DEFAULT_WIDTH, DEFAULT_HEIGHT)


StaticPopupDialogs["PRIVATE_RL"] = {
	text = L["You have changed a setting for this character only. This setting will be uneffected by profile changes and requires that you reload the user interface."],
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = ReloadUI,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false,
}

options.args = {
	header = {
		order = 1,
		type = "header",
		name = L["Version"]..format(": |cff99ff33%s|r", addon.CURRENT_VERSION),
		width = "full",		
	},
}