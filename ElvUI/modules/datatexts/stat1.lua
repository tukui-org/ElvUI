-----------------------------------------
-- Stat 1 
-----------------------------------------
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if not C["datatext"].stat1 or C["datatext"].stat1 == 0 then return end

local Stat = CreateFrame("Frame")
Stat:EnableMouse(true)
Stat:SetFrameStrata("MEDIUM")
Stat:SetFrameLevel(3)

local Text  = ElvuiInfoLeft:CreateFontString(nil, "OVERLAY")
Text:SetFont(C["media"].font, C["datatext"].fontsize, "THINOUTLINE")
Text:SetShadowOffset(E.mult, -E.mult)
E.PP(C["datatext"].stat1, Text)
Stat:SetParent(Text:GetParent())

local format = string.format
local targetlv, playerlv
local basemisschance, leveldifference, dodge, parry, block
local chanceString = "%.2f%%"
local modifierString = string.join("", "%d (+", chanceString, ")")
local manaRegenString = "%d / %d"
local displayNumberString = string.join("", "%s", E.ValColor, "%d|r")
local displayFloatString = string.join("", "%s", E.ValColor, "%.2f%%|r")
local spellpwr, avoidance, pwr
local haste, hasteBonus

local function ShowTooltip(self)
	local anchor, panel, xoff, yoff = E.DataTextTooltipAnchor(Text)
	GameTooltip:SetOwner(panel, anchor, xoff, yoff)
	GameTooltip:ClearLines()
	
	if E.Role == "Tank" then
		if targetlv > 1 then
			GameTooltip:AddDoubleLine(L.datatext_avoidancebreakdown, string.join("", " (", L.datatext_lvl, " ", targetlv, ")"))
		elseif targetlv == -1 then
			GameTooltip:AddDoubleLine(L.datatext_avoidancebreakdown, string.join("", " (", L.datatext_boss, ")"))
		else
			GameTooltip:AddDoubleLine(L.datatext_avoidancebreakdown, string.join("", " (", L.datatext_lvl, " ", playerlv, ")"))
		end
		GameTooltip:AddLine' '
		GameTooltip:AddDoubleLine(DODGE_CHANCE, format(chanceString, dodge),1,1,1)
		GameTooltip:AddDoubleLine(PARRY_CHANCE, format(chanceString, parry),1,1,1)
		GameTooltip:AddDoubleLine(BLOCK_CHANCE, format(chanceString, block),1,1,1)
		GameTooltip:AddDoubleLine(MISS_CHANCE, format(chanceString, basemisschance),1,1,1)
	elseif E.Role == "Caster" then
		GameTooltip:AddDoubleLine(STAT_HIT_CHANCE, format(modifierString, GetCombatRating(CR_HIT_SPELL), GetCombatRatingBonus(CR_HIT_SPELL)), 1, 1, 1)
		GameTooltip:AddDoubleLine(STAT_HASTE, format(modifierString, GetCombatRating(CR_HASTE_SPELL), GetCombatRatingBonus(CR_HASTE_SPELL)), 1, 1, 1)
		local base, combat = GetManaRegen()
		GameTooltip:AddDoubleLine(MANA_REGEN, format(manaRegenString, base * 5, combat * 5), 1, 1, 1)
	elseif E.Role == "Melee" then
		local hit = E.myclass == "HUNTER" and GetCombatRating(CR_HIT_RANGED) or GetCombatRating(CR_HIT_MELEE)
		local hitBonus = E.myclass == "HUNTER" and GetCombatRatingBonus(CR_HIT_RANGED) or GetCombatRatingBonus(CR_HIT_MELEE)
	
		GameTooltip:AddDoubleLine(STAT_HIT_CHANCE, format(modifierString, hit, hitBonus), 1, 1, 1)
		
		--Hunters don't use expertise
		if E.myclass ~= "HUNTER" then
			local expertisePercent, offhandExpertisePercent = GetExpertisePercent()
			expertisePercent = format("%.2f", expertisePercent)
			offhandExpertisePercent = format("%.2f", offhandExpertisePercent)
			
			local expertisePercentDisplay
			if IsDualWielding() then
				expertisePercentDisplay = expertisePercent.."% / "..offhandExpertisePercent.."%"
			else
				expertisePercentDisplay = expertisePercent.."%"
			end
			GameTooltip:AddDoubleLine(COMBAT_RATING_NAME24, format('%d (+%s)', GetCombatRating(CR_EXPERTISE), expertisePercentDisplay), 1, 1, 1)
		end
		
		local haste = E.myclass == "HUNTER" and GetCombatRating(CR_HASTE_RANGED) or GetCombatRating(CR_HASTE_MELEE)
		local hasteBonus = E.myclass == "HUNTER" and GetCombatRatingBonus(CR_HASTE_RANGED) or GetCombatRatingBonus(CR_HASTE_MELEE)
		
		GameTooltip:AddDoubleLine(STAT_HASTE, format(modifierString, haste, hasteBonus), 1, 1, 1)
	end
	
	local masteryspell
	if GetCombatRating(CR_MASTERY) ~= 0 and GetPrimaryTalentTree() then
		if E.myclass == "DRUID" then
			if E.Role == "Melee" then
				masteryspell = select(2, GetTalentTreeMasterySpells(GetPrimaryTalentTree()))
			elseif E.Role == "Tank" then
				masteryspell = select(1, GetTalentTreeMasterySpells(GetPrimaryTalentTree()))
			else
				masteryspell = GetTalentTreeMasterySpells(GetPrimaryTalentTree())
			end
		else
			masteryspell = GetTalentTreeMasterySpells(GetPrimaryTalentTree())
		end
		


		local masteryName, _, _, _, _, _, _, _, _ = GetSpellInfo(masteryspell)
		if masteryName then
			GameTooltip:AddLine' '
			GameTooltip:AddDoubleLine(masteryName, format(modifierString, GetCombatRating(CR_MASTERY), GetCombatRatingBonus(CR_MASTERY)), 1, 1, 1)
		end
	end
	
	GameTooltip:Show()
