if not TukuiCF["actionbar"].enable == true then return end

---------------------------------------------------------------------------
-- setup MultiBarRight as bar #4
---------------------------------------------------------------------------

local TukuiBar4 = CreateFrame("Frame","TukuiBar4",TukuiActionBarBackground) -- bottomrightbar
TukuiBar4:SetAllPoints(TukuiActionBarBackground)
MultiBarRight:SetParent(TukuiBar4)

for i= 1, 12 do
	local b = _G["MultiBarRightButton"..i]
	local b2 = _G["MultiBarRightButton"..i-1]
	b:ClearAllPoints()
	if TukuiCF.actionbar.bottomrows == 3 then
		if i == 1 then
			if TukuiCF["actionbar"].swaptopbottombar == true then
				b:SetPoint("TOP", MultiBarBottomLeftButton1, "BOTTOM", 0, -TukuiDB.buttonspacing)
			else
				b:SetPoint("BOTTOM", MultiBarBottomLeftButton1, "TOP", 0, TukuiDB.buttonspacing)
			end
		else
			b:SetPoint("LEFT", b2, "RIGHT", TukuiDB.buttonspacing, 0)
		end
	elseif TukuiCF.actionbar.bottomrows ~= 3 and TukuiCF.actionbar.rightbars > 1 then
		if i == 1 then
			if TukuiCF.actionbar.rightbars == 2 then
				b:SetPoint("TOPRIGHT", TukuiActionBarBackgroundRight, "TOPRIGHT", -TukuiDB.buttonspacing, -TukuiDB.buttonspacing)
			else
				b:SetPoint("TOP", TukuiActionBarBackgroundRight, "TOP", 0, -TukuiDB.buttonspacing)
			end
		else
			b:SetPoint("TOP", b2, "BOTTOM", 0, -TukuiDB.buttonspacing)
		end		
	else
		if i == 1 then
			b:SetPoint("TOPRIGHT", TukuiActionBarBackgroundRight, "TOPRIGHT", -TukuiDB.buttonspacing, -TukuiDB.buttonspacing)
		else
			b:SetPoint("TOP", b2, "BOTTOM", 0, -TukuiDB.buttonspacing)
		end	
	end
end

-- hide it if needed
if TukuiCF.actionbar.rightbars < 1 and not (((TukuiCF.actionbar.bottomrows == 3) or (TukuiCF.actionbar.bottomrows ~= 3 and TukuiCF.actionbar.rightbars > 1)) or (TukuiCF["actionbar"].bottomrows == 2 and TukuiCF["actionbar"].rightbars == 2) or (TukuiCF["actionbar"].rightbar == 2 and TukuiCF["actionbar"].bottomrows > 1 and TukuiCF["actionbar"].splitbar == true)) then
	TukuiBar4:Hide()
end

--Setup Mouseover
if TukuiCF["actionbar"].rightbarmouseover == true and not (TukuiCF.actionbar.bottomrows == 3) then
	for i=1, 12 do
		local b = _G["MultiBarRightButton"..i]
		b:SetAlpha(0)
		b:HookScript("OnEnter", function() RightBarMouseOver(1) end)
		b:HookScript("OnLeave", function() RightBarMouseOver(0) end)
	end
end