local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

-- BG TINY MAP (BG, mining, etc)
local tinymap = CreateFrame("Frame", "ElvuiTinyMapMover", UIParent)
tinymap:SetPoint("CENTER")
tinymap:SetSize(223, 150)
tinymap:EnableMouse(true)
tinymap:SetMovable(true)
tinymap:RegisterEvent("ADDON_LOADED")
tinymap:SetPoint("CENTER", UIParent, 0, 0)
tinymap:SetFrameLevel(20)
tinymap:Hide()

-- create minimap background
local tinymapbg = CreateFrame("Frame", nil, tinymap)
tinymapbg:SetAllPoints()
tinymapbg:SetFrameLevel(tinymap:GetFrameLevel() - 10)
tinymapbg:SetTemplate("Default")

tinymap:SetScript("OnEvent", function(self, event, addon)
	if addon ~= "Blizzard_BattlefieldMinimap" then return end

	BattlefieldMinimap:SetScript("OnShow", function(self)
		-- show holder
		tinymap:Show()
		BattlefieldMinimapCorner:Kill()
		BattlefieldMinimapBackground:Kill()
		BattlefieldMinimapTab:Kill()
		BattlefieldMinimapTabLeft:Kill()
		BattlefieldMinimapTabMiddle:Kill()
		BattlefieldMinimapTabRight:Kill()
		self:SetParent(tinymap)
		self:SetPoint("TOPLEFT", tinymap, "TOPLEFT", 2, -2)
		self:SetFrameStrata(tinymap:GetFrameStrata())
		self:SetFrameLevel(tinymap:GetFrameLevel() + 1)
		BattlefieldMinimapCloseButton:ClearAllPoints()
		BattlefieldMinimapCloseButton:SetPoint("TOPRIGHT", -4, 0)
		BattlefieldMinimapCloseButton:SetFrameLevel(tinymap:GetFrameLevel() + 1)
		tinymap:SetScale(1)
		tinymap:SetAlpha(1)
	end)

	BattlefieldMinimap:SetScript("OnHide", function(self)
		tinymap:SetScale(0.00001)
		tinymap:SetAlpha(0)
	end)

	tinymap:SetScript("OnMouseUp", function(self, btn)
		if btn == "LeftButton" then
			self:StopMovingOrSizing()
			if OpacityFrame:IsShown() then OpacityFrame:Hide() end -- seem to be a bug with default ui in 4.0, we hide it on next click
		elseif btn == "RightButton" then
			ToggleDropDownMenu(1, nil, BattlefieldMinimapTabDropDown, self:GetName(), 0, -4)
			if OpacityFrame:IsShown() then OpacityFrame:Hide() end -- seem to be a bug with default ui in 4.0, we hide it on next click
		end
	end)

	tinymap:SetScript("OnMouseDown", function(self, btn)
		if btn == "LeftButton" then
			if BattlefieldMinimapOptions and BattlefieldMinimapOptions.locked then
				return
			else
				self:StartMoving()
			end
		end
	end)
end)