local TukuiCF = TukuiCF
local TukuiDB = TukuiDB
local tukuilocal = tukuilocal

-----------------------------------------
-- Stat 2
-----------------------------------------

if TukuiCF["datatext"].stat2 and TukuiCF["datatext"].stat2 > 0 then
	local Stat = CreateFrame("Frame")
	Stat:EnableMouse(true)
	Stat:SetFrameStrata("MEDIUM")
	Stat:SetFrameLevel(3)

	local Text  = TukuiInfoLeft:CreateFontString(nil, "LOW")
		Text:SetFont(TukuiCF.media.font, TukuiCF["datatext"].fontsize, "THINOUTLINE")
	Text:SetShadowOffset(TukuiDB.mult, -TukuiDB.mult)
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
					local lv = TukuiDB.level +3
					for i = 1, 4 do
						local format = string.format
						local mitigation
						if lv < 60 then
							mitigation = (effectiveArmor/(effectiveArmor+400+(85 * lv)));
						else
							mitigation = (effectiveArmor/(effectiveArmor+(467.5*lv-22167.5)));
						end
						if mitigation > .75 then
							mitigation = .75
						end
						GameTooltip:AddDoubleLine(lv,format("%.2f", mitigation*100) .. "%",1,1,1)
						lv = lv - 1
					end
					lv = UnitLevel("target")
					if lv > 0 and (lv > TukuiDB.level + 3 or lv < TukuiDB.level) then
						if lv < 60 then
							mitigation = (effectiveArmor/(effectiveArmor+400+(85 * lv)));
						else
							mitigation = (effectiveArmor/(effectiveArmor+(467.5*lv-22167.5)));
						end
						if mitigation > .75 then
							mitigation = .75
						end
						GameTooltip:AddDoubleLine(lv,format("%.2f", mitigation*100) .. "%",1,1,1)
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