if not TukuiCF["actionbar"].enable == true then return end

---------------------------------------------------------------------------
-- Manage all others stuff for actionbars
---------------------------------------------------------------------------

local TukuiOnLogon = CreateFrame("Frame")
TukuiOnLogon:RegisterEvent("PLAYER_ENTERING_WORLD")
TukuiOnLogon:SetScript("OnEvent", function(self, event)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")	
	SetActionBarToggles(1, 1, 1, 1, 0)
	SetCVar("alwaysShowActionBars", 0)	
	if TukuiCF["actionbar"].showgrid == true then
		ActionButton_HideGrid = TukuiDB.dummy
		for i = 1, 12 do
			local button = _G[format("ActionButton%d", i)]
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)

			button = _G[format("BonusActionButton%d", i)]
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)
			
			button = _G[format("MultiBarRightButton%d", i)]
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)

			button = _G[format("MultiBarBottomRightButton%d", i)]
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)
			
			button = _G[format("MultiBarLeftButton%d", i)]
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)
			
			button = _G[format("MultiBarBottomLeftButton%d", i)]
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)
		end
	end
end)

function PositionAllBars()
	if TukuiCF["actionbar"].rightbars > 2 and TukuiCF["actionbar"].splitbar == true then
		TukuiCF["actionbar"].rightbars = 2
	end

	if TukuiCF["actionbar"].bottomrows < 2 then
		TukuiCF["actionbar"].swaptopbottombar = false
	end

	if TukuiCF["actionbar"].bottomrows == 3 and TukuiCF["actionbar"].rightbars ~= 0 and TukuiCF["actionbar"].splitbar == true then
		TukuiCF["actionbar"].rightbars = 0
		RightBarBig:Show()
	end

	if TukuiCF["actionbar"].bottomrows == 3 and TukuiCF["actionbar"].rightbars > 2 then
		TukuiCF["actionbar"].rightbars = 2
	end
	
	if TukuiCF["actionbar"].rightbars ~= 0 or (TukuiCF["actionbar"].bottomrows == 3 and TukuiCF["actionbar"].splitbar == true) then
		RightBarBig:Hide()
	else
		RightBarBig:Show()
	end
	
	PositionAllPanels()
	PositionMainBar()
	PositionBar2()
	PositionBar3()
	PositionBar4()
	PositionBar5()
	PositionBarPet(TukuiPetBar)
	PositionWatchFrame()
end