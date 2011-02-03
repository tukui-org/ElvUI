local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if not C["actionbar"].enable == true then return end

---------------------------------------------------------------------------
-- Manage all others stuff for actionbars
---------------------------------------------------------------------------

local ElvuiOnLogon = CreateFrame("Frame")
ElvuiOnLogon:RegisterEvent("PLAYER_ENTERING_WORLD")
ElvuiOnLogon:SetScript("OnEvent", function(self, event)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")	
	SetActionBarToggles(1, 1, 1, 1, 0)
	SetCVar("alwaysShowActionBars", 0)	
	if C["actionbar"].showgrid == true then
		ActionButton_HideGrid = E.dummy
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

function E.PositionAllBars()
	if E["actionbar"].rightbars > 2 and E["actionbar"].splitbar == true then
		E["actionbar"].rightbars = 2
	end

	if E["actionbar"].bottomrows == 3 and E["actionbar"].rightbars ~= 0 and E["actionbar"].splitbar == true then
		E["actionbar"].rightbars = 0
		if E.ABLock == true then
			RightBarBig:Show()
		end
	end

	if E["actionbar"].bottomrows == 3 and E["actionbar"].rightbars > 2 then
		E["actionbar"].rightbars = 2
	end
	
	if E["actionbar"].rightbars ~= 0 or (E["actionbar"].bottomrows == 3 and E["actionbar"].splitbar == true) then
		RightBarBig:Hide()
	else
		if E.ABLock == true then
			RightBarBig:Show()
		end
	end
	
	E.PositionAllPanels()
	E.PositionMainBar()
	E.PositionBar2()
	E.PositionBar3()
	E.PositionBar4()
	E.PositionBar5()
	E.PositionBarPet(ElvuiPetBar)
	E.PositionWatchFrame()
end