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

function FarmMode()
	if Minimap:IsShown() then
		UIFrameFadeOut(Minimap, 0.3)
		UIFrameFadeIn(FarmModeMap, 0.3) 
		Minimap.fadeInfo.finishedFunc = function() Minimap:Hide(); _G.MinimapZoomIn:Click(); _G.MinimapZoomOut:Click(); Minimap:SetAlpha(1) end
	else
		UIFrameFadeOut(FarmModeMap, 0.3)
		UIFrameFadeIn(Minimap, 0.3) 
		FarmModeMap.fadeInfo.finishedFunc = function() FarmModeMap:Hide(); _G.MinimapZoomIn:Click(); _G.MinimapZoomOut:Click(); Minimap:SetAlpha(1) end
	end
end

function E:FarmMode()
	FarmMode()
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

-- Testui Command
local testui = TestUI or function() end
TestUI = function(msg)
	if msg == "a" or msg == "arena" then
			ElvUF_Arena1:Show(); ElvUF_Arena1.Hide = function() end; ElvUF_Arena1.unit = "player"
			ElvUF_Arena2:Show(); ElvUF_Arena2.Hide = function() end; ElvUF_Arena2.unit = "player"
			ElvUF_Arena3:Show(); ElvUF_Arena3.Hide = function() end; ElvUF_Arena3.unit = "player"
			ElvUF_Arena4:Show(); ElvUF_Arena4.Hide = function() end; ElvUF_Arena4.unit = "player"
	elseif msg == "boss" or msg == "b" then
			ElvUF_Boss1:Show(); ElvUF_Boss1.Hide = function() end; ElvUF_Boss1.unit = "player"
			ElvUF_Boss2:Show(); ElvUF_Boss2.Hide = function() end; ElvUF_Boss2.unit = "player"
			ElvUF_Boss3:Show(); ElvUF_Boss3.Hide = function() end; ElvUF_Boss3.unit = "player"
			ElvUF_Boss4:Show(); ElvUF_Boss4.Hide = function() end; ElvUF_Boss4.unit = "player"
	elseif msg == "buffs" then -- better dont test it ^^
		UnitAura = function()
			-- name, rank, texture, count, dtype, duration, timeLeft, caster
			return 139, 'Rank 1', 'Interface\\Icons\\Spell_Holy_Penance', 1, 'Magic', 0, 0, "player"
		end
		if(oUF) then
			for i, v in pairs(oUF.units) do
				if(v.UNIT_AURA) then
					v:UNIT_AURA("UNIT_AURA", v.unit)
				end
			end
		end
	end
end
SlashCmdList.TestUI = TestUI
SLASH_TestUI1 = "/testui"
