--------------------------------------------------------------------
-- player Armor
--------------------------------------------------------------------

if TukuiCF["datatext"].armor and TukuiCF["datatext"].armor > 0 then
	local Stat = CreateFrame("Frame")
	Stat:EnableMouse(true)
	Stat:SetFrameStrata("BACKGROUND")
	Stat:SetFrameLevel(3)

	local Text  = TukuiInfoLeft:CreateFontString(nil, "OVERLAY")
	Text:SetFont(TukuiCF.media.font, TukuiCF["datatext"].fontsize)
	TukuiDB.PP(TukuiCF["datatext"].armor, Text)

	local function Update(self)
		baseArmor , effectiveArmor, armor, posBuff, negBuff = UnitArmor("player");
		Text:SetText((effectiveArmor).." "..tukuilocal.datatext_armor)
		--Setup Armor Tooltip
		self:SetAllPoints(Text)
	end

	Stat:RegisterEvent("UNIT_INVENTORY_CHANGED")
	Stat:RegisterEvent("UNIT_AURA")
	Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	Stat:SetScript("OnMouseDown", function() ToggleCharacter("PaperDollFrame") end)
	Stat:SetScript("OnEvent", Update)
	Stat:SetScript("OnEnter", function(self)
		if not InCombatLockdown() then
			GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, TukuiDB.Scale(6));
			GameTooltip:ClearAllPoints()
			GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, TukuiDB.mult)
			GameTooltip:ClearLines()
			GameTooltip:AddLine(tukuilocal.datatext_mitigation)
			local lv = 83
			for i = 1, 4 do
				local format = string.format
				local mitigation = (effectiveArmor/(effectiveArmor+(467.5*lv-22167.5)));
				if mitigation > .75 then
					mitigation = .75
				end
				GameTooltip:AddDoubleLine(lv,format("%.2f", mitigation*100) .. "%",1,1,1)
				lv = lv - 1
			end
			if UnitLevel("target") > 0 and UnitLevel("target") < UnitLevel("player") then
				mitigation = (effectiveArmor/(effectiveArmor+(467.5*(UnitLevel("target"))-22167.5)));
				if mitigation > .75 then
					mitigation = .75
				end
				GameTooltip:AddDoubleLine(UnitLevel("target"),format("%.2f", mitigation*100) .. "%",1,1,1)
			end
			GameTooltip:Show()
		end
	end)
	Stat:SetScript("OnLeave", function() GameTooltip:Hide() end)
end