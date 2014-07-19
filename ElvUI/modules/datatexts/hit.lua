local E, L, V, P, G = unpack(select(2, ...)); --Inport: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule('DataTexts')

local join = string.join

local lastPanel
local displayString = '';
local hitRating, hitRatingBonus;

local function OnEvent(self, event, unit)
	if E.role == "Caster" then
		local expertise = GetExpertise();
		hitRating = GetCombatRating(CR_HIT_SPELL)
		hitRatingBonus = GetCombatRatingBonus(CR_HIT_SPELL) + expertise
	else
		if E.myclass == "HUNTER" then
			hitRating = GetCombatRating(CR_HIT_RANGED)
			hitRatingBonus = GetCombatRatingBonus(CR_HIT_RANGED)
		else
			hitRating = GetCombatRating(CR_HIT_MELEE)
			hitRatingBonus = GetCombatRatingBonus(CR_HIT_MELEE)
		end
	end

	self.text:SetFormattedText(displayString, L['Hit']..': ', hitRatingBonus)
	lastPanel = self
end


local function OnEnter(self)
	DT:SetupTooltip(self)
	
	if E.role == "Caster" then
		DT.tooltip:AddLine(format(STAT_HIT_SPELL_TOOLTIP, GetCombatRating(CR_HIT_SPELL), GetCombatRatingBonus(CR_HIT_SPELL)));
		DT.tooltip:AddLine(" ");
		DT.tooltip:AddDoubleLine(STAT_TARGET_LEVEL, MISS_CHANCE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		local playerLevel = UnitLevel("player");
		for i=0, 3 do
			local missChance = format("%.2f%%", GetSpellMissChance(i));
			local level = playerLevel + i;
				if (i == 3) then
					level = level.." / |TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:0|t";
				end
			DT.tooltip:AddDoubleLine("      "..level, missChance.."    ", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		end	
	else
		if E.myclass == "HUNTER" then
			DT.tooltip:AddLine(format(STAT_HIT_RANGED_TOOLTIP, GetCombatRating(CR_HIT_RANGED), GetCombatRatingBonus(CR_HIT_RANGED)));
			DT.tooltip:AddLine(" ");
			DT.tooltip:AddDoubleLine(STAT_TARGET_LEVEL, MISS_CHANCE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			local playerLevel = UnitLevel("player");
			for i=0, 3 do
				local missChance = format("%.2f%%", GetRangedMissChance(i));
				local level = playerLevel + i;
					if (i == 3) then
						level = level.." / |TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:0|t";
					end
				DT.tooltip:AddDoubleLine("      "..level, missChance.."    ", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
			end		
		else
			DT.tooltip:AddLine(format(STAT_HIT_MELEE_TOOLTIP, GetCombatRating(CR_HIT_MELEE), GetCombatRatingBonus(CR_HIT_MELEE)));
			DT.tooltip:AddLine(" ");
			DT.tooltip:AddDoubleLine(STAT_TARGET_LEVEL, MISS_CHANCE, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			if (IsDualWielding()) then
				DT.tooltip:AddLine(STAT_HIT_NORMAL_ATTACKS, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
			end
			local playerLevel = UnitLevel("player");
			for i=0, 3 do
				local missChance = format("%.2f%%", GetMeleeMissChance(i, false));
				local level = playerLevel + i;
					if (i == 3) then
						level = level.." / |TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:0|t";
					end
				DT.tooltip:AddDoubleLine("      "..level, missChance.."    ", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
			end
			
			if (IsDualWielding()) then
				DT.tooltip:AddLine(STAT_HIT_SPECIAL_ATTACKS, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
				for i=0, 3 do
					local missChance = format("%.2f%%", GetMeleeMissChance(i, true));
					local level = playerLevel + i;
					if (i == 3) then
						level = level.." / |TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:0|t";
					end
					DT.tooltip:AddDoubleLine("      "..level, missChance.."    ", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				end
			end		
		end
	end
	
	DT.tooltip:Show()
end

local function ValueColorUpdate(hex, r, g, b)
	displayString = join("", "%s", hex, "%.2f%%|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E['valueColorUpdateFuncs'][ValueColorUpdate] = true

--[[
	DT:RegisterDatatext(name, events, eventFunc, updateFunc, clickFunc, onEnterFunc)

	name - name of the datatext (required)
	events - must be a table with string values of event names to register
	eventFunc - function that gets fired when an event gets triggered
	updateFunc - onUpdate script target function
	click - function to fire when clicking the datatext
	onEnterFunc - function to fire OnEnter
]]
DT:RegisterDatatext('Hit Rating', {"UNIT_STATS", "UNIT_AURA", "FORGE_MASTER_ITEM_CHANGED", "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_TALENT_UPDATE"}, OnEvent, nil, nil, OnEnter)
