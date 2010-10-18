-- here we kill all shit stuff on default UI that we don't need!

local k = TukuiDB.Kill

local Kill = CreateFrame("Frame")
Kill:RegisterEvent("ADDON_LOADED")
Kill:RegisterEvent("PLAYER_ENTERING_WORLD")
Kill:SetScript("OnEvent", function(self, event, addon)
	if event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		
		if IsAddOnLoaded("Tukui_Dps_Layout") or IsAddOnLoaded("Tukui_Heal_Layout") then
			InterfaceOptionsFrameCategoriesButton11:SetScale(0.00001)
			InterfaceOptionsFrameCategoriesButton11:SetAlpha(0)
			-- this part of code is temporary until it's included in oUF Framework by Haste.
			-- It hide Blizzard raid frames.
			CompactRaidFrameManager:SetScale(0.00001)
			CompactRaidFrameManager:SetAlpha(0)
			CompactRaidFrameContainer:SetScale(0.00001)
			CompactRaidFrameContainer:SetAlpha(0)
		end	
	else
		if addon == "Blizzard_AchievementUI" then
			if TukuiCF.tooltip.enable then
				hooksecurefunc("AchievementFrameCategories_DisplayButton", function(button) button.showTooltipFunc = nil end)
			end
		end
		
		if addon ~= "Tukui" then return end
		
		k(StreamingIcon)
		k(Advanced_UseUIScale)
		k(Advanced_UIScaleSlider)
		k(PartyMemberBackground)
		k(TutorialFrameAlertButton)
		
		k(InterfaceOptionsUnitFramePanelPartyBackground)
		
		if TukuiCF.arena.unitframes then
			SetCVar("showArenaEnemyFrames", 0)
			k(InterfaceOptionsUnitFramePanelArenaEnemyFrames)
			k(InterfaceOptionsUnitFramePanelArenaEnemyCastBar)
			k(InterfaceOptionsUnitFramePanelArenaEnemyPets)
		end
		
		if TukuiCF.chat.enable then
			SetCVar("WholeChatWindowClickable", 0)
			SetCVar("ConversationMode", "inline")
			k(InterfaceOptionsSocialPanelWholeChatWindowClickable)
			k(InterfaceOptionsSocialPanelConversationMode)
		end
		
		if TukuiCF.unitframes.enable then
			InterfaceOptionsFrameCategoriesButton9:SetScale(0.00001)
			InterfaceOptionsFrameCategoriesButton9:SetAlpha(0)	
			InterfaceOptionsFrameCategoriesButton9:SetScale(0.00001)
			InterfaceOptionsFrameCategoriesButton9:SetAlpha(0)
		end
		
		if TukuiCF.actionbar.enable then
			k(InterfaceOptionsActionBarsPanelBottomLeft)
			k(InterfaceOptionsActionBarsPanelBottomRight)
			k(InterfaceOptionsActionBarsPanelRight)
			k(InterfaceOptionsActionBarsPanelRightTwo)
			k(InterfaceOptionsActionBarsPanelAlwaysShowActionBars)
		end
	end
end)