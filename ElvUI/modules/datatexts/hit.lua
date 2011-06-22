-----------------------------------------
-- Hit Rating
-----------------------------------------
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if not C["datatext"].hit or C["datatext"].hit == 0 then return end

local Stat = CreateFrame("Frame")
Stat:SetFrameStrata("MEDIUM")
Stat:EnableMouse(true)
Stat:SetFrameLevel(3)

local Text  = ElvuiInfoLeft:CreateFontString(nil, "LOW")
Text:SetFont(C["media"].font, C["datatext"].fontsize, "THINOUTLINE")
Text:SetShadowOffset(E.mult, -E.mult)
E.PP(C["datatext"].hit, Text)
Stat:SetParent(Text:GetParent())

local _G = getfenv(0)
local format = string.format
local displayModifierString = string.join("", "%s", E.ValColor, "%.2f%%|r")

-- initial delay for update (let the ui load)
local int = 5
local function Update(self, t)
	int = int - t
	if int > 0 then return end

	local hitRating, hitRatingBonus
	if E.Role == "Caster" then
		hitRating = GetCombatRating(CR_HIT_SPELL)
		hitRatingBonus = GetCombatRatingBonus(CR_HIT_SPELL)
	else
		if E.myclass == "HUNTER" then
			hitRating = GetCombatRating(CR_HIT_RANGED)
			hitRatingBonus = GetCombatRatingBonus(CR_HIT_RANGED)
		else
			hitRating = GetCombatRating(CR_HIT_MELEE)
			hitRatingBonus = GetCombatRatingBonus(CR_HIT_MELEE)
		end
	end
	
	self:SetAllPoints(Text)
	Text:SetFormattedText(displayModifierString, HIT..": ", hitRatingBonus)
	int = 2
end

Stat:SetScript('OnEnter', function(self)
	local anchor, panel, xoff, yoff = E.DataTextTooltipAnchor(Text)
	GameTooltip:SetOwner(panel, anchor, xoff, yoff)
	GameTooltip:ClearLines()
	
	if E.Role == "Caster" then
		local hitChance = GetCombatRatingBonus(CR_HIT_SPELL) + GetSpellHitModifier();
		if (hitChance >= 0) then
			hitChance = format("+%.2f%%", hitChance);
		else
			hitChance = RED_FONT_COLOR_CODE..format("%.2f%%", hitChance)..FONT_COLOR_CODE_CLOSE;
		end
		GameTooltip:SetText(HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_HIT_CHANCE).." "..hitChance..FONT_COLOR_CODE_CLOSE);
		GameTooltip:AddLine(format(STAT_HIT_SPELL_TOOLTIP, GetCombatRating(CR_HIT_SPELL), GetCombatRatingBonus(CR_HIT_SPELL)));
		GameTooltip:AddLine(" ");
		GameTooltip:AddDoubleLine(STAT_TARGET_LEVEL, MISS_CHANCE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		local playerLevel = UnitLevel("player");
		for i=0, 3 do
			local missChance = format("%.2f%%", GetSpellMissChance(i));
			local level = playerLevel + i;
				if (i == 3) then
					level = level.." / |TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:0|t";
				end
			GameTooltip:AddDoubleLine("      "..level, missChance.."    ", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		end	
	else
		if E.myclass == "HUNTER" then
			local hitChance = GetCombatRatingBonus(CR_HIT_RANGED) + GetHitModifier();
			if (hitChance >= 0) then
				hitChance = format("+%.2f%%", hitChance);
			else
				hitChance = RED_FONT_COLOR_CODE..format("%.2f%%", hitChance)..FONT_COLOR_CODE_CLOSE;
			end
			GameTooltip:SetText(HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_HIT_CHANCE).." "..hitChance..FONT_COLOR_CODE_CLOSE);
			GameTooltip:AddLine(format(STAT_HIT_RANGED_TOOLTIP, GetCombatRating(CR_HIT_RANGED), GetCombatRatingBonus(CR_HIT_RANGED)));
			GameTooltip:AddLine(" ");
			GameTooltip:AddDoubleLine(STAT_TARGET_LEVEL, MISS_CHANCE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			local playerLevel = UnitLevel("player");
			for i=0, 3 do
				local missChance = format("%.2f%%", GetRangedMissChance(i));
				local level = playerLevel + i;
					if (i == 3) then
						level = level.." / |TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:0|t";
					end
				GameTooltip:AddDoubleLine("      "..level, missChance.."    ", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
			end		
		else
			local hitChance = GetCombatRatingBonus(CR_HIT_MELEE) + GetHitModifier();
			if (hitChance >= 0) then
				hitChance = format("+%.2f%%", hitChance);
			else
				hitChance = RED_FONT_COLOR_CODE..format("%.2f%%", hitChance)..FONT_COLOR_CODE_CLOSE;
			end
			GameTooltip:SetText(HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_HIT_CHANCE).." "..hitChance..FONT_COLOR_CODE_CLOSE);
			GameTooltip:AddLine(format(STAT_HIT_MELEE_TOOLTIP, GetCombatRating(CR_HIT_MELEE), GetCombatRatingBonus(CR_HIT_MELEE)));
			GameTooltip:AddLine(" ");
			GameTooltip:AddDoubleLine(STAT_TARGET_LEVEL, MISS_CHANCE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			if (IsDualWielding()) then
				GameTooltip:AddLine(STAT_HIT_NORMAL_ATTACKS, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
			end
			local playerLevel = UnitLevel("player");
			for i=0, 3 do
				local missChance = format("%.2f%%", GetMeleeMissChance(i, false));
				local level = playerLevel + i;
					if (i == 3) then
						level = level.." / |TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:0|t";
					end
				GameTooltip:AddDoubleLine("      "..level, missChance.."    ", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
			end
			
			if (IsDualWielding()) then
				GameTooltip:AddLine(STAT_HIT_SPECIAL_ATTACKS, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
				for i=0, 3 do
					local missChance = format("%.2f%%", GetMeleeMissChance(i, true));
					local level = playerLevel + i;
					if (i == 3) then
						level = level.." / |TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:0|t";
					end
					GameTooltip:AddDoubleLine("      "..level, missChance.."    ", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				end
			end		
		end
	end
	
	GameTooltip:Show()
end)
Stat:SetScript('OnLeave', function() GameTooltip:Hide() end)

Stat:SetScript("OnUpdate", Update)
Update(Stat, 6)