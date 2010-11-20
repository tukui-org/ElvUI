if not TukuiCF["actionbar"].enable == true then return end

---------------------------------------------------------------------------
-- setup MultiBarBottomRight as bar #5
---------------------------------------------------------------------------

local TukuiBar5 = CreateFrame("Frame","TukuiBar5",TukuiActionBarBackground) -- MultiBarBottomRight
TukuiBar5:SetAllPoints(TukuiActionBarBackground)
MultiBarBottomRight:SetParent(TukuiBar5)

for i=1, 12 do
	local b = _G["MultiBarBottomRightButton"..i]
	local b2 = _G["MultiBarBottomRightButton"..i-1]
	b:ClearAllPoints()
	if TukuiCF["actionbar"].rightbars > 1 then
		if i == 1 then
			b:SetPoint("TOPLEFT", TukuiActionBarBackgroundRight, "TOPLEFT", TukuiDB.buttonspacing, -TukuiDB.buttonspacing)
		else
			b:SetPoint("TOP", b2, "BOTTOM", 0, -TukuiDB.buttonspacing)
		end
	elseif TukuiCF["actionbar"].bottomrows == 3 and TukuiCF["actionbar"].splitbar == true then
		if i == 1 then
			b:SetPoint("TOP", MultiBarLeftButton4, "BOTTOM", 0, -TukuiDB.buttonspacing)
		elseif i < 4 then
			b:SetPoint("LEFT", b2, "RIGHT", TukuiDB.buttonspacing, 0)
		elseif i == 4 then
			b:SetPoint("TOP", MultiBarLeftButton10, "BOTTOM", 0, -TukuiDB.buttonspacing)
		elseif i > 4 and i < 7 then
			b:SetPoint("LEFT", b2, "RIGHT", TukuiDB.buttonspacing, 0)
		elseif i == 7 then
			b:SetPoint("RIGHT", MultiBarLeftButton1, "LEFT", -TukuiDB.buttonspacing, 0)
		elseif i > 7 and i < 10 then
			b:SetPoint("TOP", b2, "BOTTOM", 0, -TukuiDB.buttonspacing)
		elseif i == 10 then
			b:SetPoint("LEFT", MultiBarLeftButton9, "RIGHT", TukuiDB.buttonspacing, 0)
		elseif i > 10 then
			b:SetPoint("TOP", b2, "BOTTOM", 0, -TukuiDB.buttonspacing)
		else
			b:Hide()
		end
	end
end

-- hide it if needed
if not ((TukuiCF["actionbar"].rightbars > 1) or (TukuiCF["actionbar"].bottomrows == 3 and TukuiCF["actionbar"].splitbar == true)) then
	TukuiBar5:Hide()
end

--Setup Mouseover
if TukuiCF["actionbar"].rightbarmouseover == true then 
	if (not TukuiCF["actionbar"].bottomrows == 3 and TukuiCF["actionbar"].splitbar == true) or (TukuiCF["actionbar"].bottomrows == 3 and TukuiCF["actionbar"].rightbars == 2 and TukuiCF["actionbar"].splitbar ~= true) or (TukuiCF["actionbar"].rightbars > 1) then
		for i=1, 12 do
			local b = _G["MultiBarBottomRightButton"..i]
			b:SetAlpha(0)
			b:HookScript("OnEnter", function() RightBarMouseOver(1) end)
			b:HookScript("OnLeave", function() RightBarMouseOver(0) end)
		end
	end
end