-- here we kill all shit stuff on default UI that we don't need!
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

local Kill = CreateFrame("Frame")
Kill:RegisterEvent("ADDON_LOADED")
Kill:RegisterEvent("PLAYER_ENTERING_WORLD")
Kill:SetScript("OnEvent", function(self, event, addon)
	if event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		
		if IsAddOnLoaded("Elvui_RaidDPS") or IsAddOnLoaded("Elvui_RaidHeal") then
			InterfaceOptionsFrameCategoriesButton11:SetScale(0.00001)
			InterfaceOptionsFrameCategoriesButton11:SetAlpha(0)
		end	


		if E.myclass == "DEATHKNIGHT" then
			RuneFrame:Kill()
		end
	else

		if C["raidframes"].disableblizz == true then 
			InterfaceOptionsFrameCategoriesButton10:SetScale(0.00001)
			InterfaceOptionsFrameCategoriesButton10:SetAlpha(0)	
			CompactRaidFrameContainer:Kill()
			SetCVar("useCompactPartyFrames", 0)
		end

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