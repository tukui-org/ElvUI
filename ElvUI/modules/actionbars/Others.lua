if not ElvCF["actionbar"].enable == true then return end
local ElvDB = ElvDB
local ElvCF = ElvCF

---------------------------------------------------------------------------
-- Manage all others stuff for actionbars
---------------------------------------------------------------------------

local ElvuiOnLogon = CreateFrame("Frame")
ElvuiOnLogon:RegisterEvent("PLAYER_ENTERING_WORLD")
ElvuiOnLogon:SetScript("OnEvent", function(self, event)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")	
	SetActionBarToggles(1, 1, 1, 1, 0)
	SetCVar("alwaysShowActionBars", 0)	
	if ElvCF["actionbar"].showgrid == true then
		ActionButton_HideGrid = ElvDB.dummy
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
	if ElvCF["actionbar"].rightbars > 2 and ElvCF["actionbar"].splitbar == true then
		ElvCF["actionbar"].rightbars = 2
	end

	if ElvCF["actionbar"].bottomrows == 3 and ElvCF["actionbar"].rightbars ~= 0 and ElvCF["actionbar"].splitbar == true then
		ElvCF["actionbar"].rightbars = 0
		RightBarBig:Show()
	end

	if ElvCF["actionbar"].bottomrows == 3 and ElvCF["actionbar"].rightbars > 2 then
		ElvCF["actionbar"].rightbars = 2
	end
	
	if ElvCF["actionbar"].rightbars ~= 0 or (ElvCF["actionbar"].bottomrows == 3 and ElvCF["actionbar"].splitbar == true) then
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
	PositionBarPet(ElvuiPetBar)
	PositionWatchFrame()
end