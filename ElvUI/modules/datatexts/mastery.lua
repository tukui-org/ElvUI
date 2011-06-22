-----------------------------------------
-- Mastery Rating
-----------------------------------------
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if not C["datatext"].mastery or C["datatext"].mastery == 0 then return end

local Stat = CreateFrame("Frame")
Stat:SetFrameStrata("MEDIUM")
Stat:EnableMouse(true)
Stat:SetFrameLevel(3)

local Text  = ElvuiInfoLeft:CreateFontString(nil, "LOW")
Text:SetFont(C["media"].font, C["datatext"].fontsize, "THINOUTLINE")
Text:SetShadowOffset(E.mult, -E.mult)
E.PP(C["datatext"].mastery, Text)
Stat:SetParent(Text:GetParent())

local _G = getfenv(0)
local format = string.format
local displayFloatString = string.join("", "%s", E.ValColor, "%.2f%%|r")
local displayModifierString = string.join("", "%s", E.ValColor, "%.2f%%|r")

local function UpdateCaster(self)
	local spellMastery = GetCombatRatingBonus(CR_HASTE_SPELL)

	Text:SetFormattedText(displayFloatString, L.datatext_playermastery, spellMastery)
end

local function UpdateMelee(self)
	local meleeMastery = GetCombatRatingBonus(CR_HASTE_MELEE)
	local rangedMastery = GetCombatRatingBonus(CR_HASTE_RANGED)
	local masteryRating

	if E.myclass == "HUNTER" then
		masteryRating = rangedMastery
	else
		masteryRating = meleeMastery
	end

	Text:SetFormattedText(displayFloatString, L.datatext_playermastery, masteryRating)
end

-- initial delay for update (let the ui load)
local int = 5
local function Update(self, t)
	int = int - t
	if int > 0 then return end

	--STAT_MASTERY
	local masteryspell, masteryTag
	if GetCombatRating(CR_MASTERY) ~= 0 and GetPrimaryTalentTree() then
		if C["datatext"].masteryspell then
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
				masteryTag = STAT_MASTERY.." ("..masteryName.."): "
			else
				masteryTag = STAT_MASTERY..": "
			end
		else
			masteryTag = STAT_MASTERY..": "
		end
		Text:SetFormattedText(displayModifierString, masteryTag, GetMastery())
	end
	
	self:SetAllPoints(Text)
	int = 2
end

Stat:SetScript('OnEnter', function(self)
	local anchor, panel, xoff, yoff = E.DataTextTooltipAnchor(Text)
	GameTooltip:SetOwner(panel, anchor, xoff, yoff)
	GameTooltip:ClearLines()

	local mastery = GetMastery();
	local masteryBonus = GetCombatRatingBonus(CR_MASTERY);
	mastery = format("%.2f", mastery);
	
	local title = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_MASTERY).." "..mastery..FONT_COLOR_CODE_CLOSE;
	if (masteryBonus > 0) then
		title = title..HIGHLIGHT_FONT_COLOR_CODE.." ("..format("%.2f", mastery-masteryBonus)..FONT_COLOR_CODE_CLOSE..GREEN_FONT_COLOR_CODE.."+"..format("%.2f", masteryBonus)..FONT_COLOR_CODE_CLOSE..HIGHLIGHT_FONT_COLOR_CODE..")";
	end
	GameTooltip:SetText(title);
	
	local masteryKnown = IsSpellKnown(CLASS_MASTERY_SPELLS[E.myclass]);
	local primaryTalentTree = GetPrimaryTalentTree();
	if (masteryKnown and primaryTalentTree) then
		local masterySpell, masterySpell2 = GetTalentTreeMasterySpells(primaryTalentTree);
		if (masterySpell) then
			GameTooltip:AddSpellByID(masterySpell);
		end
		if (masterySpell2) then
			GameTooltip:AddLine(" ");
			GameTooltip:AddSpellByID(masterySpell2);
		end
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(format(STAT_MASTERY_TOOLTIP, GetCombatRating(CR_MASTERY), masteryBonus), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
	else
		GameTooltip:AddLine(format(STAT_MASTERY_TOOLTIP, GetCombatRating(CR_MASTERY), masteryBonus), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
		GameTooltip:AddLine(" ");
		if (masteryKnown) then
			GameTooltip:AddLine(STAT_MASTERY_TOOLTIP_NO_TALENT_SPEC, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, true);
		else
			GameTooltip:AddLine(STAT_MASTERY_TOOLTIP_NOT_KNOWN, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, true);
		end
	end
	
	GameTooltip:Show()
end)
Stat:SetScript('OnLeave', function() GameTooltip:Hide() end)

Stat:SetScript("OnUpdate", Update)
Update(Stat, 6)