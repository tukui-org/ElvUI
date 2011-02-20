local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if not C["actionbar"].enable == true then return end


---------------------------------------------------------------------------
-- setup MultiBarLeft as bar #3
---------------------------------------------------------------------------

local ElvuiBar3 = CreateFrame("Frame","ElvuiBar3",ElvuiActionBarBackground) -- bottomrightbar
ElvuiBar3:SetAllPoints(ElvuiActionBarBackground)
MultiBarLeft:SetParent(ElvuiBar3)

function E.PositionBar3()
	for i= 1, 12 do
		local b = _G["MultiBarLeftButton"..i]
		local b2 = _G["MultiBarLeftButton"..i-1]
		b:ClearAllPoints()
		b:Show()
		b:SetAlpha(1)

		if E.lowversion ~= true then
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
		else
			if C["actionbar"].swaptopbottombar == true and i == 1 and E["actionbar"].bottomrows > 1 then
				b:SetPoint("BOTTOM", ActionButton1, "TOP", 0, E.buttonspacing)
			elseif i == 1 then
				b:SetPoint("BOTTOM", MultiBarBottomLeftButton1, "TOP", 0, E.buttonspacing)
			else
				b:SetPoint("LEFT", b2, "RIGHT", E.buttonspacing, 0)
			end
		end
	
	end
	
	-- hide it if needed
	if E.lowversion ~= true then
		if E["actionbar"].rightbars > 0 then
			ElvuiBar3:Show()
		else
			ElvuiBar3:Hide()
		end	
	else
		ElvuiBar3:SetParent(ElvuiActionBarBackgroundRight)
		if E["actionbar"].bottomrows == 3 then
			ElvuiBar3:Show()
		else
			ElvuiBar3:Hide()
		end
	end	
end