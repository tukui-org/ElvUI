local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if not C["actionbar"].enable == true then return end


---------------------------------------------------------------------------
-- setup MultiBarRight as bar #4
---------------------------------------------------------------------------

local ElvuiBar4 = CreateFrame("Frame","ElvuiBar4",ElvuiActionBarBackground) -- bottomrightbar
ElvuiBar4:SetAllPoints(ElvuiActionBarBackground)
MultiBarRight:SetParent(ElvuiBar4)

function E.PositionBar4()
	for i= 1, 12 do
		local b = _G["MultiBarRightButton"..i]
		local b2 = _G["MultiBarRightButton"..i-1]
		b:ClearAllPoints()
		b:SetAlpha(1)
		b:Show()
		
		if E.lowversion ~= true then
			if E["actionbar"].splitbar == true then
				if i == 1 then
					b:SetPoint("BOTTOMLEFT", ElvuiSplitActionBarLeftBackground, "BOTTOMLEFT", E.buttonspacing, E.buttonspacing)
				elseif i == 7 then
					b:SetPoint("BOTTOMLEFT", ElvuiSplitActionBarRightBackground, "BOTTOMLEFT", E.buttonspacing, E.buttonspacing)
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
		else
			if E["actionbar"].splitbar == true and E["actionbar"].bottomrows == 3 then
				if i == 1 then
					b:SetPoint("TOPLEFT", ElvuiSplitActionBarLeftBackground, "TOPLEFT", E.buttonspacing, -E.buttonspacing)
				elseif (i > 1 and i < 5) or (i > 7 and i < 11) then
					b:SetPoint("LEFT", b2, "RIGHT", E.buttonspacing, 0)
				elseif i == 5 or i == 6 or i == 11 or i == 12 then
					b:SetPoint("TOP", b2, "BOTTOM", 0, -E.buttonspacing)
				elseif i == 7 then 
					b:SetPoint("TOPLEFT", ElvuiSplitActionBarRightBackground, "TOPLEFT", E.buttonspacing, -E.buttonspacing)
				end
			else
				if i == 1 then
					b:SetPoint("TOPRIGHT", ElvuiActionBarBackgroundRight, "TOPRIGHT", -E.buttonspacing, -E.buttonspacing)
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
		if E["actionbar"].splitbar == true or E["actionbar"].rightbars > 2 then
			ElvuiBar4:Show()
		else
			ElvuiBar4:Hide()
		end
	else
		if (E["actionbar"].splitbar == true and E["actionbar"].bottomrows == 3) or E["actionbar"].rightbars > 0 then
			ElvuiBar4:Show()
		else
			ElvuiBar4:Hide()
		end	
	end
end
