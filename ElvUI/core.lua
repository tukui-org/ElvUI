local addonName, addon = ...
local format, len, sub = string.format, string.len, string.sub
local ACEDB, ACEL = LibStub("AceDB-3.0"), LibStub("AceLocale-3.0")
local configName = format("%s_Config", addonName)
_G[addonName] = addon

LibStub("AceAddon-3.0"):NewAddon(addon, addonName, "AceEvent-3.0", "AceHook-3.0","AceTimer-3.0", "AceConsole-3.0")
local L = ACEL:GetLocale(addonName)

-- Constants
addon.PLAYER_NAME = UnitName("player");
addon.PLAYER_CLASS = select(2, UnitClass("player"));
addon.PLAYER_RACE = select(2, UnitRace("player"));
addon.PLAYER_REALM = GetRealmName();
addon.CURRENT_VERSION = GetAddOnMetadata(addonName, "Version");
addon.GAME_BUILD = GetBuildInfo();
addon.SAVED_VARIABLES = format("%sVars", addonName);
addon.SAVED_VARIABLES_PER_CHAR = format("__%sVars", addonName);

--UI Frames
--Parent frames to this need to be permanently hidden
local UIHider = CreateFrame("Frame", format("%sHider", addonName), UIParent)
UIHider:Hide()

--Holder frame for all the addon frames to be positioned onto. Eyefinity/Nvidia surround support.
local UIHolder = CreateFrame("Frame", format("%sHolder", addonName), UIParent)
UIHolder:SetPoint("CENTER")
UIHolder:SetSize(UIParent:GetSize())
UIHolder:SetFrameLevel(UIParent:GetFrameLevel())

--PetBattle-Holder/Hider frame, parent to this if you want a secure toggler for pet battles
local PetUIHolder = CreateFrame("Frame", format("%sPetUIHolder", addonName), UIHolder, "SecureHandlerStateTemplate")
PetUIHolder:SetAllPoints()
RegisterStateDriver(PetUIHolder, "visibility", "[petbattle] hide;show")

--Colorized addonName, for messages.
local colorizedName
local length = len(addonName)
for i = 1, length do
	local letter = sub(addonName, i, i)
	if(i == 1) then
		colorizedName = format("|cffA11313%s", letter)
	elseif(i == 2) then
		colorizedName = format("%s|r|cffC4C4C4%s", colorizedName, letter)
	elseif(i == length) then
		colorizedName = format("%s%s|r|cffA11313:|r", colorizedName, letter)
	else
		colorizedName = colorizedName..letter
	end
end

--@usage - send a message with 'AddonName: ' at the start.
--@params - what the message should say
function addon:Print(...)
	print(colorizedName, ...)
end

--@usage - send a debug message with 'AddonName: ' at the start, Debugmode must be enabled otherwise nothing happens.
--@params - what the debug message should say
function addon:Debug(...)
	if(not self.global.core.debugMode) then return end
	print(colorizedName, ...)
end

--Default Tables
local __defaults = {
	profile = {}
}

local defaults = {
	global = {},
	profile = {}
}

--@usage - get the defaults table for private, global, or profile settings
--@param1 - what defaults table you need
		--defaults
		--global
		--profile (default if no param is provided)
function addon:GetDefaults(subKey)
	if(subKey == "private") then
		return __defaults.profile
	elseif(subKey == "global") then
		return defaults.global
	else
		return defaults.profile
	end
end

--Options Table
local options = {
	type = "group",
	name = addonName,
	args = {},	
}

--@usage - get the options table
function addon:GetOptions()
	return options
end

function addon:PLAYER_REGEN_ENABLED()
	self:ToggleConfig() 
	self:UnregisterEvent('PLAYER_REGEN_ENABLED');
end

function addon:PLAYER_REGEN_DISABLED()
	if IsAddOnLoaded(configName) then
		local ACECD = LibStub("AceConfigDialog-3.0")
		if ACECD.OpenFrames[addonName] then
			self:RegisterEvent('PLAYER_REGEN_ENABLED');
			ACECD:Close(AddOnName);
		end
	end

	--TODO: when movers get added we need to make sure we force them to hide here
end

--@usage - toggle the in-game config, cannot be done while in combat for several reasons.
function addon:ToggleConfig() 
	if InCombatLockdown() then
		self:Print(L["You cannot open the configuration menu while in combat."])
		self:RegisterEvent('PLAYER_REGEN_ENABLED')
		return
	end
	
	if not IsAddOnLoaded(configName) then
		local _, _, _, _, _, reason = GetAddOnInfo(configName)
		if reason ~= "MISSING" and reason ~= "DISABLED" then 
			LoadAddOn(configName)
		else 
			self:Print(format(L["Uh oh, something has happened and your addon '%s' is missing or disabled."], configName)) 
			return
		end
	end
	
	local ACECD = LibStub("AceConfigDialog-3.0")
	local mode = ACECD.OpenFrames[addonName] and "Close" or "Open"
	ACECD[mode](ACECD, addonName) 
	GameTooltip:Hide() --Just in case you're mouseovered something and it closes.
end
addon:RegisterChatCommand("ec", "ToggleConfig")
addon:RegisterChatCommand("elvui", "ToggleConfig")

--@usage - Get the locales table
function addon:GetLocales()
	return ACEL:GetLocale(addonName)
end

function addon:OnInitialize()
	self.private = (ACEDB:New(self.SAVED_VARIABLES_PER_CHAR, __defaults)).profile;

	local data = ACEDB:New(self.SAVED_VARIABLES, defaults);
	self.db = data.profile
	self.global = data.global
end