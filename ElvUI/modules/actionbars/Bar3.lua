if not ElvCF["actionbar"].enable == true then return end
local ElvDB = ElvDB
local ElvCF = ElvCF

---------------------------------------------------------------------------
-- setup MultiBarLeft as bar #3
---------------------------------------------------------------------------

local ElvuiBar3 = CreateFrame("Frame","ElvuiBar3",ElvuiActionBarBackground) -- bottomrightbar
ElvuiBar3:SetAllPoints(ElvuiActionBarBackground)
MultiBarLeft:SetParent(ElvuiBar3)


--Some event fires when sheathing/unsheathing weapon that forces a show on actionbuttons, setting the parent to this frame temporarily when splitbars is applied to fix
local ElvuiBar3Split = CreateFrame("Frame", "ElvuiBarSplit1", ElvuiBar3)
ElvuiBar3Split:SetAllPoints(ElvuiActionBarBackground)


function PositionBar3()
	for i= 1, 12 do
		local b = _G["MultiBarLeftButton"..i]
		local b2 = _G["MultiBarLeftButton"..i-1]
		b:ClearAllPoints()
		b:SetParent(MultiBarLeft)
		b:Show()
		b:SetAlpha(1)
		if ElvCF["actionbar"].splitbar ~= true then
			if ElvCF["actionbar"].rightbars > 1 then
				if i == 1 then
					b:SetPoint("TOPRIGHT", ElvuiActionBarBackgroundRight, "TOPRIGHT", -ElvDB.buttonspacing, -ElvDB.buttonspacing)
				else
					b:SetPoint("TOP", b2, "BOTTOM", 0, -ElvDB.buttonspacing)
				end			
			else
				if i == 1 then
					b:SetPoint("TOP", ElvuiActionBarBackgroundRight, "TOP", 0, -ElvDB.buttonspacing)
				else
					b:SetPoint("TOP", b2, "BOTTOM", 0, -ElvDB.buttonspacing)
				end	
			end
		else
			if ElvCF.actionbar.bottomrows == 1 then
				if i == 1 then
					b:SetPoint("TOPLEFT", ElvuiSplitActionBarLeftBackground, "TOPLEFT", ElvDB.buttonspacing, -ElvDB.buttonspacing)
				elseif i > 3 and i < 7 then
					b:SetParent(ElvuiBar3Split)
				elseif i == 7 then
					b:SetPoint("TOPLEFT", ElvuiSplitActionBarRightBackground, "TOPLEFT", ElvDB.buttonspacing, -ElvDB.buttonspacing)
				elseif i > 9 then
					b:SetParent(ElvuiBar3Split)
					ElvuiBar3Split:Hide()
				else
					b:SetPoint("LEFT", b2, "RIGHT", ElvDB.buttonspacing, 0)
				end		
			elseif ElvCF.actionbar.bottomrows == 2 then
				if i == 1 then
					b:SetPoint("TOPLEFT", ElvuiSplitActionBarLeftBackground, "TOPLEFT", ElvDB.buttonspacing, -ElvDB.buttonspacing)
				elseif i == 4 then
					b:SetPoint("TOP", _G["MultiBarLeftButton"..i-3], "BOTTOM", 0, -ElvDB.buttonspacing)
				elseif i == 7 then
					b:SetPoint("TOPLEFT", ElvuiSplitActionBarRightBackground, "TOPLEFT", ElvDB.buttonspacing, -ElvDB.buttonspacing)
				elseif i == 10 then
					b:SetPoint("TOP", _G["MultiBarLeftButton"..i-3], "BOTTOM", 0, -ElvDB.buttonspacing)
				else
					b:SetPoint("LEFT", b2, "RIGHT", ElvDB.buttonspacing, 0)
				end	
			else
				if i == 1 then
					b:SetPoint("TOPLEFT", ElvuiSplitActionBarLeftBackground, "TOPLEFT", (ElvDB.buttonsize * 1) + (ElvDB.buttonspacing * 2), -ElvDB.buttonspacing)
				elseif i == 4 then
					b:SetPoint("TOP", _G["MultiBarLeftButton"..i-3], "BOTTOM", 0, -ElvDB.buttonspacing)
				elseif i == 7 then
					b:SetPoint("TOPLEFT", ElvuiSplitActionBarRightBackground, "TOPLEFT", ElvDB.buttonspacing, -ElvDB.buttonspacing)
				elseif i == 10 then
					b:SetPoint("TOP", _G["MultiBarLeftButton"..i-3], "BOTTOM", 0, -ElvDB.buttonspacing)
				else
					b:SetPoint("LEFT", b2, "RIGHT", ElvDB.buttonspacing, 0)
				end  		
			end
		end
		--Setup Mouseover
		if ElvCF["actionbar"].rightbarmouseover == true and not (ElvCF.actionbar.bottomrows == 3) and ElvCF["actionbar"].splitbar ~= true then
			b:SetAlpha(0)
			b:HookScript("OnEnter", function() 
				if not (ElvCF.actionbar.bottomrows == 3) and ElvCF["actionbar"].splitbar ~= true then
					RightBarMouseOver(1) 
				end
			end)
			b:HookScript("OnLeave", function() 
				if not (ElvCF.actionbar.bottomrows == 3) and ElvCF["actionbar"].splitbar ~= true then
					RightBarMouseOver(0) 
				end
			end)
		end
	end

	-- hide it if needed
	if ((ElvCF.actionbar.rightbars < 3 and ElvCF["actionbar"].splitbar ~= true and ElvCF.actionbar.bottomrows ~= 3) and not 
	(ElvCF["actionbar"].splitbar ~= true and ElvCF["actionbar"].bottomrows == 2 and ElvCF["actionbar"].rightbars == 2)) or 
	(ElvCF["actionbar"].bottomrows == 3 and ElvCF["actionbar"].splitbar ~= true and ElvCF["actionbar"].rightbars == 0) then
		ElvuiBar3:Hide()
	else
		ElvuiBar3:Show()
	end
end

do
	PositionBar3()
end