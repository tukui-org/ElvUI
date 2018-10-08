local E, L, DF = unpack(select(2, ...))
local B = E:GetModule('Blizzard')

--Cache global variables
--Lua functions
local _G = _G
--WoW API / Variables
local C_Garrison_GetLandingPageGarrisonType = C_Garrison.GetLandingPageGarrisonType
local ShowGarrisonLandingPage = ShowGarrisonLandingPage
local IsAddOnLoaded = IsAddOnLoaded
local CreateFrame = CreateFrame
local HideUIPanel = HideUIPanel
local PlaySound = PlaySound
local StopSound = StopSound
local EasyMenu = EasyMenu

local SOUNDKIT_UI_GARRISON_GARRISON_REPORT_OPEN = SOUNDKIT.UI_GARRISON_GARRISON_REPORT_OPEN
local SOUNDKIT_UI_GARRISON_GARRISON_REPORT_CLOSE = SOUNDKIT.UI_GARRISON_GARRISON_REPORT_CLOSE

local WAR_CAMPAIGN = WAR_CAMPAIGN
local GARRISON_LANDING_PAGE_TITLE = GARRISON_LANDING_PAGE_TITLE
local ORDER_HALL_LANDING_PAGE_TITLE = ORDER_HALL_LANDING_PAGE_TITLE

--No point caching anything else here, but list them here for mikk's FindGlobals script
-- GLOBALS: GarrisonLandingPage, DropDownList1

function B:GarrisonDropDown()
	-- Right click Menu for Garrision Button all Credits to Foxlit (WarPlan)
	if IsAddOnLoaded("WarPlan") then return; end

	local function ShowLanding(page)
		HideUIPanel(_G["GarrisonLandingPage"])
		ShowGarrisonLandingPage(page)
	end

	local function MaybeStopSound(sound)
		return sound and StopSound(sound)
	end

	local landingChoiceMenu, landingChoices
	_G["GarrisonLandingPageMinimapButton"]:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	_G["GarrisonLandingPageMinimapButton"]:HookScript("PreClick", function(self, b)
		self.landingVisiblePriorToClick = _G["GarrisonLandingPage"] and _G["GarrisonLandingPage"]:IsVisible() and _G["GarrisonLandingPage"].garrTypeID
		if b == "RightButton" then
			local openOK, openID = PlaySound(SOUNDKIT_UI_GARRISON_GARRISON_REPORT_OPEN)
			local closeOK, closeID = PlaySound(SOUNDKIT_UI_GARRISON_GARRISON_REPORT_CLOSE)
			self.openSoundID = openOK and openID
			self.closeSoundID = closeOK and closeID
		end
	end)
	_G["GarrisonLandingPageMinimapButton"]:HookScript("OnClick", function(self, b)
		if b == "LeftButton" then
			if _G["GarrisonLandingPage"].garrTypeID ~= C_Garrison_GetLandingPageGarrisonType() then
				ShowLanding(C_Garrison_GetLandingPageGarrisonType())
			end
			return
		elseif b == "RightButton" then
			if (C_Garrison_GetLandingPageGarrisonType() or 0) > 3 then
				if self.landingVisiblePriorToClick then
					ShowLanding(self.landingVisiblePriorToClick)
				else
					HideUIPanel(_G["GarrisonLandingPage"])
				end
				MaybeStopSound(self.openSoundID)
				MaybeStopSound(self.closeSoundID)
				if not landingChoiceMenu then
					landingChoiceMenu = CreateFrame("Frame", "ElvUI_LandingChoicesDropdown", E.UIParent, "UIDropDownMenuTemplate")
					local function ShowLanding_(_, ...)
						return ShowLanding(...)
					end
					landingChoices = {
						{text = GARRISON_LANDING_PAGE_TITLE, func = ShowLanding_, arg1 = 2, notCheckable = true},
						{text = ORDER_HALL_LANDING_PAGE_TITLE, func = ShowLanding_, arg1 = 3, notCheckable = true},
						{text = WAR_CAMPAIGN, func = ShowLanding_, arg1 = C_Garrison_GetLandingPageGarrisonType(), notCheckable = true},
					}
				end
				EasyMenu(landingChoices, landingChoiceMenu, "cursor", 0, 0, "MENU", 4)
				DropDownList1:ClearAllPoints()
				DropDownList1:SetPoint("TOPRIGHT", self, "TOPLEFT", 10, -4)
			elseif GarrisonLandingPage.garrTypeID == 3 then
				ShowLanding(2)
				MaybeStopSound(self.closeSoundID)
			end
		end
	end)
	_G["GarrisonLandingPageMinimapButton"]:HookScript("PostClick", function(self)
		self.closeSoundID, self.openSoundID = nil, nil
	end)
end
