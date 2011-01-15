-- here we kill all shit stuff on default UI that we don't need!
local ElvDB = ElvDB
local ElvCF = ElvCF

local k = ElvDB.Kill

local Kill = CreateFrame("Frame")
Kill:RegisterEvent("ADDON_LOADED")
Kill:RegisterEvent("PLAYER_ENTERING_WORLD")
Kill:SetScript("OnEvent", function(self, event, addon)
	if event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		
		if IsAddOnLoaded("ElvUI_Dps_Layout") or IsAddOnLoaded("ElvUI_Heal_Layout") then
			InterfaceOptionsFrameCategoriesButton11:SetScale(0.00001)
			InterfaceOptionsFrameCategoriesButton11:SetAlpha(0)
		end	


		if ElvDB.myclass == "DEATHKNIGHT" then
			k(RuneFrame)
		end
	else

		if addon == "Blizzard_AchievementUI" then
			if ElvCF.tooltip.enable then
				hooksecurefunc("AchievementFrameCategories_DisplayButton", function(button) button.showTooltipFunc = nil end)
			end
		end
		
		if addon ~= "ElvUI" then return end
		k(StreamingIcon)
		k(Advanced_UseUIScale)
		k(Advanced_UIScaleSlider)
		k(PartyMemberBackground)
		k(TutorialFrameAlertButton)
		
		k(InterfaceOptionsUnitFramePanelPartyBackground)
		
		if ElvCF.arena.unitframes then
			SetCVar("showArenaEnemyFrames", 0)
			k(InterfaceOptionsUnitFramePanelArenaEnemyFrames)
			k(InterfaceOptionsUnitFramePanelArenaEnemyCastBar)
			k(InterfaceOptionsUnitFramePanelArenaEnemyPets)
		end
		
		if ElvCF.chat.enable then
			SetCVar("WholeChatWindowClickable", 0)
			SetCVar("ConversationMode", "inline")
			k(InterfaceOptionsSocialPanelWholeChatWindowClickable)
			k(InterfaceOptionsSocialPanelConversationMode)
		end
		
		if ElvCF.unitframes.enable then
			InterfaceOptionsFrameCategoriesButton9:SetScale(0.00001)
			InterfaceOptionsFrameCategoriesButton9:SetAlpha(0)	
			InterfaceOptionsFrameCategoriesButton9:SetScale(0.00001)
			InterfaceOptionsFrameCategoriesButton9:SetAlpha(0)
		end
		
		if ElvCF.actionbar.enable then
			k(InterfaceOptionsActionBarsPanelBottomLeft)
			k(InterfaceOptionsActionBarsPanelBottomRight)
			k(InterfaceOptionsActionBarsPanelRight)
			k(InterfaceOptionsActionBarsPanelRightTwo)
			k(InterfaceOptionsActionBarsPanelAlwaysShowActionBars)
		end
	end
end)