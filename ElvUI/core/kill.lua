-- here we kill all shit stuff on default UI that we don't need!
local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

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


		if E.myclass == "DEATHKNIGHT" then
			RuneFrame:Kill()
		end
	else

		if addon == "Blizzard_AchievementUI" then
			if C.tooltip.enable then
				hooksecurefunc("AchievementFrameCategories_DisplayButton", function(button) button.showTooltipFunc = nil end)
			end
		end
		
		--[[if C["auras"].minimapauras == true then
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
		
		if C.arena.unitframes then
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
		end
		
		if C.unitframes.enable then
			InterfaceOptionsFrameCategoriesButton9:SetScale(0.00001)
			InterfaceOptionsFrameCategoriesButton9:SetAlpha(0)	
			InterfaceOptionsFrameCategoriesButton9:SetScale(0.00001)
			InterfaceOptionsFrameCategoriesButton9:SetAlpha(0)
		end
		
		if C.actionbar.enable then
			InterfaceOptionsActionBarsPanelBottomLeft:Kill()
			InterfaceOptionsActionBarsPanelBottomRight:Kill()
			InterfaceOptionsActionBarsPanelRight:Kill()
			InterfaceOptionsActionBarsPanelRightTwo:Kill()
			InterfaceOptionsActionBarsPanelAlwaysShowActionBars:Kill()
		end
	end
end)