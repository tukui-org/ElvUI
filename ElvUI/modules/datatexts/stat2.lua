
local E, C, L = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales


-----------------------------------------
-- Stat 2
-----------------------------------------

if C["datatext"].stat2 and C["datatext"].stat2 > 0 then
	local Stat = CreateFrame("Frame")
	Stat:EnableMouse(true)
	Stat:SetFrameStrata("MEDIUM")
	Stat:SetFrameLevel(3)

	local Text  = ElvuiInfoLeft:CreateFontString(nil, "LOW")
	Text:SetFont(C.media.font, C["datatext"].fontsize, "THINOUTLINE")
	Text:SetShadowOffset(E.mult, -E.mult)
	Text:SetShadowColor(0, 0, 0, 0.4)
	E.PP(C["datatext"].stat2, Text)
	
	local int = 1	
	local function Update(self, t)
		int = int - t
		if int < 0 then
			if E.Role == "Tank" then
				local baseArmor , effectiveArmor, armor, posBuff, negBuff = UnitArmor("player");
				Text:SetText("Armor: "..E.ValColor..(effectiveArmor))
				
				--Setup Armor Tooltip
				self:SetAllPoints(Text)
				self:SetScript("OnEnter", function()
					if E.Role == "Tank" then
						local anchor, panel, xoff, yoff = E.DataTextTooltipAnchor(Text)
						GameTooltip:SetOwner(panel, anchor, xoff, yoff)
						GameTooltip:ClearLines()
						GameTooltip:AddLine(L.datatext_mitigation)
						GameTooltip:AddLine(' ')
						local lv = E.level +3
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
						if lv > 0 and (lv > E.level + 3 or lv < E.level) then
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
			elseif E.Role == "Caster" then
				Text:SetText(L.datatext_playercrit.." "..E.ValColor..format("%.2f%%", GetSpellCritChance(1)))
			elseif E.Role == "Melee" then
				local meleecrit = GetCritChance()
				local rangedcrit = GetRangedCritChance()
				local CritChance
					
				if E.myclass == "HUNTER" then    
					CritChance = rangedcrit
				else
					CritChance = meleecrit
				end

				Text:SetText(L.datatext_playercrit.." "..E.ValColor..format("%.2f%%", CritChance))
			end
			int = 1
		end
	end
	
	Stat:SetScript("OnUpdate", Update)
	Update(Stat, 10)
end