local addonName, addon = ...
local defaults = addon:GetDefaults("profile")
local global = addon:GetDefaults("global")

global.core = {
	debugMode = true,
}