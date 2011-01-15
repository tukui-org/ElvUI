if not ElvCF["actionbar"].enable == true then return end
local ElvDB = ElvDB
local ElvCF = ElvCF

---------------------------------------------------------------------------
-- setup MultiBarRight as bar #4
---------------------------------------------------------------------------

local ElvuiBar4 = CreateFrame("Frame","ElvuiBar4",ElvuiActionBarBackground) -- bottomrightbar
ElvuiBar4:SetAllPoints(ElvuiActionBarBackground)
MultiBarRight:SetParent(ElvuiBar4)

function PositionBar4()
	for i= 1, 12 do
		local b = _G["MultiBarRightButton"..i]
		local b2 = _G["MultiBarRightButton"..i-1]
		b:ClearAllPoints()
		b:SetAlpha(1)
		b:Show()
		ElvuiBar4:SetParent(ElvuiActionBarBackgroundRight)
		if ElvCF.actionbar.bottomrows == 3 then
			if i == 1 then
				if ElvCF["actionbar"].swaptopbottombar == true then
					b:SetPoint("TOP", MultiBarBottomLeftButton1, "BOTTOM", 0, -ElvDB.buttonspacing)
				else
					b:SetPoint("BOTTOM", MultiBarBottomLeftButton1, "TOP", 0, ElvDB.buttonspacing)
				end
			else
				b:SetPoint("LEFT", b2, "RIGHT", ElvDB.buttonspacing, 0)
			end
			ElvuiBar4:SetParent(ElvuiActionBarBackground)
		elseif ElvCF.actionbar.bottomrows ~= 3 and ElvCF.actionbar.rightbars > 1 then
			if i == 1 then
				if ElvCF.actionbar.rightbars == 2 then
					b:SetPoint("TOPRIGHT", ElvuiActionBarBackgroundRight, "TOPRIGHT", -ElvDB.buttonspacing, -ElvDB.buttonspacing)
				else
					b:SetPoint("TOP", ElvuiActionBarBackgroundRight, "TOP", 0, -ElvDB.buttonspacing)
				end
			else
				b:SetPoint("TOP", b2, "BOTTOM", 0, -ElvDB.buttonspacing)
			end		
		else
			if i == 1 then
				b:SetPoint("TOPRIGHT", ElvuiActionBarBackgroundRight, "TOPRIGHT", -ElvDB.buttonspacing, -ElvDB.buttonspacing)
			else
				b:SetPoint("TOP", b2, "BOTTOM", 0, -ElvDB.buttonspacing)
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
	if ElvCF.actionbar.rightbars < 1 and not (((ElvCF.actionbar.bottomrows == 3) or (ElvCF.actionbar.bottomrows ~= 3 and ElvCF.actionbar.rightbars > 1)) or (ElvCF["actionbar"].bottomrows == 2 and ElvCF["actionbar"].rightbars == 2) or (ElvCF["actionbar"].rightbar == 2 and ElvCF["actionbar"].bottomrows > 1 and ElvCF["actionbar"].splitbar == true)) or (ElvCF["actionbar"].bottomrows == 2 and ElvCF["actionbar"].rightbars == 2 and ElvCF["actionbar"].splitbar ~= true) then
		ElvuiBar4:Hide()
	else
		ElvuiBar4:Show()
	end
end

do
	PositionBar4()
end