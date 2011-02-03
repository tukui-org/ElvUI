local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if not C["actionbar"].enable == true then return end


---------------------------------------------------------------------------
-- setup MultiBarLeft as bar #3
---------------------------------------------------------------------------

local ElvuiBar3 = CreateFrame("Frame","ElvuiBar3",ElvuiActionBarBackground) -- bottomrightbar
ElvuiBar3:SetAllPoints(ElvuiActionBarBackground)
MultiBarLeft:SetParent(ElvuiBar3)


--Some event fires when sheathing/unsheathing weapon that forces a show on actionbuttons, setting the parent to this frame temporarily when splitbars is applied to fix
local ElvuiBar3Split = CreateFrame("Frame", "ElvuiBarSplit1", ElvuiBar3)
ElvuiBar3Split:SetAllPoints(ElvuiActionBarBackground)


function E.PositionBar3()
	for i= 1, 12 do
		local b = _G["MultiBarLeftButton"..i]
		local b2 = _G["MultiBarLeftButton"..i-1]
		b:ClearAllPoints()
		b:SetParent(MultiBarLeft)
		b:Show()
		b:SetAlpha(1)
		if E["actionbar"].splitbar ~= true then
			if E["actionbar"].rightbars > 1 then
				if i == 1 then
					b:SetPoint("TOPRIGHT", ElvuiActionBarBackgroundRight, "TOPRIGHT", -E.buttonspacing, -E.buttonspacing)
				else
					b:SetPoint("TOP", b2, "BOTTOM", 0, -E.buttonspacing)
				end			
			else
				if i == 1 then
					b:SetPoint("TOP", ElvuiActionBarBackgroundRight, "TOP", 0, -E.buttonspacing)
				else
					b:SetPoint("TOP", b2, "BOTTOM", 0, -E.buttonspacing)
				end	
			end
		else
			if E.actionbar.bottomrows == 1 then
				if i == 1 then
					b:SetPoint("TOPLEFT", ElvuiSplitActionBarLeftBackground, "TOPLEFT", E.buttonspacing, -E.buttonspacing)
				elseif i > 3 and i < 7 then
					b:SetParent(ElvuiBar3Split)
				elseif i == 7 then
					b:SetPoint("TOPLEFT", ElvuiSplitActionBarRightBackground, "TOPLEFT", E.buttonspacing, -E.buttonspacing)
				elseif i > 9 then
					b:SetParent(ElvuiBar3Split)
					ElvuiBar3Split:Hide()
				else
					b:SetPoint("LEFT", b2, "RIGHT", E.buttonspacing, 0)
				end		
			elseif E.actionbar.bottomrows == 2 then
				if i == 1 then
					b:SetPoint("TOPLEFT", ElvuiSplitActionBarLeftBackground, "TOPLEFT", E.buttonspacing, -E.buttonspacing)
				elseif i == 4 then
					b:SetPoint("TOP", _G["MultiBarLeftButton"..i-3], "BOTTOM", 0, -E.buttonspacing)
				elseif i == 7 then
					b:SetPoint("TOPLEFT", ElvuiSplitActionBarRightBackground, "TOPLEFT", E.buttonspacing, -E.buttonspacing)
				elseif i == 10 then
					b:SetPoint("TOP", _G["MultiBarLeftButton"..i-3], "BOTTOM", 0, -E.buttonspacing)
				else
					b:SetPoint("LEFT", b2, "RIGHT", E.buttonspacing, 0)
				end	
			else
				if i == 1 then
					b:SetPoint("TOPLEFT", ElvuiSplitActionBarLeftBackground, "TOPLEFT", (E.buttonsize * 1) + (E.buttonspacing * 2), -E.buttonspacing)
				elseif i == 4 then
					b:SetPoint("TOP", _G["MultiBarLeftButton"..i-3], "BOTTOM", 0, -E.buttonspacing)
				elseif i == 7 then
					b:SetPoint("TOPLEFT", ElvuiSplitActionBarRightBackground, "TOPLEFT", E.buttonspacing, -E.buttonspacing)
				elseif i == 10 then
					b:SetPoint("TOP", _G["MultiBarLeftButton"..i-3], "BOTTOM", 0, -E.buttonspacing)
				else
					b:SetPoint("LEFT", b2, "RIGHT", E.buttonspacing, 0)
				end  		
			end
		end
		--Setup Mouseover
		if C["actionbar"].rightbarmouseover == true and not (E.actionbar.bottomrows == 3) and E["actionbar"].splitbar ~= true then
			b:SetAlpha(0)
			b:HookScript("OnEnter", function() 
				if not (E.actionbar.bottomrows == 3) and E["actionbar"].splitbar ~= true then
					RightBarMouseOver(1) 
				end
			end)
			b:HookScript("OnLeave", function() 
				if not (E.actionbar.bottomrows == 3) and E["actionbar"].splitbar ~= true then
					RightBarMouseOver(0) 
				end
			end)
		end
	end

	-- hide it if needed
	if ((E.actionbar.rightbars < 3 and E["actionbar"].splitbar ~= true and E.actionbar.bottomrows ~= 3) and not 
	(E["actionbar"].splitbar ~= true and E["actionbar"].bottomrows == 2 and E["actionbar"].rightbars == 2)) or 
	(E["actionbar"].bottomrows == 3 and E["actionbar"].splitbar ~= true and E["actionbar"].rightbars == 0) then
		ElvuiBar3:Hide()
	else
		ElvuiBar3:Show()
	end
end