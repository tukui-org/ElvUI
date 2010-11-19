if not TukuiCF["actionbar"].enable == true then return end

---------------------------------------------------------------------------
-- setup MultiBarLeft as bar #3
---------------------------------------------------------------------------

local TukuiBar3 = CreateFrame("Frame","TukuiBar3",TukuiActionBarBackground) -- bottomrightbar
TukuiBar3:SetAllPoints(TukuiActionBarBackground)
MultiBarLeft:SetParent(TukuiBar3)

for i= 1, 12 do
	local b = _G["MultiBarLeftButton"..i]
	local b2 = _G["MultiBarLeftButton"..i-1]
	b:ClearAllPoints()
	if TukuiCF["actionbar"].splitbar ~= true then
		if TukuiCF["actionbar"].rightbars > 1 then
			if i == 1 then
				b:SetPoint("TOPRIGHT", TukuiActionBarBackgroundRight, "TOPRIGHT", -TukuiDB.buttonspacing, -TukuiDB.buttonspacing)
			else
				b:SetPoint("TOP", b2, "BOTTOM", 0, -TukuiDB.buttonspacing)
			end			
		else
			if i == 1 then
				b:SetPoint("TOP", TukuiActionBarBackgroundRight, "TOP", 0, -TukuiDB.buttonspacing)
			else
				b:SetPoint("TOP", b2, "BOTTOM", 0, -TukuiDB.buttonspacing)
			end	
		end
	else
		if TukuiCF.actionbar.bottomrows == 1 then
			if i == 1 then
				b:SetPoint("TOPLEFT", TukuiSplitActionBarLeftBackground, "TOPLEFT", TukuiDB.buttonspacing, -TukuiDB.buttonspacing)
			elseif i > 3 and i < 7 then
				b:Hide()
			elseif i == 7 then
				b:SetPoint("TOPLEFT", TukuiSplitActionBarRightBackground, "TOPLEFT", TukuiDB.buttonspacing, -TukuiDB.buttonspacing)
			elseif i > 9 then
				b:Hide()
			else
				b:SetPoint("LEFT", b2, "RIGHT", TukuiDB.buttonspacing, 0)
			end		
		else
			if i == 1 then
				b:SetPoint("TOPLEFT", TukuiSplitActionBarLeftBackground, "TOPLEFT", TukuiDB.buttonspacing, -TukuiDB.buttonspacing)
			elseif i == 4 then
				b:SetPoint("TOP", _G["MultiBarLeftButton"..i-3], "BOTTOM", 0, -TukuiDB.buttonspacing)
			elseif i == 7 then
				b:SetPoint("TOPLEFT", TukuiSplitActionBarRightBackground, "TOPLEFT", TukuiDB.buttonspacing, -TukuiDB.buttonspacing)
			elseif i == 10 then
				b:SetPoint("TOP", _G["MultiBarLeftButton"..i-3], "BOTTOM", 0, -TukuiDB.buttonspacing)
			else
				b:SetPoint("LEFT", b2, "RIGHT", TukuiDB.buttonspacing, 0)
			end				
		end
	end
end

-- hide it if needed
if ((TukuiCF.actionbar.rightbars < 3 and TukuiCF["actionbar"].splitbar ~= true and TukuiCF.actionbar.bottomrows ~= 3) and not (TukuiCF["actionbar"].splitbar ~= true and TukuiCF["actionbar"].bottomrows == 2 and TukuiCF["actionbar"].rightbars == 2)) or (TukuiCF["actionbar"].bottomrows == 3 and TukuiCF["actionbar"].splitbar ~= true and TukuiCF["actionbar"].rightbars == 0) then
	TukuiBar3:Hide()
end

--Setup Mouseover
if TukuiCF["actionbar"].rightbarmouseover == true and (TukuiCF["actionbar"].splitbar ~= true and TukuiCF.actionbar.bottomrows ~= 3) or (TukuiCF["actionbar"].bottomrows == 3 and TukuiCF["actionbar"].rightbars ~= 0) then
	for i=1, 12 do
		local b = _G["MultiBarLeftButton"..i]
		b:SetAlpha(0)
		b:HookScript("OnEnter", function() RightBarMouseOver(1) end)
		b:HookScript("OnLeave", function() RightBarMouseOver(0) end)
	end
end