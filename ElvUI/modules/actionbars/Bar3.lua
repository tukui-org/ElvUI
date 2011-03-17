local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if not C["actionbar"].enable == true then return end


---------------------------------------------------------------------------
-- setup MultiBarLeft as bar #3
---------------------------------------------------------------------------

local ElvuiBar3 = CreateFrame("Frame","ElvuiBar3",ElvuiActionBarBackground) -- bottomrightbar
ElvuiBar3:SetAllPoints(ElvuiActionBarBackground)
MultiBarLeft:SetParent(ElvuiBar3)

local ElvuiBar3Split = CreateFrame("Frame", nil, ElvuiBar3)

function E.PositionBar3()
	ElvuiBar3Split:Show()
	for i= 1, 12 do
		local b = _G["MultiBarLeftButton"..i]
		local b2 = _G["MultiBarLeftButton"..i-1]
		b:ClearAllPoints()
		b:Show()
		b:SetParent(MultiBarLeft)
		b:SetAlpha(1)
		if E.lowversion ~= true then
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
		else
			if E["actionbar"].splitbar ~= true and E["actionbar"].bottomrows == 3 then
				if C["actionbar"].swaptopbottombar == true and i == 1 then
					b:SetPoint("TOP", MultiBarBottomLeftButton1, "BOTTOM", 0, -E.buttonspacing)
				elseif i == 1 then
					b:SetPoint("BOTTOM", MultiBarBottomLeftButton1, "TOP", 0, E.buttonspacing)
				else
					b:SetPoint("LEFT", b2, "RIGHT", E.buttonspacing, 0)
				end
			else
				if i > 6 and E["actionbar"].bottomrows == 1 then
					b:Hide()
					b:SetParent(ElvuiBar3Split)
					ElvuiBar3Split:Hide()
				end
				
				if i == 1 then
					b:SetPoint("BOTTOMLEFT", ElvuiSplitActionBarLeftBackground, "BOTTOMLEFT", E.buttonspacing, E.buttonspacing)
				elseif i == 4 then
					b:SetPoint("BOTTOMLEFT", ElvuiSplitActionBarRightBackground, "BOTTOMLEFT", E.buttonspacing, E.buttonspacing)
				elseif i == 7 then
					b:SetPoint("BOTTOM", MultiBarLeftButton1, "TOP", 0, E.buttonspacing)
				elseif i == 10 then
					b:SetPoint("BOTTOM", MultiBarLeftButton4, "TOP", 0, E.buttonspacing)
				else
					b:SetPoint("LEFT", b2, "RIGHT", E.buttonspacing, 0)
				end
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
		if E["actionbar"].bottomrows ~= 3 and E["actionbar"].splitbar ~= true then
			ElvuiBar3:Hide()
		else
			ElvuiBar3:Show()
		end
	end	
end