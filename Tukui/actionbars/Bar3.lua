if not TukuiCF["actionbar"].enable == true then return end

---------------------------------------------------------------------------
-- setup MultiBarLeft as bar #3
---------------------------------------------------------------------------

local TukuiBar3 = CreateFrame("Frame","TukuiBar3",TukuiActionBarBackground) -- bottomrightbar
TukuiBar3:SetAllPoints(TukuiActionBarBackground)
MultiBarLeft:SetParent(TukuiBar3)


--Some event fires when sheathing/unsheathing weapon that forces a show on actionbuttons, setting the parent to this frame temporarily when splitbars is applied to fix
local TukuiBar3Split = CreateFrame("Frame", "TukuiBarSplit1", TukuiBar3)
TukuiBar3Split:SetAllPoints(TukuiActionBarBackground)


function PositionBar3()
	for i= 1, 12 do
		local b = _G["MultiBarLeftButton"..i]
		local b2 = _G["MultiBarLeftButton"..i-1]
		b:ClearAllPoints()
		b:SetParent(MultiBarLeft)
		b:Show()
		b:SetAlpha(1)
		if TukuiCF["actionbar"].splitbar ~= true then
			if TukuiCF["actionbar"].rightbars > 1 then
				if i == 1 then
					b:SetPoint("TOPRIGHT", TukuiActionBarBackgroundRight, "TOPRIGHT", -TukuiDB.buttonspacing, -TukuiDB.buttonspacing)
				else
					b:SetPoint("TOP", b2, "BOTTOM", 0, -TukuiDB.buttonspacing)
				end			
			else
				if i == 1 then
					b:SetPoint("TOP", TukuiActionBarBackgroundRight, "TOP", 0, -TukuiDB.buttonspacing)
				else
					b:SetPoint("TOP", b2, "BOTTOM", 0, -TukuiDB.buttonspacing)
				end	
			end
		else
			if TukuiCF.actionbar.bottomrows == 1 then
				if i == 1 then
					b:SetPoint("TOPLEFT", TukuiSplitActionBarLeftBackground, "TOPLEFT", TukuiDB.buttonspacing, -TukuiDB.buttonspacing)
				elseif i > 3 and i < 7 then
					b:SetParent(TukuiBar3Split)
				elseif i == 7 then
					b:SetPoint("TOPLEFT", TukuiSplitActionBarRightBackground, "TOPLEFT", TukuiDB.buttonspacing, -TukuiDB.buttonspacing)
				elseif i > 9 then
					b:SetParent(TukuiBar3Split)
					TukuiBar3Split:Hide()
				else
					b:SetPoint("LEFT", b2, "RIGHT", TukuiDB.buttonspacing, 0)
				end		
			elseif TukuiCF.actionbar.bottomrows == 2 then
				if i == 1 then
					b:SetPoint("TOPLEFT", TukuiSplitActionBarLeftBackground, "TOPLEFT", TukuiDB.buttonspacing, -TukuiDB.buttonspacing)
				elseif i == 4 then
					b:SetPoint("TOP", _G["MultiBarLeftButton"..i-3], "BOTTOM", 0, -TukuiDB.buttonspacing)
				elseif i == 7 then
					b:SetPoint("TOPLEFT", TukuiSplitActionBarRightBackground, "TOPLEFT", TukuiDB.buttonspacing, -TukuiDB.buttonspacing)
				elseif i == 10 then
					b:SetPoint("TOP", _G["MultiBarLeftButton"..i-3], "BOTTOM", 0, -TukuiDB.buttonspacing)
				else
					b:SetPoint("LEFT", b2, "RIGHT", TukuiDB.buttonspacing, 0)
				end	
			else
				if i == 1 then
					b:SetPoint("TOPLEFT", TukuiSplitActionBarLeftBackground, "TOPLEFT", (TukuiDB.buttonsize * 1) + (TukuiDB.buttonspacing * 2), -TukuiDB.buttonspacing)
				elseif i == 4 then
					b:SetPoint("TOP", _G["MultiBarLeftButton"..i-3], "BOTTOM", 0, -TukuiDB.buttonspacing)
				elseif i == 7 then
					b:SetPoint("TOPLEFT", TukuiSplitActionBarRightBackground, "TOPLEFT", TukuiDB.buttonspacing, -TukuiDB.buttonspacing)
				elseif i == 10 then
					b:SetPoint("TOP", _G["MultiBarLeftButton"..i-3], "BOTTOM", 0, -TukuiDB.buttonspacing)
				else
					b:SetPoint("LEFT", b2, "RIGHT", TukuiDB.buttonspacing, 0)
				end  		
			end
		end
		--Setup Mouseover
		if TukuiCF["actionbar"].rightbarmouseover == true and not (TukuiCF.actionbar.bottomrows == 3) and TukuiCF["actionbar"].splitbar ~= true then
			b:SetAlpha(0)
			b:HookScript("OnEnter", function() 
				if not (TukuiCF.actionbar.bottomrows == 3) and TukuiCF["actionbar"].splitbar ~= true then
					RightBarMouseOver(1) 
				end
			end)
			b:HookScript("OnLeave", function() 
				if not (TukuiCF.actionbar.bottomrows == 3) and TukuiCF["actionbar"].splitbar ~= true then
					RightBarMouseOver(0) 
				end
			end)
		end
	end

	-- hide it if needed
	if ((TukuiCF.actionbar.rightbars < 3 and TukuiCF["actionbar"].splitbar ~= true and TukuiCF.actionbar.bottomrows ~= 3) and not 
	(TukuiCF["actionbar"].splitbar ~= true and TukuiCF["actionbar"].bottomrows == 2 and TukuiCF["actionbar"].rightbars == 2)) or 
	(TukuiCF["actionbar"].bottomrows == 3 and TukuiCF["actionbar"].splitbar ~= true and TukuiCF["actionbar"].rightbars == 0) then
		TukuiBar3:Hide()
	else
		TukuiBar3:Show()
	end
end

do
	PositionBar3()
end