end

local function UpdateTank(self)
	targetlv, playerlv = UnitLevel("target"), UnitLevel("player")
			
	-- the 5 is for base miss chance
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
	
	if select(2, UnitRace("player")) == "NightElf" then basemisschance = basemisschance + 2 end
	
	if leveldifference >= 0 then
		dodge = (GetDodgeChance()-leveldifference*.2)
		parry = (GetParryChance()-leveldifference*.2)
		block = (GetBlockChance()-leveldifference*.2)
	else
		dodge = (GetDodgeChance()+abs(leveldifference*.2))
		parry = (GetParryChance()+abs(leveldifference*.2))
		block = (GetBlockChance()+abs(leveldifference*.2))
	end
	
	if dodge <= 0 then dodge = 0 end
	if parry <= 0 then parry = 0 end
	if block <= 0 then block = 0 end
	
	if E.myclass == "DRUID" then
		parry = 0
		block = 0
	elseif E.myclass == "DEATHKNIGHT" then
		block = 0
	end
	avoidance = (dodge+parry+block+basemisschance)
	
	Text:SetFormattedText(displayFloatString, L.datatext_playeravd, avoidance)
	--Setup Tooltip
	self:SetAllPoints(Text)
end

local function UpdateCaster(self)
	if GetSpellBonusHealing() > GetSpellBonusDamage(7) then
		spellpwr = GetSpellBonusHealing()
	else
		spellpwr = GetSpellBonusDamage(7)
	end
	
	Text:SetFormattedText(displayNumberString, L.datatext_playersp, spellpwr)
	--Setup Tooltip
	self:SetAllPoints(Text)
end

local function UpdateMelee(self)
	local base, posBuff, negBuff = UnitAttackPower("player");
	local effective = base + posBuff + negBuff;
	local Rbase, RposBuff, RnegBuff = UnitRangedAttackPower("player");
	local Reffective = Rbase + RposBuff + RnegBuff;
		
	if E.myclass == "HUNTER" then
		pwr = Reffective
	else
		pwr = effective
	end
	
	Text:SetFormattedText(displayNumberString, L.datatext_playerap, pwr)      
	--Setup Tooltip
	self:SetAllPoints(Text)
end

-- initial delay for update (let the ui load)
local int = 5	
local function Update(self, t)
	int = int - t
	if int > 0 then return end
	if E.Role == "Tank" then 
		UpdateTank(self)
	elseif E.Role == "Caster" then
		UpdateCaster(self)
	elseif E.Role == "Melee" then
		UpdateMelee(self)
	end
	int = 2
end

Stat:SetScript("OnEnter", function() ShowTooltip(Stat) end)
Stat:SetScript("OnLeave", function() GameTooltip:Hide() end)
Stat:SetScript("OnUpdate", Update)
Update(Stat, 6)
