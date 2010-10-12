if not TukuiCF["actionbar"].enable == true then return end

---------------------------------------------------------------------------
-- setup MultiBarRight as bar #4
---------------------------------------------------------------------------

local TukuiBar4 = CreateFrame("Frame","TukuiBar4",UIParent) -- bottomrightbar
TukuiBar4:SetAllPoints(TukuiActionBarBackground)
MultiBarRight:SetParent(TukuiBar4)

for i= 1, 12 do
	local b = _G["MultiBarRightButton"..i]
	local b2 = _G["MultiBarRightButton"..i-1]
	b:ClearAllPoints()
	if i == 1 then
		b:SetPoint("TOPRIGHT", TukuiActionBarBackgroundRight, "TOPRIGHT", TukuiDB.Scale(-4), TukuiDB.Scale(-4))
	else
		b:SetPoint("TOP", b2, "BOTTOM", 0, -TukuiDB.buttonspacing)
	end	
end

-- hide it if needed
if TukuiCF.actionbar.rightbars < 1 then
	TukuiBar4:Hide()
end