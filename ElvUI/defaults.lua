local addonName, addon = ...
local defaults = addon:GetDefaults("profile")
local global = addon:GetDefaults("global")

global.core = {
	debugMode = true,
}

defaults.core = {
	primaryColor = {r = 0.17, g = 0.17, b = 0.17},
	secondaryColor = {r = 0, g = 0, b = 0},
	alphaLevel = 0.45,

	primaryFont = "PT Sans Narrow",
	primaryFontSize = 12,
	primaryFontOutline = "NONE",
	
	secondaryFont = "Homespun",
	secondaryFontSize = 10,
	secondaryFontOutline = "MONOCHROMEOUTLINE",

	statusbarTexture = "Smooth"
}