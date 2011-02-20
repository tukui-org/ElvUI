local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if not C["actionbar"].enable == true then return end


---------------------------------------------------------------------------
-- setup MultiBarRight as bar #4
---------------------------------------------------------------------------

local ElvuiBar4 = CreateFrame("Frame","ElvuiBar4",ElvuiActionBarBackground) -- bottomrightbar
ElvuiBar4:SetAllPoints(ElvuiActionBarBackground)
MultiBarRight:SetParent(ElvuiBar4)

local ElvuiBar4Split = CreateFrame("Frame", nil, ElvuiBar4)

function E.PositionBar4()
	ElvuiBar4Split:Show()
	for i= 1, 12 do
		local b = _G["MultiBarRightButton"..i]
		local b2 = _G["MultiBarRightButton"..i-1]
		b:ClearAllPoints()
		b:SetAlpha(1)
		b:SetParent(MultiBarRight)
		b:Show()
		
		if E.lowversion ~= true then
			if E.actionbar.bottomrows == 1 and i > 6 then 
				b:SetParent(ElvuiBar4Split)
				ElvuiBar4Split:Hide()				
			end
			
			if i == 1 then
				b:SetPoint("BOTTOMLEFT", ElvuiSplitActionBarLeftBackground, "BOTTOMLEFT", E.buttonspacing, E.buttonspacing)
			elseif i == 7 then
				b:SetPoint("BOTTOM", MultiBarRightButton1, "TOP", 0, E.buttonspacing)
			else
				b:SetPoint("LEFT", b2, "RIGHT", E.buttonspacing, 0)
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

	-- hide it if needed
	if E.lowversion ~= true then
		if E["actionbar"].splitbar ~= true then
			ElvuiBar4:Hide()
		else
			ElvuiBar4:Show()
		end
	else
		ElvuiBar4:SetParent(ElvuiActionBarBackgroundRight)
		if E["actionbar"].rightbars > 0 then
			ElvuiBar4:Show()
		else
			ElvuiBar4:Hide()
		end	
	end
end
