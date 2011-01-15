if not ElvCF["actionbar"].enable == true then return end
local ElvDB = ElvDB
local ElvCF = ElvCF

---------------------------------------------------------------------------
-- setup MultiBarBottomRight as bar #5
---------------------------------------------------------------------------

local ElvuiBar5 = CreateFrame("Frame","ElvuiBar5",ElvuiActionBarBackground) -- MultiBarBottomRight
ElvuiBar5:SetAllPoints(ElvuiActionBarBackground)
MultiBarBottomRight:SetParent(ElvuiBar5)

function PositionBar5()
	for i=1, 12 do
		local b = _G["MultiBarBottomRightButton"..i]
		local b2 = _G["MultiBarBottomRightButton"..i-1]
		b:ClearAllPoints()
		b:SetAlpha(1)
		b:Show()
		if ElvCF["actionbar"].rightbars > 1 then
			if i == 1 then
				b:SetPoint("TOPLEFT", ElvuiActionBarBackgroundRight, "TOPLEFT", ElvDB.buttonspacing, -ElvDB.buttonspacing)
			else
				b:SetPoint("TOP", b2, "BOTTOM", 0, -ElvDB.buttonspacing)
			end
		elseif ElvCF["actionbar"].bottomrows == 3 and ElvCF["actionbar"].splitbar == true then
			if i == 1 then
				b:SetPoint("TOP", MultiBarLeftButton4, "BOTTOM", 0, -ElvDB.buttonspacing)
			elseif i < 4 then
				b:SetPoint("LEFT", b2, "RIGHT", ElvDB.buttonspacing, 0)
			elseif i == 4 then
				b:SetPoint("TOP", MultiBarLeftButton10, "BOTTOM", 0, -ElvDB.buttonspacing)
			elseif i > 4 and i < 7 then
				b:SetPoint("LEFT", b2, "RIGHT", ElvDB.buttonspacing, 0)
			elseif i == 7 then
				b:SetPoint("RIGHT", MultiBarLeftButton1, "LEFT", -ElvDB.buttonspacing, 0)
			elseif i > 7 and i < 10 then
				b:SetPoint("TOP", b2, "BOTTOM", 0, -ElvDB.buttonspacing)
			elseif i == 10 then
				b:SetPoint("LEFT", MultiBarLeftButton9, "RIGHT", ElvDB.buttonspacing, 0)
			elseif i > 10 then
				b:SetPoint("TOP", b2, "BOTTOM", 0, -ElvDB.buttonspacing)
			else
				b:Hide()
			end
		end
		--Setup Mouseover
		if ElvCF["actionbar"].rightbarmouseover == true and not (ElvCF.actionbar.bottomrows == 3) then
			b:SetAlpha(0)
			b:HookScript("OnEnter", function() RightBarMouseOver(1) end)
			b:HookScript("OnLeave", function() RightBarMouseOver(0) end)
		end
	end

	-- hide it if needed
	if not ((ElvCF["actionbar"].rightbars > 1) or (ElvCF["actionbar"].bottomrows == 3 and ElvCF["actionbar"].splitbar == true)) then
		ElvuiBar5:Hide()
	else
		ElvuiBar5:Show()
	end
end

do
	PositionBar5()
end

