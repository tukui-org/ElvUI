if not ElvCF["actionbar"].enable == true then return end
local ElvDB = ElvDB
local ElvCF = ElvCF

---------------------------------------------------------------------------
-- setup MultiBarBottomLeft as bar #2
---------------------------------------------------------------------------

local ElvuiBar2 = CreateFrame("Frame","ElvuiBar2",ElvuiActionBarBackground)
ElvuiBar2:SetAllPoints(ElvuiActionBarBackground)
MultiBarBottomLeft:SetParent(ElvuiBar2)

function PositionBar2()
	for i=1, 12 do
		local b = _G["MultiBarBottomLeftButton"..i]
		local b2 = _G["MultiBarBottomLeftButton"..i-1]
		b:ClearAllPoints()
		if i == 1 then
			if ElvCF["actionbar"].swaptopbottombar == true then
				b:SetPoint("TOP", ActionButton1, "BOTTOM", 0, -ElvDB.buttonspacing)
			else
				b:SetPoint("BOTTOM", ActionButton1, "TOP", 0, ElvDB.buttonspacing)
			end
		else
			b:SetPoint("LEFT", b2, "RIGHT", ElvDB.buttonspacing, 0)
		end
	end
	-- hide it if needed
	if ElvCF.actionbar.bottomrows == 1 then
		ElvuiBar2:Hide()
	else
		ElvuiBar2:Show()
	end
end

do
	PositionBar2()
end