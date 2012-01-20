local E, L, DF = unpack(select(2, ...)); --Engine

function E:EnableAddon(addon)
	local _, _, _, _, _, reason, _ = GetAddOnInfo(addon)
	if reason ~= "MISSING" then 
		EnableAddOn(addon) 
		ReloadUI() 
	else 
		print("|cffff0000Error, Addon '"..addon.."' not found.|r") 
	end	
end

function E:DisableAddon(addon)
	local _, _, _, _, _, reason, _ = GetAddOnInfo(addon)
	if reason ~= "MISSING" then 
		DisableAddOn(addon) 
		ReloadUI() 
	else 
		print("|cffff0000Error, Addon '"..addon.."' not found.|r") 
	end
end

function E:ResetGold()
	ElvData.gold = nil;
	ReloadUI();
end

function E:FarmMode()
	if Minimap:IsShown() then
		UIFrameFadeOut(Minimap, 0.3)
		Minimap.fadeInfo.finishedFunc = function() Minimap:Hide(); end
	else
		UIFrameFadeOut(FarmModeMap, 0.3)
		FarmModeMap.fadeInfo.finishedFunc = function() FarmModeMap:Hide(); end
	end
end

function E:LoadCommands()
	self:RegisterChatCommand("ec", "ToggleConfig")
	self:RegisterChatCommand("elvui", "ToggleConfig")
	
	self:RegisterChatCommand("moveui", "MoveUI")
	self:RegisterChatCommand("resetui", "ResetUI")
	self:RegisterChatCommand("enable", "EnableAddon")
	self:RegisterChatCommand("disable", "DisableAddon")
	self:RegisterChatCommand('resetgold', 'ResetGold')
	self:RegisterChatCommand('farmmode', 'FarmMode')
	
	if E.ActionBars then
		self:RegisterChatCommand('kb', E.ActionBars.ActivateBindMode)
	end
end