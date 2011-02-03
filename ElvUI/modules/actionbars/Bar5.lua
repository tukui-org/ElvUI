local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if not C["actionbar"].enable == true then return end


---------------------------------------------------------------------------
-- setup MultiBarBottomRight as bar #5
---------------------------------------------------------------------------

local ElvuiBar5 = CreateFrame("Frame","ElvuiBar5",ElvuiActionBarBackground) -- MultiBarBottomRight
ElvuiBar5:SetAllPoints(ElvuiActionBarBackground)
MultiBarBottomRight:SetParent(ElvuiBar5)

function E.PositionBar5()
	for i=1, 12 do
		local b = _G["MultiBarBottomRightButton"..i]
		local b2 = _G["MultiBarBottomRightButton"..i-1]
		b:ClearAllPoints()
		b:SetAlpha(1)
		b:Show()
		if E["actionbar"].rightbars > 1 then
			if i == 1 then
				b:SetPoint("TOPLEFT", ElvuiActionBarBackgroundRight, "TOPLEFT", E.buttonspacing, -E.buttonspacing)
			else
				b:SetPoint("TOP", b2, "BOTTOM", 0, -E.buttonspacing)
			end
		elseif E["actionbar"].bottomrows == 3 and E["actionbar"].splitbar == true then
			if i == 1 then
				b:SetPoint("TOP", MultiBarLeftButton4, "BOTTOM", 0, -E.buttonspacing)
			elseif i < 4 then
				b:SetPoint("LEFT", b2, "RIGHT", E.buttonspacing, 0)
			elseif i == 4 then
				b:SetPoint("TOP", MultiBarLeftButton10, "BOTTOM", 0, -E.buttonspacing)
			elseif i > 4 and i < 7 then
				b:SetPoint("LEFT", b2, "RIGHT", E.buttonspacing, 0)
			elseif i == 7 then
				b:SetPoint("RIGHT", MultiBarLeftButton1, "LEFT", -E.buttonspacing, 0)
			elseif i > 7 and i < 10 then
				b:SetPoint("TOP", b2, "BOTTOM", 0, -E.buttonspacing)
			elseif i == 10 then
				b:SetPoint("LEFT", MultiBarLeftButton9, "RIGHT", E.buttonspacing, 0)
			elseif i > 10 then
				b:SetPoint("TOP", b2, "BOTTOM", 0, -E.buttonspacing)
			else
				b:Hide()
			end
		end
		--Setup Mouseover
		if C["actionbar"].rightbarmouseover == true and not (E.actionbar.bottomrows == 3) then
			b:SetAlpha(0)
			b:HookScript("OnEnter", function() RightBarMouseOver(1) end)
			b:HookScript("OnLeave", function() RightBarMouseOver(0) end)
		end
	end

	-- hide it if needed
	if not ((E["actionbar"].rightbars > 1) or (E["actionbar"].bottomrows == 3 and E["actionbar"].splitbar == true)) then
		ElvuiBar5:Hide()
	else
		ElvuiBar5:Show()
	end
end


