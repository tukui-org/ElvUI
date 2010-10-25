-----------------------------------------
-- Stat 2
-----------------------------------------

if TukuiCF["datatext"].stat2 and TukuiCF["datatext"].stat2 > 0 then
	local Stat = CreateFrame("Frame")
	Stat:EnableMouse(true)
	Stat:SetFrameStrata("BACKGROUND")
	Stat:SetFrameLevel(3)

	local Text  = TukuiBottomPanel:CreateFontString(nil, "LOW")
	Text:SetFont(TukuiCF.media.font, TukuiCF["datatext"].fontsize, "THINOUTLINE")
	TukuiDB.PP(TukuiCF["datatext"].stat2, Text)
	
	local int = 1	
	local function Update(self, t)
		int = int - t
		if int < 0 then
			if TukuiDB.Role == "Tank" then
				local baseArmor , effectiveArmor, armor, posBuff, negBuff = UnitArmor("player");
				Text:SetText("Armor: "..valuecolor..(effectiveArmor))
				--Setup Armor Tooltip
				self:SetAllPoints(Text)
				self:SetScript("OnEnter", function()
					if TukuiDB.Role == "Tank" then
						GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, TukuiDB.Scale(6));
						GameTooltip:ClearAllPoints()
						GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, TukuiDB.mult)
						GameTooltip:ClearLines()
						GameTooltip:AddLine(tukuilocal.datatext_mitigation)
						GameTooltip:AddLine(' ')
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
				self:SetScript("OnLeave", function() GameTooltip:Hide() end)				
			elseif TukuiDB.Role == "Caster" then
				Text:SetText(tukuilocal.datatext_playercrit.." "..valuecolor..format("%.2f", GetSpellCritChance(1)) .. "%")
			elseif TukuiDB.Role == "Melee" then
				local meleecrit = GetCritChance()
				local rangedcrit = GetRangedCritChance()
				local CritChance
					
				if TukuiDB.myclass == "HUNTER" then    
					CritChance = rangedcrit
				else
					CritChance = meleecrit
				end

				Text:SetText(tukuilocal.datatext_playercrit.." "..valuecolor..format("%.2f", CritChance) .. "%")
			end
			int = 1
		end
	end
	
	Stat:SetScript("OnUpdate", Update)
	Update(Stat, 10)
end