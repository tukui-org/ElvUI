local ElvCF = ElvCF
local ElvDB = ElvDB
local ElvL = ElvL

-----------------------------------------
-- Stat 1 
-----------------------------------------

if ElvCF["datatext"].stat1 and ElvCF["datatext"].stat1 > 0 then
	local Stat = CreateFrame("Frame")
	Stat:EnableMouse(true)
	Stat:SetFrameStrata("MEDIUM")
	Stat:SetFrameLevel(3)

	local Text  = ElvuiInfoLeft:CreateFontString(nil, "OVERLAY")
		Text:SetFont(ElvCF.media.font, ElvCF["datatext"].fontsize, "THINOUTLINE")
	Text:SetShadowOffset(ElvDB.mult, -ElvDB.mult)
	ElvDB.PP(ElvCF["datatext"].stat1, Text)
	
	local int = 1	
	local function Update(self, t)
		int = int - t
		if int < 0 then
			if ElvDB.Role == "Tank" then
				local format = string.format
				local targetlv, playerlv = UnitLevel("target"), UnitLevel("player")
				
				if targetlv == -1 then
					basemisschance = (5 - (3*.2))
					leveldifference = 3
				elseif targetlv > playerlv then
					basemisschance = (5 - ((targetlv - playerlv)*.2))
					leveldifference = (targetlv - playerlv)
				elseif targetlv < playerlv and targetlv > 0 then
					basemisschance = (5 + ((playerlv - targetlv)*.2))
					leveldifference = (targetlv - playerlv)
				else
					basemisschance = 5
					leveldifference = 0
				end

				if leveldifference >= 0 then
					dodge = (GetDodgeChance()-leveldifference*.2)
					parry = (GetParryChance()-leveldifference*.2)
					block = (GetBlockChance()-leveldifference*.2)
					-- the 5 is for base miss chance
					avoidance = (dodge+parry+block+basemisschance)	
				else
					dodge = (GetDodgeChance()+abs(leveldifference*.2))
					parry = (GetParryChance()+abs(leveldifference*.2))
					block = (GetBlockChance()+abs(leveldifference*.2))
					-- the 5 is for base miss chance
					avoidance = (dodge+parry+block+basemisschance)
				end
					
				Text:SetText(ElvL.datatext_playeravd..ElvDB.ValColor..format("%.2f", avoidance))
				--Setup Avoidance Tooltip
				self:SetAllPoints(Text)
				self:SetScript("OnEnter", function()
					if ElvDB.Role == "Tank" then
						GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, ElvDB.Scale(6));
						GameTooltip:ClearAllPoints()
						GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, ElvDB.mult)
						GameTooltip:ClearLines()
						if targetlv > 1 then
							GameTooltip:AddDoubleLine(ElvL.datatext_avoidancebreakdown," ("..ElvL.datatext_lvl.." "..targetlv..")")
						elseif targetlv == -1 then
							GameTooltip:AddDoubleLine(ElvL.datatext_avoidancebreakdown," ("..ElvL.datatext_boss..")")
						else
							GameTooltip:AddDoubleLine(ElvL.datatext_avoidancebreakdown," ("..ElvL.datatext_lvl.." "..playerlv..")")
						end
						GameTooltip:AddLine' '
						GameTooltip:AddDoubleLine(DODGE_CHANCE,format("%.2f",dodge) .. "%",1,1,1)
						GameTooltip:AddDoubleLine(PARRY_CHANCE,format("%.2f",parry) .. "%",1,1,1)
						GameTooltip:AddDoubleLine(BLOCK_CHANCE,format("%.2f",block) .. "%",1,1,1)
						GameTooltip:AddDoubleLine(MISS_CHANCE,format("%.2f",basemisschance) .. "%",1,1,1)
						GameTooltip:Show()
					end
				end)
				self:SetScript("OnLeave", function() GameTooltip:Hide() end)
			elseif ElvDB.Role == "Caster" then
				local spellpwr
				if GetSpellBonusHealing() > GetSpellBonusDamage(7) then
					spellpwr = GetSpellBonusHealing()
				else
					spellpwr = GetSpellBonusDamage(7)
				end
				
				Text:SetText(ElvL.datatext_playersp.." "..ElvDB.ValColor..spellpwr)      
			elseif ElvDB.Role == "Melee" then
				local base, posBuff, negBuff = UnitAttackPower("player");
				local effective = base + posBuff + negBuff;
				local Rbase, RposBuff, RnegBuff = UnitRangedAttackPower("player");
				local Reffective = Rbase + RposBuff + RnegBuff;
				local pwr
					
				if ElvDB.myclass == "HUNTER" then
					pwr = Reffective
				else
					pwr = effective
				end
				
				Text:SetText(ElvL.datatext_playerap.." "..ElvDB.ValColor..pwr)      
			end
			int = 1
		end
	end
	
	Stat:SetScript("OnUpdate", Update)
	Update(Stat, 10)
end