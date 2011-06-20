-----------------------------------------
-- Stat 2
-----------------------------------------
local E, C, L, DB = unpack(select(2, ...)) -- Import Functions/Constants, Config, Locales

if not C["datatext"].stat2 or C["datatext"].stat2 == 0 then return end

local Stat = CreateFrame("Frame")
Stat:EnableMouse(true)
Stat:SetFrameStrata("MEDIUM")
Stat:SetFrameLevel(3)

local Text  = ElvuiInfoLeft:CreateFontString(nil, "LOW")
Text:SetFont(C["media"].font, C["datatext"].fontsize, "THINOUTLINE")
Text:SetShadowOffset(E.mult, -E.mult)
E.PP(C["datatext"].stat2, Text)
Stat:SetParent(Text:GetParent())

local _G = getfenv(0)
local format = string.format
local chanceString = "%.2f%%"
local armorString = ARMOR..": "
local modifierString = string.join("", "%d (+", chanceString, ")")
local baseArmor, effectiveArmor, armor, posBuff, negBuff
local displayNumberString = string.join("", "%s", E.ValColor, "%d|r")
local displayFloatString = string.join("", "%s", E.ValColor, "%.2f%%|r")

local function CalculateMitigation(level, effective)
	local mitigation
	
	if not effective then
		_, effective, _, _, _ = UnitArmor("player")
	end
	
	if level < 60 then
		mitigation = (effective/(effective + 400 + (85 * level)));
	else
		mitigation = (effective/(effective + (467.5 * level - 22167.5)));
	end
	if mitigation > .75 then
		mitigation = .75
	end
	return mitigation
end

local function AddTooltipHeader(description)
	GameTooltip:AddLine(description)
	GameTooltip:AddLine(' ')
end

local function ShowTooltip(self)
	local anchor, panel, xoff, yoff = E.DataTextTooltipAnchor(Text)
	GameTooltip:SetOwner(panel, anchor, xoff, yoff)
	GameTooltip:ClearLines()
	
	if E.Role == "Tank" then
		AddTooltipHeader(L.datatext_mitigation)
		local lv = E.level +3
		for i = 1, 4 do
			GameTooltip:AddDoubleLine(lv,format(chanceString, CalculateMitigation(lv, effectiveArmor) * 100),1,1,1)
			lv = lv - 1
		end
		lv = UnitLevel("target")
		if lv and lv > 0 and (lv > E.level + 3 or lv < E.level) then
			GameTooltip:AddDoubleLine(lv, format(chanceString, CalculateMitigation(lv, effectiveArmor) * 100),1,1,1)
		end	
	elseif E.Role == "Caster" or E.Role == "Melee" then
		AddTooltipHeader(MAGIC_RESISTANCES_COLON)
		
		local baseResistance, effectiveResistance, posResitance, negResistance
		for i = 2, 6 do
			baseResistance, effectiveResistance, posResitance, negResistance = UnitResistance("player", i)
			GameTooltip:AddDoubleLine(_G["DAMAGE_SCHOOL"..(i+1)], format(chanceString, (effectiveResistance / (effectiveResistance + (500 + E.level + 2.5))) * 100),1,1,1)
		end
		
		local spellpen = GetSpellPenetration()
		if (E.class == "SHAMAN" or E.Role == "Caster") and spellpen > 0 then
			GameTooltip:AddLine' '
			GameTooltip:AddDoubleLine(ITEM_MOD_SPELL_PENETRATION_SHORT, spellpen,1,1,1)
		end
	end
	GameTooltip:Show()
end

local function UpdateTank(self)
	baseArmor, effectiveArmor, armor, posBuff, negBuff = UnitArmor("player");
	
	Text:SetFormattedText(displayNumberString, armorString, effectiveArmor)
	--Setup Tooltip
	self:SetAllPoints(Text)
end

local function UpdateCaster(self)
	local spellcrit = GetSpellCritChance(1)

	Text:SetFormattedText(displayFloatString, L.datatext_playercrit, spellcrit)
	--Setup Tooltip
	self:SetAllPoints(Text)
end

local function UpdateMelee(self)
	local meleecrit = GetCritChance()
	local rangedcrit = GetRangedCritChance()
	local critChance
		
	if E.myclass == "HUNTER" then    
		critChance = rangedcrit
	else
		critChance = meleecrit
	end
	
	Text:SetFormattedText(displayFloatString, L.datatext_playercrit, critChance)
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
