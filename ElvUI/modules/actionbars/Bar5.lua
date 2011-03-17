local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if not C["actionbar"].enable == true then return end


---------------------------------------------------------------------------
-- setup MultiBarBottomRight as bar #5
---------------------------------------------------------------------------

local ElvuiBar5 = CreateFrame("Frame","ElvuiBar5",ElvuiActionBarBackground) -- MultiBarBottomRight
ElvuiBar5:SetAllPoints(ElvuiActionBarBackground)
MultiBarBottomRight:SetParent(ElvuiBar5)

function E.PositionBar5()
	for i= 1, 12 do
		local b = _G["MultiBarBottomRightButton"..i]
		local b2 = _G["MultiBarBottomRightButton"..i-1]
		b:ClearAllPoints()
		b:SetAlpha(1)
		b:Show()
		
		if E.lowversion ~= true then
			if E["actionbar"].splitbar == true and E["actionbar"].bottomrows == 2 then
				if i == 1 then
					b:SetPoint("TOPLEFT", ElvuiSplitActionBarLeftBackground, "TOPLEFT", E.buttonspacing, -E.buttonspacing)
				elseif i == 7 then
					b:SetPoint("TOPLEFT", ElvuiSplitActionBarRightBackground, "TOPLEFT", E.buttonspacing, -E.buttonspacing)
				else
					b:SetPoint("LEFT", b2, "RIGHT", E.buttonspacing, 0)
				end
			else
				if i == 1 then
					b:SetPoint("TOPRIGHT", MultiBarLeftButton1, "TOPLEFT", -E.buttonspacing, 0)
				else
					b:SetPoint("TOP", b2, "BOTTOM", 0, -E.buttonspacing)
				end
			
				if C["actionbar"].rightbarmouseover == true then
					b:SetAlpha(0)
					b:HookScript("OnEnter", function() RightBarMouseOver(1) end)
					b:HookScript("OnLeave", function() RightBarMouseOver(0) end)			
				end						
			end
		else
			if E["actionbar"].splitbar == true and E["actionbar"].bottomrows == 3 then
				if C["actionbar"].swaptopbottombar == true and i == 1 then
					b:SetPoint("TOP", MultiBarBottomLeftButton1, "BOTTOM", 0, -E.buttonspacing)
				elseif i == 1 then
					b:SetPoint("BOTTOM", MultiBarBottomLeftButton1, "TOP", 0, E.buttonspacing)
				else
					b:SetPoint("LEFT", b2, "RIGHT", E.buttonspacing, 0)
				end
			else
				if i == 1 then
					b:SetPoint("TOPLEFT", ElvuiActionBarBackgroundRight, "TOPLEFT", E.buttonspacing, -E.buttonspacing)
				else
					b:SetPoint("TOP", b2, "BOTTOM", 0, -E.buttonspacing)
				end
				
				if C["actionbar"].rightbarmouseover == true then
					b:SetAlpha(0)
					b:HookScript("OnEnter", function() RightBarMouseOver(1) end)
					b:HookScript("OnLeave", function() RightBarMouseOver(0) end)			
				end			
			end
		end

	end

	-- hide it if needed
	if E.lowversion ~= true then
		if (E["actionbar"].splitbar == true and E["actionbar"].bottomrows == 2) or E["actionbar"].rightbars > 1 then
			ElvuiBar5:Show()
		else
			ElvuiBar5:Hide()
		end
	else
		if (E["actionbar"].splitbar == true and E["actionbar"].bottomrows == 3) or E["actionbar"].rightbars > 1 then
			ElvuiBar5:Show()
		else
			ElvuiBar5:Hide()
		end	
	end
end


