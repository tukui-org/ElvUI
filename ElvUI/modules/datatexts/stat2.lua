local ElvCF = ElvCF
local ElvDB = ElvDB
local ElvL = ElvL

-----------------------------------------
-- Stat 2
-----------------------------------------

if ElvCF["datatext"].stat2 and ElvCF["datatext"].stat2 > 0 then
	local Stat = CreateFrame("Frame")
	Stat:EnableMouse(true)
	Stat:SetFrameStrata("MEDIUM")
	Stat:SetFrameLevel(3)

	local Text  = ElvuiInfoLeft:CreateFontString(nil, "LOW")
		Text:SetFont(ElvCF.media.font, ElvCF["datatext"].fontsize, "THINOUTLINE")
	Text:SetShadowOffset(ElvDB.mult, -ElvDB.mult)
	ElvDB.PP(ElvCF["datatext"].stat2, Text)
	
	local int = 1	
	local function Update(self, t)
		int = int - t
		if int < 0 then
			if ElvDB.Role == "Tank" then
				local baseArmor , effectiveArmor, armor, posBuff, negBuff = UnitArmor("player");
				Text:SetText("Armor: "..ElvDB.ValColor..(effectiveArmor))
				--Setup Armor Tooltip
				self:SetAllPoints(Text)
				self:SetScript("OnEnter", function()
				if ElvDB.Role == "Tank" then
					GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, ElvDB.Scale(6));
					GameTooltip:ClearAllPoints()
					GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, ElvDB.mult)
					GameTooltip:ClearLines()
					GameTooltip:AddLine(ElvL.datatext_mitigation)
					GameTooltip:AddLine(' ')
					local lv = ElvDB.level +3
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
					if lv > 0 and (lv > ElvDB.level + 3 or lv < ElvDB.level) then
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
			elseif ElvDB.Role == "Caster" then
				Text:SetText(ElvL.datatext_playercrit.." "..ElvDB.ValColor..format("%.2f", GetSpellCritChance(1)) .. "%")
			elseif ElvDB.Role == "Melee" then
				local meleecrit = GetCritChance()
				local rangedcrit = GetRangedCritChance()
				local CritChance
					
				if ElvDB.myclass == "HUNTER" then    
					CritChance = rangedcrit
				else
					CritChance = meleecrit
				end

				Text:SetText(ElvL.datatext_playercrit.." "..ElvDB.ValColor..format("%.2f", CritChance) .. "%")
			end
			int = 1
		end
	end
	
	Stat:SetScript("OnUpdate", Update)
	Update(Stat, 10)
end