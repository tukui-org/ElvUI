-- here we kill all shit stuff on default UI that we don't need!
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

local compact_raid
function HideRaid()
	if InCombatLockdown() then return end
	CompactRaidFrameManager:Hide()
	compact_raid = CompactRaidFrameManager_GetSetting("IsShown")
	if compact_raid and compact_raid ~= "0" then 
		CompactRaidFrameManager_SetSetting("IsShown", "0")
	end
end

if C["raidframes"].disableblizz == true then 
	hooksecurefunc("CompactRaidFrameManager_UpdateShown",function()
		HideRaid()
	end)
	CompactRaidFrameManager:HookScript('OnShow', HideRaid)
	CompactRaidFrameManager:SetScale(0.000001) --- BAHAHAHA FUCK YOU RAID FRAMES!
end

local Kill = CreateFrame("Frame")
Kill:RegisterEvent("ADDON_LOADED")
Kill:RegisterEvent("PLAYER_ENTERING_WORLD")
Kill:RegisterEvent("RAID_ROSTER_UPDATE")
Kill:RegisterEvent("PLAYER_REGEN_ENABLED")
Kill:SetScript("OnEvent", function(self, event, addon)
	if (event == "PLAYER_ENTERING_WORLD" or event == "RAID_ROSTER_UPDATE" or event == "PLAYER_REGEN_ENABLED") and C["raidframes"].disableblizz == true then
		HideRaid()
	end
	if event == "PLAYER_ENTERING_WORLD" and not self.run then
		if IsAddOnLoaded("Elvui_RaidDPS") or IsAddOnLoaded("Elvui_RaidHeal") then
			InterfaceOptionsFrameCategoriesButton11:SetScale(0.00001)
			InterfaceOptionsFrameCategoriesButton11:SetAlpha(0)
		end	


		if E.myclass == "DEATHKNIGHT" then
			RuneFrame:Kill()
		end
		
		if C["raidframes"].disableblizz == true then 
			InterfaceOptionsFrameCategoriesButton10:SetScale(0.00001)
			InterfaceOptionsFrameCategoriesButton10:SetAlpha(0)	
			HideRaid()
			SetCVar("useCompactPartyFrames", 0)
		end		
		self.run = true
	elseif event == "ADDON_LOADED" then
		if addon == "Blizzard_AchievementUI" then
			if C.tooltip.enable then
				hooksecurefunc("AchievementFrameCategories_DisplayButton", function(button) button.showTooltipFunc = nil end)
			end
		end

		--[[if C["others"].minimapauras == true then
			BuffFrame:Kill()
			TemporaryEnchantFrame:Kill()
		end]]
		
		if addon ~= "ElvUI" then return end
		
		GuildChallengeAlertFrame:Kill()
		PlayerTalentFrameLearnButtonTutorialArrow:Kill()
		HelpOpenTicketButtonTutorial:Kill()
		StreamingIcon:Kill()
		Advanced_UseUIScale:Kill()
		Advanced_UIScaleSlider:Kill()
		PartyMemberBackground:Kill()
		TutorialFrameAlertButton:Kill()
		
		InterfaceOptionsUnitFramePanelPartyBackground:Kill()
		
		if C.unitframes.arena then
			SetCVar("showArenaEnemyFrames", 0)
			InterfaceOptionsUnitFramePanelArenaEnemyFrames:Kill()
			InterfaceOptionsUnitFramePanelArenaEnemyCastBar:Kill()
			InterfaceOptionsUnitFramePanelArenaEnemyPets:Kill()
		end
		
		if C.chat.enable then
			SetCVar("WholeChatWindowClickable", 0)
			SetCVar("ConversationMode", "inline")
			InterfaceOptionsSocialPanelWholeChatWindowClickable:Kill()
			InterfaceOptionsSocialPanelConversationMode:Kill()
			InterfaceOptionsSocialPanelChatStyleButton:EnableMouse(false)
			InterfaceOptionsSocialPanelChatStyle:EnableMouse(false)
			InterfaceOptionsSocialPanelChatStyle:SetAlpha(0)
			InterfaceOptionsSocialPanelChatHoverDelay:Kill()
		end
		
		if C.unitframes.enable then
			InterfaceOptionsFrameCategoriesButton9:SetScale(0.00001)
			InterfaceOptionsFrameCategoriesButton9:SetAlpha(0)	
			InterfaceOptionsCombatPanelTargetOfTarget:Kill()
			InterfaceOptionsDisplayPanelShowAggroPercentage:Kill()
			InterfaceOptionsBuffsPanelDispellableDebuffs:Kill()
			InterfaceOptionsBuffsPanelShowCastableDebuffs:Kill()
			InterfaceOptionsBuffsPanelCastableBuffs:Kill()
		end
		
		if C.actionbar.enable then
			InterfaceOptionsActionBarsPanelBottomLeft:Kill()
			InterfaceOptionsActionBarsPanelBottomRight:Kill()
			InterfaceOptionsActionBarsPanelRight:Kill()
			InterfaceOptionsActionBarsPanelRightTwo:Kill()
			InterfaceOptionsActionBarsPanelAlwaysShowActionBars:Kill()
		end
		
		if C["nameplate"].enable == true and C["nameplate"].enhancethreat == true then
			InterfaceOptionsDisplayPanelAggroWarningDisplay:Kill()
		end
	end
end)